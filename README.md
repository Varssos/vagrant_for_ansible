# Vagrant for ansible

This project is designed to run multiple Linux VMs with Vagrant for testing Ansible scripts.
Ansible runs from the **host machine** via SSH — no ansible-core is needed inside the VMs.

## Assumptions
- Each VM has SSH on a dedicated port (e.g. ubuntu2204 → port `2204`, debian131 → port `4131`)
- VM configuration is in [../hosts](../hosts) under the `vagrant` group

## Prerequisites
- [Installed Vagrant](https://developer.hashicorp.com/vagrant/install#linux)
```
vagrant --version
Vagrant 2.4.9
```

- Installed VM provider. Examples: VirtualBox, VMware, Hyper-V. Recommended:
  Install via the `virtualbox` role: `roles/virtualbox/`

## Run
```
./run.sh
# Check help for more detailed info
./run.sh help
```

## Known issues
- `grub-pc` ends up in partially-configured state on Debian — worked around with `debconf-set-selections` in `tasks/essential.yml`
- CopyQ and other GUI apps fail in headless VMs (no X server) — expected, handled with `ignore_errors: true`
