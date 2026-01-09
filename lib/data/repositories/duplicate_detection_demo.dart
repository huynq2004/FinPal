import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/domain/models/transaction.dart';

/// Demo file để showcase duplicate detection functionality
void main() async {
  print('═══════════════════════════════════════════════');
  print('🔍 DEMO: Transaction Duplicate Detection');
  print('═══════════════════════════════════════════════\n');

  // Khởi tạo repository
  final dbProvider = DatabaseProvider();
  final repository = TransactionRepository(dbProvider);

  // Demo 1: Thêm giao dịch mới (không trùng)
  print('🔹 DEMO 1: Thêm giao dịch mới\n');
  
  final transaction1 = Transaction(
    amount: 50000,
    type: 'expense',
    categoryId: 1,
    categoryName: 'Di chuyển',
    bank: 'VCB',
    createdAt: DateTime(2025, 1, 7, 10, 30),
    note: 'GRAB',
    source: 'sms',
  );

  print('📥 Thêm giao dịch: ${transaction1.amount} VND - ${transaction1.note}');
  final inserted1 = await repository.insertTransactionIfNotDuplicate(transaction1);
  if (inserted1 != null) {
    print('✅ Thêm thành công! ID: ${inserted1.id}\n');
  } else {
    print('⏭️ Bỏ qua - Giao dịch đã tồn tại\n');
  }

  // Demo 2: Thử thêm giao dịch trùng (cùng thời gian)
  print('🔹 DEMO 2: Thử thêm giao dịch trùng (cùng thời gian)\n');
  
  final transaction2 = Transaction(
    amount: 50000,
    type: 'expense',
    categoryId: 1,
    categoryName: 'Di chuyển',
    bank: 'VCB',
    createdAt: DateTime(2025, 1, 7, 10, 30), // Cùng thời gian
    note: 'GRAB',
    source: 'sms',
  );

  print('📥 Thêm giao dịch: ${transaction2.amount} VND - ${transaction2.note}');
  final inserted2 = await repository.insertTransactionIfNotDuplicate(transaction2);
  if (inserted2 != null) {
    print('✅ Thêm thành công! ID: ${inserted2.id}\n');
  } else {
    print('⏭️ Bỏ qua - Giao dịch đã tồn tại\n');
  }

  // Demo 3: Thêm giao dịch trong khoảng ±1 phút
  print('🔹 DEMO 3: Thử thêm giao dịch trong khoảng ±1 phút\n');
  
  final transaction3 = Transaction(
    amount: 50000,
    type: 'expense',
    categoryId: 1,
    categoryName: 'Di chuyển',
    bank: 'VCB',
    createdAt: DateTime(2025, 1, 7, 10, 30, 45), // 45 giây sau
    note: 'GRAB',
    source: 'sms',
  );

  print('📥 Thêm giao dịch: ${transaction3.amount} VND - ${transaction3.note} (45 giây sau)');
  final inserted3 = await repository.insertTransactionIfNotDuplicate(transaction3);
  if (inserted3 != null) {
    print('✅ Thêm thành công! ID: ${inserted3.id}\n');
  } else {
    print('⏭️ Bỏ qua - Giao dịch đã tồn tại (trong khoảng ±1 phút)\n');
  }

  // Demo 4: Thêm giao dịch khác (khác số tiền)
  print('🔹 DEMO 4: Thêm giao dịch khác (khác số tiền)\n');
  
  final transaction4 = Transaction(
    amount: 100000, // Khác số tiền
    type: 'expense',
    categoryId: 2,
    categoryName: 'Mua sắm',
    bank: 'TECHCOMBANK',
    createdAt: DateTime(2025, 1, 7, 14, 20),
    note: 'SHOPEE',
    source: 'sms',
  );

  print('📥 Thêm giao dịch: ${transaction4.amount} VND - ${transaction4.note}');
  final inserted4 = await repository.insertTransactionIfNotDuplicate(transaction4);
  if (inserted4 != null) {
    print('✅ Thêm thành công! ID: ${inserted4.id}\n');
  } else {
    print('⏭️ Bỏ qua - Giao dịch đã tồn tại\n');
  }

  // Demo 5: Thêm giao dịch sau > 1 phút
  print('🔹 DEMO 5: Thêm giao dịch sau > 1 phút (cùng thông tin khác)\n');
  
  final transaction5 = Transaction(
    amount: 50000,
    type: 'expense',
    categoryId: 1,
    categoryName: 'Di chuyển',
    bank: 'VCB',
    createdAt: DateTime(2025, 1, 7, 10, 35), // 5 phút sau
    note: 'GRAB',
    source: 'sms',
  );

  print('📥 Thêm giao dịch: ${transaction5.amount} VND - ${transaction5.note} (5 phút sau)');
  final inserted5 = await repository.insertTransactionIfNotDuplicate(transaction5);
  if (inserted5 != null) {
    print('✅ Thêm thành công! ID: ${inserted5.id}\n');
  } else {
    print('⏭️ Bỏ qua - Giao dịch đã tồn tại\n');
  }

  // Hiển thị tất cả giao dịch
  print('\n═══════════════════════════════════════════════');
  print('📊 Danh sách giao dịch đã lưu:\n');
  
  final allTransactions = await repository.getAllTransactions();
  for (int i = 0; i < allTransactions.length; i++) {
    final tx = allTransactions[i];
    print('   ${i + 1}. [ID:${tx.id}] ${tx.amount} VND - ${tx.note}');
    print('      Bank: ${tx.bank}, Time: ${tx.createdAt}');
    print('      Category: ${tx.categoryName}');
    print('      ─────────────────────────────────────────');
  }

  print('\n═══════════════════════════════════════════════');
  print('✅ Demo completed!');
  print('Kết quả: ${allTransactions.length} giao dịch được lưu');
  print('Các giao dịch trùng đã được tự động bỏ qua');
  print('═══════════════════════════════════════════════\n');
}
