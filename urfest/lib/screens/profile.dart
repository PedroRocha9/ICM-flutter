import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> friends = [];
  Uint8List? qrCodeImageData;

  @override
  void initState() {
    super.initState();
    fetchFriends(); // Fetch friends when the page is loaded
    fetchQRCode();
  }

  Future<void> fetchFriends() async {
    final response = await http.get(Uri.parse('http://192.168.43.168:8000/user/2/buddies?content=username'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final List<String> fetchedFriends = List<String>.from(data);
      setState(() {
        friends = fetchedFriends;
      });
    }
  }

  Future<void> fetchQRCode() async {
    final response = await http.get(Uri.parse('http://192.168.43.168:8000/qrcode/3'));
    if (response.statusCode == 200) {
      setState(() {
        qrCodeImageData = response.bodyBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: SingleChildScrollView( // Wrap the Column in SingleChildScrollView
        child: Column(
          children: [
            Container(
              child: const CircleAvatar(
                radius: 64.0,
                child: Icon(Icons.person, size: 64.0),
              ),
            ),
            Text(
              'Username',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Buddies',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              constraints: BoxConstraints(
                maxHeight: 200.0,
              ),
              child: ListView.builder(
                shrinkWrap: true, // Add shrinkWrap to enable scrolling within ListView
                itemCount: friends.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24.0,
                      child: Icon(Icons.person_2_outlined),
                    ),
                    title: Text(friends[index]),
                    onTap: () {
                      // Action when a friend is tapped
                    },
                  );
                },
              ),
            ),
            Center(
              child: qrCodeImageData != null
                  ? Image.memory(qrCodeImageData!)
                  : CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
