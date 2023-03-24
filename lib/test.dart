// import 'package:english_words/english_words.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:esp32/ESP32.dart';
// import 'package:esp32/test.dart';

// class WebSocketLed extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     return _WebSocketLed(); 
//   }
// }

// class _WebSocketLed extends State<WebSocketLed>{
//   double test = 0; //boolean value to track LED status, if its ON or OFF
//   late IOWebSocketChannel channel;
//   bool connected = false; //boolean value to track if WebSocket is connected
//   @override
//   void initState() {
//     test = 0; //initially leadstatus is off so its FALSE
//     connected = false; //initially connection status is "NO" so its FALSE

//     Future.delayed(Duration.zero,() async {
//         channelconnect(); //connect to WebSocket wth NodeMCU
//     });

//     super.initState();
//   }

//   channelconnect(){ //function to connect 
//     try{
//          channel = IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
//          channel.stream.listen((message) {
//             print(message);
//             String data = message;
//             setState(() {
//                  if(message == "connected"){
//                       connected = true; //message is "connected" from NodeMCU
//                  }
//                  else if (data.substring(0,2) == "Vf:"){
//                     finalVolt = double.parse(message);
//                  }
//             });
//           }, 
//         onDone: () {
//           //if WebSocket is disconnected
//           print("Web socket is closed");
//           setState(() {
//                 connected = false;
//           });    
//         },
//         onError: (error) {
//              print(error.toString());
//         },);
//     }catch (_){
//       print("error on connecting to websocket.");
//     }
//   }
 
//   Future<void> sendcmd(String cmd) async {
//          if(connected == true){       
//             channel.sink.add(cmd); //sending Command to NodeMCU
//          }else{
//             channelconnect();
//             print("Websocket is not connected.");
//          }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:Text("LED - ON/OFF NodeMCU"),
//         backgroundColor: Colors.redAccent
//       ),
//       body:Container(
//          alignment: Alignment.topCenter, //inner widget alignment to center
//          padding: EdgeInsets.all(20),
//          child:Column(
//            children:[
//                Container(
//                   child: connected?Text("WEBSOCKET: CONNECTED"):Text("DISCONNECTED")    
//                 ),

//                 Container(
//                   child: Text(test.toString())      
//                 ),

//                 Container(
//                   margin: EdgeInsets.only(top:30),
//                   child: ElevatedButton( //button to start scanning
//                   onPressed: (){ //on button press
//                           sendcmd("toggleData");
//                       setState(() {  
//                       });
//                   }, 
//                   child: Text(test.toString())
//                   )
//                 )
//            ],
//          )
//       ),
//     );
//   }
// }