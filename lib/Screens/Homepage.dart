import 'package:downv2/services/AllServices.dart';
import 'package:downv2/utils/consts.dart';
import 'package:downv2/widgets/AlertMessage.dart';
import 'package:downv2/widgets/DownloadRow.dart';
import 'package:downv2/widgets/DownloadButton.dart';
import 'package:downv2/widgets/LinkTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class FileDownloader extends StatefulWidget {
  const FileDownloader({super.key});

  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader>
    with WidgetsBindingObserver {


  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff10475b),
        appBar: AppBar(
            backgroundColor: const Color(0xff10475b),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Youtube Downloader",
                  style: TextStyle(color: Colors.white),
                ),
                Lottie.asset(
                  'assets/download.json',
                  height: 50,
                  width: 50,
                )
              ],
            )),
        body: Consumer<services>(
          builder: (BuildContext context, value, Widget? child) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(BackgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const LinkTextfield(),
                          const SizedBox(height: 20),
                          Provider.of<services>(context, listen: true)
                                  .isDownloading
                              ? const StartDownloadRow()
                              : const DownloadButton(),
                                      Provider.of<services>(context, listen: true)
                                  .isDownloading?Text((Provider.of<services>(context, listen: true).progress*100).toStringAsFixed(2)+'%'):Container()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
