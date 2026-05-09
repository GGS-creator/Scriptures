import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ScriptureApp());
}

class ScriptureApp extends StatelessWidget {
  const ScriptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scripture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A5C),
          background: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Times New Roman',
      ),
      home: const ScriptureHomePage(),
    );
  }
}

class ScriptureHomePage extends StatefulWidget {
  const ScriptureHomePage({super.key});

  @override
  State<ScriptureHomePage> createState() => _ScriptureHomePageState();
}

class _ScriptureHomePageState extends State<ScriptureHomePage> {
  String _scriptureText = 'Tap "Generate" to receive a verse from the scripture.';
  bool _isLoading = false;
  int _generationId = 0;
  static const Duration _wordDelay = Duration(milliseconds: 150);
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const String _myPcIp = '10.0.0.239';
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/send';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://$_myPcIp:8000/send';
      default:
        return 'http://localhost:8000/send';
    }
  }

  Future<void> _generateVerse() async {
    _generationId++;
    setState(() {
      _isLoading = true;
      _scriptureText = '';
    });

    try {
      final response = await http
          .get(Uri.parse(_backendUrl))
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final verse = data['message'] ?? 'No verse received.';

        await _showVerseWordByWord(verse);
      } else {
        setState(() {
          _scriptureText = 'Error: Could not fetch verse (${response.statusCode}).';
        });
      }
    } on TimeoutException {
      setState(() {
        _scriptureText =
            'Error: The server took too long to respond. Make sure FastAPI is running on port 8000.';
      });
    } catch (e) {
      setState(() {
        _scriptureText = 'Error: Could not connect to server.\n\nDetails: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showVerseWordByWord(String verse) async {
    final currentGeneration = _generationId;
    final words =
        RegExp(r'\S+\s*').allMatches(verse).map((m) => m.group(0)!).toList();

    setState(() {
      _scriptureText = '';
    });

    final buffer = StringBuffer();

    for (final word in words) {
      if (!mounted || currentGeneration != _generationId) return;

      await Future.delayed(_wordDelay);
      if (!mounted || currentGeneration != _generationId) return;

      buffer.write(word);

      setState(() {
        _scriptureText = buffer.toString();
      });

      HapticFeedback.lightImpact();
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _scriptureText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Verse copied to clipboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A3A5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SCRIPTURE',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 3,
            fontFamily: 'Times New Roman',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            color: const Color(0xFF1A3A5C),
            height: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ── Scripture Text Box ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF1A3A5C),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A3A5C).withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scrollable text
                      Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 56),
                          child: SelectableText(
                            _scriptureText,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              height: 1.75,
                              letterSpacing: 0.3,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                        ),
                      ),
                      // Copy button (bottom-right of box)
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: GestureDetector(
                          onTap: _copyText,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3A5C).withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1A3A5C).withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: Color(0xFF1A3A5C),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Copy',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Times New Roman',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Generate Button ──
              SizedBox(
                width: 200,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateVerse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF1A3A5C).withOpacity(0.5),
                    elevation: 3,
                    shadowColor: const Color(0xFF1A3A5C).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Generate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontFamily: 'Times New Roman',
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
