#INSTALL KUBERNETES IN CENTOS7

#INSTALLATION REQUIREMENTS
# Centos7
# 2 core CPU (Compulsory)
#run from root user

systemctl stop firewalld
systemctl disable firewalld

setenforce 0

sed -i 's,SELINUX=enforcing,SELINUX=disbaled,g' 

sed -i 's,/dev/mapper/centos-swap,#/dev/mapper/centos-swap,g' /etc/fstab
sudo swapoff -a

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

cat <<EOF > /etc/sysctl.d/k8.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
#Make sure this k8.conf is running. Verify again.. If it's not running, make sure you keep the above conf in the default one.

yum install wget yum-utils device-mapper-persistent-data lvm2 -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y

systemctl start docker

systemctl enable docker

sudo yum update -y

sudo yum install -y kubelet kubeadm kubectl

systemctl enable kubelet

systemctl start kubelet

sudo hostnamectl set-hostname master-node

clear

read -p " Enter your IP: " action

#Enter you desired ip for master
echo $action 'master master-node' >> /etc/hosts
#echo '192.168.1.20 node1 worker-node' >> /etc/hosts
kubeadm init --pod-network-cidr=10.10.0.0/16

mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown root:root /root/.kube/config

wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sed -i 's/10.244.0.0\/16/10.10.0.0\/16/g' kube-flannel.yml
kubectl apply -f kube-flannel.yml
rm -rf kube-flannel.yml

echo ' '
echo ' '
echo ' '
echo '.............Kubernetes Setup and Ready to Use...............'
