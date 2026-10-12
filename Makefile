.PHONY: up down logs shell test clean

up:
	docker compose -f compose/docker-compose.yml up -d --build
	docker compose -f compose/docker-compose.yml run --rm wpcli
	@echo "Site is up: http://localhost:8080"

down:
	docker compose -f compose/docker-compose.yml down

logs:
	docker compose -f compose/docker-compose.yml logs -f

shell:
	docker compose -f compose/docker-compose.yml exec php sh

test:
	bash tests/smoke/check.sh

clean:
	docker compose -f compose/docker-compose.yml down -v
