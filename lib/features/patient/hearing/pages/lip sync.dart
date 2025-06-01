import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

class SyncSoTab extends StatefulWidget {
  const SyncSoTab({super.key});

  @override
  State<SyncSoTab> createState() => _SyncSoTabState();
}

class _SyncSoTabState extends State<SyncSoTab>
    with AutomaticKeepAliveClientMixin {
  final String apiUrl = "https://api.sync.so/v2/generate";
  final String apiKey =
      'sk-ZgUH116bS_WU4luHBiaRfw.GWdZyMHAAAxOd42PP50Hj_njk_u5RCR8';
  final String fixedVideoUrl =
      "https://synchlabs-public.s3.us-west-2.amazonaws.com/david_demo_shortvid-03a10044-7741-4cfc-816a-5bccd392d1ee.mp4";
  final String audioUploadUrl =
      "https://bewtihme-001-site1.jtempurl.com/api/Audio/upload";
  final String cookie =
      ".AspNetCore.Identity.Application=CfDJ8P94FN5U-TpIgi68x8iPM903HKDhAeulKFTqPAkj9bJu2HPcvbVyNzUEQJdN7DSxMSseE02BaRxJMCkqwa_M-2KrCGS475UGzgFUlVkxGGY2PopMYK9qPOnah2NnPdBjuJveXasHeu2plCVCwFEZ2U9-WA_bLiUrnorY2_8d3khp1VKXE2Lpadg4GlvyBOEQcF_8gkw40Q85gcjGS_jPldoYZPu9CwPyNug0KLMMturIXg4_CvC9IdVI8cbOeAGewG1fykI1cmVrv-5UBaf2CRYSuFX6wlSgGOtkyJp84gfHv85xeW9C8W6vi95Rp9E8mrPUOqtlp0qJkGPqknV1prMEu91QhmYO6eIWKAiJCWl3MyIsRnqu6ezFGNQqnOvWu3kwdz1ukw2b_AF7ekfphu7rQzq6U-GHotsEcy8K2XPknJQ6u5QwJ09kX6lmyggnQOdurrqX-euXLTTxVyi1VDLgZaWcqaU_5TbNG_Dgs_1Pbua3EeGyOqwfFoeYKz6JtiIxHqJwek0NtzldVIEG5VuS01vhJ--IL3JHoUPKUSnl6uaLgug5kR7_OwEpS-_hsDVKEbaPppQhxS_fviLBmGV_blTd1LfoavzEs7kFbnranLapdbPBsK81Cz1YOM-8ugI-s4hJ-rRze7bmhJs5E1Vg9TcO-ubkZqAZxTVeYcAiH0VtP6ZaHrxAMFaBvFZJJ7sf69QETDoSuiYtUEKTHdaDMA5sqBNCltVawIUC4Xau63hwq-wwup6RQqCY7x8FzEHYqJAix6RhVY41qJX_uxcRNm9LPyzVfoxprMO2ptvVKbWFxZAQ5ZkOIzPcm54EnT4_kOr04M6Yyf6RU6idKos";

  // Video and audio controllers
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State variables
  bool _isPlayingVideo = false;
  bool _isLoading = false;
  bool _isConvertingText = false;
  bool _isPlayingAudio = false;
  bool _isAudioReady = false;
  bool _isUploadingAudio = false;
  String _currentLanguage = 'ar-SA'; // Changed default to Arabic

  // API response variables
  String _status = "IDLE";
  String _outputUrl = "";
  double? _outputDuration;
  String? _error;
  String _id = "";
  DateTime? _createdAt;
  String _model = "";

  // Text and audio handling
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  String? _audioFilePath;
  String? _uploadedAudioUrl;

  // Logging system
  final List<String> _logs = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initVideoController();
    _initTts();
    _initAudioPlayer();
    _addLog("التطبيق جاهز للاستخدام");
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    _textController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _initVideoController() {
    _videoController = VideoPlayerController.network(fixedVideoUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.addListener(_videoListener);
      });
  }

  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((playerState) {
      setState(() {
        _isPlayingAudio = playerState.playing;
      });
    });

    _audioPlayer.positionStream.listen((_) {
      if (_audioPlayer.duration != null &&
          _audioPlayer.position >= _audioPlayer.duration!) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    });
  }

  Future<void> _initTts() async {
    try {
      // Get available voices
      var voices = await _flutterTts.getVoices;
      _addLog("Available voices: ${voices.length}");

      // Set language based on current selection
      await _flutterTts.setLanguage(_currentLanguage);

      // Set other TTS parameters
      await _flutterTts.setPitch(1.0); // Higher pitch for male voice
      await _flutterTts.setSpeechRate(0.5);

      // Try to find a male voice for the selected language
      if (_currentLanguage == 'ar-SA') {
        // Try to find a specific Arabic male voice
        var arabicMaleVoice = voices.firstWhere(
          (voice) =>
              voice["locale"].toString().toLowerCase() == "ar-sa" &&
              (voice["name"].toString().toLowerCase().contains("male") ||
                  voice["name"].toString().toLowerCase().contains("majed")),
          orElse: () => null,
        );

        if (arabicMaleVoice != null) {
          await _flutterTts.setVoice(arabicMaleVoice);
          _addLog("Set Arabic male voice: ${arabicMaleVoice['name']}");
        } else {
          // Fallback to any Arabic voice
          var anyArabicVoice = voices.firstWhere(
            (v) => v["locale"].toString().toLowerCase().contains("ar"),
            orElse: () => null,
          );

          if (anyArabicVoice != null) {
            await _flutterTts.setVoice(anyArabicVoice);
            _addLog("Set Arabic voice: ${anyArabicVoice['name']}");
          }
        }
      } else {
        // For English, try to find a male voice
        var englishMaleVoice = voices.firstWhere(
          (voice) =>
              voice["locale"].toString().toLowerCase().contains("en") &&
              (voice["name"].toString().toLowerCase().contains("male") ||
                  voice["name"].toString().toLowerCase().contains("en-us") ||
                  voice["name"].toString().toLowerCase().contains("en-gb")),
          orElse: () => null,
        );

        if (englishMaleVoice != null) {
          await _flutterTts.setVoice(englishMaleVoice);
          _addLog("Set English male voice: ${englishMaleVoice['name']}");
        } else {
          // Fallback to any English voice
          var anyEnglishVoice = voices.firstWhere(
            (v) => v["locale"].toString().toLowerCase().contains("en"),
            orElse: () => null,
          );

          if (anyEnglishVoice != null) {
            await _flutterTts.setVoice(anyEnglishVoice);
            _addLog("Set English voice: ${anyEnglishVoice['name']}");
          }
        }
      }

      // Additional settings to ensure male voice
      await _flutterTts.setPitch(0.8); // Lower pitch for more masculine sound
      await _flutterTts.setSpeechRate(0.45); // Slightly slower rate

      _addLog("TTS initialized for $_currentLanguage with male voice settings");
    } catch (e) {
      _addLog("TTS initialization error: $e", isError: true);
    }
  }

  void _videoListener() {
    if (_videoController?.value.isPlaying != _isPlayingVideo) {
      setState(() {
        _isPlayingVideo = _videoController?.value.isPlaying ?? false;
      });
    }
  }

  void _addLog(String message, {bool isError = false}) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = "[$timestamp] ${isError ? 'ERROR: ' : ''}$message";
    _logs.add(logEntry);
    log(logEntry);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _toggleLanguage() async {
    setState(() {
      _currentLanguage = _currentLanguage == 'en-US' ? 'ar-SA' : 'en-US';
    });
    await _initTts();
    _showSnackBar(_currentLanguage == 'en-US'
        ? 'Language set to English'
        : 'تم تغيير اللغة إلى العربية');
  }

  Future<void> _convertTextToAudio() async {
    if (_textController.text.isEmpty) {
      _showSnackBar(
          _currentLanguage == 'en-US'
              ? "Please enter text first"
              : "الرجاء إدخال النص أولاً",
          isError: true);
      return;
    }

    setState(() {
      _isConvertingText = true;
      _isAudioReady = false;
    });

    try {
      _addLog("Starting text to audio conversion...");

      // First try using an API service that supports Arabic text
      await _useApiTtsService();
    } catch (e) {
      _addLog("Error in primary TTS method: $e", isError: true);

      try {
        // Try another service as fallback
        _addLog("Trying alternative TTS service...");
        await _useAlternativeTtsService();
      } catch (fallbackError) {
        _addLog("All TTS methods failed: $fallbackError", isError: true);
        _showSnackBar(
            _currentLanguage == 'en-US'
                ? "Could not convert text to speech"
                : "تعذر تحويل النص إلى كلام",
            isError: true);
      }
    } finally {
      setState(() => _isConvertingText = false);
    }
  }

  Future<void> _useApiTtsService() async {
    _addLog("Using API TTS service with ElevenLabs...");

    try {
      // Use a more robust TTS API that supports Arabic and other languages
      final url = Uri.parse(
          'https://api.elevenlabs.io/v1/text-to-speech/EXAVITQu4vr4xnSDxMaL');

      // Choose a voice ID based on language
      String voiceId = _currentLanguage.startsWith('ar')
          ? 'EXAVITQu4vr4xnSDxMaL' // Arabic male voice ID
          : '21m00Tcm4TlvDq8ikWAM'; // English male voice ID

      _addLog("Using voice ID: $voiceId for language: $_currentLanguage");

      // Convert request with appropriate settings
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key':
              '48bf6c4cf4bc15ed606c9b5d07b2a80a', // Replace with your own key
        },
        body: json.encode({
          'text': _textController.text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
            'style': 0.0,
            'use_speaker_boost': true
          }
        }),
      );

      if (response.statusCode == 200) {
        _addLog("Received audio data: ${response.bodyBytes.length} bytes");

        if (response.bodyBytes.length < 1000) {
          throw Exception(
              "Received audio file too small (${response.bodyBytes.length} bytes)");
        }

        // Save the audio data to a file in the cache directory
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFilePath = '${directory.path}/audio_$timestamp.mp3';

        _addLog("Saving audio to: $tempFilePath");

        final file = File(tempFilePath);
        await file.writeAsBytes(response.bodyBytes);

        _audioFilePath = tempFilePath;

        // Double check file exists and has content
        if (await file.exists()) {
          int fileSize = await file.length();
          _addLog("Verified file created with size: $fileSize bytes");

          if (fileSize < 1000) {
            throw Exception("Saved file too small: $fileSize bytes");
          }
        } else {
          throw Exception("Failed to create audio file");
        }

        // Upload the audio bytes directly from the HTTP response
        await _uploadAudioBytes(response.bodyBytes);

        setState(() => _isAudioReady = true);
      } else {
        _addLog(
            "ElevenLabs API error: ${response.statusCode} - ${response.body}",
            isError: true);
        throw Exception("ElevenLabs API error: ${response.statusCode}");
      }
    } catch (e) {
      _addLog("ElevenLabs error: $e", isError: true);
      throw e; // Let the calling method handle fallbacks
    }
  }

  // Alternative TTS service as fallback (supports both Arabic and English)
  Future<void> _useAlternativeTtsService() async {
    try {
      _addLog("Using Google Translate TTS API...");

      // Encode and prepare text
      String text = _textController.text;
      if (text.length > 200) {
        text = text.substring(0, 200); // Truncate to avoid URL length issues
        _addLog("Text truncated to 200 chars for Google TTS API");
      }

      // URL encode the text
      final encodedText = Uri.encodeComponent(text);

      // Determine language code for TTS
      String langCode = _currentLanguage.startsWith('ar') ? 'ar' : 'en';

      // Format Google Translate TTS URL with appropriate language
      final googleTtsUrl = Uri.parse(
          'https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedText&tl=$langCode&client=tw-ob');

      // Add a fake user agent to avoid blocking
      final response = await http.get(googleTtsUrl, headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'
      });

      if (response.statusCode == 200) {
        _addLog("Google TTS returned ${response.bodyBytes.length} bytes");

        if (response.bodyBytes.length < 1000) {
          throw Exception("Google TTS returned too small audio file");
        }

        // Save to temporary directory
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFilePath =
            '${directory.path}/audio_google_$timestamp.mp3'; // Google returns MP3

        final file = File(tempFilePath);
        await file.writeAsBytes(response.bodyBytes);

        _audioFilePath = tempFilePath;
        _addLog("Saved Google TTS audio to: $tempFilePath");

        // Upload the audio bytes
        await _uploadAudioBytes(response.bodyBytes);

        setState(() => _isAudioReady = true);
      } else {
        throw Exception("Google TTS API error: ${response.statusCode}");
      }
    } catch (e) {
      _addLog("Google TTS error: $e", isError: true);
      throw e;
    }
  }

  Future<void> _uploadAudioBytes(Uint8List audioBytes) async {
    if (audioBytes.length < 1000) {
      _addLog("Audio data too small to upload: ${audioBytes.length} bytes",
          isError: true);
      throw Exception("Audio data too small to be valid");
    }

    setState(() {
      _isUploadingAudio = true;
    });

    try {
      _addLog("Uploading audio file to server... (${audioBytes.length} bytes)");

      // Create the MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(audioUploadUrl));

      // Add necessary headers
      request.headers['Accept'] = '*/*';
      request.headers['Host'] = 'bewtihme-001-site1.jtempurl.com';
      request.headers['Connection'] = 'keep-alive';
      request.headers['Cookie'] = cookie;

      // Add the file with proper content type
      request.files.add(http.MultipartFile.fromBytes(
        'File', // Make sure this field name matches what the server expects
        audioBytes,
        filename: 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
        contentType: MediaType('audio', 'mp3'),
      ));

      // Log the request details
      _addLog("Request URL: ${request.url}");
      _addLog("Request headers: ${request.headers}");

      // Send the request
      _addLog("Sending upload request...");
      var streamedResponse = await request.send();

      // Read the response
      var responseBody = await streamedResponse.stream.bytesToString();
      _addLog("Upload response status: ${streamedResponse.statusCode}");
      _addLog("Upload response body: $responseBody");

      if (streamedResponse.statusCode == 200) {
        try {
          // Try to parse as JSON first
          Map<String, dynamic> jsonResponse = json.decode(responseBody);
          if (jsonResponse.containsKey('url')) {
            _uploadedAudioUrl = jsonResponse['url'];
            _addLog("Uploaded audio URL (from JSON): $_uploadedAudioUrl");
          } else {
            _uploadedAudioUrl = responseBody;
            _addLog("Using entire response as URL: $_uploadedAudioUrl");
          }
        } catch (e) {
          // If not valid JSON, try to extract a URL
          final urlPattern = RegExp(r'https?://[^\s"]+');
          final match = urlPattern.firstMatch(responseBody);
          if (match != null) {
            _uploadedAudioUrl = match.group(0);
            _addLog("Extracted URL from response: $_uploadedAudioUrl");
          } else {
            // If no URL found, use the response as is
            _uploadedAudioUrl = responseBody;
            _addLog("Using response as URL: $_uploadedAudioUrl");
          }
        }
      } else {
        throw Exception(
            'Upload failed: ${streamedResponse.statusCode} - $responseBody');
      }
    } catch (e) {
      _addLog("Error uploading audio file: $e", isError: true);
      throw e;
    } finally {
      setState(() {
        _isUploadingAudio = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (_audioFilePath == null || !_isAudioReady) return;

    try {
      if (_isPlayingAudio) {
        await _audioPlayer.stop();
        setState(() {
          _isPlayingAudio = false;
        });
      } else {
        await _audioPlayer
            .setAudioSource(AudioSource.uri(Uri.file(_audioFilePath!)));
        await _audioPlayer.play();
        setState(() {
          _isPlayingAudio = true;
        });
      }
    } catch (e) {
      _addLog("Error playing audio: $e", isError: true);
      _showSnackBar(
          _currentLanguage == 'en-US'
              ? 'Error playing audio'
              : 'خطأ في تشغيل الصوت',
          isError: true);
    }
  }

  Future<void> _generateSync() async {
    if (!_isAudioReady || _audioFilePath == null || _uploadedAudioUrl == null) {
      _addLog("لا يوجد ملف صوتي جاهز أو لم يتم رفعه", isError: true);
      _showSnackBar(
          _currentLanguage == 'en-US'
              ? 'Please convert text to audio and upload first'
              : 'الرجاء تحويل النص إلى صوت ورفعه أولاً',
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _status = "PENDING";
      _error = null;
      _outputUrl = "";
      _videoController?.dispose();
      _videoController = null;
    });

    _addLog("جاري إنشاء الفيديو المتزامن...");

    String audioUrl;

    try {
      // Try to parse as JSON first
      final decoded = jsonDecode(_uploadedAudioUrl!);
      audioUrl = decoded['url'];
      _addLog("Parsed audio URL from JSON: $audioUrl");
    } catch (e) {
      // If not JSON, use as is
      audioUrl = _uploadedAudioUrl!;
      _addLog("Using raw audio URL: $audioUrl");
    }

    _addLog("Audio URL for sync: $audioUrl");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
        body: json.encode({
          "model": "lipsync-1.7.1",
          "input": [
            {
              "url": fixedVideoUrl,
              "type": "video",
              "segments_secs": [[]]
            },
            {"url": audioUrl, "type": "audio"}
          ],
          "options": {
            "pads": [0, 5, 0, 0],
            "sync_mode": "loop",
            "output_format": "mp4"
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _addLog("استجابة API: ${data.toString()}");

        setState(() {
          _id = data['id'] ?? "";
          _createdAt = DateTime.tryParse(data['createdAt'] ?? "");
          _status = data['status'] ?? "PENDING";
          _model = data['model'] ?? "";
          _outputUrl = data['outputUrl'] ?? "";
          _outputDuration = data['outputDuration']?.toDouble();
          _error = data['error'];
        });

        if (_status == "PENDING" || _status == "PROCESSING") {
          _pollStatus();
        } else if (_status == "COMPLETED" && _outputUrl.isNotEmpty) {
          _initializeVideoPlayer();
        }
      } else {
        _addLog("خطأ في API: ${response.statusCode} - ${response.body}",
            isError: true);
        setState(() {
          _status = "ERROR";
          _error = "${response.statusCode} - ${response.body}";
          _isLoading = false;
        });
        _showSnackBar(
            _currentLanguage == 'en-US'
                ? 'API Error: ${response.statusCode}'
                : 'خطأ في الخادم: ${response.statusCode}',
            isError: true);
      }
    } catch (e) {
      _addLog("استثناء أثناء إنشاء الفيديو: $e", isError: true);
      setState(() {
        _status = "ERROR";
        _error = "$e";
        _isLoading = false;
      });
      _showSnackBar(_currentLanguage == 'en-US' ? 'Error: $e' : 'خطأ: $e',
          isError: true);
    }
  }

  Future<void> _pollStatus() async {
    while (_status == "PENDING" || _status == "PROCESSING") {
      await Future.delayed(const Duration(seconds: 2));
      _addLog("جاري التحقق من حالة الفيديو...");

      try {
        final response = await http.get(
          Uri.parse("$apiUrl/$_id"),
          headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _addLog("حالة الفيديو: ${data.toString()}");

          setState(() {
            _status = data['status'] ?? _status;
            _outputUrl = data['outputUrl'] ?? _outputUrl;
            _outputDuration =
                data['outputDuration']?.toDouble() ?? _outputDuration;
            _error = data['error'] ?? _error;
          });

          if (_status == "COMPLETED" && _outputUrl.isNotEmpty) {
            _initializeVideoPlayer();
            setState(() {
              _isLoading = false;
            });
            break;
          } else if (_status == "FAILED") {
            setState(() {
              _isLoading = false;
            });
            break;
          }
        } else {
          _addLog("فشل في التحقق من الحالة: ${response.statusCode}",
              isError: true);
        }
      } catch (e) {
        _addLog("خطأ في التحقق من الحالة: $e", isError: true);
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_outputUrl.isEmpty) return;

    _addLog("جاري تحميل الفيديو...");

    _videoController?.dispose();
    _videoController = VideoPlayerController.network(_outputUrl)
      ..addListener(_videoListener)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
        _addLog("تم تحميل الفيديو بنجاح");
      }).catchError((e) {
        _addLog("فشل في تحميل الفيديو: $e", isError: true);
      });
  }

  void _toggleVideoPlayback() {
    if (_videoController?.value.isPlaying ?? false) {
      _videoController?.pause();
    } else {
      _videoController?.play();
    }
    setState(() {});
  }

  Color _getStatusColor() {
    switch (_status) {
      case "PENDING":
        return Colors.orange;
      case "PROCESSING":
        return Colors.blue;
      case "COMPLETED":
        return Colors.green;
      case "FAILED":
      case "ERROR":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _downloadOutput() {
    _addLog("طلب تحميل الفيديو");
    _showSnackBar(
        _currentLanguage == 'en-US' ? 'Download started' : 'بدأ التحميل');
  }

  void _showLogs() {
    _addLog("عرض سجل الأحداث");
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('سجل الأحداث'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              final log = _logs.reversed.toList()[index];
              return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    log,
                    style: TextStyle(
                      color: log.contains('ERROR') ? Colors.red : Colors.black,
                    ),
                  ));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentLanguage == 'en-US' ? 'Text to Sync' : 'نص للمزامنة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: _toggleLanguage,
                  tooltip: _currentLanguage == 'en-US'
                      ? 'Switch to Arabic'
                      : 'التغيير إلى الإنجليزية',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: _currentLanguage == 'en-US'
                    ? 'Enter text to convert'
                    : 'أدخل النص للتحويل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_isConvertingText || _isUploadingAudio)
                    ? null
                    : _convertTextToAudio,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: BeWithMeColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: (_isConvertingText || _isUploadingAudio)
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Icon(Icons.record_voice_over),
                label: Text((_isConvertingText || _isUploadingAudio)
                    ? (_currentLanguage == 'en-US'
                        ? 'Processing...'
                        : 'جاري المعالجة...')
                    : (_currentLanguage == 'en-US'
                        ? 'Convert to Audio'
                        : 'تحويل إلى صوت')),
              ),
            ),
            const SizedBox(height: 16),
            if (_isAudioReady) ...[
              const Divider(),
              Text(
                _currentLanguage == 'en-US' ? 'Audio Ready' : 'الصوت جاهز',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentLanguage == 'en-US'
                          ? 'Press play to listen'
                          : 'اضغط تشغيل للاستماع',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlayingAudio ? Icons.stop : Icons.play_arrow,
                      color: Colors.blue,
                    ),
                    onPressed: _playAudio,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateSync,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: BeWithMeColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(Icons.sync),
                  label: Text(_isLoading
                      ? (_currentLanguage == 'en-US'
                          ? 'Processing...'
                          : 'جاري المعالجة...')
                      : (_currentLanguage == 'en-US'
                          ? 'Generate Sync'
                          : 'إنشاء مزامنة')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentLanguage == 'en-US' ? 'Status' : 'الحالة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: _showLogs,
                  tooltip:
                      _currentLanguage == 'en-US' ? 'Show logs' : 'عرض السجل',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentLanguage == 'en-US' ? 'Status' : 'الحالة'}: $_status',
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_id.isNotEmpty) ...[
              _buildInfoRow('ID', _id),
              const SizedBox(height: 8),
            ],
            if (_createdAt != null) ...[
              _buildInfoRow(
                  _currentLanguage == 'en-US' ? 'Created At' : 'وقت الإنشاء',
                  _createdAt.toString()),
              const SizedBox(height: 8),
            ],
            if (_model.isNotEmpty) ...[
              _buildInfoRow(
                  _currentLanguage == 'en-US' ? 'Model' : 'النموذج', _model),
              const SizedBox(height: 8),
            ],
            if (_outputDuration != null) ...[
              _buildInfoRow(_currentLanguage == 'en-US' ? 'Duration' : 'المدة',
                  '${_outputDuration!.toStringAsFixed(2)} ${_currentLanguage == 'en-US' ? 'seconds' : 'ثانية'}'),
              const SizedBox(height: 8),
            ],
            if (_error != null) ...[
              const Divider(),
              Text(
                _currentLanguage == 'en-US' ? 'Error:' : 'خطأ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    if (_status != "COMPLETED" || _outputUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentLanguage == 'en-US' ? 'Output Preview' : 'معاينة الناتج',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                    GestureDetector(
                      onTap: _toggleVideoPlayback,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlayingVideo ? Icons.pause : Icons.play_arrow,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _downloadOutput,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.download),
                label: Text(_currentLanguage == 'en-US'
                    ? 'Download Output'
                    : 'تحميل الناتج'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputSection(),
                const SizedBox(height: 16),
                _buildStatusSection(),
                const SizedBox(height: 16),
                _buildVideoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SyncSoTabPage extends StatefulWidget {
  const SyncSoTabPage({Key? key}) : super(key: key);

  @override
  State<SyncSoTabPage> createState() => _SyncSoTabPageState();
}

class _SyncSoTabPageState extends State<SyncSoTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync.so Integration'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Lip Sync', icon: Icon(Icons.sync)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const SyncSoTab(),
          Center(child: Text('History Tab - Coming Soon')),
        ],
      ),
    );
  }
}
