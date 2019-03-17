/*
 * Suspend state tracker driver
 *
 * Copyright (c) 2013-2017, Pranav Vashi <neobuddy89@gmail.com>
 *           (c) 2017, Joe Maples <joe@frap129.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#include <linux/export.h>
#include <linux/module.h>
#include <linux/fb.h>

bool state_suspended;
module_param(state_suspended, bool, 0444);

static int fb_notifier_cb(struct notifier_block *nb,
			       unsigned long event, void *data)
{
	struct fb_event *evdata = data;
	unsigned int blank;

	if (event != FB_EVENT_BLANK && event != FB_EARLY_EVENT_BLANK)
		return NOTIFY_DONE;

	if (!evdata || !evdata->data)
		return NOTIFY_DONE;

	blank = *(unsigned int *)evdata->data;

	switch (blank) {
	case FB_BLANK_POWERDOWN:
		if (event == FB_EARLY_EVENT_BLANK)
			state_suspended = true;
		break;
	case FB_BLANK_UNBLANK:
		if (event == FB_EVENT_BLANK)
			state_suspended = false;
		break;
	}

	return NOTIFY_OK;
}

static struct notifier_block display_state_nb __ro_after_init = {
	.notifier_call = fb_notifier_cb,
};

static int __init state_notifier_init(void)
{
	int ret;

	ret = fb_register_client(&display_state_nb);
	if (ret)
		pr_err("Failed to register fb notifier, err: %d\n", ret);

	return ret;
}
late_initcall(state_notifier_init);

MODULE_AUTHOR("Pranav Vashi <neobuddy89@gmail.com>");
MODULE_DESCRIPTION("Suspend state tracker");
MODULE_LICENSE("GPLv2");
