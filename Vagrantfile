Vagrant.configure("2") do |config|

  boxes = {
    "ubuntu2204" => {
      box: "bento/ubuntu-22.04",
      host_port: 2204
    },
    "ubuntu2404" => {
      box: "bento/ubuntu-24.04",
      host_port: 2404
    },
    "ubuntu2504" => {
      box: "bento/ubuntu-25.04",
      host_port: 2504
    },
    "linuxmint22wilma" => {
      box: "archman/linuxmint",
      host_port: 3220
    },
    "linuxmint223zena" => {
      box: "mgldvd/linuxmint-22.3-zena",
      host_port: 3223
    }

  }

  boxes.each do |name, opts|
    config.vm.define name do |vm|
      vm.vm.box = opts[:box]
      vm.vm.hostname = name

      vm.vm.network "forwarded_port",
        guest: 22,
        host: opts[:host_port],
        id: "ssh"

      vm.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
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
          ansible-core \
          passwd

        # user
        useradd -m -s /bin/bash ubuntu_user || true
        echo "ubuntu_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

        mkdir -p /home/ubuntu_user/.ssh
        chmod 700 /home/ubuntu_user/.ssh
        chown -R ubuntu_user:ubuntu_user /home/ubuntu_user/.ssh

        # empty password
        passwd -d ubuntu_user

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
