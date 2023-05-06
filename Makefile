project_name=dockerfoo
python_src=src tests integration_tests

# Docker resources
docker_services=dev-database dev-cli dev-db-ops test-database test-run
docker_networks=${project_name}_default
docker_volumes=${project_name}_dev-history ${project_name}_dev-db ${project_name}_test-db

# Docker profiles
p_dev=--profile dev
p_dev_ops=--profile dev-ops
p_test=--profile test

.PHONY: help
help:  # from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: check
check:  ## Check source code.
	mypy ${python_src}
	ruff check ${python_src}
	pytest tests
	black --check ${python_src}
	poetry check

.PHONY: format
format:  ## Format source code.
	ruff check --select I --fix ${python_src}
	black ${python_src}

.PHONY: build
build:  ## Build all Docker Compose services.
	docker compose ${p_dev} ${p_dev_ops} ${p_test} build

.secrets:
	mkdir -p .secrets
	chmod u+rwx,go-rwx .secrets
	@echo "$$(head --bytes 15 < /dev/urandom | base64)" > .secrets/db_password
	@echo "dev-database:*:*:*:$$(cat .secrets/db_password)" > .secrets/db_pgpass
	chmod u+rw,go-rw .secrets/*  # for protection inside the containers

.PHONY: serve
serve: .secrets	 ## Run main Docker Compose services.
	docker compose ${p_dev} up

.PHONY: run-cli
run-cli: .secrets  ## Run CLI in Docker.
	docker compose ${p_dev} run --rm dev-cli

.PHONY: run-db-ops
run-db-ops: .secrets  ## Run database shell in Docker.
	docker compose ${p_dev} run --rm dev-db-ops

.PHONY: db-reset
db-reset:  ## Reset the database.
	docker compose ${p_dev} rm --force --stop --volumes
	docker volume rm --force "${project_name}_dev-db"

.PHONY: clean
clean:  ## Remove all resources used by this project.
	docker compose ${p_dev} rm --force --stop --volumes
	docker compose ${p_dev} kill --remove-orphans
	docker volume rm --force ${docker_volumes}
	docker network rm --force ${docker_networks}
	rm -rf .secrets

.PHONY: run-integration-tests
run-integration-tests:
	docker compose ${p_test} rm --force --stop --volumes
	docker volume rm --force "${project_name}_test-db"
	docker compose ${p_test} build
	docker compose ${p_test} run --rm test-run pytest integration_tests
	docker compose ${p_test} rm --force --stop --volumes
	docker volume rm --force "${project_name}_test-db"
