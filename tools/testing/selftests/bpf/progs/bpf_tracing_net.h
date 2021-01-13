/* SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause) */
#ifndef __BPF_TRACING_NET_H__
#define __BPF_TRACING_NET_H__

#define IFNAMSIZ		16

#define RTF_GATEWAY		0x0002

#define sk_rmem_alloc		sk_backlog.rmem_alloc
#define sk_refcnt		__sk_common.skc_refcnt

#endif
