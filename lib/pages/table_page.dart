import 'package:flutter/material.dart';

class Data {
  int ID;
  double finalVolt, initialVolt, trueDistance, measuredDistance;

  Data (this.ID, this.finalVolt, this.initialVolt, this.trueDistance, this.measuredDistance);

}

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'Learn 📗',
    ));
  }
}
