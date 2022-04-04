provider "aws" {
  region = "us-east-1"
  access_key = "AKIAZRZKLPHXOBWJLIER"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXX"
}

# 1. Create VPC

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Production"
    }
}


# 2. create internet gateway
resource "aws_internet_gateway" "gw"{
    vpc_id = aws_vpc.prod-vpc.id


}

# 3. Create custom route table
resource "aws_route_table" "prod-route-table"{
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "Prod"
    }
}


# 4. Create a subnet
resource "aws_subnet" "subnet-1"{
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "prod-subnet"
    }

}

# 5. Associate subnet with route table
resource "aws_route_table_association" "a"{
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-table.id

}

# 6. Create security group to allow port 22, 80 and 443
resource "aws_security_group" "allow_web_traffic" {
    name = "allow_web_traffic"
    description = "Allow web traffic"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "HTTPS traffic "
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "HTTP traffic "
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "SSH traffic "
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_web"
    }

}

# 7. create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = ["10.0.1.50"]
    security_groups = [aws_security_group.allow_web_traffic.id]

}


# 8. Assing an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
    vpc = true
    network_interface = aws_network_interface.web-server-nic.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.gw]

}

# 9. Create Ubuntu server and install/enable apache
resource "aws_instance" "web-server-instance"{
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "main-key-tfm"

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server-nic.id

    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server  > /var/www/html/index.html'
                EOF
    tags = {
        Name  = "web-server"
    }
}



# resource "<provider>_<resource_type>" "name" {
#     config_options...
#     key1 = "value1"
#     key2 = "value2"
# }

# resource "aws_instance" "my-first-terraform" {
#     ami = "ami-0c02fb55956c7d316"
#     instance_type = "t2.micro"

#     tags = {
#         Name = "Myfirst-ubuntu-tfm"
#     }
# }

# resource "aws_vpc" "first_vpc" {
#     cidr_block = "10.0.0.0/16"
#     tags = {
#         Name = "first_vpc_tfm"
#     }
# }

# resource "aws_subnet" "subnet-1"{
#     vpc_id = aws_vpc.first_vpc.id
#     cidr_block = "10.0.1.0/24"

#     tags = {
#         Name = "prod-subnet"
#     }
# }
## https://github.com/Sanjeev-Thiyagarajan/Terraform-Crash-Course/blob/master/main.tf
