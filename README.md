# AWS Infrastructure with Terraform

This project demonstrates how to provision and configure a simple AWS infrastructure using Terraform. The infrastructure includes a Virtual Private Cloud (VPC), subnets, a security group, an EC2 instance running Apache2, and other essential AWS resources. 

---

## Features

- **VPC Creation**: A custom Virtual Private Cloud (VPC) with CIDR block `10.0.0.0/16`.
- **Subnets**: Two subnets created for high availability.
- **Internet Gateway**: Configured for public internet access.
- **Route Table**: Custom route table associated with the subnets to enable routing to the internet.
- **Security Group**: Allows HTTP (80), HTTPS (443), and SSH (22) traffic.
- **EC2 Instance**: A `t2.micro` Ubuntu EC2 instance with Apache2 installed and running.
- **Elastic IP**: Public IP address associated with the EC2 instance for internet access.
- **Custom Network Interface**: Used for attaching to the EC2 instance.
- **Provisioning with User Data**: Bootstraps the EC2 instance with Apache2 web server installation and configuration.

---

## Requirements

- Terraform CLI v1.0 or newer.
- AWS account credentials with necessary permissions.
- SSH key pair for EC2 instance access.

- Access to the AWS `us-east-1` region.

  ![aws terraform](https://github.com/user-attachments/assets/6d5cc239-9457-4c15-b4fc-ca6b93a05170)

  ![terraform](https://github.com/user-attachments/assets/d47ef823-19aa-431c-b692-af6bdfc42cf9)
