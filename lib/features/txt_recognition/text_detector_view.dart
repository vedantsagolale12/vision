import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:visiontxt/features/txt_recognition/painters/text_detector_painter.dart';
import 'package:visiontxt/widgets/detector_view.dart';

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key});

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView>
    with TickerProviderStateMixin {
  var _script = TextRecognitionScript.latin;
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _slideController.forward();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(safeArea),

          // Main Camera View
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    DetectorView(
                      title: 'Text Detector',
                      customPaint: _customPaint,
                      text: _text,
                      onImage: _processImage,
                      initialCameraLensDirection: _cameraLensDirection,
                      onCameraLensDirectionChanged: (value) =>
                          setState(() => _cameraLensDirection = value),
                    ),

                    // Processing overlay only when busy
                    if (_isBusy)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Processing Image...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Control Panel
          _buildControlPanel(),

          const SizedBox(height: 16),

          // Results Panel
          _buildResultsPanel(),

          SizedBox(height: safeArea.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(EdgeInsets safeArea) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: safeArea.top + 16,
          left: 20,
          right: 20,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VisionTXT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'AI Text Recognition',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _switchCamera,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Recognition Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TextRecognitionScript>(
                value: _script,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade600,
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (TextRecognitionScript? script) {
                  if (script != null) {
                    _changeScript(script);
                  }
                },
                items: TextRecognitionScript.values
                    .map<DropdownMenuItem<TextRecognitionScript>>((script) {
                      return DropdownMenuItem<TextRecognitionScript>(
                        value: script,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _script == script
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(_getScriptDisplayName(script)),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recognized Text',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text?.isNotEmpty == true
                        ? _text!.replaceAll('Recognized text:\n\n', '')
                        : 'Point your camera at text to start recognition...',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: _text?.isNotEmpty == true
                          ? Colors.black87
                          : Colors.grey.shade600,
                      fontStyle: _text?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeScript(TextRecognitionScript script) {
    setState(() {
      _script = script;
      _textRecognizer.close();
      _textRecognizer = TextRecognizer(script: _script);
    });
  }

  void _switchCamera() {
    setState(() {
      _cameraLensDirection = _cameraLensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
  }

  String _getScriptDisplayName(TextRecognitionScript script) {
    switch (script) {
      case TextRecognitionScript.latin:
        return 'English / Latin';
      case TextRecognitionScript.chinese:
        return 'Chinese (中文)';
      case TextRecognitionScript.devanagiri:
        return 'Hindi / Devanagari';
      case TextRecognitionScript.japanese:
        return 'Japanese (日本語)';
      case TextRecognitionScript.korean:
        return 'Korean (한국어)';
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _text = '';
    });

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        _text = recognizedText.text.isNotEmpty
            ? 'Recognized text:\n\n${recognizedText.text}'
            : 'No text detected in the image';
        _customPaint = null;
      }
    } catch (e) {
      _text = 'Error: Unable to process image. Please try again.';
      _customPaint = null;
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }
}
