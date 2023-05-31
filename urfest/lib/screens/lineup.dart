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
