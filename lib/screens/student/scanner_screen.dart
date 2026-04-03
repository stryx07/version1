import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // ─── QR detected handler ───────────────────────────────────────────────────
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final scannedValue = barcode.rawValue!.trim();

    setState(() => _isProcessing = true);
    await _scannerController.stop();

    // Fetch element name from Firestore
    final elementNom = await _firestoreService.getElementNomByCode(scannedValue);

    if (elementNom == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Invalid QR Code or Module not found: "$scannedValue"'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF1744),
          duration: const Duration(seconds: 4),
        ),
      );
      await _scannerController.start();
      setState(() => _isProcessing = false);
      return;
    }

    final email = _authService.currentUser?.email;
    if (email == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final result = await _firestoreService.markAttendance(email, scannedValue, elementNom);

    if (!mounted) return;

    switch (result) {
      case AttendanceResult.success:
        context.pushReplacement(
          '/student/confirm',
          extra: {'elementNom': elementNom},
        );
        break;

      case AttendanceResult.duplicate:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Attendance already recorded for "$elementNom" today.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00B8D4),
            duration: const Duration(seconds: 4),
          ),
        );
        await _scannerController.start();
        setState(() => _isProcessing = false);
        break;

      case AttendanceResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_off_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Network error. Please check your connection.'),
              ],
            ),
            backgroundColor: Color(0xFFFF1744),
            duration: Duration(seconds: 3),
          ),
        );
        await _scannerController.start();
        setState(() => _isProcessing = false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scanner',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              child: IconButton(
                icon: Icon(
                  _torchOn
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                  color: _torchOn ? const Color(0xFF00B8D4) : Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  _scannerController.toggleTorch();
                  setState(() => _torchOn = !_torchOn);
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          _ScanOverlay(isProcessing: _isProcessing),

          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00B8D4)),
                    SizedBox(height: 24),
                    Text(
                      'Recording Presence...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  final bool isProcessing;

  const _ScanOverlay({required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const frameSize = 280.0;
    const cornerLen = 32.0;
    const cornerThick = 6.0;
    const cornerColor = Color(0xFF00B8D4);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: frameSize,
            height: frameSize,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: _Corner(
                    topLeft: true,
                    color: cornerColor,
                    len: cornerLen,
                    thick: cornerThick,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _Corner(
                    topRight: true,
                    color: cornerColor,
                    len: cornerLen,
                    thick: cornerThick,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _Corner(
                    bottomLeft: true,
                    color: cornerColor,
                    len: cornerLen,
                    thick: cornerThick,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _Corner(
                    bottomRight: true,
                    color: cornerColor,
                    len: cornerLen,
                    thick: cornerThick,
                  ),
                ),
                
                // Animated scan line could be added here
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              isProcessing
                  ? '⌛ PROCESSING...'
                  : 'ALIGN QR CODE WITHIN FRAME',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  final Color color;
  final double len, thick;

  const _Corner({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
    required this.color,
    required this.len,
    required this.thick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
          color: color,
          thick: thick,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  final Color color;
  final double thick;

  _CornerPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.color,
    required this.thick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (topLeft) {
      canvas.drawLine(const Offset(0, 32), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), const Offset(32, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(const Offset(0, 0), const Offset(32, 0), paint);
      canvas.drawLine(const Offset(32, 0), const Offset(32, 32), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(const Offset(0, 0), const Offset(0, 32), paint);
      canvas.drawLine(const Offset(0, 32), const Offset(32, 32), paint);
    }
    if (bottomRight) {
      canvas.drawLine(const Offset(32, 0), const Offset(32, 32), paint);
      canvas.drawLine(const Offset(32, 32), const Offset(0, 32), paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

