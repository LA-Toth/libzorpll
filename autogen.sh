#!/bin/bash
#
# Run this script to generate Makefile skeletons and configure
# scripts.
#
PREFIX=
if [[ $(which libtoolize) == '' && $(which glibtoolize) ]]; then
  PREFIX=g
fi

${PREFIX}libtoolize -f --copy || exit 1
aclocal $* || exit 1
autoheader || exit 1
automake --add-missing --force-missing --copy || exit 1
autoconf || exit 1
