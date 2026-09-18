use axum::{
    extract::State,
    routing::get,
    Json, Router,
};
use serde::Serialize;
use sqlx::{postgres::PgPoolOptions, PgPool};
use std::env;
use tracing::info;

#[derive(Serialize)]
struct HealthResponse {
    status: String,
}

#[derive(Serialize, sqlx::FromRow)]
struct Todo {
    id: i32,
    title: String,
    completed: bool,
}

#[derive(serde::Deserialize)]
struct CreateTodo {
    title: String,
}

#[derive(serde::Deserialize)]
struct UpdateTodo {
    title: Option<String>,
    completed: Option<bool>,
}

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    tracing_subscriber::fmt::init();

    let database_url =
        env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await?;

    sqlx::migrate!("./migrations")
        .run(&pool)
        .await?;

    info!("Database connected and migrations applied successfully.");

    let app = Router::new()
    .route("/health", get(health))
    .route("/todos", get(get_todos).post(create_todo))
    .route("/todos/{id}", get(get_todo).put(update_todo).delete(delete_todo))
    .with_state(pool);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .expect("Failed to bind to port 3000");

    info!("API listening on http://0.0.0.0:3000");

    axum::serve(listener, app)
        .await
        .expect("Server failed");

    Ok(())
}

async fn health(
    State(pool): State<PgPool>,
) -> (axum::http::StatusCode, Json<HealthResponse>) {
    match sqlx::query("SELECT 1").execute(&pool).await {
        Ok(_) => (
            axum::http::StatusCode::OK,
            Json(HealthResponse {
                status: "healthy".to_string(),
            }),
        ),
        Err(_) => (
            axum::http::StatusCode::SERVICE_UNAVAILABLE,
            Json(HealthResponse {
                status: "unhealthy".to_string(),
            }),
        ),
    }
}

async fn get_todos(
    State(pool): State<PgPool>,
) -> Result<Json<Vec<Todo>>, (axum::http::StatusCode, Json<serde_json::Value>)> {
    let todos = sqlx::query_as::<_, Todo>(
        "SELECT id, title, completed FROM todos ORDER BY id",
    )
    .fetch_all(&pool)
    .await
    .map_err(|_| {
        (
            axum::http::StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({
                "error": "Failed to fetch todos"
            })),
        )
    })?;

    Ok(Json(todos))
}
async fn create_todo(
    State(pool): State<PgPool>,
    Json(payload): Json<CreateTodo>,
) -> Result<
    (axum::http::StatusCode, Json<Todo>),
    (axum::http::StatusCode, Json<serde_json::Value>),
> {
    let title = payload.title.trim();

    if title.is_empty() {
        return Err((
            axum::http::StatusCode::BAD_REQUEST,
            Json(serde_json::json!({
                "error": "Title is required"
            })),
        ));
    }

    let todo = sqlx::query_as::<_, Todo>(
        "INSERT INTO todos (title) VALUES ($1) RETURNING id, title, completed",
    )
    .bind(title)
    .fetch_one(&pool)
    .await
    .map_err(|_| {
        (
            axum::http::StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({
                "error": "Failed to create todo"
            })),
        )
    })?;

    Ok((axum::http::StatusCode::CREATED, Json(todo)))
}

async fn get_todo(
    State(pool): State<PgPool>,
    axum::extract::Path(id): axum::extract::Path<i32>,
) -> Result<
    Json<Todo>,
    (axum::http::StatusCode, Json<serde_json::Value>),
> {
    let todo = sqlx::query_as::<_, Todo>(
        "SELECT id, title, completed FROM todos WHERE id = $1",
    )
    .bind(id)
    .fetch_optional(&pool)
    .await
    .map_err(|_| {
        (
            axum::http::StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({
                "error": "Failed to fetch todo"
            })),
        )
    })?;

    match todo {
        Some(todo) => Ok(Json(todo)),
        None => Err((
            axum::http::StatusCode::NOT_FOUND,
            Json(serde_json::json!({
                "error": "Todo not found"
            })),
        )),
    }
}

async fn update_todo(
    State(pool): State<PgPool>,
    axum::extract::Path(id): axum::extract::Path<i32>,
    Json(payload): Json<UpdateTodo>,
) -> Result<
    Json<Todo>,
    (axum::http::StatusCode, Json<serde_json::Value>),
> {
    if payload.title.is_none() && payload.completed.is_none() {
        return Err((
            axum::http::StatusCode::BAD_REQUEST,
            Json(serde_json::json!({
                "error": "At least one field is required"
            })),
        ));
    }

    if let Some(title) = &payload.title {
        if title.trim().is_empty() {
            return Err((
                axum::http::StatusCode::BAD_REQUEST,
                Json(serde_json::json!({
                    "error": "Title cannot be empty"
                })),
            ));
        }
    }

    let todo = sqlx::query_as::<_, Todo>(
        "UPDATE todos
         SET title = COALESCE($1, title),
             completed = COALESCE($2, completed)
         WHERE id = $3
         RETURNING id, title, completed",
    )
    .bind(payload.title.as_deref().map(str::trim))
    .bind(payload.completed)
    .bind(id)
    .fetch_optional(&pool)
    .await
    .map_err(|_| {
        (
            axum::http::StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({
                "error": "Failed to update todo"
            })),
        )
    })?;

    match todo {
        Some(todo) => Ok(Json(todo)),
        None => Err((
            axum::http::StatusCode::NOT_FOUND,
            Json(serde_json::json!({
                "error": "Todo not found"
            })),
        )),
    }
}

async fn delete_todo(
    State(pool): State<PgPool>,
    axum::extract::Path(id): axum::extract::Path<i32>,
) -> Result<
    axum::http::StatusCode,
    (axum::http::StatusCode, Json<serde_json::Value>),
> {
    let result = sqlx::query("DELETE FROM todos WHERE id = $1")
        .bind(id)
        .execute(&pool)
        .await
        .map_err(|_| {
            (
                axum::http::StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({
                    "error": "Failed to delete todo"
                })),
            )
        })?;

    if result.rows_affected() == 0 {
        return Err((
            axum::http::StatusCode::NOT_FOUND,
            Json(serde_json::json!({
                "error": "Todo not found"
            })),
        ));
    }

    Ok(axum::http::StatusCode::NO_CONTENT)
}
