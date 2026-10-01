# Assignment 5 — Consolidated EC2 Deployment with Nginx Reverse Proxy

## Portfolio Summary

Designed and deployed a consolidated multi-container Todo platform on AWS EC2 using Docker Compose and Nginx as a reverse proxy. Three independent APIs—Rust/PostgreSQL, PHP/MySQL, and Python/SQLite—run on a shared private Docker network behind a single public entry point. The deployment implements persistent storage, health checks, automatic container recovery, restricted security-group access, and server-side environment secrets. The stack was validated through API, persistence, container restart, and full EC2 reboot tests.

## Overview

This project consolidates three previously developed Todo APIs onto a single AWS EC2 instance.

Instead of exposing each application independently, Nginx acts as the single public entry point and routes requests to the appropriate backend service.

The deployment demonstrates:

* AWS EC2 infrastructure
* Docker and Docker Compose
* Nginx reverse proxy
* Container networking
* Persistent Docker volumes
* PostgreSQL
* MySQL
* SQLite
* Rust
* PHP
* Python
* Health checks
* Automatic container restart
* Security group configuration
* Environment-based secrets
* Application persistence
* EC2 reboot recovery

## Architecture

```text
                         Internet
                            |
                            | HTTP :80
                            v
                 +----------------------+
                 |   Nginx Reverse      |
                 |       Proxy           |
                 |  todo-main-nginx      |
                 +----------+-----------+
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
       /rust-todos/   /php-todos/   /sqlite-todos/
              |             |             |
              v             v             v
       +-------------+ +-----------+ +-------------+
       | Rust API    | | PHP Nginx | | SQLite API  |
       | Port 3000   | | Port 80   | | Port 3000   |
       +------+------+ +-----+-----+ +------+------+
              |              |                |
              v              v                |
       +-------------+ +-----------+          |
       | PostgreSQL  | | PHP-FPM   |          |
       | Port 5432   | | Port 9000 |          |
       +-------------+ +-----+-----+          |
                            |                 |
                            v                 |
                      +-----------+           |
                      |   MySQL   |           |
                      |   3306    |           |
                      +-----------+           |
                                             |
              All services share one private Docker network
```

## APIs

| API             | Application | Database   | Internal Port | Public Route     |
| --------------- | ----------- | ---------- | ------------: | ---------------- |
| Rust Todo API   | Rust        | PostgreSQL |          3000 | `/rust-todos/`   |
| PHP Todo API    | PHP         | MySQL      |            80 | `/php-todos/`    |
| SQLite Todo API | Python      | SQLite     |          3000 | `/sqlite-todos/` |

## AWS Infrastructure

The deployment uses:

* AWS EC2
* Ubuntu 24.04 LTS
* `t3.small` instance
* Docker Engine
* Docker Compose
* Nginx

Only Nginx is exposed publicly.

### Security Group

The EC2 security group allows:

| Protocol | Port | Source      | Purpose             |
| -------- | ---: | ----------- | ------------------- |
| TCP      |   22 | My IP `/32` | SSH administration  |
| TCP      |   80 | `0.0.0.0/0` | Public HTTP traffic |

No application or database ports are exposed directly to the Internet.

## Project Structure

```text
assignment-5-consolidated-ec2/
├── README.md
├── docker-compose.yml
└── nginx/
    └── nginx.conf
```

The three application repositories are located alongside this project in the portfolio repository:

```text
devops-portfolio/
├── todo-api/
├── php-mysql-todo-api/
├── rust-postgres-todo-api/
└── assignment-5-consolidated-ec2/
```

## Docker Services

The production deployment contains seven containers:

1. `todo-main-nginx`
2. `rust-todo-api`
3. `rust-todo-postgres`
4. `todo-nginx`
5. `todo-php`
6. `todo-mysql`
7. `sqlite-todo-api`

All containers are connected to the same Docker bridge network:

```text
todo-network
```

Application and database containers do not publish host ports.

Only the main Nginx container publishes port `80`.

## Nginx Reverse Proxy

The top-level Nginx container provides the public entry point.

### Routing

```text
/rust-todos/   → rust-todo-api:3000
/php-todos/    → todo-nginx:80
/sqlite-todos/ → sqlite-todo-api:3000
```

The root path provides a simple gateway response:

```text
Todo API Gateway is running
```

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name _;

    location = / {
        default_type text/plain;
        return 200 "Todo API Gateway is running\n";
    }

    location /rust-todos/ {
        proxy_pass http://rust-todo-api:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /php-todos/ {
        proxy_pass http://todo-nginx/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /sqlite-todos/ {
        proxy_pass http://sqlite-todo-api:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Request Flow

### Rust API

```text
Client
  |
  v
EC2 :80
  |
  v
Nginx
  |
  v
rust-todo-api:3000
  |
  v
rust-todo-postgres:5432
```

### PHP API

```text
Client
  |
  v
EC2 :80
  |
  v
Nginx
  |
  v
todo-nginx:80
  |
  v
todo-php:9000
  |
  v
todo-mysql:3306
```

### SQLite API

```text
Client
  |
  v
EC2 :80
  |
  v
Nginx
  |
  v
sqlite-todo-api:3000
  |
  v
SQLite database
```

## Persistent Storage

Three named Docker volumes provide persistent storage:

```text
postgres-data
mysql-data
sqlite-data
```

### PostgreSQL

```text
postgres-data
    ↓
/var/lib/postgresql/data
```

### MySQL

```text
mysql-data
    ↓
/var/lib/mysql
```

### SQLite

```text
sqlite-data
    ↓
/data
```

This allows application data to survive container restarts and EC2 instance reboots.

## Environment Variables and Secrets

Database credentials are supplied through environment variables.

Example `.env` file:

```dotenv
POSTGRES_DB=todos
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_secure_postgres_password

MYSQL_ROOT_PASSWORD=your_secure_mysql_root_password
MYSQL_DATABASE=todos
MYSQL_USER=your_mysql_user
MYSQL_PASSWORD=your_secure_mysql_password
```

**Important:** The real `.env` file is stored only on the EC2 server and is not committed to GitHub.

Never commit production credentials, database passwords, private keys, or other secrets to the repository.

## Fresh EC2 Deployment

### 1. Connect to EC2

```bash
ssh -i ~/.ssh/todo-consolidated-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### 2. Clone the portfolio repository

```bash
git clone https://github.com/Kolawole-Olaribigbe/devops-portfolio.git
cd devops-portfolio/assignment-5-consolidated-ec2
```

### 3. Create the environment file

```bash
nano .env
```

Add your own secure values:

```dotenv
POSTGRES_DB=todos
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_secure_postgres_password

MYSQL_ROOT_PASSWORD=your_secure_mysql_root_password
MYSQL_DATABASE=todos
MYSQL_USER=your_mysql_user
MYSQL_PASSWORD=your_secure_mysql_password
```

Protect the file:

```bash
chmod 600 .env
```

### 4. Start the stack

```bash
docker compose up -d --build
```

### 5. Verify the deployment

```bash
docker compose ps
```

All seven containers should be running.

## Port Exposure Verification

Run:

```bash
docker compose ps
```

Only the main Nginx container should show a host port mapping:

```text
0.0.0.0:80->80/tcp
```

The application and database containers should show only their internal container ports.

This ensures that:

* PostgreSQL is not publicly exposed
* MySQL is not publicly exposed
* Rust API is not publicly exposed
* SQLite API is not publicly
