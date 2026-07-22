import 'package:flutter_test/flutter_test.dart';
import 'package:apotek_digital_pos/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApotekDigitalPosApp());
  });
}
