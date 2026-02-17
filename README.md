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

## Run
```
./run.sh
# or clean for all vms
./run.sh all clean
# Check help
./run.sh help
```