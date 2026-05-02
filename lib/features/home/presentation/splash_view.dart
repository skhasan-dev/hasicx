import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/core/index.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: MediaQuery.sizeOf(context).width * 0.6,
              width: MediaQuery.sizeOf(context).width * 0.6,
            ),
            Text(
              "HasicX",
              style: AppTextStyles.s60W600.copyWith(letterSpacing: 2.5),
            ),
            Text(
              "Where Music Sparks Vibes",
              style: AppTextStyles.s13W100.copyWith(letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkPermission() async {
    var perms = await Permission.storage.request();
    var perms2 = await Permission.audio.request();

    if (!perms.isGranted && !perms2.isGranted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Permission Required", style: AppTextStyles.s18W400),
          content: Text(
            "Permission is needed to access audios and songs.",
            style: AppTextStyles.s14W400,
          ),
          backgroundColor: AppColors.deepTabColor,
          actions: [
            OutlinedButton(
              onPressed: () {
                exit(0);
              },
              child: Text("Cancel", style: AppTextStyles.s12W400),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
                await checkPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tabColor,
              ),
              child: Text("Open App Settings", style: AppTextStyles.s12W400),
            ),
          ],
        ),
      );
    } else {
      Timer(Duration(seconds: 3), () {
        context.pushReplacementNamed(RouteNames.home);
      });
    }
  }
}
