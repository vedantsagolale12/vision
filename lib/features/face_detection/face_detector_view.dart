import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:visiontxt/widgets/detector_view.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView>
    with TickerProviderStateMixin {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true, 
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  List<Face> _detectedFaces = [];
  
  // Detection settings
  bool _enableContours = true;
  bool _enableLandmarks = true;
  bool _enableClassification = true;
  
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

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
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    _slideController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _slideController.dispose();
    _bounceController.dispose();
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
                      title: 'Face Detector',
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Detecting Faces...',
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
          
          // Detection Settings Panel
          _buildDetectionSettings(),
          
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
            colors: [Colors.purple.shade600, Colors.purple.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.face_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'FaceVision',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'AI Face Detection & Analysis',
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
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatsChip('Faces: ${_detectedFaces.length}', Icons.face),
                const SizedBox(width: 12),
                _buildStatsChip(
                  _cameraLensDirection == CameraLensDirection.front 
                      ? 'Front Camera' 
                      : 'Back Camera', 
                  Icons.camera_alt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionSettings() {
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
                Icons.settings_rounded,
                color: Colors.purple.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildToggleOption(
                  'Contours',
                  Icons.gesture_rounded,
                  _enableContours,
                  (value) => _updateDetectorOptions(contours: value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleOption(
                  'Landmarks',
                  Icons.place_rounded,
                  _enableLandmarks,
                  (value) => _updateDetectorOptions(landmarks: value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleOption(
                  'Classification',
                  Icons.analytics_rounded,
                  _enableClassification,
                  (value) => _updateDetectorOptions(classification: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? Colors.purple.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.purple.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: value ? Colors.purple.shade600 : Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: value ? Colors.purple.shade700 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.purple.shade600,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  Icons.analytics_outlined,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detection Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_detectedFaces.isNotEmpty)
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_detectedFaces.length} Face${_detectedFaces.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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
                  child: _detectedFaces.isNotEmpty
                      ? _buildFaceDetails()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face_retouching_off,
                                color: Colors.grey.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No faces detected',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Point camera at faces to analyze',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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

  Widget _buildFaceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _detectedFaces.asMap().entries.map((entry) {
        int index = entry.key;
        Face face = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Face ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFaceAttribute('Confidence', 
                  '${(face.headEulerAngleY! * 100).toStringAsFixed(1)}%'),
              if (face.smilingProbability != null)
                _buildFaceAttribute('Smiling', 
                    '${(face.smilingProbability! * 100).toStringAsFixed(1)}%'),
              if (face.leftEyeOpenProbability != null)
                _buildFaceAttribute('Left Eye Open', 
                    '${(face.leftEyeOpenProbability! * 100).toStringAsFixed(1)}%'),
              if (face.rightEyeOpenProbability != null)
                _buildFaceAttribute('Right Eye Open', 
                    '${(face.rightEyeOpenProbability! * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFaceAttribute(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _updateDetectorOptions({
    bool? contours,
    bool? landmarks,
    bool? classification,
  }) {
    setState(() {
      _enableContours = contours ?? _enableContours;
      _enableLandmarks = landmarks ?? _enableLandmarks;
      _enableClassification = classification ?? _enableClassification;
    });
    
    // Recreate detector with new options
    _faceDetector.close();
  }

  void _switchCamera() {
    setState(() {
      _cameraLensDirection = _cameraLensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    
    setState(() {
      _isBusy = true;
      _text = '';
    });

    try {
      final faces = await _faceDetector.processImage(inputImage);
      _detectedFaces = faces;
      
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = FaceDetectorPainter(
          faces,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        String text = 'Faces detected: ${faces.length}\n\n';
        for (int i = 0; i < faces.length; i++) {
          final face = faces[i];
          text += 'Face ${i + 1}:\n';
          text += 'Bounds: ${face.boundingBox}\n';
          if (face.smilingProbability != null) {
            text += 'Smiling: ${(face.smilingProbability! * 100).toStringAsFixed(1)}%\n';
          }
          text += '\n';
        }
        _text = text;
        _customPaint = null;
      }
      
      // Trigger bounce animation when faces are detected
      if (faces.isNotEmpty) {
        _bounceController.reset();
        _bounceController.forward();
      }
      
    } catch (e) {
      _text = 'Error: Unable to process image. Please try again.';
      _customPaint = null;
      _detectedFaces = [];
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }
}