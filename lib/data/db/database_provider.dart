import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _database;

  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finpal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
        await seedCategories(db);
      },
    );
  }

  Future<void> createTables(Database db) async {
    // TODO: Add CREATE TABLE queries here
    // await db.execute('CREATE TABLE ...');
    // Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER,
        bank TEXT,
        raw_content TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    // Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT
      )
    ''');

    // Budgets
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        limit_amount INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    // Saving Goals
    await db.execute('''
      CREATE TABLE saving_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount INTEGER NOT NULL,
        current_saved INTEGER NOT NULL,
        deadline TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // =========================
  // SEED DEFAULT CATEGORIES
  // =========================
  Future<void> seedCategories(Database db) async {
    final defaultCategories = [
      {
        'name': 'Ăn uống',
        'type': 'expense',
        'icon': 'restaurant',
        'color': '#FF7043',
      },
      {
        'name': 'Di chuyển',
        'type': 'expense',
        'icon': 'directions_car',
        'color': '#42A5F5',
      },
      {
        'name': 'Mua sắm',
        'type': 'expense',
        'icon': 'shopping_cart',
        'color': '#AB47BC',
      },
      {
        'name': 'Hóa đơn',
        'type': 'expense',
        'icon': 'receipt_long',
        'color': '#26A69A',
      },
      {
        'name': 'Thu nhập',
        'type': 'income',
        'icon': 'attach_money',
        'color': '#66BB6A',
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }
}
