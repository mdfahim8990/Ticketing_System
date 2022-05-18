import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:utsob_ticket/controller/public_controller.dart';
import '../model/ticket_serial_model.dart';
import '../model/user_model.dart';
import '../variables/config.dart';

class LocalHelper{

  ///Get Ticket Serial Model
  void getSerialModelFromPref(){
    if(PublicController.pc.pref!.getInt('serialDate')!=null && PublicController.pc.pref!.getInt('serialNo')!=null){
      PublicController.pc.ticketSerialModel(
          TicketSerialModel(
              serialNo: DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(PublicController.pc.pref!.getInt('serialDate')!))
                  ==DateFormat('dd-MM-yyyy').format(DateTime.now())
                  ? PublicController.pc.pref!.getInt('serialNo')
                  : 0,
              dateTime: DateTime.now()));
    }else{
      PublicController.pc.ticketSerialModel(TicketSerialModel(serialNo: 0, dateTime: DateTime.now()));
    }
    PublicController.pc.update();
  }

  ///get userModel data from pref
  void getUserFromPref(){
    if( PublicController.pc.pref!.getString('counterId')!=null){
      PublicController.pc.userModel(UserModel(
        counterId: PublicController.pc.pref!.getString('counterId'),
        counterName: PublicController.pc.pref!.getString('counterName'),
        counterManName: PublicController.pc.pref!.getString('counterManName'),
        username: PublicController.pc.pref!.getString('username'),
        counterGroupId: PublicController.pc.pref!.getString('counterGroupId'),
        counterGroupName: PublicController.pc.pref!.getString('counterGroupName'),
        mobile: PublicController.pc.pref!.getString('mobile'),
        token: PublicController.pc.pref!.getString('token'),
      ));
    } PublicController.pc.update();
  }

  ///Save Counter To Pref and userModel
  void saveCounterToPrefAndUserModel(){
    ///Save Counter to pref
    PublicController.pc.pref!.setString('counterId', PublicController.pc.loginModel.value.counter!.id.toString());
    PublicController.pc.pref!.setString('counterName', PublicController.pc.loginModel.value.counter!.counterName!);
    PublicController.pc.pref!.setString('counterManName', PublicController.pc.loginModel.value.counter!.countermanName!);
    PublicController.pc.pref!.setString('username', PublicController.pc.loginModel.value.counter!.username!);
    PublicController.pc.pref!.setString('counterGroupId', PublicController.pc.loginModel.value.counter!.counterGroupId!);
    PublicController.pc.pref!.setString('counterGroupName', PublicController.pc.loginModel.value.counter!.counterGroupName!);
    PublicController.pc.pref!.setString('mobile', PublicController.pc.loginModel.value.counter!.mobile!);
    PublicController.pc.pref!.setString('token', PublicController.pc.loginModel.value.accessToken!);

    ///save data to userModel
    PublicController.pc.userModel(UserModel(
      counterId: PublicController.pc.pref!.getString('counterId'),
      counterName: PublicController.pc.pref!.getString('counterName'),
      counterManName: PublicController.pc.pref!.getString('counterManName'),
      username: PublicController.pc.pref!.getString('username'),
      counterGroupId: PublicController.pc.pref!.getString('counterGroupId'),
      counterGroupName: PublicController.pc.pref!.getString('counterGroupName'),
      mobile: PublicController.pc.pref!.getString('mobile'),
      token: PublicController.pc.pref!.getString('token'),
      password: PublicController.pc.pref!.getString('password')
    ));

  }

  Future<LocationData?> getDeviceLocation()async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _locationData = await location.getLocation();
    if (kDebugMode) {
      print('Lat: ${_locationData.latitude}\nLong: ${_locationData.longitude}');
    }
    return _locationData;
  }

  Future<void> checkDay()async{
    if(DateFormat('dd-MM-yyyy').format(PublicController.pc.tempDate.value)==DateFormat('dd-MM-yyyy').format(DateTime.now())){
      PublicController.pc.tempDate(DateTime.now());
      PublicController.pc.update();
      await Future.delayed(const Duration(seconds: 30)).then((value){
        if (kDebugMode) {print('Same Day');}
        checkDay();
      });
    }else{
      await PublicController.pc.checkInternet();
      if(PublicController.pc.online.value==true){
        if(PublicController.pc.sqliteTransactionList.isEmpty){
          await PublicController.pc.syncOfflineTicket();
        }
        await PublicController.pc.logout();
      }else{
        if (kDebugMode) {print('Logout not possible for internet connection');}
        await Future.delayed(const Duration(seconds: 30));
        checkDay();
      }
    }
  }

  // Future<Position?> getDeviceCoordinate()async{
  //   var permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.always) {
  //       Position position = await Geolocator.getCurrentPosition();
  //       if (kDebugMode) {
  //         print('Position: ${position.latitude}, ${position.longitude}');
  //       }
  //       return position;
  //     }else{
  //       showToast('লোকেশন অনুমতি প্রয়োজন');
  //     }
  //   }else if(permission == LocationPermission.always){
  //     Position position = await Geolocator.getCurrentPosition(); //desiredAccuracy: LocationAccuracy.high
  //     if (kDebugMode) {
  //       print('Position: ${position.latitude}, ${position.longitude}');
  //     }
  //     return position;
  //   }else{
  //     showToast('লোকেশন অনুমতি প্রয়োজন');
  //   }
  //   return null;
  // }


  // Future<Position?> getGeoLocationPosition() async {
  //   try{
  //     bool serviceEnabled;
  //     LocationPermission permission;
  //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       await Geolocator.openLocationSettings();
  //       return null;
  //     }
  //     permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         showToast('Location permissions are denied');
  //         return null;
  //       }
  //     }
  //     if (permission == LocationPermission.deniedForever) {
  //       showToast('Location permissions are permanently denied.');
  //       return null;
  //     }
  //     return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   }catch(e){
  //     showToast('Can\'t get location');
  //     if (kDebugMode) {print(e.toString());}
  //     return null;
  //   }
  // }
}