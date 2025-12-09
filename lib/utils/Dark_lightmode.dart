// ignore_for_file: file_names, prefer_const_constructors
import 'package:carlinknew/utils/Colors.dart';
import 'package:flutter/material.dart';

class ColorNotifire with ChangeNotifier {
  bool isDark = false;
  set setIsDark(value) {
    isDark = value;
    notifyListeners();
  }

  bool get getIsDark => isDark;
  Color get getbgcolor => isDark ? darkmode : bgcolor; //background color
  Color get getboxcolor => isDark ? boxcolor : WhiteColor; //containar color
  Color get getlightblackcolor => isDark ? boxcolor : lightBlack;
  Color get getwhiteblackcolor => isDark ? WhiteColor : BlackColor; //text defultsystemicon imageicon color
  Color get getgreycolor => isDark ? greyColor : greyColor;
  Color get getwhitebluecolor => isDark ? WhiteColor : Darkblue;
  Color get getblackgreycolor => isDark ? lightBlack2 : greyColor;
  Color get getcardcolor => isDark ? darkmode : WhiteColor;
  Color get getgreywhite => isDark ? WhiteColor : greyColor;
  Color get getredcolor => isDark ? RedColor : RedColor2;
  Color get getprocolor => isDark ? yelloColor : yelloColor2;
  Color get getblackwhitecolor => isDark ? bmode : WhiteColor;
  Color get getlightblack => isDark ? lightBlack2 : lightBlack2;
  Color get getbuttonscolor => isDark ? lightgrey : lightgrey2;
  Color get getbuttoncolor => isDark ? greyColor : onoffColor;
  Color get getdarkbluecolor => isDark ? Darkblue : Darkblue;
  Color get getdarkscolor => isDark ? BlackColor : bgcolor;
  Color get getdarkwhitecolor => isDark ? WhiteColor : WhiteColor;
  Color get getblackblue => isDark ? blueColor : BlackColor;

  Color get getfevAndSearch => isDark ? darkmode : fevAndSearchColor;
  Color get getlightblackwhite => isDark ? BlackColor : fevAndSearchColor;

  Color get getborderColor => isDark ? Color(0xFF1B2537) : grey50;
  Color get getgreyscale => isDark ? Color(0xFF94A3B8) : Color(0xFF1B2537);
  Color get getsetting => isDark ? Color(0xff1B2537) : Color(0xffF8FAFC);

  Color get getCarColor => isDark ? Color(0xffF9F9F9).withOpacity(0.08) : Color(0xffF9F9F9);
  Color get getBottom => isDark ? Color(0xffF9F9F9).withOpacity(0.08) : bottomColor;
  Color get getBottom1 => isDark ? Colors.black : bottomColor;
}
