HOSTNAME ?= $(shell uname -n)

VM_BIN := ./result/bin/run-$(HOSTNAME)-vm

DEBUG ?= 0

NIX_SRCS := $(wildcard **/*.nix)

ifeq ($(DEBUG),1)
	NIX_FLAGS = --show-trace
else
	NIX_FLAGS =
endif

c: check
check:
	nix flake check --impure $(NIX_FLAGS) path:.

vm: $(VM_BIN)
	rm -f ./plutus.qcow2
	$(VM_BIN) -vga virtio -cpu host -smp 4

build:
	nix build path:.#nixosConfigurations."$(HOSTNAME)".config.system.build.toplevel --impure

$(VM_BIN): $(NIX_SRCS)
	nixos-rebuild build-vm --flake path:.#$(HOSTNAME) --impure $(NIX_FLAGS)

