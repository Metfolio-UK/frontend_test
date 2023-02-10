import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants/constants.dart';
import '../../constants/imageConstant.dart';
import '../../responsive.dart';

class BuyContainerWidget extends StatelessWidget {
  const BuyContainerWidget({
    Key? key,
    this.tittle,
    this.goldgrams,
    this.date,
    this.cost,
    this.des,
  }) : super(key: key);
  final tittle;
  final goldgrams;
  final date;
  final cost;
  final des;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: tPrimaryColor),
          borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: tittle == 'Buy'
                  ? Image.asset(
                      Images.QUICKGOLD,
                      width: 20.sp,
                    )
                  : tittle == 'Sell'
                      ? Image.asset(
                          'images/sell.png',
                          width: 20.sp,
                        )
                      : tittle == 'Delivery'
                          ? Image.asset(
                              Images.DELIVERY,
                              width: 20.sp,
                            )
                          : Container(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goldgrams ?? "",
                  style: TextStyle(
                      color: tSecondaryColor,
                      fontFamily: 'Barlow',
                      fontSize: isTab(context) ? 9.sp : 12.sp,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  date ?? "",
                  style: TextStyle(
                      color: tSecondaryColor,
                      fontSize: isTab(context) ? 5.sp : 8.sp,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child:
                // Text(
                //         cost ?? "",
                //         style: TextStyle(
                //             color: tSecondaryColor,
                //             fontSize: isTab(context) ? 9.sp : 12.sp,
                //             fontWeight: FontWeight.w700),
                //       ),
                Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cost != null
                    ? Text(
                        cost ?? "",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: tSecondaryColor,
                          fontSize: isTab(context) ? 9.sp : 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : des != null
                        ? Text(
                            des ?? "",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: tSecondaryColor,
                              fontSize: isTab(context) ? 9.sp : 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(),
                // if (des != null)
                //   Text(
                //     des ?? "",
                //     style: TextStyle(
                //       color: tSecondaryColor,
                //       fontSize: isTab(context) ? 9.sp : 12.sp,
                //       fontWeight: FontWeight.w700,
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
