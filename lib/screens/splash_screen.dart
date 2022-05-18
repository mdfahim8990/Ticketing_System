import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:utsob_ticket/screens/home_page.dart';
import '../../controller/public_controller.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  @override
  initState(){
    super.initState();
    _initData();
  }

  Future<void> _initData()async{
    await SunmiPrinter.bindingPrinter();
    //_periodicBackgroundTask();
    await Future.delayed(const Duration(seconds: 3));

      ///Auto Login
      if(PublicController.pc.pref!.getString('counterId')!=null && PublicController.pc.pref!.getInt('serialDate')!=null){
        if(DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(PublicController.pc.pref!.getInt('serialDate')!))
        == DateFormat('dd-MM-yyyy').format(DateTime.now())){
          Get.offAll(()=>const HomePage());
        }else{Get.offAll(()=>const LoginPage());}
      }else{Get.offAll(()=>const LoginPage());}
  }

  // void _periodicBackgroundTask(){
  //   // Periodic task registration
  //   Workmanager().registerPeriodicTask(
  //     "Task-1", "simplePeriodicTask",
  //     initialDelay: const Duration(minutes: 5),
  //     constraints: Constraints(networkType: NetworkType.connected),
  //     frequency: const Duration(minutes: 15),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light
        ));
    return GetBuilder<PublicController>(
      builder: (publicController) {
        if(publicController.size.value<=0.0) publicController.initApp(context);
        return Scaffold(
          body: Center(
            child: Image.asset('assets/bus.gif'),
          ),
        );
      }
    );
  }
}
