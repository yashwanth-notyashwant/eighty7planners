import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/blog.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/image.dart';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import '../widgets/blogWidgetInHomeScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Blog> posts = [];
  bool isLoading = true;
  List<ImageDat> mainListOut = [];
  bool loadMore = false;
  // bool needInternet = false;

  @override
  void initState() {
    super.initState();
    fetchPosts(loadMore);
  }

  Future<void> fetchPosts(bool loadMore) async {
    final String apiUrl = "https://intent-kit-16.hasura.app/api/rest/blogs";
    final String adminSecret =
        "32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? postsJson = prefs.getString('post');

      if (postsJson != null) {
        // If posts are already saved in SharedPreferences, load them
        List<dynamic> data = json.decode(postsJson);

        setState(() async {
          posts.addAll(
            data.map(
              (item) => Blog(
                id: item['id'],
                imageUrl: item['image_url'],
                title: item['title'],
                isFav: false,
              ),
            ),
          );
          //here ill call the load5 function every time
          var a = await load5(prefs, data, loadMore);
          isLoading = false; // Data has been loaded from SharedPreferences
        });
      } else {
        // If posts are not saved in SharedPreferences, fetch them from the API
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {'x-hasura-admin-secret': adminSecret},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final List<dynamic> data = responseData['blogs'];

          setState(() async {
            posts.addAll(
              data.map(
                (item) => Blog(
                  id: item['id'],
                  imageUrl: item['image_url'],
                  title: item['title'],
                  isFav: false,
                ),
              ),
            );
            //here ill call the load5 function every time
            var a = await load5(prefs, data, loadMore);
            isLoading = false; // Data has been loaded from the API
          });

          await prefs.setString('post', json.encode(data));
        } else {
          throw Exception('Failed to load posts');
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<List<ImageDat>> load5(
      SharedPreferences prefs, List<dynamic> data, bool loadMore) async {
    List<ImageDat> mainList = [];

    try {
      String? mainListJsonString = prefs.getString('mainList1');
      if (mainListJsonString != null) {
        print('saveed');

        // If mainList is already saved in SharedPreferences, parse and load it
        List<dynamic> mainListData = json.decode(mainListJsonString);
        mainList.addAll(
          mainListData.map(
            (item) => ImageDat(
              id: item['id'],
              imagePath: item['imagePath'],
              title: item['title'],
              isFav: false,
            ),
          ),
        );
        print(mainList[0].imagePath);
        print(mainList[0].id);
        print(mainList[0].id);
        print(mainList.length);
      }

      int beginIndex = prefs.getInt('beginIndex') ?? 0;
      int endIndex = 0;
      if (beginIndex == 0) {
        endIndex = 5;
      }
      if (loadMore == false && beginIndex != 0) {
        endIndex = beginIndex;
      }
      if (loadMore == true) {
        endIndex = beginIndex + 5;
      }

      // Make sure we don't go beyond the end of the data
      endIndex = endIndex > data.length ? data.length : endIndex;

      for (int i = beginIndex; i < endIndex; i++) {
        print('in the loop');
        String imageUrl = data[i]['image_url'];
        try {
          // Get the application documents directory
          final appDocDir = await getApplicationDocumentsDirectory();
          String imagePath = '${appDocDir.path}/image_$i.jpg';

          // Download the image using dio package and save it to the specified path
          final Dio dio = Dio();
          await dio.download(imageUrl, imagePath);

          // Create an ImageData object with the downloaded image path and other details
          ImageDat imageData = ImageDat(
            id: data[i]['id'],
            imagePath: imagePath,
            title: data[i]['title'],
            isFav: false,
          );

          // Add the ImageData object to the mainList
          mainList.add(imageData);
          print('added something');
        } catch (error) {
          print('Error downloading image: $error');
        }
      }

      // Update beginIndex in SharedPreferences

      await prefs.setInt('beginIndex', endIndex);

      // Serialize mainList to a list of maps
      List<Map<String, dynamic>> mainListJson = mainList
          .map((image) => {
                'id': image.id,
                'imagePath': image.imagePath,
                'title': image.title,
              })
          .toList();

      // Save the updated mainList in SharedPreferences
      await prefs.setString('mainList1', json.encode(mainListJson));
    } catch (error) {
      print('Error loading or saving mainList: $error');
    }
    setState(() {
      isLoading = false;
    });
    mainListOut = mainList;
    return mainList;
  }

  @override
  Widget build(BuildContext context) {
    var hi = MediaQuery.of(context).size.height;
    var wi = MediaQuery.of(context).size.width;
    return MaterialApp(
      color: Color.fromRGBO(18, 18, 18, 1),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            child: Container(
              color: Color.fromRGBO(18, 18, 18, 1),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 140,
                        color: Color.fromRGBO(40, 40, 40, 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 60, left: 25),
                              height: 140,
                              // width: wi,
                              // color: Color.fromRGBO(18, 18, 18, 1),
                              color: Color.fromRGBO(40, 40, 40, 1),
                              child: Text(
                                'Blogs',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            ConnectivityStatusWidget(),
                          ],
                        ),
                      ),
                      Positioned(
                        top:
                            110, // Position the second container 150 pixels from the top

                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(18, 18, 18, 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ),
                          ),
                          height: 50,
                          width: wi,
                          child: Center(child: Text(' ')),
                        ),
                      ),
                    ],
                  ),
                  isLoading
                      ? Container(
                          color: Color.fromRGBO(18, 18, 18, 1),
                          height: hi - 140,
                          child: Center(
                            child:
                                CircularProgressIndicator(), // Show loading spinner
                          ),
                        )
                      : Container(
                          // color: Color.fromRGBO(40, 40, 40, 1),
                          color: Color.fromRGBO(18, 18, 18, 1),
                          height: mainListOut.length * 264,
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: mainListOut.length,
                            itemBuilder: (context, index) {
                              return CardWidget(
                                  mainListOut[index], mainListOut[index].id);
                            },
                          ),
                        ),
                  Container(
                    color: Color.fromRGBO(18, 18, 18, 1),
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.only(
                        left: 5, right: 5, top: 5, bottom: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        //
                        await fetchPosts(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(40, 40, 40, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        textStyle: const TextStyle(fontSize: 20.0),
                      ),
                      child: const Text(
                        'Load More',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
//
//
// For checking internet connection
//
//
//

class ConnectivityController extends GetxController {
  Rx<ConnectivityResult> connectivityResult =
      Rx<ConnectivityResult>(ConnectivityResult.none);

  void checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    connectivityResult.value = result;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize the connectivity check and set it in the state
    checkConnectivity();

    // Periodically check connectivity (e.g., every 5 seconds)
    Timer.periodic(Duration(seconds: 1), (_) {
      checkConnectivity();
    });
  }
}

class ConnectivityStatusWidget extends StatefulWidget {
  @override
  State<ConnectivityStatusWidget> createState() =>
      _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget> {
  final ConnectivityController controller = Get.put(ConnectivityController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connectivityResult = controller.connectivityResult.value;
      Icon icon;
      Color iconColor;

      // Check the connectivity status and set the icon accordingly
      switch (connectivityResult) {
        case ConnectivityResult.none:
          icon = Icon(Icons.signal_wifi_off);
          iconColor = Colors.red;
          break;
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
          icon = Icon(Icons.signal_wifi_4_bar);
          iconColor = Colors.green;
          break;
        default:
          icon = Icon(Icons.warning);
          iconColor = Colors.yellow;
          break;
      }

      return Container(
        color: Color.fromRGBO(40, 40, 40, 1),
        margin: EdgeInsets.only(right: 20, top: 15),
        child: Icon(
          icon.icon,
          color: iconColor,
          size: 30,
        ),
      );
    });
  }
}
