// ignore_for_file: override_on_non_overriding_member

import 'dart:async';

import 'package:base_project_flutter/constants/imageConstant.dart';
import 'package:base_project_flutter/main.dart';
import 'package:base_project_flutter/views/DigitCode/DigitCode.dart';
import 'package:base_project_flutter/views/accountNotExist/accountExist.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../api_services/userApi.dart';
import '../../constants/constants.dart';
import '../../globalFuctions/globalFunctions.dart';
import '../../globalWidgets/button.dart';
import '../../responsive.dart';

class LoginMobileNumber extends StatefulWidget {
  const LoginMobileNumber({Key? key}) : super(key: key);

  @override
  State<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends State<LoginMobileNumber> {
  String dropdownValue = '+44';
  @override
  final TextEditingController _mobileNumberController = TextEditingController();

  final _formKey = new GlobalKey<FormState>();
  bool loading = false;

  startLoader(value) {
    setState(() {
      loading = value;
    });
  }

  var btnColor = tIndicatorColor;
  var selectedvalue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = false;
  }

  x() async {
    FocusScope.of(context).unfocus();
    if (_mobileNumberController.text.length < 10) {
      _formKey.currentState!.validate();
      return null;
      // final snackBar = SnackBar(
      //   content: const Text('Please Enter Mobile Number'),
      //   action: SnackBarAction(
      //     label: 'Undo',
      //     onPressed: () {
      //       // Some code to undo the change.
      //     },
      //   ),
      // );

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(snackBar);
    }

    // else if (_mobileNumberController.text.length <
    //     10) {
    //   _formKey.currentState!.validate();
    //   // final snackBar = SnackBar(
    //   //   content: const Text('number must be 10 digits'),
    //   //   action: SnackBarAction(
    //   //     label: 'Undo',
    //   //     onPressed: () {
    //   //       // Some code to undo the change.
    //   //     },
    //   //   ),
    //   // );

    //   // ScaffoldMessenger.of(context)
    //   //     .showSnackBar(snackBar);
    // }
    else {
      // //startLoading();
      startLoader(true);
      var userName = '+44' + _mobileNumberController.text;
      var checkUser = await UserAPI().checkUser(context, userName);
      print('checkUser>>>>>>>>>' + checkUser.toString());
      // print(checkUser);
      if (checkUser != null &&
          checkUser['status'] == 'OK' &&
          checkUser['user_registered'] == true) {
        startLoader(false);
        Twl.navigateTo(context, AccountExists());
      } else {
        var res = await UserAPI.sendOtp(context, userName);
        print(res);
        print(userName);
        if (res != null && res['status'] == 'OK') {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString("userName", userName);
          if (dropdownValue == '+44') {
            sharedPreferences.setString('countryCode', "GB");
          } else if (dropdownValue == '+91') {
            sharedPreferences.setString('countryCode', 'GB');
          }
          // sharedPreferences.setString(
          //     "sessionId", res['details']['Details']);
          // stopLoading();

          startLoader(false);
          Twl.navigateTo(
              context,
              DigitCode(
                isSignUp: true,
                index: null,
                number: userName,
              ));

          await analytics.logEvent(
            name: "mobile_signup",
            parameters: {
              "number": userName,
              "button_clicked": true,
            },
          );

          Segment.track(
            eventName: 'mobile_signup',
            properties: {"number": userName, "clicked": true},
          );

          mixpanel.track('mobile_signup',
              properties: {"number": userName, "clicked": true});

          await logEvent("mobile_signup", {
            "number": userName,
            'clicked': true,
          });

          // Twl.navigateTo(context, EnterYourPasscode());
        } else {
          startLoader(false);
        }
      }
    }

    // else {
    //   Twl.navigateTo(context, DigitCode(index: 2));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: tWhite,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: tWhite,
              leading: GestureDetector(
                // change the back button shadow
                onTap: () {
                  Twl.navigateBack(context);
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
              title: Text("SMS",
                  style: TextStyle(
                      color: Color(0xff57B0BA),
                      fontFamily: 'Signika',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700)),
            ),
            body: Form(
              key: _formKey,
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Column(
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
                                  border: Border.all(color: Color(0xff57B0BA))),
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
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(
                                                  color: Color(0xff57B0BA)))),
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 24, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("What is your mobile number?",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Signika',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 12),
                                    child: Image.asset(
                                      'images/uk.png',
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                  // Container(
                                  //   padding: EdgeInsets.all(10),
                                  //   height: 45,
                                  //   decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.all(
                                  //         Radius.circular(15),
                                  //       ),
                                  //       color: tlightGrayblue),
                                  //   child: DropdownButton<String>(
                                  //     value: dropdownValue,
                                  //     items: <String>["+91", "+44"]
                                  //         .map<DropdownMenuItem<String>>(
                                  //             (String value) {
                                  //       return DropdownMenuItem<String>(
                                  //         value: value,
                                  //         child: Text(
                                  //           value,
                                  //           style: TextStyle(
                                  //             fontWeight: FontWeight.w400,
                                  //             color: tSecondaryColor,
                                  //             fontSize: isTab(context)
                                  //                 ? 13.sp
                                  //                 : 16.sp,
                                  //           ),
                                  //         ),
                                  //       );
                                  //     }).toList(),
                                  //     underline:
                                  //         Container(color: tTextformfieldColor),
                                  //     onChanged: (String? newValue) async {
                                  //       SharedPreferences sharedPreferences =
                                  //           await SharedPreferences
                                  //               .getInstance();

                                  //       setState(() {
                                  //         sharedPreferences.setString(
                                  //             'countryCode', newValue!);
                                  //         dropdownValue = newValue;
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                  Container(
                                    height: 32,
                                    width: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0)),
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xff1E365B), width: 1),
                                        bottom: BorderSide(
                                            color: Color(0xff1E365B), width: 1),
                                        left: BorderSide(
                                            color: Color(0xff1E365B), width: 1),
                                        right: BorderSide(
                                            color: Color(0xff1E365B), width: 1),
                                      ),
                                    ),
                                    child: Text("(+44)",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.sp,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 32,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          } else if (value.length != 10
                                              // value.length <= 9 &&
                                              //   value.length <= 11
                                              ) {
                                            return "";
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: (v) {
                                          _formKey.currentState!.validate();
                                        },
                                        controller: _mobileNumberController,
                                        //_phoneNumberController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10)
                                        ],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontSize: 12.sp),
                                        decoration: InputDecoration(
                                          // prefix: Text('+91 ',style: TextStyle(color: tBlack),),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(12),
                                                bottomRight:
                                                    Radius.circular(12)),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(12),
                                                bottomRight:
                                                    Radius.circular(12)),
                                            borderSide: BorderSide(
                                                color: Color(0xff1E365B)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(12),
                                                bottomRight:
                                                    Radius.circular(12)),
                                            borderSide: BorderSide(
                                                color: Color(0xff1E365B)),
                                          ),
                                          // hintStyle: TextStyle(
                                          //     fontSize: isTab(context)
                                          //         ? 10.sp
                                          //         : 14.sp),
                                          // hintText: 'Enter Your Mobile Number',
                                          fillColor: Colors.white,
                                          errorStyle: TextStyle(height: 0),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(12),
                                                bottomRight:
                                                    Radius.circular(12)),
                                            borderSide: BorderSide(
                                                color: Color(0xff1E365B)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                      "We may store and send a verification code to this number",
                                      style: TextStyle(
                                          color: tSecondaryColor,
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: Color(0xff2AB2BC),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text('Continue',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontFamily: 'Barlow',
                                        fontWeight: FontWeight.w700)),
                                onPressed: x,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (loading)
          Center(
            child: Container(
              color: tBlack.withOpacity(0.3),
              // padding:
              //     EdgeInsets.only(top: 100),
              height: 100.h,
              width: 100.w,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: tPrimaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
