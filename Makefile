PROJECT = test_edocker
PROJECT_DESCRIPTION = Testing edocker
PROJECT_VERSION = 0.1.1

DEPS = lager gun jiffy

include erlang.mk
include edocker.mk
