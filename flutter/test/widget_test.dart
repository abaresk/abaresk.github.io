import 'package:flutter_test/flutter_test.dart';
import 'package:abaresk_blog/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BlogApp());
    await tester.pump();
  });
}
