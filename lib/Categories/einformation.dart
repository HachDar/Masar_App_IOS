import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class Information extends StatefulWidget {
  final String typeid;
  final String profid;
  final String catid;
  final String peoid;
  final String namepeo;

  const Information({
    super.key,
    required this.typeid,
    required this.profid,
    required this.catid,
    required this.peoid,
    required this.namepeo,
  });

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoadingInfo = true;
  Map<String, dynamic>? _infoData;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.catid)
          .collection("profession")
          .doc(widget.profid)
          .collection("type")
          .doc(widget.typeid)
          .collection("people")
          .doc(widget.peoid)
          .collection("info")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _infoData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
          _isLoadingInfo = false;
        });
      } else {
        setState(() {
          _isLoadingInfo = false;
        });
      }
    } catch (e) {
      print("Error fetching info: $e");
      setState(() {
        _isLoadingInfo = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch URL: $uri');
      throw 'Could not launch URL: $uri';
    }
  }

  Future<void> _launchCall(String phone) async {
    await _launchUrl('tel:$phone');
  }

  Future<void> _launchWhatsApp(String whats) async {
    await _launchUrl('https://wa.me/$whats');
  }

  Future<void> _launchInsta(String insta) async {
    await _launchUrl(insta);
  }

  Future<void> _launchLocation(String location) async {
    const String baseUrl = 'https://www.google.com/maps/search/';
    final String query = Uri.encodeComponent(location);
    await _launchUrl('$baseUrl$query');
  }

  Future<void> _launchFacebook(String facebook) async {
    await _launchUrl(facebook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontFamily: "Boutros",
          ),
        ),
      ),
      body: _isLoadingInfo
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundImage: NetworkImage(_infoData?['imageUrl'] ??
                            'https://via.placeholder.com/150'),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _infoData?['name'] ?? 'غير متوفر...',
                        style: TextStyle(
                          fontFamily: "Boutros",
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _infoData?['joptitle'] ?? 'غير متوفر...',
                        style: TextStyle(
                          fontFamily: "Boutros",
                          fontSize: 18.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      InkWell(
                        onTap: () {
                          _launchCall(_infoData?['phonenum'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          elevation: 0,
                          child: ListTile(
                            leading: const Icon(Icons.call,
                                color: Colors.greenAccent),
                            title: GestureDetector(
                              child: const Text(
                                "اضغط للاتصال",
                                style: TextStyle(
                                  fontFamily: "Boutros",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchWhatsApp(
                              _infoData?['whatsnum'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: Image.network(
                                  "https://img.icons8.com/?size=100&id=16713&format=png&color=000000"),
                            ),
                            title: GestureDetector(
                              child: const Text(
                                "اضغط للانتقال للواتس اب",
                                style: TextStyle(
                                  fontFamily: "Boutros",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchLocation(
                              _infoData?['location'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: const Icon(Icons.location_on,
                                color: Colors.redAccent),
                            title: GestureDetector(
                              child: Text(
                                  _infoData?['location'] ?? 'غير متوفر...'),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        child: ListTile(
                          leading: const Icon(Icons.school,
                              color: Colors.blueAccent),
                          title: Text(
                              _infoData?['certificates'] ?? 'غير متوفر...'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchInsta(_infoData?['insta'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: SizedBox(
                              height: 15.h,
                              width: 15.w,
                              child: Image.network(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Instagram_logo_2022.svg/1200px-Instagram_logo_2022.svg.png"),
                            ),
                            title: GestureDetector(
                              child: const Text('حساب الانستغرام'),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchInsta(
                              _infoData?['facebook'] ?? 'غير متوفر...');
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
                            leading: SizedBox(
                              height: 15.h,
                              width: 15.w,
                              child: Image.network(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Facebook_f_logo_%282019%29.svg/1200px-Facebook_f_logo_%282019%29.png"),
                            ),
                            title: GestureDetector(
                              child: const Text('حساب الفيسبوك '),
                            ),
                          ),
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
