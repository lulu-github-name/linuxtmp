/*
 *  Copyright (C) 2018  Red Hat, Inc.
 *
 *  This work is licensed under the terms of the GNU GPL, version 2. See
 *  the COPYING file in the top-level directory.
 */

#include <linux/cpu.h>
#include <linux/percpu.h>
#include <linux/uaccess.h>
#include <asm/spec_ctrl.h>
#include <asm/cpufeature.h>
#include <asm/nospec-branch.h>
#include <asm/cpu.h>

/*
 * Kernel IBRS speculation control structure
 */
DEFINE_PER_CPU(struct kernel_ibrs_spec_ctrl, spec_ctrl_pcp);
