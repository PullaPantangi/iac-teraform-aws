#!/bin/bash
yum install git* wget nginx* -y
echo "Copying the SSH Key Of Jenkins to the server"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCPo9tb2e6PERHaf3gMG6TozhIKqNbhkR5T/5KNI3hDHO1KnIlw8or0kYoeSSMX4K00byxSn4DgOarknj4ZuINgfbmyNk81DJlTBBBHHU7duxsnHCiggFz9JhgpcyhqprLHh3EqBn9N3qRPOs9Ic7tVtXDRKtUt3P1/tJV1Jx2usBjlXa9MC6BsoOzdyauN5N/HOrslkO2KXR22sACfk5ccF/bHIKBROfiY9BEBuiCLeD6V8mRbNzb1169WuBFpQtYUofrKGEAmTJzjo957q8M/lRAOkxsxh95mgxwLi1SKamhKSB6RiutdsDopRHc18cmq560OJSCVaKEbEjQlDhXTyQ38w+2pQa4DDGC1NYOYnN4x4FNd7n0wtPfBU1dWoQvvQHWcW6t9ezuCQ3sgUoLKjlzbfDAEgn6RLGrkR7IbFdv2Ux4xuBbtG6Kc4Bp61b+xLC82XlOojDhz12kgkt3AaKJsQC4jgpicT6RI/9B4d/FLQaV4Whg8v9sMEBBFr0s= raoli@Bhuvika" >> /home/ec2-user/.ssh/authorized_keys
git clone https://github.com/AdilShamim8/100-Simple-Websites.git
cd 100-Simple-Websites/Color\Picker
cp *  /var/www/html
systemctl start nginx
systemctl enable nginx
echo "Nginx is installed and running" >> /home/ec2-user/userdata.log