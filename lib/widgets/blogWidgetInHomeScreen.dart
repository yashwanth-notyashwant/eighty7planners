import 'dart:core';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'dart:async';

import 'package:flutter/services.dart';

import '../screens/blog_details.dart';

class CardWidget extends StatefulWidget {
  // Blog blog;
  final blog;
  String id;
  CardWidget(this.blog, this.id);

  @override
  State<CardWidget> createState() => _CardWidgetState(id: id);
}

class _CardWidgetState extends State<CardWidget> {
  String id;
  _CardWidgetState({required this.id});

  bool isLiked = false;

  // void toggleLike() {
  //   setState(() {
  //     // load from storage for liked list if id in liked list then make its is liked true
  //     isLiked = !isLiked;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // Load like status from SharedPreferences when the widget initializes.
    loadLikeStatus();
  }

  Future<void> loadLikeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool liked = prefs.getBool(id) ?? false;
    setState(() {
      isLiked = liked;
    });
  }

  Future<void> toggleLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Toggle the like status
    setState(() {
      isLiked = !isLiked;
    });
    // Save the updated like status to SharedPreferences
    await prefs.setBool(id, isLiked);
  }

  @override
  Widget build(BuildContext context) {
    var wi = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostsDetailScreen(widget.blog)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        width: wi * 0.95,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color.fromRGBO(18, 18, 18, 1),
        ),
        child: Card(
          color: Color.fromRGBO(40, 40, 40, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Provide a unique tag for each image
                    SizedBox(
                      height: 180,
                      width: wi * 0.95,
                      child: Hero(
                        tag: 'image${widget.blog.id}',
                        child: Image.file(
                          File(widget.blog.imagePath),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    Container(
                      height: 52,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: wi * 0.72,
                            padding:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            // margin: EdgeInsets.only(right: ),
                            child: Text(
                              widget.blog.title,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            // width: wi * 0.15,
                            margin: EdgeInsets.only(right: 18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  onPressed: toggleLike,
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                    size: 30.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
