// C:\Users\user\Desktop\0703flutter_v2\lib\main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app/router.dart';
import 'app/theme.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'features/chatbot/viewmodel/chatbot_viewmodel.dart';
import 'features/diagnosis/viewmodel/diagnosis_viewmodel.dart';

// ✅ 새로운 기능 ViewModel 임포트 추가 (경로 확인)
import 'features/history/viewmodel/history_viewmodel.dart';
import 'features/non_face_to_face/viewmodel/consultation_viewmodel.dart'; // ✅ 이 경로가 정확해야 합니다.
import 'features/nearby_clinics/viewmodel/clinic_viewmodel.dart';


void main() {
  final String globalBaseUrl = kIsWeb
      ? "http://127.0.0.1:5000"
      : "http://10.0.2.2:5000";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => UserInfoViewModel()),
        ChangeNotifierProvider(create: (context) => ChatbotViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => DiagnosisViewModel(baseUrl: globalBaseUrl)),
        // ✅ 새로운 기능 ViewModel 추가
        ChangeNotifierProvider(create: (context) => HistoryViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => ConsultationViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => ClinicViewModel(baseUrl: globalBaseUrl)),
      ],
      child: const MediToothApp(),
    ),
  );
}

class MediToothApp extends StatelessWidget {
  const MediToothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
