import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/constants.dart';
import '../../constants/imageConstant.dart';
import '../../globalFuctions/globalFunctions.dart';
import '../../globalWidgets/button.dart';

import '../../responsive.dart';
import '../bottomNavigation.dart/bottomNavigation.dart';

class DeliverySucessful extends StatefulWidget {
  const DeliverySucessful({Key? key, this.delivryQty}) : super(key: key);
  final delivryQty;
  @override
  State<DeliverySucessful> createState() => _DeliverySucessfulState();
}

class _DeliverySucessfulState extends State<DeliverySucessful> {
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
                        Images.DONE,
                        scale: 4.5,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Center(
                      child: Text(
                        // ${(widget.delivryQty ??0).toStringAsFixed(3)}
                        'Your Delivery is confirmed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Signika",
                            color: tTextSecondary,
                            fontSize: isTab(context) ? 13.sp : 16.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      'Thank you for your order, your details have \n been emailed to you!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: tSecondaryColor,
                          fontSize: isTab(context) ? 9.sp : 12.sp,
                          fontWeight: FontWeight.w400),
                    )
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
          //   height: 3.7.h,
          // )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        onPressed: () async {
          Twl.navigateTo(
              context, BottomNavigation(tabIndexId: 0, actionIndex: 0));
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
  }
}
