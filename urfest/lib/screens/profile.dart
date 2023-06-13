import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> friends = [];
  Uint8List? qrCodeImageData;
  Box<String>? friendsBox;
  Box<Uint8List>? qrCodeBox;

  int userId = 0;

  @override
  void initState() {
    super.initState();

    initializeHiveAndOpenBoxes();
  }

  Future<void> initializeHiveAndOpenBoxes() async {
    await openHiveBoxes(); // Open the Hive boxes
    
    await fetchUserFromCache();

    fetchFriendsFromCache();
    fetchQRCodeFromCache();

    fetchFriends();
    fetchQRCode();
  }

  Future<void> openHiveBoxes() async {
    await Hive.openBox<String>('friends').then((box) {
      friendsBox = box;
    });
    await Hive.openBox<Uint8List>('qrcode').then((box) {
      qrCodeBox = box;
    });
  }

  Future<void> removeFriend(int buddyIDToEliminate) async {
    final response = await http.delete(
      Uri.parse('http://192.168.43.168:8000/user/$userId/buddies/$buddyIDToEliminate'),
    );

    if (response.statusCode == 200) {
      setState(() {
        friends
            .removeWhere((friend) => friend == buddyIDToEliminate.toString());
      });
    } else {
      print('Failed to remove the friend');
    }
  }

  Future<void> fetchUserFromCache() async {
    final Box<int>? userBox = await Hive.openBox<int>('userBox');
    if (userBox != null && userBox.isOpen) {
      userId = userBox.get('userBox')!;
    }
  }

  Future<void> fetchFriends() async {
    final response = await http.get(
        Uri.parse('http://192.168.43.168:8000/user/$userId/buddies?content=username'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> fetchedFriends = List<String>.from(data);
      setState(() {
        friends = fetchedFriends;
        friendsBox?.put('friends', jsonEncode(fetchedFriends));
      });
    }
  }

  Future<void> fetchQRCode() async {
    final response =
        await http.get(Uri.parse('http://192.168.43.168:8000/qrcode/$userId'));
    if (response.statusCode == 200) {
      final Uint8List imageData = response.bodyBytes;
      setState(() {
        qrCodeImageData = imageData;
        qrCodeBox?.put('qrcode', imageData);
      });
    }
  }

  Future<void> fetchFriendsFromCache() async {
    print("INSIDE FETCH FRIENDS FROM CACHE");
    if (friendsBox != null && friendsBox!.isOpen) {
      final String? cachedFriends = friendsBox!.get('friends');
      print("CACHED FIRENDS");
      print(cachedFriends);
      if (cachedFriends != null) {
        final List<dynamic> decodedFriends = jsonDecode(cachedFriends);
        final List<String> fetchedFriends =
            decodedFriends.map((friend) => friend.toString()).toList();
        setState(() {
          friends = fetchedFriends;
        });
      }
    }
  }

  Future<void> fetchQRCodeFromCache() async {
    if (qrCodeBox != null && qrCodeBox!.isOpen) {
      final Uint8List? cachedQRCode = qrCodeBox!.get('qrcode');
      if (cachedQRCode != null) {
        setState(() {
          qrCodeImageData = cachedQRCode;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: SingleChildScrollView(
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
                maxHeight: 135.0,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24.0,
                      child: Icon(Icons.person_2_outlined),
                    ),
                    title: Text(friends[index]),
                    onTap: () {},
                    trailing: IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Remove Friend'),
                              content: Text(
                                  'Are you sure you want to remove this friend?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Remove'),
                                  onPressed: () async {
                                    String username = friends[index];
                                    // Call the function to remove the friend
                                    final response = await http.get(Uri.parse(
                                        'http://192.168.43.168:8000/user/$username'));
                                    if (response.statusCode == 200) {
                                      // If the server returns a 200 OK response, then parse the JSON.
                                      Map<String, dynamic> json =
                                          jsonDecode(response.body);
                                      await removeFriend(json['id']);

                                      // remove list view item
                                      setState(() {
                                        friends.removeAt(index);
                                      });
                                    } else {
                                      // If the server did not return a 200 OK response,
                                      // then throw an exception.
                                      throw Exception(
                                          'Failed to load festival location');
                                    }
                                    // After removing the friend, dismiss the dialog
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'QR Code to let people add you',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: qrCodeImageData != null
                  ? Container(
                      padding: EdgeInsets.all(8.0),
                      child: Image.memory(
                        qrCodeImageData!,
                        width: 280, // set the width of the QR code here
                        height: 280, // set the height of the QR code here
                        fit: BoxFit.contain,
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
