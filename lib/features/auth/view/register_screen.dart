//C:\Users\user\Desktop\0703flutter_v2\lib\features\auth\view\register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatter를 위해 필요
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedGender = 'M';
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isChecking = false;
  bool _isDuplicate = false; // 아이디 중복 여부 (true면 중복, false면 사용 가능)
  bool _isIdChecked = false; // 아이디 중복 확인 버튼을 눌렀는지 여부

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // 아이디 중복 검사
  Future<void> _checkDuplicateId() async {
    final viewModel = context.read<AuthViewModel>();
    final id = _userIdController.text.trim();

    // 아이디 길이 유효성 검사 (최소 4자)
    if (id.length < 4) {
      _showSnack('아이디는 최소 4자 이상이어야 합니다');
      setState(() {
        _isIdChecked = false; // 유효성 검사 실패 시 중복확인 상태 초기화
        _isDuplicate = true; // 유효성 검사 실패 시 중복으로 간주하여 제출 방지
      });
      return;
    }

    setState(() {
      _isChecking = true; // 로딩 상태 시작
      _isIdChecked = false; // 중복확인 진행 중
    });

    final exists = await viewModel.checkUserIdDuplicate(id);

    setState(() {
      _isChecking = false; // 로딩 상태 종료
      _isIdChecked = true; // 중복확인 완료
      _isDuplicate = exists ?? true; // 네트워크 오류 시 중복으로 간주 (안전한 기본값)
    });

    if (exists == null) {
      _showSnack('ID 중복검사 실패: 서버와 연결할 수 없습니다');
    } else if (exists) {
      _showSnack('이미 사용 중인 아이디입니다');
    } else {
      _showSnack('사용 가능한 아이디입니다');
    }
  }

  // 회원가입 제출
  Future<void> _submit() async {
    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      _showSnack('모든 필드를 올바르게 입력해주세요.');
      return;
    }

    // 아이디 중복 확인 여부 검사
    if (!_isIdChecked) {
      _showSnack('아이디 중복 확인이 필요합니다.');
      return;
    }
    // 아이디 중복 여부 검사
    if (_isDuplicate) {
      _showSnack('이미 사용 중인 아이디입니다. 다른 아이디를 사용해주세요.');
      return;
    }

    final userData = {
      'name': _nameController.text.trim(),
      'gender': _selectedGender,
      'birth': _birthController.text.trim(),
      'phone': _phoneController.text.trim(),
      'user_id': _userIdController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    final viewModel = context.read<AuthViewModel>();
    final error = await viewModel.registerUser(userData);

    if (error == null) {
      _showSnack('회원가입 성공!');
      context.go('/login'); // 회원가입 성공 시 로그인 화면으로 이동
    } else {
      _showSnack(error); // 서버에서 반환된 오류 메시지 표시
    }
  }

  // 스낵바 표시 유틸리티 함수
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'), // 뒤로가기 버튼
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          // ✅ 사용자가 입력하는 동안 실시간으로 유효성 검사
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              // ✅ 이름 필드: 한글 입력 문제 해결 - Formatter 제거, Validator에서 검사
              _buildTextField(
                _nameController,
                '이름 (한글만)', // 레이블 변경하여 입력 방식 안내
                keyboardType: TextInputType.name,
                // inputFormatters 제거
              ),
              _buildGenderSelector(),
              // 생년월일 필드: 자동 하이픈 추가
              _buildTextField(
                _birthController,
                '생년월일 (YYYYMMDD)', // 레이블 변경하여 입력 방식 안내
                maxLength: 10, // YYYY-MM-DD는 10자
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()], // 새로 정의한 포매터 적용
              ),
              _buildTextField(
                _phoneController,
                '전화번호 (숫자만)', // 사용자에게 하이픈 없이 입력하도록 안내
                maxLength: 11,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _userIdController,
                      '아이디 (최소 4자, 최대 20자)', // 아이디 최대 글자 제한 안내
                      minLength: 4,
                      maxLength: 20, // 아이디 최대 글자 제한 적용
                      // 아이디 필드 변경 시 중복확인 상태 초기화
                      onChanged: (value) {
                        setState(() {
                          _isIdChecked = false;
                          _isDuplicate = true; // 다시 중복으로 간주
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isChecking ? null : _checkDuplicateId,
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('중복확인'),
                  ),
                ],
              ),
              _buildTextField(_passwordController, '비밀번호 (최소 6자)', isPassword: true, minLength: 6),
              _buildTextField(_confirmController, '비밀번호 확인', isPassword: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('회원가입 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드 위젯 빌더
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    int? maxLength,
    int? minLength,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged, // 텍스트 변경 이벤트 추가
    List<TextInputFormatter>? inputFormatters, // TextInputFormatter 리스트 추가
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged, // 추가된 onChanged 콜백
        inputFormatters: inputFormatters, // TextInputFormatter 적용
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '', // maxLength 사용 시 하단에 글자 수 표시 제거
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '$label을 입력해주세요';
          if (minLength != null && value.trim().length < minLength) {
            return '$label은 ${minLength}자 이상이어야 합니다';
          }
          if (label == '비밀번호 확인' && value != _passwordController.text) {
            return '비밀번호가 일치하지 않습니다';
          }
          // ✅ 이름 필드 유효성 검사 (한글만 허용)
          if (label == '이름 (한글만)' && !RegExp(r'^[가-힣]+$').hasMatch(value)) {
            return '이름은 한글만 입력 가능합니다';
          }
          // 전화번호 유효성 검사
          if (label == '전화번호 (숫자만)' && !RegExp(r'^\d{10,11}$').hasMatch(value)) {
            return '유효한 전화번호를 입력하세요 (숫자 10-11자리)';
          }
          // 생년월일 유효성 검사
          if (label == '생년월일 (YYYYMMDD)') { // 레이블에 맞게 변경
            final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // 형식은 YYYY-MM-DD
            if (!dateRegex.hasMatch(value)) {
              return '올바른 생년월일 형식(YYYY-MM-DD)으로 입력하세요';
            }
            try {
              final DateTime birthDate = DateTime.parse(value);
              final DateTime now = DateTime.now();
              if (birthDate.isAfter(now)) {
                return '생년월일은 오늘 날짜를 넘을 수 없습니다';
              }
            } catch (e) {
              return '유효하지 않은 날짜입니다 (예: 2023-02-30)';
            }
          }
          return null;
        },
      ),
    );
  }

  // 성별 선택 라디오 버튼 빌더
  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Text('성별', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('남'),
              value: 'M',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('여'),
              value: 'F',
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
          ),
        ],
      ),
    );
  }
}

// 생년월일 자동 하이픈 추가를 위한 커스텀 TextInputFormatter
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), ''); // 숫자만 남김
    String newText = '';

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 6) { // 4번째(년도 뒤)와 6번째(월 뒤)에 하이픈 추가
        if (text.length > i) {
          newText += '-';
        }
      }
      newText += text[i];
    }

    // 최대 길이 10 (YYYY-MM-DD)
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    // 커서 위치 조정
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}