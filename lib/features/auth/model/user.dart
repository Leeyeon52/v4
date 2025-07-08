// C:\Users\sptzk\Desktop\t0703\lib\features\auth\model\user.dart

class User {
  final String userId;
  final String name;
  final String gender;
  final String birth;
  final String phone;
  final String address; // Flask에서 address 필드도 반환하므로 추가

  User({
    required this.userId,
    required this.name,
    required this.gender,
    required this.birth,
    required this.phone,
    this.address = '', // 기본값 설정
  });

  // JSON 데이터로부터 User 객체를 생성하는 팩토리 생성자
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      birth: json['birth'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String? ?? '', // null 처리 추가
    );
  }

  // User 객체를 JSON으로 변환하는 메서드 (필요시)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'gender': gender,
      'birth': birth,
      'phone': phone,
      'address': address,
    };
  }
}