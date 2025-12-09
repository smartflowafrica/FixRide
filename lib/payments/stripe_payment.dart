// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:carlinknew/payments/paymentcard.dart';
import 'package:carlinknew/utils/Custom_widget.dart';
import 'package:carlinknew/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';




class StripePaymentWeb extends StatefulWidget {
  final PaymentCardCreated paymentCard;

  const StripePaymentWeb({Key? key, required this.paymentCard})
      : super(key: key);

  @override
  State<StripePaymentWeb> createState() => _StripePaymentWebState();
}

class _StripePaymentWebState extends State<StripePaymentWeb> {
  late WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PaymentCardCreated? payCard;
  var progress;

  @override
  void initState() {
    super.initState();
    setState(() {});
    payCard = widget.paymentCard;
        final params = PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.grey.shade200)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            debugPrint("************ URL *****:--- $initialUrl");
            debugPrint("************ Navigating to URL: ${request.url}");
            debugPrint("************ Parsed URI: $uri");
            debugPrint("************ 2435243254: ${uri.queryParameters["status"]}");
            debugPrint("************ queryParamiter: ${uri.queryParametersAll}");
            debugPrint("************ queryParamiter url: ${uri.queryParameters["Transaction_id"]}");

            // Check the status parameter instead of Result
            final status = uri.queryParameters["status"];
            debugPrint(" /*/*/*/*/*/*/*/*/*/*/*/*/*/ Status ---- $status");
            if (status == null) {
              debugPrint("No status parameter found.");
            } else {
              debugPrint("Status parameter: $status");
              if (status == "success") {
                debugPrint("Purchase successful.");
                Get.back(result: uri.queryParameters["Transaction_id"]);
                return NavigationDecision.prevent;
              } else {
                debugPrint("Purchase failed with status: $status.");
                Navigator.pop(context);
                showToastMessage(status);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            debugPrint("============== url =========== $url");
          },
          onProgress: (int value) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(initialUrl));
      debugPrint("============== initial =========== $initialUrl");

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  String get initialUrl => '${Config.pGateway}stripe/index.php?name=${payCard!.name}&email=${payCard!.email}&cardno=${payCard!.number}&cvc=${payCard!.cvv}&amt=${payCard!.amount}&mm=${payCard!.month}&yyyy=${payCard!.year}';

  @override
  Widget build(BuildContext context) {
    if (_scaffoldKey.currentState == null) {
      return PopScope(
        // onWillPop: (() async => true),
        canPop: true,
        onPopInvoked: (didPop) {
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Get.height * 0.02),
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Please don`t press back until the transaction is complete'.tr,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.01),
                Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    Container(
                      color: Colors.grey.shade200,
                      height: 25,
                      child: WebViewWidget(controller: _controller),
                    ),
                    Container(height: 25, color: Colors.white, width: Get.width),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back()),
            backgroundColor: Colors.black12,
            elevation: 0.0),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
  
  // void readJS() async {
  //   setState(() {
  //     _controller
  //         .evaluateJavascript("document.documentElement.innerText")
  //         .then((value) async {
  //       if (value.contains("Transaction_id")) {
  //         String fixed = value.replaceAll(r"\'", "");
  //         if (GetPlatform.isAndroid) {
  //           String json = jsonDecode(fixed);
  //           var val = jsonStringToMap(json);
  //           if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
  //             Get.back(result: val["Transaction_id"]);
  //             Fluttertoast.showToast(msg: val["ResponseMsg"],timeInSecForIosWeb: 4);
  //           } else {
  //             Fluttertoast.showToast(msg: val["ResponseMsg"],timeInSecForIosWeb: 4);
  //             Get.back();
  //           }
  //         } else {
  //           var val = jsonStringToMap(fixed);
  //           if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
  //             Get.back(result: val["Transaction_id"]);
  //             Fluttertoast.showToast(msg: val["ResponseMsg"],timeInSecForIosWeb: 4);
  //           } else {
  //             Fluttertoast.showToast(msg: val["ResponseMsg"],timeInSecForIosWeb: 4);
  //             Get.back();
  //           }
  //         }
  //       }
  //       return "";
  //     });
  //   });
  // }

  void readJS() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        "document.documentElement.innerText",
      );
  
      if (result is String && result.contains("Transaction_id")) {
        String fixed = result.replaceAll(r"\'", "");
  
        // Platform specific decoding
        Map<String, dynamic> val;
        if (GetPlatform.isAndroid) {
          String json = jsonDecode(fixed);
          val = jsonStringToMap(json);
        } else {
          val = jsonStringToMap(fixed);
        }
  
        // Handling result
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          Get.back(result: val["Transaction_id"]);
          Fluttertoast.showToast(
            msg: val["ResponseMsg"],
            timeInSecForIosWeb: 4,
          );
        } else {
          Fluttertoast.showToast(
            msg: val["ResponseMsg"],
            timeInSecForIosWeb: 4,
          );
          Get.back();
        }
      }
    } catch (e) {
      print("JavaScript evaluation error: $e");
    }
  }

  Map<String, dynamic> jsonStringToMap(String data) {
    List<String> str = data
        .replaceAll("{", "")
        .replaceAll("}", "")
        .replaceAll("\"", "")
        .replaceAll("'", "")
        .split(",");
    Map<String, dynamic> result = {};
    for (int i = 0; i < str.length; i++) {
      List<String> s = str[i].split(":");
      result.putIfAbsent(s[0].trim(), () => s[1].trim());
    }
    return result;
  }
}
