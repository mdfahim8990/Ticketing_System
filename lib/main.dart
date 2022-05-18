import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsob_ticket/screens/splash_screen.dart';
import 'package:utsob_ticket/variables/variable.dart';
import 'controller/public_controller.dart';

// void callbackDispatcher() {
//   Get.put(PublicController());
//   Workmanager().executeTask((taskName, inputData) {
//     print("********************* Native called background task: $taskName *********************");
//     ApiHelper().getLogOutResponse();
//     return Future.value(true);
//   });
// }

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Variables().statusBarTheme;
  Variables.portraitMood;
  Get.put(PublicController());
  ///Background Task
  //Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fahim টিকেট',
      debugShowCheckedModeBanner: false,
      theme: Variables.themeData,
      home: const SplashScreen(),
    );
  }
}

