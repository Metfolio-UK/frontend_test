// ignore_for_file: unused_field

import 'dart:async';
import 'dart:math';
import 'package:base_project_flutter/constants/imageConstant.dart';
import 'package:base_project_flutter/responsive.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

import '../../constants/constants.dart';
import '../../globalFuctions/globalFunctions.dart';
import '../../globalWidgets/button.dart';

import '../keypad/keypad.dart';
import 'confirmPasscode.dart';
import 'confirmYourPasscode.dart';

class CreateYourPassCode extends StatefulWidget {
  const CreateYourPassCode({Key? key, required this.loginFlow})
      : super(key: key);
  final loginFlow;
  @override
  State<CreateYourPassCode> createState() => _CreateYourPassCodeState();
  // @override
  // _CreateYourPassCodeState createState() => _CreateYourPassCodeState();
}

class _CreateYourPassCodeState extends State<CreateYourPassCode> {
  final TextEditingController _otpCodeController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  late String displayCode;
  TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // displayCode = getNextCode();
  }

  x() async {
    if (_formKey.currentState!.validate()) {
      Twl.navigateTo(
          context,
          ConfirmYourPassCode(
            passcode: pinController.text,
            loginFlow: widget.loginFlow,
          ));
    }
  }

  var btnColor = tIndicatorColor;
  var selectedvalue;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future<bool>.value(false);
      },
      child: Scaffold(
          backgroundColor: tWhite,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: tWhite,
            automaticallyImplyLeading: widget.loginFlow ? false : true,
            leading: GestureDetector(
              // change the back button shadow
              onTap: () {
                // if (widget.loginFlow == true) {
                //   Twl.willpopAlert(context);
                // } else {
                //   Twl.navigateBack(context);
                // }
                Twl.willpopAlert(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: selectedvalue == 1 ? btnColor : tWhite,
                    borderRadius: BorderRadius.circular(10)),
                child: Image.asset(
                  Images.NAVBACK,
                  color: Color(0xff57B0BA),
                  scale: 4,
                ),
              ),
            ),
            titleSpacing: 0,
            centerTitle: false,
            title: Text("Create Passcode",
                style: TextStyle(
                    color: Color(0xff57B0BA),
                    fontFamily: 'Signika',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700)),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Builder(
                builder: (context) => SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Color(0xff57B0BA))),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 6,
                                      color: Color(0xffE5B02C),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        color: Color(0xffE5B02C),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        color: Color(0xffE5B02C),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: Color(0xff57B0BA)))),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Image.asset(
                              'images/finish.png',
                              width: 20,
                              height: 20,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("SMS",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Barlow',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700)),
                            Text("Personal Details",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Barlow',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700)),
                            Text("Create Passcode",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Barlow',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700)),
                            Text("Verification",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Barlow',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700)),
                            Container()
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12.sp),
                        height: 1,
                        color: Colors.black,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Create your Passcode",
                          style: TextStyle(
                              fontFamily: 'Barlow',
                              color: Color(0xff1E365B),
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w700
                              // fontFamily: AppTextStyle.robotoBold
                              ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "This will be required upon logging into Metfolio.\nYou can change it later",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: tSecondaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400
                              // fontFamily: AppTextStyle.robotoBold
                              ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 70,
                        ),
                        child: PinCodeTextField(
                          //backgroundColor: Colors.white,
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 4,
                          obscureText: true,
                          // obscuringCharacter: '*',
                          blinkDuration: Duration(milliseconds: 200),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          // validator: (v) {
                          //   if (v!.length < 4 || v.length == 0) {
                          //     return "passcode length did not match";
                          //   } else {
                          //     return null;
                          //   }
                          // },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            activeColor: tlightGrayblue,
                            selectedColor: tlightGrayblue,
                            selectedFillColor: tlightGrayblue,
                            inactiveFillColor: tlightGrayblue,
                            inactiveColor: tlightGrayblue,
                            borderRadius: BorderRadius.circular(12),
                            borderWidth: 0,
                            fieldHeight: isTab(context) ? 10.w : 13.w,
                            fieldWidth: isTab(context) ? 10.w : 12.w,
                            activeFillColor: tlightGrayblue,
                          ),
                          cursorColor: Colors.black,
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          //errorAnimationController: errorController,
                          controller: pinController,
                          keyboardType: TextInputType.none,
                          // boxShadows: [tBoxShadow],
                          onCompleted: (v) {
                            print("Completed");
                          },
                          onTap: () {
                            print("Pressed");
                          },
                          onChanged: (value) {
                            print(value);
                            // setState(() {
                            //   currentText = value;
                            // });
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");

                            return true;
                          },
                        ),
                      ),
                      KeyPad(
                        pinController: pinController,
                        isPinLogin: true,
                        onChange: (String pin) {
                          pinController.text = pin;
                          print('${pinController.text}');
                          setState(() {});
                        },
                        onSubmit: (String pin) {
                          if (pin.length != 4) {
                            (pin.length == 0)
                                ? showInSnackBar('Please Enter Pin')
                                : showInSnackBar('Wrong Pin');
                            return;
                          } else {
                            pinController.text = pin;

                            if (pinController.text == displayCode) {
                              showInSnackBar('Pin Match');
                              setState(() {
                                displayCode = getNextCode();
                              });
                            } else {
                              showInSnackBar('Wrong pin');
                            }
                            print('Pin is ${pinController.text}');
                          }
                        },
                      ),
                      // Spacer(),
                      SizedBox(height: 13.h),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: Color(0xff2AB2BC),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text('Continue',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Barlow',
                                    fontSize: 25)),
                            onPressed: x,
                          ),
                        ),
                      ),
                      //   GestureDetector(
                      //     onTap: () {
                      //       // if (_formKey.currentState!.validate()) {
                      //         Twl.navigateTo(context, BottomNavigation());
                      //  //   }
                      //     },
                      //     child: Center(
                      //       child: Container(
                      //         width: 200,
                      //         height: 40,
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(15),
                      //             color: tPrimaryColor),
                      //         child: Center(
                      //             child: Text('Continue',
                      //                 style: TextStyle( fontFamily: 'Signika',color: tSecondaryColor, fontSize: 13.sp))),
                      //       ),
                      //     ),
                      //   ),SizedBox(height:20),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void showInSnackBar(String value) {
    print('error' + value);
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(new SnackBar(content: new Text(value)));
  }

  getNextCode() {
    pinController.text = '';
    var rng = new Random();
    var code = (rng.nextInt(9000) + 1000).toString();
    print('Random No is : $code');
    return code;
  }
}
