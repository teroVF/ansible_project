#!/bin/bash
log_and_exit() {
    #red
    echo -e "\e[31m$1\e[0m" >> /tmp/control_node.logtm  
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
package_to_install=(python3-pip)
package_to_upgrade=(python3)


for nome in ${nomes[@]}; do
    create_user $nome
done


apt update -y || log_and_exit "Erro ao atualizar o repositório"
apt upgrade -y || log_and_exit "Erro ao atualizar os pacotes"
apt install -y software-properties-common || log_and_exit "Erro ao instalar o pacote software-properties-common"
apt-add-repository --yes --update ppa:ansible/ansible || log_and_exit "Erro ao adicionar o repositório do ansible"

for package in ${package_to_install[@]}; do
    apt install $package -y || log_and_exit "Erro ao instalar o pacote $package"
done

for package in ${package_to_upgrade[@]}; do
    apt upgrade $package -y || log_and_exit "Erro ao atualizar o pacote $package"
done

mv /tmp/ansible /opt/ansible || log_and_exit "Erro ao mover o diretório /tmp/ansible para /opt/ansible"
#Grupo ansible_3 com os usuários antero, miguel e pedro para rwx o diretório /opt/ansible
groupadd ansible_3 || log_and_exit "Erro ao criar o grupo ansible"
chown :ansible_3 /opt/ansible || log_and_exit "Erro ao alterar o grupo do diretório /opt/ansible"

mv /tmp/ansible.pem /opt/key || log_and_exit "Erro ao mover o arquivo /tmp/ansible.pem para /opt/ansible.pem"
chown -R root:ansible_3 /opt/key || log_and_exit "Erro ao alterar o dono do arquivo /opt/ansible.pem" 

#visudo
echo "%ansible_3 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers || log_and_exit "Erro ao adicionar a permissão no arquivo /etc/sudoers"

chmod -R 3770 /opt/ansible || log_and_exit "Erro ao alterar as permissões do diretório /opt/ansible"

for nome in ${nomes[@]}; do
    usermod -aG ansible_3 $nome || log_and_exit "Erro ao adicionar o usuário $nome ao grupo ansible"
    ln -s /opt/ansible /home/$nome/ansible || log_and_exit "Erro ao criar o link simbólico /home/$nome/ansible"
    ln -s /opt/key /home/$nome/ansible.pem || log_and_exit "Erro ao criar o link simbólico /home/$nome/ansible.pem"
done
