/* SPDX-License-Identifier: GPL-2.0 */
/*
 * BPF programs attached to network namespace
 */

#ifndef __NETNS_BPF_H__
#define __NETNS_BPF_H__

#include <linux/bpf-netns.h>

struct bpf_prog;

/* RHEL: The struct netns_bpf can be changed between releases and is not
 * kABI stable. */
struct netns_bpf {
	struct bpf_prog __rcu *progs[MAX_NETNS_BPF_ATTACH_TYPE];
};

#endif /* __NETNS_BPF_H__ */
