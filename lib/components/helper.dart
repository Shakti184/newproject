import 'package:flutter/material.dart';

class Helper{
  static customAlertBox(BuildContext context,String text){
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text(text),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: const Text("OK")),
        ],
      );
    });
  }
}