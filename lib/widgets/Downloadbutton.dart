import 'package:downv2/services/AllServices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<services>(
      builder: (BuildContext context, value, Widget? child) {
        return SliderButton(
            height: 60,
            disable: value.isDownloading,
            action: () async {
              if (value.isButtonClickable) {
                value.requestPermission(context);
              } else {}

              return value.isDownloading;
            },
            label: Center(
              child: Text(
                value.buttonString ?? 'Download File',
                style: const TextStyle(
                    color: Color(0xff4a4a4a),
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
            ),
            icon: const Icon(Icons.download));
      },
    );
  }
}
