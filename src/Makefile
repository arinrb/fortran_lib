# Constants
MY_ERB ?= erb -T - -P
MY_GFORTRAN_DEBUG ?= gfortran -ffree-line-length-none -fmax-identifier-length=63 -pipe -cpp -C -Wall -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG
MY_IFORT_DEBUG ?= ifort -fpp -warn -assume realloc_lhs -no-ftz -check -trace -O0 -p -g -DDEBUG
MY_FORTRAN_DEBUG ?= $(MY_GFORTRAN_DEBUG)
# MY_FORTRAN_DEBUG ?= $(MY_IFORT_DEBUG)
MY_RUBY ?= ruby

ERB := ${MY_ERB} -T '-' -P
FC := ${MY_FORTRAN_DEBUG}
RUBY := ${MY_RUBY}

# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
.SECONDARY:
.PRECIOUS:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

# Commands
.PHONY: all test

NAMES := $(shell cat names.txt)
TESTS := $(addsuffix .tested,$(filter %_test,$(NAMES)))
EXECS := $(addprefix ../bin/,$(addsuffix .exe,$(filter-out %_test %_lib,$(NAMES))))

ERRORTEST_RB_SRCS := $(shell git ls-files *_errortest.rb)
ERRORTESTS := $(ERRORTEST_RB_SRCS:%.rb=%.make)

all: $(EXECS)
test: $(TESTS) $(ERRORTESTS)

include $(addsuffix .make,$(NAMES))

# Tasks
io_lib_errortest.make: io_lib_errortest.rb config_lib.o constant_lib.o character_lib.o comparable_lib.o io_lib.o io_lib_test.o
	${RUBY} errortest_generate.rb $<
binary_tree_map_lib_errortest.make: binary_tree_map_lib_errortest.rb binary_tree_map_lib.o binary_tree_map_lib_test.o
	${RUBY} errortest_generate.rb $<
sac_lib_errortest.make: sac_lib_errortest.rb character_lib.o sac_lib.o sac_lib_test.o
	${RUBY} errortest_generate.rb $<

# Rules
%.F90: %.F90.erb
	$(ERB) $^ >| $@
%.make: %.F90
	make_fort_deps.sh $* >| $@
%.tested: %.exe
	./$<
	touch $@
../bin/%.exe: %.exe
	\cp -f $< $@
