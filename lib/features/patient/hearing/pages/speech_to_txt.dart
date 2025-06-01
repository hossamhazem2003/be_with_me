import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isListening = false;
  String _text = 'اضغط على الزر وابدأ التحدث';
  bool _speechReady = false;
  bool _isProcessingFile = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          print('Status: $status');
          if (status == 'done' && _isListening) {
            _startListening();
          }
        },
      );
      setState(() {});
    } catch (e) {
      setState(() => _text = 'تعذر تهيئة التعرف الصوتي');
    }
  }

  Future<void> _startListening() async {
    if (!_speechReady) return;

    setState(() {
      _isListening = true;
      _text = 'استمع...';
    });

    await _speech.listen(
      onResult: (result) => setState(() {
        if (result.recognizedWords.isNotEmpty) {
          _text = result.recognizedWords;
        }
      }),
      listenFor: Duration(days: 1),
      pauseFor: Duration(days: 1),
      cancelOnError: false,
      partialResults: true,
      onSoundLevelChange: (level) => print('مستوى الصوت: $level'),
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _stopListening() async {
    if (!_speechReady) return;

    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _pickAndProcessAudioFile() async {
    setState(() {
      _isProcessingFile = true;
      _text = 'جاري معالجة الملف...';
    });

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        File audioFile = File(file.path!);

        if (!await audioFile.exists()) {
          setState(() => _text = 'الملف غير موجود');
          return;
        }

        if (await audioFile.length() == 0) {
          setState(() => _text = 'الملف فارغ');
          return;
        }

        if (_audioPlayer.playing) {
          await _audioPlayer.stop();
        }

        await _audioPlayer.setFilePath(audioFile.path);
        await _audioPlayer.play();

        if (!await _speech.initialize()) {
          setState(() => _text = 'فشل في تهيئة التعرف على الكلام');
          return;
        }

        await _speech.listen(
          onResult: (result) => setState(() {
            if (result.recognizedWords.isNotEmpty) {
              _text = result.recognizedWords;
            }
          }),
          listenFor: Duration(days: 1),
          pauseFor: Duration(days: 1),
          cancelOnError: false,
          partialResults: true,
          onSoundLevelChange: (level) => print('مستوى الصوت: $level'),
          listenMode: stt.ListenMode.dictation,
        );
      } else {
        setState(() => _text = 'لم يتم اختيار ملف');
      }
    } catch (e) {
      setState(() => _text = 'حدث خطأ أثناء معالجة الملف: $e');
    } finally {
      setState(() => _isProcessingFile = false);
    }
  }

  Future<void> _stopEverything() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 600;

          return Column(
            children: [
              SizedBox(height: 20),
              // مربع النص
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20.0 : 32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        _text,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // الأزرار في الأسفل
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20.0 : 32.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            _isListening ? _stopListening : _startListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red
                              : BeWithMeColors.mainColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isListening ? Icons.stop : Icons.mic,
                                size: 24, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              _isListening ? 'إيقاف التسجيل' : 'بدء التسجيل',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            _isProcessingFile ? null : _pickAndProcessAudioFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BeWithMeColors.mainColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessingFile
                            ? CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.audio_file,
                                      size: 24, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'اختيار ملف صوتي',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    _stopEverything();
    _audioPlayer.dispose();
    super.dispose();
  }
}
