import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:sparta/utils/constant.dart';
import 'package:sparta/utils/merged_player.dart';
import 'package:sparta/utils/video_widget.dart';
import 'package:sparta/widget/custom_appbar.dart';

class OutputScreen extends StatefulWidget {
  String path;

  OutputScreen(this.path);

  @override
  _OutputScreenState createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar("Merged Video", true),
            Expanded(
              child: MergedPlayer(
                true,
                widget.path
              ),
            ),
            InkWell(
              onTap: (){
                GallerySaver.saveVideo(widget.path).then((value){
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.success,
                    text: "Video Saved",
                  );
                }).onError((error, stackTrace){
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: "Unable to save video",
                  );
                });
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(7)
                ),
                child: Text("SAVE VIDEO",style: const TextStyle(fontSize:18,color: Colors.white,fontWeight: FontWeight.w300),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
