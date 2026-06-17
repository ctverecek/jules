import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NeoSnakeApp());
}

class NeoSnakeApp extends StatelessWidget {
  const NeoSnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neo Brutal Snake',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F07A), // Bright yellow
        fontFamily: 'Courier', // Monospace for retro feel
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      home: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

class _SnakeGameState extends State<SnakeGame> {
  final int rows = 20;
  final int columns = 20;
  final int initialSpeed = 300; // ms

  List<int> snake = [45, 44, 43];
  int food = 50;
  Direction direction = Direction.right;
  bool isPlaying = false;
  bool isGameOver = false;
  Timer? timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    generateFood();
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      isGameOver = false;
      snake = [45, 44, 43];
      direction = Direction.right;
      score = 0;
      generateFood();
    });

    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: initialSpeed), (Timer t) {
      updateSnake();
    });
  }

  void stopGame() {
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    timer?.cancel();
  }

  void updateSnake() {
    setState(() {
      int head = snake.first;
      int newHead = head;

      switch (direction) {
        case Direction.up:
          newHead = head - columns;
          break;
        case Direction.down:
          newHead = head + columns;
          break;
        case Direction.left:
          if (head % columns == 0) {
            newHead = head + columns - 1; // Wrap around
          } else {
            newHead = head - 1;
          }
          break;
        case Direction.right:
          if ((head + 1) % columns == 0) {
            newHead = head - columns + 1; // Wrap around
          } else {
            newHead = head + 1;
          }
          break;
      }

      // Vertical wrap around
      if (newHead < 0) {
        newHead += rows * columns;
      } else if (newHead >= rows * columns) {
        newHead -= rows * columns;
      }

      // Check collision with self
      if (snake.contains(newHead)) {
        stopGame();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score += 10;
        generateFood();
        // Speed up slightly could be added here
      } else {
        snake.removeLast();
      }
    });
  }

  void generateFood() {
    Random random = Random();
    int newFood;
    do {
      newFood = random.nextInt(rows * columns);
    } while (snake.contains(newFood));
    setState(() {
      food = newFood;
    });
  }

  void changeDirection(Direction newDirection) {
    if (direction == Direction.up && newDirection == Direction.down) return;
    if (direction == Direction.down && newDirection == Direction.up) return;
    if (direction == Direction.left && newDirection == Direction.right) return;
    if (direction == Direction.right && newDirection == Direction.left) return;

    setState(() {
      direction = newDirection;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header / Score
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NeoBox(
                color: const Color(0xFFF9A8D4), // Pink
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SNAKE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text('SCORE: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),

            // Game Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0) {
                      changeDirection(Direction.down);
                    } else if (details.delta.dy < 0) {
                      changeDirection(Direction.up);
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0) {
                      changeDirection(Direction.right);
                    } else if (details.delta.dx < 0) {
                      changeDirection(Direction.left);
                    }
                  },
                  child: NeoBox(
                    color: const Color(0xFFA7F3D0), // Mint Green
                    padding: const EdgeInsets.all(4),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rows * columns,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                      ),
                      itemBuilder: (context, index) {
                        bool isSnake = snake.contains(index);
                        bool isHead = snake.isNotEmpty && snake.first == index;
                        bool isFood = food == index;

                        Color cellColor = Colors.transparent;
                        if (isHead) {
                          cellColor = Colors.black;
                        } else if (isSnake) {
                          cellColor = const Color(0xFF34D399); // Darker Green
                        }

                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: cellColor,
                            border: isSnake ? Border.all(color: Colors.black, width: 2) : null,
                          ),
                          child: isFood
                              ? const Icon(Icons.star, color: Color(0xFFF87171), size: 16)
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Controls & Status
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isGameOver
                  ? NeoButton(
                      text: 'GAME OVER\nTAP TO RESTART',
                      color: const Color(0xFFF87171),
                      onPressed: startGame,
                    )
                  : !isPlaying
                      ? NeoButton(
                          text: 'START GAME',
                          color: const Color(0xFF60A5FA), // Blue
                          onPressed: startGame,
                        )
                      : NeoBox(
                          color: const Color(0xFFE5E7EB), // Gray
                          child: const Center(
                            child: Text(
                              'SWIPE TO MOVE',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Neobrutalism UI Components

class NeoBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  const NeoBox({
    super.key,
    required this.child,
    required this.color,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class NeoButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const NeoButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(6, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
