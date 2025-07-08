## Gaming Website

- `docker compose -f php-gaming-website/deploy/single-server/docker-compose.yml up -d`
- `docker compose -f php-gaming-website/deploy/single-server/docker-compose.yml down --remove-orphans`

## Restler

- `docker build -t restler .`
- `docker build --no-cache -t restler ./restler-fuzzer  `

```sh
docker run -it --rm \
  -v $(pwd)/restler-fuzzer/data:/data \
  --network host \
  restler \
  python3 /data/restler-quick-start.py \
  --api_spec_path /data/openapi.yaml \
  --restler_drop_dir /RESTler \
  --ip localhost \
  --port 80
```

### With Custom Dictionary

```sh
docker run -it --rm \
  -v $(pwd)/restler-fuzzer/data:/data \
  --network host \
  restler \
  python3 /RESTler/restler/restler.py fuzz \
  --grammar_file /data/grammar.py \
  --dictionary_file /data/custom_dict.json \
  --settings /data/restler_settings.json \
  --target_ip localhost \d
  --target_port 80
```

### Testing

- `docker run -it --rm -v $(pwd)/restler-fuzzer/data:/data --network host restler /bin/sh`

`curl -c cookies.txt -b cookies.txt -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "login[email]=test@test.ie&login[password]=testtest" \
  http://localhost:80/login`

`git clone https://github.com/microsoft/restler-fuzzer.git`
`git clone https://github.com/marein/php-gaming-website.git`

1. `docker run -it --rm -v $(pwd)/data:/data --network host restler /bin/sh`
2. `python3 /data/restler-quick-start.py \
--api_spec_path /data/openapi.yaml \
--restler_drop_dir /RESTler \
--ip localhost \
--port 80`
3. `cp -r /restler_working_dir/ /data`
