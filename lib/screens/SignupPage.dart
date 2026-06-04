import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/screens/HomePage.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/widgets/CustomButton.dart';
import 'package:rotam_turkiye/widgets/CustomInput.dart';
import 'package:rotam_turkiye/screens/LoginPage.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? _selectedCity;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCity = null;
    _errorMessage = null;
  }

  void onConnect() async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);

    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;
    String? city = _selectedCity;

    if (email.isEmpty || password.isEmpty || name.isEmpty || city == null) {
      setState(() {
        _errorMessage = 'Tüm alanları doldurunuz';
      });
      return;
    } else if (!isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Geçersiz email';
      });
      return;
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    print("email: ${emailController.text}\n");
    print("Şifre: ${passwordController.text}\n");
    print("İsim: ${nameController.text}\n");
    print("Şehir: $_selectedCity\n");

    UserModel? creatingUser =
        await userModel.createUserWithEmailAndPassword(email, password);

    if (creatingUser != null) {
      print("Kayıt olan kullanıcı: ${creatingUser.id}isim: ${creatingUser.name}");

      bool success =
          await userModel.saveUserDetails(creatingUser.id, name, city);

      if (success) {
        print("Kullanıcı bilgileri başarıyla kaydedildi.");
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(
                userModel: creatingUser,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Kullanıcı bilgileri kaydedilemedi!';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kullanıcı oluşturulamadı!';
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
    final userModel = Provider.of<MyUserModel>(context);
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
                    controller: emailController,
                    // defaultValue parametresi kaldırıldı
                  ),
                  CustomInput(
                    hintText: "Parola",
                    isPassword: true,
                    inputType: InputType.TextField,
                    controller: passwordController,
                    // defaultValue parametresi kaldırıldı
                  ),
                  CustomInput(
                    hintText: "İsim Soyisim",
                    isPassword: false,
                    inputType: InputType.TextField,
                    controller: nameController,
                    // defaultValue parametresi kaldırıldı
                  ),
                  CustomInput(
                    hintText: "Şehir seç",
                    isPassword: false,
                    inputType: InputType.Dropdown,
                    onChanged: (selectedCity) {
                      setState(() {
                        _selectedCity = selectedCity;
                      });
                    },
                    // defaultValue parametresi kaldırıldı
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Hesabınız var mı? ',
                      style: TextStyle(color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Giriş yapın.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        )
                      : SizedBox(),
                  CustomButton(
                    text: "Kayıt Ol",
                    onPressed: onConnect,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
