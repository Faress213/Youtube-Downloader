import 'package:downv2/services/AllServices.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class StartDownloadRow extends StatelessWidget {
  const StartDownloadRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<services>(
      builder: (context, value, child) {
        return Row(
          children: [
            Expanded(
                child: LinearPercentIndicator(
              percent: value.progress,
            )),
            Row(
              children: [
                IconButton(
                    onPressed: value.isPaused
                        ? value.resumeDownload
                        : value.pauseDownload,
                    icon: value.isPaused
                        ? const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.pause,
                            color: Colors.white,
                          )),
                IconButton(
                    onPressed: () {
                      value.cancelDownload(context);
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                    )),
              ],
            )
          ],
        );
      },
    );
  }
}
