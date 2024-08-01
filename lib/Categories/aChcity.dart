import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalel/Categories/bChprofession.dart';
import 'package:dalel/auth/authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
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
      QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();
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

    // إضافة العنصر الجديد

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
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                    Get.offAll(AuthPage());
                  },
                  btnCancelText: "إلغاء",
                  btnCancelOnPress: () {},
                ).show();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
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
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    right: 8.0,
                  ),
                  child: Text(
                    "مسار",
                    style: TextStyle(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final catdoc = snapshot.data![i];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => Profession(catid: catdoc.id));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30.r,
                                backgroundImage: NetworkImage(
                                  catdoc['imageUrl'],
                                ),
                              ),
                              Text(
                                catdoc[
                                    'name'], // يمكنك تغيير هذا النص بعنوان البطاقة
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
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
