// C:\Users\sptzk\Desktop\t0703\lib\features\auth\viewmodel\auth_viewmodel.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // kIsWeb을 위해 필요
import 'package:http/http.dart' as http;
import '../model/user.dart';

class AuthViewModel with ChangeNotifier {
  // ✅ 생성자를 통해 주입받도록 변경 (final 키워드 유지)
  final String _baseUrl; 

  // ✅ 생성자 추가: baseUrl을 필수 매개변수로 받습니다.
  AuthViewModel({required String baseUrl}) : _baseUrl = baseUrl;

  Future<bool?> checkUserIdDuplicate(String userId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/auth/exists?user_id=$userId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['exists'] == true;
      } else {
        if (kDebugMode) {
          print('ID 중복검사 서버 응답 오류: StatusCode=${res.statusCode}, Body=${res.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('ID 중복검사 중 네트워크 오류: $e');
      }
      return null;
    }
  }

  Future<String?> registerUser(Map<String, String> userData) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (res.statusCode == 201) {
        return null;
      } else {
        final data = jsonDecode(res.body);
        return data['error'] ?? '알 수 없는 오류가 발생했습니다.';
      }
    } catch (e) {
      if (kDebugMode) {
        print('회원가입 중 네트워크 오류: $e');
      }
      return '서버와 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
    }
  }

  /// 사용자 로그인
  /// 반환값: User 객체 (로그인 성공), String (오류 메시지)
  Future<User?> loginUser(String userId, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return User.fromJson(data['user']);
      } else {
        final data = jsonDecode(res.body);
        throw data['error'] ?? '알 수 없는 로그인 오류';
      }
    } catch (e) {
      if (kDebugMode) {
        print('로그인 중 네트워크 오류: $e');
      }
      if (e is String) {
        throw e;
      } else {
        throw '서버와 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
      }
    }
  }

  Future<String?> deleteUser(String userId, String password) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/auth/delete_account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'password': password}),
      );

      if (res.statusCode == 200) {
        return null;
      } else {
        final data = jsonDecode(res.body);
        return data['error'] ?? '회원 탈퇴 중 알 수 없는 오류가 발생했습니다.';
      }
    } catch (e) {
      if (kDebugMode) {
        print('회원 탈퇴 중 네트워크 오류: $e');
      }
      return '서버와 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
    }
  }
}