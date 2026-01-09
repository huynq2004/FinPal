import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/domain/models/transaction.dart' as fp;

void main() {
  // Enable sqflite on desktop/VM for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Insert manual transaction persists to DB', () async {
    // Use in-memory database for isolated test
    final dbProvider = DatabaseProvider(testMode: true);
    final repo = TransactionRepository(dbProvider);

    // Ensure DB/tables exist
    await dbProvider.database;

    final before = await repo.getAllTransactions();

    final now = DateTime.now();
    final tx = fp.Transaction(
      amount: 123456,
      type: 'expense',
      categoryId: null,
      categoryName: 'Khác',
      bank: 'Tiền mặt',
      createdAt: now,
      note: 'Test manual insert',
      source: 'manual',
    );

    final inserted = await repo.insertTransaction(tx);

    expect(inserted.id, isNotNull, reason: 'Auto-increment id must be set');

    final after = await repo.getAllTransactions();
    expect(
      after.length,
      before.length + 1,
      reason: 'Row count should increase by 1',
    );

    final fetched = await repo.getTransactionById(inserted.id!);
    expect(fetched, isNotNull);
    expect(fetched!.amount, 123456);
    expect(fetched.type, 'expense');
    expect(fetched.source, 'manual');
    expect(fetched.note, 'Test manual insert');
  });
}
