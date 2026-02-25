import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharely/auth_service.dart';
import 'package:sharely/login.dart';
import 'package:sharely/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lunar/lunar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 오늘 날짜 선택
    _selectedDay = _focusedDay;
  }

  // 오늘 버튼 활성화 여부 계산
  bool get isTodaySelected {
    final today = DateTime.now();
    return _selectedDay != null &&
        _selectedDay!.year == today.year &&
        _selectedDay!.month == today.month &&
        _selectedDay!.day == today.day;
  }

  // 공휴일(나중에 API 연동해서 실제 공휴일 데이터로 변경 예정)
  String? _getHolidayName(DateTime day) {
    final holidays = <DateTime, String>{
      DateTime(day.year, 1, 1): "새해",
      DateTime(day.year, 2, 17): "설날",
      DateTime(day.year, 3, 1): "삼일절",
      DateTime(day.year, 5, 5): "어린이날",
      DateTime(day.year, 5, 24): "부처님오신날",
      DateTime(day.year, 6, 6): "현충일",
      DateTime(day.year, 7, 17): "제헌절",
      DateTime(day.year, 8, 15): "광복절",
      DateTime(day.year, 9, 25): "추석",
      DateTime(day.year, 10, 3): "개천절",
      DateTime(day.year, 10, 9): "한글날",
      DateTime(day.year, 12, 25): "크리스마스",
    };

    return holidays[DateTime(day.year, day.month, day.day)];
  }

  final Map<String, Color> categoryColors = {
    "기본": Colors.grey,
    "업무": Colors.blue,
    "개인": Colors.green,
    "약속": Colors.orange,
  };

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
    DateTime selectedDate = DateTime.now();
    String selectedCategory = "기본";
    String selectedRepeat = "없음";
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 같이 올라가게
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // 상단 드래그 바
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // 상단 버튼 영역
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 취소
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.buttonborderColor,
                                ),
                              ),

                              // 저장
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  final text = controller.text.trim();
                                  if (text.isNotEmpty) {
                                    final dayKey = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                    );

                                    final eventText =
                                        "[$selectedCategory] $text";

                                    if (_events[dayKey] != null) {
                                      _events[dayKey]!.add(eventText);
                                    } else {
                                      _events[dayKey] = [eventText];
                                    }

                                    setState(() {});
                                  }

                                  Navigator.pop(context);
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.main.withOpacity(
                                    0.15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 내용 영역 (스크롤 가능)
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // 일정 제목
                                TextField(
                                  controller: controller,
                                  maxLines: 1,
                                  decoration: const InputDecoration(
                                    hintText: "제목",
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.grayTextColor,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                /// 날짜 선택
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${selectedDate.year}.${selectedDate.month}.${selectedDate.day}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    TextButton(
                                      child: const Text("날짜 변경"),
                                      onPressed: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                          locale: const Locale('ko', 'KR'),
                                        );

                                        if (picked != null) {
                                          setStateDialog(() {
                                            selectedDate = picked;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // 반복 설정
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "반복",
                                      style: TextStyle(fontSize: 16),
                                    ),

                                    SizedBox(
                                      width: 100,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedRepeat,
                                        items:
                                            [
                                                  "없음",
                                                  "매일",
                                                  "매주",
                                                  "매월",
                                                  "매년",
                                                  "사용자화",
                                                ]
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setStateDialog(() {
                                              selectedRepeat = value;
                                            });
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // 카테고리 선택
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "카테고리",
                                      style: TextStyle(fontSize: 16),
                                    ),

                                    SizedBox(
                                      width: 100,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedCategory,
                                        items: categoryColors.keys.map((
                                          category,
                                        ) {
                                          return DropdownMenuItem(
                                            value: category,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets.only(
                                                    right: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        categoryColors[category],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                Text(category),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setStateDialog(() {
                                              selectedCategory = value;
                                            });
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 일정 조회 다이얼로그
  void _showEventDetailDialog(DateTime dayKey, String eventText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          /// 타이틀 영역에 X 버튼 추가
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined),
                splashRadius: 20,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(eventText),
          ),

          actions: [
            /// ✏ 수정
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditEventDialog(dayKey, eventText);
              },
              child: const Text("수정"),
            ),

            // 삭제
            TextButton(
              onPressed: () {
                setState(() {
                  _events[dayKey]?.remove(eventText);
                  if (_events[dayKey]?.isEmpty ?? false) {
                    _events.remove(dayKey);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 일정 수정 다이얼로그
  void _showEditEventDialog(DateTime dayKey, String oldEvent) {
    final controller = TextEditingController(text: oldEvent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("일정 수정"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                final newText = controller.text.trim();
                if (newText.isNotEmpty) {
                  setState(() {
                    final index = _events[dayKey]!.indexOf(oldEvent);
                    _events[dayKey]![index] = newText;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 사이드 메뉴
      drawer: SizedBox(
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
                  Navigator.pop(context);
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
      ),

      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "${_focusedDay.year}. ${_focusedDay.month.toString().padLeft(2, '0')}",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: const Icon(
                Icons.search_outlined,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                print("검색창 클릭");
              },
            ),
          ),
        ],
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
                    backgroundColor: isTodaySelected
                        ? AppColors.main
                        : Colors.transparent,
                    side: BorderSide(
                      color:
                          _selectedDay != null &&
                              isSameDay(_selectedDay, DateTime.now())
                          ? AppColors.main
                          : AppColors.buttonborderColor,
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
                      if (isTodaySelected) {
                        // 이미 오늘이 선택되어 있으면 선택 해제
                        _selectedDay = null;
                      } else {
                        _focusedDay = today;
                        _selectedDay = today;
                      }
                    });
                  },
                  child: Text(
                    "오늘",
                    style: TextStyle(
                      color: isTodaySelected ? Colors.white : Colors.black,
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
                  eventLoader: _getEventsForDay,
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
                    markersMaxCount: 0,
                    selectedDecoration: BoxDecoration(
                      color: AppColors.main,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final isSelected = isSameDay(_selectedDay, day);
                      final holidayName = _getHolidayName(day);
                      final isHoliday = holidayName != null;

                      final lunar = Lunar.fromDate(day);
                      final lunarMonth = lunar.getMonth();
                      final lunarDay = lunar.getDay();

                      final events = _getEventsForDay(day);

                      return Container(
                        padding: const EdgeInsets.only(top: 5),
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            /// 위쪽 영역 (날짜 + 공휴일)
                            Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.main
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isHoliday
                                          ? Colors.red
                                          : isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),

                                if (holidayName != null)
                                  Text(
                                    holidayName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),

                            ...events
                                .take(2)
                                .map(
                                  (e) => GestureDetector(
                                    onTap: () {
                                      final dayKey = DateTime(
                                        day.year,
                                        day.month,
                                        day.day,
                                      );

                                      // 여기서 수정창이 아니라 조회창을 열도록 변경
                                      _showEventDetailDialog(dayKey, e);
                                    },
                                    child: Text(
                                      e,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),

                            /// 이 Expanded 가 핵심
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  '$lunarMonth/$lunarDay',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final holidayName = _getHolidayName(day);
                      final isHoliday = holidayName != null;

                      final lunar = Lunar.fromDate(day);
                      final lunarMonth = lunar.getMonth();
                      final lunarDay = lunar.getDay();

                      final events = _getEventsForDay(day);

                      return Container(
                        padding: const EdgeInsets.only(top: 5),
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            /// 위쪽 영역 (날짜 + 공휴일)
                            Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppColors.main,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),

                                if (holidayName != null)
                                  Text(
                                    holidayName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.red, // 항상 빨간색 유지
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),

                            if (events.isNotEmpty)
                              ...events
                                  .take(2)
                                  .map(
                                    (e) => GestureDetector(
                                      // 여기도 동일
                                      onTap: () {
                                        _showEventDetailDialog(day, e);
                                      },
                                      child: Text(
                                        e,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),

                            /// 음력은 항상 하단
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  '$lunarMonth/$lunarDay',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      final lunar = Lunar.fromDate(day);
                      final lunarMonth = lunar.getMonth();
                      final lunarDay = lunar.getDay();

                      return Container(
                        padding: const EdgeInsets.only(top: 5),
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey, // 다른 달은 흐리게
                                ),
                              ),
                            ),
                            Text(
                              '$lunarMonth/$lunarDay',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
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
