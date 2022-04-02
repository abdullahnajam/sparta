import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel{
  String id,url,title;

  VideoModel(this.id,this.url,this.title);

  VideoModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        url = map['url'],
        title = map['title'];

  VideoModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}