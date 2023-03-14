import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:base_project_flutter/responsive.dart';
import 'package:base_project_flutter/views/PersonalDetails/PersonalDetails.dart';
import 'package:base_project_flutter/views/passCodePage/lockScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../api_services/userApi.dart';
import '../../constants/constants.dart';
import '../../constants/imageConstant.dart';
import '../../globalFuctions/globalFunctions.dart';
import '../../globalWidgets/button.dart';
import '../../main.dart';

class DigitCode extends StatefulWidget {
  const DigitCode(
      {required this.index,
      required this.number,
      required this.isSignUp,
      Key? key})
      : super(key: key);

  final int? index;
  final String? number;
  final bool isSignUp;

  @override
  State<DigitCode> createState() => _DigitCodeState();
}

class _DigitCodeState extends State<DigitCode> {
  final TextEditingController _otpCodeController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  // late String username;
  // bool hasError = false;
  late String otpCode;

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  var sessionId;
  var username;
  var authCode;
  late SharedPreferences sharedPreferences;
  bool hasError = false;
  bool isLoading = true;
  // _verifyOtpCode(
  //   String otp,
  //   startLoading,
  //   stopLoading,
  // ) async {
  //   print('here');
  //   FocusScope.of(context).requestFocus(new FocusNode());
  //   // FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  //   // _firebaseMessaging.getToken().then((token) async {
  //   // print(token);

  //   sharedPreferences = await SharedPreferences.getInstance();
  //   //  otpCode = _otpCodeController.text;
  //   setState(() {
  //     username = sharedPreferences.getString('userName')!;
  //     // sessionId = sharedPreferences.getString('sessionId')!;
  //   });
  //   var res = await UserAPI().verifyOtp(context, username, otp, 'token', '1');
  //   print(res);

  //   if (res != null && res['status'] == 'OK') {
  //     print('object');
  //     setState(() {
  //       //startLoading();
  //     });

  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     sharedPreferences.setString("authCode", res['auth_code']);
  //     if (sharedPreferences.getString('authCode') != null) {
  //       var check = await UserAPI().checkApi(
  //         res['auth_code'],
  //       );
  //       print('checkkkk');

  //       print(check);

  //       if (check != null && check['status'] == 'OK') {
  //         sharedPreferences.setString(
  //             "contact_no", check['detail']['contact_no'].toString());
  //         sharedPreferences.setString(
  //             "userId", check['detail']['id'].toString());
  //         sharedPreferences.setString(
  //             "username", check['detail']['username'].toString());
  //         if (check['detail']['email'] != null) {
  //           sharedPreferences.setString(
  //               "email", check['detail']['email'].toString());
  //         }
  //         if (check['detail']['gender'] != null) {
  //           sharedPreferences.setString(
  //               "gender", check['detail']['gender'].toString());
  //         }
  //         if (check['detail']['profile_image'] != null) {
  //           sharedPreferences.setString(
  //               "profile_image", check['detail']['profile_image'].toString());
  //         }
  //         if (check['detail']['date_of_birth'] != null) {
  //           sharedPreferences.setString(
  //               "date_of_birth", check['detail']['date_of_birth'].toString());
  //         }

  //         setState(() {
  //           isLoading = true;
  //         });
  //         if (
  //             // check['detail']['email'] != null &&
  //             // check['detail']['first_name'] != null &&
  //             // check['detail']['date_of_birth'] != null &&
  //             check['detail']['veriff_status'] == true ||
  //                 check['detail']['veriff_status'] == 'true') {
  //           Twl.navigateTo(context, BottomNavigation());
  //         } else {
  //           Twl.navigateTo(context, PersonalDetails());
  //         }

  //         // Navigator.of(context).push(MaterialPageRoute(
  //         //     builder: (context) => Twl.navigateTo(context, PersonalDetails());(
  //         //           authCode: authCode,
  //         //         )));
  //       } else {
  //         stopLoading();
  //         displayDialog(
  //           context,
  //           'OTP Failed',
  //           check['error'],
  //         );
  //       }
  //     } else {
  //       stopLoading();
  //       // displayDialog(
  //       //   context,
  //       //   'error',
  //       //   'User not found',
  //       // );
  //     }
  //   } else {
  //     stopLoading();
  //     displayDialog(
  //       context,
  //       'OTP Failed',
  //       res['error'],
  //     );
  //   }
  //   // });
  // }
  bool loading = false;

  startLoader(value) {
    setState(() {
      loading = value;
    });
  }

  x() async {
    FocusScope.of(context).unfocus();
    startLoader(true);

    // if (_formKey.currentState!.validate() && widget.index == 2) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        hasError = false;
      });
      // //startLoading();
      otpCode = _otpCodeController.text;
      print(otpCode);
      print('here');
      FocusScope.of(context).requestFocus(new FocusNode());
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      _firebaseMessaging.getToken().then((token) async {
        print(token);

        sharedPreferences = await SharedPreferences.getInstance();
        //  otpCode = _otpCodeController.text;
        setState(() {
          username = sharedPreferences.getString('userName')!;
          // sessionId = sharedPreferences.getString('sessionId')!;
        });
        setState(() {
          isLoading = false;
        });
        var res =
            await UserAPI().verifyOtp(context, username, otpCode, token!, '1');
        print(res);

        if (res != null && res['status'] == 'OK') {
          print('object');
          setState(() {
            // //startLoading();
          });

          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString("authCode", res['auth_code']);
          if (sharedPreferences.getString('authCode') != null) {
            var check = await UserAPI().checkApi(
              res['auth_code'],
            );
            print('checkkkk ' + check.toString());

            // print();

            if (check != null && check['status'] == 'OK') {
              if (check['detail']['stripe_cus_id'] != null) {
                sharedPreferences.setString(
                    'cusId', check['detail']['stripe_cus_id']);
              }

              sharedPreferences.setString(
                  'userId', check['detail']['userId'].toString());
              sharedPreferences.setString(
                  "contact_no", check['detail']['contact_no'].toString());
              print(check['detail']['stripe_publishable_key']);
              sharedPreferences.setString(
                  'stripePublicKey', check['detail']['stripe_publishable_key']);
              Stripe.publishableKey = check['detail']['stripe_publishable_key'];
              await Stripe.instance.applySettings();
              sharedPreferences.setString(
                  'stripesecretKey', check['detail']['stripe_secret_Key']);
              // sharedPreferences.setString("userId",
              //     check['detail']['id'].toString());
              sharedPreferences.setString(
                  "username", check['detail']['username'].toString());
              if (check['detail']['email'] != null) {
                sharedPreferences.setString(
                    "email", check['detail']['email'].toString());
              }
              if (check['detail']['gender'] != null) {
                sharedPreferences.setString(
                    "gender", check['detail']['gender'].toString());
              }
              if (check['detail']['profile_image'] != null) {
                sharedPreferences.setString("profile_image",
                    check['detail']['profile_image'].toString());
              }
              if (check['detail']['date_of_birth'] != null) {
                sharedPreferences.setString("date_of_birth",
                    check['detail']['date_of_birth'].toString());
              }

              setState(() {
                isLoading = true;
              });
              if (check['detail']['email'] != null &&
                      check['detail']['first_name'] != null &&
                      check['detail']['date_of_birth'] != null &&
                      check['detail']['delivery_address']['post_code'] !=
                          null &&
                      check['detail']['delivery_address']['address_line_one'] !=
                          null
                  // check['detail']['veriff_status'] == true ||
                  //     check['detail']['veriff_status'] == 'true'
                  ) {
                setState(() {
                  isLoading = true;
                });
                startLoader(false);
                // stopLoading();
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(check['detail']['userId'].toString())
                    .snapshots()
                    .listen((userData) {
                  setState(() async {
                    if (userData.data()?['userId'] != null) {
                      final facebookAppEvents = FacebookAppEvents();
                      facebookAppEvents.setAdvertiserTracking(enabled: true);
                      facebookAppEvents.logEvent(
                        name: 'button_clicked',
                        parameters: {
                          'button_id': 'the_clickme_button',
                        },
                      );
                      facebookAppEvents.setUserData(
                        email: check['detail']['email'],
                        firstName: check['detail']['username'],
                        dateOfBirth: check['detail']['date_of_birth'],
                      );
                      startLoader(false);
                      Twl.navigateTo(
                          context,
                          LockScreen(
                            navigate: false,
                          ));

                      await FirebaseAnalytics.instance.logEvent(
                        name: "otp_mobile",
                        parameters: {
                          "otp": otpCode,
                          "button_clicked": true,
                        },
                      );

                      Segment.track(
                        eventName: 'otp_mobile',
                        properties: {"otp": otpCode, "clicked": true},
                      );

                      mixpanel.track(
                        'otp_mobile',
                        properties: {"otp": otpCode, "clicked": true},
                      );
                    } else {
                      final facebookAppEvents = FacebookAppEvents();
                      facebookAppEvents.setAdvertiserTracking(enabled: true);
                      facebookAppEvents.logEvent(
                        name: 'button_clicked',
                        parameters: {
                          'button_id': 'the_clickme_button',
                        },
                      );
                      facebookAppEvents.setUserData(
                        email: check['detail']['email'],
                        firstName: check['detail']['username'],
                        dateOfBirth: check['detail']['date_of_birth'],
                      );
                      startLoader(false);
                      Twl.navigateTo(
                          context,
                          PersonalDetails(
                            isLoadingFlow: true,
                          ));
                      checkverification(
                          context, check['detail']['verification_status']);
                      // Twl.navigateTo(context,
                      //     BottomNavigation());
                    }
                  });
                });
              } else {
                startLoader(false);
                setState(() {
                  isLoading = true;
                });
                // stopLoading();
                Twl.navigateTo(
                    context,
                    PersonalDetails(
                      isLoadingFlow: true,
                    ));
              }

              await FirebaseAnalytics.instance.logEvent(
                name: "otp_mobile",
                parameters: {
                  "otp": otpCode,
                  "button_clicked": true,
                },
              );

              Segment.track(
                eventName: 'otp_mobile',
                properties: {"otp": otpCode, "clicked": true},
              );

              mixpanel.track(
                'otp_mobile',
                properties: {"otp": otpCode, "clicked": true},
              );

              // stopLoading();
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => Twl.navigateTo(context, PersonalDetails());(
              //           authCode: authCode,
              //         )));
            } else {
              startLoader(false);
              setState(() {
                isLoading = true;
              });
              // stopLoading();
              // displayDialog(
              //   context,
              //   'OTP Failed',
              //   check['error'],
              // );
            }
          } else {
            startLoader(false);
            setState(() {
              isLoading = true;
            });
            // stopLoading();
            // displayDialog(
            //   context,
            //   'error',
            //   'User not found',
            // );
          }
        } else {
          setState(() {
            isLoading = true;
          });
          startLoader(false);
          setState(() {
            hasError = true;
          });

          // stopLoading();
          // displayDialog(
          //   context,
          //   'OTP Failed',
          //   res['error'],
          // );
        }
        startLoader(false);
        // _verifyOtpCode(
        //   otpCode,
        //   startLoading,
        //   stopLoading,
        // );
        // stopLoading();
      });
      // Twl.navigateTo(context, PersonalDetails());
    }
    // else if (_formKey.currentState!.validate() &&
    //     widget.index == 1) {
    else {
      setState(() {
        hasError = false;
      });
      startLoader(false);
      // Twl.navigateTo(context, ForgotPasswordPasscode());
    }
  }

  var btnColor = tIndicatorColor;
  var selectedvalue;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Twl.willpopAlert(context);
      },
      child: Stack(
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
                          fontWeight: FontWeight.w700))),
              body: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isSignUp)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 0, bottom: 0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Color(0xff57B0BA),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text("Log In",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Barlow',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: tPrimaryColor,
                                size: 18,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Color(0xff57B0BA),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text("SMS",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Barlow',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: tPrimaryColor,
                                size: 18,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text("Passcode",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Barlow',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      if (!widget.isSignUp)
                        Container(
                          margin: EdgeInsets.only(top: 10.sp),
                          height: 1,
                          color: Colors.black,
                        ),
                      if (widget.isSignUp)
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
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color:
                                                          Color(0xff57B0BA)))),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color:
                                                          Color(0xff57B0BA)))),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      color:
                                                          Color(0xff57B0BA)))),
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
                      if (widget.isSignUp)
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
                      if (widget.isSignUp)
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
                                  Text("Verify your mobile number",
                                      style: TextStyle(
                                          fontFamily: 'Barlow',
                                          color: Colors.black,
                                          fontSize: isTab(context)
                                              ? 18.sp
                                              : widget.isSignUp
                                                  ? 15.sp
                                                  : 18.sp,
                                          fontWeight: FontWeight.w700)),
                                  SizedBox(height: 4),
                                  Text(
                                      "Enter the 6 digit code we sent to ${widget.number}",
                                      style: TextStyle(
                                          color: tSecondaryColor,
                                          fontSize:
                                              isTab(context) ? 9.sp : 12.sp,
                                          fontWeight: FontWeight.w400)),
                                  SizedBox(height: 12),
                                  PinCodeTextField(
                                    // backgroundColor: Colors.white,
                                    appContext: context,
                                    pastedTextStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    length: 6,
                                    obscureText: false,
                                    obscuringCharacter: '*',
                                    // blinkWhenObscuring: true,
                                    animationType: AnimationType.fade,

                                    // validator: (v) {
                                    //   if (v!.length < 6 || v.length == 0) {
                                    //     return "";
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.box,
                                      activeColor:
                                          hasError ? Colors.red : Colors.black,
                                      selectedColor:
                                          hasError ? Colors.red : Colors.black,
                                      // selectedFillColor: Colors.black,
                                      // inactiveFillColor: Colors.white,
                                      inactiveColor:
                                          //  Colors.red,
                                          hasError ? Colors.red : Colors.black,
                                      borderRadius: BorderRadius.circular(15),
                                      borderWidth: hasError ? 2 : 1,
                                      errorBorderColor: Colors.red,
                                      fieldHeight: isTab(context) ? 10.w : 13.w,
                                      fieldWidth: isTab(context) ? 10.w : 12.w,
                                    ),

                                    cursorColor: Colors.black,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    animationDuration:
                                        Duration(milliseconds: 300),
                                    errorAnimationDuration: 1000,
                                    // enableActiveFill: true,
                                    //errorAnimationController: errorController,
                                    controller: _otpCodeController,
                                    keyboardType: TextInputType.number,
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
                                  SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                        // color: tSecondaryColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: ArgonTimerButton(
                                        initialTimer: 30,
                                        elevation: 0,
                                        height: isTab(context) ? 50 : 30,
                                        width: isTab(context) ? (100.w) : 100.w,
                                        borderRadius: isTab(context) ? 90 : 30,
                                        color: tWhite,
                                        minWidth: 100.w,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Re-send verification code',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: tSecondaryColor,
                                                    fontSize: isTab(context)
                                                        ? 9.sp
                                                        : 12.sp,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                        loader: (timeLeft) {
                                          return Text(
                                            "Re-send verification code $timeLeft",
                                            style: TextStyle(
                                                color: tSecondaryColor,
                                                fontSize: isTab(context)
                                                    ? 9.sp
                                                    : 12.sp,
                                                fontWeight: FontWeight.w400),
                                          );
                                        },
                                        onTap: (startTimer, btnState) async {
                                          SharedPreferences sharedPreferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          var userName;
                                          setState(() {
                                            userName = sharedPreferences
                                                .getString("userName")
                                                .toString();
                                          });
                                          var res = await UserAPI.sendOtp(
                                              context, userName);
                                          print(res);
                                          print(userName);
                                          if (res != null &&
                                              res['status'] == 'OK') {
                                            // if (type == 1)
                                            Twl.navigateTo(
                                                context,
                                                DigitCode(
                                                  isSignUp: true,
                                                  index: null,
                                                  number: widget.number,
                                                ));
                                          } else {
                                            // Twl.createAlert(context, 'error',
                                            //     res['error']);
                                          }
                                        }),
                                  ),
                                  // Center(
                                  //   child: Text(
                                  //     "Re-send verification code",
                                  //     style: TextStyle(
                                  //         color: tSecondaryColor,
                                  //         fontSize: isTab(context) ? 14.sp : 16.sp,
                                  //         fontWeight: FontWeight.w400),
                                  //     textAlign: TextAlign.center,
                                  //   ),
                                  // )
                                ]),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  child: Text('Continue',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.sp,
                                          fontFamily: 'Barlow',
                                          fontWeight: FontWeight.w700)),
                                  onPressed: isLoading == false ? null : x,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20)
                    ]),
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
            )
        ],
      ),
    );
  }
}
