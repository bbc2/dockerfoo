docker_services=database cli db-ops
docker_networks=dockerfoo_default
docker_volumes=dockerfoo_history dockerfoo_pgdata
python_src=src tests

.PHONY: help
help:  # from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: check
check:  ## Check source code.
	mypy ${python_src}
	ruff check ${python_src}
	pytest
	black --check ${python_src}
	poetry check

.PHONY: format
format:  ## Format source code.
	ruff check --select I --fix ${python_src}
	black ${python_src}

.PHONY: build
build:  ## Build all Docker Compose services.
	docker compose build ${docker_services}

.secrets:
	mkdir -p .secrets
	chmod u+rwx,go-rwx .secrets
	@echo "$$(head --bytes 15 < /dev/urandom | base64)" > .secrets/database_password
	@echo "database:*:*:*:$$(cat .secrets/database_password)" > .secrets/database_pgpass
	chmod u+rw,go-rw .secrets/*  # for protection inside the containers

.PHONY: serve
serve: .secrets	 ## Run main Docker Compose services.
	docker compose up

.PHONY: run-cli
run-cli: .secrets  ## Run CLI in Docker.
	docker compose run --rm cli

.PHONY: run-db-ops
run-db-ops: .secrets  ## Run database shell in Docker.
	docker compose run --rm db-ops

.PHONY: db-reset
db-reset:  ## Reset the database.
	docker compose rm --force --stop --volumes
	docker volume rm --force dockerfoo_pgdata

.PHONY: clean
clean:  ## Remove all resources used by this project.
	docker compose rm --force --stop --volumes
	docker compose kill --remove-orphans
	docker volume rm --force ${docker_volumes}
	docker network rm --force ${docker_networks}
	rm -rf .secrets
