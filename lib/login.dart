import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharely/auth_service.dart';
import 'package:sharely/home.dart';
import 'package:sharely/signup.dart';
import 'package:sharely/theme/colors.dart';

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Image.asset(
              'assets/images/logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 이메일
                Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5),
                  child: Text(
                    "아이디",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "이메일을 입력해주세요.",
                    hintStyle: TextStyle(color: AppColors.grayTextColor),
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppColors.grayTextColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),

                /// 비밀번호
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                    child: Text(
                      "비밀번호",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: false, // 비밀번호 안보이게
                  decoration: InputDecoration(
                    hintText: "비밀번호를 입력해주세요.",
                    hintStyle: TextStyle(color: AppColors.grayTextColor),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: AppColors.grayTextColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                /// 로그인 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "로그인",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // 로그인
                    authService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 로그인 성공
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("로그인 성공")));

                        // HomePage로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(err)));
                      },
                    );
                  },
                ),

                /// 회원가입 버튼
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 버튼 크기 최소화
                      children: const [
                        Text(
                          "아직 회원이 아니신가요?  ",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          "회원가입",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.main,
                            color: AppColors.main,
                          ),
                        ),
                      ],
                    ),

                    // 기존 onPressed 코드
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
