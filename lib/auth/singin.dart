import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dalel/Categories/aChcity.dart';
import 'package:dalel/auth/authpage.dart';
import 'package:dalel/auth/login.dart';
import 'package:dalel/extensions/button.dart';
import 'package:dalel/extensions/textformfild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Check for error in login result
      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);
        Get.offAll(const CityPage());
        // Once signed in, return the UserCredential
        return await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
      } else {
        print('Facebook login failed: ${loginResult.status}');
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
          message: loginResult.message,
        );
      }
    } catch (e) {
      print('Error during Facebook login: $e');
      throw FirebaseAuthException(
        code: 'ERROR_FACEBOOK_LOGIN_FAILED',
        message: e.toString(),
      );
    }
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

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth == null) {
        print("Google authentication failed");
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'خطأ',
          desc: 'فشل التحقق من Google. الرجاء المحاولة مرة أخرى.',
          btnOkOnPress: () {},
        ).show();
        return Future.error("Google authentication failed");
      }

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
            'حدث خطأ غير متوقع أثناء تسجيل الدخول عبر Google. الرجاء المحاولة مرة أخرى.',
        btnOkOnPress: () {},
      ).show();
      return Future.error(e);
    }
  }

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

  Future<void> _register() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'خطأ',
        desc: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.',
        btnOkColor: Colors.red,
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
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      Navigator.of(context).pop();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "شكرا",
        desc:
            "نجحت عمليتك لانشائك الحساب وصلتك رسالة للايميل الرجاء تفعيله وتسجيل الدخول",
        btnOkText: "تسجيل الدخول",
        btnCancelText: "الغاء",
        btnOkOnPress: () {
          Get.off(const Login());
        },
        btnCancelOnPress: () {},
      ).show();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: "كلمة المرور ضعيفة",
          desc: 'كلمة المرور هذه ضعيفة جدا',
          btnOkOnPress: () {},
        ).show();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: "الايميل خطأ",
          desc: "الايميل مستخدم سابقاً",
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      Navigator.of(context).pop();
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "خطأ",
        desc: "هناك خطأ ما حاول مجدداً",
        btnOkOnPress: () {},
      ).show();
      print("========================================== $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مسار',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'انشاء الحساب',
                  style: TextStyle(
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
                SizedBox(height: 20.h),
                SizedBox(
                  width: 300.w,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text('انشاء الحساب'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 24.w),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                const Text('تسجيل باستخدام'),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        await signInWithFacebook();
                      },
                      child: SizedBox(
                        width: 50.w,
                        height: 50.h,
                        child: Image.asset("images\Facebook_Logo_2023.png"),
                      ),
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
