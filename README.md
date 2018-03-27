# Romey Jenkins

This folder contains the ansible playbook necessary for provisioning and configuring Romey Inc.'s Jenkins service.

## Installation

Make sure that Ansible is installed with

```bash
$ make check
```

If you don't have Ansible, please install it according to [their website](http://docs.ansible.com/ansible/latest/intro_installation.html).


## Running

Since Jenkins requiring an initial, manual user setup, this deployment takes three steps.

### 1. Setup Hosts

Provision the servers you wan to use for Jenkins and add their public IPs  under a `jenkins` group a .ini formatted file called `instance_hosts` in this directory.

You can refer to `example_hosts` for guidance

Note: If there's a `vaulted_vars.yml` file, and you don't know what the vault password is, ask you how ever provided you with the playbook for it. If not, then the sudo password must be added to a `ansible-vault` like so:

Create a `vaulted_vars.yml` file and encrypt with whatever password you wish:
```bash
$ echo "jenkins_become_pass: <sudo_password_for_jenkins>" > vaulted_vars.yml
$ ansible-vault encrypt vaulted_vars.yml
```

Verify with:
```bash
$ ansible-vault view vaulted_vars.yml
```

### 2. Deploy Jenkins

Once you've provisioned and defined your hosts, it's time to deploy jenkins to them.

Do so by running:

```bash
$ make deploy
```

This will install the necessary dependencies to install and run a dockerized version of Jenkins exposed at port `8080`. Docker is used to facilitate deployment.


Note: The last play prints an object. The value of "msg" is the `initialAdminPassword` needed to unlock Jenkins in the next step.


### 3. Configure Jenkins

Once deployed, point your browser to each of your host's public ips at port `8080`. To unlock jenkins you'll have to use the `initialAdminPassword` from the last step.


With that password, unlock Jenkins and create a user.


Export the user name and password you've used to local environment variables, like so:

```bash
$ export JENKINS_USER=admin
$ export JENKINS_PASSWORD=supersecretpassword
```

This will be used by ansible to configure your Jenkins installations with the jobs defined in `roles/jenkins/files/jobs/`

Finally run the configure tasks with:


```bash
$ make configure
```

At the end of these steps, you'll be able to return to you're host's Jenkins services (accessible on them via port `8080`), and verify that the jobs you want are defined, enabled, and running appropriately.


## Extending

In order to add more jobs to be deployed in further installations add them to `roles/jenkins/files/jobs` according to the syntax specified by [Jenkins Job Builder](https://docs.openstack.org/infra/jenkins-job-builder/).


## Testing

For testing locally you need to download [vagrant](https://www.vagrantup.com/downloads.html), [ruby](https://www.ruby-lang.org/en/downloads/), and [bundle](http://bundler.io/). You can do so by following the instructions on their websites. Once downloaded, make sure you have all the tools necessary with:

```bash
$ make test-check
```

Setup and deploy jenkins to a local vagrant box:

```bash
$ make test-deploy
```

Following the steps in the normal flow and go to [http://localhost:8080](http://localhost:8080) to set up the user accounts. Afterwards, run the configuration and test everything with:


```bash
$ make test
```
