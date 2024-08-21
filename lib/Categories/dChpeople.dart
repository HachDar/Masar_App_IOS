import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalel/Categories/einformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class People extends StatefulWidget {
  final String typeid;
  final String profid;
  final String catid;
  const People(
      {super.key,
      required this.profid,
      required this.catid,
      required this.typeid});

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _adNames = [];
  List<DocumentSnapshot> _peopleDocs = [];
  final int _currentIndex = 0;
  final bool _isLoadingAds = true;
  bool _isLoadingPeople = true;

  @override
  void initState() {
    super.initState();
    _fetchAdNames();
    _fetchPeople();
  }

  Future<void> _fetchPeople() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .doc(widget.profid)
          .collection("type")
          .doc(widget.typeid)
          .collection("people")
          .orderBy('timestamp', descending: false) // ترتيب تصاعدي
          .get();
      List<DocumentSnapshot> peopleDocs = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('name') && data['name'] is String) {
          peopleDocs.add(doc);
        } else {
          print("Missing or invalid 'name' field in document: ${doc.id}");
        }
      }

      setState(() {
        _peopleDocs = peopleDocs;
        _isLoadingPeople = false;
      });
    } catch (e) {
      print("Error fetching people: $e");
      setState(() {
        _isLoadingPeople = false;
      });
    }
  }

  void _launchAdurl(String adurl) async {
    String url = adurl;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "اختيار الاشخاص",
            style: TextStyle(
              fontFamily: "Boutros",
            ),
          ),
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
                        fontFamily: "Boutros",
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
                if (_isLoadingPeople)
                  const Center(child: CircularProgressIndicator())
                else if (_peopleDocs.isEmpty)
                  const Center(child: Text("No people available"))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: _peopleDocs.length,
                    itemBuilder: (context, i) {
                      final data =
                          _peopleDocs[i].data() as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          Get.to(Information(
                            typeid: widget.typeid,
                            profid: widget.profid,
                            catid: widget.catid,
                            peoid: _peopleDocs[i].id,
                            namepeo: data['name'],
                          ));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0.r), // ضبط نصف القطر بناءً على حجم الشاشة
                          ),
                          child: Padding(
                            // إضافة Padding لتحسين التباعد الداخلي
                            padding: EdgeInsets.all(
                                2.0.w), // ضبط التباعد بناءً على حجم الشاشة
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius: 18
                                      .r, // ضبط نصف قطر الأيقونة بناءً على حجم الشاشة
                                  backgroundImage: NetworkImage(
                                    data['imageUrl'],
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        2.h), // إضافة تباعد بين الأيقونة والنص
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontFamily: "Boutros",
                                    fontSize: 13
                                        .sp, // ضبط حجم الخط بناءً على حجم الشاشة
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
