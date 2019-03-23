// SPDX-License-Identifier: GPL-2.0
/*
 * CorePower - System power state optimizer
 *
 * Copyright (C) 2019 Danny Lin <danny@kdrag0n.dev>.
 */

#define pr_fmt(fmt) "corepower: " fmt

#include <linux/cpu.h>
#include <linux/cpuidle.h>
#include <linux/display_state.h>
#include <linux/input.h>
#include <linux/moduleparam.h>
#include <linux/fb.h>
#include <linux/slab.h>
#include <soc/qcom/lpm_levels.h>
#include <linux/sched.h>
#include <linux/types.h>

#define ST_ROOT "/"

enum power_state {
	STATE_UNKNOWN = 0,
	STATE_AWAKE,
	STATE_WAKING,
	STATE_SLEEP,
};

static atomic_t current_state;
static atomic_t next_state;
static struct workqueue_struct *power_state_wq;

static bool enabled __read_mostly = true;
static short wake_timeout __read_mostly = CONFIG_COREPOWER_WAKE_TIMEOUT;
module_param(wake_timeout, short, 0644);

static bool cpu_force_deep_idle __read_mostly = true;
static bool cluster_force_deep_idle __read_mostly = true;
static __read_mostly int suspend_stune_boost = CONFIG_SUSPEND_STUNE_BOOST;

/* Core */
static enum power_state get_current_state(void)
{
	return atomic_read(&current_state);
}

static bool is_state_intensive(enum power_state state)
{
	return state == STATE_AWAKE || state == STATE_WAKING;
}

static void state_update_worker(struct work_struct *work)
{
	enum power_state state = atomic_read(&next_state);
	bool intensive;
	int ret;

	if (!enabled)
		goto skip_update;

	intensive = is_state_intensive(state);

	/* Do nothing if we are already in this state, unless forced */
	if (state == get_current_state())
		goto skip_update;

	/* Force use of the deepest CPU idle state available */
	if (cpu_force_deep_idle) {
		get_online_cpus();
		ret = cpuidle_use_deepest_state_mask(cpu_online_mask,
						     !intensive);
		put_online_cpus();
		if (ret)
			goto skip_update;
	}

	/* Force use of the deepest CPU cluster idle state available */
	if (cluster_force_deep_idle)
		lpm_cluster_use_deepest_state(!intensive);

skip_update:
	atomic_set(&current_state, state);
	atomic_set(&next_state, STATE_UNKNOWN);
}
static DECLARE_WORK(state_update_work, state_update_worker);

static void update_state(enum power_state target_state, bool sync)
{
	atomic_set(&next_state, target_state);
	queue_work(power_state_wq, &state_update_work);

	if (sync)
		flush_work(&state_update_work);
}

static void wake_reset_worker(struct work_struct *unused)
{
	flush_work(&state_update_work);

	if (get_current_state() == STATE_WAKING)
		update_state(STATE_SLEEP, false);
}
static DECLARE_DELAYED_WORK(wake_reset_work, wake_reset_worker);

void corepower_wake(void)
{
	update_state(STATE_WAKING, false);
	queue_delayed_work(power_state_wq, &wake_reset_work,
			   msecs_to_jiffies(wake_timeout));
}

/* Parameter handlers */
static int param_bool_set(const char *buf, const struct kernel_param *kp)
{
	enum power_state old_state = get_current_state();
	int ret;

	flush_work(&state_update_work);
	if (old_state != STATE_AWAKE) {
		/* Toggle state to make the change take effect */
		update_state(STATE_AWAKE, true);
		ret = param_set_bool(buf, kp);
		update_state(old_state, true);
	} else {
		ret = param_set_bool(buf, kp);
	}

	return ret;
}

static const struct kernel_param_ops bool_param_ops = {
	.set = param_bool_set,
	.get = param_get_bool,
};

static int param_uint_set(const char *buf, const struct kernel_param *kp)
{
	enum power_state old_state = get_current_state();
	int ret;

	flush_work(&state_update_work);
	if (old_state != STATE_AWAKE) {
		/* Toggle state to make the change take effect */
		update_state(STATE_AWAKE, true);
		ret = param_set_uint(buf, kp);
		update_state(old_state, true);
	} else {
		ret = param_set_uint(buf, kp);
	}

	return ret;
}

static const struct kernel_param_ops uint_param_ops = {
	.set = param_uint_set,
	.get = param_get_uint,
};

module_param_cb(enabled, &bool_param_ops, &enabled, 0644);
module_param_cb(cpu_force_deep_idle, &bool_param_ops, &cpu_force_deep_idle,
		0644);
module_param_cb(cluster_force_deep_idle, &bool_param_ops,
		&cluster_force_deep_idle, 0644);

/* Base */
static int fb_notifier_cb(struct notifier_block *nb, unsigned long event,
			       void *data)
{
	struct fb_event *evdata = data;
	unsigned int blank;
	int root_stune_boost_default = INT_MIN;

	if (event != FB_EVENT_BLANK && event != FB_EARLY_EVENT_BLANK)
		return NOTIFY_DONE;

	if (!evdata || !evdata->data)
		return NOTIFY_DONE;

	blank = *(unsigned int *)evdata->data;

	switch (blank) {
	case FB_BLANK_POWERDOWN: /* Off */
		if (event == FB_EARLY_EVENT_BLANK)
			update_state(STATE_SLEEP, false);
			set_stune_boost(ST_ROOT, suspend_stune_boost,
					&root_stune_boost_default);
		break;
	case FB_BLANK_UNBLANK: /* On */
		if (event == FB_EVENT_BLANK)
			update_state(STATE_AWAKE, false);
						if (root_stune_boost_default != INT_MIN)
				set_stune_boost(ST_ROOT, root_stune_boost_default, NULL);
		break;
	}

	return NOTIFY_OK;
}

static struct notifier_block display_state_nb __ro_after_init = {
	.notifier_call = fb_notifier_cb,
};

static void corepower_input_event(struct input_handle *handle,
				  unsigned int type, unsigned int code,
				  int value)
{
	if (code == KEY_POWER && value == 1 && !is_display_on() &&
	    get_current_state() == STATE_SLEEP)
		corepower_wake();
}

static int corepower_input_connect(struct input_handler *handler,
				   struct input_dev *dev,
				   const struct input_device_id *id)
{
	struct input_handle *handle;
	int ret;

	handle = kzalloc(sizeof(*handle), GFP_KERNEL);
	if (!handle)
		return -ENOMEM;

	handle->dev = dev;
	handle->handler = handler;
	handle->name = "corepower_handle";

	ret = input_register_handle(handle);
	if (ret)
		goto err_free_handle;

	ret = input_open_device(handle);
	if (ret)
		goto err_unreg_handle;

	return 0;

err_unreg_handle:
	input_unregister_handle(handle);
err_free_handle:
	kfree(handle);
	return ret;
}

static void corepower_input_disconnect(struct input_handle *handle)
{
	input_close_device(handle);
	input_unregister_handle(handle);
	kfree(handle);
}

static const struct input_device_id corepower_input_ids[] = {
	/* Power button */
	{
		.flags = INPUT_DEVICE_ID_MATCH_EVBIT,
		.evbit = { BIT_MASK(EV_KEY) },
		.keybit = { [BIT_WORD(KEY_POWER)] = BIT_MASK(KEY_POWER) },
	},
	{}
};

static struct input_handler corepower_input_handler = {
	.name = "corepower_handler",
	.event = corepower_input_event,
	.connect = corepower_input_connect,
	.disconnect = corepower_input_disconnect,
	.id_table = corepower_input_ids
};

static int __init corepower_init(void)
{
	int ret;

	power_state_wq =
		alloc_workqueue("corepower_wq", WQ_HIGHPRI | WQ_UNBOUND, 0);
	if (!power_state_wq)
		return -ENOMEM;

	ret = input_register_handler(&corepower_input_handler);
	if (ret) {
		pr_err("Failed to register input handler, err: %d\n", ret);
		goto err_destroy_wq;
	}

	ret = fb_register_client(&display_state_nb);
	if (ret)
		pr_err("Failed to register fb notifier, err: %d\n", ret);

	return 0;

err_destroy_wq:
	destroy_workqueue(power_state_wq);
	return ret;
}
late_initcall(corepower_init);
