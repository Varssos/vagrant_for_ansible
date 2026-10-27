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

- Installed VM provider (VirtualBox, installed manually — there is no role for it). Kernel module `vboxdrv` must be loaded:
```
lsmod | grep vboxdrv
VBoxManage --version   # must not print "vboxdrv kernel module is not loaded"
```
If it is not loaded, follow the next section.

### VirtualBox kernel module (fresh system / after kernel update)
Without it Vagrant fails with `No usable default provider could be found` or
`VirtualBox is complaining that the kernel module is not loaded`.

1. Install build requirements (`dkms` rebuilds the module on every kernel update):
```
sudo apt install dkms build-essential linux-headers-$(uname -r)
```
2. Check whether Secure Boot is on: `mokutil --sb-state`.
   - `SecureBoot disabled`: skip to step 4.
   - `SecureBoot enabled`: the module must be signed with an enrolled MOK key (steps 3a-3c). `/var/lib/shim-signed/mok/` is empty until the key is created.
3. Secure Boot only:
   - a. Create the key: `sudo update-secureboot-policy --new-key` (the `Can't load .rnd into RNG` warning is harmless)
   - b. Schedule enrollment and set a one-time password: `sudo mokutil --import /var/lib/shim-signed/mok/MOK.der`. Do not use `update-secureboot-policy --enroll-key`: it only works for DKMS modules and prints `No DKMS modules installed` for VirtualBox, which builds its module via `vboxconfig`.
   - c. `sudo reboot`. At boot the blue MOK Manager appears (press a key before GRUB times out): Enroll MOK → Continue → Yes → enter the password from step 3b.
4. Build, sign and load the module:
```
sudo /sbin/vboxconfig
sudo modprobe vboxdrv
VBoxManage list hostinfo
mokutil --test-key /var/lib/shim-signed/mok/MOK.der   # Secure Boot only: "is already enrolled"
```
5. Verify: `vagrant up --provider=virtualbox ubuntu2404` (or `./run.sh ubuntu2404`).

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