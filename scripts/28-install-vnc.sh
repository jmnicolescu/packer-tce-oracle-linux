#!/bin/sh

#--------------------------------------------------------------------------------------
# Oracle Linux OS - Configure VNC [ 28-install-vnc.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 28-install-vnc.sh" 
echo "#--------------------------------------------------------------"

yum -y install pixman pixman-devel libXfont
yum -y install tigervnc-server
yum -y install xterm
sleep 10

# Create vncpasswd
export myuser="juliusn"

su - ${myuser} -c "mkdir -p /home/${myuser}/.vnc"
su - ${myuser} -c "echo ${myuser} | vncpasswd -f > /home/${myuser}/.vnc/passwd"
su - ${myuser} -c "chmod 0600 /home/${myuser}/.vnc/passwd"

cp /lib/systemd/system/vncserver@.service /lib/systemd/system/vncserver@.service.ORG
cd /etc/systemd/system

# update vncserver@:1.service
cat << EOF > /etc/systemd/system/vncserver@:1.service
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill :1 > /dev/null 2>&1 || :'
ExecStart=/sbin/runuser -l juliusn -c "rm -rf /tmp/.X* ; /usr/bin/vncserver :1 -geometry 1920x1200 -depth 24"
PIDFile=/home/juliusn/.vnc/%H:1.pid
ExecStop=/bin/sh -c '/usr/bin/vncserver -kill :1 > /dev/null 2>&1 || :'

[Install]
WantedBy=multi-user.target
EOF

cp /etc/systemd/system/vncserver@:1.service /lib/systemd/system/vncserver@.service

## firewall-cmd --permanent --zone=public --add-port=5901/tcp
## firewall-cmd --permanent --zone=public --add-port=5901/tcp --permanent
## firewall-cmd --permanent --zone=public --add-service vnc-server
## firewall-cmd --reload

rm -rf /tmp/.X11-unix

systemctl daemon-reload
systemctl enable vncserver@:1.service 
# systemctl start vncserver@:1.service
# systemctl status vncserver@:1.service

#--------------------------------------------------------------------------------------
# Customize The Screensaver Options In Gnome
#--------------------------------------------------------------------------------------
mkdir -p /etc/dconf/db/local.d/locks/

cat << EOF >  /etc/dconf/db/local.d/00-screensaver
[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/screensaver]
lock-enabled=false
lock-delay=uint32 0
EOF

cat << EOF > /etc/dconf/db/local.d/locks/screensaver
/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-enabled
/org/gnome/desktop/screensaver/lock-delay
EOF

#--------------------------------------------------------------------------------------
# Additional settings for VNC/juliusn
#--------------------------------------------------------------------------------------

cp /home/juliusn/.xinitrc.gnome /home/juliusn/.xinitrc
cp /home/juliusn/.vnc/xstartup.gnome /home/juliusn/.vnc/xstartup
chmod 755 /home/juliusn/.vnc/xstartup* /home/juliusn/.xinitrc* /home/juliusn/.Xresources
chown -R juliusn:juliusn /home/juliusn/.vnc /home/juliusn/.xinitrc* /home/juliusn/.Xresources

echo "Done 28-install-vnc.sh"