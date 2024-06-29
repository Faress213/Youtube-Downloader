
import 'package:downv2/Screens/Homepage.dart';
import 'package:downv2/services/AllServices.dart';
import 'package:downv2/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import 'package:provider/provider.dart';

void main() async{
WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ChangeNotifierProvider(create: (context) => services(),child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
         primarySwatch: Colors.grey,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionHandleColor: Colors.grey,
          selectionColor: Color.fromARGB(255, 233, 232, 232),
        ),
       
      ),
      home:  const FileDownloader(),
    );
  }
}
