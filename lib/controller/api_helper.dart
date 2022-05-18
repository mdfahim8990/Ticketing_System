import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:utsob_ticket/controller/local_helper.dart';
import 'package:utsob_ticket/controller/public_controller.dart';
import 'package:utsob_ticket/controller/sqlite_helper.dart';
import 'package:utsob_ticket/model/login_model.dart';
import 'package:utsob_ticket/model/report_model.dart';
import 'package:utsob_ticket/variables/variable.dart';
import '../model/sqlite_transaction_model.dart';
import '../variables/config.dart';

class ApiHelper{
  final SQLiteHelper sqLiteHelper = SQLiteHelper();
  final LocalHelper localHelper = LocalHelper();

  Future<bool> getLoginResponse(String username, String password)async{
    LocationData? location = await LocalHelper().getDeviceLocation();
    try{
      http.Response response = await http.post(
          Uri.parse(Variables.baseUrl+'auth/login'),
        body: {
          'username': username,
          'password': password,
          'lat': location!=null?location.latitude.toString():'0.0',
          'long': location!=null?location.longitude.toString():'0.0',
          'date':DateTime.now().toString()
        }
      );
      if(response.statusCode==200){
        PublicController.pc.loginModel(loginModelFromJson(response.body));

        ///Save Counter List To SQLite DB
        await sqLiteHelper.storeAllCounterGroupToOffline(PublicController.pc.loginModel.value.counterGroupList!);

        ///Save Ticket serial
        PublicController.pc.pref!.setInt('serialNo', PublicController.pc.loginModel.value.counter!.lastSlNo!=null
            ? int.parse(PublicController.pc.loginModel.value.counter!.lastSlNo!)
            : 0);
        PublicController.pc.pref!.setInt('serialDate', DateTime.now().millisecondsSinceEpoch);

        ///Save password
        PublicController.pc.pref!.setString('password', password);

        localHelper.getSerialModelFromPref();
        localHelper.saveCounterToPrefAndUserModel();

        if (kDebugMode) {
          print(PublicController.pc.userModel.value.token);
        }
        return true;
      }else{
        showToast('Login failed');
        return false;
      }
    }on SocketException{
      showToast('ইন্টারনেট সংযোগ নেই');
      return false;
    } catch(e){
      showToast('Login Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> getLogOutResponse()async{
    LocationData? location = await LocalHelper().getDeviceLocation();
    try{
      http.Response response = await http.post(
          Uri.parse(Variables.baseUrl+'auth/logout'),
          headers:{'Authorization': 'Bearer ${PublicController.pc.pref!.getString('token')}'},
        body: {
          'lat': location!=null?location.latitude.toString():'0.0',
          'long': location!=null?location.longitude.toString():'0.0',
          'counter_id': PublicController.pc.pref!.getString('counterId'),
          'date':DateTime.now().toString()
        }
      );
      if (kDebugMode) {
        print(response.body);
      }
      if(response.statusCode==200){
        return true;
      }else{return false;}
    }on SocketException{
      showToast('ইন্টারনেট সংযোগ নেই');
      return false;
    } catch(e){
      if (kDebugMode) {print(e.toString());}
      return false;
    }
  }

  Future<void> getSellTicketResponse(Map<String, dynamic> map)async{
    ///Save Counter to pref
    PublicController.pc.pref!.setInt('serialDate', DateTime.now().millisecondsSinceEpoch);
    PublicController.pc.pref!.setInt('serialNo', int.parse(map['sl_no']));
    localHelper.getSerialModelFromPref();

    SqliteTransactionModel offLineModel = SqliteTransactionModel(
        map['from_counter_id'].toString(),
        map['to_group_id'].toString(),
        map['total_fare'].toString(),
        map['regular_fare'].toString(),
        map['student_fare'].toString(),
        map['toll'].toString(),
        map['sl_no'].toString(),
        DateTime.now().toString()
    );

    try{
      http.Response response = await http.post(
          Uri.parse(Variables.baseUrl+'transaction/single-transaction'),
          headers:{
            'Authorization': 'Bearer ${PublicController.pc.pref!.getString('token')}',
          }, body: {
            'from_counter_id': map['from_counter_id'],
            'to_group_id': map['to_group_id'],
            'total_fare': map['total_fare'],
            'regular_fare': map['regular_fare'],
            'student_fare': map['student_fare'],
            'toll': map['toll'],
            'sl_no': map['sl_no'],
            'date': map['date']
          });
      var jsonData=jsonDecode(response.body);
      if(jsonData['success']==true){
        showToast('Online');
      }else{
        await sqLiteHelper.insertTransaction(offLineModel);
        showToast('Offline');
      }
    }on SocketException{
      await sqLiteHelper.insertTransaction(offLineModel);
      showToast('Offline');
    }
    catch(e){
      await sqLiteHelper.insertTransaction(offLineModel);
      if (kDebugMode) {
        print(e.toString());
      }
      showToast('Offline');
    }
  }

  Future<void> getSyncTicketResponse()async{
    List<Map<String,dynamic>> transactionList=[];
    for(var e in PublicController.pc.sqliteTransactionList){
      transactionList.add({
        'from_counter_id': e.fromCounterId,
        'to_group_id': e.toGroupId,
        'total_fare': e.totalFare,
        'regular_fare': e.regularFare,
        'student_fare': e.studentFare,
        'toll': e.toll,
        'sl_no': e.slNo,
        'date': e.date
      });}
    var bodyData = json.encode(transactionList);

    try{
      http.Response response = await http.post(
          Uri.parse(Variables.baseUrl+'transaction/sync'),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${PublicController.pc.pref!.getString('token')}',
          }, body: bodyData);
      var jsonData=jsonDecode(response.body);
      if(jsonData['success']){
        showToast('Success');
        sqLiteHelper.deleteTransactionList();
      }else {
        showToast('Failed');
      }
    }on SocketException{
      showToast('ইন্টারনেট সংযোগ নেই');
    }
    catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
      showToast(e.toString());
    }
  }

  Future<void> getDailyReportResponse()async{
    try{
      http.Response response = await http.post(
          Uri.parse(Variables.baseUrl+'transaction/daily-report'),
          headers:{
            'Authorization': 'Bearer ${PublicController.pc.pref!.getString('token')}',
          },body: {
        'counter_id': PublicController.pc.pref!.getString('counterId'),
        'date': DateTime.now().toString()
      });
      var jsonData = jsonDecode(response.body);
      if(response.statusCode==200){
        if(jsonData['data']!=null){
          PublicController.pc.reportModel(reportModelFromJson(response.body));
          ///Save Counter to pref
          PublicController.pc.pref!.setInt('serialDate', DateTime.now().millisecondsSinceEpoch);
          PublicController.pc.pref!.setInt('serialNo', int.parse(PublicController.pc.reportModel.value.data!.totalTicket!));
        }else{
          PublicController.pc.reportModel.value.data!.totalFare='0';
          PublicController.pc.reportModel.value.data!.totalTicket='0';
          PublicController.pc.reportModel.value.data!.totalFare='0';
        }
      }else {
        showToast('Failed');
      }
    }on SocketException{
      showToast('ইন্টারনেট সংযোগ নেই');
    } catch(e){
      if (kDebugMode) {print(e.toString());}
    }
  }
}