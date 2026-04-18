Vagrant.configure("2") do |config|

  boxes = {
    "ubuntu2204" => {
      box: "bento/ubuntu-22.04",
      host_port: 2204
    },
    "ubuntu2404" => {
      box: "bento/ubuntu-24.04",
      host_port: 2404,
      disk_size: "48GB"
    },
    # "ubuntu2504" => {
    #   box: "bento/ubuntu-25.04",
    #   host_port: 2504
    # },
    # Some issues with sudo apt update on start
    # "linuxmint22wilma" => {
    #   box: "archman/linuxmint",
    #   host_port: 3220
    # }, 
    # "linuxmint222zara" => {
    #   box: "mgldvd/linuxmint-22.2-zara",
    #   host_port: 3222
    # },
    "linuxmint223zena" => {
      box: "mgldvd/linuxmint-22.3-zena",
      host_port: 3223
    },
    "debian131" => {
      box: "bento/debian-13.1",
      host_port: 4131
    }

  }

  boxes.each do |name, opts|
    config.vm.define name do |vm|
      vm.vm.box = opts[:box]
      vm.vm.hostname = name
      vm.vm.boot_timeout = 600

      vm.vm.network "forwarded_port",
        guest: 22,
        host: opts[:host_port],
        id: "ssh"

      vm.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end

      if opts[:disk_size]
        vm.disksize.size = opts[:disk_size]
      end

      vm.vm.provision "shell", inline: <<-SHELL
        export DEBIAN_FRONTEND=noninteractive

        apt-get update
        apt-get install -y \
          sudo \
          openssh-server \
          curl \
          ca-certificates \
          git \
          wget \
          nano \
          python3 \
          python3-pip \
          passwd \
          cloud-guest-utils

        # Extend LVM to fill disk (vagrant-disksize resizes the VirtualBox disk,
        # but partition + LVM must be expanded manually inside the VM)
        PART=$(pvdisplay 2>/dev/null | grep 'PV Name' | awk '{print $3}' | head -1)
        if [ -n "$PART" ]; then
          DISK=$(echo "$PART" | sed 's/[0-9]*$//')
          PARTNUM=$(echo "$PART" | grep -o '[0-9]*$')
          growpart "$DISK" "$PARTNUM" || true
          pvresize "$PART" || true
          lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv || true
          resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv || true
        fi

        # user
        useradd -m -s /bin/bash test_user || true
        echo "test_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

        mkdir -p /home/test_user/.ssh
        chmod 700 /home/test_user/.ssh
        chown -R test_user:test_user /home/test_user/.ssh

        # empty password
        passwd -d test_user

        # SSH config
        mkdir -p /run/sshd
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

        systemctl enable ssh
        systemctl restart ssh
      SHELL

    end
  end
end
