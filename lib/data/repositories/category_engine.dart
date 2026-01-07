/// Engine xử lý phân loại giao dịch dựa trên rule-based keywords
class CategoryEngine {
  /// Bảng mapping keyword → category name
  static const Map<String, List<String>> _keywordMap = {
    'Di chuyển': ['grab', 'be', 'gojek', 'xe om', 'taxi'],
    'Mua sắm': ['shopee', 'lazada', 'tiki', 'sendo', 'tgdd', 'fpt shop'],
    'Ăn uống': [
      'grab food',
      'shopee food',
      'highlands',
      'phuc long',
      'the coffee house',
      'starbucks',
      'now',
      'baemin',
      'lotteria',
      'kfc',
      'jollibee',
      'pizza',
      'pho',
      'bun',
    ],
  };

  /// Map category name → category ID (hardcoded cho demo)
  /// Trong thực tế, sẽ load từ DB
  static const Map<String, int> _categoryIds = {
    'Di chuyển': 1,
    'Mua sắm': 2,
    'Ăn uống': 3,
    'Khác': 99, // Default category
  };

  /// Phân loại content và trả về categoryId
  /// Trả về null nếu không tìm thấy category phù hợp
  int? classify(String content) {
    if (content.isEmpty) return _categoryIds['Khác'];

    // Normalize content: lowercase và bỏ dấu
    final normalized = _normalize(content);

    print('🔍 [CategoryEngine] Đang phân loại: "$content" → normalized: "$normalized"');

    // Tạo danh sách (keyword, categoryName) và sắp xếp theo độ dài giảm dần
    // Để match keyword dài trước (VD: "grab food" trước "grab")
    final keywordList = <({String keyword, String categoryName})>[];
    for (final entry in _keywordMap.entries) {
      final categoryName = entry.key;
      for (final keyword in entry.value) {
        keywordList.add((keyword: keyword, categoryName: categoryName));
      }
    }
    
    // Sắp xếp theo độ dài keyword giảm dần
    keywordList.sort((a, b) => b.keyword.length.compareTo(a.keyword.length));

    // Duyệt qua các keywords (từ dài nhất đến ngắn nhất)
    for (final item in keywordList) {
      // Sử dụng word boundary để tránh match một phần từ
      // VD: "now" chỉ match "now" hoặc "now food", không match "unknown"
      final pattern = RegExp(r'\b' + RegExp.escape(item.keyword) + r'\b');
      if (pattern.hasMatch(normalized)) {
        final categoryId = _categoryIds[item.categoryName];
        print('✅ [CategoryEngine] Match keyword "${item.keyword}" → ${item.categoryName} (ID: $categoryId)');
        return categoryId;
      }
    }

    // Không match keyword nào → trả về category "Khác"
    print('❌ [CategoryEngine] Không tìm thấy keyword → Khác');
    return _categoryIds['Khác'];
  }

  /// Normalize text: lowercase + bỏ dấu tiếng Việt
  String _normalize(String text) {
    String result = text.toLowerCase();

    // Map dấu tiếng Việt → không dấu
    const Map<String, String> vietnameseDiacritics = {
      'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
      'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
      'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
      'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
      'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
      'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
      'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
      'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
      'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
      'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
      'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
      'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
      'đ': 'd',
    };

    // Thay thế từng ký tự có dấu
    vietnameseDiacritics.forEach((diacritic, replacement) {
      result = result.replaceAll(diacritic, replacement);
    });

    return result;
  }

  /// Lấy tên category từ ID (cho debug/display)
  String? getCategoryNameById(int? categoryId) {
    if (categoryId == null) return null;
    
    for (final entry in _categoryIds.entries) {
      if (entry.value == categoryId) {
        return entry.key;
      }
    }
    
    return null;
  }
}
