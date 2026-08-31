import 'dart:convert';
import 'dart:typed_data';

const ansiSecurityFixtures = <String>[
  'plain\u0000text\u0007',
  '\u001b[31mred\u001b[0m',
  '\u001b]0;forged title\u0007visible',
  '\u001b]8;;https://example.invalid\u001b\\link\u001b]8;;\u001b\\',
  '\u001b[2J\u001b[Hcursor text',
  '\u001b[999999999999999999999moversized',
  '\u001b[31unterminated',
  '\u009b31mC1 sequence',
];

const unifiedDiffFixture = '''diff --git a/lib/example.dart b/lib/example.dart
index 1111111..2222222 100644
--- a/lib/example.dart
+++ b/lib/example.dart
@@ -1,3 +1,4 @@ class Example {
 context
-old value
+new value
+extra value
\\ No newline at end of file
''';

const malformedDiffFixtures = <String>[
  '',
  '@@ not a hunk @@\n+text',
  '--- /dev/null\n+++ b/new.txt\n@@ -0,0 +1 @@\n+created',
  'diff --git malformed\nBinary files a/x and b/x differ',
  '@@ -999999999999999999 +1 @@\n context',
  'diff --git a/a b/a\r--- a/a\r+++ b/a\r@@ -1 +1 @@\r-a\r+b',
];

Uint8List fixturePng() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

Uint8List fixtureGif() =>
    base64Decode('R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==');

Uint8List fixtureAnimatedGif() {
  final single = fixtureGif();
  return Uint8List.fromList(<int>[
    ...single.sublist(0, 33),
    ...single.sublist(19, 33),
    0x3b,
  ]);
}

Uint8List fixtureWebp() => base64Decode(
  'UklGRkoAAABXRUJQVlA4ID4AAADQAwCdASoBAAEAAUAmJQBOgCHwAP7uAAA=',
);

Uint8List fixtureJpeg() => base64Decode(
  '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAX/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAF//8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABBQJ//8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAgBAwEBPwF//8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAgBAgEBPwF//8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQAGPwJ//8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPyF//9oADAMBAAIAAwAAABD/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oACAEDAQE/EB//xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oACAECAQE/EB//xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oACAEBAAE/EB//2Q==',
);

Uint8List pngHeaderWithDimensions(int width, int height) {
  final bytes = Uint8List(24);
  bytes.setAll(0, const <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  bytes.setAll(12, const <int>[0x49, 0x48, 0x44, 0x52]);
  writeBigEndian32(bytes, 16, width);
  writeBigEndian32(bytes, 20, height);
  return bytes;
}

void writeBigEndian32(Uint8List bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}
