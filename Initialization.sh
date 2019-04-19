#!/usr/bin/env bash
#
# Author: bavdu
# Email: bavduer@163.com
# Date: 2019/04/18
# Usage: init server computer.


# 当前用户.
#if [ $id -eq 0 ];then
#  echo "this user is root."
#else
#  id $USER | grep wheel
#  if [ $? -eq 0 ];then
#    echo "$USER是管理员."
#  else
#    echo "$USER不是管理员"
#    exit
#  fi
#fi
#
# 安装必要的软件.
sudo systemctl disable firewalld && sudo systemctl stop firewalld
STATUS=$(getenforce)
if [ $STATUS == "Disabled" ];then
  printf "SELINUX is closed.\n"
else
  sudo sed -ri s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
  sudo setenforce 0
fi


# 安装必须要的工具
sudo mkdir /etc/yum.repos.d/repobak
sudo mv /etc/yum.repos.d/* /etc/yum.repos.d/repobak/

sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
if [ $? -ne 0 ];then
  printf "请检查你的网络!!!\n"
  exit
else
  sudo curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  if [ $? -ne 0 ];then
    printf "请检查你的网络!!!\n"
    exit
  else
    sudo sed -rie '/aliyuncs*/d' /etc/yum.repos.d/CentOS-Base.repo
    sudo yum clean all && sudo yum makecache fast
  fi
fi

sudo yum -y install vim net-tools wget ntpdate ShellCheck cmake make lftp
sudo yum -y groupinstall "Development Tools"


# 同步时间
sudo ntpdate -b ntp1.aliyun.com

# 优化ssh
sudo sed -ri s/"#UseDNS yes"/"UseDNS no"/g /etc/ssh/sshd_config
sudo systemctl restart sshd

# 优化网络
sudo cp /etc/sysconfig/network-scripts/ifcfg-$(ifconfig | awk -F":" 'NR==1{ print $1 }'){,.bak}
sudo sed -ri '/IPV6*/d' /etc/sysconfig/network-scripts/ifcfg-$(ifconfig | awk -F":" 'NR==1{ print $1 }')

sudo systemctl restart network
