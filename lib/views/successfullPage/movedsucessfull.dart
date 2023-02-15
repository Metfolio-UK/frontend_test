import 'package:base_project_flutter/constants/constants.dart';
import 'package:base_project_flutter/globalFuctions/globalFunctions.dart';
import 'package:base_project_flutter/responsive.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sizer/sizer.dart';

import '../../constants/imageConstant.dart';
import '../../globalWidgets/button.dart';
import '../bottomNavigation.dart/bottomNavigation.dart';

class MovedSucessful extends StatefulWidget {
  const MovedSucessful({Key? key}) : super(key: key);

  @override
  State<MovedSucessful> createState() => _MovedSucessfulState();
}

class _MovedSucessfulState extends State<MovedSucessful> {
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
                        'Your gold has been moved!',
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
          if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
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
    //   backgroundColor: tWhite,
    //   appBar: AppBar(
    //     elevation: 0,
    //     backgroundColor: tWhite,
    //     automaticallyImplyLeading: false,
    //   ),
    //   body: Column(
    //     children: [
    //       Expanded(
    //         child: SingleChildScrollView(
    //           child: Center(
    //             child: Column(
    //               children: [
    //                 SizedBox(
    //                   height: 2.h,
    //                 ),
    //                 Center(
    //                   child: Text(
    //                     'Successful',
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(
    //                         color: tPrimaryColor,
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
    //                     '50 Grams for delivery ',
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(
    //                         fontFamily: "Signika",
    //                         color: tTextSecondary,
    //                         fontSize: isTab(context) ? 13.sp : 16.sp,
    //                         fontWeight: FontWeight.w400),
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   height: 1.6.h,
    //                 ),
    //                 Text(
    //                   'Thank you for your order, your details have\nbeen emailed to you!',
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                       color: tSecondaryColor,
    //                       fontSize: isTab(context) ? 9.sp : 12.sp,
    //                       fontWeight: FontWeight.w400),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(horizontal: 20.w),
    //         child: Button(
    //             borderSide: BorderSide(
    //               color: tPrimaryColor,
    //             ),
    //             color: tPrimaryColor,
    //             textcolor: tWhite,
    //             bottonText: 'Back to portfolio',
    //             onTap: (startLoading, stopLoading, btnState) async {
    //               Twl.navigateTo(context, BottomNavigation());
    //             }),
    //       ),
    //       SizedBox(
    //         height: 3.7.h,
    //       )
    //     ],
    //   ),
    // );
  }
}
