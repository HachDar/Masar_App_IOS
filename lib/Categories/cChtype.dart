import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cChtype.dart';
import 'dChpeople.dart';

class Type extends StatefulWidget {
  final String profid;
  final String catid;
  const Type({super.key, required this.profid, required this.catid});

  @override
  State<Type> createState() => _TypeState();
}

class _TypeState extends State<Type> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _adNames = [];
  List<DocumentSnapshot> _typeDocs = [];
  int _currentIndex = 0;
  bool _isLoadingAds = true;
  bool _isLoadingTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchAdNames();
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .doc(widget.profid)
          .collection("type")
          .get();
      setState(() {
        _typeDocs = querySnapshot.docs;
        _isLoadingTypes = false;
      });
    } catch (e) {
      print("Error fetching types: $e");
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  void _launchAdurl(String adurl) async {
    String url = "$adurl";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<List<DocumentSnapshot>> _fetchAdNames() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('customad').get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching ad names: $e");
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
        title: const Center(
          child: Text("اختيار نوع المهنة"),
        ),
      ),
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
          Container(
            color: Colors.white,
            child: Column(
              children: [
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
                        width: double.infinity,
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
                if (_isLoadingTypes)
                  const Center(child: CircularProgressIndicator())
                else if (_typeDocs.isEmpty)
                  const Center(child: Text("No Type available"))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _typeDocs.length,
                    itemBuilder: (context, i) {
                      final people = _typeDocs[i];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Get.to(People(
                                profid: widget.profid,
                                catid: widget.catid,
                                typeid: people.id));
                          },
                          child:  Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30.r,
                                backgroundImage: NetworkImage(
                                  people['imageUrl'],
                                ),
                              ),
                              Text(
                                people[
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
