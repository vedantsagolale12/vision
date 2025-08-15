import 'package:go_router/go_router.dart';
import 'package:visiontxt/features/face_detection/face_detector_view.dart';
import 'package:visiontxt/features/face_mesh_detector/face_mesh_detector_view.dart';
import 'package:visiontxt/features/home_screen/home_screen.dart';
import 'package:visiontxt/features/object_detector/object_detector_view.dart';
import 'package:visiontxt/features/pose_detection/pose_detector_view.dart';
import 'package:visiontxt/features/selfie_segementation/selfie_segmenter_view.dart';
import 'package:visiontxt/features/splashscreen/splash_view.dart';
import 'package:visiontxt/features/txt_recognition/text_detector_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/face',
      builder: (context, state) => const FaceDetectorView(),
    ),
    GoRoute(
      path: '/txt',
      builder: (context, state) => const TextRecognizerView(),
    ),
    GoRoute(
      path: '/mesh',
      builder: (context, state) => const FaceMeshDetectorView(),
    ),
    GoRoute(
      path: '/object',
      builder: (context, state) => const ObjectDetectorView(),
    ),
    GoRoute(
      path: '/pds',
      builder: (context, state) => const PoseDetectorView(),
    ),
      GoRoute(
      path: '/segment',
      builder: (context, state) => const SelfieSegmenterView(),
    ),
  ],
);
