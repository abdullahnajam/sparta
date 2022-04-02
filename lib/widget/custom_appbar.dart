import 'package:flutter/material.dart';
import 'package:sparta/utils/constant.dart';

class CustomAppBar extends StatefulWidget {
  String title;bool back;
  CustomAppBar(this.title,this.back);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.2, color: Colors.grey),
        ),
      ),
      height: AppBar().preferredSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: widget.back?InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back,color: primaryColor,size: 20,),
                    )
                ):Container(),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(widget.title,textAlign: TextAlign.center,style: TextStyle(color: primaryColor),)
              ),
              Container(),
            ],
          ),
        ],
      ),
    );
  }
}
