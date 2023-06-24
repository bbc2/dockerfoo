# Dockerfoo

Demonstration of a development environment with Docker Compose.

## Prerequisites

- Python Poetry
- Docker Compose

## Usage

### Development

Build the container images:

```sh
make build
```

Spin up the database:

```sh
make serve
```

If this is the first time you run this target, the makefile will generate secrets in
`.secrets`.

Run the CLI:

```sh
make run-cli  # This opens a new shell in the CLI container.
```

```sh
dockerfoo init
dockerfoo seed --count 1000000
```

For debugging, you can use the `pqsl` program:

```sh
make run-db-ops  # This opens a new psql CLI connected to the database.
```

```pgsql
\d
select count(*) from tokens
```

If you want to delete the database and start over:

```sh
make reset-db  # This deletes the Docker volume containing the database files.
```

### Production

To use the CLI in production mode, set the following environment variable:

```sh
DF_MODE=prod make build run-cli
```

In production mode, the container has only the production code and no mount point. By
default, `DF_MODE` is `dev`.

## Architecture

### Environment

Almost everything runs in Docker. Notable exceptions are unit tests, code linting and
package updates.

### Code

This project is currently primarily a CLI (`dockerfoo`) which can initialize and update
a database. However, this architecture should be suitable for a web application as well.

```
src/dockerfoo
├── cli: CLI subcommands
├── sql: SQLAlchemy models (no connection code)
├── db: Database connection utilities
└── util: Generic utilities (e.g. timing code)
```
