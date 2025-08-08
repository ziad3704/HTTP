#!/bin/bash
set -e

# Update packages
apt update -y

# Install .NET
echo "Installing .NET..."
apt install -y aspnetcore-runtime-6.0 dotnet-sdk-6.0

# Install Git & unzip
echo "Installing Git & unzip..."
apt install -y git unzip

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Clone GitHub repo
echo "Cloning repo..."
cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/ziad3704/HTTP.git

# Build .NET project
echo "Building project..."
cd HTTP
echo 'DOTNET_CLI_HOME=/temp' >> /etc/environment
export DOTNET_CLI_HOME=/temp
dotnet publish -c Release --self-contained=false --runtime linux-x64

# Create systemd service
cat >/etc/systemd/system/srv-02.service <<EOL
[Unit]
Description=Dotnet S3 info service
After=network.target

[Service]
ExecStart=/usr/bin/dotnet /home/ubuntu/HTTP/bin/Release/net6.0/linux-x64/HTTP.dll
SyslogIdentifier=srv-02
Environment=DOTNET_CLI_HOME=/temp
Restart=always
User=ubuntu
WorkingDirectory=/home/ubuntu/HTTP

[Install]
WantedBy=multi-user.target
EOL

# Enable and start service
systemctl daemon-reload
systemctl enable srv-02
systemctl start srv-02
