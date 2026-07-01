import 'package:flutter/foundation.dart';

import '../../domain/repositories/work_item_repository.dart';
import '../repositories/work_item_repository_drift.dart';
import 'database.dart';

/// Acesso lazy ao banco local / [WorkItemRepository]. Sem web/WASM nesta
/// fase (ver `AppDatabase`) — em `kIsWeb`, `repository` é `null` e chamadas
/// de shadow-write viram no-op, sem quebrar a build web.
class DatabaseProvider {
  DatabaseProvider._();

  static AppDatabase? _database;
  static WorkItemRepository? _repository;

  static WorkItemRepository? get repository {
    if (kIsWeb) return null;
    _database ??= AppDatabase();
    return _repository ??= WorkItemRepositoryDrift(_database!);
  }
}
