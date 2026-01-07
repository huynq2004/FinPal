import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/data/repositories/saving_goal_repository.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late SavingGoalRepository repository;

  setUpAll(() {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    repository = SavingGoalRepository();
  });

  group('SavingGoalRepository CRUD Tests', () {
    test('createGoal should insert a new goal and return id', () async {
      // Arrange
      final newGoal = SavingGoal(
        name: 'Test Goal',
        targetAmount: 5000000,
        currentSaved: 0,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      // Act
      final goalId = await repository.createGoal(newGoal);

      // Assert
      expect(goalId, greaterThan(0));

      // Verify it exists
      final retrieved = await repository.getGoalById(goalId);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test Goal'));
      expect(retrieved.targetAmount, equals(5000000));
    });

    test('updateGoal should modify existing goal', () async {
      // Arrange
      final newGoal = SavingGoal(
        name: 'Original Name',
        targetAmount: 3000000,
        currentSaved: 1000000,
        deadline: DateTime.now().add(const Duration(days: 60)),
        createdAt: DateTime.now(),
      );

      final goalId = await repository.createGoal(newGoal);
      final createdGoal = await repository.getGoalById(goalId);

      // Act
      final updatedGoal = createdGoal!.copyWith(
        name: 'Updated Name',
        targetAmount: 5000000,
      );
      await repository.updateGoal(updatedGoal);

      // Assert
      final retrieved = await repository.getGoalById(goalId);
      expect(retrieved!.name, equals('Updated Name'));
      expect(retrieved.targetAmount, equals(5000000));
      expect(retrieved.currentSaved, equals(1000000)); // Unchanged
    });

    test('getGoalById should return null for non-existent id', () async {
      // Act
      final goal = await repository.getGoalById(99999);

      // Assert
      expect(goal, isNull);
    });

    test('deleteGoal should remove the goal', () async {
      // Arrange
      final newGoal = SavingGoal(
        name: 'To Be Deleted',
        targetAmount: 1000000,
        currentSaved: 0,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final goalId = await repository.createGoal(newGoal);
      expect(await repository.getGoalById(goalId), isNotNull);

      // Act
      await repository.deleteGoal(goalId);

      // Assert
      final deletedGoal = await repository.getGoalById(goalId);
      expect(deletedGoal, isNull);
    });

    test('getAllGoals should return all goals', () async {
      // Arrange
      await repository.createGoal(
        SavingGoal(
          name: 'Goal 1',
          targetAmount: 1000000,
          currentSaved: 500000,
          deadline: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        ),
      );

      await repository.createGoal(
        SavingGoal(
          name: 'Goal 2',
          targetAmount: 2000000,
          currentSaved: 1000000,
          deadline: DateTime.now().add(const Duration(days: 60)),
          createdAt: DateTime.now(),
        ),
      );

      // Act
      final goals = await repository.getAllGoals();

      // Assert
      expect(goals.length, greaterThanOrEqualTo(2));
    });
  });

  group('SavingGoalRepository Business Logic Tests', () {
    test(
      'addSavingsToGoal should increase currentSaved and create history',
      () async {
        // Arrange
        final newGoal = SavingGoal(
          name: 'Savings Test',
          targetAmount: 5000000,
          currentSaved: 1000000,
          deadline: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
        );

        final goalId = await repository.createGoal(newGoal);

        // Act
        await repository.addSavingsToGoal(goalId, 500000);

        // Assert
        final updatedGoal = await repository.getGoalById(goalId);
        expect(updatedGoal!.currentSaved, equals(1500000));

        // Verify history was created
        final history = await repository.getHistoryByGoalId(goalId);
        expect(history.length, equals(1));
        expect(history.first.amount, equals(500000));
        expect(history.first.type, equals('add'));
      },
    );

    test(
      'withdrawFromGoal should decrease currentSaved and create history',
      () async {
        // Arrange
        final newGoal = SavingGoal(
          name: 'Withdraw Test',
          targetAmount: 5000000,
          currentSaved: 3000000,
          deadline: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
        );

        final goalId = await repository.createGoal(newGoal);

        // Act
        await repository.withdrawFromGoal(goalId, 1000000, note: 'Emergency');

        // Assert
        final updatedGoal = await repository.getGoalById(goalId);
        expect(updatedGoal!.currentSaved, equals(2000000));

        // Verify history
        final history = await repository.getHistoryByGoalId(goalId);
        expect(history.length, equals(1));
        expect(history.first.amount, equals(-1000000));
        expect(history.first.type, equals('withdraw'));
        expect(history.first.note, equals('Emergency'));
      },
    );

    test(
      'withdrawFromGoal should throw exception when insufficient funds',
      () async {
        // Arrange
        final newGoal = SavingGoal(
          name: 'Insufficient Test',
          targetAmount: 5000000,
          currentSaved: 500000,
          deadline: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
        );

        final goalId = await repository.createGoal(newGoal);

        // Act & Assert
        expect(
          () => repository.withdrawFromGoal(goalId, 1000000),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'getGoalsByProgress should return goals sorted by completion percentage',
      () async {
        // Arrange
        await repository.createGoal(
          SavingGoal(
            name: 'Low Progress',
            targetAmount: 10000000,
            currentSaved: 1000000, // 10%
            deadline: DateTime.now().add(const Duration(days: 90)),
            createdAt: DateTime.now(),
          ),
        );

        await repository.createGoal(
          SavingGoal(
            name: 'High Progress',
            targetAmount: 5000000,
            currentSaved: 4500000, // 90%
            deadline: DateTime.now().add(const Duration(days: 60)),
            createdAt: DateTime.now(),
          ),
        );

        await repository.createGoal(
          SavingGoal(
            name: 'Medium Progress',
            targetAmount: 2000000,
            currentSaved: 1000000, // 50%
            deadline: DateTime.now().add(const Duration(days: 30)),
            createdAt: DateTime.now(),
          ),
        );

        // Act
        final sortedGoals = await repository.getGoalsByProgress();

        // Assert
        expect(sortedGoals.length, greaterThanOrEqualTo(3));

        // First should have highest progress
        final firstProgress = repository.getProgressPercentage(
          sortedGoals.first,
        );
        expect(firstProgress, greaterThanOrEqualTo(80)); // 90%
      },
    );

    test(
      'getGoalsNearDeadline should return only goals within threshold',
      () async {
        // Arrange
        final now = DateTime.now();

        // Goal expiring in 5 days
        await repository.createGoal(
          SavingGoal(
            name: 'Urgent Goal',
            targetAmount: 1000000,
            currentSaved: 500000,
            deadline: now.add(const Duration(days: 5)),
            createdAt: now,
          ),
        );

        // Goal expiring in 50 days
        await repository.createGoal(
          SavingGoal(
            name: 'Far Goal',
            targetAmount: 2000000,
            currentSaved: 1000000,
            deadline: now.add(const Duration(days: 50)),
            createdAt: now,
          ),
        );

        // Already completed goal (should be excluded)
        await repository.createGoal(
          SavingGoal(
            name: 'Completed Goal',
            targetAmount: 1000000,
            currentSaved: 1000000,
            deadline: now.add(const Duration(days: 3)),
            createdAt: now,
          ),
        );

        // Act
        final nearDeadline = await repository.getGoalsNearDeadline(7);

        // Assert
        final urgentGoalFound = nearDeadline.any(
          (g) => g.name == 'Urgent Goal',
        );
        final farGoalFound = nearDeadline.any((g) => g.name == 'Far Goal');
        final completedGoalFound = nearDeadline.any(
          (g) => g.name == 'Completed Goal',
        );

        expect(urgentGoalFound, isTrue);
        expect(farGoalFound, isFalse);
        expect(completedGoalFound, isFalse);
      },
    );

    test('getProgressPercentage should calculate correctly', () {
      // Arrange
      final goal1 = SavingGoal(
        name: 'Half Done',
        targetAmount: 2000000,
        currentSaved: 1000000,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final goal2 = SavingGoal(
        name: 'Zero Target',
        targetAmount: 0,
        currentSaved: 500000,
        deadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(repository.getProgressPercentage(goal1), equals(50.0));
      expect(repository.getProgressPercentage(goal2), equals(0.0));
    });
  });

  group('SavingGoalRepository History Tests', () {
    test(
      'getHistoryByGoalId should return all transactions for a goal',
      () async {
        // Arrange
        final newGoal = SavingGoal(
          name: 'History Test',
          targetAmount: 5000000,
          currentSaved: 0,
          deadline: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
        );

        final goalId = await repository.createGoal(newGoal);

        // Add multiple transactions
        await repository.addSavingsToGoal(goalId, 1000000);
        await repository.addSavingsToGoal(goalId, 500000);
        await repository.withdrawFromGoal(goalId, 200000);

        // Act
        final history = await repository.getHistoryByGoalId(goalId);

        // Assert
        expect(history.length, equals(3));
        expect(history[0].type, equals('withdraw')); // Most recent first
        expect(history[1].type, equals('add'));
        expect(history[2].type, equals('add'));
      },
    );

    test('deleteHistoryByGoalId should remove all history records', () async {
      // Arrange
      final newGoal = SavingGoal(
        name: 'Delete History Test',
        targetAmount: 5000000,
        currentSaved: 0,
        deadline: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now(),
      );

      final goalId = await repository.createGoal(newGoal);
      await repository.addSavingsToGoal(goalId, 1000000);
      await repository.addSavingsToGoal(goalId, 500000);

      // Act
      await repository.deleteHistoryByGoalId(goalId);

      // Assert
      final history = await repository.getHistoryByGoalId(goalId);
      expect(history.length, equals(0));
    });
  });
}
