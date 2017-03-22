# configure.ac for lfsr-generator.
# Copyright (C) 2007  Wakabayashi Masaki
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

# Initialize for autoconf and automake
AC_PREREQ([2.58])
m4_include([version.m4])
AC_INIT([lfsr-generator], VERSION_NUMBER)
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.9 -Wall])
AC_CONFIG_SRCDIR([src/lfsr-generator.in])
AC_CONFIG_HEADERS([build-aux/config.h])
AM_MAINTAINER_MODE

# Checks for programs
AC_PROG_CC
AC_PROG_CXX
AC_PATH_PROG(PERL, perl, [AC_MSG_WARN([perl not found.])])
AC_CHECK_PROG(CXX_AVAILABLE, $CXX, yes, no)
AM_CONDITIONAL([CXX_AVAILABLE], [test x$CXX_AVAILABLE = xyes])

# Checks for compiler characteristics
AC_CHECK_SIZEOF([long])

# Output results
AC_CONFIG_FILES([
  Makefile
  build-aux/Makefile
  src/Makefile
])
AC_CONFIG_FILES([src/lfsr-generator], [chmod +x src/lfsr-generator])
AC_CONFIG_FILES([src/test-engine], [chmod +x src/test-engine])
AC_CONFIG_FILES([src/fibonacci-singleshift-test], [chmod +x src/fibonacci-singleshift-test])
AC_CONFIG_FILES([src/fibonacci-multishift-test], [chmod +x src/fibonacci-multishift-test])
AC_CONFIG_FILES([src/galois-test], [chmod +x src/galois-test])
AC_OUTPUT
