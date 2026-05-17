import 'package:flutter_test/flutter_test.dart';
import 'package:pakeeza_pos/core/constants/app_constants.dart';

void main() {
  test('app name is set', () {
    expect(AppConstants.appName, 'Pakeeza POS');
  });
}
