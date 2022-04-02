import 'package:flutter/cupertino.dart';
import 'package:sparta/model/video_model.dart';

class VideoProvider extends ChangeNotifier {
  VideoModel? video1;
  VideoModel? video2;
  int? count1,count2;

  void setVideo1(VideoModel video) {
    this.video1 = video;
    notifyListeners();
  }

  void setCount1(int count) {
    this.count1 = count;
    notifyListeners();
  }
  void setCount2(int count) {
    this.count2 = count;
    notifyListeners();
  }

  void setVideo2(VideoModel video) {
    this.video2 = video;
    notifyListeners();
  }
}
