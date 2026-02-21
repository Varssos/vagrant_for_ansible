# Vagrant for ansible

This project is deigned to run multiple linux VMs with vagrant for testing ansible scripts

## Assumptions:
- create box ubuntu2204 for ubuntu 22.04 and with ssh on port `2204` without password (configured ansible `host` to that)
- above that folder exist `test_run.yml` with installed ansible-core

## Prerequisities
- [Installed vagrant](https://developer.hashicorp.com/vagrant/install#linux)
```
vagrant --version
Vagrant 2.4.9
```

- Installed VM providers. Examples are VirtualBox, VMware, Hyper-V. Recommended:
```
tasks/virtualbox.yml
```

## Run
```
./run.sh
# Check help for more detailed info
./run.sh help
```


## Known issues
Check `iac_and_automation/vagrant/known_issues/`
