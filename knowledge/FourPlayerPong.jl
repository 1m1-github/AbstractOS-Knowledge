task_name = :four_player_pong

# 4-Player Pong Game: A square arena with paddles on all four sides.
# Players control paddles: Top (A/D), Bottom (Left/Right arrows), Left (W/S), Right (Up/Down arrows).
# Ball bounces off paddles and walls; score when ball hits a side without a paddle.
# Served as an interactive HTML page with Canvas and JavaScript.

html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>4-Player Pong</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #000;
            color: #fff;
            text-align: center;
            margin: 0;
            padding: 20px;
        }
        canvas {
            border: 2px solid #fff;
            background-color: #000;
        }
        #score {
            font-size: 24px;
            margin-bottom: 20px;
        }
        #controls {
            font-size: 16px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h1>4-Player Pong</h1>
    <div id="score">Top: 0 | Bottom: 0 | Left: 0 | Right: 0</div>
    <canvas id="pongCanvas" width="600" height="600"></canvas>
    <div id="controls">
        <p>Top Player: A/D to move left/right</p>
        <p>Bottom Player: Left/Right arrows to move left/right</p>
        <p>Left Player: W/S to move up/down</p>
        <p>Right Player: Up/Down arrows to move up/down</p>
        <p>Press Space to start/reset</p>
    </div>

    <script>
        const canvas = document.getElementById('pongCanvas');
        const ctx = canvas.getContext('2d');
        const scoreDisplay = document.getElementById('score');

        // Game variables
        let ball = { x: 300, y: 300, dx: 3, dy: 3, radius: 10 };
        let paddles = {
            top: { x: 250, y: 0, width: 100, height: 10, score: 0 },
            bottom: { x: 250, y: 590, width: 100, height: 10, score: 0 },
            left: { x: 0, y: 250, width: 10, height: 100, score: 0 },
            right: { x: 590, y: 250, width: 10, height: 100, score: 0 }
        };
        let keys = {};
        let gameRunning = false;

        // Event listeners
        document.addEventListener('keydown', (e) => {
            keys[e.key] = true;
            if (e.key === ' ') {
                gameRunning = !gameRunning;
                if (!gameRunning) resetBall();
            }
        });
        document.addEventListener('keyup', (e) => {
            keys[e.key] = false;
        });

        function update() {
            if (!gameRunning) return;

            // Move paddles
            if (keys['a'] && paddles.top.x > 0) paddles.top.x -= 5;
            if (keys['d'] && paddles.top.x < 500) paddles.top.x += 5;
            if (keys['ArrowLeft'] && paddles.bottom.x > 0) paddles.bottom.x -= 5;
            if (keys['ArrowRight'] && paddles.bottom.x < 500) paddles.bottom.x += 5;
            if (keys['w'] && paddles.left.y > 0) paddles.left.y -= 5;
            if (keys['s'] && paddles.left.y < 500) paddles.left.y += 5;
            if (keys['ArrowUp'] && paddles.right.y > 0) paddles.right.y -= 5;
            if (keys['ArrowDown'] && paddles.right.y < 500) paddles.right.y += 5;

            // Move ball
            ball.x += ball.dx;
            ball.y += ball.dy;

            // Ball collisions with paddles
            if (ball.y - ball.radius <= paddles.top.y + paddles.top.height &&
                ball.x >= paddles.top.x && ball.x <= paddles.top.x + paddles.top.width &&
                ball.dy < 0) {
                ball.dy = -ball.dy;
            }
            if (ball.y + ball.radius >= paddles.bottom.y &&
                ball.x >= paddles.bottom.x && ball.x <= paddles.bottom.x + paddles.bottom.width &&
                ball.dy > 0) {
                ball.dy = -ball.dy;
            }
            if (ball.x - ball.radius <= paddles.left.x + paddles.left.width &&
                ball.y >= paddles.left.y && ball.y <= paddles.left.y + paddles.left.height &&
                ball.dx < 0) {
                ball.dx = -ball.dx;
            }
            if (ball.x + ball.radius >= paddles.right.x &&
                ball.y >= paddles.right.y && ball.y <= paddles.right.y + paddles.right.height &&
                ball.dx > 0) {
                ball.dx = -ball.dx;
            }

            // Ball hits walls (score)
            if (ball.y - ball.radius <= 0) {
                paddles.top.score++;
                resetBall();
            }
            if (ball.y + ball.radius >= 600) {
                paddles.bottom.score++;
                resetBall();
            }
            if (ball.x - ball.radius <= 0) {
                paddles.left.score++;
                resetBall();
            }
            if (ball.x + ball.radius >= 600) {
                paddles.right.score++;
                resetBall();
            }

            updateScore();
        }

        function resetBall() {
            ball.x = 300;
            ball.y = 300;
            ball.dx = (Math.random() > 0.5 ? 1 : -1) * 3;
            ball.dy = (Math.random() > 0.5 ? 1 : -1) * 3;
        }

        function updateScore() {
            scoreDisplay.textContent = `Top: \${paddles.top.score} | Bottom: \${paddles.bottom.score} | Left: \${paddles.left.score} | Right: \${paddles.right.score}`;
        }

        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Draw paddles
            ctx.fillStyle = '#fff';
            ctx.fillRect(paddles.top.x, paddles.top.y, paddles.top.width, paddles.top.height);
            ctx.fillRect(paddles.bottom.x, paddles.bottom.y, paddles.bottom.width, paddles.bottom.height);
            ctx.fillRect(paddles.left.x, paddles.left.y, paddles.left.width, paddles.left.height);
            ctx.fillRect(paddles.right.x, paddles.right.y, paddles.right.width, paddles.right.height);

            // Draw ball
            ctx.beginPath();
            ctx.arc(ball.x, ball.y, ball.radius, 0, Math.PI * 2);
            ctx.fill();
        }

        function gameLoop() {
            update();
            draw();
            requestAnimationFrame(gameLoop);
        }

        gameLoop();
    </script>
</body>
</html>
"""

put!(output_devices[:MultiPathBrowserOutput], "/pong-game", html_content)
