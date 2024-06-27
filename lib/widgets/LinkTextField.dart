import 'package:downv2/services/AllServices.dart';
import 'package:downv2/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LinkTextfield extends StatelessWidget {
  const LinkTextfield({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<services>(
      builder: (BuildContext context, services value, Widget? child) {
        return TextField(
          
          style: value.getTheme(context) == Brightness.light
              ? labelstyleLight
              : labelstyleDark,
          readOnly: true,
          controller: value.urlController,
          decoration: InputDecoration(
            
            enabledBorder:  const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            disabledBorder:  const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintText: 'Enter a Youtube URL',
              labelStyle: value.getTheme(context) == Brightness.light
                  ? labelstyleLight
                  : labelstyleDark,
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.paste,
                  color: Colors.white,
                ),
                onPressed: (){
                  value.pasteIn();
                },
              ),
            ),
        );
      },
    );
  }
}
