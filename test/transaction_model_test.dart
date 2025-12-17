import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/domain/models/transaction.dart';

void main() {
  test('Transaction.fromMap parses ISO string date', () {
    final map = {
      'amount': 1000,
      'type': 'income',
      'category': 'Test',
      'created_at': '2025-12-16T10:00:00.000Z',
      'source': 'test',
    };

    final tx = Transaction.fromMap(map);
    expect(tx.createdAt.toUtc().year, 2025);
    expect(tx.createdAt.toUtc().hour, 10);
  });

  test('Transaction.fromMap parses integer milliseconds', () {
    final millis = DateTime(2025, 12, 16, 11, 0).millisecondsSinceEpoch;
    final map = {
      'amount': 2000,
      'type': 'expense',
      'category': 'Test',
      'created_at': millis,
      'source': 'test',
    };

    final tx = Transaction.fromMap(map);
    expect(tx.createdAt.year, 2025);
    expect(tx.createdAt.hour, 11);
  });

  test('Transaction.fromMap handles DateTime directly', () {
    final dt = DateTime(2025, 12, 16, 12, 0);
    final map = {
      'amount': 3000,
      'type': 'income',
      'category': 'Test',
      'created_at': dt,
      'source': 'test',
    };

    final tx = Transaction.fromMap(map);
    expect(tx.createdAt, dt);
  });
}
