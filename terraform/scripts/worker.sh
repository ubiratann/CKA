#!/bin/bash

# Enabling required kernel modules
cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Disabling swap
swapoff -a 
sudo sed -i 's/swap/#swap/g' /etc/fstab

# Apply sysctl params without reboot
sudo sysctl --system

# Removing another container runtimes
sudo apt-get remove docker docker-engine docker.io containerd runc -y
sudo apt-get update -y

# Instaling required dependencies
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

# Instaling containerd from docker repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install containerd.io -y

# Installing CNI plugins
curl https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz -O
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz

# Opening port 6443 for KubeAPI
sudo iptables -I INPUT  -p tcp --dport 6433 -j ACCEPT
sudo iptables -I OUTPUT -p tcp --sport 6433 -j ACCEPT

sudo iptables -I OUTPUT -p tcp --sport 6783 -j ACCEPT
sudo iptables -I OUTPUT -p tcp --sport 6783 -j ACCEPT

sudo iptables -I OUTPUT -p udp --sport 6783 -j ACCEPT
sudo iptables -I OUTPUT -p udp --sport 6783 -j ACCEPT

sudo iptables -I OUTPUT -p udp --sport 6784 -j ACCEPT
sudo iptables -I OUTPUT -p udp --sport 6784 -j ACCEPT

cat << EOF | sudo tee -a  /etc/rc.local
iptables -I INPUT  -p tcp --dport 6433 -j ACCEPT
iptables -I OUTPUT -p tcp --sport 6433 -j ACCEPT

iptables -I OUTPUT -p tcp --sport 6783 -j ACCEPT
iptables -I OUTPUT -p tcp --sport 6783 -j ACCEPT

iptables -I OUTPUT -p udp --sport 6783 -j ACCEPT
iptables -I OUTPUT -p udp --sport 6783 -j ACCEPT

iptables -I OUTPUT -p udp --sport 6784 -j ACCEPT
iptables -I OUTPUT -p udp --sport 6784 -j ACCEPT
EOF

sudo sed -i 's/disabled_plugins/#disabled_plugins/'  /etc/containerd/config.toml 
cat << EOF | sudo tee -a /etc/containerd/config.toml 
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
EOF

sudo systemctl restart containerd

# Instaling kubernetes tools
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm
sudo apt-mark hold kubelet kubeadm

