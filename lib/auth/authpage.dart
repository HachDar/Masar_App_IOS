import 'package:dalel/auth/login.dart';
import 'package:dalel/auth/singin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SvgPicture.asset(
                "assets/background.svg",
                width: Get.width,
                height: Get.height,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: SvgPicture.asset(
                      "assets/Black and Orange Initials Letter R Broadcast Media Logo.svg",
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 120, left: 30, right: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    button(
                      "تسجيل الدخول",
                      () {
                        Get.to(const Login());
                      },
                    ),
                    const SizedBox(height: 30),
                    button(
                      "انشاء الحساب",
                      () {
                        Get.to(const Register());
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget button(String text, void Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          height: 65,
          width: Get.width,
          child: ColoredBox(
            color: Colors.white,
            child: Center(
              child: Text(
                text.toUpperCase(),
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
