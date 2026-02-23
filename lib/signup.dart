import 'package:flutter/material.dart';
import 'package:sharely/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharely/auth_wrapper.dart';

/// 회원가입 페이지 (이름 + 이메일 + 비밀번호)
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 회원가입 함수
  Future<void> signUp() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print("에러 발생: ${e.message}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "회원가입 실패")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "회원가입",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이름
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 5),
              child: Text(
                "이름",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "이름",
                hintStyle: TextStyle(color: AppColors.grayTextColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),

            // 휴대전화
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 5, bottom: 5),
              child: Text(
                "휴대전화",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: "휴대전화('-' 제외 11자리)",
                hintStyle: TextStyle(color: AppColors.grayTextColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),

            // 이메일
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 5, bottom: 5),
              child: Text(
                "이메일",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "이메일",
                hintStyle: TextStyle(color: AppColors.grayTextColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),

            // 비밀번호
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 5, bottom: 5),
              child: Text(
                "비밀번호",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "비밀번호",
                hintStyle: TextStyle(color: AppColors.grayTextColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 회원가입 버튼
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
              child: const Text(
                "가입하기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                signUp();
              },
            ),
          ],
        ),
      ),
    );
  }
}
