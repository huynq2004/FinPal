import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/domain/models/transaction.dart' as domain;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Khởi tạo sqflite_ffi cho test
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Transaction Duplicate Detection Tests', () {
    late DatabaseProvider dbProvider;
    late TransactionRepository repository;

    setUp(() async {
      // Tạo in-memory database cho mỗi test
      dbProvider = DatabaseProvider(testMode: true);
      repository = TransactionRepository(dbProvider);
      
      // Đợi database khởi tạo
      await dbProvider.database;
    });

    tearDown(() async {
      await dbProvider.close();
    });

    test('Giao dịch mới không trùng', () async {
      final transaction = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );

      final isDuplicate = await repository.isDuplicateTransaction(
        amount: transaction.amount,
        time: transaction.createdAt,
        bank: transaction.bank,
        content: transaction.note,
      );

      expect(isDuplicate, false);
    });

    test('Giao dịch trùng hoàn toàn', () async {
      // Insert giao dịch đầu tiên
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra giao dịch trùng
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'VCB',
        content: 'GRAB',
      );

      expect(isDuplicate, true);
    });

    test('Giao dịch trùng trong khoảng ±1 phút (30 giây)', () async {
      // Insert giao dịch tại 10:30:00
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30, 0),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra tại 10:30:30 (30 giây sau)
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30, 30),
        bank: 'VCB',
        content: 'GRAB',
      );

      expect(isDuplicate, true);
    });

    test('Giao dịch trùng trong khoảng ±1 phút (59 giây)', () async {
      // Insert giao dịch tại 10:30:00
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30, 0),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra tại 10:30:59 (59 giây sau)
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30, 59),
        bank: 'VCB',
        content: 'GRAB',
      );

      expect(isDuplicate, true);
    });

    test('Giao dịch không trùng khi cách nhau > 1 phút', () async {
      // Insert giao dịch tại 10:30
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra tại 10:32 (2 phút sau)
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 32),
        bank: 'VCB',
        content: 'GRAB',
      );

      expect(isDuplicate, false);
    });

    test('Giao dịch không trùng khi khác số tiền', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với số tiền khác
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 60000, // Khác số tiền
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'VCB',
        content: 'GRAB',
      );

      expect(isDuplicate, false);
    });

    test('Giao dịch không trùng khi khác bank', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với bank khác
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'TECHCOMBANK', // Khác bank
        content: 'GRAB',
      );

      expect(isDuplicate, false);
    });

    test('Giao dịch không trùng khi khác content', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với content khác
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'VCB',
        content: 'SHOPEE', // Khác content
      );

      expect(isDuplicate, false);
    });

    test('Giao dịch trùng với bank case-insensitive', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với bank khác case
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'vcb', // Lowercase
        content: 'GRAB',
      );

      expect(isDuplicate, true);
    });

    test('Giao dịch trùng với content case-insensitive', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với content khác case
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'VCB',
        content: 'grab', // Lowercase
      );

      expect(isDuplicate, true);
    });

    test('Bỏ qua bank nếu một trong hai null', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với bank = null
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: null, // Bank null → bỏ qua điều kiện bank
        content: 'GRAB',
      );

      expect(isDuplicate, true);
    });

    test('Bỏ qua content nếu một trong hai null', () async {
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Kiểm tra với content = null
      final isDuplicate = await repository.isDuplicateTransaction(
        amount: 50000,
        time: DateTime(2025, 1, 1, 10, 30),
        bank: 'VCB',
        content: null, // Content null → bỏ qua điều kiện content
      );

      expect(isDuplicate, true);
    });

    test('insertTransactionIfNotDuplicate - insert thành công khi không trùng', () async {
      final transaction = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );

      final result = await repository.insertTransactionIfNotDuplicate(transaction);

      expect(result, isNotNull);
      expect(result!.id, isNotNull);
      expect(result.amount, 50000);
    });

    test('insertTransactionIfNotDuplicate - trả về null khi trùng', () async {
      // Insert giao dịch đầu tiên
      final transaction1 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30),
        note: 'GRAB',
        source: 'sms',
      );
      await repository.insertTransaction(transaction1);

      // Thử insert giao dịch trùng
      final transaction2 = domain.Transaction(
        amount: 50000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime(2025, 1, 1, 10, 30, 30), // 30 giây sau
        note: 'GRAB',
        source: 'sms',
      );

      final result = await repository.insertTransactionIfNotDuplicate(transaction2);

      expect(result, isNull); // Trả về null vì trùng
    });

    test('Nhiều giao dịch khác nhau không bị phát hiện trùng', () async {
      // Insert nhiều giao dịch khác nhau
      final transactions = [
        domain.Transaction(
          amount: 50000,
          type: 'expense',
          categoryId: 1,
          categoryName: 'Di chuyển',
          bank: 'VCB',
          createdAt: DateTime(2025, 1, 1, 10, 30),
          note: 'GRAB',
          source: 'sms',
        ),
        domain.Transaction(
          amount: 100000,
          type: 'expense',
          categoryId: 2,
          categoryName: 'Mua sắm',
          bank: 'TECHCOMBANK',
          createdAt: DateTime(2025, 1, 1, 14, 20),
          note: 'SHOPEE',
          source: 'sms',
        ),
        domain.Transaction(
          amount: 75000,
          type: 'expense',
          categoryId: 3,
          categoryName: 'Ăn uống',
          bank: 'MB',
          createdAt: DateTime(2025, 1, 1, 16, 45),
          note: 'HIGHLANDS',
          source: 'sms',
        ),
      ];

      for (final tx in transactions) {
        await repository.insertTransaction(tx);
      }

      // Tất cả đều không bị phát hiện trùng khi insert lại với thời gian khác
      for (final tx in transactions) {
        final isDuplicate = await repository.isDuplicateTransaction(
          amount: tx.amount,
          time: tx.createdAt.add(const Duration(minutes: 5)), // 5 phút sau
          bank: tx.bank,
          content: tx.note,
        );
        expect(isDuplicate, false);
      }
    });
  });
}
