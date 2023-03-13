Minecraft Overviewer on AWS
===============

0. Generate an SSH key. Stick the private key in TeamCity in an agent push profile. Stick the public key in your teamcity/userdata.yml.
1. Get the AWS CLI set up appropriately. Review ami/image.pkr.hcl and main.tf for relevant role_arn entries, and reconfigure according to your situation's requirements.
2. `packer build image.pkr.hcl` - this will create an AMI with Minecraft Overviewer already deployed in Docker and ready to run.
3. If you're not me, you'll want to change the instance.tf subnet_id and vpc_id entries to not use my remote state. You'll probably also want to change the security groups to allow SSH from your location, not my TeamCity instance.
4. `terraform init` and `terraform apply --auto-approve` to create the base infrastructure for TeamCity to use
5. Mount the two volumes to an instance, and format them with `mkfs -text4 -L VOLID /dev/nvmeXn1` where VOLID is the AWS volume ID without the "vol-" prefix
6. Configure a TeamCity cloud profile:
    - Source = the AMI built by Packer
    - VPC subnet = whatever works for you, but make sure the subnet can reach the internet (via public IP+IGW, or NAT GW)
    - IAM profile = `TeamCityOverviewer`
    - Key pair name = None is fine here, you (probably) won't be SSH-ing in.
    - Instance type = Anything arm64-based with enough CPU/RAM to ~~sink a ship~~ _do the render_.
    - SG: pick both MCOverviewer-runner and teamcity-agent
    - User script: use contents of ./teamcity/userdata.yml
    - Spot instances: yes. Set a sensible bid price for your instance type.
7. Create a build job using the build-job.sh script. Adapt the volume IDs as needed for your volumes. Make sure you have an overviewer config handy in the working directory.

