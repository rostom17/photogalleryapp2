import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Photo Gallery App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> PhotoDetailPage(album:snapshot.data![index])),);
                        },
                        child: Image.network(snapshot.data![index].thumbnailUrl),
                      ),
                      title: Text(snapshot.data![index].title),
                    );
                  },
                );
              } else {
                return const Text('No data');
              }
            },
          ),

        ),
      ),
    );
  }
}

class PhotoDetailPage extends StatelessWidget {
  final Album album;

  PhotoDetailPage({required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Photo Details',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 25,
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(album.url),
            SizedBox(height: 20),
            Text('Title: ${album.title}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('ID: ${album.id}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}


Future<List<Album>> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((album) => Album.fromJson(album)).toList();
  } else {
    throw Exception('Failed to load album');
  }
}

class Album {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  const Album({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'albumId': int albumId,
      'id': int id,
      'title': String title,
      'url' : String url,
      'thumbnailUrl' : String thumbnailUrl,
      } =>
          Album(
              albumId: albumId,
              id: id,
              title: title,
              url: url,
              thumbnailUrl: thumbnailUrl
          ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}
