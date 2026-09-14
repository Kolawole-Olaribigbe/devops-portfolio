# Todo API — Single Docker Container

A beginner-friendly REST API built with **Python, Flask, and SQLite**, then containerized with Docker.

This project demonstrates core Docker fundamentals without Docker Compose, including image building, container management, health checks, non-root execution, environment variables, and persistent storage using a named Docker volume.

## Project Objectives

* Build a REST API with Flask
* Store Todo data in SQLite
* Create a Docker image using a slim Python base image
* Run the application as a non-root user
* Configure the database path using an environment variable
* Add a Docker health check
* Persist SQLite data using a named Docker volume
* Demonstrate that data survives container removal and recreation

## Technologies Used

* Python 3.12
* Flask 3.1.2
* SQLite
* Docker
* Docker named volumes
* Bash / Linux

## API Endpoints

| Method | Endpoint     | Description      |
| ------ | ------------ | ---------------- |
| GET    | `/health`    | Check API health |
| GET    | `/todos`     | Get all Todos    |
| POST   | `/todos`     | Create a Todo    |
| GET    | `/todos/:id` | Get one Todo     |
| PUT    | `/todos/:id` | Update a Todo    |
| DELETE | `/todos/:id` | Delete a Todo    |

Each Todo contains:

* `id`
* `title`
* `completed`

## Database

The application uses SQLite.

The database path is configurable through the `DB_PATH` environment variable.

Inside the Docker container:

```text
DB_PATH=/data/todos.db
```

The `/data` directory is connected to the Docker named volume:

```text
todos-data -> /data
```

This allows the SQLite database to survive when the container is removed.

## Project Structure

```text
todo-api/
├── app.py
├── requirements.txt
├── Dockerfile
├── .dockerignore
└── README.md
```

## Build the Docker Image

From the project directory:

```bash
docker build -t todo-api .
```

This creates the image:

```text
todo-api:latest
```

## Create the Persistent Volume

Create a named Docker volume:

```bash
docker volume create todos-data
```

The volume stores the SQLite database independently of the container.

## Run the Container

```bash
docker run -d \
  --name todo-api \
  --restart unless-stopped \
  -p 3000:3000 \
  -e DB_PATH=/data/todos.db \
  -v todos-data:/data \
  todo-api:latest
```

### Docker Run Options Explained

| Option                      | Purpose                                                             |
| --------------------------- | ------------------------------------------------------------------- |
| `-d`                        | Runs the container in detached/background mode                      |
| `--name todo-api`           | Gives the container a predictable name                              |
| `--restart unless-stopped`  | Automatically restarts the container unless it was manually stopped |
| `-p 3000:3000`              | Maps host port 3000 to container port 3000                          |
| `-e DB_PATH=/data/todos.db` | Sets the SQLite database path inside the container                  |
| `-v todos-data:/data`       | Mounts the named volume to `/data` for persistent storage           |
| `todo-api:latest`           | Specifies the Docker image to run                                   |

## Test the API

### Health Check

```bash
curl http://localhost:3000/health
```

Expected:

```json
{"status":"healthy"}
```

### Create a Todo

```bash
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Docker","completed":false}'
```

### Get All Todos

```bash
curl http://localhost:3000/todos
```

### Get a Todo

```bash
curl http://localhost:3000/todos/1
```

### Update a Todo

```bash
curl -X PUT http://localhost:3000/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Docker fundamentals","completed":true}'
```

### Delete a Todo

```bash
curl -X DELETE http://localhost:3000/todos/1
```

## Verify Container Health

```bash
docker ps
```

The container should show:

```text
(healthy)
```

The Docker health check calls:

```text
GET /health
```

## Verify Non-Root Execution

The container runs as the `appuser` user instead of root.

Verify with:

```bash
docker inspect todo-api --format '{{.Config.User}}'
```

Expected:

```text
appuser
```

## Test Data Persistence

Create a Todo:

```bash
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Docker persistence test","completed":false}'
```

Stop the container:

```bash
docker stop todo-api
```

Remove the container:

```bash
docker rm todo-api
```

Recreate the container using the same named volume:

```bash
docker run -d \
  --name todo-api \
  --restart unless-stopped \
  -p 3000:3000 \
  -e DB_PATH=/data/todos.db \
  -v todos-data:/data \
  todo-api:latest
```

Check the Todo:

```bash
curl http://localhost:3000/todos
```

The Todo should still exist.

This demonstrates that the data is stored in the `todos-data` volume rather than being dependent on the container itself.

### Important

Removing the container does **not** remove the named volume.

To remove the stored Todo data, the volume itself must be removed:

```bash
docker volume rm todos-data
```

## Docker Configuration

The Dockerfile includes:

* Python 3.12 slim base image
* Dependency installation before application source copy
* Non-root `appuser`
* Port exposure
* Docker health check
* Persistent `/data` directory
* Python application startup command

## What I Learned

Through this project I practiced:

* Building Docker images
* Writing a Dockerfile
* Docker image layer caching
* Using `.dockerignore`
* Running containers manually
* Port mapping
* Environment variables
* Docker health checks
* Running containers as non-root users
* Docker named volumes
* Persistent application data
* Container stop/remove/recreation
* Testing REST APIs with `curl`

## Project Outcome

The Todo API runs successfully as a single Docker container with:

* REST API functionality
* SQLite database storage
* Persistent Docker volume
* Health monitoring
* Non-root execution
* Configurable database path
* No Docker Compose dependency

