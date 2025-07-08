// C:\Users\sptzk\Desktop\t0703\lib\features\diagnosis\view\realtime_prediction_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb 임포트
import 'package:camera/camera.dart'; // camera 패키지 임포트
import 'dart:io'; // 파일 저장을 위해 임포트 (Android/iOS 전용)
import 'package:path_provider/path_provider.dart'; // 경로 지정을 위해 임포트
// TODO: YOLOv11-seg 모델 연동을 위한 패키지 임포트 (예: tflite_flutter 또는 별도 로컬 모델 관리)
// import 'package:tflite_flutter/tflite_flutter.dart';

// IMPORTANT: main 함수에서 사용 가능한 카메라 목록을 초기화해야 합니다.
// runApp 전에 다음 코드를 실행해야 합니다.
//
// List<CameraDescription> cameras = [];
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
//   cameras = await availableCameras(); // 사용 가능한 카메라 목록 가져오기
//   runApp(const MyApp()); // 앱 실행
// }

class RealtimePredictionScreen extends StatefulWidget {
  const RealtimePredictionScreen({super.key});

  @override
  State<RealtimePredictionScreen> createState() => _RealtimePredictionScreenState();
}

class _RealtimePredictionScreenState extends State<RealtimePredictionScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = []; // 사용 가능한 카메라 목록을 저장할 변수
  bool _isCameraInitialized = false;
  bool _isCameraReady = false; // 카메라 미리보기가 준비되었는지 확인하는 플래그

  // TODO: YOLOv11-seg 모델 관련 변수 추가
  // Interpreter? _interpreter; // TFLite 모델 인터프리터
  // bool _isModelLoaded = false;
  // List<dynamic>? _detectionResults; // 예측 결과 저장

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeCamera();
      // TODO: 모델 로드 함수 호출 (필요하다면)
      // _loadModel();
    }
  }

  // TODO: TFLite 모델 로드 함수 예시
  /*
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/yolov11n_seg.tflite'); // 모델 파일 경로
      setState(() {
        _isModelLoaded = true;
      });
      print('YOLOv11-seg 모델 로드 완료');
    } catch (e) {
      print('YOLOv11-seg 모델 로드 중 오류 발생: $e');
      setState(() {
        _isModelLoaded = false;
      });
    }
  }
  */

  Future<void> _initializeCamera() async {
    try {
      // main 함수에서 availableCameras()를 호출하여 _cameras에 저장했다고 가정
      // 만약 main에서 하지 않았다면 여기서 availableCameras()를 다시 호출해야 합니다.
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isCameraInitialized = false;
        });
        print('사용 가능한 카메라가 없습니다.');
        return;
      }

      // 첫 번째 카메라를 선택하고 해상도 설정
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.medium, // 실시간 처리를 위해 medium 또는 low가 적합할 수 있습니다.
        enableAudio: false,
      );

      // 카메라 초기화
      await _controller!.initialize();

      // TODO: 실시간 이미지 스트림 시작 (YOLO 모델 연동 시 필요)
      /*
      _controller!.startImageStream((CameraImage image) {
        // 이 곳에서 CameraImage를 YOLO 모델 입력 형식에 맞게 전처리하고,
        // 모델 추론을 실행하며, 결과를 _detectionResults에 저장하고 setState 호출
        // 추론 로직은 UI 스레드를 블록하지 않도록 별도의 Isolate에서 실행하는 것이 좋습니다.
        _runModelOnFrame(image);
      });
      */

      setState(() {
        _isCameraInitialized = true;
        _isCameraReady = true; // 카메라 초기화 및 미리보기 준비 완료
      });
    } catch (e) {
      print('카메라 초기화 중 오류 발생: $e');
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  // TODO: 카메라 프레임에서 모델 실행 함수 예시
  /*
  Future<void> _runModelOnFrame(CameraImage cameraImage) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('모델이 로드되지 않았습니다.');
      return;
    }

    // TODO: CameraImage를 YOLO 모델 입력에 맞게 전처리하는 로직 구현
    // 이 부분은 복잡할 수 있으며, 이미지 형식 변환, 리사이징 등이 포함됩니다.
    // List<List<List<num>>> inputImage = preprocessCameraImage(cameraImage);

    // TODO: 모델 추론 실행
    // var output = List.filled(outputShape, 0).reshape(outputShape); // 모델 출력 형태에 맞게 정의
    // _interpreter!.run(inputImage, output);

    // TODO: 추론 결과 파싱 및 _detectionResults 업데이트
    // final parsedResults = parseYoloOutput(output);
    // setState(() {
    //   _detectionResults = parsedResults;
    // });
  }
  */

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      print('카메라가 초기화되지 않았습니다.');
      return;
    }
    if (_controller!.value.isTakingPicture) {
      // 이미 사진을 찍고 있으면 무시
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      print('사진이 촬영되었습니다: ${image.path}');

      // 촬영된 사진을 앱 내부 폴더에 저장
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await image.saveTo(filePath);
      print('사진이 저장되었습니다: $filePath');

      // TODO: 촬영된 사진(filePath)을 YOLOv11-seg 모델에 전달하여 예측 수행
      // 이 부분은 실시간 스트림 처리가 아닌, 한 장의 사진에 대한 예측 로직이 들어갈 수 있습니다.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진이 저장되었습니다: ${image.path.split('/').last}')),
      );
    } catch (e) {
      print('사진 촬영 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // 카메라 컨트롤러 해제
    // TODO: 모델 인터프리터 해제 (필요하다면)
    // _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 예측'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // 홈 화면으로 돌아가기
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb) // 웹 환경일 경우
              Column(
                children: [
                  const Icon(Icons.web_asset_off, size: 100, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  const Text(
                    '웹에서는 실시간 예측 기능을 이용할 수 없습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '이 기능은 Android 또는 iOS 기기에서만 지원됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              )
            else // Android 또는 iOS 환경일 경우
              Expanded( // 카메라 미리보기가 화면 전체를 채우도록 Expanded 사용
                child: _isCameraInitialized && _isCameraReady && _controller!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            child: AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: CameraPreview(_controller!),
                            ),
                          ),
                          // TODO: 여기에 YOLOv11-seg 예측 결과 오버레이 추가 (CustomPaint 등 사용)
                          // 예를 들어, _detectionResults 변수에 예측 결과가 있다면 이를 그리는 CustomPainter를 사용합니다.
                          /*
                          if (_detectionResults != null)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DetectionPainter(
                                  _detectionResults!,
                                  _controller!.value.previewSize!, // 카메라 미리보기 크기
                                  // 추가적으로 이미지 원본 크기, 바운딩 박스 색상 등 전달
                                ),
                              ),
                            ),
                          */
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: FloatingActionButton(
                              onPressed: _takePicture, // 캡처 버튼
                              child: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text('카메라 로딩 중...', style: TextStyle(fontSize: 18)),
                            Text('카메라 권한을 확인해주세요.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

// TODO: CustomPainter 예시 (예측 결과를 화면에 그리는 용도)
/*
class DetectionPainter extends CustomPainter {
  final List<dynamic> detections; // YOLO 모델의 예측 결과 (예: 바운딩 박스, 마스크 등)
  final Size previewSize; // 카메라 미리보기의 실제 크기 (렌더링되는 위젯 크기와 다를 수 있음)
  // final Size originalImageSize; // 모델에 입력된 원본 이미지 크기 (선택 사항)

  DetectionPainter(this.detections, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boxPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint maskPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // TODO: YOLO 모델의 출력 좌표를 화면 좌표로 변환하는 로직 구현
    // previewSize와 size(캔버스 크기)를 사용하여 스케일링 및 위치 조정을 해야 합니다.

    for (var detection in detections) {
      // 바운딩 박스 그리기
      // final Rect rect = Rect.fromLTRB(left, top, right, bottom); // 변환된 좌표
      // canvas.drawRect(rect, boxPaint);

      // 세그멘테이션 마스크 그리기 (Path 사용)
      // final Path maskPath = Path();
      // for (var point in detection.maskPoints) { // 마스크 포인트 데이터
      //   if (maskPath.isEmpty) {
      //     maskPath.moveTo(point.x, point.y);
      //   } else {
      //     maskPath.lineTo(point.x, point.y);
      //   }
      // }
      // maskPath.close();
      // canvas.drawPath(maskPath, maskPaint);

      // 텍스트 라벨 그리기
      // TextPainter(
      //   text: TextSpan(text: detection.label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      //   textDirection: TextDirection.ltr,
      // )..layout()..paint(canvas, Offset(rect.left, rect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // 이전 예측 결과와 다르면 다시 그립니다.
    // return oldDelegate is DetectionPainter && oldDelegate.detections != detections;
    return true; // 일단 항상 다시 그리도록 설정
  }
}
*/