from flask import Flask, request, jsonify
import sqlite3
import os

app = Flask(__name__)

DB_PATH = os.getenv("DB_PATH", "/data/todos.db")


def get_db():
    db_dir = os.path.dirname(DB_PATH)

    if db_dir:
        os.makedirs(db_dir, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_db()

    conn.execute("""
        CREATE TABLE IF NOT EXISTS todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0
        )
    """)

    conn.commit()
    conn.close()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/todos", methods=["GET"])
def get_todos():
    conn = get_db()
    todos = conn.execute("SELECT * FROM todos").fetchall()
    conn.close()

    return jsonify([
        {
            "id": todo["id"],
            "title": todo["title"],
            "completed": bool(todo["completed"])
        }
        for todo in todos
    ])


@app.route("/todos", methods=["POST"])
def create_todo():
    data = request.get_json(silent=True) or {}

    if not data.get("title"):
        return jsonify({"error": "title is required"}), 400

    completed = bool(data.get("completed", False))

    conn = get_db()

    cursor = conn.execute(
        "INSERT INTO todos (title, completed) VALUES (?, ?)",
        (data["title"], completed)
    )

    conn.commit()
    todo_id = cursor.lastrowid
    conn.close()

    return jsonify({
        "id": todo_id,
        "title": data["title"],
        "completed": completed
    }), 201


@app.route("/todos/<int:todo_id>", methods=["GET"])
def get_todo(todo_id):
    conn = get_db()

    todo = conn.execute(
        "SELECT * FROM todos WHERE id = ?",
        (todo_id,)
    ).fetchone()

    conn.close()

    if todo is None:
        return jsonify({"error": "todo not found"}), 404

    return jsonify({
        "id": todo["id"],
        "title": todo["title"],
        "completed": bool(todo["completed"])
    })


@app.route("/todos/<int:todo_id>", methods=["PUT"])
def update_todo(todo_id):
    data = request.get_json(silent=True) or {}

    if "title" not in data and "completed" not in data:
        return jsonify({
            "error": "title or completed is required"
        }), 400

    conn = get_db()

    todo = conn.execute(
        "SELECT * FROM todos WHERE id = ?",
        (todo_id,)
    ).fetchone()

    if todo is None:
        conn.close()
        return jsonify({"error": "todo not found"}), 404

    title = data.get("title", todo["title"])
    completed = bool(data.get("completed", bool(todo["completed"])))

    conn.execute(
        "UPDATE todos SET title = ?, completed = ? WHERE id = ?",
        (title, completed, todo_id)
    )

    conn.commit()
    conn.close()

    return jsonify({
        "id": todo_id,
        "title": title,
        "completed": completed
    })


@app.route("/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    conn = get_db()

    cursor = conn.execute(
        "DELETE FROM todos WHERE id = ?",
        (todo_id,)
    )

    conn.commit()
    conn.close()

    if cursor.rowcount == 0:
        return jsonify({"error": "todo not found"}), 404

    return jsonify({"message": "todo deleted"})


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=3000)
