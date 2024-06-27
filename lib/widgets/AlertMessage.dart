import 'package:downv2/services/AllServices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlertMessage extends StatelessWidget {
  const AlertMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<services>(
      builder: ( context, services value, Widget? child) {
        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            value.statusMessage,
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
}