// C:\Users\sptzk\Desktop\t0703\lib\features\mypage\view\edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatter를 위해 필요
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/model/user.dart'; // User 모델 임포트
import '../viewmodel/userinfo_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedGender;
  late TextEditingController _birthController;
  late TextEditingController _phoneController;
  late TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserInfoViewModel>().user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedGender = user?.gender ?? 'M';
    _birthController = TextEditingController(text: user?.birth ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _userIdController = TextEditingController(text: user?.userId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _showSnack('개인정보가 저장되었습니다. (실제 저장 로직은 미구현)');
      context.pop(); // 저장 후 이전 화면 (마이페이지)으로 돌아가기
    } else {
      _showSnack('입력된 정보를 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 수정'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // 이전 화면 (마이페이지)으로 돌아가기
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              _buildTextField(
                _nameController,
                '이름 (한글만)',
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[가-힣]*$')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '이름을 입력해주세요';
                  if (!RegExp(r'^[가-힣]+$').hasMatch(value)) return '이름은 한글만 입력 가능합니다';
                  return null;
                },
              ),
              _buildGenderSelector(),
              _buildTextField(
                _birthController,
                '생년월일 (YYYY-MM-DD)',
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '생년월일을 입력해주세요';
                  final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!dateRegex.hasMatch(value)) return '올바른 생년월일 형식(YYYY-MM-DD)으로 입력하세요';
                  try {
                    final DateTime birthDate = DateTime.parse(value);
                    final DateTime now = DateTime.now();
                    if (birthDate.isAfter(now)) return '생년월일은 오늘 날짜를 넘을 수 없습니다';
                  } catch (e) {
                    return '유효하지 않은 날짜입니다 (예: 2023-02-30)';
                  }
                  return null;
                },
              ),
              _buildTextField(
                _phoneController,
                '전화번호 (숫자만)',
                maxLength: 11,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '전화번호를 입력해주세요';
                  if (!RegExp(r'^\d{10,11}$').hasMatch(value)) return '유효한 전화번호를 입력하세요 (숫자 10-11자리)';
                  return null;
                },
              ),
              _buildTextField(
                _userIdController,
                '아이디',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('변경 사항 저장', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    int? maxLength,
    int? minLength,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    InputDecoration? decoration,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        decoration: decoration ?? InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          counterText: '',
        ),
        validator: validator,
      ),
    );
  }

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

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    String newText = '';

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 6) {
        if (text.length > i) {
          newText += '-';
        }
      }
      newText += text[i];
    }

    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}