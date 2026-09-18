# Rust + PostgreSQL Todo API

A containerized Todo REST API built with **Rust, Axum, SQLx, PostgreSQL, and Docker Compose**.

This project demonstrates multi-container application deployment, persistent PostgreSQL storage, database migrations, API healthchecks, Docker multi-stage builds, and REST API development.

## Architecture

```text
                    ┌─────────────────────┐
                    │     Client / curl    │
                    └──────────┬──────────┘
                               │
                               │ HTTP :3000
                               ▼
                    ┌─────────────────────┐
                    │     Rust API        │
                    │   Axum + SQLx       │
                    │                     │
                    │   /health           │
                    │   /todos            │
                    └──────────┬──────────┘
                               │
                               │ PostgreSQL
                               ▼
                    ┌─────────────────────┐
                    │     PostgreSQL      │
                    │                     │
                    │     todos table     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Docker Volume     │
                    │    postgres-data    │
                    └─────────────────────┘
```

## Tech Stack

* **Rust**
* **Axum** — HTTP web framework
* **SQLx** — PostgreSQL database access and migrations
* **PostgreSQL 16**
* **Docker**
* **Docker Compose**
* **Tokio** — asynchronous runtime
* **Serde / Serde JSON** — JSON serialization
* **Tracing** — application logging

## Features

* RESTful Todo API
* Full CRUD operations
* PostgreSQL database
* Automatic database migrations at application startup
* Docker multi-stage build
* Non-development runtime image based on `debian:bookworm-slim`
* Persistent PostgreSQL named volume
* API healthcheck
* PostgreSQL healthcheck
* Docker Compose service dependency handling
* Environment-based configuration
* Input validation and HTTP error handling
* Structured application logging

## API Endpoints

| Method | Endpoint     | Description                   |
| ------ | ------------ | ----------------------------- |
| GET    | `/health`    | Check API and database health |
| GET    | `/todos`     | Get all todos                 |
| POST   | `/todos`     | Create a todo                 |
| GET    | `/todos/:id` | Get a specific todo           |
| PUT    | `/todos/:id` | Update a todo                 |
| DELETE | `/todos/:id` | Delete a todo                 |

### Todo Structure

```json
{
  "id": 1,
  "title": "Learn Rust",
  "completed": false
}
```

## Project Structure

```text
rust-postgres-todo-api/
├── migrations/
│   └── 0001_create_todos.sql
├── src/
│   └── main.rs
├── .dockerignore
├── .env.example
├── .gitignore
├── Cargo.lock
├── Cargo.toml
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Environment Variables

Create a `.env` file in the project directory.

Example:

```env
POSTGRES_DB=todos
POSTGRES_USER=todo_user
POSTGRES_PASSWORD=your_password
DATABASE_URL=postgres://todo_user:your_password@postgres:5432/todos
RUST_LOG=info
```

A `.env.example` file is included as a safe configuration template.

The actual `.env` file is excluded from Git using `.gitignore`.

## Running the Application

Make sure Docker is installed and running.

Start the application:

```bash
docker.compose up --build -d
```

Check the containers:

```bash
docker.compose ps
```

Both services should report a healthy status.

Example:

```text
rust-todo-api        Up (healthy)
rust-todo-postgres  Up (healthy)
```

## Health Check

The API exposes:

```text
GET /health
```

Test it with:

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

Docker also performs the healthcheck automatically using:

```text
curl -f http://localhost:3000/health
```

## Testing the API

### Get all todos

```bash
curl http://localhost:3000/todos
```

### Create a todo

```bash
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Rust"}'
```

### Get a todo

```bash
curl http://localhost:3000/todos/1
```

### Update a todo

```bash
curl -X PUT http://localhost:3000/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

### Delete a todo

```bash
curl -i -X DELETE http://localhost:3000/todos/1
```

## Input Validation

The API validates incoming requests.

For example, creating a todo without a title:

```bash
curl -i -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":""}'
```

Returns:

```text
HTTP/1.1 400 Bad Request
```

with:

```json
{
  "error": "Title is required"
}
```

Requesting a todo that does not exist returns:

```text
HTTP/1.1 404 Not Found
```

## Database Migrations

SQLx migrations are stored in:

```text
migrations/
```

The application automatically runs pending migrations during startup:

```rust
sqlx::migrate!("./migrations")
    .run(&pool)
    .await?;
```

This means no manual migration command is required when starting the application.

## Data Persistence

PostgreSQL uses a Docker named volume:

```yaml
volumes:
  postgres-data:
```

The volume is mounted at:

```text
/var/lib/postgresql/data
```

The database survives container recreation.

For example:

```bash
docker.compose down
docker.compose up -d
```

Todo records remain available after the containers are recreated.

To deliberately remove the database volume:

```bash
docker.compose down -v
```

**Warning:** `down -v` permanently removes the PostgreSQL data stored in the Docker volume.

## Docker Build

The API uses a multi-stage Docker build.

### Builder stage

The Rust application is compiled using:

```text
rust:1-bookworm
```

### Runtime stage

Only the compiled binary and required runtime dependencies are copied into:

```text
debian:bookworm-slim
```

This keeps the runtime image separate from the Rust build environment.

Build manually with:

```bash
docker build -t rust-postgres-todo-api .
```

## Docker Compose Services

### API

The Rust API:

* Builds from the local Dockerfile
* Exposes port `3000`
* Connects to PostgreSQL using `DATABASE_URL`
* Runs database migrations on startup
* Includes a Docker healthcheck

### PostgreSQL

The database uses:

```text
postgres:16-alpine
```

It includes:

* Database initialization through environment variables
* Persistent Docker volume
* PostgreSQL healthcheck

The API waits for PostgreSQL to become healthy before starting.

## Useful Commands

Start services:

```bash
docker.compose up -d
```

Rebuild and start:

```bash
docker.compose up --build -d
```

View running services:

```bash
docker.compose ps
```

View API logs:

```bash
docker logs rust-todo-api
```

View PostgreSQL logs:

```bash
docker logs rust-todo-postgres
```

Stop and remove containers:

```bash
docker.compose down
```

Stop containers and remove the database volume:

```bash
docker.compose down -v
```

## What This Project Demonstrates

This project demonstrates practical experience with:

* Rust application development
* REST API design
* Axum
* SQLx and PostgreSQL
* Database migrations
* Docker multi-stage builds
* Docker Compose
* Container networking
* Environment-based configuration
* Persistent storage
* Container healthchecks
* Service dependency management
* API validation and error handling
* Application logging
* Linux and command-line tooling

## Project Status

**Completed**

Core requirements and stretch features have been implemented and tested:

* [x] Rust REST API
* [x] PostgreSQL database
* [x] Docker multi-stage build
* [x] Docker Compose
* [x] Full CRUD API
* [x] Automatic SQLx migrations
* [x] Persistent PostgreSQL volume
* [x] API health endpoint
* [x] API Docker healthcheck
* [x] PostgreSQL healthcheck
* [x] Service health dependency
* [x] Input validation
* [x] Error handling
* [x] Structured application logging
* [x] Persistence verified after container recreation

