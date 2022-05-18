import 'package:flutter/material.dart';
import '../variables/color_variable.dart';
import '../variables/config.dart';

class QuantityButton extends StatelessWidget {
  const QuantityButton({Key? key,required this.onTap, required this.icon}) : super(key: key);
  final Function() onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: dSize(.18),
        child:Icon(icon,size: dSize(.1),color: Colors.white),
        decoration: BoxDecoration(
            color: AllColor.primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(dSize(.5)))
        ),
      ),
    );
  }
}
