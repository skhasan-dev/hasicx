import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/core/index.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _isHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPermission();
    });
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
    if (_isHandled) return;

    var storage = await Permission.storage.request();
    var audio = await Permission.audio.request();

    if (!mounted) return;

    if (!storage.isGranted && !audio.isGranted) {
      _isHandled = true;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Permission Required", style: AppTextStyles.s18W400),
          content: Text(
            "Access to audio files is required to display your music library.",
            style: AppTextStyles.s14W400,
          ),
          backgroundColor: AppColors.deepTabColor,
          actions: [
            OutlinedButton(
              onPressed: () => exit(0),
              child: Text("Exit", style: AppTextStyles.s12W400),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
                _isHandled = false; // allow retry
                if (mounted) checkPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tabColor,
              ),
              child: Text("Open Settings", style: AppTextStyles.s12W400),
            ),
          ],
        ),
      );
    } else {
      _isHandled = true;

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      await context.read<MusicPlayerProvider>().getSongs();

      if (!mounted) return;

      context.pushReplacementNamed(RouteNames.home);
    }
  }
}
