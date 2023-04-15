import 'package:chat/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    connectToServer();
  }
  void connectToServer() {
    try {

      // Configure socket transports must be specified
      socket = IO.io('http://localhost:3000/',IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    } catch (e) {
      print(e.toString());
    }


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Container(
              child: Center(
                child: Column(
                  children: [
                    ElevatedButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(
                          myUserId: '12',
                          otherUserId: '21',
                          socket: socket,
                        )),);
                    }, child: Text("ONE")),
                    SizedBox(height: 30,),
                    ElevatedButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(
                          myUserId: '21',
                          otherUserId: '12',
                          socket: socket,
                        )),);
                    }, child: Text("TWO")),
                    SizedBox(height: 30,),
                    ElevatedButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(
                          myUserId: '211',
                          otherUserId: '121',
                          socket: socket,
                        )),);
                    }, child: Text("THREE")),
                  ],
                ),
              ),
            );
          }
        ),
      )
    );
  }
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext?  context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
