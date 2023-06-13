import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({Key? key}) : super(key: key);

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  int userId = 0;

  final GlobalKey _globalKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;
  bool showPrompt = false;
  Map<String, dynamic>? qrData;

  @override
  void initState() {
    super.initState();

    initializeHiveAndOpenBoxes();
  }

  Future<void> initializeHiveAndOpenBoxes() async {
    await fetchUserFromCache();
  }

  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((barcode) {
      setState(() {
        this.barcode = barcode;
        qrData = parseQRCodeData(barcode.code!);
        showPrompt = true;
      });
    });
  }

  Map<String, dynamic> parseQRCodeData(String qrCodeData) {
    try {
      final Map<String, dynamic> qrData = json.decode(qrCodeData);
      return qrData;
    } catch (e) {
      return {};
    }
  }

  void acceptQRCode() {
    // Handle accepted QR code
    setState(() {
      showPrompt = false;
    });

    // Add friend to list
    http
        .post(
      Uri.parse('http://192.168.43.168:8000/user/$userId/buddies/'),
      body: json.encode({
        'buddy': qrData!['id'],
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        // Request was successful
        print('Friend added successfully');
        // Handle any further actions here
      } else {
        // Request failed
        print('Failed to add friend');

        // Show error message as a prompt
        final error = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );

        // Handle any error scenarios here
      }
    }).catchError((error) {
      // Error occurred during the request
      print('Error adding friend: $error');

      // Show error message as a prompt
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $error')),
      );

      // Handle any error scenarios here
    });
  }

  void cancelQRCode() {
    // Handle canceled QR code
    setState(() {
      showPrompt = false;
    });
  }

  Future<void> fetchUserFromCache() async {
    final Box<int>? userBox = await Hive.openBox<int>('userBox');
    if (userBox != null && userBox.isOpen) {
      userId = userBox.get('userBox')!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QRView(
                      key: _globalKey,
                      onQRViewCreated: qr,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Scan a QR code to add a friend',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          if (showPrompt)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
                child: AlertDialog(
                  title: Text('QR Code Scanned'),
                  content: Text(
                      qrData != null && qrData!.containsKey('username')
                          ? 'Add ${qrData!['username']} to your list?'
                          : 'Add buddy to your list?'),
                  actions: [
                    ElevatedButton(
                      onPressed: acceptQRCode,
                      child: Text('Accept'),
                    ),
                    ElevatedButton(
                      onPressed: cancelQRCode,
                      child: Text('Cancel'),
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
