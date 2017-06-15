# -*- mode: ruby -*-
# vi: set ft=ruby :
slurm_compute = {
    :worker1 => {                                                              
        :hostname => "worker1",
        :ipaddress => "192.168.56.181"
    },
    :worker2 => {                                                              
        :hostname => "worker2",
        :ipaddress => "192.168.56.182"
    }
}


$initiator_script = <<SCRIPT
yum -y update
yum -y groupinstall "Base"
yum -y install epel-release
yum -y install nfs-utils
yum -y install autofs
yum -y install ntp
systemctl enable ntpd
ntpdate pool.ntp.org
systemctl start ntpd
echo "Setting hosts file"
echo "192.168.56.180    head" >> /etc/hosts
echo "192.168.56.181    worker1" >> /etc/hosts
echo "192.168.56.182    worker2" >> /etc/hosts
echo "Adding Munge and slurm User"
groupadd -g 981 munge
useradd -m -c "Munge User" -d /var/lib/munge -u 981 -g munge -s /sbin/nologin munge
groupadd -g 982 slurm
useradd -m  -c "Slurm Workload Manager" -d /var/lib/slurm -u 982 -g slurm -s /bin/bash slurm
echo "Installing munge"
yum -y install munge munge-libs munge-devel
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

$nfs_script = <<SCRIPT
echo "Configuring NFS and autofs"
mkdir -p /mnt/shared
echo "/mnt/shared  *(rw,no_root_squash)" > /etc/exports
systemctl enable nfs-server.service
systemctl restart nfs-server.service
echo "AUTO FS"
echo "/-    /etc/auto.direct" >> /etc/auto.master
echo "#/mnt/shared     -fstype=nfs,vers=3,noatime      head:/mnt/shared" > /etc/auto.direct
systemctl enable autofs
systemctl restart autofs
SCRIPT

$slurm_script = <<SCRIPT
echo "Build SLURM"
mkdir -p /mnt/shared/slurm
cd /mnt/shared/slurm/
wget https://www.schedmd.com/downloads/archive/slurm-16.05.10-2.tar.bz2
rpmbuild -ta slurm-16.05.10-2.tar.bz2 --define "_rpmdir /mnt/shared/slurm"
cd x86_64/
yum -y localinstall --nogpgcheck slurm-16.05.10-2*rpm slurm-devel-16.05.10-2*rpm slurm-munge-16.05.10-2*rpm slurm-perlapi-16.05.10-2*rpm slurm-plugins-16.05.10-2*rpm slurm-sjobexit-16.05.10-2*rpm slurm-sjstat-16.05.10-2*rpm slurm-torque-16.05.10-2*rpm slurm-seff-16.05.10-2*rpm slurm-slurmdbd-16.05.10-2*rpm slurm-sql-16.05.10-2*rpm slurm-plugins-16.05.10-2*rpm
SCRIPT


$node_script = <<SCRIPT
echo " Worker configuration specific"
echo "AUTO FS"
echo "/-    /etc/auto.direct" >> /etc/auto.master
echo "/mnt/shared     -fstype=nfs,vers=3,noatime      head:/mnt/shared" > /etc/auto.direct
systemctl enable autofs
systemctl restart autofs
cd /mnt/shared/slurm/x86_64/
yum -y localinstall --nogpgcheck slurm-16.05.10-2*rpm slurm-devel-16.05.10-2*rpm slurm-munge-16.05.10-2*rpm slurm-perlapi-16.05.10-2*rpm slurm-plugins-16.05.10-2*rpm slurm-sjobexit-16.05.10-2*rpm slurm-sjstat-16.05.10-2*rpm slurm-torque-16.05.10-2*rpm slurm-seff-16.05.10-2*rpm
SCRIPT

Vagrant.configure("2") do |config|
    config.vm.define "head" do |head|
        head.vm.box = "centos/7"
        head.vm.hostname = 'head'
        head.vm.network "private_network", ip: "192.168.56.180"
        head.vm.provision "shell", inline: $initiator_script
        head.vm.provision "shell", inline: $head_script
        head.vm.provision "shell", inline: $nfs_script
        head.vm.provision "shell", inline: $slurm_script
    end

    slurm_compute.each_pair do |name, options|
        config.vm.define name do |worker|
            worker.vm.box = "centos/7"
            worker.vm.hostname = "#{name}"
            worker.vm.network "private_network", ip: options[:ipaddress]
            worker.vm.provider :virtualbox do |v|
                v.customize ["modifyvm", :id, "--cpus", "2"]
            end
            worker.vm.provision :shell, :inline => $initiator_script
            worker.vm.provision :shell, :inline => $node_script
        end
    end
end
