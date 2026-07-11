// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/core/extensions/string_extension.dart';

void main() {
  group('StringExtension.repairJsonBrackets', () {
    test('does not modify already valid JSON lists', () {
      const validJson =
          '[{"text": "Hello", "options": ["A", "B"], "correctAnswers": [0]}]';
      expect(validJson.repairJsonBrackets(), equals(validJson));
      expect(jsonDecode(validJson.repairJsonBrackets()), isList);
    });

    test('does not modify already valid JSON objects', () {
      const validJson = '{"questions": [{"text": "Hello"}]}';
      expect(validJson.repairJsonBrackets(), equals(validJson));
      expect(jsonDecode(validJson.repairJsonBrackets()), isMap);
    });

    test('repairs truncated JSON lists ending inside properties', () {
      const truncated =
          '[{"text": "Hello", "options": ["A", "B"], "correctAnswers": [0]';
      final repaired = truncated.repairJsonBrackets();
      expect(repaired, endsWith('}]'));
      final decoded = jsonDecode(repaired) as List;
      expect(decoded.length, 1);
      expect(decoded.first['text'], 'Hello');
    });

    test('repairs truncated JSON lists ending inside string literals', () {
      const truncated = '[{"text": "Hello", "explanation": "This is a tr';
      final repaired = truncated.repairJsonBrackets();
      expect(repaired, endsWith('"}]'));
      final decoded = jsonDecode(repaired) as List;
      expect(decoded.length, 1);
      expect(decoded.first['explanation'], 'This is a tr');
    });

    test('repairs truncated JSON objects with list fields', () {
      const truncated = '{"questions": [{"text": "Hello"';
      final repaired = truncated.repairJsonBrackets();
      expect(repaired, endsWith('}]}'));
      final decoded = jsonDecode(repaired) as Map;
      expect(decoded['questions'], isList);
      expect((decoded['questions'] as List).first['text'], 'Hello');
    });

    test(
      'ignores bracket/brace characters inside valid closed string literals',
      () {
        const truncated =
            '[{"text": "Ignore [brackets] and {braces} inside", "explanation": "Truncated here';
        final repaired = truncated.repairJsonBrackets();
        expect(repaired, endsWith('"}]'));
        final decoded = jsonDecode(repaired) as List;
        expect(decoded.first['text'], 'Ignore [brackets] and {braces} inside');
        expect(decoded.first['explanation'], 'Truncated here');
      },
    );

    test('ignores escaped quotes inside string literals', () {
      const truncated =
          r'[{"text": "He said \"Hello\" inside", "explanation": "Truncated';
      final repaired = truncated.repairJsonBrackets();
      expect(repaired, endsWith('"}]'));
      final decoded = jsonDecode(repaired) as List;
      expect(decoded.first['text'], 'He said "Hello" inside');
      expect(decoded.first['explanation'], 'Truncated');
    });
  });
}
