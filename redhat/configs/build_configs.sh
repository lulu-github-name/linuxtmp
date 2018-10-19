#!/bin/bash
#
# This script merges together the hierarchy of CONFIG_* files under generic
# and debug to form the necessary $PACKAGE_NAME<version>-<arch>-<variant>.config
# files for building RHEL kernels, based on the contents of a control file

PACKAGE_NAME=$1 # defines the package name used
SUBARCH=$2 # defines a specific arch for use with rh-configs-arch-prep target

set errexit
set nounset

control_file="priority"

function combine_config_layer()
{
	dir=$1
	file="config-$(echo $dir | sed -e 's|/|-|g')"

	if [ $(ls $dir/ | grep -c "^CONFIG_") -eq 0 ]; then
		touch $file
		return
	fi

	grep -Eh -e '# CONFIG_[_A-Z0-9]+ is not set' -e '^[^#]' \
		$dir/CONFIG_* > $file
}

function merge_configs()
{
	archvar=$1
	arch=$(echo "$archvar" | cut -f1 -d"-")
	configs=$2
	name=$PACKAGE_NAME-$archvar.config
	echo -n "Building $name ... "
	touch config-merging config-merged
	for config in $(echo $configs | sed -e 's/:/ /g')
	do
		perl merge.pl config-$config config-merging > config-merged
		mv config-merged config-merging
	done
	if [ "x$arch" == "xaarch64" ]; then
		echo "# arm64" > $name
	elif [ "x$arch" == "xppc64" ]; then
		echo "# powerpc" > $name
	elif [ "x$arch" == "xppc64le" ]; then
		echo "# powerpc" > $name
	elif [ "x$arch" == "xs390x" ]; then
		echo "# s390" > $name
	else
		echo "# $arch" > $name
	fi
	sort config-merging >> $name
	rm -f config-merged config-merging
	echo "done"
}

glist=$(find generic -type d)
dlist=$(find debug -type d)

for d in $glist $dlist
do
	combine_config_layer $d
done

while read line
do
	if [ $(echo "$line" | grep -c "^#") -ne 0 ]; then
		continue
	elif [ $(echo "$line" | grep -c "^$") -ne 0 ]; then
		continue
	else
		arch=$(echo "$line" | cut -f1 -d"=")
		configs=$(echo "$line" | cut -f2 -d"=")

		if [ -n "$SUBARCH" -a "$SUBARCH" != "$arch" ]; then
			continue
		fi
		merge_configs $arch $configs
	fi
done < $control_file

rm -f config-*
