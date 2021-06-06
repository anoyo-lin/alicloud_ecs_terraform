locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello ${var.name}"
sudo apt update
sudo apt install git -y
git clone https://gitee.com/easzlab/kubeasz.git
cd kubeasz/ && ./ezdown -D && ./ezdown -P && ./ezdown -S
docker exec -it kubeasz ezctl start-aio
curl -fsSL -o helm.tar.gz https://mirror.azure.cn/kubernetes/helm/helm-v3.3.4-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/helm
chmod 755 /usr/local/bin/helm
source .profile
helm version
kubectl version
EOF
}
