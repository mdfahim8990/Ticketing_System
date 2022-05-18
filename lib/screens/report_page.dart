import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:utsob_ticket/controller/public_controller.dart';
import 'package:utsob_ticket/variables/config.dart';
import 'package:utsob_ticket/variables/variable.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);
  @override
  State<ReportPage> createState() => _ReportPageState();
}
class _ReportPageState extends State<ReportPage> {

  @override
  void initState() {
    super.initState();
    _getReport();
  }

  Future<void> _getReport()async{
    await Future.delayed(const Duration(milliseconds: 2));
    await PublicController.pc.getDailyReport();
  }

  @override
  Widget build(BuildContext context) {
    Variables().statusBarTheme;
    return GetBuilder<PublicController>(
      builder: (pc){
        return Scaffold(
          backgroundColor: Colors.blueGrey.shade100,
          appBar: AppBar(
            elevation: 0.0,
            title: Text('টিকেট বিক্রির রিপোর্ট',style: Variables.whiteTextStyle.copyWith(fontSize: dSize(.05))),
          ),
          body: !pc.loading.value
              ? _bodyUI(pc)
              : const Center(child: CircularProgressIndicator()),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: dSize(.04)),
            child: ElevatedButton(
              onPressed: ()async{
                if(pc.reportModel.value.data!=null){
                  await pc.printDailyReport();
                }else{showToast('');}
              },
              child: Text('প্রিন্ট রিপোর্ট',style: Variables.whiteTextStyle.copyWith(fontSize: dSize(.045))),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
            ),
          ),
        );
      }
    );
  }

  Widget _bodyUI(PublicController pc)=>Center(
    child: pc.reportModel.value.data!=null? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
         padding: EdgeInsets.all(dSize(.05)),
         child: Card(
           child: Padding(
             padding: EdgeInsets.all(dSize(.04)),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('দৈনিকঃ ${enToBn(DateFormat('dd/MM/yyyy').format(pc.reportModel.value.data!.date!))}',style: Variables.textStyle.copyWith(fontSize: dSize(.06))),
                 Text('সর্বমোট টিকেট সংখ্যাঃ ${enToBn(pc.reportModel.value.data!.totalTicket!)} টি',style: Variables.textStyle.copyWith(fontSize: dSize(.06))),
                 Text('সর্বমোট মুল্যঃ ${enToBn(pc.reportModel.value.data!.totalFare!)} ৳',style: Variables.textStyle.copyWith(fontSize: dSize(.06))),
               ],
             ),
           ),
         ),
        )
      ],
    ):Text('কোন রিপোর্ট খুজে পাওয়া যায়নি',style: Variables.textStyle.copyWith(fontSize: dSize(.06))),
  );
}
