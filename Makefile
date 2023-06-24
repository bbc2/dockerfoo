project_name=dockerfoo
env=main
python_src=src tests integration_tests

full_env=${project_name}-${env}
secrets_dir=.secrets/${env}

# Docker resources
docker_services=dev-database cli db-ops test-database test-run
docker_networks=${full_env}_default
docker_volumes=${full_env}_history ${full_env}_db

# Docker project
d_env=--project-name "${full_env}"
export DF_SECRETS_DIR=${secrets_dir}

# Docker profiles
p_dev_ops=--profile dev-ops

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
	docker compose ${d_env} ${p_dev_ops} build

${secrets_dir}:
	mkdir -p "${secrets_dir}"
	chmod u+rwx,go-rwx "${secrets_dir}"
	@echo "$$(head --bytes 15 < /dev/urandom | base64)" > "${secrets_dir}/db_password"
	@echo "database:*:*:*:$$(cat "${secrets_dir}/db_password")" > "${secrets_dir}/db_pgpass"
	chmod u+rw,go-rw "${secrets_dir}"/*  # for protection inside the containers

.PHONY: serve
serve: ${secrets_dir}  ## Run main Docker Compose services.
	docker compose ${d_env} up

.PHONY: run-cli
run-cli: ${secrets_dir}  ## Run CLI in Docker.
	docker compose ${d_env} run --rm cli

.PHONY: run-db-ops
run-db-ops: ${secrets_dir}  ## Run database shell in Docker.
	docker compose ${d_env} run --rm db-ops

.PHONY: db-reset
db-reset:  ## Reset the database.
	docker compose ${d_env} rm --force --stop --volumes
	docker volume rm --force "${full_env}_db"

.PHONY: clean
clean:  ## Remove all resources used by this project.
	docker compose ${d_env} rm --force --stop --volumes
	docker compose ${d_env} kill --remove-orphans
	docker volume rm --force ${docker_volumes}
	docker network rm --force ${docker_networks}
	rm -rf "${secrets_dir}"

.PHONY: run-integration-tests
run-integration-tests: override full_env=${project_name}-integration-tests
run-integration-tests: options= \
	--file compose/integration_tests.yml \
	--project-name "${full_env}"
run-integration-tests: override p_dev=--file compose/integration_tests.yml
run-integration-tests:  ## Run integration tests
	docker compose ${options} rm --force --stop --volumes
	docker volume rm --force ${docker_volumes}
	docker network rm --force ${docker_networks}
	docker compose ${options} build
	docker compose ${options} run --rm run pytest integration_tests
	docker compose ${options} rm --force --stop --volumes
	docker volume rm --force ${docker_volumes}
	docker network rm --force ${docker_networks}
