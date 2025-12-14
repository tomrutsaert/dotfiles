Generate systemd user service for podman-compose

From the directory containing docker-compose.yml:

`docker-compose up -d`

with systemd

```
sudo cp ollama.service /etc/systemd/system/ollama.service
sudo systemctl daemon-reload
sudo systemctl enable --now ollama.service
sudo systemctl status ollama.service
```