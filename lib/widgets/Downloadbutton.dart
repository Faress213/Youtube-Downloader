import 'package:downv2/services/AllServices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<services>(
      builder: (BuildContext context, value, Widget? child) {
        return ElevatedButton(
          
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.0), // Set the border radius here
              ),
            ),
          ),
          onPressed: value.isDownloading
              ? null
              : () async {
                if(value.isButtonClickable){
                   value.requestPermission(context);
                }
                else{
                  
                }
                 
                },
          child: Text(value.buttonString ?? 'Download File'),
        );
      },
    );
  }
}
