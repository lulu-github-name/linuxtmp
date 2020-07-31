#!/bin/bash

set -u

KERNELDIR="$(dirname ${PWD})"

cat <<EOF > mock.cfg.tmp
config_opts['chroot_setup_cmd'] = """--releasever=${RHEL_MAJOR} install
    bash bc bison bzip2 coreutils cpio diffutils dwarves
    elfutils-libelf-devel findutils flex
    gawk gcc gcc-c++ grep gzip git-core
    hostname info make openssl openssl-devel
    patch perl-interpreter python3
    sed shadow-utils tar unzip util-linux which xz
"""
config_opts['chroothome'] = '/builddir'
config_opts['dnf_warning'] = True
config_opts['package_manager'] = 'dnf'
config_opts['root'] = 'rhel-${RHEL_MAJOR}.${RHEL_MINOR}.0-build-${USER}'
config_opts['rpmbuild_networking'] = False
config_opts['rpmbuild_timeout'] = 86400
config_opts['target_arch'] = '${CURARCH}'
config_opts['use_host_resolv'] = False
config_opts['yum.conf'] = """\
[main]
cachedir=/var/cache/yum
debuglevel=1
logfile=/var/log/yum.log
reposdir=/dev/null
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
keepcache=1
install_weak_deps=0
strict=1
[build]
name=build
baseurl=http://download.devel.redhat.com/brewroot/repos/rhel-${RHEL_MAJOR}.${RHEL_MINOR}.0-build/latest/${CURARCH}
module_hotfixes=1
"""
config_opts['plugin_conf']['ccache_enable'] = False
config_opts['plugin_conf']['root_cache_enable'] = False
config_opts['plugin_conf']['yum_cache_enable'] = False
config_opts['clean'] = False
config_opts['cleanup_on_failure'] = False
config_opts['cleanup_after'] = False
config_opts['plugin_conf']['bind_mount_opts']['dirs'].append(('${KERNELDIR}', '/builddir'))
EOF
