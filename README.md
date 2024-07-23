## Install OpenHPC on Single Node (i.e. on rockygpu computer)

This article indicates how to install OpenHPC on a single node running Rocky 9.4, using Warewulf and Slurm. This gives a guide to how to set up a OpenHPC cluster on a single computer, serving as both the schedular and compute node. 

This guide is an updated version of [manbaritone guide shown here](https://github.com/manbaritone/OpenHPC-Installation/blob/master/09_OpenHPC%20Slurm%20Setup%20for%20Single%20Node.md). This has been updated for running on Rocky 9, and using OpenHPC version 3.

At this point, we assume that you have installed a fresh version of Rocky 9 from here: https://rockylinux.org/download

## Step 1: Pre-setup

For this, the main and compute node run on the same computer. This computer has the following credentials. You will need to change these for your own computer

Hostname: rockygpu
ethernet name: enp0s31f6
ip (inet) address: 192.168.11.11
(Obtain these last two pieces of information by typing ```ifconfig``` into the terminal).

### Step 1.1: Add host information to computer

Do this by adding the following line to your ``/etc/hosts`` file:

```bash
sudo vim /etc/hosts
```

```
127.0.0.1     localhost localhost.localdomain localhost4 localhost4.localdomain4 # <-- Already exists in file
::1           localhost localhost.localdomain localhost6 localhost6.localdomain6 # <-- Already exists in file
192.168.11.11 rockygpu # <-- Newly added
```

Then you want to change the hostname of the computer.

```bash
sudo hostnamectl set-hostname rockygpu
```

### Step 1.2: Disable the firewall

```bash
sudo systemctl disable firewalld
sudo systemctl stop firewalld
```

### Step 1.3: Disable SeLinux

Open ```sudo vim /etc/selinux/config``` and change the following line to ```disabled```. 

```bash
sudo vim /etc/selinux/config
```

```
SELINUX=disabled
```

### Step 1.4: Reboot the device

Once you have done all this, reboot your device by typing into the terminal

```bash
sudo reboot
```

### Step 1.5: Update your system

The last thing to do is to update your Rocky 9 installation. We will do this a few times just to make sure everything has updated (this is more a double check that everything is up-to-date more than anything).

```bash
sudo yum -y update
sudo yum -y upgrade
sudo yum -y update
sudo yum -y upgrade
sudo yum -y update
sudo yum -y upgrade
```

## Step 2: OpenHPC and Slurm Setup

### Step 2.1: Install the OpenHPC Repository

First, we want to install the most up-to-date version of OpenHPC 3 from the installation guide in https://github.com/openhpc/ohpc/wiki/3.x

```bash
sudo dnf install http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/ohpc-release-3-1.el9.x86_64.rpm
```

### Step 2.2: Enable CRB repository

```bash
sudo dnf install dnf-plugins-core
sudo dnf config-manager --set-enabled crb
```

### Step 2.3: Install basic package for OpenHPC

```bash
# Install base meta-packages
sudo dnf -y install ohpc-base
sudo dnf -y install ohpc-warewulf
```

### Step 2.4: Install Slurm

```bash
sudo yum -y install ohpc-slurm-server
sudo yum -y install ohpc-slurm-client
sudo cp /etc/slurm/slurm.conf.ohpc /etc/slurm/slurm.conf
```

### Step 2.5: Restart and enable services

```bash
sudo systemctl enable mariadb.service 
sudo systemctl restart mariadb
sudo systemctl enable httpd.service
sudo systemctl restart httpd
sudo systemctl enable dhcpd.service
```

### Step 2.6: Install OpenHPC for compute node

```bash
sudo yum -y install ohpc-base-compute
```

### Step 2.7: Install modules user enviroment for compute node and master node

```bash
sudo yum -y install lmod-ohpc
```

### Step 2.8: Create basic values for OpenHPC

```bash
sudo wwinit database 
sudo wwinit ssh_keys
```

## Step 3: Make Configurations in /slurm.conf

Change the following in below:

```bash
sudo vim /etc/slurm/slurm.conf
```

* SlurmctldHost
* NODES
  * NodeName
  * NodeAddr
  * NodeHostName
  * Gres=gpu:nvidia:1 => Change this to the number of GPUs you are using
  * To get most of the information needed for the node, type ```slurmd -C``` into the terminal.
* PARTITIONS
  * Change this to the partitions you would like to use.

```bash title="sudo vim /etc/slurm/slurm.conf"
# Example slurm.conf file. Please run configurator.html
# (in doc/html) to build a configuration file customized
# for your environment.
#
#
# slurm.conf file generated by configurator.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
ClusterName=cluster
SlurmctldHost=rockygpu
#SlurmctldHost=
#
#DisableRootJobs=NO
#EnforcePartLimits=NO
#Epilog=
#EpilogSlurmctld=
#FirstJobId=1
#MaxJobId=67043328
#GresTypes=
#GroupUpdateForce=0
#GroupUpdateTime=600
#JobFileAppend=0
#JobRequeue=1
#JobSubmitPlugins=lua
#KillOnBadExit=0
#LaunchType=launch/slurm
#Licenses=foo*4,bar
#MailProg=/bin/mail
#MaxJobCount=10000
#MaxStepCount=40000
#MaxTasksPerNode=512
MpiDefault=none
#MpiParams=ports=#-#
#PluginDir=
#PlugStackConfig=
#PrivateData=jobs
ProctrackType=proctrack/cgroup
#Prolog=
#PrologFlags=
#PrologSlurmctld=
#PropagatePrioProcess=0
#PropagateResourceLimits=
#PropagateResourceLimitsExcept=
#RebootProgram=
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
#SlurmdUser=root
#SrunEpilog=
#SrunProlog=
StateSaveLocation=/var/spool/slurmctld
SwitchType=switch/none
#TaskEpilog=
#TaskPlugin=task/affinity
#TaskProlog=
#TopologyPlugin=topology/tree
#TmpFS=/tmp
#TrackWCKey=no
#TreeWidth=
#UnkillableStepProgram=
#UsePAM=0
#
#
# TIMERS
#BatchStartTimeout=10
#CompleteWait=0
#EpilogMsgTime=2000
#GetEnvTimeout=2
#HealthCheckInterval=0
#HealthCheckProgram=
InactiveLimit=0
KillWait=30
#MessageTimeout=10
#ResvOverRun=0
MinJobAge=300
#OverTimeLimit=0
SlurmctldTimeout=120
SlurmdTimeout=300
#UnkillableStepTimeout=60
#VSizeFactor=0
Waittime=0
#
#
# SCHEDULING
#DefMemPerCPU=0
#MaxMemPerCPU=0
#SchedulerTimeSlice=30
SchedulerType=sched/backfill
SelectType=select/cons_tres
#
#
# JOB PRIORITY
#PriorityFlags=
#PriorityType=priority/multifactor
#PriorityDecayHalfLife=
#PriorityCalcPeriod=
#PriorityFavorSmall=
#PriorityMaxAge=
#PriorityUsageResetPeriod=
#PriorityWeightAge=
#PriorityWeightFairshare=
#PriorityWeightJobSize=
#PriorityWeightPartition=
#PriorityWeightQOS=
#
#
# LOGGING AND ACCOUNTING
#AccountingStorageEnforce=0
#AccountingStorageHost=
#AccountingStoragePass=
#AccountingStoragePort=
AccountingStorageType=accounting_storage/none
#AccountingStorageUser=
#AccountingStoreFlags=
#AccountingStorageTRES=gres/gpu
#JobCompHost=
#JobCompLoc=
#JobCompPass=
#JobCompPort=
#JobCompType=jobcomp/none
#JobCompUser=
#JobContainerType=
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurmd.log
#SlurmSchedLogFile=
#SlurmSchedLogLevel=
#DebugFlags=
#
#
# POWER SAVE SUPPORT FOR IDLE NODES (optional)
#SuspendProgram=
#ResumeProgram=
#SuspendTimeout=
#ResumeTimeout=
#ResumeRate=
#SuspendExcNodes=
#SuspendExcParts=
#SuspendRate=
#SuspendTime=
#
#
# POWER SAVE SUPPORT FOR IDLE NODES (optional)
#SuspendProgram=
#ResumeProgram=
#SuspendTimeout=
#ResumeTimeout=
#ResumeRate=
#SuspendExcNodes=
#SuspendExcParts=
#SuspendRate=
#SuspendTime=
#
#
# COMPUTE NODES
# OpenHPC default configuration
# Enable the task/affinity plugin to add the --cpu-bind option to srun for GEOPM
TaskPlugin=task/affinity
PropagateResourceLimitsExcept=MEMLOCK
JobCompType=jobcomp/filetxt
Epilog=/etc/slurm/slurm.epilog.clean
#AccountingStorageType=accounting_storage/filetxt
#Epilog=/etc/slurm/slurm.epilog.clean
GresTypes=gpu
#
#
# NODES
NodeName=rockygpu NodeAddr=rockygpu NodeHostName=rockygpu Gres=gpu:nvidia:1 CPUs=16 Boards=1 SocketsPerBoard=1 CoresPerSocket=8 ThreadsPerCore=2 RealMemory=31564
#
#
# PARTITIONS
PartitionName=parallel Nodes=rockygpu DefMemPerCPU=512 Default=YES Shared=NO State=UP MaxTime=INFINITE
PartitionName=gpu      Nodes=rockygpu DefMemPerCPU=512 Default=YES Shared=NO State=UP MaxTime=INFINITE
#
#
# OpenHPC default configuration
# Enable the task/affinity plugin to add the --cpu-bind option to srun for GEOPM
# Enable configless option
#SlurmctldParameters=enable_configless
# Setup interactive jobs for salloc
LaunchParameters=use_interactive_step
```

## Step 4: Install EasyBuild for OpenHPC

Easybuild allows the user to easily install programs that the ```module``` program can mount and unmount as the user requires.

First, install EasyBuild

```bash
sudo dnf -y install EasyBuild-ohpc
```

If you are the admin, add the following to your ```~/.bashrc``` file

```bash
vim ~/.bashrc
```

```bash
# These lines are needed so that EasyBuild saves general shared programs to a shared folder by the Admin.
export EASYBUILD_PREFIX=/home/admin/easybuild
module use /home/admin/easybuild/modules/all
```

Once you have done this, create the ``easybuild`` folder that will contain all your programs that you install using easybuild.

```bash
mkdir -p /home/admin/easybuild
chmod -R 755 /home/admin/easybuild
```

This will allow all program the admin installs to be added to a shared directory, allowing all users to access the programs. 

## Step 5: Add the GPU (Optional)

### Step 5.1: Add gres.conf for GPU allocation 

Please check number of GPU, e.g. nvidia[0-1] is 2 GPUs

```bash
sudo vim /etc/slurm/gres.conf
```

Add the line below if you have just 1 GPU.

```bash title="sudo vim /etc/slurm/gres.conf"
NodeName=rockygpu Name=gpu File=/dev/nvidia0
```

If you have multiple GPUs

```bash title="sudo vim /etc/slurm/gres.conf"
NodeName=rockygpu Name=gpu File=/dev/nvidia[0-1]
```

### Step 5.2: Install ``nvidia-smi``

Now this is going to be weird, but it doesnt work unless you install the driver, then uninstall it, then reinstall it. So try this:

#### Step 5.2.1: Install ``nvidia-smi`` first time around

To do this, go to the https://developer.nvidia.com/cuda-downloads site and include the options:

* Linux
* x86_64
* Rocky
* 9
* rpm (local)

And do what is asked of you. For me this was

```bash
wget https://developer.download.nvidia.com/compute/cuda/12.5.1/local_installers/cuda-repo-rhel9-12-5-local-12.5.1_555.42.06-1.x86_64.rpm
sudo rpm -i cuda-repo-rhel9-12-5-local-12.5.1_555.42.06-1.x86_64.rpm
sudo dnf clean all
sudo dnf -y install cuda-toolkit-12-5

sudo dnf -y module install nvidia-driver:latest-dkms
```

### Step 5.2.2: Reboot the device

If you try running/typing in the terminal:

```bash 
nvidia-smi
```
may give

```bash 
NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver. Make sure that the latest NVIDIA driver is installed and running.
```

Try rebooting the computer:

```bash
sudo reboot
```

Then try ```nvidia-smi```


### Step 5.2.3: Reinstall ```cuda-toolkit``` if it does not work

So it is likely that ```nvidia-smi``` will not work. The stupid solution is to reinstall it. When I reinstall the ```cuda-toolkit```, it all of a sudden works. To do this:

First, uninstall all nvidia based programs

```bash
sudo dnf erase *nvidia* 
```

Then repeat the installation process from https://developer.nvidia.com/cuda-downloads 

```bash
wget https://developer.download.nvidia.com/compute/cuda/12.5.1/local_installers/cuda-repo-rhel9-12-5-local-12.5.1_555.42.06-1.x86_64.rpm
sudo rpm -i cuda-repo-rhel9-12-5-local-12.5.1_555.42.06-1.x86_64.rpm
sudo dnf clean all
sudo dnf -y install cuda-toolkit-12-5

sudo dnf -y module install nvidia-driver:latest-dkms
```

This should now work. If it doesn't, reboot:

```bash
sudo reboot
```

Hopefully you will get something that looks like this

```bash
[admin@rockygpu ~]$ nvidia-smi
Thu Jul 11 02:16:23 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 555.42.06              Driver Version: 555.42.06      CUDA Version: 12.5     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4090        Off |   00000000:17:00.0 Off |                  Off |
| 33%   43C    P0             63W /  450W |       1MiB /  24564MiB |      2%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA GeForce RTX 4090        Off |   00000000:85:00.0 Off |                  Off |
| 32%   43C    P0             61W /  450W |       1MiB /  24564MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

If this doesn't solve the problem, you may need to google another solution, like turning off secure boot. 

### Step 5.3: Install CUDA driver

We will now install the CUDA driver that will be used to allow your program to interact with the nVidia GPUs

#### Step 5.3.1: Load EasyBuild

Then install a CUDA drive using easybuild

```bash
module purge
module avail # <- Use this to get the version of Easybuild you have
module load EasyBuild/X.X.X # where X.X.X is the version given to you from module avail
# For me this was module load EasyBuild/4.9.1
```
#### Step 5.3.2: Search for CUDA drive in EasyBuild

```bash
eb --search cuda
```

This will give you a list that may include the following:

```bash
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-5.5.22-GCC-4.8.2.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-5.5.22.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-6.0.37.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-6.5.14.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-7.0.28.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-7.5.18-GCC-4.9.4-2.25.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-7.5.18-iccifort-2016.3.210-GCC-4.9.3-2.25.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-7.5.18.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-8.0.44-GCC-5.4.0-2.26.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-8.0.44-iccifort-2016.3.210-GCC-5.4.0-2.26.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-8.0.44.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-8.0.61.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-8.0.61_375.26-GCC-5.4.0-2.26.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.0.176-GCC-6.4.0-2.28.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.0.176-iccifort-2017.4.196-GCC-6.4.0-2.28.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.0.176.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.1.85-GCC-6.4.0-2.28.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.1.85.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.2.88-GCC-6.4.0-2.28.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.2.88-GCC-7.3.0-2.30.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.2.88.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-9.2.148.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.0.130.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.105-GCC-8.2.0-2.31.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.105-iccifort-2019.1.144-GCC-8.2.0-2.31.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.105.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.168.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.243-GCC-8.3.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.243-iccifort-2019.5.281.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.1.243.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-10.2.89-GCC-8.3.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.0.2-GCC-9.3.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.0.2-iccifort-2020.1.217.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.1.1-GCC-10.2.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.1.1-iccifort-2020.4.304.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.3.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.4.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.4.2.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.5.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.5.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.5.2.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.6.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.7.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-11.8.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.0.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.1.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.1.1.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.2.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.2.2.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.3.0.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.3.2.eb
 * /opt/ohpc/pub/libs/easybuild/4.9.1/easybuild/easyconfigs/c/CUDA/CUDA-12.4.0.eb
 ```

#### Step 5.3.3: Install for CUDA drive in EasyBuild

Install the latest version of CUDA, which for us is CUDA-12.4.0.eb

```bash
eb --accept-eula-for=CUDA CUDA-12.4.0.eb
```

## Step 6: Reboot the device

We have done a lot at this point, so lets to a quick reboot to refresh the system

```bash
sudo reboot
```

## Step 7: Restart the Slurm and Munge services.

```bash
sudo systemctl enable munge
sudo systemctl enable slurmctld
sudo systemctl enable slurmd
sudo systemctl start munge
sudo systemctl start slurmctld
sudo systemctl start slurmd
```

## Step 8: Determine memlock values

```bash
sudo perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' /etc/security/limits.conf
sudo perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' /etc/security/limits.conf
#sudo perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' $CHROOT/etc/security/limits.conf 
#sudo perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' $CHROOT/etc/security/limits.conf
```

## Step 9: Test resource by checking that the command below give back information about the rockygpu computer.

First, try seeing if the following works

```bash 
sudo scontrol show nodes
```

If it does not, you may need to check how your ``munge``, ``slurmctld``, ``slurmd`` do not have any problems. We can check that everything is working by running ```systemctl status```:

```bash
sudo systemctl status munge
sudo systemctl status slurmctld
sudo systemctl status slurmd
```

This will give an output:

```bash
[admin@rockygpu ~]$ sudo systemctl status munge
sudo systemctl status slurmctld
sudo systemctl status slurmd
● munge.service - MUNGE authentication service
     Loaded: loaded (/usr/lib/systemd/system/munge.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-07-11 03:00:30 EDT; 1min 49s ago
       Docs: man:munged(8)
   Main PID: 1152 (munged)
      Tasks: 4 (limit: 818512)
     Memory: 1.6M
        CPU: 5ms
     CGroup: /system.slice/munge.service
             └─1152 /usr/sbin/munged

Jul 11 03:00:30 rockygpu systemd[1]: Starting MUNGE authentication service...
Jul 11 03:00:30 rockygpu systemd[1]: Started MUNGE authentication service.
Jul 11 03:00:58 rockygpu systemd[1]: /usr/lib/systemd/system/munge.service:10: PIDFile= references a path below legacy directory /var/run/, updating /var/run/munge/munged.pid → /run/munge/munged.pid; please update the unit file accordingly.
Jul 11 03:00:58 rockygpu systemd[1]: /usr/lib/systemd/system/munge.service:10: PIDFile= references a path below legacy directory /var/run/, updating /var/run/munge/munged.pid → /run/munge/munged.pid; please update the unit file accordingly.
Jul 11 03:00:58 rockygpu systemd[1]: /usr/lib/systemd/system/munge.service:10: PIDFile= references a path below legacy directory /var/run/, updating /var/run/munge/munged.pid → /run/munge/munged.pid; please update the unit file accordingly.
● slurmctld.service - Slurm controller daemon
     Loaded: loaded (/usr/lib/systemd/system/slurmctld.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-07-11 03:00:36 EDT; 1min 43s ago
   Main PID: 1300 (slurmctld)
      Tasks: 18
     Memory: 9.0M
        CPU: 109ms
     CGroup: /system.slice/slurmctld.service
             ├─1300 /usr/sbin/slurmctld --systemd
             └─1319 "slurmctld: slurmscriptd"

Jul 11 03:00:36 rockygpu slurmctld[1300]: (null): _log_init: Unable to open logfile `/var/log/slurmctld.log': Permission denied
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: Recovered state of 1 nodes
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: Recovered information about 0 jobs
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: select/cons_tres: select_p_node_init: select/cons_tres SelectTypeParameters not specified, using default value: CR_Core_Memory
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: select/cons_tres: part_data_create_array: select/cons_tres: preparing for 1 partitions
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: Recovered state of 0 reservations
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: read_slurm_conf: backup_controller not specified
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: select/cons_tres: select_p_reconfigure: select/cons_tres: reconfigure
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: select/cons_tres: part_data_create_array: select/cons_tres: preparing for 1 partitions
Jul 11 03:00:36 rockygpu slurmctld[1300]: slurmctld: Running as primary controller
● slurmd.service - Slurm node daemon
     Loaded: loaded (/usr/lib/systemd/system/slurmd.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-07-11 03:00:39 EDT; 1min 40s ago
   Main PID: 1301 (slurmd)
      Tasks: 2
     Memory: 5.4M
        CPU: 20ms
     CGroup: /system.slice/slurmd.service
             └─1301 /usr/sbin/slurmd --systemd

Jul 11 03:00:38 rockygpu slurmd[1301]: slurmd: error: Waiting for gres.conf file /dev/nvidia1
Jul 11 03:00:39 rockygpu slurmd[1301]: slurmd: gres.conf file /dev/nvidia1 now exists
Jul 11 03:00:39 rockygpu slurmd[1301]: slurmd: warning: Ignoring file-less GPU gpu:nvidia from final GRES list
Jul 11 03:00:39 rockygpu slurmd[1301]: slurmd: slurmd version 23.11.6 started
Jul 11 03:00:39 rockygpu slurmd[1301]: slurmd: slurmd started on Thu, 11 Jul 2024 03:00:39 -0400
Jul 11 03:00:39 rockygpu systemd[1]: Started Slurm node daemon.
Jul 11 03:00:39 rockygpu slurmd[1301]: slurmd: CPUs=6 Boards=1 Sockets=1 Cores=6 Threads=1 Memory=127956 TmpDisk=71616 Uptime=14 CPUSpecList=(null) FeaturesAvail=(null) FeaturesActive=(null)
Jul 11 03:01:08 rockygpu slurmd[1301]: slurmd: error: Unable to register: Unable to contact slurm controller (connect failure)
Jul 11 03:01:38 rockygpu slurmd[1301]: slurmd: error: Unable to register: Unable to contact slurm controller (connect failure)
Jul 11 03:02:09 rockygpu slurmd[1301]: slurmd: error: Unable to register: Unable to contact slurm controller (connect failure)
```

If there are any problems with ```slurmd``` and ```sudo systemctl status slurmd``` indicates problems regarding the GPU, this will be because you are having problems with installing ```nvidia-smi```. If you can't install ```nvidia-smi```, you can try not adding the gpus to slurm to begin just to see if you can get slurm to work. 

For me, ``sudo scontrol show nodes`` did not work. Some troubleshooting I did:

* In this example, we see that ``Jul 11 03:00:36 rockygpu slurmctld[1300]: (null): _log_init: Unable to open logfile `/var/log/slurmctld.log': Permission denied``. This is not a big problem, but it can be solved by typing into the terminal ``chmod -R 777 /var/log/slurmctld.log``. This still didn't work for me, but 
* We can see that ``slurmd`` is likely the problem, because ``slurmd: error: Unable to register: Unable to contact slurm controller (connect failure)``


Once you have tried problem solving, try below

```bash
sudo systemctl restart munge
sudo systemctl restart slurmctld
sudo systemctl restart slurmd
sudo systemctl status munge
sudo systemctl status slurmctld
sudo systemctl status slurmd
```

For me, I put in the wrong ip address in ``/etc/hosts``. Once I corrected it, I then restarted ``munge``, ``slurmctld``, ``slurmd``, and then everything worked. When I did the following below

```bash 
sudo scontrol show nodes
```

I got: 

```bash
[admin@rockygpu ~]$ sudo scontrol show nodes
NodeName=rockygpu Arch=x86_64 CoresPerSocket=6 
   CPUAlloc=0 CPUEfctv=6 CPUTot=6 CPULoad=0.01
   AvailableFeatures=(null)
   ActiveFeatures=(null)
   Gres=gpu:nvidia:2
   NodeAddr=rockygpu NodeHostName=rockygpu Version=23.11.6
   OS=Linux 5.14.0-427.24.1.el9_4.x86_64 #1 SMP PREEMPT_DYNAMIC Mon Jul 8 17:47:19 UTC 2024 
   RealMemory=127956 AllocMem=0 FreeMem=126414 Sockets=1 Boards=1
   State=UNKNOWN+DRAIN+INVALID_REG ThreadsPerCore=1 TmpDisk=0 Weight=1 Owner=N/A MCS_label=N/A
   Partitions=gpu 
   BootTime=2024-07-11T03:00:25 SlurmdStartTime=2024-07-11T03:15:57
   LastBusyTime=2024-07-11T03:15:57 ResumeAfterTime=None
   CfgTRES=cpu=6,mem=127956M,billing=6
   AllocTRES=
   CapWatts=n/a
   CurrentWatts=0 AveWatts=0
   ExtSensorsJoules=n/a ExtSensorsWatts=0 ExtSensorsTemp=n/a
   Reason=gres/gpu count reported lower than configured (0 < 2) [slurm@2024-07-11T03:15:52]
```

And when I do 

```bash
sudo scontrol show partitions
```

I got:

```bash 
[admin@rockygpu ~]$ sudo scontrol show partitions
PartitionName=gpu
   AllowGroups=ALL AllowAccounts=ALL AllowQos=ALL
   AllocNodes=ALL Default=NO QoS=N/A
   DefaultTime=NONE DisableRootJobs=NO ExclusiveUser=NO GraceTime=0 Hidden=NO
   MaxNodes=UNLIMITED MaxTime=UNLIMITED MinNodes=0 LLN=NO MaxCPUsPerNode=UNLIMITED MaxCPUsPerSocket=UNLIMITED
   Nodes=rockygpu
   PriorityJobFactor=1 PriorityTier=1 RootOnly=NO ReqResv=NO OverSubscribe=NO
   OverTimeLimit=NONE PreemptMode=OFF
   State=UP TotalCPUs=16 TotalNodes=1 SelectTypeParameters=NONE
   JobDefaults=(null)
   DefMemPerCPU=512 MaxMemPerNode=UNLIMITED
   TRES=cpu=16,mem=31564M,node=1,billing=16

PartitionName=parallel
   AllowGroups=ALL AllowAccounts=ALL AllowQos=ALL
   AllocNodes=ALL Default=YES QoS=N/A
   DefaultTime=NONE DisableRootJobs=NO ExclusiveUser=NO GraceTime=0 Hidden=NO
   MaxNodes=UNLIMITED MaxTime=UNLIMITED MinNodes=0 LLN=NO MaxCPUsPerNode=UNLIMITED MaxCPUsPerSocket=UNLIMITED
   Nodes=rockygpu
   PriorityJobFactor=1 PriorityTier=1 RootOnly=NO ReqResv=NO OverSubscribe=NO
   OverTimeLimit=NONE PreemptMode=OFF
   State=UP TotalCPUs=16 TotalNodes=1 SelectTypeParameters=NONE
   JobDefaults=(null)
   DefMemPerCPU=512 MaxMemPerNode=UNLIMITED
   TRES=cpu=16,mem=31564M,node=1,billing=16
```

## Installation essential modules/softwares

1. Install other Development Tools

```bash
sudo dnf -y install ohpc-autotools
sudo dnf -y install hwloc-ohpc
sudo dnf -y install spack-ohpc
sudo dnf -y install valgrind-ohpc
```

2.  Install the Intel Complier (Intel oneAPI Base) (THIS DOES NOT WORK ANYMORE)

    * Ref: https://software.intel.com/content/www/us/en/develop/tools/oneapi/base-toolkit/download.html?operatingsystem=linux&distributions=yumpackagemanager

```bash
sudo bash -c 'cat << EOF > /etc/yum.repos.d/oneAPI.repo
[oneAPI]
name=Intel(R) oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF'
```
```bash
sudo yum upgrade intel-basekit
```

3. Install the ``GNU13`` compiler.

```bash
sudo dnf -y install gnu13-compilers-ohpc
```

4. Install MPI Stacks for parallelisation.

```bash
sudo dnf -y install openmpi5-pmix-gnu13-ohpc mpich-ofi-gnu13-ohpc mpich-ucx-gnu13-ohpc
```

5. Install performance tools for aiding in application performance analysis.

```bash
sudo dnf -y install ohpc-gnu13-perf-tools
```

6. Setup the default development environment that configures the default environment to enables autotools, the GNU compiler toolchain, and the OpenMPI stack.

```bash
sudo dnf -y install lmod-defaults-gnu13-openmpi5-ohpc
```

7. Install useful 3rd party libraries and tools

```bash
# Install 3rd party libraries/tools meta-packages built with GNU toolchain
sudo dnf -y install ohpc-gnu13-serial-libs
sudo dnf -y install ohpc-gnu13-io-libs
sudo dnf -y install ohpc-gnu13-python-libs
sudo dnf -y install ohpc-gnu13-runtimes

# Install parallel lib meta-packages for all available MPI toolchains
sudo dnf -y install ohpc-gnu13-mpich-parallel-libs
sudo dnf -y install ohpc-gnu13-openmpi5-parallel-libs
```

8. Install other 3rd party development libraries and tools

    * Some of these may not install due to changes with Intel. This is ok, just install whatever you can.

```bash
# Enable Intel oneAPI and install OpenHPC compatibility packages
sudo dnf -y install intel-oneapi-toolkit-release-ohpc
sudo rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
sudo dnf -y install intel-compilers-devel-ohpc
sudo dnf -y install intel-mpi-devel-ohpc

# Install 3rd party libraries/tools meta-packages built with Intel toolchain
sudo dnf -y install openmpi4-pmix-intel-ohpc
sudo dnf -y install ohpc-intel-serial-libs
sudo dnf -y install ohpc-intel-geopm
sudo dnf -y install ohpc-intel-io-libs
sudo dnf -y install ohpc-intel-perf-tools
sudo dnf -y install ohpc-intel-python3-libs
sudo dnf -y install ohpc-intel-mpich-parallel-libs
sudo dnf -y install ohpc-intel-mvapich2-parallel-libs
sudo dnf -y install ohpc-intel-openmpi4-parallel-libs
sudo dnf -y install ohpc-intel-impi-parallel-libs
```

<!-- 

3. Install the OpenHPC GNU9 basic additional packages (you can check additional packages from http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/).

```bash
sudo yum install -y ohpc-gnu9* R-gnu9-ohpc adios-gnu9* boost-gnu9* fftw-gnu9* hdf5-gnu9* mpich-ofi-gnu9* mpich-ucx-gnu9* mvapich2-gnu9* netcdf-gnu9* openmpi4-gnu9* pdtoolkit-gnu9* phdf5-gnu9* pnetcdf-gnu9* python3-mpi4py-gnu9* sionlib-gnu9* 
```

4. Install the OpenHPC Intel basic additional packages (you can check additional packages from http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/).

```bash
sudo yum install -y ohpc-intel* intel-compilers-devel-ohpc intel-mpi-devel-ohpc adios-intel* boost-intel* hdf5-intel* mpich-ofi-intel* mpich-ucx-intel* mvapich2-intel* netcdf-intel* openmpi4-intel* pdtoolkit-intel* phdf5-intel* pnetcdf-intel* python3-mpi4py-intel* sionlib-intel* 
``` -->


## Restart the Resource Manager

It is now a good idea to restart the resource manager and check that it is running

```bash
sudo systemctl restart munge
sudo systemctl restart slurmctld
sudo systemctl restart slurmd
sudo systemctl status munge
sudo systemctl status slurmctld
sudo systemctl status slurmd
```

## Test the CPU and GPU

To test the CPU and GPU, do the following

1. Create a ```Tests``` folder and change directory into it

```bash
mkdir -p Tests
cd Tests
```

2. Download the ``CPU_test.sl`` and ``GPU_test.sl`` files

```bash
curl -O https://raw.githubusercontent.com/geoffreyweal/OpenHPC-Slurm-Setup-for-Single-Node/main/Tests/CPU_test.sl
curl -O https://raw.githubusercontent.com/geoffreyweal/OpenHPC-Slurm-Setup-for-Single-Node/main/Tests/GPU_test.sl
```

3. Submit the ```CPU_test.sl``` file to slurm.

```bash
sbatch CPU_test.sl
```

This file just runs the CPU without doing anything for 60 second. You should expect to see a ``CPU_sleep_test.out`` and ``CPU_sleep_test.err`` file. If you do, slurm is working.

NOTE: Check that:
* The ```CPU_sleep_test.err``` contains nothing, and
* The ```CPU_sleep_test.out``` contains messages regarding when it starts and ends sleeping for 60 seconds.

4. Submit the ```GPU_test.sl``` file to slurm.

First, obtain the version of cuda you have on your computer:

```bash
[admin@rockygpu Tests]$ module avail cuda

--------------------------------------------------------------------------------- /home/admin/.local/easybuild/modules/all ---------------------------------------------------------------------------------
   CUDA/12.4.0
```

Then modify ``GPU_test.sl`` so that it loads your version of ``CUDA`` before submitting it to slurm

```bash
sbatch GPU_test.sl
```

This test will be quick, and you should expect to see a ``test_gpu.out`` and ``test_gpu.err`` file. If you do, slurm is working.

NOTE: Check that:
* The ```test_gpu.err``` contains nothing, and
* The ```test_gpu.out``` contains something like below:

```bash
Running nvidia-smi to check GPU status...
Thu Jul 11 17:49:55 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 555.42.06              Driver Version: 555.42.06      CUDA Version: 12.5     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce GTX 1650        Off |   00000000:01:00.0 Off |                  N/A |
| 40%   30C    P8              5W /   75W |      75MiB /   4096MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A      2009      G   /usr/libexec/Xorg                              66MiB |
|    0   N/A  N/A      2795      G   /usr/bin/gnome-shell                            5MiB |
+-----------------------------------------------------------------------------------------+
Running a simple GPU test program...
Hello from GPU!
```
* Crucially, it is important that ```test_gpu.out``` ends with the ``Hello from GPU!`` line. 


## If you have problems with the Tests: Restart up the computing node 

You may need to restart up the computer in slurm. If so, try the following. Only do this if the tests did not work.

```bash
sudo scontrol update nodename=rockygpu state=DOWN Reason='restarting node'
sudo scontrol update nodename=rockygpu state=IDLE
```
