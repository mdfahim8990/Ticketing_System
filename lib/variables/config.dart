import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:utsob_ticket/variables/variable.dart';

import '../controller/public_controller.dart';

double dSize(double size){
  return PublicController.pc.size.value*size;
}

void showToast(message) => Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.SNACKBAR,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0
);

void showLoading(){
  showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_)=>AlertDialog(
        scrollable: true,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: dSize(.04)),
            Expanded(child: Text('Please wait...',style: Variables.textStyle))
          ],
        ),
  ));
}
void closeLoading(){
  Get.back();
}

String enToBn(String bnString){
  String enString = bnString.replaceAll('0','০').replaceAll('1','১')
      .replaceAll('2','২').replaceAll('3','৩').replaceAll('4','৪')
      .replaceAll('5','৫').replaceAll('6','৬').replaceAll('7','৭')
      .replaceAll('8','৮').replaceAll('9','৯');
  return enString;
}