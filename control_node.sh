#/bin/bash

useradd -m -d /home/antero antero -s /bin/bash
mkdir -p /home/antero/.ssh
touch /home/antero/.ssh/authorized_keys
chown -R antero:antero /home/antero/.ssh
echo '${file("./public_keys/antero.pub")}' | sudo tee /home/antero/.ssh/authorized_keys > /dev/null

useradd -m -d /home/miguel miguel -s /bin/bash
mkdir -p /home/miguel/.ssh
touch /home/miguel/.ssh/authorized_keys
chown -R miguel:miguel /home/miguel/.ssh
echo '${file("./public_keys/antero.pub")}' | sudo tee /home/miguel/.ssh/authorized_keys > /dev/null
useradd -m -d /home/pedro pedro -s /bin/bash
mkdir -p /home/pedro/.ssh
touch /home/pedro/.ssh/authorized_keys
chown -R pedro:pedro /home/pedro/.ssh
echo '${file("./public_keys/antero.pub")}' | sudo tee /home/pedro/.ssh/authorized_keys > /dev/null



# Install all the necessary packages
sudo apt update -y
apt upgrade -y python
apt install -y ansible

