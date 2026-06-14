import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharely/auth_service.dart';
import 'package:sharely/login.dart';
import 'package:sharely/category.dart';

/// 홈 화면 사이드 메뉴(드로어) — home.dart에서 분리.
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.6, // 화면 50%
      child: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? "사용자",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? "",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              contentPadding: const EdgeInsets.only(left: 24),
              leading: Icon(Icons.folder_open_outlined, size: 20),
              title: Text("카테고리"),
              onTap: () {
                Navigator.pop(context); // 드로어 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryPage()),
                );
              },
            ),

            ListTile(
              contentPadding: const EdgeInsets.only(left: 24),
              leading: Icon(Icons.palette_outlined, size: 20),
              title: Text("테마 설정"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              contentPadding: const EdgeInsets.only(left: 24),
              leading: Icon(Icons.view_agenda_outlined, size: 20),
              title: Text("캘린더 버전"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 24),
              leading: Icon(Icons.info_outline, size: 20),
              title: Text("고객지원"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              contentPadding: const EdgeInsets.only(left: 24),
              leading: Icon(Icons.settings_outlined, size: 20),
              title: Text("설정"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            ListTile(
              contentPadding: const EdgeInsets.only(left: 24, bottom: 30),
              title: const Text(
                "로그아웃",
                style: TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.red,
                ),
              ),
              onTap: () {
                context.read<AuthService>().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
