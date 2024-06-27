import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class services with ChangeNotifier {
  final TextEditingController _urlController = TextEditingController();
  bool _isDownloading = false;
  final String _statusMessage = "";
  bool _isSnackbarVisible = false;
  double _progress = 0.0;
  bool _isPaused = false;
  bool isSuccessfulDownload = false;
  String? buttonString;
  bool isButtonClickable = true;

  StreamSubscription<List<int>>? _downloadSubscription;

  void pasteIn() => _pasteClipboardContent();
  void startDownload(BuildContext context) =>
      _startDownload(_urlController.text, context);
  void showPermissionDialog(BuildContext context) =>
      _showPermissionDialog(context);
  void requestPermission(BuildContext context) => _requestPermission(context);

  TextEditingController get urlController => _urlController;
  bool get isDownloading => _isDownloading;
  String get statusMessage => _statusMessage;
  bool get isSnackbarVisible => _isSnackbarVisible;
  bool get isPaused => _isPaused;
  double get progress => _progress;

  Future<void> _requestPermission(BuildContext context) async {
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.photos.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }

    if (permissionStatus) {
      startDownload(context);
    } else {
      showPermissionDialog(context);
    }
    notifyListeners();
  }

  Brightness getTheme(BuildContext context) {
    return MediaQuery.of(context).platformBrightness;
  }

  Future<void> _startDownload(String url, BuildContext context) async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (url.isEmpty) {
      _showSnackbar('Please Enter A URL', false, context);
      return;
    }

    if (!result) {
      _showSnackbar('No Internet Connection', false, context);
      return;
    } else {
      if (url.contains('youtube') || url.contains('youtu')) {
        downloadYouTubeVideo(url, context);
      } else {
        _showSnackbar('Only Youtube Links Please', false, context);
      }
    }
  }

  Future<void> downloadYouTubeVideo(
      String videoUrl, BuildContext context) async {
    var yt = YoutubeExplode();
    _isDownloading = true;
    notifyListeners();

    try {
      var videoId = extractVideoId(videoUrl);
      if (videoId == null) {
        if (context.mounted) {
          _showSnackbar('Invalid YouTube video ID or URL', false, context);
        }
        _isDownloading = false;
        notifyListeners();
        return;
      }

      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var streamInfo = manifest.muxed.withHighestBitrate();
      var stream = yt.videos.streamsClient.get(streamInfo);

      var dir = await getTemporaryDirectory();
      var filePath = '${dir.path}/${DateTime.now().toString()}.mp4';
      var file = File(filePath);
      var output = file.openWrite();

      var totalBytes = streamInfo.size.totalBytes;
      var downloadedBytes = 0;

      _downloadSubscription = stream.listen(
        (data) {
          output.add(data);
          downloadedBytes += data.length;
          double progress = downloadedBytes / totalBytes;

          _progress = progress;
          notifyListeners();
        },
        onDone: () async {
          await output.close();
          final result = await ImageGallerySaver.saveFile(filePath);
          if (result['isSuccess']) {
            isSuccessfulDownload = true;
          } else {
            isSuccessfulDownload = false;
          }
          log('Downloaded: ${file.path}');
          yt.close();
          _isDownloading = false;
          _progress = 0.0;
          getButtonText();
        },
        onError: (e) {
          if (context.mounted) {
            _showSnackbar(
                'Something Wrong Happened, Try Again', false, context);
          }
          yt.close();
          _isDownloading = false;
          _progress = 0.0;
          notifyListeners();
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackbar('Something Wrong Happened, Try Again', false, context);
      }
      yt.close();
      _isDownloading = false;
      _progress = 0.0;
      notifyListeners();
    }
  }

  void getButtonText() {
    if (isSuccessfulDownload) {
      buttonString = 'Done :)';
      isButtonClickable = false;
      notifyListeners();
    }
    Timer(const Duration(seconds: 3), () {
      buttonString = "Download File";
      isButtonClickable = true;
      notifyListeners();
    });
  }

  void pauseDownload() {
    if (_downloadSubscription != null && !_isPaused) {
      _downloadSubscription!.pause();
      _isPaused = true;
      notifyListeners();
    }
  }

  void resumeDownload() {
    if (_downloadSubscription != null && _isPaused) {
      _downloadSubscription!.resume();
      _isPaused = false;
      notifyListeners();
    }
  }

  void cancelDownload(BuildContext context) {
    if (_downloadSubscription != null) {
      _downloadSubscription!.cancel();
      _isDownloading = false;
      _isPaused = false;
      _progress = 0.0;
      notifyListeners();
    }
    if (context.mounted) {
      _showSnackbar('You Canceled The Download', false, context);
    }
  }

  String? extractVideoId(String url) {
    final shortUrlPattern = RegExp(r'youtu\.be\/([a-zA-Z0-9_-]+)');
    final regularUrlPattern = RegExp(r'v=([a-zA-Z0-9_-]+)');
    final embedUrlPattern = RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]+)');
    final shortsUrlPattern = RegExp(r'youtube\.com\/shorts\/([a-zA-Z0-9_-]+)');

    var shortMatch = shortUrlPattern.firstMatch(url);
    if (shortMatch != null) {
      return shortMatch.group(1);
    }

    var regularMatch = regularUrlPattern.firstMatch(url);
    if (regularMatch != null) {
      return regularMatch.group(1);
    }

    var embedMatch = embedUrlPattern.firstMatch(url);
    if (embedMatch != null) {
      return embedMatch.group(1);
    }

    var shortsMatch = shortsUrlPattern.firstMatch(url);
    if (shortsMatch != null) {
      return shortsMatch.group(1);
    }

    return null;
  }

  void _pasteClipboardContent() async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null) {
      _urlController.text = clipboardData.text!;
    }
    notifyListeners();
  }

  void _showSnackbar(String message, bool wantIcon, BuildContext context) {
    if (!_isSnackbarVisible) {
      _isSnackbarVisible = true;
      notifyListeners();

      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Dismiss any currently visible SnackBar
      scaffoldMessenger.hideCurrentSnackBar();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(message)),
              wantIcon
                  ? !message.contains('Storage')
                      ? const Icon(Icons.done, color: Colors.green)
                      : const Icon(
                          Icons.storage,
                          color: Colors.red,
                        )
                  : Container(),
            ],
          ),
          duration: const Duration(seconds: 2),
          onVisible: () {
            Future.delayed(const Duration(seconds: 2), () {
              _isSnackbarVisible = false;
              notifyListeners();
            });
          },
        ),
      );
    }
  }

  void _showDialog(String message, bool wantIcon, BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification'),
          content: const Text('Your File Downloaded Successfully'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                notifyListeners();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    if (!context.mounted) return; // Check if the widget is still mounted

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Storage Permission Required',
              style: TextStyle(fontSize: 15),
            ),
          ),
          content: const Text('Please grant access to storage to continue.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
