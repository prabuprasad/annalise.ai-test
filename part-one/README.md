# I have included all variables in main.tf file.

# This terrform file will connect to AWS and do the following steps

    Create a vpc
    Create subnets for different parts of the infrastructure
    Attach an internet gateway to the VPC
    Create a route table for a public subnet
    Create security groups to allow specific traffic
    Create ec2 instances on the subnets

# I also like to attach my terraform file, which will be used to setup a three node kubernetes cluster under Rancher (kubernetes Orchestration tool) for our development purpose.