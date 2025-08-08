#!/bin/bash
sudo apt update
echo "install dotnet"
sudo apt install -y aspnetcore-runtime-6.0
sudo apt install -y dotnet-sdk-6.0
echo "insatll git"
sudo apt install git
git --version
sudo apt install unzip
echo "install cli"

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
    
#clone repo from code commit
cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/ziad3704/HTTP.git
cd srv-02echo "dotnet build"
echo 'DOTNET_CLI_HOME=/temp' >> /etc/environment
sudo mkdir -p /temp/.nuget/NuGet
sudo chown -R ubuntu:ubuntu /temp
export DOTNET_CLI_HOME=/temp

dotnet publish -c Release --self-contained=false --runtime linux-x64
cat >/etc/systemd/system/srv-02.service <<EOL
[Unit]
Description=Dotnet S3 info service
After=network.target

[Service]
ExecStart=/usr/bin/dotnet /home/ubuntu/srv-02/bin/Release/netcoreapp6/linux-x64/srv02.dll
SyslogIdentifier=srv-02

Environment=DOTNET_CLI_HOME=/temp
Restart=always
User=ubuntu
WorkingDirectory=/home/ubuntu/HTTP

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload

#run it
systemctl start srv-02
