HOSTNAME ?= $(shell uname -n)

SRCS := $(find . -type f ! -path "./.git/*")

VM_BIN := ./result/bin/run-$(HOSTNAME)-vm

DEBUG ?= 0

ifeq ($(DEBUG),1)
	CHECK_FLAGS = --show-trace
else
	CHECK_FLAGS =
endif

c: check
check:
	nix flake check --impure $(CHECK_FLAGS)

vm: $(VM_BIN)
	$(VM_BIN)

$(VM_BIN): $(SRCS)
	nixos-rebuild build-vm --flake .#$(HOSTNAME) --impure

