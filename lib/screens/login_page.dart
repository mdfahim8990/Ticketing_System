import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsob_ticket/controller/public_controller.dart';
import 'package:utsob_ticket/variables/config.dart';
import 'package:utsob_ticket/variables/variable.dart';
import 'package:utsob_ticket/widgets/text_field_tile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username=TextEditingController(text: '');
  final TextEditingController _password=TextEditingController(text: '');

  @override
  void initState(){
    super.initState();
    _username.text = PublicController.pc.pref!.getString('username')??'';
    _password.text = PublicController.pc.pref!.getString('password')??'';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Variables().statusBarTheme;
    return GetBuilder<PublicController>(
      builder: (pc) {
        return Scaffold(
          body: _bodyUI(pc),
        );
      }
    );
  }
  Widget _bodyUI(PublicController pc)=>SafeArea(
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dSize(.1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/bus.png',height: dSize(.4)),
                Positioned(
                  top: dSize(.11),
                  child: Text('উৎসব',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: dSize(.07))),
                ),
              ],
            ),

            TextFieldTile(controller: _username,labelText: 'Username',prefixIcon: Icons.person),
            SizedBox(height: dSize(.05)),
            TextFieldTile(controller: _password,labelText: 'Password',prefixIcon: Icons.lock,obscure: true),
            SizedBox(height: dSize(.05)),
            !pc.loading.value
                ? ElevatedButton(
              onPressed: ()async{
                if(_username.text.isNotEmpty && _password.text.isNotEmpty){
                  await pc.login(_username.text, _password.text);
                }else{showToast('সঠিক তথ্য দিয়ে পুনরায় চেষ্টা করুন');}
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: dSize(.2)),
                child: Text('লগইন',style: TextStyle(fontSize: dSize(.05))),
              ),
            ): const CircularProgressIndicator()
          ],
        ),
      ),
    ),
  );

}
