import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  setPathUrlStrategy();
  // Analytics here:
  // https://console.firebase.google.com/u/2/project/blog-1e103/analytics/app/web:YWRhMDIyNTctNWUxMy00OTEzLWFlNjgtMThjMzc4MjhkODg5/overview/reports~2Fdashboard%3Fr%3Dfirebase-overview&fpn%3D885371653561
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BlogApp());
}
