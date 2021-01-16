/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _ASM_X86_DEVICE_H
#define _ASM_X86_DEVICE_H

struct dev_archdata {
#if defined(CONFIG_INTEL_IOMMU) || defined(CONFIG_AMD_IOMMU)
	void *iommu; /* hook for IOMMU specific extension */
#endif
#ifdef CONFIG_STA2X11
	bool is_sta2x11;
#endif
};

struct pdev_archdata {
};

#endif /* _ASM_X86_DEVICE_H */
