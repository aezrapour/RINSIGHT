import 'package:flutter/material.dart';
import 'package:rinsight_companion_app/Home/Home.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() =>_NavScreenState();
}
class _NavScreenState extends State<NavScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return const Placeholder();
  }
}
  // Widget build(BuildContext context) 
  // {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Navigation'),
  //     ),
  //     body: Center(
  //       child: ElevatedButton(
  //         onPressed: () {
  //           Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => const HomeScreen()),
  //             );
  //         },
  //         child: const Text('Go back!'),
  //       ),
  //     ),
  //   );
  // }