#!/bin/bash
log_and_exit() {
    echo $1 >> /var/log/control_node.log
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
package_to_install=(ansible)
package_to_upgrade=(python3)

for nome in ${nomes[@]}; do
    create_user $nome
done


# Install all the necessary packages
apt update -y || log_and_exit "Erro ao atualizar o repositório"

for package in ${package_to_install[@]}; do
    apt install $package -y || log_and_exit "Erro ao instalar o pacote $package"
done

for package in ${package_to_upgrade[@]}; do
    apt upgrade $package -y || log_and_exit "Erro ao atualizar o pacote $package"
done

mkdir /opt/ansible || log_and_exit "Erro ao criar o diretório /opt/ansible"
groupadd ansible_3 || log_and_exit "Erro ao criar o grupo ansible"
chown :ansible_3 /opt/ansible || log_and_exit "Erro ao alterar o grupo do diretório /opt/ansible"
chmod 1770 /opt/ansible || log_and_exit "Erro ao alterar as permissões do diretório /opt/ansible"

for nome in ${nomes[@]}; do
    usermod -aG ansible_3 $nome || log_and_exit "Erro ao adicionar o usuário $nome ao grupo ansible"
    ln -s /opt/ansible /home/$nome/ansible || log_and_exit "Erro ao criar o link simbólico /home/$nome/ansible"
done

