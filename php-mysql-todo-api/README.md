# PHP MySQL Todo API

A containerized Todo List REST API built with **PHP, MySQL, Nginx, and Docker Compose**.

The project demonstrates how to run a PHP application with PHP-FPM behind Nginx and connect it to a separate MySQL database container with persistent storage.

## Architecture

```text
Client
  │
  ▼
Nginx :8080
  │
  ▼
PHP-FPM :9000
  │
  ▼
MySQL :3306
  │
  ▼
Named Volume
mysql-data
```

## Technologies

* PHP 8.3
* PHP-FPM
* Nginx
* MySQL 8.0
* Docker
* Docker Compose
* PDO
* SQL prepared statements

## Features

* Create, read, update, and delete todos
* MySQL database persistence
* Automatic database table creation
* Prepared statements for database queries
* Environment-based database configuration
* Input validation
* HTTP 400 and 404 error handling
* MySQL healthcheck
* PHP waits for MySQL to become healthy
* Nginx reverse proxy to PHP-FPM

## API Endpoints

| Method | Endpoint      | Description       |
| ------ | ------------- | ----------------- |
| GET    | `/todos`      | Get all todos     |
| GET    | `/todos/{id}` | Get a single todo |
| POST   | `/todos`      | Create a todo     |
| PUT    | `/todos/{id}` | Update a todo     |
| DELETE | `/todos/{id}` | Delete a todo     |

## Running the Project

Clone the repository and enter the project directory:

```bash
cd php-mysql-todo-api
```

Start the application:

```bash
docker.compose up --build -d
```

The API will be available at:

```text
http://localhost:8080
```

Check the running containers:

```bash
docker.compose ps
```

## Database Configuration

The PHP container receives its database configuration through environment variables:

```yaml
DB_HOST: mysql
DB_NAME: todos
DB_USER: todo_user
DB_PASSWORD: todo_password
```

The MySQL container is configured with:

```yaml
MYSQL_ROOT_PASSWORD: root_password
MYSQL_DATABASE: todos
MYSQL_USER: todo_user
MYSQL_PASSWORD: todo_password
```

## Example Requests

### Create a Todo

```bash
curl -X POST http://localhost:8080/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Docker Compose"}'
```

### Get All Todos

```bash
curl http://localhost:8080/todos
```

### Get a Todo by ID

```bash
curl http://localhost:8080/todos/1
```

### Update a Todo

```bash
curl -X PUT http://localhost:8080/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

### Delete a Todo

```bash
curl -X DELETE http://localhost:8080/todos/1
```

## Error Handling

The API validates incoming requests and returns appropriate HTTP status codes.

Examples:

```text
400 Bad Request
```

Returned for invalid input such as a missing title or invalid `completed` value.

```text
404 Not Found
```

Returned when a requested todo does not exist.

The API does not expose database stack traces to clients.

## Data Persistence

MySQL uses a named Docker volume:

```yaml
volumes:
  - mysql-data:/var/lib/mysql
```

Database data survives:

```bash
docker.compose down
docker.compose up -d
```

The database volume is removed only when explicitly using:

```bash
docker.compose down -v
```

## Healthcheck

MySQL includes a Docker healthcheck:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "todo_user", "-ptodo_password"]
  interval: 5s
  timeout: 5s
  retries: 10
```

PHP depends on MySQL becoming healthy before starting:

```yaml
depends_on:
  mysql:
    condition: service_healthy
```

This helps prevent the PHP application from starting before the database is ready.

## Project Structure

```text
php-mysql-todo-api/
├── Dockerfile
├── docker-compose.yml
├── index.php
├── nginx/
│   └── default.conf
├── .gitignore
└── README.md
```

## What I Practiced

This project provided hands-on practice with:

* Containerizing a PHP application
* Docker Compose multi-container architecture
* PHP-FPM and Nginx integration
* MySQL container configuration
* Docker named volumes
* Service dependencies and healthchecks
* Environment variables
* REST API development
* PDO and prepared SQL statements
* API validation and HTTP status codes
* Testing containerized applications with `curl`

