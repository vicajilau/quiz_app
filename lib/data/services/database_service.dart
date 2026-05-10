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

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';

/// Service responsible for initializing the local database and registering adapters.
class DatabaseService {
  /// Initializes the database.
  /// 
  /// If [path] is provided, it initializes the database at that specific path
  /// (useful for testing). Otherwise, it uses the default application directory.
  static Future<void> init({String? path}) async {
    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }
    
    // Register all custom adapters
    Hive.registerAdapter(SrsMetadataAdapter());
  }
}
