import 'package:flutter_test/flutter_test.dart';
import 'package:geo_tag_camera/app/app.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MunicipalApp(cameras: []));
    expect(find.byType(MunicipalApp), findsOneWidget);
  });
}
