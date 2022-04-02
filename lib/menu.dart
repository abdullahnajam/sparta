import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:sparta/choose_video.dart';
import 'package:sparta/merge.dart';
import 'package:sparta/output.dart';
import 'package:sparta/provider/video_provider.dart';
import 'package:sparta/utils/constant.dart';
import 'package:sparta/utils/video_widget.dart';
import 'package:sparta/widget/custom_appbar.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  int video1Counter=1;int video2Counter=1;
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



    final outputPath = '$rawDocumentPath/output.mp4';

    final v1 = '$rawDocumentPath/video1.mp4';
    final loop1 = '$rawDocumentPath/loop1.mp4';
    final filtered1 = '$rawDocumentPath/filtered1.mp4';



    final v2 = '$rawDocumentPath/video2.mp4';
    final loop2 = '$rawDocumentPath/loop2.mp4';
    final filtered2 = '$rawDocumentPath/filtered2.mp4';
    String path1="";
    String path2="";
    for(int i=0;i<video1Counter;i++){
      path1+="-i $v1 ";
    }
    for(int i=0;i<video2Counter;i++){
      path2+="-i $v2 ";
    }

    print("$v1");

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    String commandToExecute = '-y -i $filtered1 -i $filtered2 -r 24000/1001 -filter_complex \'[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=2:v=1:a=1[out]\' -map \'[out]\' $outputPath';
    String cmdLoop1 = '-y $path1 -r 24000/1001 -filter_complex \'[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=$video1Counter:v=1:a=1[out]\' -map \'[out]\' $loop1';
    String cmdLoop2 = '-y $path2 -r 24000/1001 -filter_complex \'[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=$video2Counter:v=1:a=1[out]\' -map \'[out]\' $loop2';
    int l1=await _flutterFFmpeg.execute(cmdLoop1);
    int l2=await _flutterFFmpeg.execute(cmdLoop2);
    int f1=await _flutterFFmpeg.execute('-y -i $loop1 -vf scale=640:480 -aspect 16:9 $filtered1');
    int f2=await _flutterFFmpeg.execute('-y -i $loop2 -vf scale=640:480  -aspect 16:9 $filtered2');
    _flutterFFmpeg.execute(commandToExecute).then((rc){
      if(rc==0){
        pr!.close();
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OutputScreen(outputPath)));
      }
      else{
        pr!.close();
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "$rc : Something went wrong l1=$l1, l2=$l2, f1=$f1, f2=$f2",
        );
      }
    }).onError((error, stackTrace){
      pr!.close();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "${error.toString()}",
      );
    });

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_){
      final provider = Provider.of<VideoProvider>(context, listen: false);
      pr= ProgressDialog(context: context);
      setState(() {
        video1Counter=provider.count1 ?? 1;
        video2Counter=provider.count2 ?? 1;
      });
    });
  }
  ProgressDialog? pr;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar("Sparta", false),
            Expanded(
              flex: 4,
              child:provider.video1==null?InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseVideo(1)));

                },
                child: Container(
                  margin: EdgeInsets.all(20),
                  color: Colors.white,
                  child: DottedBorder(
                      color: primaryColor,
                      strokeWidth: 1,
                      dashPattern: [7],
                      borderType: BorderType.Rect,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/upload.png",color: primaryColor,height: 50,width: 50,fit: BoxFit.cover,),
                            SizedBox(height: 10,),
                            Text("Select Video",style: TextStyle(color: primaryColor,fontWeight: FontWeight.w300),)
                          ],
                        ),
                      )
                  ),
                ),
              ):Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text("Video # 1 - ${provider.video1!.title}",style: TextStyle(fontSize:18,color: primaryColor),),
                        ),
                        IconButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseVideo(1)));
                          },
                          icon: Icon(Icons.edit,color: primaryColor,),
                        )
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {

                              video1Counter++;
                              provider.setCount1(video1Counter);
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryColor,width: 3)
                            ),
                            child: Icon(Icons.add,color: primaryColor,size: 50,),
                          ),
                        ),
                        Container(
                          child: Text(video1Counter.toString(),style: TextStyle(fontSize:50,color: primaryColor),),
                        ),
                        InkWell(
                          onTap: (){
                            if(video1Counter>1) {
                              setState(() {
                                video1Counter--;
                                provider.setCount1(video1Counter);
                              });
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryColor,width: 3)
                            ),
                            child: Icon(Icons.remove,color: primaryColor,size: 50,),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ),
            Expanded(
              flex: 4,
              child: provider.video2==null?InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseVideo(2)));

                },
                child: Container(
                  margin: EdgeInsets.all(20),
                  color: Colors.white,
                  child: DottedBorder(
                      color: primaryColor,
                      strokeWidth: 1,
                      dashPattern: [7],
                      borderType: BorderType.Rect,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/upload.png",color: primaryColor,height: 50,width: 50,fit: BoxFit.cover,),
                            SizedBox(height: 10,),
                            Text("Select Video",style: TextStyle(color: primaryColor,fontWeight: FontWeight.w300),)
                          ],
                        ),
                      )
                  ),
                ),
              ):
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text("Video # 2 - ${provider.video2!.title}",style: TextStyle(fontSize:18,color: primaryColor),),
                            ),
                            IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChooseVideo(2)));
                              },
                              icon: Icon(Icons.edit,color: primaryColor,),
                            )
                          ],
                        ),

                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  video2Counter++;
                                  provider.setCount2(video2Counter);
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryColor,width: 3)
                                ),
                                child: Icon(Icons.add,color: primaryColor,size: 50,),
                              ),
                            ),
                            Container(
                              child: Text(video2Counter.toString(),style: TextStyle(fontSize:50,color: primaryColor),),
                            ),
                            InkWell(
                              onTap: (){
                                if(video2Counter>1) {
                                  setState(() {
                                  video2Counter--;
                                  provider.setCount2(video2Counter);
                                });
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryColor,width: 3)
                                ),
                                child: Icon(Icons.remove,color: primaryColor,size: 50,),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
            ),
            InkWell(
              onTap: (){
                if(provider.video1!=null && provider.video2!=null){
                pr!.show(max: 100, msg: 'Merging');
                  download(provider.video1!.url, 1).then((value){
                    download(provider.video2!.url, 2).then((value) => _videoMerger()).onError((error, stackTrace) {
                      pr!.close();
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.error,
                        text: "Unable to load video # 2",
                      );
                    });
                  }).onError((error, stackTrace) {
                    pr!.close();
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.error,
                      text: "Unable to load video # 1",
                    );
                  });
                }
                else{
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: "Please select both videos",
                  );
                }
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
                child: Text("MERGE VIDEOS",style: const TextStyle(fontSize:18,color: Colors.white,fontWeight: FontWeight.w300),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
