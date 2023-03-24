// import 'package:english_words/english_words.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/io.dart';

// import 'package:esp32/main.dart';

// class Data{
//   double v1, v2, dv, dist, val;
//   int ID;

//   Data(this.ID,this.v1, this.v2, this.dv, this.dist, this.val);

//   updateData(double v1, double v2, double dist, double val){
//     this.v1 = v1;
//     this.v2 = v2;
//     this.dist = dist;
//     this.val = val;
//     dv= v1-v2;
//   }
// }


// class MeasuringPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<UIState>();

//     return DataTable(
//       headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states){
//         if (states.contains(MaterialState.hovered)) {
//           return Theme.of(context).colorScheme.primary.withOpacity(0.08);
//         }
//         return null;  // Use the default value.
//       }),
//       columns: const <DataColumn>[
//         DataColumn(
//           label: Expanded(
//             child: Text(
//               'V1',
//               style: TextStyle(fontStyle: FontStyle.normal),
//             ),
//           ),
//         ),
//         DataColumn(
//           label: Expanded(
//             child: Text(
//               'V2',
//               style: TextStyle(fontStyle: FontStyle.normal),
//             ),
//           ),
//         ),
//         DataColumn(
//           label: Expanded(
//             child: Text(
//               'Distance',
//               style: TextStyle(fontStyle: FontStyle.normal),
//             ),
//           ),
//         ),
//       ],
//       rows: const <DataRow>[
//         DataRow(
//           cells: <DataCell>[
//             DataCell(Text('Sarah')),
//             DataCell(Text('19')),
//             DataCell(Text('Student')),
//           ],
//         ),
//         DataRow(
//           cells: <DataCell>[
//             DataCell(Text('Janine')),
//             DataCell(Text('43')),
//             DataCell(Text('Professor')),
//           ],
//         ),
//         DataRow(
//           cells: <DataCell>[
//             DataCell(Text('William')),
//             DataCell(Text('27')),
//             DataCell(Text('Associate Professor')),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class WebSocketLed extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     return _WebSocketLed(); 
//   }
// }

// class _WebSocketLed extends State<WebSocketLed>{
//   bool ledstatus; //boolean value to track LED status, if its ON or OFF
//   IOWebSocketChannel channel;
//   bool connected; //boolean value to track if WebSocket is connected

//   @override
//   void initState() {
//     ledstatus = false; //initially leadstatus is off so its FALSE
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
//             setState(() {
//                  if(message == "connected"){
//                       connected = true; //message is "connected" from NodeMCU
//                  }else if(message == "poweron:success"){
//                       ledstatus = true; 
//                  }else if(message == "poweroff:success"){
//                       ledstatus = false;
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
//                 if(ledstatus == false && cmd != "poweron" && cmd!= "poweroff"){
//                     print("Send the valid command");
//                 }else{
//                    channel.sink.add(cmd); //sending Command to NodeMCU
//                 }
//          }else{
//             channelconnect();
//             print("Websocket is not connected.");
//          }
//   }
// }


// /*
// class MeasuringPage extends StatefulWidget {
//   @override
//   MeasuringPageState createState() => new MeasuringPageState();
// }
 
// class MeasuringPageState extends State<MeasuringPage>{
//   @override
//   Widget build(BuildContext context) {
//   List<Data> dataList = <Data>[];

//   final formKey = new GlobalKey<FormState>();
//   var ID_Controller = new TextEditingController();
//   var Val_Controller = new TextEditingController();
//   var V1_Controller = new TextEditingController();
//   var V2_Controller = new TextEditingController();
//   var DeltaV_Controller = new TextEditingController();
//   var Dist_Controller = new TextEditingController();
//   var lastID = 0;

//   @override
//   void initState() {
//     super.initState();
//     lastID++;
//     ID_Controller.text = lastID.toString();
//   }
//   // Method that is used to refresh the UI and show the new inserted data.
//   refreshList() {
//     setState(() {
//       ID_Controller.text = lastID.toString();
//     });
//   }
//   // 


// validate() {
//     if (formKey.currentState!.validate()) {
//       formKey.currentState!.save();
//       String id = ID_Controller.text;
//       String val = Val_Controller.text;
//       String v1 = V1_Controller.text;
//       String v2 = V2_Controller.text;
//       String dv = DeltaV_Controller.text;
//       String dist = Dist_Controller.text;
//       Data currData = Data(int.parse(id), double.parse(v1),double.parse(v2), double.parse(dv), double.parse(dist),double.parse(val));
//       dataList.add(currData);
//       lastID++;
//       refreshList();
//       Val_Controller.text = "";
//       V1_Controller.text = "";
//       V2_Controller.text = "";
//       DeltaV_Controller.text = "";
//       Dist_Controller.text = "";
//     }
//   }


// return MaterialApp(
//       // MaterialApp with home as scaffold
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text("Insert Into Data Table"),
//         ),
//         body: ListView(
//           children: <Widget>[
//             Form(
//               key: formKey,
//               child: Padding(
//                 padding: EdgeInsets.all(15.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text("Initial Voltage [mV]:"),
//                     TextField(
//                       controller: V1_Controller,
//                       keyboardType: TextInputType.number,
//                     ),
//                     Text("Final Voltage [mV]:"),
//                     TextFormField(
//                       controller: V2_Controller,
//                       keyboardType: TextInputType.number,
//                     ),
//                     Text("Change in Voltage [mV]:"),
//                     TextFormField(
//                       controller: DeltaV_Controller,
//                       keyboardType: TextInputType.number,
//                     ),
//                     Text("Measured Value [mm]:"),
//                     TextFormField(
//                       controller: Dist_Controller,
//                       keyboardType: TextInputType.number,
//                     ),
//                     Text("True Value [mm]:"),
//                     TextFormField(
//                       controller: Val_Controller,
//                       keyboardType: TextInputType.number,
//                     ),
//                     SizedBox(
//                       width: double.infinity,
//                       child: MaterialButton(
//                         color: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         child: Text(
//                           'Insert Data',
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                         onPressed: validate,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: [
//                   DataColumn(
//                     label: Text("ID"),
//                   ),
//                   DataColumn(
//                     label: Text("Initial Voltage [mV]"),
//                   ),
//                   DataColumn(
//                     label: Text("Final Voltage [mV]"),
//                   ),
//                   DataColumn(
//                     label: Text("Change in Voltage [mV]"),
//                   ),
//                   DataColumn(
//                     label: Text("Measured Value [mm]"),
//                   ),
//                   DataColumn(
//                     label: Text("True Value [mm]"),
//                   ),
//                 ],
//                 rows: dataList.map(
//                   (currData) => DataRow(cells: [
//                     DataCell(
//                       Text(currData.ID.toString()),
//                     ),
//                     DataCell(
//                       Text(currData.v1.toString()),
//                     ),
//                     DataCell(
//                       Text(currData.v2.toString()),
//                     ),
//                     DataCell(
//                       Text(currData.dv.toString()),
//                     ),
//                     DataCell(
//                       Text(currData.dist.toString()),
//                     ),
//                     DataCell(
//                       Text(currData.val.toString()),
//                     ),
//                   ]),
//                 ).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// */
