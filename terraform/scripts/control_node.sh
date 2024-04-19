#!/bin/bash

log_and_exit() {
    echo $1 >> /var/log/control_node.log
    exit 1
}

create_user() {
    useradd -m -d /home/$1 $1 -s /bin/bash || log_and_exit "Erro ao criar o usuário $1"
    mkdir -p /home/$1/.ssh || log_and_exit "Erro ao criar o diretório /home/$1/.ssh"
    touch /home/$1/.ssh/authorized_keys || log_and_exit "Erro ao criar o arquivo /home/$1/.ssh/authorized_keys"~
    chown -R $1:$1 /home/$1/.ssh || log_and_exit "Erro ao alterar o dono do diretório /home/$1/.ssh"
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

# equivalente ao script abaixo
#  "sudo useradd -m -d /home/antero antero -s /bin/bash",
#     "sudo mkdir -p /home/antero/.ssh",
#     "sudo touch /home/antero/.ssh/authorized_keys",
#     "sudo chown -R antero:antero /home/antero/.ssh",
#     "sudo echo '${file("./public_keys/antero.pub")}' | sudo tee /home/antero/.ssh/authorized_keys > /dev/null",

#     "sudo useradd -m -d /home/miguel miguel -s /bin/bash",
#     "sudo mkdir -p /home/miguel/.ssh",
#     "sudo touch /home/miguel/.ssh/authorized_keys",
#     "sudo chown -R miguel:miguel /home/miguel/.ssh",
#     "sudo echo '${file("./public_keys/antero.pub")}' | sudo tee /home/miguel/.ssh/authorized_keys > /dev/null",

#     "sudo useradd -m -d /home/pedro pedro -s /bin/bash",
#     "sudo mkdir -p /home/pedro/.ssh",
#     "sudo touch /home/pedro/.ssh/authorized_keys",
#     "sudo chown -R pedro:pedro /home/pedro/.ssh",
#     "sudo echo '${file("./public_keys/antero.pub")}' | sudo tee /home/pedro/.ssh/authorized_keys > /dev/null",
#     "sudo apt update -y",
#     "sudo apt upgrade -y python",
#     "sudo apt install -y ansible",