import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

const kAppThemeColor = Color(0xFF1593D5);
const kWhiteThemeColor = Color(0xFFFFFFFF);
const kRedThemeColor = Color(0xFFDD3300);

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey();
  Barcode? qrCodeResult;
  QRViewController? qrViewController;

  bool isFlashLightOff = true;

  void _onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    controller.scannedDataStream.listen(
      (scanQRCode) {
        setState(() {
          qrCodeResult = scanQRCode;
        });
      },
    );
  }

  /// Launch url
  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App bar
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),

      /// Body
      body: Column(
        children: <Widget>[
          /// QR scanner
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: const [
                BarcodeFormat.qrcode,
              ],
              overlay: QrScannerOverlayShape(
                borderColor: kAppThemeColor,
                borderRadius: 16.0,
                borderWidth: 6.0,
              ),
            ),
          ),

          /// Bottom components
          Expanded(
            flex: 1,
            child: Padding(
              // Add padding to the bottom components
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                primary: false,
                children: [
                  /// Scan qr code button
                  ElevatedButton.icon(
                    onPressed: () async {
                      (qrCodeResult != null)
                          ? await _launchURL(
                              Uri.parse(qrCodeResult!.code.toString()))
                          : print('No URL'); // ignore: avoid_print
                      setState(() {
                        qrCodeResult = null;
                      });
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Scan the QR Code'),
                  ),

                  /// Flash on/off, Flip camera buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Flash on/off button
                        IconButton.filled(
                          onPressed: () async {
                            setState(() {
                              if (isFlashLightOff) {
                                isFlashLightOff = false;
                              } else {
                                isFlashLightOff = true;
                              }
                            });
                            await qrViewController?.toggleFlash();
                          },
                          icon: isFlashLightOff
                              ? const Icon(Icons.flash_off_rounded)
                              : const Icon(Icons.flash_on_rounded),
                          iconSize: 35,
                        ),

                        /// Adding space
                        const SizedBox(width: 16.0),

                        /// Flip camera button
                        IconButton.filled(
                          onPressed: () async {
                            await qrViewController?.flipCamera();
                          },
                          icon: const Icon(Icons.cameraswitch_rounded),
                          iconSize: 35,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Logo
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered by: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Image(
                  image: AssetImage('images/adna-logo-txt.png'),
                  width: 25,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}