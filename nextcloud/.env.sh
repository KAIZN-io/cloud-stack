traefik_ip_address=`docker inspect --format '{{ .NetworkSettings.Networks.traefik_network.IPAddress }}' traefik-traefik-1`
traefik_ip_prefix_length=`docker inspect --format '{{ .NetworkSettings.Networks.traefik_network.IPPrefixLen }}' traefik-traefik-1`

TRAEFIK_CIDR="${traefik_ip_address}/${traefik_ip_prefix_length}"
