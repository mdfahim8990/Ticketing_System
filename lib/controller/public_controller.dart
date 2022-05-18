import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:utsob_ticket/controller/local_helper.dart';
import 'package:utsob_ticket/controller/sqlite_helper.dart';
import 'package:utsob_ticket/model/login_model.dart';
import 'package:utsob_ticket/model/report_model.dart';
import 'package:utsob_ticket/model/ticket_serial_model.dart';
import 'package:utsob_ticket/model/user_model.dart';
import '../model/sqlite_counter_group_model.dart';
import '../model/sqlite_transaction_model.dart';
import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../variables/config.dart';
import 'api_helper.dart';

class PublicController extends GetxController {
  static PublicController pc = Get.find();
  final ApiHelper apiHelper = ApiHelper();
  final SQLiteHelper sqLiteHelper = SQLiteHelper();
  final LocalHelper localHelper = LocalHelper();
  late SharedPreferences? pref;
  RxDouble size = 0.0.obs;
  RxBool loading = false.obs;
  RxBool online = true.obs;

  Rx<DateTime> tempDate = DateTime.now().obs;

  Rx<UserModel> userModel = UserModel().obs;
  Rx<TicketSerialModel> ticketSerialModel = TicketSerialModel().obs;
  Rx<ReportModel> reportModel = ReportModel().obs;

  RxList<SqliteTransactionModel> sqliteTransactionList =
      <SqliteTransactionModel>[].obs;
  RxList<SqliteCounterGroupModel> sqliteCounterGroupList =
      <SqliteCounterGroupModel>[].obs;

  Rx<LoginModel> loginModel = LoginModel().obs;

  Future<void> initApp(BuildContext context) async {
    pref = await SharedPreferences.getInstance();
    if (MediaQuery.of(context).size.width <= 500) {
      size(MediaQuery.of(context).size.width);
    } else {
      size(MediaQuery.of(context).size.height);
    }
    update();
    if (kDebugMode) {
      print('Initialized!!!\n Size: ${size.value}');
    }

    await checkInternet();
    localHelper.getSerialModelFromPref();
    localHelper.getUserFromPref();
    await sqLiteHelper.getCounterGroupList();
    await sqLiteHelper.getTransactionList();
  }

  Future<void> checkInternet() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      online(true);update();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      online(true);update();
    } else {
      online(false);update();
    }if (kDebugMode) {
      print('Device ${online.value ? 'online' : 'offline'}');
    }
  }

  Future<void> login(String username, String password) async {
    loading(true);update();
    bool result = await apiHelper.getLoginResponse(username, password);
    if (result) {
      showToast('Login success');
      Get.offAll(() => const HomePage());
    }
    loading(false);update();
  }

  Future<void> sellTicket(Map<String, dynamic> map) async {
    await apiHelper.getSellTicketResponse(map);
  }

  Future<void> syncOfflineTicket() async {
    showLoading();
    await apiHelper.getSyncTicketResponse();
    closeLoading();
  }

  Future<void> getDailyReport() async {
    loading(true);update();
    await apiHelper.getDailyReportResponse();
    loading(false);update();
  }

  Future<void> logout() async {
    showLoading();
    await apiHelper.getLogOutResponse();
    closeLoading();
    await pref!.clear();
    await pref!.setInt('serialDate', ticketSerialModel.value.dateTime!.millisecondsSinceEpoch); //DateTime.now().millisecondsSinceEpoch
    await pref!.setInt('serialNo', ticketSerialModel.value.serialNo!);
    await pref!.setString('username', userModel.value.username!);
    await pref!.setString('password', userModel.value.password!);
    Get.offAll(() => const LoginPage());
  }

  Future<void> printTicket(Map<String, dynamic> map, String toCounterGroupName, double fare, double toll) async {
    try {
      await SunmiPrinter.initPrinter();
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('উৎসব ট্রান্সপোর্ট লিঃ\n',style: SunmiStyle(bold: true, fontSize: SunmiFontSize.XL));
      // await SunmiPrinter.setCustomFontSize(26);
      // await SunmiPrinter.printText('সিরিয়াল নংঃ ${enToBn(map['sl_no'])}');
      await SunmiPrinter.setCustomFontSize(25);
      await SunmiPrinter.printText('তারিখঃ ${enToBn(DateFormat('dd/MM/yyyy - hh:mm:aa').format(DateTime.now()))}');
      await SunmiPrinter.setCustomFontSize(27);
      await SunmiPrinter.printText('${userModel.value.counterGroupName} টু $toCounterGroupName');
      await SunmiPrinter.setCustomFontSize(27);
      await SunmiPrinter.printText('(ভাড়া ${enToBn(fare.toString())} টাকা + টোল ${enToBn(toll.toString())}\nটাকা প্রতি টিকেট)'
          '= ${enToBn((fare + toll).toString())} টাকা\n');
      await SunmiPrinter.printText('অভিযোগ/রিজার্ভঃ ০১৯১৫১৫০৯০৮,\n০১৯১৩২৬০০০১, ০১৮৩১৩০১০১২\n');
      await SunmiPrinter.printText('Powered by: sukhtaraintltd.com\n01714070437');
      await SunmiPrinter.printText('\n');
      await SunmiPrinter.exitTransactionPrint(true);

      ///Sell Ticket
      await pc.sellTicket(map);
    } catch (e) {
      showToast('Printing Error: $e');
    }
  }

  Future<void> printDailyReport() async {
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.printText(
        'দৈনিকঃ ${enToBn(DateFormat('dd/MM/yyyy').format(reportModel.value.data!.date!))}',
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.LG));
    await SunmiPrinter.setCustomFontSize(27);
    await SunmiPrinter.printText('${pc.pref!.getString('counterName')}',
        style: SunmiStyle(bold: true));
    await SunmiPrinter.setCustomFontSize(26);
    await SunmiPrinter.printText(
        'সর্বমোট টিকিট সংখ্যাঃ ${enToBn(reportModel.value.data!.totalTicket!)} টি');
    await SunmiPrinter.setCustomFontSize(26);
    await SunmiPrinter.printText(
        'সর্বমোট মুল্যঃ ${enToBn(pc.reportModel.value.data!.totalFare!)} টাকা\n');
    await SunmiPrinter.printText('\n');
    await SunmiPrinter.exitTransactionPrint(true);
  }
}
