# Prometheus
Prometheus container

    The AWS image builds but fails at 'docker pull'. A dna_base image has not been created yet. Once dna_base
    is ready, the docker commands will work.
    
    All trusted Cert name to be changed for each environment if needed
    
    The packer environment variables need to be set up for each platform you are building on. Include the user
    name and user password for the AWS platform and just the user name for the AWS2 platform.
    
Dev Notes

    Prometheus -
        When using the environment variable PROMETHEUS_CONFIG to set the test configuration, 
        after exporting the variable, I had to use '-E' in the docker-compose command.
        sudo -E docker-compose up

    Packer -
        All of the builders are contained in 'prometheus-template.json'.
        To use just one of the builders: packer build -only={builder name} prometheus-template.json
        Or to not use one of the builders: packer build -except={builder name} prometheus-template.json
        
        Now using two variable files
        1. Create a variable file for the credentials and include
            aws_access_key
            aws_secret_key
            aws_session_token
            
        2. Create a variable file and add the folowing variables per build
        
        aws_builder:
            newuser_name
            newuser_pass
            aws_region
            aws_security_group
            aws_vpc_id
            aws_subnet_id
            aws_zone
            source_ami_owner
            source_name_filter
            

        aws2_builder:
            newuser_name
            aws_region
            aws_security_group
            aws_vpc_id
            aws_subnet_id
            aws_zone
            aws_endpoint
            source_ami_owner
            source_name_filter

        open_builder:
            bot_user_pass
            newuser_pass
            source_image_name
            open_flavor
            open_region
            open_tenant_name
            id_endpoint

        Usage:
            packer build -only=aws_builder -var-file={path to credentials file} -var-file={path to var file} {path to prometheus-template.json}
            or        
            packer build -only=aws_builder \
            -var 'newuser_name=foo' \
            -var 'region=us-east-1b' \
            -var 'source_image_name=ubuntu-1234' \
            -var ...
            {path to prometheus-template.json}

    cAdvisor -
        May need to use --privileged=true and --volume=/cgroup:/cgroup:ro on CentOS to give cAdvisor proper access

        To fix an error on centOS 'inotify_add_watch not found', do the following
        mount -o remount,rw 'sys/fs/cgroup'
        ln -s /sys/fs/cgroup/cpu,cpuacct /sys/fs/cgroup/cpuacct,cpu

        On aws you need to run the docker container with the following command
        docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/cgroup:/sys/fs/cgroup:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --detach=true --name=cadvisor google/cadvisor:latest

