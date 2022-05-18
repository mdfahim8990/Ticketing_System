import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsob_ticket/controller/local_helper.dart';
import 'package:utsob_ticket/controller/public_controller.dart';
import 'package:utsob_ticket/controller/sqlite_helper.dart';
import 'package:utsob_ticket/screens/report_page.dart';
import 'package:utsob_ticket/tile/counter_tile.dart';
import 'package:utsob_ticket/variables/color_variable.dart';
import 'package:utsob_ticket/variables/config.dart';
import 'package:utsob_ticket/variables/variable.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<PopupMenuButtonState<int>> _key = GlobalKey();
  bool _isStudent=false;
  double _fare = 0.0;
  double _toll = 0.0;

  @override
  void initState() {
    super.initState();
    PublicController.pc.tempDate(DateTime.now());
   Future.delayed(const Duration(milliseconds: 50)).then((value) => LocalHelper().checkDay());
  }

  @override
  Widget build(BuildContext context) {
    Variables().statusBarTheme;
    return GetBuilder<PublicController>(
      builder: (pc) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(dSize(.15)),
            child: SafeArea(
              child: Container(
                height: dSize(.15),
                padding: EdgeInsets.only(left: dSize(.04),top: dSize(.02),bottom: dSize(.02)),
                color: AllColor.primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${pc.userModel.value.counterManName}',maxLines: 1,style: Variables.whiteTextStyle),
                          Text('${pc.userModel.value.mobile}',maxLines:1,style: Variables.whiteTextStyle.copyWith(fontSize: dSize(.035))),
                        ],
                      ),
                    ),

                    ///Sync Button
                    ElevatedButton(
                      onPressed: ()async{
                        showLoading();
                        await pc.checkInternet();
                        await SQLiteHelper().getTransactionList();
                        closeLoading();
                        if(pc.online.value==true){
                          if(pc.sqliteTransactionList.isNotEmpty){
                            await pc.syncOfflineTicket();
                          }else{showToast('সব আপ টু ডেট');}
                        }else{showToast('ইন্টারনেট সংযোগ নেই');}
                      },
                      child: Text('sync',style: Variables.whiteTextStyle),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                    ),
                    SizedBox(width: dSize(.02)),
                    ElevatedButton(
                      onPressed: ()async{
                        showLoading();
                        await pc.checkInternet();
                        await SQLiteHelper().getTransactionList();
                        closeLoading();
                        if(pc.online.value==true){
                          if(pc.sqliteTransactionList.isEmpty){
                            Get.to(()=>const ReportPage());
                          }else{showToast('প্রথমে Sync করুন');}
                        }else{showToast('ইন্টারনেট সংযোগ নেই');}
                      },
                      child: Text('রিপোর্ট',style: Variables.whiteTextStyle),
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                    ),


                    ///Popup menu
                    PopupMenuButton<int>(
                      key: _key,
                      onSelected: (int val)async{
                        if(val==1){
                          showLoading();
                          await pc.checkInternet();
                          closeLoading();
                          await SQLiteHelper().getTransactionList();
                          if(pc.online.value==true){
                            if(pc.sqliteTransactionList.isEmpty){
                              await pc.logout();
                            }else{showToast('প্রথমে Sync করুন');}
                          }else{showToast('ইন্টারনেট সংযোগ নেই');}
                        }
                      },
                      itemBuilder: (context) {
                        return <PopupMenuEntry<int>>[
                          PopupMenuItem(
                            child: Text('লগ আউট',style: Variables.textStyle), value: 1,
                            padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                          ),
                        ];
                      },
                      padding: const EdgeInsets.all(0.0),
                      icon: Icon(Icons.more_vert,color: Colors.white,size: dSize(.07)),
                      tooltip: 'যেকোনো একটি নির্বাচন করুন',
                      offset: Offset(0,dSize(.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: _bodyUI(pc),
        );
      }
    );
  }

  Widget _bodyUI(PublicController pc)=>Column(
    children: [
      ///My Counter
      if(pc.userModel.value.counterName!=null)
      Container(
        padding: EdgeInsets.all(dSize(.025)),
        margin: EdgeInsets.all(dSize(.03)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(dSize(.01))),
            border: Border.all(color:  AllColor.primaryColor),
        ), child: Text('${pc.userModel.value.counterName}',textAlign:TextAlign.center,
          style: Variables.textStyle.copyWith(fontSize: dSize(.05),fontWeight: FontWeight.bold)),
      ),

      ///Counter List
      Expanded(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(dSize(.03)),
          children: [
            ///Counter List
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pc.sqliteCounterGroupList.length,
              itemBuilder: (context, index)=>Material(
                child: InkWell(
                  onTap: ()async{await _sellTicket(pc, index);},
                  child: CounterTile(model: pc.sqliteCounterGroupList[index]),
                  splashColor: Colors.white54,
                  highlightColor: Colors.white54),
                borderRadius: BorderRadius.circular(5),
                color: Colors.amber,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.9,
                crossAxisSpacing: dSize(.03),
                mainAxisSpacing: dSize(.03)),
            )
          ]
        ),
      ),

      ///Bottom Nav
      _bottomNav()
    ],
  );

  Widget _bottomNav()=>Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.all(dSize(.03)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ///Total Price
        Row(
          children: [
            Text('টিকেটের মুল্যঃ ${enToBn((_fare+_toll).toString())} ৳',style: Variables.textStyle.copyWith(fontSize: dSize(.055))),
            Expanded(
              child: ///Student Fair
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isStudent,
                    onChanged: (val)=>setState((){
                      _isStudent=val!;
                    }),
                  ),
                  Text('ছাত্র/ছাত্রী',style: Variables.textStyle.copyWith(fontSize: dSize(.055)))
                ],
              ),
            )
          ],
        ),

        ///Ticket Quantity
        // Row(
        //   children: [
        //     Text('টিকিট সংখ্যাঃ',style: Variables.textStyle.copyWith(fontSize: dSize(.055))),
        //     SizedBox(width: dSize(.04)),
        //
        //     Expanded(
        //       child: Container(
        //         decoration: BoxDecoration(
        //           border: Border.all(color: AllColor.primaryColor),
        //           borderRadius: BorderRadius.all(Radius.circular(dSize(.5)))
        //         ),
        //         child: Row(
        //           children: [
        //            QuantityButton(onTap: (){
        //              if(_quantity>1){
        //                setState(()=>_quantity--);
        //              }
        //            }, icon: Icons.remove),
        //             Expanded(child: Text(enToBn('$_quantity'),textAlign:TextAlign.center,style: Variables.textStyle.copyWith(fontSize: dSize(.065)))),
        //             QuantityButton(
        //               onTap: (){
        //                 setState(()=>_quantity++);
        //             }, icon: Icons.add),
        //           ],
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      ],
    ),
  );

  Future<void> _sellTicket(PublicController pc, int index)async{
    setState(() {
      _fare = _isStudent
          ? double.parse(pc.sqliteCounterGroupList[index].studentFare!)!=0.0
          ? double.parse(pc.sqliteCounterGroupList[index].studentFare!)
          : double.parse(pc.sqliteCounterGroupList[index].regularFare!)
          : double.parse(pc.sqliteCounterGroupList[index].regularFare!);
      _toll = double.parse(pc.sqliteCounterGroupList[index].toll!);
    });

    Map<String,dynamic> map = {
      'from_counter_id': pc.pref!.getString('counterId'),
      'to_group_id': pc.sqliteCounterGroupList[index].toGroupId,
      'total_fare': (_fare+_toll).toString(),
      'regular_fare': pc.sqliteCounterGroupList[index].regularFare,
      'student_fare': pc.sqliteCounterGroupList[index].studentFare,
      'toll': _toll.toString(),
      'sl_no': '${pc.ticketSerialModel.value.serialNo!+1}',
      'date': DateTime.now().toString()
    };
    await pc.checkInternet();
    if(pc.online.value==true){
      await pc.printTicket(map, pc.sqliteCounterGroupList[index].toGroupName!,_fare,_toll);
    }else{
      showToast('কোন ইন্টারনেট সনযোগ নেই');
    }
  }
}
