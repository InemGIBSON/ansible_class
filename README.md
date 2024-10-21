# ansible_class
LAB SESSION: CONFIGURATION MANAGEMENT WITH ANSIBLE
This lab session will guide you through configuring EC2 instances with Ansible. You will:

Provision EC2 instances on AWS
Set up an Ansible controller node
Manage target hosts using SSH and Ansible playbooks.
1. Provision EC2 Instances
Launch 3 EC2 instances in the AWS console:
Use an Amazon Linux or Ubuntu AMI.
Select t2.micro instance type.
Configure security groups to allow SSH (port 22) and HTTP (port 80) access.
Note: Take note of the public IP addresses of all instances.
2. Assign Roles to EC2 Instances
Controller Node: Designate one EC2 instance as the Ansible server.
Host Machines: The remaining two instances will serve as the managed hosts.
3. Set Inbound Rules
Ensure that inbound security group rules are configured to:

Allow SSH (22) from your local IP (or anywhere for simplicity).
Allow HTTP (80) from anywhere to access web applications.
4. SSH Setup & Key Generation
On the controller node (Ansible server):

Generate an SSH key pair:

bash
Copy code
ssh-keygen -t rsa -b 4096
This will create two files: a private key and a public key.

Copy the SSH public key to the hosts: Use ssh-copy-id to enable passwordless SSH from the controller node to the managed hosts:

bash
Copy code
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@<host-ip>
Verify SSH Access:

bash
Copy code
ssh ubuntu@<host-ip>
5. Set Unique Hostnames for Servers
Rename the hostnames on the EC2 instances to avoid confusion:

bash
Copy code
sudo hostnamectl set-hostname <new-hostname>
6. GitHub Setup (Optional)
Set up a GitHub repository to store your Ansible playbooks:

Initialize a Git repository:
bash
Copy code
git init
Add and commit files:
bash
Copy code
git add .
git commit -m "Initial commit"
Push to GitHub:
bash
Copy code
git remote add origin https://github.com/<username>/<repository>.git
git push -u origin main
7. Install Ansible on the Controller Node
Update your system:

bash
Copy code
sudo yum update -y
Install Ansible: On Amazon Linux/RedHat:

bash
Copy code
sudo yum install epel-release -y
sudo yum install ansible -y
On Ubuntu:

bash
Copy code
sudo apt update && sudo apt install ansible -y
8. Create the Ansible Inventory File
The inventory file is crucial for specifying the target hosts for Ansible to manage.

Create an inventory file (e.g., hosts.ini) in /etc/ansible or your project directory:
ini
Copy code
[web]
host1 ansible_host=<host1-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
host2 ansible_host=<host2-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
9. Create and Run Ansible Playbook to Install WordPress
Now, let's create an Ansible playbook to install and configure WordPress on the target hosts.

Create a playbook (e.g., wordpress.yml):

yaml
Copy code
- hosts: web
  become: yes
  tasks:
    - name: Update apt packages
      apt:
        update_cache: yes

    - name: Install necessary packages for WordPress
      apt:
        name:
          - apache2
          - mysql-server
          - php
          - php-mysql
          - libapache2-mod-php
        state: present

    - name: Download WordPress
      command: wget https://wordpress.org/latest.tar.gz -P /tmp/

    - name: Extract WordPress
      command: tar -xvzf /tmp/latest.tar.gz -C /var/www/html

    - name: Set correct ownership
      file:
        path: /var/www/html/wordpress
        owner: www-data
        group: www-data
        recurse: yes

    - name: Enable Apache rewrite module
      command: a2enmod rewrite

    - name: Restart Apache
      service:
        name: apache2
        state: restarted
Run the Playbook: Execute the playbook to install WordPress on the target nodes:

bash
Copy code
ansible-playbook -i hosts.ini wordpress.yml
10. Additional Steps (Optional)
You might want to configure MySQL for WordPress. This can be added as a task in the playbook.
Customize security group rules for better security practices, such as restricting SSH to specific IP addresses.
Conclusion
By the end of this lab, you will have:

Provisioned EC2 instances.
Configured an Ansible controller and host nodes.
Installed Ansible and set up SSH access.
Deployed WordPress using Ansible playbooks.
This setup showcases the power of configuration management and automation with Ansible, simplifying server and software management across multiple environments.
