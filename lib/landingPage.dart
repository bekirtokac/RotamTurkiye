import 'package:flutter/material.dart';
import 'package:rotam_turkiye/screens/HomePage.dart';
import 'package:rotam_turkiye/screens/Onboarding.dart';
import 'package:rotam_turkiye/screens/SignupPage.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<MyUserModel>(context);

    if (userModel.state == ViewState.Idle) {
      if (userModel.user == null) {
        return Onboarding();
      } else {
        return HomePage(userModel: userModel.user);
      }
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // if (_userModel.user == null) {
    //   // Show Onboarding
    //   return Onboarding();
    // } else {
    //   // Navigate to HomePage
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(
    //           builder: (context) => HomePage(
    //                 authService: _userModel.user,
    //               )),
    //     );
    //   });
    //   return Container(); // Placeholder while navigation happens
    // }
  }
}
