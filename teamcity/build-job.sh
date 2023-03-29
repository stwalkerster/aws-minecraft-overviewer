#!/bin/bash

if [[ $(sudo nvme list | grep -c "Elastic Block Store") == "3" ]]; then
	echo "Disks already mounted."
else
	aws ec2 attach-volume --device /dev/sdf --instance-id $(ec2metadata --instance-id) --volume-id vol-%volid.maps%
	aws ec2 attach-volume --device /dev/sdg --instance-id $(ec2metadata --instance-id) --volume-id vol-%volid.worlds%
    sleep 10
    sudo mkdir -p /srv/minecraft-maps /srv/minecraft-worlds
    sudo mount -text4 /dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol%volid.maps% /srv/minecraft-maps
    sudo mount -text4 /dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol%volid.worlds% /srv/minecraft-worlds
fi


function serverCommand {
    ssh -o 'StrictHostKeyChecking accept-new' minecraft@${ServerHost} 'echo '"'"$1"'"' > /run/minecraft-'$InstanceName'.control'
}

serverCommand 'tellraw @a {"text":"[Server: Starting AWS %TaskName%...]","color":"gray","italic":true}'
serverCommand 'save-off'
serverCommand 'save-all'

sleep 5

docker image ls

sudo mkdir -p /srv/minecraft-worlds /srv/minecraft-maps /srv/minecraft-maps/${InstanceName}/custom-icons/
sudo chown teamcity-agent /srv/minecraft-worlds /srv/minecraft-maps /srv/minecraft-maps/${InstanceName}/custom-icons/

rsync -e "ssh -o StrictHostKeyChecking=accept-new" -avz --exclude=plugins/ --exclude=logs/ --exclude=libraries/ --exclude=crash-reports/ --delete minecraft@${ServerHost}:/opt/minecraft/${InstanceName}/ /srv/minecraft-worlds/${InstanceName}/

serverCommand 'save-on'

sudo rsync -a --delete icons/ /srv/minecraft-maps/${InstanceName}/custom-icons/

# UID 1000 because the container runs as that UID
sudo chown -R 1000:1000 /srv/minecraft-maps/${InstanceName}
sudo chmod -R a+rX /srv/minecraft-worlds/${InstanceName}/

sudo rm -f /srv/minecraft-maps/${InstanceName}/progress.json.bak
if [[ -f /srv/minecraft-maps/${InstanceName}/progress.json ]]; then
	sudo cp -a /srv/minecraft-maps/${InstanceName}/progress.json /srv/minecraft-maps/${InstanceName}/progress.json.bak
fi

if [[ "%TaskName%" == "POI update" ]]; then
	taskFlags="--genpoi"
fi

docker run --rm \
    ${DockerFlags} \
	--name=overviewer-${InstanceName} \
    -e BUILD_WORLD_UNIX_NAME=${InstanceName} \
    -e BUILD_WORLD_PATH=/world/world \
    -e BUILD_RENDER_FANCY_BITS=%renderFancyBits% \
    -v /srv/minecraft-worlds/${InstanceName}:/world \
    -v $(pwd):/config \
    -v /srv/minecraft-maps:/map %imageName% \
    --config=/config/config.py ${taskFlags} ${RenderFlags}
    
if [[ "%TaskName%" == "POI update" ]] && [[ -f /srv/minecraft-maps/${InstanceName}/progress.json.bak ]]; then
	sudo cp -a /srv/minecraft-maps/${InstanceName}/progress.json.bak /srv/minecraft-maps/${InstanceName}/progress.json
fi

serverCommand 'tellraw @a {"text":"[Server: Completed AWS %TaskName%]","italic":true,"color":"gray"}'
