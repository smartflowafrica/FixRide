// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:carlinknew/model/signup_modal.dart';
import 'package:http/http.dart' as http;
import 'package:carlinknew/utils/App_content.dart';
import 'package:carlinknew/utils/Colors.dart';
import 'package:carlinknew/utils/Custom_widget.dart';
import 'package:carlinknew/utils/Dark_lightmode.dart';
import 'package:carlinknew/utils/config.dart';
import 'package:carlinknew/utils/fontfameli_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/msg_otp_controller.dart';
import '../../controller/sms_type_controller.dart';
import '../../controller/twilio_otp_controller.dart';
import '../bottombar/bottombar_screen.dart';
import 'newpassword_screen.dart';

class OtpScreen extends StatefulWidget {
  String? ccode;
  String? number;
  String? fullName;
  String? email;
  String? password;
  String? signup;
  String? otpCode;
  String? msgType;
  OtpScreen({super.key, this.msgType,this.otpCode,this.fullName, this.email, this.password, this.ccode, this.number, this.signup});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  OtpFieldController otpController = OtpFieldController();
  String code = "";
  String verrification = "";

  late ColorNotifire notifire;
  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  SmsTypeController smsTypeController = Get.put(SmsTypeController());
  MsgOtpController msgOtpController = Get.put(MsgOtpController());
  TwilioOtpController twilioOtpController = Get.put(TwilioOtpController());

  var decode;

  @override
  void initState() {
    // getdatafromsingup();
    setState(() {
      verrification = widget.signup ?? "";
    });    getdarkmodepreviousstate();
    startTimer();
    super.initState();
  }

  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  Future<void> getdatafromsingup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var decode1 = prefs.getString('SingUpdata')!;
    debugPrint("++++++ $decode1");
    setState(() {
      decode = json.decode(decode1);
    });
  }


  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      bottomNavigationBar: SizedBox(
        height: 135,
        width: Get.size.width,
        child: Column(
          children: [
            GestButton(
              height: 50,
              Width: Get.size.width,
              buttoncolor: onbordingBlue,
              buttontext: "Continue",
              margin: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              style: TextStyle(
                fontFamily: FontFamily.europaBold,
                color: WhiteColor,
                fontSize: 15,
              ),
              onclick: () {
                debugPrint(decode);
                try {
                  if(widget.msgType == "Firebase"){
                    debugPrint("nccdvdvf");
                    verifyOtp(code);
                    otpController.clear();
                    if (verrification == "signUpScreen") {
                      signup(widget.fullName, widget.email, widget.number, widget.password, widget.ccode).then((value) {
                        if (value["ResponseCode"] == "200") {
                          commonBottom();
                          OneSignal.User.addTagWithKey("user_id", signUp?.userLogin.id);
                          Fluttertoast.showToast(msg: value['ResponseMsg']);
                        } else {
                          Fluttertoast.showToast(msg: value['ResponseMsg']);
                        }
                      });
                    }
                    if(verrification == "resetScreen") {
                      Get.to(NewPasswordScreen(conutry: widget.ccode!, mobile: widget.number!));
                    }
                  }else{
                    if(widget.otpCode == code){
                      otpController.clear();
                      if (verrification == "signUpScreen") {
                        debugPrint("35354656");
                        signup(widget.fullName, widget.email, widget.number, widget.password, widget.ccode).then((value) {
                          if (value["ResponseCode"] == "200") {
                            commonBottom();
                            OneSignal.User.addTagWithKey("user_id", signUp?.userLogin.id);
                            Fluttertoast.showToast(msg: value['ResponseMsg']);
                          } else {
                            Fluttertoast.showToast(msg: value['ResponseMsg']);
                          }
                        });
                      }
                      if(verrification == "resetScreen") {
                        Get.to(NewPasswordScreen(conutry: widget.ccode!, mobile: widget.number!));
                      }
                    }else{
                      showToastMessage("Please enter your valid OTP".tr);
                    }
                  }
                } catch (e) {
                  showToastMessage("Please enter your valid OTP".tr);
                }
              },
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: BorderSide(color: onbordingBlue),
                  fixedSize: Size(Get.width, 50),
                ),
                  onPressed: enableResend ? resendCode : null,
                  child: enableResend ? Text('Resend Code', style: TextStyle(color: onbordingBlue, fontSize: 15)) : Text('$secondsRemaining seconds', style: TextStyle(color: onbordingBlue, fontSize: 15)),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(6),
                  child: Image.asset(Appcontent.close, color: notifire.getwhiteblackcolor),
                ),
              ),
              SizedBox(height: Get.size.height * 0.04),
              Container(
                height: 100,
                width: Get.size.width,
                alignment: Alignment.center,
                child: Image.asset(Appcontent.ematy),
              ),
              SizedBox(height: 10,),
              Container(
                width: Get.size.width,
                alignment: Alignment.center,
                child: Text("Almost there!", style: TextStyle(fontFamily: FontFamily.europaBold, color: notifire.getwhiteblackcolor, fontSize: 24)),
              ),
              SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                  text: TextSpan(
                children: [
                  TextSpan(text: 'You need to enter 6-digit code that we have sent to your mobile number', style: TextStyle(fontFamily: FontFamily.europaWoff, color: greyScale, fontSize: 14)),
                  TextSpan(text: ' ${widget.ccode} ${widget.number}', style: TextStyle(fontFamily: FontFamily.europaBold, color: notifire.getwhiteblackcolor, fontSize: 15)),
                ],
              )),
              SizedBox(height: Get.size.height * 0.035),
              OTPTextField(
                controller: otpController,
                length: 6,
                width: MediaQuery.of(context).size.width,
                fieldWidth: 50,
                style: TextStyle(fontSize: 17),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.box,
                onChanged: (value) {
                  setState(() {
                   code = value;
                  });
                },
                otpFieldStyle: OtpFieldStyle(
                  focusBorderColor: onbordingBlue,
                  enabledBorderColor: Color(0xffEEF2F6),
                  disabledBorderColor: Color(0xffEEF2F6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  SignUp? signUp;
  Future signup(fullname, email, mobile, password, ccode) async {
    Map body = {
      'name': fullname,
      'email': email,
      'mobile': mobile,
      'password': password,
      'ccode': ccode,
    };
    debugPrint("$body");
    try {
      var response = await http.post(Uri.parse(Config.baseUrl + Config.signup), body: jsonEncode(body), headers: {
            'Content-Type': 'application/json',
          });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        debugPrint(data);
        preferences.setString('Usertype', "USER");
        preferences.setString('UserLogin', jsonEncode(data["UserLogin"]));
        debugPrint("+ + + + + +  ++ + ++ + +  + + + + $data");
        setState(() {
          signUp = signUpFromJson(response.body);
        });
        return data;
      } else {}
    } catch (e) {}
  }

  Future<void> verifyOtp(String otp) async {
    try{
      FirebaseAuth auth1 = FirebaseAuth.instance;
      var credential = await auth1.signInWithCredential(PhoneAuthProvider.credential(verificationId: widget.otpCode!, smsCode: otp));

      if(credential.user != null){
        signup(widget.fullName, widget.email, widget.number, widget.password, widget.ccode).then((value) {
          if (value["ResponseCode"] == "200") {
            commonBottom();
            OneSignal.User.addTagWithKey("user_id", signUp?.userLogin.id);
            Fluttertoast.showToast(msg: value['ResponseMsg']);
          } else {
            Fluttertoast.showToast(msg: value['ResponseMsg']);
          }
        });
      } else {
        Fluttertoast.showToast(msg: 'Wrong OTP');
      }
    } catch(e){
      Fluttertoast.showToast(msg: 'Wrong OTP');
      debugPrint('+-+-$decode');
      debugPrint(e.toString());
    }
  }

  Future<void> resend(String otp) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.ccode! + widget.number!,
        verificationCompleted: (PhoneAuthCredential credential) async {
        try{
          FirebaseAuth auth1 = FirebaseAuth.instance;
          var credential = await auth1.signInWithCredential(PhoneAuthProvider.credential(verificationId: widget.otpCode!, smsCode: otp));
          if(credential.user != null){
            signup(decode['name'], decode['email'], decode['mobile'], decode['password'], decode['ccode']).then((value) {
              if (value["ResponseCode"] == "200") {
                commonBottom();
                Fluttertoast.showToast(msg: value['ResponseMsg']);
              } else {
                Fluttertoast.showToast(msg: value['ResponseMsg']);
              }
            });
          } else {
            Fluttertoast.showToast(msg: 'Wrong OTP');
          }
        } catch(e){
          Fluttertoast.showToast(msg: 'Wrong OTP');
        }
      },
      verificationFailed: (FirebaseAuthException e) {},
      timeout: Duration(seconds: secondsRemaining),
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void resendCode() {
    smsTypeController.smsTypeApi().then((smsType) {
      if(smsType["Result"] == "true"){
        debugPrint("cscvdxvdcvfcbgbgn");
        if(smsType["otp_auth"] == "No"){
          // signUpController.setUserApiData("${widget.ccode}");
        }else {
          if (smsType["SMS_TYPE"] == "Firebase") {
            debugPrint("cscvdxvdcvfcbgbgn");
            resend(code);
          } else if (smsType["SMS_TYPE"] == "Msg91") {
            //  msg_otp;
            debugPrint("cscvdxvdcvfcbgbgn");
            msgOtpController.msgOtpApi(mobile: "${widget.ccode}${widget.number}").then((msgOtp) {
              debugPrint("************* $msgOtp");
              if (msgOtp["Result"] == "true") {
                setState(() {
                  widget.otpCode = msgOtp["otp"].toString();
                });
                debugPrint(
                    "++++++++msgOtp+++++++++++ ${msgOtp["otp"]}");
              } else {
                showToastMessage(
                    "Invalid mobile number");
              }
            },);
          } else if (smsType["SMS_TYPE"] == "Twilio") {
            debugPrint("cscvdxvdcvfcbgbgn");
            twilioOtpController.twilioOtpApi(mobile: "${widget.ccode}${widget.number}").then((twilioOtp) {
              debugPrint("---------- $twilioOtp");
              if (twilioOtp["Result"] == "true") {
                setState(() {
                  widget.otpCode = twilioOtp["otp"].toString();
                });
                debugPrint(
                    "++++++++twilioOtp+++++++++++ ${twilioOtp["otp"]}");
              } else {
                showToastMessage(
                    "Invalid mobile number".tr);
              }
            },);
          } else {
            showToastMessage(
                "Invalid mobile number".tr);
          }
        }
      }
    },);
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
      startTimer();
    });
  }


  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          enableResend = true;
          t.cancel(); // Cancel timer when done
        }
      });
    });
  }
  Future<void> resetNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', false);
  }

  Future commonBottom(){
    return Get.bottomSheet(
      backgroundColor: notifire.getbgcolor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      SizedBox(
        height: 437,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            Image.asset(Appcontent.accountsucess, height: 96, width: 96),
            Text('Account Successfully\nCreated!'.tr, style: TextStyle(fontSize: 24, fontFamily: 'gilroyBold', fontWeight: FontWeight.w700, color: notifire.getwhiteblackcolor), textAlign: TextAlign.center),
            Text('Awesome. Your account is\nready to use.'.tr, style: TextStyle(fontSize: 16, fontFamily: 'gilroy Medium', fontWeight: FontWeight.w500, color: greyScale), textAlign: TextAlign.center),
            GestButton(
              height: 50,
              Width: Get.size.width,
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              buttontext: 'Start exploring'.tr,
              style: TextStyle(fontFamily: FontFamily.europaBold, fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
              onclick: () {
                Get.offAll(BottomBarScreen());
              },
              buttoncolor: onbordingBlue,
            ),
          ],
        ),
      ),
    );
  }

}