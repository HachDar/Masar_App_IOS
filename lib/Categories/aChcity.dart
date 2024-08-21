import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalel/Categories/bChprofession.dart';
import 'package:dalel/auth/authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  bool showAdImage = true;
  String adImageUrl = '';
  String adStartC = '';
  bool showCloseButton = false;

  @override
  void initState() {
    super.initState();
    _fetchAdImage();
  }

  Future<void> _fetchAdImage() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('adimages').get();

      DocumentSnapshot document = querySnapshot.docs.first; // استخدام أول مستند

      String url = document['imageUrlstartad'];
      String urlstarted = document['urlstartad'];

      setState(() {
        adImageUrl = url;
        adStartC = urlstarted;
      });

      Timer(const Duration(seconds: 5), () {
        setState(() {
          showCloseButton = true;
        });
      });
    } catch (e) {
      print('Error fetching ad image: $e');
      setState(() {
        showAdImage = false;
      });
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح الرابط: $uri')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء فتح الرابط: $e')),
      );
    }
  }

  launchWhatsApp(BuildContext context) async {
    const whatsappUrl = 'https://wa.me/+201118546085';
    await _launchUrl(context, whatsappUrl);
  }

  launchEmail(BuildContext context, String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw ' الايميل Hamada.matter@gmail.com:تواصل معنا على';
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      title: 'خطأ',
      desc: errorMessage,
      btnOkText: "حسناً",
      btnOkOnPress: () {},
    ).show();
  }

  void _launchAdurl(String adurl) async {
    String url = adurl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _fetchCityNames() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .orderBy('timestamp', descending: false) // ترتيب تصاعدي
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print("خطأ في اسم المدينة: $e");
      return [];
    }
  }

  Future<List<DocumentSnapshot>> _fetchAdNames() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('customad').get();
      return querySnapshot.docs;
    } catch (e) {
      print("خطأ في الاعلانات: $e");
      return [];
    }
  }

  List<Widget> generateAdTiles(List<DocumentSnapshot> ads) {
    List<Widget> adTiles = ads.map((adDoc) {
      final ad = adDoc.data() as Map<String, dynamic>;
      final String imageUrl =
          ad['imageUrl'] ?? 'https://via.placeholder.com/150';
      final String? url = ad['url'];
      final String adId = adDoc.id;

      return InkWell(
        onTap: () {
          _launchAdurl("$url");
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0.r),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes!)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Container(color: Colors.blue);
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10.0.r),
              ),
            ),
          ],
        ),
      );
    }).toList();

    return adTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "اختيار المدينة",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Boutros",
            ),
          ),
        ),
        actions: [
          IconButton(
            color: Colors.blue,
            onPressed: () async {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.info,
                animType: AnimType.bottomSlide,
                title: 'تنبيه',
                desc: 'هل تريد تسجيل الخروج من التطبيق',
                btnOkOnPress: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(const AuthPage());
                },
                btnCancelText: "إلغاء",
                btnOkText: "بالتأكيد",
                btnCancelOnPress: () {},
              ).show();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: showAdImage && adImageUrl.isNotEmpty
          ? Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    _launchUrl(context, adStartC);
                  },
                  child: Center(
                    child: Image.network(
                      adImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes!)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Text('Failed to load image',
                                style: TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (showCloseButton)
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showAdImage = false;
                        });
                      },
                      child: Container(
                        width: 30.0.w, // عرض الزر
                        height: 30.0.h, // ارتفاع الزر
                        decoration: const BoxDecoration(
                          color: Colors.white, // لون الخلفية البيضاء
                          shape: BoxShape.circle, // جعل الشكل دائريًا
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // لون الظل
                              blurRadius: 4, // شدة التمويه
                              offset: Offset(0, 2), // إزاحة الظل
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: Colors.black, // لون الأيقونة الأسود
                            size: 30.0, // حجم الأيقونة
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : ListView(
              children: [
                Container(
                  height: 100.h,
                  width: 200.w,
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey,
                          child: SvgPicture.asset(
                              "assets/Black and Orange Initials Letter R Broadcast Media Logo.svg"),
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            "تواصل معنا ",
                            style: TextStyle(
                              fontFamily: "Boutros",
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  launchEmail(
                                      context, "Hamada.matter@gmail.com");
                                },
                                icon: const Icon(Icons.email),
                              ),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    launchWhatsApp(context);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: SizedBox(
                                      height: 400.h,
                                      width: 400.w,
                                      child: Image.network(
                                          "https://img.icons8.com/?size=100&id=16713&format=png&color=000000"),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          right: 8.0,
                        ),
                        child: Text(
                          "مسار",
                          style: TextStyle(
                              fontFamily: "Boutros",
                              color: Colors.blue,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchAdNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("خطأ في جلب البيانات"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("لايوجد اعلانات"));
                    } else {
                      print("Data fetched: ${snapshot.data}");
                      return SizedBox(
                        width: 100.w,
                        height: 100.h,
                        child: CarouselSlider(
                          items: generateAdTiles(snapshot.data!),
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            autoPlay: true,
                            aspectRatio: 2.0,
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 10.h),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchCityNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error fetching cities"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No cities available"));
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, i) {
                          final catdoc = snapshot.data![i];
                          return InkWell(
                            onTap: () {
                              Get.to(() => Profession(catid: catdoc.id));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                // إضافة Padding للتباعد الداخلي
                                padding: EdgeInsets.all(2.0.w),
                                // استخدام .w لضبط التباعد بناءً على حجم الشاشة
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 18.r,
                                      // استخدام .r لضبط نصف القطر بناءً على حجم الشاشة
                                      backgroundImage: NetworkImage(
                                        catdoc['imageUrl'],
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    // استخدام .h لضبط الارتفاع بناءً على حجم الشاشة
                                    Text(
                                      catdoc['name'],
                                      style: TextStyle(
                                        fontFamily: "Boutros",
                                        fontSize: 13.sp,
                                        // استخدام .sp لضبط حجم الخط بناءً على حجم الشاشة
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }
}
