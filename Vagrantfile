# -*- mode: ruby -*-
# vi: set ft=ruby :
slurm_computer = {
    :worker1 => {                                                              
        :hostname => "worker1",
        :ipaddress => "192.168.56.181"
    }
    :worker2 => {                                                              
        :hostname => "worker2",
        :ipaddress => "192.168.56.182"
    }
}


$initiator_script = <<SCRIPT
yum -y update
yum -y groupinstall "Base"
yum -y install epel-release
yum -y install ntp
systemctl enable ntpd
ntpdate pool.ntp.org
systemctl start ntpd
echo "Installing munge"
yum install munge munge-libs munge-devel
echo "Seeting hosts file"
echo "192.168.56.180    head" >> /etc/hosts
echo "192.168.56.181    worker1" >> /etc/hosts
echo "192.168.56.182    worker2" >> /etc/hosts
echo "Adding Munge and slurm User"
groupadd -g 981 munge
useradd -m -c "Munge User" -d /var/lib/munge -u 981 -g munge -s /sbin/nologin munge
groupadd -g 982 slurm
useradd -m  -c "Slurm Workload Manager" -d /var/lib/slurm -u 982 -g slurm -s /bin/bash slurm
SCRIPT

$head_script = <<SCRIPT
echo "Installing mariadb"
yum -y install mariadb-server mariadb-devel
echo "Installing components for RPM build"
yum -y install rpm-build gcc openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel gtk2-devel man2html libibmad libibumad perl-Switch perl-ExtUtils-MakeMaker
echo "Munge KEY"
dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key
SCRIPT


Vagrant.configure("2") do |config|
    config.vm.define "head" do |head|
        head.vm.box = "centos/7"
        head.vm.hostname = 'head'
        head.vm.network "private_network", ip: "192.168.56.180"
        head.vm.provision "shell", inline: $initiator_script
        head.vm.provision "shell", inline: $head_script
    end

    slurm_cluster.each_pair do |name, options|
        global_config.vm.define name do |config|
            config.vm.box = "centos/7"
            config.vm.hostname = "#{name}"
            config.vm.network "private_network", ip: options[:ipaddress]
            config.vm.provider :virtualbox do |v|
                v.customize ["modifyvm", :id, "--cpus", "2"]
            end
            config.vm.provision :shell, :inline => $initiator_script
    end
end
