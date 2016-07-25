# Ansible ssh callback

Here are the helper scripts and manual how to do it.
----------------------------------------------------
If you need a centralized update of servers behind NAT with function like [provisioning-callback] (http://docs.ansible.com/ansible-tower/2.2.0/html/userguide/job_templates.html#ug-provisioning-callbacks), this manual can help you.
The basic idea is to allow some servers that are not directly accessible by the ssh, can automatically connect to a central server on which the ansible repository stored and receive configuration updates or project code updates.
The first thing you need to do to set up a key access between the central server and the target server.

On central server:
------------------
```
root@central:~# git clone https://github.com/1it/ansible-ssh-callback.git
root@central:~# cd ansible-ssh-callback
root@central:~# ./bootstrap.sh server
root@central:~# su - ansible
ansible@central:~$ ssh-keygen -b 4096 -t rsa -f $HOME/.ssh/id_rsa
ansible@central:~$ cat $HOME/.ssh/id_rsa.pub
```
This public-key you have to copy to the target server. You may want to add this key for the AMI on Amazon or KVM virtual machine.

On target server (client):
-----------------
```
root@target:~# git clone https://github.com/1it/ansible-ssh-callback.git
root@target:~# cd ansible-ssh-callback
root@target:~# ./bootstrap.sh client
root@target:~# su - ansible
ansible@target:~$ ssh-keygen -b 4096 -t rsa -f $HOME/.ssh/id_rsa
ansible@target:~$ cat $HOME/.ssh/id_rsa.pub
ansible@target:~$ echo "ssh-rsa AAAAB3NzaC1...central_server_public_key_contents... ansible@central.example.com" >> $HOME/.ssh/authorized_keys
```
The same on the central server but with some restrictions.
Now you can clone this repository to both servers.

Next:
------------------
On central: Put target server pub-key contents to .ssh/authorized_keys (see example in files/server.ssh.authorized_keys) for ansible user.
On client: Put central server pub-key contents to .ssh/authorized_keys for ansible user.
Then put you roles and playbooks to it's folders then try run ssh-tunnel script.
```
ansible@target:~$ ssh-tunnel
```
Use example from files/example.crontab to create a cron-job.
