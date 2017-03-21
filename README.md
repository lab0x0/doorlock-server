```
## RUN ON SERVER

docker run -d -e APP_ID="12345678" -e APP_SECRET="12345678" -e APP_TOKEN="12345678" -e TOTP_TOKEN="12345678" -e PUMA_WORKERS="1" -e MIN_THREADS="1" -e MAX_THREADS="16" -e RAILS_ENV="production" -e RACK_ENV="production" --name doorlock  targence/doorlock
```


```
## BUILD IMAGE

docker build --no-cache  . -t targence/doorlock
```
