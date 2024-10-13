
import 'package:flutter/material.dart';
import 'package:gopher_eye/providers/plot_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class MobileScannerWithOverlay extends StatefulWidget {
  const MobileScannerWithOverlay({Key? key}) : super(key: key);

  @override
  _MobileScannerWithOverlayState createState() =>
      _MobileScannerWithOverlayState();
}

class _MobileScannerWithOverlayState extends State<MobileScannerWithOverlay> {
  String? qrText;
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 250,
      height: 250,
    );
    return Scaffold(
        appBar: AppBar(
            title: const Text('Mobile Scanner with Overlay'),
            backgroundColor: Colors.transparent,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
            leading: const BackButton(
              color: Colors.white,
            )),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          MobileScanner(
            scanWindow: scanWindow,
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              for (final Barcode barcode in barcodes) {
                print('Barcode: ${barcode.rawValue}');
                setState(() {
                  qrText = barcode.rawValue;
                });

              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }

              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: qrText != null,
                child: InkWell(
                    onTap: () {
                      Provider.of<PlotProvider>(context, listen: false)
                          .setPlot(int.parse(qrText!));
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 100,
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          qrText ?? 'No QR code detected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    )),
              ))
        ]));
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: use `Offset.zero & size` instead of Rect.largest
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()..addRect(Rect.largest);

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
