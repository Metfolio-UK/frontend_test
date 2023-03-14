import 'package:base_project_flutter/api_services/userApi.dart';
import 'package:base_project_flutter/constants/constants.dart';
import 'package:base_project_flutter/constants/imageConstant.dart';
import 'package:base_project_flutter/main.dart';
import 'package:base_project_flutter/responsive.dart';
import 'package:base_project_flutter/views/bottomNavigation.dart/bottomNavigation.dart';
import 'package:base_project_flutter/views/listAddress/confirmAddress.dart';
import 'package:base_project_flutter/views/notificationPage/notification.dart';
import 'package:base_project_flutter/views/veriffPage/veriffPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:veriff_flutter/veriff_flutter.dart';

import 'globalFuctions/globalFunctions.dart';
import 'globalWidgets/button.dart';
import 'views/loginPassCodePages/createYourPasscode.dart';

class Extra extends StatefulWidget {
  const Extra({Key? key, required this.throughProfile}) : super(key: key);
  final bool throughProfile;

  @override
  State<Extra> createState() => Extraq();
}

class Extraq extends State<Extra> {
  var btnColor = tIndicatorColor;
  var selectedvalue;

  String _platformVersion = 'Unknown';
  String _sessionResult = 'Not started';
  String _sessionError = 'None';
  late TextEditingController _sessionURLController;
  late TextEditingController _localeController;
  bool _isBrandingOn = true;
  bool _useCustomIntro = true;

  @override
  void initState() {
    super.initState();

    _sessionURLController = TextEditingController();
    _localeController = TextEditingController();
    initPlatformState();
    setState(() {
      _sessionURLController
        ..text =
            "https://alchemy.veriff.com/v/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZXNzaW9uX2lkIjoiNzE3ODMyMDQtNTA3NS00YzQ2LWJmOWItYzVjMDY1NjBiZTIzIiwiaWF0IjoxNjU5NTk2NjQ1fQ.m9QX4mkCYeAmmgZlamvpnJ_lMGT3Fem7U5oakwvxIws";
    });
  }

  @override
  void dispose() {
    _sessionURLController.dispose();
    _localeController.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Veriff().platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Configuration setupConfiguration(url) {
    Configuration config = Configuration(url);
    config.useCustomIntroScreen = true;
    AssetImage logo = AssetImage('assets/icons/Splash1.png');
    if (_isBrandingOn) {
      Branding branding = Branding(
        themeColor: "#E5B02C",
        backgroundColor: "#ffffff",
        statusBarColor: "#ffffff",
        primaryTextColor: "#E5B02C",
        secondaryTextColor: "#1E365B",
        primaryButtonBackgroundColor: "#1E365B",
        buttonCornerRadius: 20,
        // logo: logo,
        androidNotificationIcon: "ic_notification",
      );
      config.branding = branding;
    }
    if (_localeController.text.length != 0) {
      config.languageLocale = _localeController.text;
    }
    if (_useCustomIntro) {
      config.useCustomIntroScreen = _useCustomIntro;
      print('Custom intro set to: $_useCustomIntro');
    }
    return config;
  }

  // Future<void>
  _startVeriffFlow(context, url, sessionId) async {
    if (_sessionURLController.text == null) {
      print("You must enter a session URL!");
      return;
    }
    Veriff veriff = Veriff();
    Configuration config = setupConfiguration(url);

    try {
      Result result = await veriff.start(config);
      print("================= Result from Veriff SDK ================\n");
      setState(() {
        _sessionResult = result.status.toString();
        _sessionError = result.error.toString();
      });
      var resVerffiCallback = await UserAPI()
          .veriffCallBack(context, result.status.toString(), sessionId);
      print('resVerffiCallback');
      print(resVerffiCallback);

      switch (result.status) {
        case Status.done:
          print("Session is completed.");
          if (resVerffiCallback != null &&
              resVerffiCallback['status'] == 'OK' &&
              (resVerffiCallback['veriff_status'] == true ||
                  resVerffiCallback['veriff_status'] == 'true')) {
            // checkVeriffStatus(
            //     resVerffiCallback['details']['status'], url, sessionId);
            return Twl.navigateTo(
                context,
                CreateYourPassCode(
                  loginFlow: true,
                ));
            // return Twl.navigateTo(context, BottomNavigation());
          } else {
            checkVeriffStatus(resVerffiCallback['error'], url, sessionId);
            // return Twl.createAlert(
            //     context, "error", resVerffiCallback['error']);
          }
          break;
        case Status.canceled:
          print("Session is canceled by the user.");
          // return Twl.createAlert(
          //     context, 'error', 'Session is canceled by the user.');
          break;
        case Status.error:
          switch (result.error) {
            case Error.cameraUnavailable:
              print("User did not give permission for the camera");
              // return Twl.createAlert(context, 'error',
              //     'User did not give permission for the camera.');
              break;
            case Error.microphoneUnavailable:
              print("User did not give permission for the microphone.");
              break;
            case Error.networkError:
              print("Network error occurred.");
              // return Twl.createAlert(
              //     context, 'error', 'Network error occurred.');
              break;
            case Error.sessionError:
              print("A local error happened before submitting the session.");
              // return Twl.createAlert(context, 'error',
              //     'A local error happened before submitting the session.');
              break;
            case Error.deprecatedSDKVersion:
              print(
                  "Version of Veriff SDK used in plugin has been deprecated. Please update to the latest version.");
              // return Twl.createAlert(context, 'error',
              //     'Version of Veriff SDK used in plugin has been deprecated. Please update to the latest version.');
              break;
            case Error.unknown:
              print("Uknown error occurred.");
              // return Twl.createAlert(
              //     context, 'error', 'Uknown error occurred.');
              break;
            case Error.nfcError:
              print("Error with NFC");
              // return Twl.createAlert(context, 'error', 'Error with NFC');
              break;
            case Error.setupError:
              print("Error with setup");
              // return Twl.createAlert(context, 'error', 'Error with setup');
              break;
            case Error.none:
              print("No error.");
              // return Twl.createAlert(context, 'error', 'No error.');
              break;
            default:
              break;
          }
          break;
        default:
          break;
      }
      print("==========================================================\n");
      return result.status;
    } on PlatformException {
      //log this
    }
  }

  checkVeriffStatus(status, url, sessionId) {
    switch (status) {
      case 'approved':
        return Twl.navigateTo(
            context,
            CreateYourPassCode(
              loginFlow: true,
            ));
      case 'resubmission_requested':
        return Twl.navigateTo(
            context,
            VeriffiPage(
              sessionUrl: null,
              sessionId: null,
            ));
      // break;
      case 'declined':
        return Twl.navigateTo(
            context,
            VeriffiPage(
              sessionUrl: null,
              sessionId: null,
            ));
      // break;
      case 'expired':
        return Twl.navigateTo(
            context,
            VeriffiPage(
              sessionUrl: null,
              sessionId: null,
            ));
      // break;
      case 'abandoned':
        return Twl.navigateTo(
            context,
            VeriffiPage(
              sessionUrl: null,
              sessionId: null,
            ));
      // break;
      case 'process':
        return Twl.navigateTo(
            context,
            VeriffStatusCheck(
              sessionId: sessionId,
              status: status,
            ));
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
              title: Text("Verification",
                  style: TextStyle(
                      color: Color(0xff57B0BA),
                      fontFamily: 'Signika',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700)),
            ),
            body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                                color: Color(0xffE5B02C),
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
              SizedBox(height: 24),
              Text("Verify Your Identity",
                  style: TextStyle(
                      color: tSecondaryColor,
                      fontFamily: 'Barlow',
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text("Stay unverified for your first £10,000",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: tSecondaryColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400)),
              SizedBox(height: 3.h),
              Center(
                  child: Container(
                      padding: EdgeInsets.all(8),
                      child: Image.asset('images/verify.png',
                          height: 163, width: 162))),
              Spacer(),
              if (!widget.throughProfile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      setState(() {
                        verificationStatus = 3;
                      });
                      Twl.navigateTo(context, NotificationPage());
                    },
                    child: Center(
                      child: Text(
                        "Skip to App",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              if (!widget.throughProfile) SizedBox(height: 8),
              if (!widget.throughProfile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.black,
                      height: 2,
                      width: 100,
                    ),
                    Text("  OR  ",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Signika',
                            fontSize: 20)),
                    Container(
                      color: Colors.black,
                      height: 2,
                      width: 100,
                    ),
                  ],
                ),
              if (!widget.throughProfile) SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.center,
                  child: Button(
                    borderSide: BorderSide.none,
                    color: Color(0xff2AB2BC),
                    textcolor: tWhite,
                    bottonText: 'Continue',
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Barlow',
                        fontSize: 25),
                    onTap: (startLoading, stopLoading, btnState) async {
                      var firstName;
                      var lastName;
                      var emailId;
                      var dob;
                      var number;
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      setState(() {
                        firstName = sharedPreferences.getString('firstName');
                        lastName = sharedPreferences.getString('lastName');
                        emailId = sharedPreferences.getString('email');
                        dob = sharedPreferences.getString('dob');
                        number = sharedPreferences.getString("userName");
                      });

                      print('verffi api>>>>>>>>>>>>');
                      var veriffiRes = await UserAPI()
                          .veriff(context, firstName, lastName, number);
                      if (veriffiRes['status'] == 'OK' && veriffiRes != null) {
                        var url;
                        setState(() {
                          url = veriffiRes['details']['url'];
                        });
                        print(url);
                        var res = await _startVeriffFlow(
                            context, url, veriffiRes['details']['id']);
                        print(res);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),
            ]),
          ))
    ]);
  }
}
