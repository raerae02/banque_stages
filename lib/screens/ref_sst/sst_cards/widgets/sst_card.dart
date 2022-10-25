//import 'dart:js_util';

import 'package:flutter/material.dart';

//SST
class SSTCard extends StatelessWidget {
  //params and variables
  const SSTCard(this.nmb, this.title, {super.key});
  final int nmb;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: ListTile(
        title: Text(
          'FICHE$nmb',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        isThreeLine: true,
        //onTap should redirect to the risk
        onTap: () => debugPrint("Clicked"),
      ),
    );
  }
}
