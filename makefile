ifeq ($(filter rh-% rhg-%,$(MAKECMDGOALS)),)
	include Makefile
endif

_OUTPUT := "."
# this section is needed in order to make O= to work
ifeq ("$(origin O)", "command line")
  _OUTPUT := "$(abspath $(O))"
  _EXTRA_ARGS := O=$(_OUTPUT)
endif

ifeq ($(firstword $(MAKECMDGOALS)), rh-mock)
export MOCK_TARGETS = $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
%: ;
rh-mock:
	$(MAKE) -C redhat $(MAKECMDGOALS) $(_EXTRA_ARGS)
endif

rh-%::
	$(MAKE) -C redhat $(@) $(_EXTRA_ARGS)

rhg-%::
	$(MAKE) -C redhat $(@) $(_EXTRA_ARGS)

