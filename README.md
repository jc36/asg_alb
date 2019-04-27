## ASG + ALB
Use Terraform to provision an AWS Autoscaling Group, and Application Load Balancer. All instances created by the autoscaling group have bootstrap using the userdata.sh file.

You need change variables **host_headers**, **ssh_allow** and **asg_tag_name** with your values, add **public_key** into `.ssh/key.pem.pub`, and set ENV with your credentials e.g:

    export AWS_ACCESS_KEY_ID=<access_key>
    export AWS_SECRET_ACCESS_KEY=<secret_key>
    export AWS_DEFAULT_REGION=us-east-1

