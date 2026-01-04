#!/usr/bin/env bash

VM_NAME="$1"
ISO_PATH="$2"

if [[ $VM_NAME = "" || $ISO_PATH = "" ]]; then
  echo "Usage: $0 <vm-name> <iso path>" >&2
  exit 1
fi

DISK_IMG="/var/lib/libvirt/images/${VM_NAME}.qcow2"
RAM_MB="${5:-4096}"
VCPUS="${6:-2}"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "ISO not found at $ISO_PATH" >&2
  exit 1
fi

echo "Creating disk image $DISK_IMG..."
sudo qemu-img create -f qcow2 "$DISK_IMG" 40G

echo "Launching $VM_NAME for ISO installation..."
sudo virt-install \
  --name "$VM_NAME" \
  --memory "$RAM_MB" \
  --vcpus "$VCPUS" \
  --disk path="$DISK_IMG",format=qcow2 \
  --cdrom "$ISO_PATH" \
  --osinfo detect=on,require=off \
  --network network=routed-net,model=virtio \
  --graphics none \
  --console pty,target_type=serial \
  --boot cdrom,hd,useserial=on \
  --noautoconsole

echo ""
echo "=============================================="
echo "VM '$VM_NAME' is now booting from ISO."
echo "Complete installation manually,"
echo "then run customization commands afterward if desired."
echo "=============================================="

