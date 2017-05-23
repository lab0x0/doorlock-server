```
## RUN ON SERVER

docker run -d   -p 127.0.0.1:8002:4567  -v "$(pwd)/db:/app/db" -e  APP_ID="12345678"  -e APP_SECRET="12345678" -e APP_TOKEN="12345678" -e TOTP_TOKEN="12345678" -e PUMA_WORKERS="1" -e MIN_THREADS="1" -e MAX_THREADS="16" -e RAILS_ENV="production" -e RACK_ENV="production" --name doorlock targence/doorlock
```

```
## PULL IMAGE FROM: hub.docker.com/r/targence/doorlock

docker pull targence/doorlock
```


```
## OR BUILD IMAGE

docker build --no-cache  . -t targence/doorlock
```
