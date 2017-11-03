# APITP deployment scripts

The deployment scripts in this folder use Ansible in order to maintain the
production environment. The playbooks are written to install Docker and Dokku,
and then create the APITP app and its associated services.

## Structure

This folder follows the guidelines from Ansible. Please refer to the Ansible
documentation for details on the implementation of these deployment scripts.

```
inventory/hosts              Inventory file
inventory/group_vars/all     Shared environment variables
inventory/group_vars/prod    Production environment variables
inventory/group_vars/test    Test environment variables
library/dokku_*.py           Dokku custom modules for the app playbook
module_utils/dokku.py        Support code for the Dokku modules
roles/apt_essentials/        Essential packages role
roles/docker/                Docker setup role
roles/dokku/                 Dokku setup role
roles/swap/                  Swapfile setup role
vars/app-common.yml          Public deployment variables
vars/app-secrets.yml.tmpl    Template to fill with secret variables
app.yml                      Playbook to setup the application
system.yml                   Playbook to setup the system
```

## Deploying a new instance

1. Either copy `vars/app-secrets.template.yml` to `vars/app-secrets.yml` and fill in the
   variables, or if you have the Vault password, put it in the `.vault_pass` and use the
   configuration under version control in this repository.

2. Edit the `[prod]` section in `inventory/hosts` to match the SSH host you are
   setting up.

3. Copy the public key to be used for deployments to `files/id_prod.pub`

4. Update the `hostname` variable in `inventory/group_vars/prod` to match the
   target hostname of the server.

5. Ensure `python` is installed on the target server, and password-less sudo is
   configured.
```bash
$ ssh my_server 'sudo sh -c "apt-get update -q && apt-get install -y python"'
# Note: must not ask for a password
```

6. On your development machine, with Ansible installed (`pip install ansible`),
   run the playbooks.
```bash
$ ansible-playbooks -i inventory/hosts -l prod server.yml
$ ansible-playbooks -i inventory/hosts -l prod app.yml
```

7. Configure the git remote in the repository
```bash
$ git remote add prod dokku@my_server:apitp
```

8. Push the code to trigger a deployment
```bash
$ git push prod master
```

9. Setup the database
```bash
# Create database from scratch
$ ssh dokku@my_server 'run apitp bundle exec rake db:structure:load'
# *OR* restore it from a backup
$ ssh dokku@my_server 'postgres:import apitp' <db.backup
# If upgrading from a previous version
$ ssh dokku@my_server 'run apitp bundle exec rake db:migrate'
```

10. Setup SSL using letsencrypt: if you have a backup of the `letsencrypt`
    folder, push it to the `/home/dokku/apitp/` folder using the method of your
    choice. This will enable restoring a previous certificate instead of
    generating a new one. Either way, run the following command to enable SSL:
```bash
$ ssh dokku@my_server 'letsencrypt apitp'
```

11. If starting from a fresh database, you will want to create some admin users.
    Run the following commands to do so:
```bash
# connect to the server
$ ssh my_server
# start a shell in the APITP context
my_server $ dokku run apitp bash
# now create an admin
apitp $ bundle exec rake 'apitp:admin:create[Name of the admin,address@example.com]'
# (optional) make this admin a super admin
apitp $ bundle exec rake apitp:admin:super:set[address@example.com]
# exit container
apitp $ exit
```

12. Also, if starting from a fresh database, you need to setup the recurring job
    which is responsible for sending notification e-mails.
```bash
# locally
$ ssh dokku@my_server 'run apitp bundle exec rake apitp:email:setup'
```

## Using a testing instance

You can test the deployment process locally using a suitably configured virtual
machine. This folder is already setup for a machine called `dokku.me`, as
created by the `Vagrantfile` from the [dokku repository](https://github.com/dokku/dokku).
Just replace the server names with `test` (ie. `ansible-playbook [...] -l test`)
to use this instance instead.

## Upgrading

To upgrade to a new version, do the following:

```bash
# push new code to trigger an update
$ git push prod master
# migrate the database
$ ssh dokku@my_server 'run apitp bundle exec rake db:migrate'
```
