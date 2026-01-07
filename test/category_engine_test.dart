import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/data/repositories/category_engine.dart';

void main() {
  group('CategoryEngine Tests', () {
    late CategoryEngine engine;

    setUp(() {
      engine = CategoryEngine();
    });

    test('Phân loại content về Di chuyển', () {
      // Test các keyword di chuyển
      expect(engine.classify('GRAB'), 1); // categoryId = 1
      expect(engine.classify('Be'), 1);
      expect(engine.classify('GOJEK'), 1);
      expect(engine.classify('thanh toan tai GRAB'), 1);
      
      // Verify category name
      expect(engine.getCategoryNameById(1), 'Di chuyển');
    });

    test('Phân loại content về Mua sắm', () {
      // Test các keyword mua sắm
      expect(engine.classify('SHOPEE'), 2); // categoryId = 2
      expect(engine.classify('Lazada'), 2);
      expect(engine.classify('TIKI'), 2);
      expect(engine.classify('mua hang tai SHOPEE'), 2);
      
      // Verify category name
      expect(engine.getCategoryNameById(2), 'Mua sắm');
    });

    test('Phân loại content về Ăn uống', () {
      // Test các keyword ăn uống
      expect(engine.classify('HIGHLANDS'), 3); // categoryId = 3
      expect(engine.classify('phuc long'), 3);
      expect(engine.classify('THE COFFEE HOUSE'), 3);
      expect(engine.classify('STARBUCKS'), 3);
      expect(engine.classify('GRAB FOOD'), 3);
      
      // Verify category name
      expect(engine.getCategoryNameById(3), 'Ăn uống');
    });

    test('Phân loại content không match keyword → Khác', () {
      // Content không match keyword nào
      expect(engine.classify('ABC COMPANY'), 99); // categoryId = 99 (Khác)
      expect(engine.classify('UNKNOWN MERCHANT'), 99);
      expect(engine.classify('123456'), 99);
      
      // Verify category name
      expect(engine.getCategoryNameById(99), 'Khác');
    });

    test('Normalize text: bỏ dấu tiếng Việt', () {
      // Test với content có dấu
      expect(engine.classify('Phúc Long'), 3); // "Phúc Long" → "phuc long" → Ăn uống
      expect(engine.classify('Hải Sản'), 99); // Không match → Khác
    });

    test('Empty content trả về Khác', () {
      expect(engine.classify(''), 99);
    });

    test('Case insensitive matching', () {
      // Viết hoa/thường đều match
      expect(engine.classify('grab'), 1);
      expect(engine.classify('GRAB'), 1);
      expect(engine.classify('GrAb'), 1);
      expect(engine.classify('shopee'), 2);
      expect(engine.classify('SHOPEE'), 2);
    });
  });
}
