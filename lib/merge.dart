import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:sparta/utils/constant.dart';

class Merge extends StatefulWidget {
  int count1,count2;

  Merge(this.count1, this.count2);

  @override
  _MergeState createState() => _MergeState();
}

class _MergeState extends State<Merge> {
  Future<void> download(String url, int fileNumber) async {
    Dio dio=new Dio();
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: (int received, int total) {
          setState(() {


          });

        },
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.statusCode);

      await FileSaver.instance.saveFile("video$fileNumber", response.data, "mp4");

    } catch (e) {
      print("error $e");
    }
  }

  void _videoMerger() async {



    final outputPath = '$rawDocumentPath/outut.mp4';
    final v1 = '$rawDocumentPath/video1.mp4';



    final v2 = '$rawDocumentPath/video2.mp4';
    String path1="";
    for(int i=0;i<4;i++){
      path1+="-i $v1 ";
    }

    print("$v1");

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    String commandToExecute = '-y $path1 -r 24000/1001 -filter_complex \'[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=4:v=1:a=1[out]\' -map \'[out]\' $outputPath';
    _flutterFFmpeg.execute(commandToExecute).then((rc) => print("FFmpeg process exited with rc $rc"));
    GallerySaver.saveVideo(outputPath);
    //_flutterFFmpeg.execute(commandToExecute).then((rc) => print("FFmpeg process exited with rc $rc")).onError((error, stackTrace) => print("rc error ${error.toString()}"));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: (){
                download(beeVideo, 1).then((value){
                  download(testUrl, 2).then((value) => _videoMerger());
                });
              },
              child: Container(
                height: 50,
                width: 100,
                color: Colors.blue,
                child: Text("Merge"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
