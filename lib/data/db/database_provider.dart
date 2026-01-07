import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _database;
  final bool testMode;

  DatabaseProvider._init({this.testMode = false});
  
  /// Constructor cho test với in-memory database
  factory DatabaseProvider({bool testMode = false}) {
    if (testMode) {
      return DatabaseProvider._init(testMode: true);
    }
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    if (testMode) {
      // Sử dụng in-memory database cho test
      return await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          await createTables(db);
          await seedCategories(db);
        },
      );
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finpal.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await createTables(db);
        await seedCategories(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migrate từ version 1 → 2
        if (oldVersion < 2) {
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_categories_name_type ON categories(name, type)',
          );
        }

        // Migrate từ version 2 → 3 (hoặc từ 1 → 3)
        if (oldVersion < 3) {
          // Xóa bảng cũ nếu có
          await db.execute('DROP TABLE IF EXISTS saving_history');

          // Tạo lại bảng với schema mới
          await db.execute('''
            CREATE TABLE saving_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              goal_id INTEGER NOT NULL,
              amount INTEGER NOT NULL,
              type TEXT NOT NULL,
              note TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY (goal_id) REFERENCES saving_goals (id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }
  
  /// Đóng database (dùng cho test)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
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
        color TEXT,
        UNIQUE(name, type)
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

    // Saving History (tracking khi thêm/rút tiền từ hũ)
    await db.execute('''
      CREATE TABLE saving_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES saving_goals (id) ON DELETE CASCADE
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
      await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
