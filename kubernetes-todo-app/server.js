const express = require("express");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || "/data";
const DATA_FILE = path.join(DATA_DIR, "todos.json");

app.use(express.json());

// Ensure the storage directory exists
fs.mkdirSync(DATA_DIR, { recursive: true });

// Read existing Todo items
function readTodos() {
    try {
        if (!fs.existsSync(DATA_FILE)) {
            return [];
        }

        return JSON.parse(fs.readFileSync(DATA_FILE, "utf8"));
    } catch (error) {
        console.error("Error reading Todo data:", error);
        return [];
    }
}

// Save Todo items
function saveTodos(todos) {
    fs.writeFileSync(DATA_FILE, JSON.stringify(todos, null, 2));
}

// Application home route
app.get("/", (req, res) => {
    res.json({
        message: "Kubernetes Todo API is running!",
        version: "1.0.0"
    });
});

// Health check
app.get("/health", (req, res) => {
    res.json({ status: "healthy" });
});

// Retrieve all Todo items
app.get("/todos", (req, res) => {
    res.json(readTodos());
});

// Create a Todo item
app.post("/todos", (req, res) => {
    const { title } = req.body;

    if (!title || typeof title !== "string" || !title.trim()) {
        return res.status(400).json({
            error: "A valid Todo title is required"
        });
    }

    const todos = readTodos();

    const newTodo = {
        id: Date.now(),
        title: title.trim(),
        completed: false
    };

    todos.push(newTodo);
    saveTodos(todos);

    res.status(201).json(newTodo);
});

// Start the server
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Todo API listening on port ${PORT}`);
});
