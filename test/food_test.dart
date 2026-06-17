import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Snake can eat food and score increases', (WidgetTester tester) async {
    await tester.pumpWidget(const NeoSnakeApp());

    // Tap Start Game
    await tester.tap(find.text('START GAME'));
    await tester.pump();

    final state = tester.state(find.byType(SnakeGame)) as dynamic;

    // Force food to be right next to the snake head
    state.setState(() {
      state.direction = Direction.right;
      state.snake = [45, 44, 43];
      state.food = 46;
      state.score = 0;
    });

    // Tick the game (simulate 1 step)
    state.updateSnake();
    await tester.pump();

    // Check if snake ate the food
    expect(state.snake.contains(46), isTrue);
    expect(state.score, 10);
    expect(state.food != 46, isTrue); // Food should have moved
  });
}
