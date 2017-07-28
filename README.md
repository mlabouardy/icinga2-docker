## Run

```
$ docker run -d -p 80:80 -p 5665:5665 -v /PATH/volume:/etc/icinga2/conf.d/configurations --name icinga2 mlabouardy/icinga2
