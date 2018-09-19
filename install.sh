#!/bin/bash
#
#

#定义函数
function lvecho {
    echo -e "\033[32m $1 \033[0m"
}

function hongecho {
    echo -e "\033[31m $1 \033[0m"
}


clear
echo ""
echo "+------------------------------------------------------------------------+"
echo "|             kodexplorer4.34 Linux Server, Written by                   |"
echo "+------------------------------------------------------------------------+"
echo "|        install kodexplorer4.34 on Linux  By hackermofrom@gmail.com     |"
echo "+------------------------------------------------------------------------+"
echo "|        LA*P         Local  Test visit        http://127.0.0.1          |"
echo "+------------------------------------------------------------------------+"
sleep 1
echo "判断用户 ..."
if [ "$USER" != "root" ];then
    echo -n "请使用root用户执行本脚本 ..."
    hongecho "Error"
    exit
else
    echo -n "当前用户为 $USER "
    lvecho "OK"
fi
sleep 1
echo -n "判断yum仓库是否存在 ..."
lvecho "ok"
yum clean all >> ./log/yum.log
repolist=`yum repolist  | grep "repolist" | awk -F : '{print $2}'`

if [ $repolist == 0 ];then
    echo -n "yum仓库配置错误 请查看yum.log  正在退出"
    hongecho "Error"
    exit 2
else
    echo -n "yum仓库配置正确..."
    lvecho "OK"
fi
echo "
==============================================="
echo ""
echo "执行安装..."
echo "判断是否安装Apache ..."
rpm -q httpd >> /dev/null
if [ $? -eq 0 ];then
    echo -n "已安装 Apache "
    lvecho "OK"
else
    yum -y install httpd
fi

echo "判断是否安装PHP ..."
rpm -q php >> /dev/null
if [ $? -eq 0 ];then
    echo -n "已安装 PHP "
    lvecho "OK"
else
    yum -y install php
fi


#web
echo "本脚本会默认清理/var/www/html/下的所有文件,使用前请备份"
hongecho "选项:
1 清空/var/www/html/下的所有文件
2 备份/var/www/html文件到当前目录
  如无特殊需求请选择1 或回车即可 "

read -p "请输入您想要修改的选项:" option
case $option in
1)
    rm -rf /var/www/html/* ;;
2)
    echo "打包中...名称为 html.tar.gz"
    tar -czf ./html.tar.gz /var/www/html/ >> ./log/html.log;;
*)
    rm -rf /var/www/html/* ;;
esac

#install
echo "正在安装kodexplorer4.34"
sleep 1
unzip kodexplorer4.34.zip -d /var/www/html/ >> ./log/kodexplorer.log
echo -n "解压kodexplorer完成,日志文件请查看./log/kodexplorer.log"
lvecho "OK"
echo "配置Selinux"
su -c 'setenforce 0'
if [ $? -eq 0 ];then
    lvecho "Selinux . . .  OK"
else
    echo "设置失败"
    exit 2
fi

echo "设置权限"
chmod -R 777 /var/www/html/
if [ $? -eq 0 ];then
    echo -n "权限设置 . . .  "
    lvecho "OK"
else
    echo -n "权限设置 . . . "
    hongecho "Error"
    exit 3
fi
#判断操作系统
hostnamectl | grep "centos" >> ./log/OS.log
if [ $? -eq 0 ];then
    echo "当前系统为Centos"
else
    echo -n "当前系统为Rhel 暂不支持 Rhel "
    hongecho "Error"
    exit 2
fi
#echo "安装kodexplorer扩展"
echo "安装kodexplorer扩展 . . ."
echo "安装php-mbstring ..."
sleep 1
yum -y install php-mbstring
if [ $? -eq 0 ];then
    echo "扩展php-mbstring . . ."
    lvecho "OK"
else
    echo "离线本地安装中 . . . "
    yum -y install Packages/php-mbstring-5.4.16-42.el7.x86_64.rpm
fi
echo "安装 php-gd ..."
yum -y install php-gd
if [ $? -eq 0 ];then
    echo "扩展php-gd . . ."
    lvecho "OK"
else
    echo "离线本地安装中 . . . "
    yum -y install Packages/php-gd-5.4.16-42.el7.x86_64.rpm
fi

#启动服务
echo "启动服务 ..."
systemctl restart httpd
echo "加入开机自启 ..."
systemctl enable httpd
lvecho "OK"

echo -n "作者:"
lvecho "小小白"
echo -n "使用环境:"
lvecho "达内教育Centos7物理机 暂不支持Rhel7"
echo -n"有意见请联系:"
lvecho "hackermofrom@gmail.com"
echo "版本:"
lvecho "测试版v1.0"

echo "安装后请访问本机地址
或访问http://127.0.0.1"

