## Run

```
$ docker run -d -p 80:80 -p 5665:5665 -v /PATH/volume:/etc/icinga2/conf.d/configurations --name icinga2 mlabouardy/icinga2
```

## Icinga 2 API

The container already enables the Icinga 2 API listening on port `5665`. Export the
port accordingly.

    docker run -d -ti --name icinga2-api -p 80:80 -p 5665:5665 mlabouardy/icinga2

After the container is up and running, connect via HTTP to the exposed port using
the credentials `root:icinga`.

Example (change the IP address to your localhost):

    curl -ksSu root:icinga 'https://192.168.99.100:4665/v1/objects/hosts' | jq '.'

## Icinga Web 2

Icinga Web 2 can be accessed at http://localhost:80/icingaweb2 w/ `icingaadmin:icinga` as credentials.

The configuration is located in /etc/icingaweb2 which is exposed as [volume](#volumes) from
docker.

By default the icingaweb2 database is created including the `root` user. Additional
configuration is also added to skip the setup wizard.

## Ports

The following ports are exposed:

  Port     | Service
  ---------|---------
  80       | HTTP
  443      | HTTPS
  5665     | Icinga 2 API & Cluster

## Volumes

These volumes can be mounted in order to test and develop various stuff.

    /etc/icinga2
    /etc/icingaweb2
    /var/lib/icinga2
    /usr/share/icingaweb2
