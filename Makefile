HOSTS ?= instance_hosts
PRIVATE_KEY ?= ~/.ssh/id_rsa
.DEFAULT_GOAL := help
.PHONY: check help deploy configure test-check test-setup test-deploy test-configure configure-nginx


check: ## check to make sure tools are installed
	ansible --version

deploy:  ## deploy jenkins on the hosts defined at "instance_hosts"
	ansible-playbook --private-key=$(PRIVATE_KEY) -i $(HOSTS) playbook.yaml --tags "deploy"  --ask-vault-pass -e@vaulted_vars.yml

configure:  ## configure the jenkins hosts
	ansible-playbook --private-key=$(PRIVATE_KEY) -i $(HOSTS) playbook.yaml --tags "configure" --ask-vault-pass -e@vaulted_vars.yml

configure-nginx:  ## configure nginx on the host to serve Jenkins via HTTPS
	ansible-playbook --private-key=$(PRIVATE_KEY) -i $(HOSTS) playbook.yaml --tags "nginx" --ask-vault-pass -e@vaulted_vars.yml

test-check: check  ## check to make sure testing tools are installed
	bundle --version
	vagrant --version

test-setup:  ## setup local vagrant box for testing
	cd test && vagrant up && bundle

test-deploy:  test-setup ## deploy to local vagrant for testing
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i test/hosts --private-key test/.vagrant/machines/default/virtualbox/private_key playbook.yaml --tags "deploy"

test-configure:  ## configure localhost for testing
	ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i test/hosts --private-key test/.vagrant/machines/default/virtualbox/private_key playbook.yaml --tags "configure"

test: test-configure  ## test the deploy/configuration
	cd test && rake spec

test-clean:  ## destroy vagrant machine after testing
	cd test && vagrant destroy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
