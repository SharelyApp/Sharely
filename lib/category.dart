import 'package:flutter/material.dart';
import 'package:sharely/theme/colors.dart';

/// 카테고리 데이터 모델 (이름 + 색상)
class Category {
  String name;
  Color color;
  Category({required this.name, required this.color});
}

/// 카테고리 관리 페이지 — 목록 조회 / 추가 / 수정 / 삭제, 색상 지정.
/// 현재는 메모리 상태로 동작하며, 추후 Firestore 등으로 영구 저장 연결 가능.
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // 예시 카테고리 시드
  final List<Category> _categories = [
    Category(name: '개인일정', color: const Color(0xFF43A047)),
    Category(name: '근무', color: const Color(0xFF1E88E5)),
    Category(name: '미팅', color: const Color(0xFFFB8C00)),
    Category(name: '약속', color: const Color(0xFFE53935)),
  ];

  // 사용자가 고를 수 있는 색상 팔레트
  static const List<Color> _palette = [
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFF3949AB),
    Color(0xFF1E88E5),
    Color(0xFF039BE5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFF7CB342),
    Color(0xFFFDD835),
    Color(0xFFFFB300),
    Color(0xFFFB8C00),
    Color(0xFFF4511E),
    Color(0xFF6D4C41),
    Color(0xFF757575),
    Color(0xFF546E7A),
  ];

  void _showEditSheet({Category? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    Color selectedColor = existing?.color ?? _palette.first;
    final bool isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                // 키보드가 시트를 가리지 않도록
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? '카테고리 수정' : '카테고리 추가',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '카테고리 이름',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '색상',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _palette.map((c) {
                      final bool sel = c.value == selectedColor.value;
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedColor = c),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: sel
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: sel
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('카테고리 이름을 입력해주세요.')),
                          );
                          return;
                        }
                        setState(() {
                          if (isEdit && index != null) {
                            _categories[index].name = name;
                            _categories[index].color = selectedColor;
                          } else {
                            _categories.add(
                              Category(name: name, color: selectedColor),
                            );
                          }
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        isEdit ? '저장' : '추가',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text("'${_categories[index].name}' 카테고리를 삭제할까요?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _categories.removeAt(index));
              Navigator.pop(dialogContext);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '카테고리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: _categories.isEmpty
          ? const Center(
              child: Text(
                '카테고리가 없습니다.\n+ 버튼으로 추가해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(cat.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () =>
                            _showEditSheet(existing: cat, index: index),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteCategory(index),
                      ),
                    ],
                  ),
                  onTap: () => _showEditSheet(existing: cat, index: index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showEditSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
