import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsob_ticket/model/sqlite_counter_group_model.dart';
import 'package:utsob_ticket/variables/config.dart';
import 'package:utsob_ticket/variables/variable.dart';
import '../controller/public_controller.dart';

class CounterTile extends StatelessWidget {
  const CounterTile({Key? key, required this.model}) : super(key: key);
  final SqliteCounterGroupModel model;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PublicController>(
      builder: (pc) {
        return Padding(
          padding: EdgeInsets.all( dSize(.04)),
          child: Center(
            child: Text('${model.toGroupName}',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: Variables.textStyle.copyWith(fontWeight: FontWeight.w500,fontSize: dSize(.05))),
          ),
        );
      }
    );
  }
}
