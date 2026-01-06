# 🏦 Savings Module - Backend Documentation

## 📌 Tổng quan

Module quản lý **hũ tiết kiệm** (Saving Goals) cho ứng dụng FinPal, bao gồm CRUD operations, tracking lịch sử, và business logic.

---

## 📂 Cấu trúc Files

```
lib/
├── domain/models/
│   ├── saving_goal.dart          # Model chính cho Savings Goal
│   └── saving_history.dart       # Model cho lịch sử giao dịch
├── data/
│   ├── db/
│   │   └── database_provider.dart # SQLite setup (bảng saving_goals, saving_history)
│   └── repositories/
│       └── saving_goal_repository.dart # Backend logic chính
test/
└── saving_goal_repository_test.dart   # Unit tests (9 test groups)
```

---

## 🗄️ Database Schema

### Table: `saving_goals`

| Column        | Type    | Description                |
| ------------- | ------- | -------------------------- |
| id            | INTEGER | Primary Key (Auto)         |
| name          | TEXT    | Tên hũ tiết kiệm           |
| target_amount | INTEGER | Số tiền mục tiêu (VND)     |
| current_saved | INTEGER | Số tiền đã tiết kiệm (VND) |
| deadline      | TEXT    | Hạn đạt mục tiêu (ISO8601) |
| created_at    | TEXT    | Ngày tạo (ISO8601)         |

### Table: `saving_history`

| Column     | Type    | Description                   |
| ---------- | ------- | ----------------------------- |
| id         | INTEGER | Primary Key (Auto)            |
| goal_id    | INTEGER | Foreign Key → saving_goals.id |
| amount     | INTEGER | Số tiền (+ thêm / - rút)      |
| type       | TEXT    | 'add' hoặc 'withdraw'         |
| note       | TEXT    | Ghi chú (nullable)            |
| created_at | TEXT    | Thời gian giao dịch (ISO8601) |

---

## 🚀 API Methods

### **CRUD Operations**

#### 1. `createGoal(SavingGoal goal) → Future<int>`

Tạo mới saving goal.

```dart
final goalId = await repository.createGoal(SavingGoal(
  name: 'Mua laptop',
  targetAmount: 20000000,
  currentSaved: 0,
  deadline: DateTime.now().add(Duration(days: 180)),
  createdAt: DateTime.now(),
));
```

#### 2. `updateGoal(SavingGoal goal) → Future<int>`

Cập nhật thông tin goal (tên, target, deadline).

```dart
final updatedGoal = existingGoal.copyWith(
  name: 'Laptop Gaming',
  targetAmount: 25000000,
);
await repository.updateGoal(updatedGoal);
```

#### 3. `getGoalById(int id) → Future<SavingGoal?>`

Lấy goal theo ID, trả về `null` nếu không tồn tại.

```dart
final goal = await repository.getGoalById(1);
if (goal != null) {
  print('Progress: ${repository.getProgressPercentage(goal)}%');
}
```

#### 4. `getAllGoals() → Future<List<SavingGoal>>`

Lấy tất cả goals.

```dart
final allGoals = await repository.getAllGoals();
```

#### 5. `deleteGoal(int id) → Future<int>`

Xóa goal (CASCADE sẽ xóa cả history).

```dart
await repository.deleteGoal(goalId);
```

---

### **Savings Management**

#### 6. `addSavingsToGoal(int goalId, int amount) → Future<int>`

Thêm tiền vào hũ + tự động tạo history.

```dart
await repository.addSavingsToGoal(1, 500000); // Thêm 500k vào goal #1
```

#### 7. `withdrawFromGoal(int goalId, int amount, {String? note}) → Future<int>`

Rút tiền từ hũ (kiểm tra số dư).

```dart
await repository.withdrawFromGoal(1, 200000, note: 'Emergency expense');
```

**Exception:** Ném `Exception` nếu số dư không đủ.

---

### **Business Logic**

#### 8. `getGoalsByProgress() → Future<List<SavingGoal>>`

Lấy danh sách goals **sắp xếp theo % hoàn thành** (cao → thấp).

```dart
final sortedGoals = await repository.getGoalsByProgress();
// sortedGoals[0] = goal có % cao nhất
```

#### 9. `getGoalsNearDeadline(int daysThreshold) → Future<List<SavingGoal>>`

Lấy goals **sắp hết hạn** trong N ngày tới (chưa hoàn thành).

```dart
final urgentGoals = await repository.getGoalsNearDeadline(7);
// Goals hết hạn trong 7 ngày tới
```

#### 10. `getProgressPercentage(SavingGoal goal) → double`

Tính % hoàn thành (0-100).

```dart
final progress = repository.getProgressPercentage(goal);
// 75.5 (nếu 7.5M/10M)
```

---

### **History Tracking**

#### 11. `getHistoryByGoalId(int goalId) → Future<List<SavingHistory>>`

Lấy lịch sử giao dịch của goal (sorted theo thời gian mới nhất).

```dart
final history = await repository.getHistoryByGoalId(1);
for (var record in history) {
  print('${record.type}: ${record.amount} VND - ${record.note}');
}
```

#### 12. `deleteHistoryByGoalId(int goalId) → Future<int>`

Xóa tất cả history của goal.

```dart
await repository.deleteHistoryByGoalId(1);
```

---

## 🧪 Testing

### Run All Tests

```bash
flutter test test/saving_goal_repository_test.dart
```

### Test Coverage

- ✅ CRUD operations (create, update, delete, get)
- ✅ Savings management (add, withdraw, validation)
- ✅ Business logic (progress sorting, deadline alerts)
- ✅ History tracking (create, retrieve, delete)
- ✅ Edge cases (null handling, insufficient funds, zero target)

**Total Tests:** 15 test cases across 3 groups.

---

## 📊 Usage Example

```dart
// 1. Tạo goal mới
final repo = SavingGoalRepository();
final goalId = await repo.createGoal(SavingGoal(
  name: 'Du lịch Nhật Bản',
  targetAmount: 30000000,
  currentSaved: 0,
  deadline: DateTime(2026, 12, 31),
  createdAt: DateTime.now(),
));

// 2. Thêm tiền vào hũ
await repo.addSavingsToGoal(goalId, 5000000); // +5M
await repo.addSavingsToGoal(goalId, 3000000); // +3M

// 3. Kiểm tra tiến độ
final goal = await repo.getGoalById(goalId);
print('Progress: ${repo.getProgressPercentage(goal!)}%'); // 26.67%

// 4. Xem lịch sử
final history = await repo.getHistoryByGoalId(goalId);
print('Total transactions: ${history.length}'); // 2

// 5. Cảnh báo deadline
final urgent = await repo.getGoalsNearDeadline(30);
if (urgent.isNotEmpty) {
  print('⚠️ ${urgent.length} goals expiring soon!');
}
```

---

## 🔄 Migration Notes

### Database Version: 2

Nếu upgrade từ version cũ, cần:

1. Tạo bảng `saving_history` (xem `database_provider.dart`)
2. Thêm FOREIGN KEY constraint với CASCADE delete

### Breaking Changes

- None (module mới)

---

## 🛠️ Next Steps (Optional Enhancements)

- [ ] Add notifications cho goals gần deadline
- [ ] Implement auto-save rules (tự động chuyển % lương vào hũ)
- [ ] Export history to CSV/Excel
- [ ] Add goal categories/tags
- [ ] Implement recurring deposits

---

## 📞 Support

**Developer:** Backend Team - Savings Module  
**Branch:** `feature/savings`  
**Last Updated:** January 6, 2026
