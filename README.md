Minecraft Overviewer on AWS
===============

0. Generate an SSH key. Stick the private key in TeamCity in an agent push profile. Stick the public key in your teamcity/userdata.yml.
1. Get the AWS CLI set up appropriately. Review ami/image.pkr.hcl and main.tf for relevant role_arn entries, and reconfigure according to your situation's requirements.
2. `packer build image.pkr.hcl` - this will create an AMI with Minecraft Overviewer already deployed in Docker and ready to run. Import the AMI and snapshot with these commands:
    * `terraform import aws_ami.overviewer[0] $(< ami/manifest.json jq -r .builds[0].artifact_id | cut -d : -f 2)`
    * `terraform import aws_ebs_snapshot.overviewer[0] $(terraform show -json | jq -r '.values.root_module.resources[] | select(.address | contains("aws_ami.overviewer")).values.root_snapshot_id')`
4. `terraform init` and `terraform apply --auto-approve` to create the base infrastructure for TeamCity to use
5. `terraform apply --auto-approve -var format_volume=true` to create a filesystem on each EBS volume. The created instance will terminate itself when done.
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

