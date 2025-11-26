#!/usr/bin/env bash
set -euo pipefail

# -------- Inputs --------
BASE_IMG="/var/lib/libvirt/images/base-noble-ubuntu-server-cloudimg-amd64.img"
VM_NAME="$1"
CLONE_IMG="/var/lib/libvirt/images/${VM_NAME}.qcow2"
USERNAME="${2:-dev}"
PASSWORD="${3:-password123}"
OS_VARIANT="${4:-ubuntu-lts-latest}"
RAM_MB="${5:-4096}"
VCPUS="${6:-4}"

# NFS mount from NAS
NFS_HOST_IP="192.168.86.16"
NFS_EXPORT_PATH="/volume1/dev"
NFS_MOUNT_PATH="/mnt/dev"

# -------- Validate --------
if [[ ! -f "$BASE_IMG" ]]; then
  echo "Base image not found at $BASE_IMG" >&2
  exit 1
fi

# -------- Clone --------
echo "Cloning base image to $CLONE_IMG..."
cp --reflink=auto "$BASE_IMG" "$CLONE_IMG"

# -------- Generate Random IP --------
RANDOM_IP_OCTET=$((RANDOM % 235 + 20))
IP_ADDRESS="192.168.200.$RANDOM_IP_OCTET"
echo "Assigned static IP for $VM_NAME: $IP_ADDRESS"

# -------- Prepare netplan YAML with static randomized IP --------
NETPLAN_FILE=$(mktemp)
cat > "$NETPLAN_FILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      addresses: [$IP_ADDRESS/24]
      gateway4: 192.168.200.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
EOF

# -------- Customize Image --------
echo "Customizing $CLONE_IMG..."
virt-customize \
  -a "$CLONE_IMG" \
  --hostname "$VM_NAME" \
  --run-command "useradd -m -s /bin/bash $USERNAME" \
  --run-command "echo '$USERNAME:$PASSWORD' | chpasswd" \
  --upload "$NETPLAN_FILE:/etc/netplan/01-netcfg.yaml" \
  --run-command "echo '$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers" \
  --run-command "touch /etc/cloud/cloud-init.disabled" \
  --run-command "echo 'export TERM=xterm-256color' >> /home/$USERNAME/.bashrc" \
  --run-command "echo 'ulimit -n 65535' >> /home/$USERNAME/.bashrc" \
  --run-command "echo '127.0.1.1 $VM_NAME' >> /etc/hosts" \
  --run-command "rm -f /etc/resolv.conf" \
  --run-command "echo 'nameserver 1.1.1.1' > /etc/resolv.conf" \
  --run-command "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf" \
  --install build-essential \
  --install linux-headers-generic \
  --install git \
  --install bc \
  --install flex \
  --install bison \
  --install libelf-dev \
  --install libssl-dev \
  --install nfs-common \
  --install cloud-guest-utils \
  --run-command "mkdir -p $NFS_MOUNT_PATH" \
  --run-command "echo '$NFS_HOST_IP:$NFS_EXPORT_PATH $NFS_MOUNT_PATH nfs defaults 0 0' >> /etc/fstab" \
  --firstboot-command "netplan apply && mount -a" \
  --selinux-relabel

# Clean up temp file
rm "$NETPLAN_FILE"

# -------- Launch VM --------
echo "Launching $VM_NAME..."
virt-install \
  --name "$VM_NAME" \
  --memory "$RAM_MB" \
  --vcpus "$VCPUS" \
  --disk path="$CLONE_IMG",format=qcow2 \
  --osinfo "$OS_VARIANT" \
  --network network=routed-net,model=virtio \
  --graphics none \
  --console pty,target_type=serial \
  --import \
  --noautoconsole

echo "'$VM_NAME' is provisioned with static IP $IP_ADDRESS and ready for kernel development. NFS is mounted at $NFS_MOUNT_PATH."
