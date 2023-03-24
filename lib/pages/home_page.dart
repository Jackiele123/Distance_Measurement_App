import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:web_socket_channel/io.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:esp32/main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<WebSocketProvider>();
    String vi = appState.initialVolt.toString();
    String vf = appState.finalVolt.toString();
    String dist = appState.distance.toString();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: appState.connected ? Colors.green : Colors.red,
            alignment: Alignment.center,
            margin:
                const EdgeInsets.only(top: 0, bottom: 200, left: 0, right: 0),
            width: 1500.0,
            height: 100.0,
          ),
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Initial Voltage',
                    style: TextStyle(fontStyle: FontStyle.normal),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Final Voltage',
                    style: TextStyle(fontStyle: FontStyle.normal),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Distance',
                    style: TextStyle(fontStyle: FontStyle.normal),
                  ),
                ),
              ),
            ],
            rows: <DataRow>[
              DataRow(
                cells: <DataCell>[
                  DataCell(Text(vi.substring(0, min(vi.length, 6)))),
                  DataCell(Text(vf.substring(0, min(vf.length, 6)))),
                  DataCell(Text(dist.substring(0, min(dist.length, 6)))),
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
                icon: const Icon(CupertinoIcons.text_badge_plus),
                label: const Text('Add'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  appState.sendcmd('toggleData');
                },
                icon: const Icon(CupertinoIcons.waveform),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
