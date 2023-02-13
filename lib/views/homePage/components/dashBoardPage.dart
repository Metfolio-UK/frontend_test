import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:base_project_flutter/models/myOrders.dart';
import 'package:base_project_flutter/views/revivewPaymentDetails/revivewPaymentDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:base_project_flutter/constants/constants.dart';
import 'package:base_project_flutter/constants/imageConstant.dart';
import 'package:base_project_flutter/globalFuctions/globalFunctions.dart';
import 'package:base_project_flutter/main.dart';
import 'package:base_project_flutter/views/bottomNavigation.dart/bottomNavigation.dart';
import 'package:base_project_flutter/models/myOrders.dart' as myOrdersModel;
import 'package:flutter_stripe/flutter_stripe.dart' as st;

import 'package:base_project_flutter/views/nameyourgoal/nameyourgoal.dart';

import 'package:base_project_flutter/views/sorryscreen/sorryscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../api_services/orderApi.dart';
import '../../../api_services/stripeApi.dart';
import '../../../api_services/userApi.dart';
import '../../../provider/actionProvider.dart';
import '../../../responsive.dart';
import '../../activity/activity.dart';
import '../../components/BuyContainerWidget.dart';
import '../../components/goldcontainer.dart';
import '../../components/menuContainerWidget.dart';
import '../../nameyourgoal/GoalAmount.dart';
import '../../profilePage/profilePage.dart';
import '../../veriffPage/veriffPage.dart';
import 'goals.dart';

// ignore: must_be_immutable
class DashBoardPage extends StatefulWidget {
  final Function navigate;
  Function? innerNavvigate;

  DashBoardPage({required this.navigate, this.innerNavvigate});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage>
    with SingleTickerProviderStateMixin {
  late final _tabController;
  late ScrollController _scrollController;
  Future<myOrdersModel.MyOrderDetialsModel>? MyOrderDetials;
  final goalNameController = TextEditingController();
  final goalAmountController = TextEditingController();
  int repeatType = 0;
  bool goalIsActive = false;
  bool editGoalName = false;
  bool editGoalAmount = false;
  String goalName = "";
  String goalAmount = "";
  bool invalidEntryName = false;
  bool invalidEntryAmount = false;
  @override
  void initState() {
    checkLoginStatus();
    getGoldPrice();
    getMyGoal();
    setState(() {
      MyOrderDetials = UserAPI().getMyOrders(context, '0', '');
    });
    ActionProvider _data = Provider.of<ActionProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _data.phyGoldAction(1);
      _data.goalGoldAction(1);
    });
    _tabController = TabController(
        length: 2, vsync: this, animationDuration: Duration(milliseconds: 10));
    _scrollController = ScrollController();
    // TODO: implement initState
    super.initState();
  }

  var myGoalDetails;
  var goalTotalValue;
  var avalibleGoalGold;
  var defPaymentDeatils;
  var goalId;
  getMyGoal() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var res = await UserAPI().getMyGoals(context);
    if (mounted) {
      setState(() {
        myGoalDetails = res;
        // print("name_of_goal");
        // print(myGoalDetails['details']['name_of_goal']);
      });
    }
    if (res != null && res['status'] == 'OK') {
      setState(() {
        sharedPreferences.setString("goalName", res['details']['name_of_goal']);
        // myGoalDetails = res;
        goalId = res['details']['id'].toString();

        avalibleGoalGold = res['details']['availableGoldByGoal'];
      });
      var cusId = sharedPreferences.getString('cusId');
      print('cusId>>>>>>>>>>>>' + cusId.toString());
      var defPmId;
      var cusDetails = await StripePaymentApi()
          .getCustomerPaymentDetails(context, cusId.toString());
      print("cusDetails" + cusDetails.toString());
      if (cusDetails != null) {
        defPmId = cusDetails['invoice_settings']['default_payment_method'];

        print(defPmId);
        var result = await StripePaymentApi()
            .getCustomerCards(context, cusId.toString());
        print("cardlist>>>>>>>>");
        print(result);
        if (result != null) {
          for (var i = 0; i <= result['data']!.length - 1; i++) {
            if (result['data'][i]['id'] == defPmId) {
              if (mounted) {
                setState(() {
                  defPaymentDeatils = result['data'][i];
                });
              }
              break;
            }
          }
          print(defPaymentDeatils);
          // print("defPaymentDeatils>>>>>>" +
          //     defPaymentDeatils['card']['wallet']['type']);
        }
      }
    }
  }

  var res;
  var priceDetails;
  var phyGoldValue = 0.0;
  var totalGold = '0';
  var verifStatus;
  var goldWeigthRange;
  getGoldPrice() async {
    // var status = await checkVeriffStatus(context);
    // setState(() {
    //   verifStatus = status;
    //   print(verifStatus.runtimeType);
    // });
    // SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    // var authCode = sharedPrefs.getString('authCode');
    // var checkApi = await UserAPI().checkApi(authCode);
    // print(checkApi);
    // if (checkApi != null && checkApi['status'] == 'OK') {
    //   verifStatus = checkApi['detail']['veriff_status'];
    //   print(verifStatus.runtimeType);
    // } else {
    //   Twl.createAlert(context, 'error', checkApi['error']);
    // }

    res = await UserAPI().getGoldPrice(context);
    print('getGoldPrice>>>>>>>>>>>>>');
    print(res);
    setState(() {
      priceDetails = res['details'];

      goldWeigthRange = res['details']['gold_weight_ranges'];

      _priceController..text = _currentSliderValue.toString();
      finalBuyValue(_currentSliderValue, priceDetails['price_gram_24k']);
      if (avalibleGoalGold != null) {
        goalTotalValue = avalibleGoalGold * (priceDetails['price_gram_24k']);
        print('goalTotalValue');
        print(goalTotalValue);
      }
    });
    checkGold();
    // }

    print('getGoldPrice');
    print(res);
  }

  finalBuyValuewithGrams(qty, goldPrice) async {
    var mintingvalue;
    var mintingvaluebefore = await getMintingvalue(
      qty,
    );
    mintingvalue =
        mintingvaluebefore * double.parse(goldPrice.toStringAsFixed(3));
    var volatilityvalue;
    var volatilityvaluebefore = await getvolatilityvalue(
      qty,
    );
    volatilityvalue =
        volatilityvaluebefore * double.parse(goldPrice.toStringAsFixed(3));
    print('qty');
    print(qty);
    print("goldPrice");
    print(goldPrice);
    print('mintingvalue');
    print(mintingvalue);
    print('volatilityvalue');
    print(volatilityvalue);
    print(qty);
    var finalBuyPrice;
    for (var i = 0; i <= goldWeigthRange.length - 1; i++) {
      if (qty >= goldWeigthRange[i]['gold_range_start'] &&
          qty <= goldWeigthRange[i]['gold_range_end']) {
        print('Between>>>>>>>');
        // markupPercentage
        var markupPercentage = goldWeigthRange[i]['markup_percentage'];

        // TotalValueBeforeMarkup

        var TotalValueBeforeMarkup = goldPrice +
            double.parse(mintingvalue.toString()) +
            double.parse(volatilityvalue.toString());

        // FeesMarkup
        var FeesMarkup =
            (TotalValueBeforeMarkup) * goldWeigthRange[i]['markup_percentage'];
        // finalBuyPrice
        finalBuyPrice = TotalValueBeforeMarkup + FeesMarkup;
        print('markupPercentage');
        print(markupPercentage);
        print('FeesMarkup');
        print(FeesMarkup);
        print('finalBuyPrice');
        print(finalBuyPrice.toString());
        // print(roundOffToXDecimal(2.274, numberOfDecimal: 2));
        setState(() {
          _priceController
            ..text =
                // Secondarycurrency +
                (finalBuyPrice.toStringAsFixed(2)).toString();
        });
        print(finalBuyPrice.toStringAsFixed(2));

        break;
      }
      // else {
      //   // if (qty == '0' || qty == 0) {
      //   //   print('Not between');
      //   //   setState(() {
      //   //     _priceController..text = '0';
      //   //   });
      //   //   return '0';
      //   // }
      // }
    }
    return finalBuyPrice.toStringAsFixed(2);
  }

  getMintingvalue(goldPrice) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var mintingPercent;
    var mintingValue;
    print("minivallll");
    print(double.parse(sharedPreferences.getString('minting').toString()));
    setState(() {
      mintingPercent = sharedPreferences.getString('minting');
      mintingValue = (double.parse(mintingPercent) / 100);
      // *
      //     double.parse(goldPrice.toStringAsFixed(3));
    });
    // print(gram);
    // print(livePrice);
    // print('mintingPercent');
    // print(goldPrice.toStringAsFixed(3));
    // print(mintingPercent);
    // print(mintingValue);
    return mintingValue;
  }

  getvolatilityvalue(goldPrice) async {
    var volatilityPercent;
    var volatilityValue;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      volatilityPercent = sharedPreferences.getString('volatility');
      volatilityValue = (double.parse(volatilityPercent) / 100);
      //  *
      //     double.parse(goldPrice.toStringAsFixed(3));
    });
    return volatilityValue;
  }

  double roundDouble(double value, int places) {
    var mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  finalBuyValue(amount, liveGoldPrice) async {
    // var amount = 1132.96;
    // var liveGoldPrice = 47.4700;
    var mintingvalue = await getMintingvalue(liveGoldPrice);
    var volatilityvalue = await getvolatilityvalue(liveGoldPrice);
    print('amount');
    print(amount);
    print("liveGoldPrice");
    print(liveGoldPrice);
    print('mintingvalue');
    print(mintingvalue);
    print('volatilityvalue');
    print(volatilityvalue);
    var finalBuyPrice;
    var oneGram = 1;
    // var goldQuantityBeforeAddingTaxes = amount / liveGoldPrice;
    // print('goldQuantityBeforeAddingTaxes ' +
    //     goldQuantityBeforeAddingTaxes.toString());
    // print(qty);
    var markupPercentage;
    var totalValueBeforeMarkup;
    for (var i = 0; i <= goldWeigthRange.length - 1; i++) {
      var goldValue = (oneGram * liveGoldPrice).toStringAsFixed(4);
      // print('goldValue  ' + goldValue.toString());
      var barMinting =
          (double.parse(goldValue) * mintingvalue).toStringAsFixed(4);
      var volatilityFees =
          (double.parse(goldValue) * volatilityvalue).toStringAsFixed(4);
      // print("barMinting " + barMinting.toString());
      // print("volatilityFees " + volatilityFees.toString());
      totalValueBeforeMarkup = (double.parse(goldValue.toString()) +
              double.parse(barMinting.toString()) +
              double.parse(volatilityFees.toString()))
          .toStringAsFixed(4);
      print('totalValueBeforeMarkup' + totalValueBeforeMarkup.toString());

      if (amount >= goldWeigthRange[i]['range_price_start'] &&
          amount <= goldWeigthRange[i]['range_orice_end']) {
        markupPercentage =
            (goldWeigthRange[i]['markup_percentage']).toStringAsFixed(2);
        print('markupPercentage ' + markupPercentage.toString());
        // var FeesMarkup =
        //     (double.parse(markupPercentage) * totalValueBeforeMarkup)
        //         .toStringAsFixed(4);
        // print('FeesMarkup ' + FeesMarkup.toString());
        // var buyPrice = (double.parse(FeesMarkup.toString()) +
        //         double.parse(totalValueBeforeMarkup.toString()))
        //     .toStringAsFixed(4);
        // print('buyPrice ' + buyPrice.toString());
        // finalBuyPrice = (double.parse(buyPrice)).toStringAsFixed(3);
        // print(finalBuyPrice);
        // print('finalBuyPrice ' + finalBuyPrice.toString());
        // break
      }
      //  else {
      //   markupPercentage = (goldWeigthRange[goldWeigthRange.length - 1]
      //           ['markup_percentage'])
      //       .toStringAsFixed(2);
      //   // print('markupPercentage ' + markupPercentage.toString());
      //   // var FeesMarkup =
      //   //     (double.parse(markupPercentage) * totalValueBeforeMarkup)
      //   //         .toStringAsFixed(4);
      //   // // print('FeesMarkup ' + FeesMarkup.toString());
      //   // var buyPrice = (double.parse(FeesMarkup.toString()) +
      //   //         double.parse(totalValueBeforeMarkup.toString()))
      //   //     .toStringAsFixed(4);
      //   // // print('buyPrice ' + buyPrice.toString());
      //   // finalBuyPrice = (double.parse(buyPrice)).toStringAsFixed(3);
      //   // print(finalBuyPrice);
      // }

    }
    print(markupPercentage);
    var feesMarkup =
        (double.parse(markupPercentage) * double.parse(totalValueBeforeMarkup))
            .toStringAsFixed(4);
    print('FeesMarkup ' + feesMarkup.toString());
    var buyPrice = (double.parse(feesMarkup.toString()) +
            double.parse(totalValueBeforeMarkup.toString()))
        .toStringAsFixed(4);
    print('buyPrice ' + buyPrice.toString());
    finalBuyPrice = (double.parse(buyPrice)).toStringAsFixed(3);
    print(finalBuyPrice);
    print('finalBuyPrice ' + finalBuyPrice.toString());
    print("asdbcsa");
    print(finalBuyPrice);
    print(double.parse(finalBuyPrice).toStringAsFixed(3));
    var goldUnits = (amount / double.parse(finalBuyPrice)).toStringAsFixed(3);
    print('goldUnits ' + goldUnits);
    setState(() {
      _qtyController..text = goldUnits;
    });
    return goldUnits;
  }

  checkGold() async {
    var res =
        await UserAPI().checkAvaliableGold(context, physicalGold.toString());
    if (res != null && res['status'] == "OK") {
      if (mounted) {
        setState(() {
          totalGold = res['details']['availableGold'].toStringAsFixed(3);
          if (totalGold != null) {
            phyGoldValue = double.parse(totalGold.toString()) *
                (priceDetails['price_gram_24k']);
          }
        });
      }
    } else {}
    print('totalGold>>>>>>>>>>>>>');
    // print(totalGold);
    print(phyGoldValue);
    print(double.parse(totalGold.toString()));
  }

  var phyGoldType = 1;

  var selectedIndex = 0;
  var btnColor = tTextformfieldColor;
  var selectedvalue;

  late SharedPreferences sharedPreferences;
  var mobileNo;
  var email;
  var firstname;
  var check;
  var profileImage;
  var authCode;
  var details;
  var lastName;

  String pay = "bank";
  String repeat = "monthly";
  TextEditingController _priceController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();

  double _currentSliderValue = 1;

  show() {
    showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          // UDE : SizedBox instead of Container for whitespaces
          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(height: 5),
                Center(
                    child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                      color: _getColorFromHex("#DEB14A"),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                )),
                Container(height: 20),
                Center(
                    child: Text("Type amount or use the slider",
                        style: TextStyle(
                            fontFamily: "Barlow",
                            fontWeight: FontWeight.w300,
                            color: tTextSecondary,
                            fontSize: 14))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("\nStart Goal",
                        style: TextStyle(
                            fontFamily: "Barlow",
                            fontWeight: FontWeight.bold,
                            color: tTextSecondary,
                            fontSize: 31)),
                  ],
                ),
                Container(height: 10),
                Container(
                    height: 40,
                    width: 360,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: _getColorFromHex("#1E365B"),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: 99,
                            child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("GBP(£) ",
                                        style: TextStyle(
                                            fontFamily: "Barlow",
                                            fontWeight: FontWeight.w700,
                                            color: tTextSecondary,
                                            fontSize: 16)),
                                    Image.asset('images/euro.png', height: 20),
                                  ]),
                            )),
                        Container(
                          width: 1,
                          height: 40,
                          color: _getColorFromHex("#1E365B"),
                        ),
                        Container(
                            width: 226,
                            child: Center(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: _priceController,

                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(
                                        r'^0'), //users can't type 0 at 1st position
                                  ),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]+[.]{0,1}[0-9]*')),
                                  LengthLimitingTextFieldFormatterFixed(50000),
                                  DecimalTextInputFormatter(decimalRange: 2)
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                // readOnly: true,
                                // keyboardType: TextInputType.phone,
                                onChanged: (value) async {
                                  if (value != '') {
                                    var finalGrams = await finalBuyValue(
                                        double.parse(value),
                                        priceDetails['price_gram_24k']);
                                    if (double.parse(value) >= 1) {
                                      print((double.parse(value)) <= 100);
                                      print(finalGrams);
                                      if ((double.parse(value)) <= 5000) {
                                        setState(() {
                                          _currentSliderValue =
                                              (double.parse(value));
                                          if (value != '') {
                                            // _qtyController..text = finalGrams;
                                          } else {
                                            _qtyController..text = '0';
                                          }
                                        });
                                      } else if ((double.parse(value)) >=
                                          50000) {
                                        print("objegfbfgbfct");
                                        setState(() {
                                          _currentSliderValue = 5000;
                                        });
                                      } else {
                                        setState(() {
                                          _currentSliderValue = 5000;
                                          _qtyController..text = finalGrams;
                                        });
                                      }
                                    } else {
                                      if (double.parse(value) >= 1) {
                                        _currentSliderValue =
                                            double.parse(value);
                                      }
                                      setState(() {
                                        _qtyController..text = '0';
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _qtyController..text = '0';
                                    });
                                  }
                                },
                                style: TextStyle(
                                    fontFamily: 'Signika',
                                    color: tTextSecondary,
                                    fontSize: isTab(context) ? 13.sp : 16.sp,
                                    fontWeight: FontWeight.w400),
                                // maxLength: 4,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  errorStyle: TextStyle(height: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.red,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),

                                  // prefix: Text('+91 ',style: TextStyle(color: tBlack),),
                                  // prefixText: 'GBP ($Secondarycurrency):',

                                  counterText: "",
                                  // isDense: true,
                                  contentPadding: EdgeInsets.only(
                                    right: 21.w,
                                    left: 20,
                                    top: 9,
                                    bottom: 9,
                                  ),
                                  prefixStyle: TextStyle(
                                      fontFamily: 'Signika',
                                      color: tTextSecondary,
                                      fontSize: isTab(context) ? 13.sp : 16.sp,
                                      fontWeight: FontWeight.w400),
                                  // prefixIcon: Padding(
                                  //   padding: const EdgeInsets.only(
                                  //     top: 10,
                                  //     left: 20,
                                  //   ),
                                  //   child: Text(
                                  //     'GBP ($Secondarycurrency):',
                                  //     style: TextStyle(
                                  //       fontFamily: 'Signika',
                                  //       color: tTextSecondary,
                                  //       fontSize: isTab(context) ? 12.sp : 13.sp,
                                  //       fontWeight: FontWeight.w400,
                                  //     ),
                                  //     textAlign: TextAlign.center,
                                  //   ),
                                  // ),
                                  hintText: Secondarycurrency,
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: tSecondaryColor.withOpacity(0.3),
                                      fontSize: isTab(context) ? 9.sp : 12.sp),
                                  // hintText: 'Enter Your Mobile Number',
                                  fillColor: tPrimaryTextformfield,
                                  // contentPadding: EdgeInsets.only(
                                  // right: 21.w,
                                  // left: 20,
                                  //   top: 2,
                                  //   bottom: 2,
                                  // ),
                                  // filled: true,
                                  // border: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(10),
                                  //   borderSide: BorderSide(
                                  //     width: 0,
                                  //     style: BorderStyle.none,
                                  //   ),
                                  // ),
                                ),
                              ),
                            ))
                      ],
                    )),
                Container(height: 10),
                Container(
                  width: double.infinity,
                  child: CupertinoSlider(
                      thumbColor: tTextSecondary,
                      activeColor: tTextSecondary,
                      divisions: 5000,
                      max: 5000,
                      min: 1,
                      value: _currentSliderValue,
                      onChanged: (value) async {
                        // var goldPrice =
                        //     value * priceDetails['price_gram_24k'];
                        var goldPrice = priceDetails['price_gram_24k'];
                        print(roundDouble(value, 0));
                        var finalBuyPrice = await finalBuyValue(
                            roundDouble(value, 0), goldPrice);
                        print(finalBuyPrice);
                        setState(() {
                          _currentSliderValue = value;
                          _qtyController..text = finalBuyPrice;
                          _priceController..text = value.toStringAsFixed(0);
                        });
                      }),
                ),
                Container(height: 10),
                Container(
                    height: 40,
                    width: 360,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: _getColorFromHex("#1E365B"),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: 99,
                            child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Gold(g) ",
                                        style: TextStyle(
                                            fontFamily: "Barlow",
                                            fontWeight: FontWeight.w700,
                                            color: tTextSecondary,
                                            fontSize: 16)),
                                    Image.asset(Images.GOLD, height: 16),
                                  ]),
                            )),
                        Container(
                          width: 1,
                          height: 40,
                          color: _getColorFromHex("#1E365B"),
                        ),
                        Container(
                            width: 226,
                            child: Center(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: _qtyController,
                                // keyboardType: TextInputType.phone,
                                // readOnly: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]+[.]{0,1}[0-9]*')),
                                  // FilteringTextInputFormatter.deny(
                                  //   RegExp(
                                  //       r'^0'), //users can't type 0 at 1st position
                                  // ),
                                  DecimalTextInputFormatter(decimalRange: 3),
                                  LengthLimitingTextFieldFormatterFixed(1000),
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                // focusNode: FocusNode(),
                                // onTap: () => TextSelection(
                                //       baseOffset: 0,
                                //       extentOffset:
                                //           _qtyController.value.text.length - 1,
                                //     ),

                                onChanged: (value) async {
                                  if (value != '') {
                                    // if (double.parse(value) != 1 ) {
                                    setState(() {
                                      //     _qtyController
                                      //       ..text = num.parse(value)
                                      //           .toDouble()
                                      //           .toString();
                                      _qtyController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: _qtyController
                                                      .text.length));
                                    });
                                    // }\

                                    if ((1000 >=
                                        double.parse(value.toString()))) {
                                      var goldPrice =
                                          double.parse(value).toDouble() *
                                              priceDetails['price_gram_24k'];
                                      var finalBuyPrice =
                                          await finalBuyValuewithGrams(
                                              roundDouble(
                                                  double.parse(value), 3),
                                              goldPrice);
                                      if (double.parse(value) < 100) {
                                        setState(() {
                                          if (double.parse(finalBuyPrice) <=
                                                  100 &&
                                              double.parse(finalBuyPrice) >=
                                                  1) {
                                            _currentSliderValue = double.parse(
                                                finalBuyPrice.toString());
                                            _priceController
                                              ..text = finalBuyPrice;
                                          } else {
                                            _currentSliderValue = 100;
                                            _priceController
                                              ..text = finalBuyPrice;
                                          }
                                        });
                                      } else {
                                        _currentSliderValue = 5000;
                                        _priceController..text = finalBuyPrice;
                                        // Twl.createAlert(context, "error",
                                        //     "you can buy max 100 grams");
                                      }
                                    }
                                  } else {
                                    _priceController..text = '0';
                                  }
                                },
                                style: TextStyle(
                                    fontFamily: 'Signika',
                                    color: tTextSecondary,
                                    fontSize: isTab(context) ? 13.sp : 16.sp,
                                    fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.red,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),

                                  // prefixText: 'Grams:',
                                  // prefixStyle: TextStyle(
                                  //   fontFamily: 'Signika',
                                  //   color: tTextSecondary,
                                  //   fontSize: isTab(context) ? 13.sp : 16.sp,
                                  //   fontWeight: FontWeight.w400,
                                  // ),
                                  // prefixIcon: Padding(
                                  //   padding: const EdgeInsets.only(
                                  //     top: 10,
                                  //     left: 20,
                                  //   ),
                                  //   child: Text(
                                  //     'Grams:',
                                  //     style: TextStyle(
                                  //       fontFamily: 'Signika',
                                  //       color: tTextSecondary,
                                  //       fontSize: isTab(context) ? 12.sp : 13.sp,
                                  //       fontWeight: FontWeight.w400,
                                  //     ),
                                  //     textAlign: TextAlign.center,
                                  //   ),
                                  // ),
                                  // prefix: Text('+91 ',style: TextStyle(color: tBlack),),
                                  hintText: 'g',
                                  errorStyle: TextStyle(height: 0),
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: tSecondaryColor.withOpacity(0.3),
                                      fontSize: isTab(context) ? 9.sp : 12.sp),
                                  // hintText: 'Enter Your Mobile Number',
                                  fillColor: tPrimaryTextformfield,
                                  contentPadding: EdgeInsets.only(
                                    right: 20.w,
                                    left: 20,
                                    top: 9,
                                    bottom: 9,
                                  ),
                                  filled: false,
                                  // border: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(10),
                                  //   borderSide: BorderSide(
                                  //     width: 0,
                                  //     style: BorderStyle.none,
                                  //   ),
                                  // ),
                                  isDense: true,
                                ),
                              ),
                            ))
                      ],
                    )),
                Container(height: 120),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter
                                            setState /*You can rename this!*/) {
                                  // UDE : SizedBox instead of Container for whitespaces
                                  return Container(
                                      height: 1000,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 24,
                                                        left: 8,
                                                        right: 16),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('Paying with',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Barlow",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      tTextSecondary,
                                                                  fontSize:
                                                                      26)),
                                                          GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                show();
                                                              },
                                                              child: Text(
                                                                  "Done",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "SignikaB",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: _getColorFromHex(
                                                                          "#2AB2BC"),
                                                                      fontSize:
                                                                          20)))
                                                        ])),
                                                Divider(
                                                    color: _getColorFromHex(
                                                        "#707070")),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12, left: 12),
                                                    child: Text("Pay with Bank",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 15))),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: "Fee: ",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 10),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: "No Fees ",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Barlow",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: _getColorFromHex(
                                                                    "#2AB2BC"),
                                                                fontSize: 10),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                Container(
                                                  height: 15,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    //    Twl.navigateBack(context);
                                                    setState(() {
                                                      pay = "bank";
                                                    });
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            "images/Bank.png",
                                                            height: 30,
                                                          ),
                                                          SizedBox(width: 15),
                                                          Text(
                                                            'Pay with Bank',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Barlow',
                                                              fontSize:
                                                                  isTab(context)
                                                                      ? 10.sp
                                                                      : 12.sp,
                                                              color:
                                                                  tSecondaryColor,
                                                            ),
                                                          ),
                                                          Spacer(),

                                                          /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                          Image.asset(
                                                            (pay == "bank")
                                                                ? 'images/yes.png'
                                                                : 'images/no.png',
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 12,
                                                      bottom: 10,
                                                    ),
                                                    child: Container(
                                                        height: 0.6,
                                                        color: _getColorFromHex(
                                                            "#707070"))),
                                                //Pay with card

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12, left: 12),
                                                    child: Text('Pay with Card',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 15))),

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: "Fee: ",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 10),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                "2.7% + 20p (Card Processing Fee) ",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Barlow",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: _getColorFromHex(
                                                                    "#2AB2BC"),
                                                                fontSize: 10),
                                                          ),
                                                        ],
                                                      ),
                                                    )),

                                                Container(
                                                  height: 15,
                                                ),
                                                if (Platform.isAndroid &&
                                                    !Platform.isIOS)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      //    Twl.navigateBack(context);
                                                      setState(() {
                                                        pay = "google";
                                                      });
                                                    },
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 12,
                                                                right: 12),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              "assets/icons/gpay_Pay_Mark.png",
                                                              width: 30,
                                                            ),
                                                            SizedBox(width: 15),
                                                            Text(
                                                              "Google Pay",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Barlow',
                                                                fontSize: isTab(
                                                                        context)
                                                                    ? 10.sp
                                                                    : 12.sp,
                                                                color:
                                                                    tSecondaryColor,
                                                              ),
                                                            ),
                                                            Spacer(),

                                                            /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                            Image.asset(
                                                              (pay == "google")
                                                                  ? 'images/yes.png'
                                                                  : 'images/no.png',
                                                              height: 20,
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                if (Platform.isAndroid &&
                                                    !Platform.isIOS)
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 12,
                                                        top: 12,
                                                        bottom: 10,
                                                      ),
                                                      child: Container(
                                                          height: 0.6,
                                                          color:
                                                              _getColorFromHex(
                                                                  "#707070"))),
                                                if (Platform.isAndroid &&
                                                    !Platform.isIOS)
                                                  Container(
                                                    height: 0,
                                                  ),
                                                //pay with apple
                                                if (st.Stripe.instance
                                                    .isApplePaySupported.value)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      //    Twl.navigateBack(context);
                                                      setState(() {
                                                        pay = "apple";
                                                      });
                                                    },
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 12,
                                                                right: 12),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              "assets/icons/applePayBlack.png",
                                                              width: 30,
                                                            ),
                                                            SizedBox(width: 15),
                                                            Text(
                                                              "Apple Pay",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Barlow',
                                                                fontSize: isTab(
                                                                        context)
                                                                    ? 10.sp
                                                                    : 12.sp,
                                                                color:
                                                                    tSecondaryColor,
                                                              ),
                                                            ),
                                                            Spacer(),

                                                            /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                            Image.asset(
                                                              (pay == "apple")
                                                                  ? 'images/yes.png'
                                                                  : 'images/no.png',
                                                              height: 20,
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                if (st.Stripe.instance
                                                    .isApplePaySupported.value)
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 12,
                                                        top: 12,
                                                        bottom: 10,
                                                      ),
                                                      child: Container(
                                                          height: 0.6,
                                                          color:
                                                              _getColorFromHex(
                                                                  "#707070"))),

                                                if (st.Stripe.instance
                                                    .isApplePaySupported.value)
                                                  Container(
                                                    height: 10,
                                                  ),
                                                //pay with debit

                                                GestureDetector(
                                                  onTap: () async {
                                                    //    Twl.navigateBack(context);
                                                    setState(() {
                                                      pay = "card";
                                                    });
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            "assets/icons/cardIcon.png",
                                                            width: 30,
                                                          ),
                                                          SizedBox(width: 15),
                                                          Text(
                                                            "Add debit/credit card",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Barlow',
                                                              fontSize:
                                                                  isTab(context)
                                                                      ? 10.sp
                                                                      : 12.sp,
                                                              color:
                                                                  tSecondaryColor,
                                                            ),
                                                          ),
                                                          Spacer(),

                                                          /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                          Image.asset(
                                                            (pay == "card")
                                                                ? 'images/yes.png'
                                                                : 'images/no.png',
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )),
                                                ),

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 12,
                                                      bottom: 10,
                                                    ),
                                                    child: Container(
                                                        height: 0.6,
                                                        color: _getColorFromHex(
                                                            "#707070"))),
                                              ])));
                                });
                              });
                        },
                        child: Column(children: [
                          Row(children: [
                            Text("Paying with",
                                style: TextStyle(
                                    fontFamily: "Barlow",
                                    fontWeight: FontWeight.w300,
                                    color: tTextSecondary,
                                    fontSize: 12)),
                            Container(width: 50)
                          ]),
                          Transform.translate(
                              offset: Offset(
                                  (pay == "card" || pay == "bank") ? -17 : 0,
                                  2),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    (pay == "bank")
                                        ? Image.asset('images/Bank.png',
                                            height: 25)
                                        : (pay == "card")
                                            ? Image.asset(
                                                'assets/icons/cardIcon.png',
                                                width: 25)
                                            : (pay == "apple")
                                                ? Image.asset(
                                                    'assets/icons/applePayBlack.png',
                                                    width: 25)
                                                : Image.asset(
                                                    'assets/icons/gpay_Pay_Mark.png',
                                                    width: 25),
                                    Text(
                                        (pay == "bank")
                                            ? " Bank "
                                            : (pay == "card")
                                                ? " Card "
                                                : (pay == "apple")
                                                    ? " Apple Pay "
                                                    : " Google Pay ",
                                        style: TextStyle(
                                            fontFamily: "Barlow",
                                            fontWeight: FontWeight.w700,
                                            color: tTextSecondary,
                                            fontSize: 14)),
                                    Image.asset('assets/icons/expandmore.png',
                                        height: 11),
                                  ]))
                        ])),
                    GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter
                                            setState /*You can rename this!*/) {
                                  // UDE : SizedBox instead of Container for whitespaces
                                  return Container(
                                      height: 1000,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 24,
                                                        left: 8,
                                                        right: 16),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('Repeats on',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Barlow",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      tTextSecondary,
                                                                  fontSize:
                                                                      26)),
                                                          GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                show();
                                                              },
                                                              child: Text(
                                                                  "Done",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "SignikaB",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: _getColorFromHex(
                                                                          "#2AB2BC"),
                                                                      fontSize:
                                                                          20)))
                                                        ])),
                                                Divider(
                                                    color: _getColorFromHex(
                                                        "#707070")),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12, left: 12),
                                                    child: Text("Start Date",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 15))),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: "",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 10),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                "Your first transaction will occur on this date",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Barlow",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: _getColorFromHex(
                                                                    "#2AB2BC"),
                                                                fontSize: 10),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                Container(
                                                  height: 15,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    //    Twl.navigateBack(context);
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Start Date - 11/02/2023',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Barlow',
                                                              fontSize:
                                                                  isTab(context)
                                                                      ? 10.sp
                                                                      : 12.sp,
                                                              color:
                                                                  tSecondaryColor,
                                                            ),
                                                          ),
                                                          Spacer(),

                                                          /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                          Image.asset(
                                                            'images/yes.png',
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 12,
                                                      bottom: 10,
                                                    ),
                                                    child: Container(
                                                        height: 0.6,
                                                        color: _getColorFromHex(
                                                            "#707070"))),
                                                //Pay with card

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12, left: 12),
                                                    child: Text('Repeats',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 15))),

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: "",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Barlow",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                tTextSecondary,
                                                            fontSize: 10),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                "Your subsequent transactions will occur on this schedule",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Barlow",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: _getColorFromHex(
                                                                    "#2AB2BC"),
                                                                fontSize: 10),
                                                          ),
                                                        ],
                                                      ),
                                                    )),

                                                Container(
                                                  height: 15,
                                                ),

                                                GestureDetector(
                                                  onTap: () async {
                                                    //    Twl.navigateBack(context);
                                                    setState(() {
                                                      repeat = "daily";
                                                    });
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Daily",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Barlow',
                                                              fontSize:
                                                                  isTab(context)
                                                                      ? 10.sp
                                                                      : 12.sp,
                                                              color:
                                                                  tSecondaryColor,
                                                            ),
                                                          ),
                                                          Spacer(),

                                                          /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                          Image.asset(
                                                            (repeat == "daily")
                                                                ? 'images/yes.png'
                                                                : 'images/no.png',
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )),
                                                ),

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 12,
                                                      bottom: 10,
                                                    ),
                                                    child: Container(
                                                        height: 0.6,
                                                        color: _getColorFromHex(
                                                            "#707070"))),

                                                Container(
                                                  height: 0,
                                                ),
                                                //pay with apple

                                                GestureDetector(
                                                  onTap: () async {
                                                    //    Twl.navigateBack(context);
                                                    setState(() {
                                                      repeat = "weekly";
                                                    });
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Weekly",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Barlow',
                                                              fontSize:
                                                                  isTab(context)
                                                                      ? 10.sp
                                                                      : 12.sp,
                                                              color:
                                                                  tSecondaryColor,
                                                            ),
                                                          ),
                                                          Spacer(),

                                                          /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                          Image.asset(
                                                            (repeat == "weekly")
                                                                ? 'images/yes.png'
                                                                : 'images/no.png',
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )),
                                                ),

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 12,
                                                      bottom: 10,
                                                    ),
                                                    child: Container(
                                                        height: 0.6,
                                                        color: _getColorFromHex(
                                                            "#707070"))),

                                                Container(
                                                  height: 10,
                                                ),
                                                //pay with debit

                                                GestureDetector(
                                                  onTap: () async {
                                                    //    Twl.navigateBack(context);
                                                    setState(() {
                                                      repeat = "monthly";
                                                    });
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Monthly",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Barlow',
                                                              fontSize:
                                                                  isTab(context)
                                                                      ? 10.sp
                                                                      : 12.sp,
                                                              color:
                                                                  tSecondaryColor,
                                                            ),
                                                          ),
                                                          Spacer(),

                                                          /*  Text(
                          '${physcialGold.toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),*/

                                                          Image.asset(
                                                            (repeat ==
                                                                    "monthly")
                                                                ? 'images/yes.png'
                                                                : 'images/no.png',
                                                            height: 20,
                                                          ),
                                                        ],
                                                      )),
                                                ),

                                                Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 12,
                                                      top: 12,
                                                      bottom: 10,
                                                    ),
                                                    child: Container(
                                                        height: 0.6,
                                                        color: _getColorFromHex(
                                                            "#707070"))),
                                              ])));
                                });
                              });
                        },
                        child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Repeats",
                                    style: TextStyle(
                                        fontFamily: "Barlow",
                                        fontWeight: FontWeight.w300,
                                        color: tTextSecondary,
                                        fontSize: 12)),
                                Container(width: 110)
                              ]),
                          Transform.translate(
                              offset: Offset(-10, 2),
                              child: Row(children: [
                                Container(
                                    height: 25,
                                    child: Center(
                                        child: Image.asset("images/Cal.png",
                                            height: 20))),
                                Text(
                                    " ${(repeat == "daily") ? 'Daily' : (repeat == "weekly") ? 'Weekly' : 'Monthly'}  on 11th ",
                                    style: TextStyle(
                                        fontFamily: "Barlow",
                                        fontWeight: FontWeight.w700,
                                        color: tTextSecondary,
                                        fontSize: 14)),
                                Image.asset('assets/icons/expandmore.png',
                                    height: 11),
                              ]))
                        ]))
                  ],
                ),
                Container(height: 20),
                Container(
                    height: 40,
                    width: 356,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: _getColorFromHex("#E5B02C"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();

                        var price;
                        var qty;
                        setState(() {
                          var qtyFormate =
                              num.parse(_qtyController.text).toDouble();
                          var priceFormate =
                              num.parse(_priceController.text).toDouble();
                          price = priceFormate.toStringAsFixed(2);
                          qty = qtyFormate.toString();
                        });
                        Twl.navigateTo(
                            context,
                            RevivewPaymentDetails(
                                repeat: repeat,
                                qty: qty.replaceAll(RegExp('g'), ''),
                                price: price.replaceAll(
                                    RegExp(Secondarycurrency), ''),
                                type: Recuring,
                                goldType: '1',
                                liveGoldPrice: priceDetails['price_gram_24k'],
                                payment: pay));
                      },
                      child: Text("Continue",
                          style: TextStyle(
                              fontFamily: "Barlow",
                              fontWeight: FontWeight.w700,
                              color: tTextSecondary,
                              fontSize: 20)),
                    )),
                Container(height: 5),
              ],
            ),
          );
        });
      },
    );
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    authCode = sharedPreferences.getString('authCode');
    check = await UserAPI().checkApi(sharedPreferences.getString('authCode')!);
    print(check);
    if (check != null && check['status'] == 'OK') {
      setState(() {
        details = check['detail'];
      });
      sharedPreferences.setString(
          'contactnumber', check['detail']['contact_no'].toString());
      sharedPreferences.setString('email', check['detail']['email'].toString());

      sharedPreferences.setString(
          'username', check['detail']['username'].toString());
      sharedPreferences.setString(
          'firstName', check['detail']['first_name'].toString());
      sharedPreferences.setString('lastName', check['detail']['last_name']);
      if (check['detail']['profile_image'] != null) {
        sharedPreferences.setString(
            "profile_image", check['detail']['profile_image']);
      }
    }

    setState(() {
      mobileNo = sharedPreferences.getString("contactnumber") != null
          ? sharedPreferences.getString("contactnumber")
          : ' ';
      print(mobileNo);
      email = sharedPreferences.getString('email') != null
          ? sharedPreferences.getString('email')
          : ' ';
      firstname = sharedPreferences.getString('firstName') != null
          ? sharedPreferences.getString('firstName')
          : ' ';
      lastName = sharedPreferences.getString('lastName') != null
          ? sharedPreferences.getString('lastName')
          : '';
      profileImage = sharedPreferences.getString('profile_image') != null
          ? sharedPreferences.getString('profile_image')
          : 'https://img.icons8.com/bubbles/50/000000/user.png';
    });
  }

  bool loading = false;

  void repeatgoal() {
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStates2) {
        return Container(
          height: 90.h,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      child: Container(
                        height: 4,
                        width: 20.w,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: tPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Repeats on",
                            style: TextStyle(
                              fontFamily: 'Barlow',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Done",
                            style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: tlightBlue),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Divider(
                      height: 4,
                      color: tgrayColor2,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start Date",
                            style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Your first transaction will occur on this date",
                            style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 10,
                                color: grayColor,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today - 23/02/2023",
                                style: TextStyle(
                                    fontFamily: 'Barlow',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: tgreenColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: tSecondaryColor)),
                                child: Center(
                                  child: Image.asset(
                                    "images/tick.png",
                                    width: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Divider(
                            height: 4,
                            color: tGray,
                          ),
                          SizedBox(
                            height: 32,
                          ),
                          Text(
                            "Repeats",
                            style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Your subsequent transactions will occur on this schedule",
                            style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 10,
                                color: grayColor,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Daily",
                                style: TextStyle(
                                    fontFamily: 'Barlow',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  setStates2(() {
                                    repeatType = 0;
                                  });
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                      color: repeatType == 0
                                          ? tgreenColor
                                          : twhiteColor2,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: tSecondaryColor)),
                                  child: Center(
                                    child: repeatType != 0
                                        ? null
                                        : Image.asset(
                                            "images/tick.png",
                                            width: 14,
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Divider(
                            height: 4,
                            color: tlightGray,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Weekly",
                                style: TextStyle(
                                    fontFamily: 'Barlow',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  setStates2(() {
                                    repeatType = 1;
                                  });
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                      color: repeatType == 1
                                          ? tgreenColor
                                          : twhiteColor2,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: tSecondaryColor)),
                                  child: Center(
                                    child: repeatType != 1
                                        ? null
                                        : Image.asset(
                                            "images/tick.png",
                                            width: 14,
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Divider(
                            height: 4,
                            color: tlightGray,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Monthly",
                                style: TextStyle(
                                    fontFamily: 'Barlow',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  setStates2(() {
                                    repeatType = 2;
                                  });
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                      color: repeatType == 2
                                          ? tgreenColor
                                          : twhiteColor2,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: tSecondaryColor)),
                                  child: Center(
                                    child: repeatType != 2
                                        ? null
                                        : Image.asset(
                                            "images/tick.png",
                                            width: 14,
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  void editgoal() {
    // getGoalData();
    print("myGoalDetails--->" + myGoalDetails.toString());
    goalNameController.text = myGoalDetails['details']['name_of_goal'];
    goalAmountController.text =
        myGoalDetails['details']['goal_amount'].toString();
    goalIsActive =
        myGoalDetails['details']['current_status'] == 2 ? true : false;
    print("defPaymentDeatils");
    print(defPaymentDeatils);
    setState(() {
      editGoalName = false;
      editGoalAmount = false;
      invalidEntryName = false;
      invalidEntryAmount = false;
    });
    showMaterialModalBottomSheet(
      // isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (contexts, setStates) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              setStates(() {
                editGoalName = false;
                editGoalAmount = false;
              });
            },
            child: Container(
              height: 75.h,
              padding: MediaQuery.of(context).viewInsets,
              child: CustomScrollView(
                // padding: EdgeInsets.all(0),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Align(
                          child: Container(
                            height: 4,
                            width: 20.w,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: tPrimaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Edit Goal",
                                    style: TextStyle(
                                      fontFamily: 'Barlow',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          backgroundColor: tredColor,
                                          radius: 12,
                                          child: Image.asset(
                                            "images/bin.png",
                                            width: 15,
                                          )),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "End Goal",
                                        style: TextStyle(
                                          fontFamily: 'Barlow',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: tYellow,
                                        size: 16,
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Click off the popup to discard\nchanges.",
                                style: TextStyle(
                                    fontFamily: 'Barlow',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: grayColor),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Text(
                                "Goal Name",
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: invalidEntryName
                                            ? tredColor
                                            : tSecondaryColor)),
                                child: editGoalName
                                    ? TextFormField(
                                        autofocus: true,
                                        textAlign: TextAlign.center,
                                        controller: goalNameController,
                                        style: TextStyle(
                                            fontFamily: 'Barlow',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(0),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setStates(() {
                                            if (!editGoalName)
                                              editGoalName = true;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                goalNameController.text,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Barlow',
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Icon(
                                              Icons.edit,
                                              size: 14,
                                            )
                                          ],
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Goal Status",
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                    border: Border.all(color: tSecondaryColor),
                                    borderRadius: BorderRadius.circular(24)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setStates(() {
                                            if (!goalIsActive)
                                              goalIsActive = true;
                                          });
                                        },
                                        child: Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                              color: goalIsActive
                                                  ? tPrimaryColor
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          child: Center(
                                            child: Text(
                                              "Active",
                                              style: TextStyle(
                                                  fontFamily: 'Barlow',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: tSecondaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setStates(() {
                                            if (goalIsActive)
                                              goalIsActive = false;
                                          });
                                        },
                                        child: Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                              color: !goalIsActive
                                                  ? tPrimaryColor
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          child: Center(
                                            child: Text(
                                              "Inactive",
                                              style: TextStyle(
                                                  fontFamily: 'Barlow',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: tSecondaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Recurring Order of:",
                                style: TextStyle(
                                  fontFamily: 'Barlow',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: invalidEntryAmount
                                            ? tredColor
                                            : tSecondaryColor)),
                                child: editGoalAmount
                                    ? TextFormField(
                                        autofocus: true,
                                        textAlign: TextAlign.center,
                                        controller: goalAmountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        style: TextStyle(
                                            fontFamily: 'Barlow',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(0),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setStates(() {
                                            if (!editGoalAmount)
                                              editGoalAmount = true;
                                            print(editGoalAmount);
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "£${getAmount(goalAmountController.text)} worth of Gold",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Barlow',
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Icon(
                                              Icons.edit,
                                              size: 14,
                                            )
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Paying with",
                                        style: TextStyle(
                                          fontFamily: 'Barlow',
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      if (defPaymentDeatils != null)
                                        Row(
                                          children: [
                                            Image.asset(
                                              getcardType(defPaymentDeatils[
                                                          'card']['wallet'] !=
                                                      null
                                                  ? defPaymentDeatils['card']
                                                      ['wallet']['type']
                                                  : ''),
                                              width: 30,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              getcardTypeName(defPaymentDeatils[
                                                          'card']['wallet'] !=
                                                      null
                                                  ? defPaymentDeatils['card']
                                                      ['wallet']['type']
                                                  : ''),
                                              style: TextStyle(
                                                  fontFamily: 'Barlow',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            InkWell(
                                              child: Image.asset(
                                                "images/down.png",
                                                width: 12,
                                              ),
                                            )
                                          ],
                                        )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Repeat",
                                        style: TextStyle(
                                          fontFamily: 'Barlow',
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      InkWell(
                                        onTap: repeatgoal,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "images/calender.png",
                                              width: 24,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "Monthly on 23rd",
                                              style: TextStyle(
                                                  fontFamily: 'Barlow',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            InkWell(
                                              child: Image.asset(
                                                "images/down.png",
                                                width: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: loading
                                          ? null
                                          : () async {
                                              if (goalNameController
                                                      .text.isEmpty ||
                                                  goalNameController.text ==
                                                      "" ||
                                                  goalAmountController
                                                      .text.isEmpty ||
                                                  getAmount(goalAmountController
                                                          .text) ==
                                                      "") {
                                                if ((goalNameController
                                                            .text.isEmpty ||
                                                        goalNameController
                                                                .text ==
                                                            "") &&
                                                    (goalAmountController
                                                            .text.isEmpty ||
                                                        getAmount(
                                                                goalAmountController
                                                                    .text) ==
                                                            "")) {
                                                  print("bothfalse");
                                                  setStates(() {
                                                    invalidEntryName = true;
                                                    invalidEntryAmount = true;
                                                  });
                                                }

                                                if (goalNameController
                                                        .text.isEmpty ||
                                                    goalNameController.text ==
                                                        "")
                                                  setStates(() {
                                                    invalidEntryName = true;
                                                    invalidEntryAmount = false;
                                                  });
                                                if (goalAmountController
                                                        .text.isEmpty ||
                                                    getAmount(
                                                            goalAmountController
                                                                .text) ==
                                                        "")
                                                  setStates(() {
                                                    invalidEntryAmount = true;
                                                    invalidEntryName = false;
                                                  });
                                                return;
                                              }
                                              setStates(() {
                                                loading = true;
                                                invalidEntryAmount = false;
                                                invalidEntryName = false;
                                              });
                                              var goalName;
                                              var amount;
                                              var date;
                                              var currentStatus =
                                                  goalIsActive ? 2 : 1;
                                              goalName =
                                                  goalNameController.text;
                                              amount =
                                                  goalAmountController.text;
                                              date = "1st of every month";
                                              print("currentstatus" +
                                                  currentStatus.toString());
                                              var response = await OrderAPI()
                                                  .editGoal(
                                                      context,
                                                      goalId,
                                                      goalName,
                                                      amount.replaceAll(
                                                          RegExp(
                                                              Secondarycurrency),
                                                          ''),
                                                      date,
                                                      '1',
                                                      currentStatus.toString());
                                              print(response);
                                              setStates(() {
                                                loading = false;
                                              });
                                              Navigator.pop(context);
                                              Twl.navigateTo(
                                                  context,
                                                  BottomNavigation(
                                                    actionIndex: 0,
                                                    tabIndexId: 0,
                                                  ));
                                            },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: tPrimaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: loading
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                "Confirm Changes",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Barlow',
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  var top = 0.0;

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          content: Container(
            width: 80.w,
            height: 40.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: tPrimaryColor,
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  "48.54 grams left to go!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Signika',
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Use our awesome features to get there:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Barlow',
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                GridView.count(
                  crossAxisSpacing: 18,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(2, 4, 2, 12),
                      decoration: BoxDecoration(
                          border: Border.all(color: tSecondaryColor),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Start a Goal!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Signika',
                            ),
                          ),
                          Image.asset(
                            "assets/icons/newgoal.png",
                            scale: 4,
                          ),
                          Text(
                            "Invest regularly in physical\ngold at the best market rates!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Barlow',
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                      color: tPrimaryColor,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    "Start Today",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Barlow',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(2, 4, 2, 12),
                      decoration: BoxDecoration(
                          border: Border.all(color: tSecondaryColor),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Invest!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Signika',
                            ),
                          ),
                          Image.asset(
                            Images.QUICKGOLD,
                            width: 58,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Buy Gold now at the best\nmarket rates!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Barlow',
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                      color: tPrimaryColor,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    "Buy Now",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Barlow',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ActionProvider _data = Provider.of<ActionProvider>(context);
    return myGoalDetails == null
        ? Center(
            child: Container(
              width: 10.w,
              height: 10.w,
              child: CircularProgressIndicator(
                color: tPrimaryColor,
              ),
            ),
          )
        : NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: tPrimaryColor,
                  automaticallyImplyLeading: false,
                  expandedHeight: 430,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: Size(200, 140),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border(bottom: BorderSide(color: Colors.white))),
                      child: Column(
                        children: [
                          Container(
                            height: 3.h,
                            margin: EdgeInsets.all(0),
                            color: tPrimaryColor,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  )),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Center(
                                    child: Container(
                                      width: 20.w,
                                      height: 3,
                                      decoration: BoxDecoration(
                                          color: tPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _data.changeActionIndex(0);
                                  Twl.navigateTo(
                                      context,
                                      BottomNavigation(
                                        tabIndexId: 1,
                                        actionIndex: 0,
                                      ));
                                  _data.navGoldTypeaction('1');

                                  Segment.track(
                                    eventName: 'buy_gold_button',
                                    properties: {"tapped": true},
                                  );

                                  await FirebaseAnalytics.instance.logEvent(
                                    name: "buy_gold_button",
                                    parameters: {"tapped": true},
                                  );

                                  mixpanel.track(
                                    'buy_gold_button',
                                    properties: {"tapped": true},
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 6.h,
                                      width: 6.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: tSecondaryColor)),
                                      child: Center(
                                        child: Image.asset(
                                          Images.QUICKGOLD,
                                          width: 24.sp,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Invest",
                                      style: TextStyle(
                                          fontSize:
                                              isTab(context) ? 18.sp : 10.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Barlow',
                                          color: tSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              InkWell(
                                onTap: () async {
                                  // if (verifStatus) {
                                  _showAlertDialog();
                                  // await _data.changeActionIndex(3);
                                  // Twl.navigateTo(
                                  //     context,
                                  //     BottomNavigation(
                                  //         tabIndexId: 1, actionIndex: 3));
                                  // } else {
                                  //   Twl.navigateTo(context, VeriffiPage());
                                  // }
                                  // widget.navigate(1);
                                  // Twl.navigateTo(context, DeliveryForm());

                                  Segment.track(
                                    eventName: 'delivery_button',
                                    properties: {"tapped": true},
                                  );

                                  await FirebaseAnalytics.instance.logEvent(
                                    name: "delivery_button",
                                    parameters: {"tapped": true},
                                  );

                                  mixpanel.track(
                                    "delivery_button",
                                    properties: {"tapped": true},
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 6.h,
                                      width: 6.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: tSecondaryColor)),
                                      child: Center(
                                        child: Image.asset(
                                          Images.DELIVERY,
                                          width: 24.sp,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Deliver",
                                      style: TextStyle(
                                          fontSize:
                                              isTab(context) ? 18.sp : 10.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Barlow',
                                          color: tSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              InkWell(
                                onTap: () async {
                                  show();
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 6.h,
                                      width: 6.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: tSecondaryColor)),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/icons/newgoal.png",
                                          scale: 4,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "New Goal",
                                      style: TextStyle(
                                          fontSize:
                                              isTab(context) ? 18.sp : 10.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Barlow',
                                          color: tSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              InkWell(
                                onTap: () async {
                                  print("asdcsa");
                                  SharedPreferences sharedPreferences =
                                      await SharedPreferences.getInstance();
                                  var userId =
                                      sharedPreferences.getString('userId');
                                  var userName = sharedPreferences.getString(
                                        'firstName',
                                      )! +
                                      ' ' +
                                      sharedPreferences.getString(
                                        'lastName',
                                      )!;
                                  var phoneNumber =
                                      sharedPreferences.getString('username');
                                  var email =
                                      sharedPreferences.getString('email');
                                  // print(userName);
                                  print(phoneNumber);
                                  print(email);
                                  await Intercom.instance
                                      .loginIdentifiedUser(userId: userId);
                                  await Intercom.instance.updateUser(
                                      name: userName,
                                      phone: phoneNumber,
                                      email: email);
                                  await Intercom.instance.displayMessenger();
                                  // Twl.navigateTo(context, Sorry());

                                  Segment.track(
                                    eventName: 'help_button',
                                    properties: {"tapped": true},
                                  );

                                  await FirebaseAnalytics.instance.logEvent(
                                    name: "help_button",
                                    parameters: {"tapped": true},
                                  );

                                  mixpanel.track(
                                    "help_button",
                                    properties: {"tapped": true},
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 6.h,
                                      width: 6.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: tSecondaryColor)),
                                      child: Center(
                                        child: Image.asset(
                                          'images/question.png',
                                          width: 16.sp,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Help",
                                      style: TextStyle(
                                          fontSize:
                                              isTab(context) ? 18.sp : 10.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Barlow',
                                          color: tSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Center(
                            child: Container(
                              height: 5.h,
                              width: 70.w,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Color(0xffF3F4F6)),
                              child: TabBar(
                                indicatorWeight: 0,
                                indicatorPadding: EdgeInsets.all(0),
                                // dividerColor: Colors.black,
                                // isScrollable: true,
                                controller: _tabController,
                                labelColor: tSecondaryColor,
                                unselectedLabelColor: tSecondaryColor,
                                labelStyle: TextStyle(
                                    fontSize: isTab(context) ? 18.sp : 14.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Barlow',
                                    color: tSecondaryColor),
                                // labelPadding:
                                //     EdgeInsets.symmetric(horizontal: 18),
                                indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24)),
                                tabs: [
                                  Tab(text: 'Transactions'),
                                  Tab(
                                    text: 'Orders',
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    top = constraints.biggest.height;
                    return FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.white,
                              height: 48,
                            ),
                            Container(
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Hi ${firstname?[0].toUpperCase() ?? ''}${firstname?.substring(1) ?? ''}👋",
                                        style: TextStyle(
                                            fontFamily: 'Barlow',
                                            fontSize: 28,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Twl.navigateTo(context, ProfilePage());
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: tPrimaryColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                          (firstname != null &&
                                                  lastName != null)
                                              ? (firstname[0].toUpperCase() ??
                                                      '') +
                                                  (lastName[0].toUpperCase() ??
                                                      '')
                                              : '',
                                          style: TextStyle(
                                              color: tSecondaryColor,
                                              fontFamily: 'Barlow',
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              height: 8,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 3.w, top: 6.h),
                              color: tPrimaryColor,
                              child: Row(
                                children: [
                                  ArgonButton(
                                    highlightElevation: 0,
                                    elevation: 0,
                                    width: 145,
                                    height: 145,
                                    borderRadius: 15,
                                    color: tContainerColor,
                                    child: Goldcontainer(
                                      // selectedvalue == 1 ? btnColor : tContainerColor,
                                      goldGrams: _data.phyGoldDispalyType == 1
                                          ? '${totalGold}g'
                                          : (Secondarycurrency +
                                              phyGoldValue.toStringAsFixed(2)),
                                      // goldGrams: '£5,300.72',
                                      imagess: Images.GOLD,
                                      title: "Physical Gold",
                                      ontap: () async {
                                        goldDisplaySheet(
                                            context,
                                            _data,
                                            phyGoldValue,
                                            totalGold,
                                            Images.GOLD,
                                            1);

                                        Segment.track(
                                          eventName: 'physical_gold_button',
                                          properties: {"tapped": true},
                                        );

                                        mixpanel.track(
                                          'physical_gold_button',
                                          properties: {"tapped": true},
                                        );

                                        await FirebaseAnalytics.instance
                                            .logEvent(
                                          name: "physical_gold_button",
                                          parameters: {"tapped": true},
                                        );
                                      },
                                    ),
                                    loader: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Lottie.asset(
                                          Loading.LOADING,
                                          // width: 50.w,
                                        )
                                        // SpinKitRotatingCircle(
                                        //   color: Colors.white,
                                        //   // size: loaderWidth ,
                                        // ),
                                        ),
                                    onTap:
                                        (tartLoading, stopLoading, btnState) {
                                      // Twl.navigateTo(
                                      //   context,
                                      //   BottomNavigation(
                                      //     tabIndexId: 0,
                                      //     actionIndex: 0,
                                      //     homeindex: 1,
                                      //   ),
                                      // );
                                    },
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  // if (myGoalDetails != null)
                                  if (myGoalDetails['status'] == 'NOK')
                                    ArgonButton(
                                      elevation: 0,
                                      highlightElevation: 0,
                                      height: 145,
                                      width: 145,
                                      borderRadius: 10,
                                      color: tContainerColor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 12,
                                            bottom: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Container(
                                                // height: 5.h,
                                                // height: 38,
                                                child: Image.asset(
                                                    "assets/icons/newgoal.png",
                                                    width: 35
                                                    // scale: 3,
                                                    ),
                                              ),
                                              Container(width: 5),
                                              Text(
                                                "Goals!",
                                                style: TextStyle(
                                                  color: tBlue,
                                                  fontFamily: 'Barlow',
                                                  fontSize: isTab(context)
                                                      ? 13.sp
                                                      : 24,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ]),
                                            Container(height: 2),
                                            Text(
                                              "Invest regularly in\nphysical gold at the\nbest market rates!",
                                              style: TextStyle(
                                                color: tBlue,
                                                fontFamily: 'Barlow',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Container(height: 10),
                                            Container(
                                                height: 30,
                                                child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      primary: _getColorFromHex(
                                                          "#E5B02C"),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                    ),
                                                    onPressed: () async {
                                                      // if (verifStatus) {

                                                      // } else {
                                                      //   Twl.navigateTo(
                                                      //       context, VeriffiPage());
                                                      // }
                                                      // Twl.navigateTo(context, NameYourGoal());

                                                      /*   Twl.navigateTo(context,
                                                          GoalAmount());*/

                                                      show();

                                                      Segment.track(
                                                        eventName:
                                                            'start_a_goal_button',
                                                        properties: {
                                                          "tapped": true
                                                        },
                                                      );

                                                      mixpanel.track(
                                                        'start_a_goal_button',
                                                        properties: {
                                                          "tapped": true
                                                        },
                                                      );

                                                      await FirebaseAnalytics
                                                          .instance
                                                          .logEvent(
                                                        name:
                                                            "start_a_goal_button",
                                                        parameters: {
                                                          "tapped": true
                                                        },
                                                      );
                                                    },
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text("Start Today",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Barlow",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      13)),
                                                          Icon(Icons
                                                              .keyboard_arrow_right)
                                                        ])))
                                          ],
                                        ),
                                      ),
                                      loader: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Lottie.asset(
                                            Loading.LOADING,
                                            // width: 50.w,
                                          )
                                          // SpinKitRotatingCircle(
                                          //   color: Colors.white,
                                          //   // size: loaderWidth ,
                                          // ),
                                          ),
                                      onTap:
                                          (tartLoading, stopLoading, btnState) {
                                        Twl.navigateTo(context, GoalAmount());
                                      },
                                    ),
                                  // if (myGoalDetails != null)
                                  if (myGoalDetails['status'] == 'OK')
                                    ArgonButton(
                                      highlightElevation: 0,
                                      elevation: 0,
                                      height: 145,
                                      width: 145,
                                      borderRadius: 10,
                                      color: tContainerColor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 13),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Image.asset(
                                                  "assets/icons/newgoal.png",
                                                  width: 35),
                                            ),
                                            SizedBox(
                                              height: 24,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _data.goalDispalyType == 1
                                                      ? avalibleGoalGold
                                                              .toStringAsFixed(
                                                                  3) +
                                                          'g'
                                                      : '£${(goalTotalValue ?? 0).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      color: tBlue,
                                                      fontFamily: 'Barlow',
                                                      fontSize: isTab(context)
                                                          ? 13.sp
                                                          : 24,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    goldDisplaySheet(
                                                      context,
                                                      _data,
                                                      goalTotalValue,
                                                      avalibleGoalGold ?? 0,
                                                      Images.GOLD,
                                                      2,
                                                    );
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                tSecondaryColor)),
                                                    child: Image.asset(
                                                      'images/down.png',
                                                      height: 8,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Text(
                                              myGoalDetails['details']
                                                          ['name_of_goal'] ==
                                                      ''
                                                  ? "My Goal"
                                                  : myGoalDetails['details']
                                                      ['name_of_goal'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: tBlue,
                                                  fontFamily: 'Barlow',
                                                  fontSize: isTab(context)
                                                      ? 11.sp
                                                      : 15,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      loader: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Lottie.asset(
                                            Loading.LOADING,
                                            // width: 50.w,
                                          )
                                          // SpinKitRotatingCircle(
                                          //   color: Colors.white,
                                          //   // size: loaderWidth ,
                                          // ),
                                          ),
                                      onTap:
                                          (tartLoading, stopLoading, btnState) {
                                        // Twl.navigateTo(
                                        //   context,
                                        //   BottomNavigation(
                                        //     tabIndexId: 0,
                                        //     actionIndex: 0,
                                        //     homeindex: 2,
                                        //   ),
                                        // );
                                      },
                                    ),
                                ],
                              ),
                            ),

                            // Center(
                            //   child: Container(
                            //     height: 5.h,
                            //     width: 70.w,
                            //     padding: EdgeInsets.all(4),
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(24),
                            //         color: Color(0xffF3F4F6)),
                            //     child: TabBar(
                            //       controller: _tabController,
                            //       labelColor: tSecondaryColor,
                            //       unselectedLabelColor: tSecondaryColor,
                            //       labelStyle: TextStyle(
                            //           fontSize: isTab(context) ? 18.sp : 14.sp,
                            //           fontWeight: FontWeight.w500,
                            //           fontFamily: 'Barlow',
                            //           color: tSecondaryColor),
                            //       indicator: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(24)),
                            //       tabs: [
                            //         Tab(text: 'Transactions'),
                            //         Tab(
                            //           text: 'Orders',
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // Expanded(
                            //   child: Container(
                            //       child: TabBarView(controller: _tabController, children: [
                            //     Column(
                            //       children: [
                            //         for (int i = 0; i < 15; i++)
                            //           Text(
                            //             "tab1",
                            //             style: TextStyle(
                            //                 fontSize: 30.sp,
                            //                 fontWeight: FontWeight.w500,
                            //                 fontFamily: 'Barlow',
                            //                 color: tSecondaryColor),
                            //           ),
                            //       ],
                            //     ),
                            //     Text("tab2")
                            //   ])),
                            // )
                            // Container(
                            //   color: Colors.white,
                            //   child: Text(
                            //     "Quick access",
                            //     style: TextStyle(
                            //         fontSize: isTab(context) ? 18.sp : 21.sp,
                            //         fontWeight: FontWeight.w500,
                            //         fontFamily: 'Signika',
                            //         color: tSecondaryColor),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 4.h,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     MenuContainerWidget(
                            //       tittle: "Buy Gold",
                            //       image: Images.QUICKGOLD,
                            //       onTap: (tartLoading, stopLoading, btnState) async {
                            //         await _data.changeActionIndex(0);
                            //         Twl.navigateTo(
                            //             context,
                            //             BottomNavigation(
                            //               tabIndexId: 1,
                            //               actionIndex: 0,
                            //             ));
                            //         _data.navGoldTypeaction('1');

                            //         Segment.track(
                            //           eventName: 'buy_gold_button',
                            //           properties: {"tapped": true},
                            //         );

                            //         await FirebaseAnalytics.instance.logEvent(
                            //           name: "buy_gold_button",
                            //           parameters: {"tapped": true},
                            //         );

                            //         mixpanel.track(
                            //           'buy_gold_button',
                            //           properties: {"tapped": true},
                            //         );
                            //       },
                            //     ),
                            //     MenuContainerWidget(
                            //       tittle: "Sell Gold",
                            //       image: Images.SELLGOLD,
                            //       onTap: (tartLoading, stopLoading, btnState) async {
                            //         await _data.changeActionIndex(1);
                            //         Twl.navigateTo(context,
                            //             BottomNavigation(tabIndexId: 1, actionIndex: 0));

                            //         Segment.track(
                            //           eventName: 'sell_gold_button',
                            //           properties: {"tapped": true},
                            //         );

                            //         await FirebaseAnalytics.instance.logEvent(
                            //           name: "sell_gold_button",
                            //           parameters: {"tapped": true},
                            //         );

                            //         mixpanel.track(
                            //           "sell_gold_button",
                            //           properties: {"tapped": true},
                            //         );
                            //       },
                            //     ),
                            //     MenuContainerWidget(
                            //       tittle: "Move",
                            //       image: Images.MOVE,
                            //       onTap: (tartLoading, stopLoading, btnState) async {
                            //         // await _data.changeActionIndex(2);
                            //         // print('_data.initialIndex');
                            //         // print(initialIndex);
                            //         // if (verifStatus) {
                            //         Twl.navigateTo(context,
                            //             BottomNavigation(tabIndexId: 1, actionIndex: 2));
                            //         _data.navGoldTypeaction('1');
                            //         // } else {
                            //         //   Twl.navigateTo(context, VeriffiPage());
                            //         // }
                            //         // widget.navigate(1);

                            //         Segment.track(
                            //           eventName: 'move_button',
                            //           properties: {"tapped": true},
                            //         );

                            //         await FirebaseAnalytics.instance.logEvent(
                            //           name: "move_button",
                            //           parameters: {"tapped": true},
                            //         );

                            //         mixpanel.track(
                            //           "move_button",
                            //           properties: {"tapped": true},
                            //         );
                            //       },
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 4.h,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     MenuContainerWidget(
                            //       tittle: "Delivery",
                            //       image: Images.DELIVERY,
                            //       onTap: (tartLoading, stopLoading, btnState) async {
                            //         // if (verifStatus) {
                            //         await _data.changeActionIndex(3);
                            //         Twl.navigateTo(context,
                            //             BottomNavigation(tabIndexId: 1, actionIndex: 3));
                            //         // } else {
                            //         //   Twl.navigateTo(context, VeriffiPage());
                            //         // }
                            //         // widget.navigate(1);
                            //         // Twl.navigateTo(context, DeliveryForm());

                            //         Segment.track(
                            //           eventName: 'delivery_button',
                            //           properties: {"tapped": true},
                            //         );

                            //         await FirebaseAnalytics.instance.logEvent(
                            //           name: "delivery_button",
                            //           parameters: {"tapped": true},
                            //         );

                            //         mixpanel.track(
                            //           "delivery_button",
                            //           properties: {"tapped": true},
                            //         );
                            //       },
                            //     ),
                            //     MenuContainerWidget(
                            //       tittle: "Help",
                            //       image: Images.HELPHOME,
                            //       onTap: (tartLoading, stopLoading, btnState) async {
                            //         print("asdcsa");
                            //         SharedPreferences sharedPreferences =
                            //             await SharedPreferences.getInstance();
                            //         var userId = sharedPreferences.getString('userId');
                            //         var userName = sharedPreferences.getString(
                            //               'firstName',
                            //             )! +
                            //             ' ' +
                            //             sharedPreferences.getString(
                            //               'lastName',
                            //             )!;
                            //         var phoneNumber =
                            //             sharedPreferences.getString('username');
                            //         var email = sharedPreferences.getString('email');
                            //         // print(userName);
                            //         print(phoneNumber);
                            //         print(email);
                            //         await Intercom.instance
                            //             .loginIdentifiedUser(userId: userId);
                            //         await Intercom.instance.updateUser(
                            //             name: userName, phone: phoneNumber, email: email);
                            //         await Intercom.instance.displayMessenger();
                            //         // Twl.navigateTo(context, Sorry());

                            //         Segment.track(
                            //           eventName: 'help_button',
                            //           properties: {"tapped": true},
                            //         );

                            //         await FirebaseAnalytics.instance.logEvent(
                            //           name: "help_button",
                            //           parameters: {"tapped": true},
                            //         );

                            //         mixpanel.track(
                            //           "help_button",
                            //           properties: {"tapped": true},
                            //         );
                            //       },
                            //     ),
                            //     MenuContainerWidget(
                            //       tittle: "New Goal",
                            //       image: Images.NEWGOAL,
                            //       onTap: (tartLoading, stopLoading, btnState) async {
                            //         // if (verifStatus) {
                            //         if (myGoalDetails['status'] == 'NOK') {
                            //           Twl.navigateTo(context, GoalAmount());
                            //         } else if (myGoalDetails['status'] == 'OK') {
                            //           Twl.navigateTo(context, Sorry());
                            //         }
                            //         // } else {
                            //         //   Twl.navigateTo(context, VeriffiPage());
                            //         // }

                            //         Segment.track(
                            //           eventName: 'new_goal_button',
                            //           properties: {"tapped": true},
                            //         );

                            //         await FirebaseAnalytics.instance.logEvent(
                            //           name: "new_goal_button",
                            //           parameters: {"tapped": true},
                            //         );

                            //         mixpanel.track(
                            //           "new_goal_button",
                            //           properties: {"tapped": true},
                            //         );
                            //       },
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    );
                  }),
                )
              ];
            },
            body: TabBarView(controller: _tabController, children: [
              FutureBuilder<MyOrderDetialsModel>(
                  future: MyOrderDetials,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("ERROR" + snapshot.error.toString());
                      // return Text(snapshot.error.toString());
                    }
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          child: CircularProgressIndicator(
                            color: tPrimaryColor,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      var orderdetails = snapshot.data!.details;
                      // var details = orderdetails[0];
                      return Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 1.h,
                            ),
                            for (int i = 0; i < orderdetails.length; i++)
                              (orderdetails[i].typeId != 3)
                                  ? Column(
                                      children: [
                                        BuyContainerWidget(
                                          tittle: getTypeOfActivity(
                                              orderdetails[i].typeId),
                                          // == Buy
                                          //  ? "Buy" :details.typeId == Move? 'Move': "Sell",
                                          date: Twl.dateFormate(
                                              orderdetails[i].createdOn),
                                          goldgrams:
                                              "${(double.parse(orderdetails[i].quantity.replaceAll('g', '') == '' ? '0' : orderdetails[i].quantity.replaceAll('g', ''))).toStringAsFixed(3)} Grams",

                                          cost: (orderdetails[i].typeId == 1 ||
                                                  orderdetails[i].typeId == 2)
                                              ? "£${orderdetails[i].totalWTax != null ? (orderdetails[i].totalWTax).toStringAsFixed(2) : ''}"
                                              : null,
                                          des: (orderdetails[i].typeId == 3 ||
                                                  orderdetails[i].typeId == 4)
                                              ? (orderdetails[i].moveDesc ?? '')
                                              : '',
                                          // : getDeliveryStatus(details.deliveryStatus ?? '1'),
                                        ),
                                        SizedBox(
                                          height: 2.h,
                                        ),
                                      ],
                                    )
                                  : Container(),
                          ],
                        ),
                      );
                    }
                    return Container();
                  }),
              if (myGoalDetails['status'] == 'OK')
                Column(
                  children: [
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                      margin: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: tPrimaryColor),
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  "assets/icons/newgoal.png",
                                  scale: 4,
                                )),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '£${myGoalDetails['details']['goal_amount']}',
                                  style: TextStyle(
                                      color: tSecondaryColor,
                                      fontFamily: 'Barlow',
                                      fontSize: isTab(context) ? 9.sp : 12.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  myGoalDetails['details']['payment_date'],
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
                                InkWell(
                              onTap: () {
                                editgoal();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 14),
                                    decoration: BoxDecoration(
                                        color: grayColor,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      "Edit Goal",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTab(context) ? 9.sp : 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
            ])
            // body: Container(
            //   color: Colors.white,
            //   child: Column(
            //     children: [],
            //   ),
            // )
            );
  }
}

goldDisplaySheet(context, _data, amount, gram, image, type) {
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    )),
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (BuildContext context,
          StateSetter setState /*You can rename this!*/) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    height: 10,
                    width: 30.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: tPrimaryColor3,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    if (type == 1) {
                      _data.phyGoldAction(2);
                    } else {
                      _data.goalGoldAction(2);
                    }

                    // setState(() {
                    //   phyGoldType = 2;
                    // });
                    // print('phyGoldType' +
                    //     phyGoldType.toString());
                    Twl.navigateBack(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: tTextformfieldColor,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Image.asset(
                            Images.SELLGOLD,
                            scale: 4.5,
                            // height: 20,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'View in GBP',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Barlow',
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),
                        Spacer(),
                        Text(
                          Secondarycurrency + (amount ?? 0).toStringAsFixed(2),
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    if (type == 1) {
                      _data.phyGoldAction(1);
                    } else {
                      _data.goalGoldAction(1);
                    }

                    Twl.navigateBack(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: tTextformfieldColor,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          image,
                          height: 20,
                        ),
                        SizedBox(width: 15),
                        Text(
                          'View in Grams',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Barlow',
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${double.parse(gram.toString()).toStringAsFixed(3)}g',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: isTab(context) ? 10.sp : 12.sp,
                            color: tSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 70),
              ],
            ),
          ),
        );
      });
    },
  );
}

// checkVeriffStatus(context) async {
//   SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
//   var authCode = sharedPrefs.getString('authCode');
//   var checkApi = await UserAPI().checkApi(authCode);
//   print(checkApi);
//   if (checkApi != null && checkApi['status'] == 'OK') {
//     return checkApi['detail']['veriff_status'];
//   } else {
//     // return Twl.createAlert(context, 'error', checkApi['error']);
//   }
// }

_getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
