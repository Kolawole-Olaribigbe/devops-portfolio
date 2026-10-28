# Assignment 6: Zero-Touch Deployment with GitLab CI/CD to AWS EC2

## Project Overview

This project automates the deployment of a multi-API Todo application to an AWS EC2 instance using GitLab CI/CD, Docker, and Nginx.

It builds on Assignment 5, which consolidated multiple Todo APIs behind a single Nginx entry point. Assignment 6 extends that deployment with an automated pipeline for configuration validation, container image publishing, deployment, and smoke testing.

The goal is to reduce manual deployment steps and make application updates more consistent and repeatable.

## Objectives

- Validate Docker Compose and Nginx configuration through CI/CD.
- Build and publish versioned Docker images to the GitLab Container Registry.
- Deploy application updates to an AWS EC2 instance through a dedicated GitLab Runner.
- Run smoke tests after deployment.
- Keep application deployment separate from image building on the EC2 host.

## Architecture

```text
Developer
   |
   | Push or merge to main
   v
GitLab Repository
   |
   v
GitLab CI/CD Pipeline
   |
   +--> Validate Docker Compose
   |
   +--> Validate Nginx
   |
   +--> Build and publish Docker images
   |       |
   |       v
   |   GitLab Container Registry
   |
   +--> Deploy through dedicated runner
   |       |
   |       v
   |   AWS EC2 Instance
   |       |
   |       v
   |   Docker Compose + Nginx
   |       |
   |       +--> Rust Todo API + PostgreSQL
   |       +--> PHP Todo API + MySQL
   |       +--> SQLite Todo API
   |
   +--> Post-deployment smoke tests
```

## CI/CD Pipeline

The pipeline is organized into three stages:

### 1. Validate

- Validate the Docker Compose configuration.
- Check the Nginx configuration.
- Detect configuration problems before deployment.

### 2. Build and Publish

- Build the required Docker images.
- Tag images with the relevant Git commit identifier.
- Push the images to the GitLab Container Registry.

### 3. Deploy

- Run the deployment job through a dedicated GitLab Runner.
- Use the configured deployment script on the runner.
- Deploy the published images to EC2.
- Run post-deployment smoke tests.

The deployment job is configured to run on the `main` branch.

## Application Architecture

The application uses Docker Compose to manage the services:

- **Nginx:** Public entry point for incoming HTTP traffic.
- **Rust Todo API:** API service backed by PostgreSQL.
- **PHP Todo API:** PHP application backed by MySQL and served through its Nginx service.
- **SQLite Todo API:** Todo API using SQLite for data storage.
- **Docker network:** Allows application services to communicate internally.
- **Named volumes:** Provide persistent storage for database data.

The intended deployment model uses published container images rather than building application images directly on the EC2 host.

## Security and Reliability Considerations

- Store credentials in GitLab CI/CD variables instead of committing secrets to the repository.
- Keep private keys, environment files, and other sensitive configuration out of Git.
- Use versioned container image tags to identify application builds.
- Validate configuration before deployment.
- Use post-deployment smoke tests to check whether the deployment is responding as expected.
- Restrict public access to the services that need it; keep backend services on the internal Docker network where possible.

## Technology Stack

- Amazon Web Services (AWS EC2)
- GitLab CI/CD
- GitLab Container Registry
- GitLab Runner
- Docker
- Docker Compose
- Nginx
- Linux
- Rust
- PHP
- PostgreSQL
- MySQL
- SQLite
- Bash and shell scripting

## Key Learning Outcomes

Through this project, I practised:

- Building multi-stage CI/CD pipelines.
- Validating Docker and Nginx configuration automatically.
- Building and publishing container images.
- Using commit-based image tags.
- Configuring a dedicated runner for deployment tasks.
- Separating image publishing from application deployment.
- Deploying multi-container applications to AWS EC2.
- Performing post-deployment smoke tests.
- Managing deployment configuration and credentials more carefully.

## Relationship to Assignment 5

Assignment 5 focused on consolidating multiple Todo APIs behind a single Nginx entry point on AWS EC2.

Assignment 6 builds on that foundation by introducing automated validation, container image publishing, deployment orchestration, and smoke testing through GitLab CI/CD.

## Deployment Notes

This project depends on environment-specific infrastructure and configuration, including GitLab CI/CD variables, a configured GitLab Runner, AWS EC2, registry access, and the deployment script installed for the runner.

These resources must be configured before the pipeline can be reproduced in another environment. The deployment script is not included in this repository, so its internal implementation is not documented here.

## Conclusion

This project demonstrates practical experience with cloud infrastructure, Docker-based application deployment, GitLab CI/CD automation, and operational testing.

It represents a step toward repeatable, reliable deployments as part of my development as a Cloud Infrastructure and DevOps Engineer.
