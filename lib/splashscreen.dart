import 'package:flutter/material.dart';
import 'package:human_generator/custom_splash.dart';
import 'package:human_generator/drawing_page.dart';

class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSplash(
        duration: 2000,
        home: const DrawingPage(),
        imagePath: const Center(
          child: Text(
            "Human Face Generator",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 35, color: Colors.white),
          ),
        ),
        backGroundColor: Colors.purple,
      ),
    );
  }
}

// class CustomSplashScreen extends StatefulWidget {
//   const CustomSplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CustomSplashScreen> createState() => _CustomSplashScreenState();
// }
//
// class _CustomSplashScreenState extends State<CustomSplashScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SplashScreen(
//         seconds: 2,
//         navigateAfterSeconds: const Home(),
//         title: const Text(
//           "Human Face Generator",
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 35, color: Colors.white),
//         ),
//         gradientBackground: const LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromRGBO(138, 35, 135, 1),
//               Color.fromRGBO(233, 64, 87, 1),
//               Color.fromRGBO(242, 113, 33, 1),
//             ]),
//         loaderColor: Colors.white);
//   }
// }
