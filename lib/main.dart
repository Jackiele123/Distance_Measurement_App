import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:esp32/ESP32.dart';
import 'package:esp32/test.dart';
void main() {
  runApp(ESP32());
}

class ESP32 extends StatelessWidget {
  const ESP32({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WebSocketProvider(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
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


  void channelconnect(){ //function to connect 
    try{
        channel = IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
        channel.stream.listen((message){
            print(message);
            print(message);
            String data = message;
            String test = data.substring(0,3);
            if(message == "connected"){
              connected = true; //message is "connected" from NodeMCU
            }
            else if (data.substring(0,3) == "Vf:"){
            finalVolt = double.parse(data.substring(3));
            }
            else if (data.substring(0,3) == "Vi:"){
            initialVolt = double.parse(data.substring(3));
            notifyListeners();
            }
            else if (data.substring(0,3) == "di:"){
            distance = double.parse(data.substring(3));
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
        },);
    }catch (_){
      print("error on connecting to websocket.");
    }
  }
  Future<void> sendcmd(String cmd) async {
         if(connected == true){       
            channel.sink.add(cmd); //sending Command to NodeMCU
         }else{
            channelconnect();
            print("Websocket is not connected.");
         }
         notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override

  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      // case 1:
      //   page = FavoritesPage();
      //   break;
      // case 2:
      //   page = TestPage();
      //   break;
      default:
        page = GeneratorPage();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                   NavigationRailDestination(
                    icon: Icon(Icons.show_chart),
                    label: Text('Data'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<WebSocketProvider>();
    appState.initialVolt.toString();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(
              'V1',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'V2',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Distance',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
      rows: <DataRow>[
        DataRow(
          cells: <DataCell>[
            DataCell(Text(appState.initialVolt.toString())),
            DataCell(Text(appState.finalVolt.toString())),
            DataCell(Text(appState.distance.toString())),
          ],
        ),
      ],
    ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.sendcmd('toggleData');
                },
                icon: Icon(CupertinoIcons.add),
                label: Text('Add'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.sendcmd('toggleData');
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// class FavoritesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<UIState>();

//     if (appState.favorites.isEmpty) {
//       return Center(
//         child: Text('No favorites yet.'),
//       );
//     }

//     return ListView(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(20),
//           child: Text('You have '
//               '${appState.favorites.length} favorites:'),
//         ),
//         for (var pair in appState.favorites)
//           ListTile(
//             leading: Icon(Icons.favorite),
//             title: Text(pair.asLowerCase),
//           ),
//       ],
//     );
//   }
// }


