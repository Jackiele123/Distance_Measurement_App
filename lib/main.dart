import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esp32/pages/graph_page.dart';
import 'package:esp32/pages/home_page.dart';
import 'package:esp32/pages/table_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WebSocketProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Navigation(),
      ),
    );
  }
}

class WebSocketProvider extends ChangeNotifier {
  double initialVolt = 0;
  double finalVolt = 0;
  double distance = 0;
  late IOWebSocketChannel channel;
  bool connected = false; //boolean value to track if WebSocket is connected
  
  void channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
          String data = message;
          if (message == "connected") {
            connected = true; //message is "connected" from NodeMCU
          } else if (data.substring(0, 3) == "Vf:") {
            finalVolt = double.parse(data.substring(3));
            distance = 0.1278 * pow(finalVolt - initialVolt, 0.9427);
            notifyListeners();
          } else if (data.substring(0, 3) == "Vi:") {
            initialVolt = double.parse(data.substring(3));
            finalVolt = 0;
            distance = 0;
            notifyListeners();
          }
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          connected = false;
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd); //sending Command to NodeMCU
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
    notifyListeners();
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigiation Bar',
      home: Scaffold(
        body: [HomePage(), const TablePage(), const GraphPage()][selectedPageIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedPageIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.table_chart),
              icon: Icon(Icons.table_chart_outlined),
              label: 'Table',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.show_chart),
              icon: Icon(Icons.show_chart_outlined),
              label: 'Graph',
            ),
          ],
        ),
      ),
    );
  }
}
