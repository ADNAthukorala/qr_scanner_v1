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

  /// URL validation
  bool isValidUrl(String url) {
    // Regular expression for URL validation
    final RegExp regExp = RegExp(
      r'^https?:\/\/(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+(?:\/[^\s]*)?$',
      caseSensitive: false,
      multiLine: false,
    );
    return regExp.hasMatch(url);
  }

  /// Launch url
  Future<void> _launchURL(Uri url) async {
    if (isValidUrl(url.toString())) {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } else {
      print('Not a valid URL'); // ignore: avoid_print
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
            child: Stack(
              children: [
                QRView(
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
                Center(
                  heightFactor: 1.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      (qrCodeResult != null)
                          ? qrCodeResult!.code.toString()
                          : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kAppThemeColor),
                    ),
                  ),
                ),
              ],
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
                  (qrCodeResult != null)
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            if (qrCodeResult != null) {
                              await _launchURL(
                                  Uri.parse(qrCodeResult!.code.toString()));
                              setState(() {
                                qrCodeResult = null;
                              });
                            } else {
                              print('No URL'); // ignore: avoid_print
                            }
                          },
                          icon: const Icon(Icons.link_rounded),
                          label: const Text('Open the Link'),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {},
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
