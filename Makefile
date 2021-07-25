HOSTNAME ?= $(shell uname -n)

VM_BIN := ./result/bin/run-$(HOSTNAME)-vm

DEBUG ?= 0

ifeq ($(DEBUG),1)
	NIX_FLAGS = --show-trace
else
	NIX_FLAGS =
endif

c: check
check:
	nix flake check --impure $(NIX_FLAGS)

vm: build-vm
	$(VM_BIN)

build-vm:
	nixos-rebuild build-vm --flake .#$(HOSTNAME) --impure $(NIX_FLAGS)

