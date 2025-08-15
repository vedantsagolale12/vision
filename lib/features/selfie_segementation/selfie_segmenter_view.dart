import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:visiontxt/features/selfie_segementation/painters/selfie_segmenter_painter.dart';
import 'package:visiontxt/widgets/detector_view.dart';

class SelfieSegmenterView extends StatefulWidget {
  const SelfieSegmenterView({super.key});

  @override
  State<SelfieSegmenterView> createState() => _SelfieSegmenterViewState();
}

class _SelfieSegmenterViewState extends State<SelfieSegmenterView>
    with SingleTickerProviderStateMixin {
  final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() async {
    _fadeController.dispose();
    _canProcess = false;
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          DetectorView(
            title: '',
            customPaint: _customPaint,
            text: _text,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) =>
                _cameraLensDirection = value,
          ),

          /// Gradient overlay for a more modern look
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// App bar with modern styling
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.go('/home'),
                  ),
                  Text(
                    'Selfie Segmenter',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  _buildGlassButton(
                    icon: Icons.cameraswitch,
                    onPressed: () {
                      setState(() {
                        _cameraLensDirection =
                            _cameraLensDirection == CameraLensDirection.front
                                ? CameraLensDirection.back
                                : CameraLensDirection.front;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Bottom info panel
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _text ?? 'Initializing segmentation...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onPressed,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    final mask = await _segmenter.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        mask != null) {
      final painter = SegmentationPainter(
        mask,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text =
          'Mask detected: ${(mask?.confidences ?? []).where((c) => c > 0.8).length} high-confidence points';
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
