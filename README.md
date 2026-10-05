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

- Vagrant plugin vagrant-disksize
```
vagrant plugin install vagrant-disksize
vagrant plugin list
```

- Installed VM provider. Examples: VirtualBox, VMware, Hyper-V. Recommended:
  Install via the `virtualbox` role: `roles/virtualbox/`

- Only on fresh system! Setup vagrant as default, config secure boot, MOK etc
```
sudo /sbin/vboxconfig
sudo modprobe vboxdrv
VBoxManage list hostinfo
vagrant status

# or
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
```
Later have to:
1. `sudo reboot`
2. At boot, a blue MOK Manager screen will appear (may need a keypress to catch it before GRUB times out) — select Enroll MOK → Continue → Yes, then enter the password you set during mokutil --import.
3. Let it finish and boot into Linux normally.
4. Verify and retry:
```
mokutil --test-key /var/lib/shim-signed/mok/MOK.der
sudo modprobe vboxdrv
VBoxManage list hostinfo
vagrant status
```

## Run
```
./run.sh
# Check help for more detailed info
./run.sh help
```

## Known issues
- `grub-pc` ends up in partially-configured state on Debian — worked around with `debconf-set-selections` in `tasks/essential.yml`
- CopyQ and other GUI apps fail in headless VMs (no X server) — expected, handled with `ignore_errors: true`
- 