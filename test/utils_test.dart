import 'package:app_router/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('joinPaths', () {
    void verify(String pathA, String pathB, String expected) {
      final String result = PathUtils.joinPaths(pathA, pathB);
      expect(result, expected);
    }

    void verifyThrows(String pathA, String pathB) {
      expect(
        () => PathUtils.joinPaths(pathA, pathB),
        throwsA(isA<AssertionError>()),
      );
    }

    verify('/a', 'b/c', '/a/b/c');
    verify('/', 'b', '/b');
    verifyThrows('/a', '/b');
    verifyThrows('/a', '/');
    verifyThrows('/', '/');
    verifyThrows('/', '');
    verifyThrows('', '');
  });
}
