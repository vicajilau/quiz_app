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

import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/data/services/ai/ai_document_chunking_service.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';

class MockAppLocalizations implements AppLocalizations {
  @override
  String get aiErrorResponse => 'AI Error Response';
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'Chunking service slices string locally and creates references without Gemini',
    () async {
      final localizations = MockAppLocalizations();

      // Creates a dummy text of 10000 characters
      final String longText = List.generate(1000, (i) => '1234567890').join('');
      expect(longText.length, 10000);

      final refs = await AiDocumentChunkingService.instance.chunkDocument(
        longText,
        'doc1',
        localizations,
      );

      // It chunks about 3000 chars per batch, so 10000 / 3000 ~ 4 chunks expected
      expect(refs.isNotEmpty, isTrue);
      expect(refs.length, 4);
      expect(refs.first.startOffset, 0);
      expect(refs.last.endOffset, 10000);
      expect(refs.first.blockType, contains('Section'));
    },
  );
}
