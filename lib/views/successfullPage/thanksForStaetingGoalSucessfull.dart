import 'package:base_project_flutter/views/bottomNavigation.dart/bottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/constants.dart';
import '../../constants/imageConstant.dart';
import '../../globalFuctions/globalFunctions.dart';
import '../../globalWidgets/button.dart';
import '../../responsive.dart';

class ThanksForStartingGoalSucessful extends StatefulWidget {
  const ThanksForStartingGoalSucessful({Key? key}) : super(key: key);

  @override
  State<ThanksForStartingGoalSucessful> createState() =>
      _ThanksForStartingGoalSucessfulState();
}

class _ThanksForStartingGoalSucessfulState
    extends State<ThanksForStartingGoalSucessful> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: tWhite,
        // leading: GestureDetector(
        //   onTap: () {
        //     Twl.navigateBack(context);
        //   },
        //   child: Image.asset(
        //     Images.NAVBACK,
        //     scale: 4,
        //   ),
        // ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Successful',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: tPrimaryColor,
                            fontFamily: "Signika",
                            fontSize: isTab(context) ? 18.sp : 21.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: Image.asset(
                        Images.SUCESSFULL,
                        scale: 4,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Center(
                      child: Text(
                        'Thanks for starting a goal!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: tSecondaryColor,
                            fontFamily: "Signika",
                            fontSize: isTab(context) ? 13.sp : 16.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 20.w),
          //   child: Button(
          //       borderSide: BorderSide(
          //         color: tPrimaryColor,
          //       ),
          //       color: tPrimaryColor,
          //       textcolor: tWhite,
          //       bottonText: 'Home',
          //       onTap: (startLoading, stopLoading, btnState) async {
          //         Twl.navigateTo(context, BottomNavigation());
          //       }),
          // ),
          // SizedBox(
          //   height: 3.h,
          // )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        onPressed: () async {
          Twl.navigateTo(
              context,
              BottomNavigation(
                actionIndex: 0,
                tabIndexId: 0,
              ));
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          var count = sharedPreferences.getString("app_review").toString();
          if (count == null) {
            sharedPreferences.setString('app_review', '1');
            if (await inAppReview.isAvailable()) {
              inAppReview.requestReview();
            }
          } else {
            var curCount = int.parse(count);
            curCount += 1;

            if (int.parse(count) % 10 == 0) {
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            }

            sharedPreferences.setString('app_review', curCount.toString());
          }
          //In app review for andriod and ios
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        label: Container(
          // height: 10.h,
          width: 40.w,
          child: Center(
            child: Text(
              'Home',
              style: TextStyle(
                  color: tSecondaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 15),
            ),
          ),
        ),
        backgroundColor: tPrimaryColor,
      ),
    );
    // Scaffold(
    //   // appBar: AppBar(
    //   //   elevation: 0,
    //   //   backgroundColor: tWhite,
    //   //   leading: GestureDetector(
    //   //     onTap: () {
    //   //       Twl.navigateBack(context);
    //   //     },
    //   //     child: Image.asset(
    //   //       Images.NAVBACK,
    //   //       scale: 3.5,
    //   //     ),
    //   //   ),
    //   // ),
    //   body: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       SizedBox(
    //         height: 6.h,
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(horizontal: 17),
    //         child: GestureDetector(
    //           onTap: () {
    //             Twl.navigateBack(context);
    //           },
    //           child: Image.asset(
    //             Images.NAVBACK,
    //             scale: 4,
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: SingleChildScrollView(
    //           child: Center(
    //             child: Column(
    //               children: [
    //                 SizedBox(
    //                   height: 1.2.h,
    //                 ),
    //                 Center(
    //                   child: Text(
    //                     'Successful',
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(
    //                         color: tPrimaryColor,
    //                         fontFamily: "Signika",
    //                         fontSize: isTab(context) ? 18.sp : 21.sp,
    //                         fontWeight: FontWeight.w600),
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   height: 5.1.h,
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.symmetric(horizontal: 19),
    //                   child: Image.asset(
    //                     Images.DONE,
    //                     scale: 4,
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   height: 8.2.h,
    //                 ),
    //                 Center(
    //                   child: Text(
    //                     'Thanks for starting a goal!',
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(
    //                         color: tTextSecondary,
    //                         fontSize: isTab(context) ? 13.sp : 15.sp,
    //                         fontWeight: FontWeight.w400),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(horizontal: 20.w),
    //         child: Align(
    //           alignment: Alignment.center,
    //           child: Button(
    //               borderSide: BorderSide(
    //                 color: tPrimaryColor,
    //               ),
    //               color: tPrimaryColor,
    //               textcolor: tWhite,
    //               bottonText: 'Back to portfolio',
    //               onTap: (startLoading, stopLoading, btnState) async {
    //                 Twl.navigateTo(context, BottomNavigation());
    //               }),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 3.h,
    //       )
    //     ],
    //   ),
    // );
  }
}
