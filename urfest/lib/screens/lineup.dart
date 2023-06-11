
import 'package:flutter/material.dart';

class LineUpPage extends StatefulWidget {
  @override
  _LineUpPageState createState() => _LineUpPageState();
}

class _LineUpPageState extends State<LineUpPage> {
  // Assume this is your data
  final Map<String, List<String>> artistsPerDay = {
    'Day 1': ['Artist 1', 'Artist 2', 'Artist 3'],
    'Day 2': ['Artist 4', 'Artist 5', 'Artist 6'],
    'Day 3': ['Artist 7', 'Artist 8', 'Artist 9'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festival Line Up'),
      ),
      body: ListView.builder(
        itemCount: artistsPerDay.keys.length,
        itemBuilder: (context, index) {
          String day = artistsPerDay.keys.elementAt(index);
          return ExpansionTile(
            title: Text(day),
            children: artistsPerDay[day]!.map((artist) {
              return ListTile(
                title: Text(artist),
                onTap: () {
                  // Navigate to artist details page
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ArtistDetailsPage(artist: artist)),
                  // );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
/*

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LineUpPage extends StatefulWidget {
  const LineUpPage({super.key});

  @override
  _LineUpPageState createState() => _LineUpPageState();
}

class _LineUpPageState extends State<LineUpPage> {
  Uint8List? qrCodeImageData;

  Future<void> fetchQRCode() async {
    final response = await http.get(Uri.parse('http://192.168.43.168:8000/qrcode/3'));
    if (response.statusCode == 200) {
      setState(() {
        qrCodeImageData = response.bodyBytes;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQRCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Center(
        child: qrCodeImageData != null
            ? Image.memory(qrCodeImageData!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
*/