traefik_container_id=`./manage.sh traefik ps -q traefik`
traefik_ip_address=`docker inspect --format '{{ .NetworkSettings.Networks.traefik_network.IPAddress }}' ${traefik_container_id}`
traefik_ip_prefix_length=`docker inspect --format '{{ .NetworkSettings.Networks.traefik_network.IPPrefixLen }}' ${traefik_container_id}`

TRAEFIK_CIDR="${traefik_ip_address}/${traefik_ip_prefix_length}"
