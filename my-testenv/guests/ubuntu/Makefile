# Makefile to build the guest filesystem image based on Ubuntu 22.04

QEMU_BIN_PREFIX          = ../../../build
export PATH := $(realpath $(shell pwd)/$(QEMU_BIN_PREFIX)):$(PATH)

DOWNLOAD_DIR             = downloads
WORK_DIR                 = work
BUILD_DIR                = build
KERNELS_DIR              = kernels

UBUNTU_VERSIONS          = 22.04 24.04
UBUNTU_ARCH              = x86_64

BASE_IMAGES              = $(addprefix guest_base_ubuntu_, $(addsuffix _$(UBUNTU_ARCH).img, $(UBUNTU_VERSIONS)))

UBUNTU_2204_X86_URL      = https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
UBUNTU_2404_X86_URL      = https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

ALL_IMAGES               = $(BASE_IMAGES)


# ---------------------------------------------------------------------
#  USAGE
# ---------------------------------------------------------------------

.PHONY: usage

usage:
	@echo "Build images for qemu."
	@echo
	@echo "Available targets:"
	@echo "  all          Build all images."
	@echo "  build/<IMG>  Build only the specified image."
	@echo "               Possible base images:"
	@for IMG in $(BASE_IMAGES); do \
	  echo "                 $(BUILD_DIR)/$$IMG"; \
	  done
	@echo "  qemu-<IMG>   Start a qemu using the specified image."
	@echo "               Possible qemu runs with one of the base images:"
	@for IMG in $(BASE_IMAGES); do \
	  echo "                 qemu/$$IMG"; \
	  done
	@echo "  ssh          Open a ssh into the image."
	@echo "  clean        Clean the workspace."
	@echo "  distclean    Clean the workspace including built kernels."
	@echo


# ---------------------------------------------------------------------
#  ALL TARGET
# ---------------------------------------------------------------------
all: $(addprefix $(BUILD_DIR)/, $(ALL_IMAGES))


# ---------------------------------------------------------------------
#  CLEANUP
# ---------------------------------------------------------------------
.PHONY: clean distclean

clean:
	@find . -iname "*~" -exec rm -f {} \;
	@rm -f $(BUILD_DIR)/kernel_builder_*

distclean: clean
	@rm -rf $(BUILD_DIR) $(KERNELS_DIR) $(WORK_DIR)


# ---------------------------------------------------------------------
#  DOWNLOAD TARGETS
# ---------------------------------------------------------------------
$(DOWNLOAD_DIR)/ubuntu_22.04_x86_64.img:
	@mkdir -p $(DOWNLOAD_DIR)
	@echo "Downloading $@ from $(UBUNTU_2204_X86_URL)"
	@curl -o $@ $(UBUNTU_2204_X86_URL)

$(DOWNLOAD_DIR)/ubuntu_24.04_x86_64.img:
	@mkdir -p $(DOWNLOAD_DIR)
	@echo "Downloading $@ from $(UBUNTU_2404_X86_URL)"
	@curl -o $@ $(UBUNTU_2404_X86_URL)


# ---------------------------------------------------------------------
#  X86 BUILD TARGETS
# ---------------------------------------------------------------------
$(BUILD_DIR)/guest_base_ubuntu_%_$(UBUNTU_ARCH).img: $(DOWNLOAD_DIR)/ubuntu_%_$(UBUNTU_ARCH).img
	@mkdir -p "$(BUILD_DIR)" "$(WORK_DIR)"
	@scripts/create_base_image.sh "$@" "$<" "$(WORK_DIR)/$(notdir $@)"


# ---------------------------------------------------------------------
#  TEST QEMU RUNS
# ---------------------------------------------------------------------
QEMU_TARGETS = $(addprefix qemu/, $(BASE_IMAGES))

#.PHONY: $(QEMU_TARGETS)

qemu/%: $(BUILD_DIR)/%
	qemu-system-x86_64 -m 8G \
	  -smp 16 \
	  -enable-kvm \
      -drive if=virtio,file=$<,cache=none \
      -net user,hostfwd=tcp::2242-:22 -net nic -nographic


.PHONY: ssh

ssh:
	@ssh -p 2242 -i ../ssh_keys/qemu -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null root@localhost
