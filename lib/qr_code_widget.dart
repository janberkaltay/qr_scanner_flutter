import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner/scanned_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeWidget extends StatefulWidget {
  const QRCodeWidget({Key? key}) : super(key: key);

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {


  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isFlashOn = false;
  String result = '';
  String endless = 'https://endlesstech.org/';
  List<String> lastScannedCodes = [];

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _loadLastScannedCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastScannedCodes = prefs.getStringList('lastScannedCodes') ?? [];
    });
  }

  void _saveLastScannedCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('lastScannedCodes', lastScannedCodes);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        if (scanData.code != result) {
          result = scanData.code!;
          lastScannedCodes.add(result);
          if (lastScannedCodes.length > 10) {
            lastScannedCodes.removeAt(0);
          }
          _showURLDialog(context, result);
          _saveLastScannedCodes();
        }
        await controller.pauseCamera();
      }
    });
  }


  Future<void> _showURLDialog(BuildContext context, String url) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Kod Algılandı'),
          content:
              Text('Kod başka bir uygulamada açılacaktır. Emin misiniz?\n$url'),
          actions: <Widget>[
            TextButton(
              child: const Text('Aç'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchURL(url);
                await controller?.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('Kapat'),
              onPressed: () async {
                Navigator.of(context).pop();
                await controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      await launch(url, forceSafariVC: false);
    } catch (e) {
      await launch(url, forceSafariVC: true);
    }
  }

  void _showScannedCodesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScannedCodesPage(lastScannedCodes: lastScannedCodes),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLastScannedCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'QR Kod Okuyucu',
          style:
              TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () async {
              if (controller != null) {
                await controller!.flipCamera();
              }
            },
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.deepPurple,
              size: 32,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 20),
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Destek Ol',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: MediaQuery.of(context).size.width - 60,
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.deepPurple,
                    borderRadius: 30,
                    borderLength: 40,
                    borderWidth: 10,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    if (controller != null) {
                      await controller!.flipCamera();
                    }
                  },
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (isFlashOn) {
                      await controller?.toggleFlash();
                    } else {
                      await controller?.toggleFlash();
                    }
                    setState(() {
                      isFlashOn = !isFlashOn;
                    });
                  },
                  icon: Icon(
                    isFlashOn ? Icons.flash_off : Icons.flash_on,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showScannedCodesPage,
                  child: const Text('Son 10 Tarama Sonucu'),
                ),
              ],
            ),
          ),
          const Text(
            'QR Kod Okuyucu verilerinizi kaydetmez!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () async {
              await _launchURL(endless);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered',
                  style: TextStyle(color: Colors.black),
                ),
                Icon(Icons.copyright),
                Text(
                  'By Endless Software',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
