import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';

class RealTimeObjectDetection extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RealTimeObjectDetection({required this.cameras, Key? key})
      : super(key: key);

  @override
  _RealTimeObjectDetectionState createState() =>
      _RealTimeObjectDetectionState();
}

class _RealTimeObjectDetectionState extends State<RealTimeObjectDetection> {
  CameraController? _controller;
  bool isModelLoaded = false;
  List<dynamic>? recognitions;
  int imageHeight = 0;
  int imageWidth = 0;
  int _frameCount = 0;
  bool _isProcessing = false;
  bool _isDisposed = false;
  FlutterTts flutterTts = FlutterTts();
  Map<String, double> knownObjectSizes = {
    'person': 170.0, // متوسط طول الشخص بالسم
    'car': 150.0, // متوسط ارتفاع السيارة بالسم
    'chair': 50.0, // ارتفاع الكرسي بالسم
    'cup': 15.0, // ارتفاع الكوب بالسم
    'bottle': 25.0, // ارتفاع الزجاجة بالسم
    'phone': 15.0, // طول الهاتف بالسم
  };
  String lastSpokenText = '';
  DateTime lastSpokenTime = DateTime.now();
  double focalLength = 1000.0; // يجب معايرة هذه القيمة حسب كاميرا الجهاز
  bool isWarningActive = false;
  bool showControls = true; // لإظهار وإخفاء أزرار التحكم

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTts();
      _initialize();
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage('ar-SA'); // اللغة العربية
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _initialize() async {
    try {
      await loadModel();
      await initializeCamera(null);
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _closeAllResources();
    super.dispose();
  }

  Future<void> _closeAllResources() async {
    try {
      if (_controller != null) {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
      }
      await Tflite.close();
      await flutterTts.stop();
    } catch (e) {
      debugPrint('Error closing resources: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      // تأكد من أن الملفات موجودة في المسار الصحيح
      String? res = await Tflite.loadModel(
        model: 'assets/yolov8n.tflite', // تأكد من المسار الصحيح
        labels: 'assets/labelmap.txt', // تأكد من المسار الصحيح
        numThreads: 2,
        isAsset: true,
        useGpuDelegate: false,
      );

      debugPrint('Model loading result: $res');

      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          isModelLoaded = res == 'success';
        });
      }

      if (!isModelLoaded) {
        debugPrint('Failed to load model. Check model files and paths.');
      }
    } catch (e) {
      debugPrint('Failed to load model: $e');
      if (mounted) {
        setState(() {
          isModelLoaded = false;
        });
      }
    }
  }

  Future<void> toggleCamera() async {
    if (_isProcessing || _controller == null) return;

    _isProcessing = true;
    try {
      final lensDirection = _controller!.description.lensDirection;
      CameraDescription? newDescription;

      if (lensDirection == CameraLensDirection.front) {
        newDescription = widget.cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.back);
      } else {
        newDescription = widget.cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.front);
      }

      if (newDescription != null) {
        await initializeCamera(newDescription);
      }
    } catch (e) {
      debugPrint('Camera switch error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> initializeCamera(CameraDescription? description) async {
    try {
      if (_controller != null) {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
      }

      final newController = CameraController(
        description ?? widget.cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await newController.initialize();

      if (_isDisposed || !mounted) return;

      setState(() {
        _controller = newController;
      });

      newController.startImageStream((CameraImage image) {
        if (_isDisposed) return;

        _frameCount++;
        if (isModelLoaded && !_isProcessing && _frameCount % 3 == 0) {
          _runModel(image);
        }
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  double _calculateDistance({
    required double knownObjectHeight,
    required double objectHeightInImage,
    required double focalLength,
  }) {
    return (knownObjectHeight * focalLength) / objectHeightInImage;
  }

  Future<void> _speak(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('Text-to-speech error: $e');
    }
  }

  Future<void> _runModel(CameraImage image) async {
    if (image.planes.isEmpty || _isProcessing || _isDisposed || !isModelLoaded)
      return;

    _isProcessing = true;

    try {
      var results = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        model: 'SSDMobileNet',
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 1,
        threshold: 0.4,
      );

      debugPrint(
          'Model inference results: ${results?.length} objects detected');

      if (_isDisposed || !mounted) return;

      if (results != null) {
        setState(() {
          recognitions = results;
          imageHeight = image.height;
          imageWidth = image.width;
        });

        _processRecognitions(results);
      }
    } catch (e) {
      debugPrint('Model inference error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _processRecognitions(List<dynamic> results) {
    if (results.isEmpty) return;

    final detection = results.first;
    final objectName = detection['detectedClass'];
    final confidence = detection['confidenceInClass'];
    final rect = detection['rect'];

    if (confidence < 0.5) return;

    if (knownObjectSizes.containsKey(objectName)) {
      final objectHeightInImage = rect['h'] * imageHeight;
      final distanceInCm = _calculateDistance(
        knownObjectHeight: knownObjectSizes[objectName]!,
        objectHeightInImage: objectHeightInImage,
        focalLength: focalLength,
      );

      final distanceInMeters = distanceInCm / 100;
      final textToSpeak = _generateSpeechText(objectName, distanceInMeters);

      if (textToSpeak != lastSpokenText ||
          DateTime.now().difference(lastSpokenTime).inSeconds > 5) {
        _speak(textToSpeak);
        lastSpokenText = textToSpeak;
        lastSpokenTime = DateTime.now();

        // التحكم في حالة التحذير
        setState(() {
          isWarningActive = distanceInMeters <= 2.0;
        });
      }
    }
  }

  String _generateSpeechText(String objectName, double distanceInMeters) {
    if (distanceInMeters <= 2.0) {
      return 'تحذير هناك! $objectName';
    } else {
      return 'تحذير هناك! $objectName';
    }
  }

  void _toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: BeWithMeColors.mainColor,
              strokeWidth: 4,
            ),
            SizedBox(height: 20),
            Text(
              'جاري تهيئة الكاميرا...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (!isModelLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'تعذر تحميل النموذج',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loadModel,
              style: ElevatedButton.styleFrom(
                backgroundColor: BeWithMeColors.mainColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. شاشة الكاميرا بحجم كامل
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),

          // 2. صناديق العناصر المكتشفة
          if (recognitions != null)
            BoundingBoxes(
              recognitions: recognitions!,
              previewH: imageHeight.toDouble(),
              previewW: imageWidth.toDouble(),
              screenH: MediaQuery.of(context).size.height,
              screenW: MediaQuery.of(context).size.width,
              isWarning: isWarningActive,
            ),

          // 3. تحذير في حالة وجود جسم قريب
          if (isWarningActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تحذير! هناك جسم قريب',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. معلومات حالة التطبيق في الأعلى
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: AnimatedOpacity(
              opacity: showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isModelLoaded ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isModelLoaded ? 'نشط' : 'غير نشط',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. أزرار التحكم في الأسفل
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MaterialButton(
                          onPressed: toggleCamera,
                          color: Colors.teal,
                          textColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: const CircleBorder(),
                          child: const Icon(Icons.cameraswitch, size: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. إظهار المسافة للأجسام المكتشفة
          if (recognitions != null && recognitions!.isNotEmpty)
            Positioned(
              bottom: showControls ? 100 : 30,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isWarningActive
                          ? Colors.red.withOpacity(0.7)
                          : Colors.teal.withOpacity(0.7),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isWarningActive
                                ? Icons.priority_high
                                : Icons.visibility,
                            color: isWarningActive ? Colors.red : Colors.teal,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${recognitions!.first["detectedClass"]}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الدقة: ${(recognitions!.first["confidenceInClass"] * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BoundingBoxes extends StatelessWidget {
  final List<dynamic> recognitions;
  final double previewH;
  final double previewW;
  final double screenH;
  final double screenW;
  final bool isWarning;

  const BoundingBoxes({
    required this.recognitions,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
    required this.isWarning,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: recognitions.map((rec) {
        final rect = rec["rect"];
        final x = rect["x"] * screenW;
        final y = rect["y"] * screenH;
        final w = rect["w"] * screenW;
        final h = rect["h"] * screenH;
        final confidence = (rec["confidenceInClass"] * 100).toStringAsFixed(0);
        final label = rec["detectedClass"];

        final color = isWarning ? Colors.red : Colors.teal;
        final shadowColor = isWarning
            ? Colors.red.withOpacity(0.3)
            : Colors.teal.withOpacity(0.3);

        return Positioned(
          left: x,
          top: y,
          width: w,
          height: h,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isWarning ? 12 : 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 4),
                      Text(
                        "$label",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    "$confidence%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
