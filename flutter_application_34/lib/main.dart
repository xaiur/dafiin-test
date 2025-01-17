import 'package:flutter/material.dart';
import 'package:flutter_application_34/models/http_provider.dart';
import 'package:flutter_application_34/pages/home_provider.dart';
import 'package:provider/provider.dart';

// import 'pages/home_stateful.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: HomeStateful(),
      home: ChangeNotifierProvider(
        create: (context) => HttpProvider(),
        child: HomeProvider()),
    );
  }
}