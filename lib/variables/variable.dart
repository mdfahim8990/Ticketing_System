import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utsob_ticket/variables/config.dart';
import 'color_variable.dart';

class Variables {
  //static const String baseUrl = 'http://uthsobticketing.sukhtaraintltd.com/api/';
  static const String baseUrl = 'http://uthsobdemo.binduitsolutions.com/api/';

  var statusBarTheme = SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: AllColor.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light
      ));

  static var portraitMood = SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  static ThemeData themeData = ThemeData(
      primarySwatch: const MaterialColor(0xffAA7B29, AllColor.primaryColorMap),
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionHandleColor: AllColor.primaryColor,
          selectionColor: Colors.cyan)
  );

  static TextStyle textStyle = TextStyle(color: AllColor.textColor,fontSize: dSize(.045));
  static TextStyle whiteTextStyle = TextStyle(color: Colors.white,fontSize: dSize(.045));

}