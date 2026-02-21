import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharely/auth_service.dart';
import 'package:sharely/login.dart';
import 'package:sharely/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {};
  final user = FirebaseAuth.instance.currentUser;

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addEventDialog() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('날짜를 먼저 선택해주세요.')));
      return;
    }

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("일정 추가"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "일정 내용을 입력하세요"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final dayKey = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                );

                if (_events[dayKey] != null) {
                  _events[dayKey]!.add(text);
                } else {
                  _events[dayKey] = [text];
                }

                setState(() {}); // UI 업데이트
              }
              Navigator.pop(context);
            },
            child: const Text("저장"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      /// 🔥 사이드 메뉴
      drawer: SizedBox(
        width: screenWidth * 0.6, // ✅ 화면 50%
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
                  Navigator.pop(context);
                },
              ),

              ListTile(
                contentPadding: const EdgeInsets.only(left: 24),
                leading: Icon(Icons.palette_outlined, size: 20),
                title: Text("캘린더 테마"),
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
      ),

      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "${_focusedDay.year}. ${_focusedDay.month}",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬 유지
              children: [
                /// 오늘 버튼
                TextButton(
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.buttonborderColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    final today = DateTime.now();
                    setState(() {
                      _focusedDay = today;
                      _selectedDay = today;
                    });
                  },
                  child: const Text(
                    "오늘",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// 이전 달
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    side: const BorderSide(
                      color: AppColors.buttonborderColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _goToPreviousMonth,
                  child: const Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(width: 10),

                /// 다음 달
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    side: const BorderSide(
                      color: AppColors.buttonborderColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _goToNextMonth,
                  child: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = constraints.maxHeight;

                final daysOfWeekHeight = totalHeight * 0.05; // 요일 5%
                final rowHeight = (totalHeight - daysOfWeekHeight) / 5;

                return TableCalendar(
                  locale: 'ko_KR',
                  headerVisible: false,
                  rowHeight: rowHeight,
                  daysOfWeekHeight: daysOfWeekHeight,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    isTodayHighlighted: false,
                    defaultTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.main,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final events =
                          _events[DateTime(day.year, day.month, day.day)] ?? [];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 날짜만 동그라미
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.transparent, // 기본은 투명
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),
                          // 일정 텍스트 표시
                          ...events
                              .take(2)
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final events =
                          _events[DateTime(day.year, day.month, day.day)] ?? [];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 선택된 날짜만 동그라미 강조
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.main,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),

                          // 선택된 날짜 일정 표시
                          ...events
                              .take(2)
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      // 버튼 눌러서 선택된 날짜에 이벤트 추가
      floatingActionButton: FloatingActionButton(
        onPressed: _addEventDialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppColors.main,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
