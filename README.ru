# Ansible ssh callback

Здесь приведены скрипты и файлы для реализации функции ssh callback в связке с Ansible.
----------------------------------------------------
Если вам нужен сервер для централизованного обновления и управления конфигурациями серверов или ПК находящихся за NAT c функцией похожей на реализацию [provisioning-callback] (http://docs.ansible.com/ansible-tower/2.2.0/html/userguide/job_templates.html#ug-provisioning-callbacks), то это мануал возможно вам поможет.
Основная идея (зачем это вообще нужно) в том чтобы сервера к которым нет прямого доступа или вновь созданные из образа сервера подключались к серверу на котором хранится ваш ansible-проект и получали обратный коннект для применения изменений и полуения обновлений.
Вам понадобится это настроить ключевой доступ между центральным сервером и его "клиентами".
Для первичной настройки серевера и клиента в репозитории есть скрипт bootstrap.sh 

Настройка на центральном сервере:
------------------
```
root@central:~# git clone https://github.com/1it/ansible-ssh-callback.git
root@central:~# cd ansible-ssh-callback
root@central:~# ./bootstrap.sh server
root@central:~# su - ansible
ansible@central:~$ ssh-keygen -b 4096 -t rsa -f $HOME/.ssh/id_rsa
ansible@central:~$ cat $HOME/.ssh/id_rsa.pub
```
Этот ключ вам нужно будет скопировать на целевой сервер. Возможно также вы захотите положить это ключ в образ (AMI или QEMU/KVM) виртуальной машины.

Первичная настройка на целевом сервере (client):
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

Далее:
------------------
На центральном сервере: Добавьте клиентские pub-ключи в файл .ssh/authorized_keys (смотрите пример в files/server.ssh.authorized_keys) для пользователя ansible.
На целевом сервере: Добавьте pub-ключ с центрального сервера в файл .ssh/authorized_keys для пользователя ansible.
Положите ваши плейбуки и роли в соответствующие директории и пропишите их в скрипте ssh-server-script. Начинайте пользоваться.

```
ansible@target:~$ ssh-tunnel
```
Чтобы настроить обновление по крону воспользуйтесь примером в files/example.crontab






