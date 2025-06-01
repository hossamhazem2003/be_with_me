import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:just_audio/just_audio.dart';

class VoiceChatScreen extends StatefulWidget {
  final String targetUserId;
  final bool isCaller;

  const VoiceChatScreen({
    super.key,
    required this.targetUserId,
    required this.isCaller,
  });

  @override
  _VoiceChatScreenState createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late HubConnection _hubConnection;
  final String _serverUrl = "https://bewtihme-001-site1.jtempurl.com/callHub";

  bool _isListening = false;
  String _text = 'اضغط على الزر وابدأ التحدث';
  bool _speechReady = false;
  bool _isSending = false;
  late String _senderId;
  bool _callActive = false;
  bool _connectionEstablished = false;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    print('[INIT] VoiceChatScreen initialized');
    _senderId = SharedPreferencesManager.getUserId()!;
    print('[USER] Current user ID: $_senderId');
    print('[CALL] Target user ID: ${widget.targetUserId}');
    print('[ROLE] Is caller: ${widget.isCaller}');

    _initSpeech();
    _initSignalR();
  }

  void _initSpeech() async {
    print('[SPEECH] Initializing speech recognition...');
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          print('[SPEECH STATUS] $status');
          if (status == 'done' && _isListening) {
            _startListening();
          }
        },
      );
      print('[SPEECH] Initialization result: $_speechReady');
      setState(() {});
    } catch (e) {
      print('[SPEECH ERROR] $e');
      setState(() => _text = 'تعذر تهيئة التعرف الصوتي');
    }
  }

  Future<String> _getAuthToken() async {
    // استرجاع التوكن من مكان تخزينه (مثل SharedPreferences)
    final token = await SharedPreferencesManager.getToken();
    return token!;
  }

  Future<void> _initSignalR() async {
    print('[SIGNALR] Initializing SignalR connection to $_serverUrl');
    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(
        _serverUrl,
        options: HttpConnectionOptions(
          accessTokenFactory: () => _getAuthToken(), // إضافة مصنع التوكن
        ),
      )
          .withAutomaticReconnect()
          .build();

      // إصلاح معالجات الأحداث لتكون من نوع void
      _hubConnection.onclose(({Exception? error}) {
        print('[SIGNALR] Connection closed. Error: $error');
        if (mounted) {
          setState(() {
            _connectionEstablished = false;
            _callActive = false;
          });
        }
      });

      _hubConnection.onreconnecting(({Exception? error}) {
        print('[SIGNALR] Reconnecting... Error: $error');
      });

      _hubConnection.onreconnected(({String? connectionId}) {
        print('[SIGNALR] Reconnected. Connection ID: $connectionId');
        if (mounted) {
          setState(() => _connectionEstablished = true);
        }
      });

      // تسجيل معالجات الأحداث
      _hubConnection.on("IncomingCall", (arguments) => _handleIncomingCall(arguments));
      _hubConnection.on("CallAccepted", (arguments) => _handleCallAccepted(arguments));
      _hubConnection.on("ReceiveVoiceCall", (arguments) => _handleReceivedMessage(arguments));

      print('[SIGNALR] Starting connection...');
      await _hubConnection.start();

      print('[SIGNALR] Connection state: ${_hubConnection.state}');
      print('[SIGNALR] Connection ID: ${_hubConnection.connectionId}');

      if (mounted) {
        setState(() {
          _connectionEstablished = true;
          _initializing = false;
        });
      }

      if (widget.isCaller) {
        print('[CALL] Initiating call to ${widget.targetUserId}');
        try {
          await _hubConnection.invoke("InitiateCall", args: [widget.targetUserId]);
          print('[CALL] InitiateCall invoked successfully');
        } catch (e) {
          print('[CALL ERROR] Failed to initiate call: $e');
          if (mounted) {
            setState(() => _text = 'فشل بدء المكالمة: $e');
          }
        }
      }
    } catch (e) {
      print('[SIGNALR ERROR] Connection failed: $e');
      if (mounted) {
        setState(() {
          _text = 'تعذر الاتصال بالخادم: ${e.toString()}';
          _initializing = false;
        });
      }
    }
  }

// تعديل معالجات الأحداث لتعمل بشكل صحيح
  void _handleIncomingCall(List<dynamic>? args) {
    print('[CALL] Incoming call received with args: $args');
    if (args != null && args.length == 1) {
      final callerId = args[0] as String;
      print('[CALL] Call from: $callerId');
      if (mounted) {
        setState(() {
          _text = 'مكالمة واردة من $callerId';
        });
      }
      _showIncomingCallDialog(callerId);
    }
  }

  void _handleCallAccepted(List<dynamic>? args) {
    print('[CALL] Call accepted with args: $args');
    if (args != null && args.length == 1) {
      final acceptorId = args[0] as String;
      print('[CALL] Accepted by: $acceptorId');
      if (mounted) {
        setState(() {
          _callActive = true;
          _text = 'تم قبول المكالمة من $acceptorId';
        });
      }
    }
  }

  void _handleReceivedMessage(List<dynamic>? args) {
    print('[MESSAGE] Received message with args: $args');
    if (args != null && args.length == 1) {
      final message = args[0] as String;
      print('[MESSAGE] Content: $message');
      if (mounted) {
        setState(() {
          _text = "رسالة صوتية: $message";
        });
      }
    }
  }


  Future<void> _showIncomingCallDialog(String callerId) async {
    print('[UI] Showing incoming call dialog');
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('مكالمة واردة'),
        content: Text('تلقيت مكالمة من $callerId'),
        actions: [
          TextButton(
            onPressed: () {
              print('[CALL] Call rejected');
              Navigator.pop(context);
              _rejectCall(callerId);
            },
            child: const Text('رفض'),
          ),
          TextButton(
            onPressed: () {
              print('[CALL] Call accepted');
              Navigator.pop(context);
              _acceptCall(callerId);
            },
            child: const Text('قبول'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptCall(String callerId) async {
    print('[CALL] Accepting call from $callerId');
    try {
      await _hubConnection.invoke("AcceptCall", args: [callerId]);
      print('[CALL] AcceptCall invoked successfully');
      setState(() {
        _callActive = true;
        _text = 'تم قبول المكالمة، يمكنك التحدث الآن';
      });
    } catch (e) {
      print('[CALL ERROR] Failed to accept call: $e');
      setState(() {
        _text = 'خطأ في قبول المكالمة';
      });
    }
  }

  Future<void> _rejectCall(String callerId) async {
    print('[CALL] Rejecting call from $callerId');
    setState(() {
      _text = 'تم رفض المكالمة';
    });
  }

  Future<void> _startListening() async {
    print('[SPEECH] Starting listening...');
    if (!_speechReady || !_callActive) {
      print('[SPEECH] Cannot start listening - Speech ready: $_speechReady, Call active: $_callActive');
      return;
    }

    setState(() {
      _isListening = true;
      _text = 'استمع...';
    });

    await _speech.listen(
      onResult: (result) {
        print('[SPEECH] Recognition result: ${result.recognizedWords}');
        setState(() {
          if (result.recognizedWords.isNotEmpty) {
            _text = result.recognizedWords;
          }
        });
      },
      listenFor: const Duration(days: 1),
      pauseFor: const Duration(days: 1),
      cancelOnError: false,
      partialResults: true,
      onSoundLevelChange: (level) => print('[SPEECH] Sound level: $level'),
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _stopListening() async {
    print('[SPEECH] Stopping listening...');
    if (!_speechReady) return;

    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _sendVoiceMessage() async {
    print('[MESSAGE] Attempting to send message...');
    if (_text.isEmpty || _text == 'اضغط على الزر وابدأ التحدث') {
      print('[MESSAGE] No text to send');
      setState(() => _text = 'لا يوجد نص لإرساله');
      return;
    }

    if (!_callActive) {
      print('[MESSAGE] Call is not active');
      setState(() => _text = 'يجب أن تكون المكالمة نشطة لإرسال الرسائل');
      return;
    }

    setState(() => _isSending = true);

    try {
      print('[MESSAGE] Sending: $_text to ${widget.targetUserId}');
      await _hubConnection.invoke(
        "SendPrivateVoiceCall",
        args: [widget.targetUserId, _text],
      );

      print('[MESSAGE] Sent successfully');
      setState(() {
        _text = 'تم إرسال الرسالة بنجاح';
      });
    } catch (e) {
      print('[MESSAGE ERROR] $e');
      setState(() => _text = 'خطأ في الإرسال: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _endCall() async {
    print('[CALL] Ending call...');
    try {
      await _hubConnection.invoke("EndCall", args: [widget.targetUserId]);
      print('[CALL] Ended successfully');
    } catch (e) {
      print('[CALL ERROR] Failed to end call: $e');
    }
    setState(() {
      _callActive = false;
      _text = 'تم إنهاء المكالمة';
    });
  }

  Future<void> _stopEverything() async {
    print('[CLEANUP] Stopping everything...');
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
    if (_callActive) {
      await _endCall();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[UI] Building widget - Call active: $_callActive, Connection: $_connectionEstablished');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_callActive ? 'مكالمة نشطة' : 'بدء المكالمة'),
          actions: [
            if (_callActive)
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _endCall,
              ),
          ],
        ),
        body: _initializing
            ? const Center(child: CircularProgressIndicator())
            : !_connectionEstablished
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تعذر الاتصال بالخادم'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initSignalR,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;

            return Column(
              children: [
                const SizedBox(height: 20),
                // مربع النص
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20.0 : 32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),

                        )],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Text(
                          _text,
                          style: const TextStyle(
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
                      if (_callActive) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isListening ? _stopListening : _startListening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening ? Colors.red : Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_isListening ? Icons.stop : Icons.mic,
                                    size: 24, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  _isListening ? 'إيقاف التسجيل' : 'بدء التسجيل',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSending || _text.isEmpty || !_callActive
                              ? null
                              : _sendVoiceMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSending
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send,
                                  size: 24, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'إرسال الرسالة',
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
      ),
    );
  }

  @override
  void dispose() {
    print('[DISPOSE] Disposing resources...');
    _stopEverything();
    _hubConnection.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}