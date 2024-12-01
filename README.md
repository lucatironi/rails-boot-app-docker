# Bootstrap New Rails Apps with Docker

```bash
git clone https://github.com/lucatironi/rails-boot-app-docker
mv rails-boot-app-docker <your-app-name>
cd <your-app-name>
docker volume create ruby-bundle-cache
docker compose up
```