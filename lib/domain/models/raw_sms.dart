/// Model đại diện cho một tin nhắn SMS thô chưa được xử lý
class RawSms {
  final String address; // Số điện thoại hoặc tên người gửi (VD: VCB, TECHCOMBANK)
  final String body; // Nội dung tin nhắn
  final DateTime date; // Thời gian nhận tin nhắn
  final int id; // ID của SMS trong hệ thống

  RawSms({
    required this.address,
    required this.body,
    required this.date,
    required this.id,
  });

  /// Tạo RawSms từ Map (từ Telephony plugin)
  factory RawSms.fromMap(Map<String, dynamic> map) {
    return RawSms(
      address: map['address'] ?? '',
      body: map['body'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      id: map['_id'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'RawSms(id: $id, address: $address, date: $date, body: ${body.substring(0, body.length > 50 ? 50 : body.length)}...)';
  }
}
