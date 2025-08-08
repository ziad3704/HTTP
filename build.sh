#!/bin/bash


sudo apt update


echo "Install .NET 6 SDK and runtime"
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo add-apt-repository ppa:dotnet/backports -y
sudo apt install -y aspnetcore-runtime-6.0
sudo apt install -y dotnet-sdk-6.0


echo "Install git"
sudo apt install -y git
git --version


echo "Install unzip"
sudo apt install -y unzip


echo "Install AWS CLI v2"
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install


echo "Clone project"
cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/ziad3704/HTTP.git

sudo chown -R ubuntu:ubuntu /home/ubuntu/HTTP


echo 'DOTNET_CLI_HOME=/temp' | sudo tee -a /etc/environment
sudo mkdir -p /temp/.nuget/NuGet
sudo chown -R ubuntu:ubuntu /temp
export DOTNET_CLI_HOME=/temp


cd /home/ubuntu/HTTP
dotnet publish -c Release --self-contained=false --runtime linux-x64


echo "Create systemd service"
sudo tee /etc/systemd/system/srv-02.service > /dev/null <<'EOL'
[Unit]
Description=Dotnet S3 info service

[Service]
ExecStart=/usr/bin/dotnet /home/ubuntu/HTTP/bin/Release/netcoreapp6/linux-x64/srv02.dll
SyslogIdentifier=srv-02
Restart=always
Environment=DOTNET_CLI_HOME=/temp

[Install]
WantedBy=multi-user.target
EOL


sudo systemctl daemon-reload
sudo systemctl enable srv-02
sudo systemctl start srv-02
sudo systemctl status srv-02 
