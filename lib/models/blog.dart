import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Blog {
  String id;
  String imageUrl;
  String title;
  bool isFav;

  Blog({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.isFav,
  });
}
