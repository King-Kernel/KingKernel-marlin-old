/*
 *  drivers/cpufreq/cpufreq_chill.c
 *
 *  Copyright (C)  2001 Russell King
 *            (C)  2003 Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>.
 *                      Jun Nakajima <jun.nakajima@intel.com>
 *            (C)  2009 Alexander Clouter <alex@digriz.org.uk>
 *            (C)  2016 Joe Maples <joe@frap129.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/slab.h>
<<<<<<< HEAD
<<<<<<< HEAD
#include "cpufreq_governor.h"
<<<<<<< HEAD
#include <linux/display_state.h>
=======
#include "cpufreq_chill.h"
=======
#include "cpufreq_governor.h"
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables
#ifdef CONFIG_POWERSUSPEND
#include <linux/powersuspend.h>
#endif
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h

/* Chill version macros */
<<<<<<< HEAD
#define CHILL_VERSION_MAJOR			(2)
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
#define CHILL_VERSION_MINOR			(0)
=======
#define CHILL_VERSION_MAJOR			(1)
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
#define CHILL_VERSION_MINOR			(1)
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
#define CHILL_VERSION_MINOR			(3)
>>>>>>> 89d2cfef07a... cpufreq: chill: Don't check for target frequency when boosting
=======
#define CHILL_VERSION_MINOR			(1)
>>>>>>> 6c66a250bd5... cpufreq: chill: Use native display_state instead of PowerSuspend
=======
#define CHILL_VERSION_MINOR			(2)
>>>>>>> 221f642107c... chill: Reset boost count at max regardless of whether we've boosted
=======
#define CHILL_VERSION_MINOR			(5)
>>>>>>> 25a07dd7e0d... chill: Decrease boost count alongside frequency
=======
#define CHILL_VERSION_MINOR			(6)
>>>>>>> 01d49229fb9... chill: Reset boost count on policy->min
=======
#define CHILL_VERSION_MINOR			(7)
>>>>>>> 2c60c27d59a... chill: Allow any number >= 1 for boost count
=======
#define CHILL_VERSION_MINOR			(8)
>>>>>>> a3b5ef08cb1... chill: Fix logic for reducing boost count with freq
=======
#define CHILL_VERSION_MINOR			(9)
>>>>>>> 3657ca1396f... chill: Fix down_threshold_suspended sysfs input
=======
#define CHILL_VERSION_MINOR			(3)
>>>>>>> 868d882e126... chill: I'm secretly retarded
=======
#define CHILL_VERSION_MINOR			(4)
>>>>>>> 3cf87276695... chill: Simplify boost increment logic
=======
#define CHILL_VERSION_MINOR			(10)
>>>>>>> 00c5a269f6a... Update Chill to 2.10
=======
#define CHILL_VERSION_MINOR			(2)
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
#define CHILL_VERSION_MINOR			(4)
>>>>>>> 2486219a5e3... cpufreq: chill: use GOV_CHILL macro
=======
#define CHILL_VERSION_MINOR			(5)
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables

/* Chill governor macros */
#define DEF_FREQUENCY_UP_THRESHOLD		(90)
#define DEF_FREQUENCY_DOWN_THRESHOLD		(40)
#define DEF_FREQUENCY_DOWN_THRESHOLD_SUSPENDED	(45)
#define DEF_FREQUENCY_STEP			(5)
<<<<<<< HEAD
#define DEF_SAMPLING_RATE			(20000)
#define DEF_BOOST_ENABLED			(0)
#define DEF_BOOST_COUNT				(8)
=======
#define DEF_SLEEP_DEPTH				(1)
#define DEF_SAMPLING_RATE			(20000)
#define DEF_BOOST_ENABLED			(1)
#define DEF_BOOST_COUNT				(3)
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
#define CHILL_VERSION_MINOR			(6)
=======
#define CHILL_VERSION_MINOR			(7)
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
=======
#define CHILL_VERSION_MINOR			(8)
>>>>>>> 0153a72f931... cpufreq: chill: Impliment down_threshold_suspended

/* Chill governor macros */
#define DEF_FREQUENCY_UP_THRESHOLD		(85)
#define DEF_FREQUENCY_DOWN_THRESHOLD		(30)
#define DEF_FREQUENCY_DOWN_THRESHOLD_SUSPENDED	(60)
#define DEF_FREQUENCY_STEP			(5)
#define DEF_SAMPLING_RATE			(20000)
#define DEF_BOOST_ENABLED			(1)
#define DEF_BOOST_COUNT				(7)
>>>>>>> d37f805276d... cpufreq: chill: Guard against 0 sleep depth and optimize defaults

static DEFINE_PER_CPU(struct cs_cpu_dbs_info_s, cs_cpu_dbs_info);
static DEFINE_PER_CPU(struct cs_dbs_tuners *, cached_tuners);

unsigned int boost_counter = 0;

=======
#ifdef CONFIG_POWERSUSPEND
#include <linux/powersuspend.h>
#endif

/* Chill version macros */
#define CHILL_VERSION_MAJOR		(1)
#define CHILL_VERSION_MINOR		(0)

/* Chill governor macros */
#define DEF_FREQUENCY_UP_THRESHOLD		(80)
#define DEF_FREQUENCY_DOWN_THRESHOLD		(20)
#define DEF_FREQUENCY_DOWN_THRESHOLD_SUSPENDED	(20)
#define DEF_FREQUENCY_STEP			(5)
#define DEF_SLEEP_DEPTH			(1)
#define DEF_SAMPLING_RATE		(20000)

static DEFINE_PER_CPU(struct cs_cpu_dbs_info_s, cs_cpu_dbs_info);

<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
static inline unsigned int get_freq_target(struct cs_dbs_tuners *cs_tuners,
=======
static inline unsigned int get_freq_target(struct chill_dbs_tuners *chill_tuners,
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
static inline unsigned int get_freq_target(struct cs_dbs_tuners *cs_tuners,
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables
					   struct cpufreq_policy *policy)
{
	unsigned int freq_target = (cs_tuners->freq_step * policy->max) / 100;

	/* max freq cannot be less than 100. But who knows... */
	if (unlikely(freq_target == 0))
		freq_target = DEF_FREQUENCY_STEP;

	return freq_target;
}

/*
 * Every sampling_rate, we check, if current idle time is less than 20%
 * (default), then we try to increase frequency. Every sampling_rate,
 *  we check, if current idle time is more than 80%
 * (default), then we try to decrease frequency
 *
 * Any frequency increase takes it to the maximum frequency. Frequency reduction
 * happens at minimum steps of 5% (default) of maximum frequency
 */
static void cs_check_cpu(int cpu, unsigned int load)
{
	struct cs_cpu_dbs_info_s *dbs_info = &per_cpu(cs_cpu_dbs_info, cpu);
	struct cpufreq_policy *policy = dbs_info->cdbs.cur_policy;
	struct dbs_data *dbs_data = policy->governor_data;
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;

<<<<<<< HEAD
	/* Create display state boolean */
	bool display_on = is_display_on();

	/* Once min frequency is reached while screen off, stop taking load samples*/
<<<<<<< HEAD
<<<<<<< HEAD
	if (power_suspended && policy->cur == policy->min)
=======
	if (!display_on && policy->cur == policy->min)
>>>>>>> 6c66a250bd5... cpufreq: chill: Use native display_state instead of PowerSuspend
		return;

=======
	if (power_suspended & policy->cur == policy->min)
		return;
#endif
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
=======
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	/*
	 * break out if we 'cannot' reduce the speed as the user might
	 * want freq_step to be zero
	 */
	if (cs_tuners->freq_step == 0)
		return;

<<<<<<< HEAD
<<<<<<< HEAD
	/* Check for frequency decrease */
	if (display_on && load < cs_tuners->down_threshold) {
		unsigned int freq_target;
		/*
		 * if we cannot reduce the frequency anymore, break out early
		 */
		if (policy->cur == policy->min)
=======
	/* Check for frequency increase */
	if (load > cs_tuners->up_threshold) {

		/* if we are already at full speed then break out early */
		if (dbs_info->requested_freq == policy->max)
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
			return;

<<<<<<< HEAD
<<<<<<< HEAD
=======
		/* reduce boost count with frequency */
		if (boost_counter > 0)
			boost_counter--;

>>>>>>> 25a07dd7e0d... chill: Decrease boost count alongside frequency
		freq_target = get_freq_target(cs_tuners, policy);
		if (dbs_info->requested_freq > freq_target)
			dbs_info->requested_freq -= freq_target;
		else {
			dbs_info->requested_freq = policy->min;
			boost_counter = 0;
		}
		__cpufreq_driver_target(policy, dbs_info->requested_freq,
				CPUFREQ_RELATION_L);
		return;
	} else if (!display_on && load <= cs_tuners->down_threshold_suspended) {
		unsigned int freq_target;
		/*
		 * if we cannot reduce the frequency anymore, break out early
		 */
		if (policy->cur == policy->min)
			return;

		freq_target = get_freq_target(cs_tuners, policy);
		if (dbs_info->requested_freq > freq_target)
			dbs_info->requested_freq -= freq_target;
		else {
			dbs_info->requested_freq = policy->min;
<<<<<<< HEAD
=======
		/* Boost if count is reached, otherwise increase freq */
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
		if (cs_tuners->boost_enabled && boost_counter >= cs_tuners->boost_count)
			dbs_info->requested_freq += get_freq_target(cs_tuners, policy->max);
=======
		if (chill_tuners->boost_enabled && boost_counter >= chill_tuners->boost_count)
=======
		if (cs_tuners->boost_enabled && boost_counter >= cs_tuners->boost_count)
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables
			dbs_info->requested_freq = policy->max;
>>>>>>> 89d2cfef07a... cpufreq: chill: Don't check for target frequency when boosting
=======
		if (chill_tuners->boost_enabled && boost_counter >= chill_tuners->boost_count)
			dbs_info->requested_freq += get_freq_target(chill_tuners, policy->max);
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
		else
			dbs_info->requested_freq += get_freq_target(cs_tuners, policy);

 		/* Make sure max hasn't been reached, otherwise increment boost_counter */
		if (dbs_info->requested_freq >= policy->max)
			dbs_info->requested_freq = policy->max;
		else
			boost_counter++;
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option

		__cpufreq_driver_target(policy, dbs_info->requested_freq,
				CPUFREQ_RELATION_L);
		return;
	}

<<<<<<< HEAD
<<<<<<< HEAD
=======
#ifdef CONFIG_POWERSUSPEND
	/* Check for frequency decrease */
	if (!power_suspended && load < cs_tuners->down_threshold) {
		unsigned int freq_target;
		/*
		 * if we cannot reduce the frequency anymore, break out early
		 */
		if (policy->cur == policy->min)
			return;

		freq_target = get_freq_target(cs_tuners, policy);
		if (dbs_info->requested_freq > freq_target)
			dbs_info->requested_freq -= freq_target;
		else
			dbs_info->requested_freq = policy->min;

		__cpufreq_driver_target(policy, dbs_info->requested_freq,
				CPUFREQ_RELATION_L);
		return;
	} else if (power_suspended && load <= cs_tuners->down_threshold_suspended) {
		unsigned int freq_target;
		/*
		 * if we cannot reduce the frequency anymore, break out early
		 */
		if (policy->cur == policy->min)
			return;

		freq_target = get_freq_target(cs_tuners, policy);
		if (dbs_info->requested_freq > freq_target)
			dbs_info->requested_freq -= freq_target;
		else
			dbs_info->requested_freq = policy->min;

		__cpufreq_driver_target(policy, dbs_info->requested_freq,
				CPUFREQ_RELATION_L);
		return;
	}

>>>>>>> 0153a72f931... cpufreq: chill: Impliment down_threshold_suspended
#else
=======
	/* Check for frequency increase */
	if (load > cs_tuners->up_threshold) {

		/* if we are already at full speed then break out early */
		if (dbs_info->requested_freq == policy->max)
			return;

#ifdef CONFIG_POWERSUSPEND
		/* if power is suspended then break out early */
		if (power_suspended)
			return;
#endif

		dbs_info->requested_freq += get_freq_target(cs_tuners, policy);

		if (dbs_info->requested_freq > policy->max)
			dbs_info->requested_freq = policy->max;

		__cpufreq_driver_target(policy, dbs_info->requested_freq,
			CPUFREQ_RELATION_H);
		return;
	}

>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	/* Check for frequency decrease */
	if (load < cs_tuners->down_threshold) {
		unsigned int freq_target;
		/*
		 * if we cannot reduce the frequency anymore, break out early
		 */
		if (policy->cur == policy->min)
			return;

		freq_target = get_freq_target(cs_tuners, policy);
		if (dbs_info->requested_freq > freq_target)
			dbs_info->requested_freq -= freq_target;
		else
			dbs_info->requested_freq = policy->min;
<<<<<<< HEAD
=======
			boost_counter = 0;
		}
>>>>>>> 01d49229fb9... chill: Reset boost count on policy->min
=======
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov

		__cpufreq_driver_target(policy, dbs_info->requested_freq,
				CPUFREQ_RELATION_L);
		return;
	}
<<<<<<< HEAD
#endif
<<<<<<< HEAD

=======
>>>>>>> 6c66a250bd5... cpufreq: chill: Use native display_state instead of PowerSuspend
	/* Check for frequency increase */
	if (load > cs_tuners->up_threshold) {

		/* if we are already at full speed then break out early */
		if (dbs_info->requested_freq == policy->max)
			return;

		/* if display is off then break out early */
		if (!display_on)
			return;

		/* Boost if count is reached, otherwise increase freq */
		if (cs_tuners->boost_enabled && boost_counter >= cs_tuners->boost_count) {
			dbs_info->requested_freq = policy->max;
			boost_counter = 0;
		} else {
			dbs_info->requested_freq += get_freq_target(cs_tuners, policy);
			boost_counter++;
		};

		__cpufreq_driver_target(policy, dbs_info->requested_freq,
			CPUFREQ_RELATION_H);
		return;
	}
=======
>>>>>>> 0153a72f931... cpufreq: chill: Impliment down_threshold_suspended
=======
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
}

static void cs_dbs_timer(struct work_struct *work)
{
	struct cs_cpu_dbs_info_s *dbs_info = container_of(work,
			struct cs_cpu_dbs_info_s, cdbs.work.work);
	unsigned int cpu = dbs_info->cdbs.cur_policy->cpu;
	struct cs_cpu_dbs_info_s *core_dbs_info = &per_cpu(cs_cpu_dbs_info,
			cpu);
	struct dbs_data *dbs_data = dbs_info->cdbs.cur_policy->governor_data;
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	int delay = delay_for_sampling_rate(cs_tuners->sampling_rate);
	bool modify_all = true;
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
	unsigned int sampling_rate_suspended = cs_tuners->sampling_rate * cs_tuners->sleep_depth;
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
=======
	unsigned int sampling_rate_suspended = chill_tuners->sampling_rate * chill_tuners->sleep_depth;
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
	unsigned int sampling_rate_suspended = cs_tuners->sampling_rate * cs_tuners->sleep_depth;
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables

	mutex_lock(&core_dbs_info->cdbs.timer_mutex);

	if (!need_load_eval(&core_dbs_info->cdbs, cs_tuners->sampling_rate))
		modify_all = false;
<<<<<<< HEAD
<<<<<<< HEAD
		else
=======
	else
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
=======
#ifdef CONFIG_POWERSUSPEND
	else if (power_suspended && need_load_eval(&core_dbs_info->cdbs, sampling_rate_suspended))
#else
	else
#endif
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
			dbs_check_cpu(dbs_data, cpu);

	gov_queue_work(dbs_data, dbs_info->cdbs.cur_policy, delay, modify_all);
	mutex_unlock(&core_dbs_info->cdbs.timer_mutex);
}

static int dbs_cpufreq_notifier(struct notifier_block *nb, unsigned long val,
		void *data)
{
	struct cpufreq_freqs *freq = data;
	struct cs_cpu_dbs_info_s *dbs_info =
					&per_cpu(cs_cpu_dbs_info, freq->cpu);
	struct cpufreq_policy *policy;

	if (!dbs_info->enable)
		return 0;

	policy = dbs_info->cdbs.cur_policy;

	/*
	 * we only care if our internally tracked freq moves outside the 'valid'
	 * ranges of frequency available to us otherwise we do not change it
	*/
	if (dbs_info->requested_freq > policy->max
			|| dbs_info->requested_freq < policy->min)
		dbs_info->requested_freq = freq->new;

	return 0;
}

/************************** sysfs interface ************************/
static struct common_dbs_data cs_dbs_cdata;

static ssize_t store_sampling_rate(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1)
		return -EINVAL;

	cs_tuners->sampling_rate = max(input, dbs_data->min_sampling_rate);
	return count;
}

static ssize_t store_up_threshold(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1 || input > 100 || input <= cs_tuners->down_threshold)
		return -EINVAL;

	cs_tuners->up_threshold = input;
	return count;
}

static ssize_t store_down_threshold(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	/* cannot be lower than 11 otherwise freq will not fall */
	if (ret != 1 || input < 11 || input > 100 ||
			input >= cs_tuners->up_threshold)
		return -EINVAL;

	cs_tuners->down_threshold = input;
	return count;
}

static ssize_t store_down_threshold_suspended(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	/* cannot be lower than 11 otherwise freq will not fall */
	if (ret != 1 || input < 11 || input > 100 ||
			input >= cs_tuners->up_threshold)
		return -EINVAL;

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
	cs_tuners->down_threshold_suspended = input;
=======
	cs_tuners->down_threshold = input;
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
=======
	chill_tuners->down_threshold = input;
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
	cs_tuners->down_threshold = input;
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables
	return count;
}

static ssize_t store_ignore_nice_load(struct dbs_data *dbs_data,
		const char *buf, size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input, j;
	int ret;

	ret = sscanf(buf, "%u", &input);
	if (ret != 1)
		return -EINVAL;

	if (input > 1)
		input = 1;

	if (input == cs_tuners->ignore_nice_load) /* nothing to do */
		return count;

	cs_tuners->ignore_nice_load = input;

	/* we need to re-evaluate prev_cpu_idle */
	for_each_online_cpu(j) {
		struct cs_cpu_dbs_info_s *dbs_info;
		dbs_info = &per_cpu(cs_cpu_dbs_info, j);
		dbs_info->cdbs.prev_cpu_idle = get_cpu_idle_time(j,
					&dbs_info->cdbs.prev_cpu_wall, 0);
		if (cs_tuners->ignore_nice_load)
			dbs_info->cdbs.prev_cpu_nice =
				kcpustat_cpu(j).cpustat[CPUTIME_NICE];
	}
	return count;
}

static ssize_t store_freq_step(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1)
		return -EINVAL;

	if (input > 100)
		input = 100;

	/*
	 * no need to test here if freq_step is zero as the user might actually
	 * want this, they would be crazy though :)
	 */
	cs_tuners->freq_step = input;
	return count;
}

<<<<<<< HEAD
<<<<<<< HEAD
static ssize_t store_boost_enabled(struct dbs_data *dbs_data, const char *buf,
=======
static ssize_t store_sleep_depth(struct dbs_data *dbs_data, const char *buf,
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1)
		return -EINVAL;

<<<<<<< HEAD
	if (input >= 1)
		input = 1;
	else
		input = 0;

	cs_tuners->boost_enabled = input;
	return count;
}

static ssize_t store_boost_count(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1)
		return -EINVAL;

	if (input >= 5)
		input = 5;

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
	if (input = 0)
		input = 0;

	cs_tuners->boost_count = input;
=======
	if (input < 1)
		input = 1;

	cs_tuners->sleep_depth = input;
>>>>>>> d37f805276d... cpufreq: chill: Guard against 0 sleep depth and optimize defaults
=======
	chill_tuners->sleep_depth = input;
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
	cs_tuners->sleep_depth = input;
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables
	return count;
}

=======
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
static ssize_t store_boost_enabled(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1)
		return -EINVAL;

	if (input >= 1)
		input = 1;
	else
		input = 0;

	cs_tuners->boost_enabled = input;
	return count;
}

static ssize_t store_boost_count(struct dbs_data *dbs_data, const char *buf,
		size_t count)
{
	struct cs_dbs_tuners *cs_tuners = dbs_data->tuners;
	unsigned int input;
	int ret;
	ret = sscanf(buf, "%u", &input);

	if (ret != 1)
		return -EINVAL;

	if (input < 1)
		input = 0;

<<<<<<< HEAD
	cs_tuners->boost_count = input;
=======
	if (input > 5)
		input = 5;

	cs_tuners->sleep_depth = input;
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	return count;
}

<<<<<<< HEAD
show_store_one(cs, sampling_rate);
show_store_one(cs, up_threshold);
show_store_one(cs, down_threshold);
show_store_one(cs, down_threshold_suspended);
show_store_one(cs, ignore_nice_load);
show_store_one(cs, freq_step);
<<<<<<< HEAD
<<<<<<< HEAD
=======
declare_show_sampling_rate_min(cs);
<<<<<<< HEAD
show_store_one(cs, sleep_depth);
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
show_store_one(cs, boost_enabled);
show_store_one(cs, boost_count);
=======
declare_show_sampling_rate_min(cs);
show_store_one(cs, sleep_depth);
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
=======
	chill_tuners->boost_count = input;
	return count;
}

show_store_one(chill, sampling_rate);
show_store_one(chill, up_threshold);
show_store_one(chill, down_threshold);
show_store_one(chill, down_threshold_suspended);
show_store_one(chill, ignore_nice_load);
show_store_one(chill, freq_step);
declare_show_sampling_rate_min(chill);
show_store_one(chill, sleep_depth);
show_store_one(chill, boost_enabled);
show_store_one(chill, boost_count);
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
	cs_tuners->boost_count = input;
	return count;
}

show_store_one(cs, sampling_rate);
show_store_one(cs, up_threshold);
show_store_one(cs, down_threshold);
show_store_one(cs, down_threshold_suspended);
show_store_one(cs, ignore_nice_load);
show_store_one(cs, freq_step);
declare_show_sampling_rate_min(cs);
show_store_one(cs, sleep_depth);
show_store_one(cs, boost_enabled);
show_store_one(cs, boost_count);
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables

gov_sys_pol_attr_rw(sampling_rate);
gov_sys_pol_attr_rw(up_threshold);
gov_sys_pol_attr_rw(down_threshold);
gov_sys_pol_attr_rw(down_threshold_suspended);
gov_sys_pol_attr_rw(ignore_nice_load);
gov_sys_pol_attr_rw(freq_step);
<<<<<<< HEAD
<<<<<<< HEAD
=======
gov_sys_pol_attr_ro(sampling_rate_min);
<<<<<<< HEAD
gov_sys_pol_attr_rw(sleep_depth);
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
gov_sys_pol_attr_rw(boost_enabled);
gov_sys_pol_attr_rw(boost_count);

static struct attribute *dbs_attributes_gov_sys[] = {
=======
gov_sys_pol_attr_ro(sampling_rate_min);
gov_sys_pol_attr_rw(sleep_depth);

static struct attribute *dbs_attributes_gov_sys[] = {
	&sampling_rate_min_gov_sys.attr,
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	&sampling_rate_gov_sys.attr,
	&up_threshold_gov_sys.attr,
	&down_threshold_gov_sys.attr,
	&down_threshold_suspended_gov_sys.attr,
	&ignore_nice_load_gov_sys.attr,
	&freq_step_gov_sys.attr,
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
	&sleep_depth_gov_sys.attr,
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
	&boost_enabled_gov_sys.attr,
	&boost_count_gov_sys.attr,
=======
	&sleep_depth_gov_sys.attr,
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	NULL
};

static struct attribute_group cs_attr_group_gov_sys = {
	.attrs = dbs_attributes_gov_sys,
	.name = "chill",
};

static struct attribute *dbs_attributes_gov_pol[] = {
<<<<<<< HEAD
=======
	&sampling_rate_min_gov_pol.attr,
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	&sampling_rate_gov_pol.attr,
	&up_threshold_gov_pol.attr,
	&down_threshold_gov_pol.attr,
	&down_threshold_suspended_gov_pol.attr,
	&ignore_nice_load_gov_pol.attr,
	&freq_step_gov_pol.attr,
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
	&sleep_depth_gov_pol.attr,
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
	&boost_enabled_gov_pol.attr,
	&boost_count_gov_pol.attr,
=======
	&sleep_depth_gov_pol.attr,
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov
	NULL
};

static struct attribute_group cs_attr_group_gov_pol = {
	.attrs = dbs_attributes_gov_pol,
	.name = "chill",
};

/************************** sysfs end ************************/

<<<<<<< HEAD
<<<<<<< HEAD
static void save_tuners(struct cpufreq_policy *policy,
			  struct cs_dbs_tuners *tuners)
{
	int cpu;

	if (have_governor_per_policy())
		cpu = cpumask_first(policy->related_cpus);
	else
		cpu = 0;

	WARN_ON(per_cpu(cached_tuners, cpu) &&
		per_cpu(cached_tuners, cpu) != tuners);
	per_cpu(cached_tuners, cpu) = tuners;
}

static struct cs_dbs_tuners *alloc_tuners(struct cpufreq_policy *policy)
=======
static int chill_init(struct dbs_data *dbs_data)
>>>>>>> 7d019fa8484... cpufreq: chill: Major cleanup, move changes from governor.h to chill.h
=======
static int cs_init(struct dbs_data *dbs_data)
>>>>>>> 55a9e8a3418... cpufreq: chill: Go back to using Conservative's tunables
{
	struct cs_dbs_tuners *tuners;

	tuners = kzalloc(sizeof(*tuners), GFP_KERNEL);
	if (!tuners) {
		pr_err("%s: kzalloc failed\n", __func__);
		return ERR_PTR(-ENOMEM);
	}

	tuners->up_threshold = DEF_FREQUENCY_UP_THRESHOLD;
	tuners->down_threshold = DEF_FREQUENCY_DOWN_THRESHOLD;
	tuners->down_threshold_suspended = DEF_FREQUENCY_DOWN_THRESHOLD_SUSPENDED;
	tuners->ignore_nice_load = 0;
	tuners->freq_step = DEF_FREQUENCY_STEP;
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
	tuners->sleep_depth = DEF_SLEEP_DEPTH;
>>>>>>> ef2a5fdce7b... cpufreq: chill: Add boost option
=======
>>>>>>> 155574ee802... cpufreq: chill: Replace sleep_depth with true load ignorance
	tuners->boost_enabled = DEF_BOOST_ENABLED;
	tuners->boost_count = DEF_BOOST_COUNT;
=======
	tuners->sleep_depth = DEF_SLEEP_DEPTH;
>>>>>>> 2be0437dd8e... cpufreq: Add Chill cpu gov

	save_tuners(policy, tuners);

	return tuners;
}

static struct cs_dbs_tuners *restore_tuners(struct cpufreq_policy *policy)
{
	int cpu;

	if (have_governor_per_policy())
		cpu = cpumask_first(policy->related_cpus);
	else
		cpu = 0;

	return per_cpu(cached_tuners, cpu);
}

static int cs_init(struct dbs_data *dbs_data, struct cpufreq_policy *policy)
{
	struct cs_dbs_tuners *tuners;

	tuners = restore_tuners(policy);
	if (!tuners) {
		tuners = alloc_tuners(policy);
		if (IS_ERR(tuners))
			return PTR_ERR(tuners);
	}

	dbs_data->tuners = tuners;
	dbs_data->min_sampling_rate = DEF_SAMPLING_RATE;
	mutex_init(&dbs_data->mutex);
	return 0;
}

static void cs_exit(struct dbs_data *dbs_data)
{
	//nothing to do
}

define_get_cpu_dbs_routines(cs_cpu_dbs_info);

static struct notifier_block cs_cpufreq_notifier_block = {
	.notifier_call = dbs_cpufreq_notifier,
};

static struct cs_ops cs_ops = {
	.notifier_block = &cs_cpufreq_notifier_block,
};

static struct common_dbs_data cs_dbs_cdata = {
	.governor = 1,
	.attr_group_gov_sys = &cs_attr_group_gov_sys,
	.attr_group_gov_pol = &cs_attr_group_gov_pol,
	.get_cpu_cdbs = get_cpu_cdbs,
	.get_cpu_dbs_info_s = get_cpu_dbs_info_s,
	.gov_dbs_timer = cs_dbs_timer,
	.gov_check_cpu = cs_check_cpu,
	.gov_ops = &cs_ops,
	.init = cs_init,
	.exit = cs_exit,
};

static int cs_cpufreq_governor_dbs(struct cpufreq_policy *policy,
				   unsigned int event)
{
	return cpufreq_governor_dbs(policy, &cs_dbs_cdata, event);
}

#ifndef CONFIG_CPU_FREQ_DEFAULT_GOV_CHILL
static
#endif
struct cpufreq_governor cpufreq_gov_chill = {
	.name			= "chill",
	.governor		= cs_cpufreq_governor_dbs,
	.max_transition_latency	= TRANSITION_LATENCY_LIMIT,
	.owner			= THIS_MODULE,
};

static int __init cpufreq_gov_dbs_init(void)
{
	return cpufreq_register_governor(&cpufreq_gov_chill);
}

static void __exit cpufreq_gov_dbs_exit(void)
{
	int cpu;

	cpufreq_unregister_governor(&cpufreq_gov_chill);
	for_each_possible_cpu(cpu) {
		kfree(per_cpu(cached_tuners, cpu));
		per_cpu(cached_tuners, cpu) = NULL;
	}
}

MODULE_AUTHOR("Alexander Clouter <alex@digriz.org.uk>");
MODULE_AUTHOR("Joe Maples <joe@frap129.org>");
MODULE_DESCRIPTION("'cpufreq_chill' - A dynamic cpufreq governor for "
		"Low Latency Frequency Transition capable processors "
		"optimised for use in a battery environment");
MODULE_LICENSE("GPL");

#ifdef CONFIG_CPU_FREQ_DEFAULT_GOV_CHILL
fs_initcall(cpufreq_gov_dbs_init);
#else
module_init(cpufreq_gov_dbs_init);
#endif
module_exit(cpufreq_gov_dbs_exit);

