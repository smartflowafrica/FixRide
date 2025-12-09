import 'package:carlinknew/utils/Custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:async';
import '../utils/config.dart';

class Flutterwave extends StatefulWidget {
  final String? name;
  final String? email;
  final String? totalAmount;
  const Flutterwave({super.key, this.name, this.email, this.totalAmount});

  @override
  State<Flutterwave> createState() => _FlutterwaveState();
}

class _FlutterwaveState extends State<Flutterwave> {
  final GlobalKey<ScaffoldState> _globalKey=GlobalKey();
  late WebViewController webViewController;
  var progress;
  String? accessToken;
  String? payerID;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final params = PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            if (uri.queryParameters["status"] == null) {
              accessToken = uri.queryParameters["token"];
            } else {
              if (uri.queryParameters["status"] == "successful") {
                payerID = uri.queryParameters["transaction_id"];
                Get.back(result: payerID);
              } else {
                Get.back();
                showToastMessage("${uri.queryParameters["status"]}");
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onProgress: (int progressValue) {
            setState(() {
              progress = progressValue / 100;
            });
          },
        ),
      )
      
      ..loadRequest(Uri.parse("${Config.pGateway}flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}"));
      

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (_globalKey.currentState == null) {
      print("Flutterwave ++++++++++++++++++++++----${"${Config.pGateway}flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}"}");
      return WillPopScope (
        onWillPop: () {
          return Future(() => true);
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                WebViewWidget(controller: webViewController),
                isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: Get.height * 0.02),
                      SizedBox(
                        width: Get.width * 0.80,
                        child: Text(
                          'Please don`t press back until the transaction is complete'
                              .tr,
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
                )
                    : const Stack(),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _globalKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
