# Makefile for lfsr-generator.
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

bin_SCRIPTS = lfsr-generator
TESTS = \
	fibonacci-singleshift-test \
	fibonacci-multishift-test \
	galois-test
check_SCRIPTS = test-engine $(TESTS)
BUILT_SOURCES = shift_lfsr_c.h shift_lfsr_c.c shift_lfsr_cplusplus.h
noinst_PROGRAMS = prng-sample-c
prng_sample_c_SOURCES = prng_sample_c.c
nodist_prng_sample_c_SOURCES = shift_lfsr_c.h shift_lfsr_c.c
if CXX_AVAILABLE
noinst_PROGRAMS += prng-sample-cplusplus
prng_sample_cplusplus_SOURCES = prng_sample_cplusplus.cc
nodist_prng_sample_cplusplus_SOURCES = shift_lfsr_cplusplus.h
endif
CLEANFILES = $(BUILT_SOURCES)
EXTRA_DIST = shift_lfsr_test.c

prng_sample_config = \
	--config=fibonacci \
	--length=31 \
	--taps=31,18 \
	--shift-amounts=12,12,8 \
	--shift-left

shift_lfsr_c.h: lfsr-generator
	$(builddir)/lfsr-generator \
	  --header \
	  --variable-type='unsigned long' \
	  > $@

shift_lfsr_c.c: lfsr-generator
	$(builddir)/lfsr-generator \
	  $(prng_sample_config) \
	  --variable-type='unsigned long' \
	  > $@

shift_lfsr_cplusplus.h: lfsr-generator
	$(builddir)/lfsr-generator \
	  $(prng_sample_config) \
	  --function-qualifier=inline \
	  --function-template \
	  --namespace=lfsr \
	  > $@
