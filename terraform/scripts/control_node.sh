#!/bin/bash
log_and_exit() {
    #red
    echo -e "\e[31m$1\e[0m" >> /tmp/control_node.log
    exit 1
}

create_user() {
    useradd -m -d /home/$1 $1 -s /bin/bash || log_and_exit "Erro ao criar o usuário $1"
    mkdir -p /home/$1/.ssh || log_and_exit "Erro ao criar o diretório /home/$1/.ssh"
    touch /home/$1/.ssh/authorized_keys || log_and_exit "Erro ao criar o arquivo /home/$1/.ssh/authorized_keys"
    chown -R $1:$1 /home/$1/.ssh || log_and_exit "Erro ao alterar o dono do diretório /home/$1/.ssh"
    usermod -aG sudo $1 || log_and_exit "Erro ao adicionar o usuário $1 ao grupo sudo"
    cat /tmp/public_keys/$1.pub | tee /home/$1/.ssh/authorized_keys > /dev/null || log_and_exit "Erro ao adicionar a chave pública ao arquivo /home/$1/.ssh/authorized_keys"
}

#users
nomes=(antero miguel pedro)

#pacotes
package_to_install=(python3-pip ansible)
package_to_upgrade=(python3)


for nome in ${nomes[@]}; do
    create_user $nome
done


apt update -y || log_and_exit "Erro ao atualizar o repositório"
apt install -y software-properties-common || log_and_exit "Erro ao instalar o pacote software-properties-common"
apt-add-repository --yes --update ppa:ansible/ansible || log_and_exit "Erro ao adicionar o repositório do ansible"


git clone https://github.com/teroVF/ansible_project.git /opt/ansible || log_and_exit "Erro ao clonar o repositório ansible_project"l
git config --global --add safe.directory /opt/ansible || log_and_exit "Erro ao adicionar o safe.directory"
#Grupo ansible_3 com os usuários antero, miguel e pedro para rwx o diretório /opt/ansible
groupadd ansible_3 || log_and_exit "Erro ao criar o grupo ansible"
chown -R :ansible_3 /opt/ansible || log_and_exit "Erro ao alterar o grupo do diretório /opt/ansible"

mv /tmp/ansible.pem /opt/ansible.pem || log_and_exit "Erro ao mover o arquivo /tmp/ansible.pem para /opt/ansible.pem"
chown -R root:ansible_3 /opt/ansible.pem || log_and_exit "Erro ao alterar o dono do arquivo /opt/ansible.pem" 
chown 600 /opt/ansible.pem || log_and_exit "Erro ao alterar as permissões do arquivo /opt/ansible.pem"

#visudo
echo '%ansible_3 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers || log_and_exit "Erro ao adicionar a permissão no arquivo /etc/sudoers"

chmod -R 770 /opt/ansible || log_and_exit "Erro ao alterar as permissões do diretório /opt/ansible"

for nome in ${nomes[@]}; do
    usermod -aG ansible_3 $nome || log_and_exit "Erro ao adicionar o usuário $nome ao grupo ansible"
    ln -s /opt/ansible/ansible_v1 /home/$nome/ansible || log_and_exit "Erro ao criar o link simbólico /home/$nome/ansible"
    ln -s /opt/ansible.pem /home/$nome/ansible.pem || log_and_exit "Erro ao criar o link simbólico /home/$nome/ansible.pem"
    echo "StrictHostKeyChecking no" >> /home/$nome/.ssh/config || log_and_exit "Erro ao adicionar a configuração StrictHostKeyChecking no arquivo /home/$nome/.ssh/config"
done

for package in ${package_to_install[@]}; do
    apt install $package -y || log_and_exit "Erro ao instalar o pacote $package"
done

for package in ${package_to_upgrade[@]}; do
    apt upgrade $package -y || log_and_exit "Erro ao atualizar o pacote $package"
done

pip install "pywinrm>=0.3.0" || log_and_exit "Erro ao instalar o pacote pywinrm"
