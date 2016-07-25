#!/usr/bin/env bash

# This script can help you prepare your systems to use ansible-ssh-callback

ANSIBLE_SRC_PATH='/home/ansible/src'
ANSIBLE_BRANCH="origin/stable-2.1"
ANSIBLE_HOME="/home/ansible"
BIN_PATH="/usr/local/bin"

# Create ansible user
ansible_useradd () {

    useradd -m -s /bin/bash -c 'Ansible user' ansible

    read -p "Grant sudo (root) permissions for user ansible (required on client) (y/n)?" SUDO
    if [ "$SUDO" == "y" ]; then
        echo "OK! ";
        if visudo -c -f files/sudoers; then
            cp files/sudoers /etc/sudoers.d/ansible
            echo "Done"
        else
            echo "Error sudoers file corrupt or not exists!"
            exit 1
        fi
    else
      echo "Done";
    fi

}

# Install ansible
ansible_install () {
    cd $ANSIBLE_HOME
    git clone git://github.com/ansible/ansible.git --recursive "$ANSIBLE_SRC_PATH"
    cd "$ANSIBLE_SRC_PATH"
    git checkout "$ANSIBLE_BRANCH"
    make && make install
}

# Copy client scripts
client_copy_scripts () {
    cp scripts/ssh-tunnel $ANSIBLE_HOME
}

# Copy server scripts
server_copy_scripts () {
    cp scripts/ssh-server-script $ANSIBLE_HOME
}

# Copy client files
client_copy_files () {
    mkdir $ANSIBLE_HOME/.ssh
    cp files/client.ssh.config $ANSIBLE_HOME/.ssh/config
    cp files/defaults.ssh-tunnel $ANSIBLE_HOME/.ssh-tunnel
}

# Copy server files
server_copy_files () {
    mkdir $ANSIBLE_HOME/.ssh
    cp ansible.cfg $ANSIBLE_HOME/
    cp files/server.ssh.config $ANSIBLE_HOME/.ssh/config
    cp files/server.ssh.authorized_keys $ANSIBLE_HOME/authorized_keys
    cp -r group_vars $ANSIBLE_HOME/group_vars
    cp -r host_vars $ANSIBLE_HOME/host_vars
    cp -r inventory $ANSIBLE_HOME/inventory
    cp -r roles $ANSIBLE_HOME/roles
    cp -r playbooks $ANSIBLE_HOME/playbooks
}

if [ "$1" = "client" ]
    then
        ansible_useradd
        ansible_install
        client_copy_scripts
        client_copy_files
        echo "All things done!"
elif [ "$1" = "server" ]
    then
        ansible_useradd
        ansible_install
        client_copy_scripts
        client_copy_files
        echo "All things done!"
elif [ "$1" != "client|server" ]
    then
        echo "Error! Role name expected."
        echo "Please choose role: client or server."
        echo "Then exec: ./bootstrap.sh role"
        exit 1
fi
