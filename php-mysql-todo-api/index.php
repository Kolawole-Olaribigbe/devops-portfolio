<?php

header('Content-Type: application/json');

$dbHost = getenv('DB_HOST') ?: 'mysql';
$dbName = getenv('DB_NAME') ?: 'todos';
$dbUser = getenv('DB_USER') ?: 'todo_user';
$dbPass = getenv('DB_PASSWORD') ?: 'todo_password';

try {
    $pdo = new PDO(
        "mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4",
        $dbUser,
        $dbPass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS todos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            completed BOOLEAN NOT NULL DEFAULT FALSE
        )
    ");

    $method = $_SERVER['REQUEST_METHOD'];
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

    if ($method === 'GET' && $path === '/todos') {
        $stmt = $pdo->query("SELECT id, title, completed FROM todos ORDER BY id");
        $todos = $stmt->fetchAll();

        echo json_encode($todos);
        exit;
    }

    if ($method === 'POST' && $path === '/todos') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (!isset($data['title']) || trim($data['title']) === '') {
        http_response_code(400);

        echo json_encode([
            'error' => 'Title is required'
        ]);
        exit;
    }

    $title = trim($data['title']);

    $stmt = $pdo->prepare(
        "INSERT INTO todos (title) VALUES (:title)"
    );

    $stmt->execute([
        'title' => $title
    ]);

    http_response_code(201);

    echo json_encode([
        'id' => $pdo->lastInsertId(),
        'title' => $title,
        'completed' => false
    ]);

    exit;
    }

    if ($method === 'PUT' && preg_match('#^/todos/([0-9]+)$#', $path, $matches)) {
    $id = $matches[1];

    $data = json_decode(file_get_contents('php://input'), true);

    if (!is_array($data)) {
        http_response_code(400);

        echo json_encode([
            'error' => 'Invalid JSON'
        ]);
        exit;
    }

    $fields = [];
    $params = ['id' => $id];

    if (isset($data['title'])) {
        if (trim($data['title']) === '') {
            http_response_code(400);

            echo json_encode([
                'error' => 'Title cannot be empty'
            ]);
            exit;
        }

        $fields[] = 'title = :title';
        $params['title'] = trim($data['title']);
    }

    if (isset($data['completed'])) {
        if (!is_bool($data['completed'])) {
            http_response_code(400);

            echo json_encode([
                'error' => 'Completed must be true or false'
            ]);
            exit;
        }

        $fields[] = 'completed = :completed';
        $params['completed'] = $data['completed'];
    }

    if (empty($fields)) {
        http_response_code(400);

        echo json_encode([
            'error' => 'Nothing to update'
        ]);
        exit;
    }

    $stmt = $pdo->prepare(
        "UPDATE todos SET " . implode(', ', $fields) . " WHERE id = :id"
    );

    $stmt->execute($params);

    if ($stmt->rowCount() === 0) {
        $check = $pdo->prepare("SELECT id FROM todos WHERE id = :id");
        $check->execute(['id' => $id]);

        if (!$check->fetch()) {
            http_response_code(404);

            echo json_encode([
                'error' => 'Todo not found'
            ]);
            exit;
        }
    }

    $stmt = $pdo->prepare(
        "SELECT id, title, completed FROM todos WHERE id = :id"
    );

    $stmt->execute(['id' => $id]);

    echo json_encode($stmt->fetch());
    exit;
    }

    if ($method === 'DELETE' && preg_match('#^/todos/([0-9]+)$#', $path, $matches)) {
    $id = $matches[1];

    $stmt = $pdo->prepare("DELETE FROM todos WHERE id = :id");
    $stmt->execute([
        'id' => $id
    ]);

    if ($stmt->rowCount() === 0) {
        http_response_code(404);

        echo json_encode([
            'error' => 'Todo not found'
        ]);
        exit;
    }

    echo json_encode([
        'message' => 'Todo deleted successfully'
    ]);

    exit;
    }

    if ($method === 'GET' && preg_match('#^/todos/([0-9]+)$#', $path, $matches)) {
    $id = $matches[1];

    $stmt = $pdo->prepare(
        "SELECT id, title, completed FROM todos WHERE id = :id"
    );

    $stmt->execute([
        'id' => $id
    ]);

    $todo = $stmt->fetch();

    if (!$todo) {
        http_response_code(404);

        echo json_encode([
            'error' => 'Todo not found'
        ]);
        exit;
    }

    echo json_encode($todo);
    exit;
}


    echo json_encode([
        'message' => 'Todo API is running'
    ]);

} catch (PDOException $e) {
    http_response_code(500);

    echo json_encode([
        'error' => 'Database connection failed'
    ]);
}
