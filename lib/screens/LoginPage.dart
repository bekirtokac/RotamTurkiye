import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/screens/HomePage.dart';
import 'package:rotam_turkiye/screens/SignupPage.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/widgets/CustomButton.dart';
import 'package:rotam_turkiye/widgets/CustomInput.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = null;
  }

  void onLogin() async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Tüm alanları doldurunuz';
      });
    } else if (!isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Geçersiz email';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });

      print('Email: $email');
      print('Password: $password');
      UserModel? loginUser =
          await userModel.signInWithEmailAndPassword(email, password);

      if (loginUser != null) {
        print("Oturum açan kullanıcı: " + loginUser.id.toString());

        // HomePage'e yönlendirme
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(
              userModel: loginUser,
            ),
          ),
        );
      } else {
        // Kullanıcı giriş yaparken bir hata oluştu
        setState(() {
          _errorMessage = 'Kullanıcı giriş yaparken bir hata oluştu!';
        });
      }
    }
  }

  bool isValidEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFFF5733),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20.0)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rotam Türkiye",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Seyahatlerinizi kişiselleştirin",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.8,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomInput(
                    hintText: "Email",
                    isPassword: false,
                    inputType: InputType.TextField,
                    controller: _emailController,
                    // defaultValue parametresi kaldırıldı
                  ),
                  CustomInput(
                    hintText: "Parola",
                    isPassword: true,
                    inputType: InputType.TextField,
                    controller: _passwordController,
                    // defaultValue parametresi kaldırıldı
                  ),
                  SizedBox(height: 20),
                  _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        )
                      : SizedBox(),
                  RichText(
                    text: TextSpan(
                      text: 'Hesabınız yok mu? ',
                      style: TextStyle(color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Kayıt olun.',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: "Giriş Yap",
                    onPressed: onLogin,
                    color: Color(0xFFFF5733),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
