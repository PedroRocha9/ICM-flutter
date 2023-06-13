import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LineUpPage extends StatefulWidget {
  @override
  _LineUpPageState createState() => _LineUpPageState();
}

class _LineUpPageState extends State<LineUpPage> {
  List<Map<String, dynamic>> lineups = [];

  @override
  void initState() {
    super.initState();
    fetchLineups();
  }

  Future<void> fetchLineups() async {
    final response = await http
        .get(Uri.parse('http://192.168.43.168:8000/festival/1/lineup/'));

    if (response.statusCode == 200) {
      setState(() {
        print("lineups");
        print(json.decode(response.body));
      });
    } else {
      print('Failed to fetch lineups: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Festival Line Up'),
      ),
      body: ListView.builder(
        itemCount: lineups.length,
        itemBuilder: (context, index) {
          final lineup = lineups[index];
          final day = lineup['day'];
          final artists = lineup['artists'];

          return ExpansionTile(
            title: Text('Day $day'),
            children: artists.map<Widget>((artist) {
              return ListTile(
                title: Text(artist['name']),
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
