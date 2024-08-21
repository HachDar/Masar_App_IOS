import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dalel/Categories/aChcity.dart';
import 'package:dalel/auth/authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController email;
  late TextEditingController password;

  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Google sign-in failed");
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'خطأ',
          desc: 'فشل تسجيل الدخول عبر Google. الرجاء المحاولة مرة أخرى.',
          btnOkOnPress: () {},
        ).show();
        return Future.error("Google sign-in failed");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error during Google sign-in: $e");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'خطأ',
        desc:
            'Google حدث خطأ غير متوقع أثناء تسجيل الدخول الرجاء المحاولة مرة أخرى',
        btnOkOnPress: () {},
      ).show();
      return Future.error(e);
    }
  }

  Future<void> _signIn() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'خطأ',
        desc: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      print("Login successful: ${credential.user?.email}");

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        Navigator.of(context).pop();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'خطأ',
          desc: 'يرجى تفعيل البريد الإلكتروني قبل تسجيل الدخول.',
          btnOkOnPress: () {},
        ).show();
        return;
      }

      Navigator.of(context).pop();
      Get.offAll(const CityPage());
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      String message;
      if (e.code == 'user-not-found') {
        message = 'لا يوجد مستخدم لهذا البريد الإلكتروني.';
        print('Error: user-not-found');
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور خاطئة.';
        print('Error: wrong-password');
      } else {
        message = 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.';
        print('Error: ${e.code}');
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'خطأ',
        desc: message,
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      Navigator.of(context).pop();
      print("Error during sign in: $e");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'خطأ',
        desc: 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Get.offAll(const AuthPage()),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: Image.asset(
                      "images/Black and Orange Initials Letter R Broadcast Media Logo.png"),
                ),
                SizedBox(height: 20.h),
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontFamily: "Boutros",
                    fontSize: 24.sp,
                  ),
                ),
                SizedBox(height: 40.h),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'البريد الالكتروني',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: password,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _toggleVisibility,
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: 300.w,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 24.w),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: "Boutros",
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                const Text(
                  'تسجيل باستخدام',
                  style: TextStyle(
                    fontFamily: "Boutros",
                  ),
                ),
                SizedBox(height: 10.h),
                InkWell(
                  onTap: () async {
                    await signInWithGoogle();
                    Get.offAll(const CityPage());
                  },
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Image.asset("images/google-symbol.png"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
