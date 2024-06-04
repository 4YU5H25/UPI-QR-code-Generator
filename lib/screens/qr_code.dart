// lib/screens/qr_display_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/upi_provider.dart';

class QrDisplayScreen extends ConsumerWidget {
  final ScreenshotController screenshotController = ScreenshotController();

  QrDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upiUri = ref.watch(upiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated QR Code'),
        elevation: 10,
        backgroundColor: Colors.white60,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Screenshot(
                  controller: screenshotController,
                  child: QrImageView(
                    data: upiUri!,
                    version: QrVersions.auto,
                    size: MediaQuery.sizeOf(context).width * 0.9,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () async {
                await _saveQrImage(screenshotController, context);
              },
              heroTag: "Save",
              tooltip: "Save",
              child: const Icon(Icons.save),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     await share();
      //   },
      //   heroTag: "Share",
      //   tooltip: "Share",
      //   child: const Icon(Icons.share),
      // ),
    );
  }

  Future<void> _saveQrImage(
      ScreenshotController screenshotController, BuildContext context) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/qr_code.png';

      screenshotController
          .captureAndSave(
        directory.path,
        fileName: 'qr_code.png',
        pixelRatio: 2.0,
      )
          .then((image) async {
        final result = await ImageGallerySaver.saveFile(imagePath);
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save QR Code')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  Future<void> share() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getTemporaryDirectory();
      // final imagePath = '${directory.path}/qr_code.png';

      await screenshotController.captureAndSave(
        directory.path,
        fileName: 'qr_code.png',
        pixelRatio: 2.0,
      );
      // await Share.shareXFiles([XFile(imagePath)], text: 'UPI QR code');
    }
  }
}
