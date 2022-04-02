import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparta/menu.dart';
import 'package:sparta/model/video_model.dart';
import 'package:sparta/provider/video_provider.dart';
import 'package:sparta/utils/constant.dart';
import 'package:sparta/utils/video_widget.dart';
import 'package:sparta/widget/custom_appbar.dart';
import 'package:video_player/video_player.dart';

class ChooseVideo extends StatefulWidget {
  int videoNumber;

  ChooseVideo(this.videoNumber);

  @override
  _ChooseVideoState createState() => _ChooseVideoState();
}

class _ChooseVideoState extends State<ChooseVideo> {




  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child:
        Column(
          children: [
            CustomAppBar("Choose Video", true),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('videos').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      VideoModel video=VideoModel.fromMap(data, document.reference.id);
                      return Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height*0.4,
                            width: MediaQuery.of(context).size.width,
                            child: VideoWidget(
                              true,
                              video.url,
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              if(widget.videoNumber==1){
                                provider.setVideo1(video);

                              }
                              else{
                                provider.setVideo2(video);
                              }
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                  MainMenu()), (Route<dynamic> route) => false);
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
                              child: Text("SELECT VIDEO",style: const TextStyle(fontSize:18,color: Colors.white,fontWeight: FontWeight.w300),),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            /*if(videosLoad && videos.length==0)
              Center(
                child: Text("No Videos Found"),
              )
            else if(videosLoad)
              Expanded(
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (BuildContext context,int index){
                    return  InkWell(
                      onTap: (){
                        setState(() {

                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.4,
                        width: double.infinity,
                        child: VideoWidget(
                           true,
                            videos[index].url,
                        ),
                      ),

                    );
                  },
                ),
              )
            else
              Center(
                child: CircularProgressIndicator(),
              )*/
          ],
        ),
      ),
    );
  }


}
