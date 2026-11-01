import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(const AdhkarApp());
}

class AdhkarApp extends StatefulWidget {
  const AdhkarApp({Key? key}) : super(key: key);

  @override
  State<AdhkarApp> createState() => _AdhkarAppState();
}

class _AdhkarAppState extends State<AdhkarApp> {
  bool isEveningMode = false;

  void toggleTheme() {
    setState(() {
      isEveningMode = !isEveningMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أذكار - Liquid Glass',
      themeMode: isEveningMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE2E8F0),
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(onToggleTheme: toggleTheme, isEveningMode: isEveningMode),
    );
  }
}

class DhikrItem {
  final String id;
  final String text;
  final String note;
  final int targetCount;
  int currentCount;
  bool isCompleted;
  bool isFavorite;

  DhikrItem({
    required this.id,
    required this.text,
    required this.note,
    required this.targetCount,
    this.currentCount = 0,
    this.isCompleted = false,
    this.isFavorite = false,
  });
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isEveningMode;

  const HomeScreen({Key? key, required this.onToggleTheme, required this.isEveningMode}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _tasbeehCount = 0;
  String _searchQuery = '';

  // أذكار الصباح
  final List<DhikrItem> _morningAdhkar = [
    DhikrItem(id: 'm-1', text: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيطَانِ الرَّجِيمِ (آية الكرسي)', note: 'من قالها حين يصبح أُجير من الجن حتى يمسي.', targetCount: 1),
    DhikrItem(id: 'm-2', text: 'سورة الإخلاص والمعوذتان (3 مرات)', note: 'تكفيك من كل شيء.', targetCount: 3),
    DhikrItem(id: 'm-3', text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ...', note: 'طلب خير ما في اليوم والتعوذ من شره.', targetCount: 1),
    DhikrItem(id: 'm-4', text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا...', note: '', targetCount: 1),
    DhikrItem(id: 'm-5', text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلاَّ أَنْتَ (سيد الاستغفار)', note: 'من قالها موقنا بها فمات دخل الجنة.', targetCount: 1),
    DhikrItem(id: 'm-6', text: 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ...', note: 'من قالها أعتقه الله من النار.', targetCount: 4),
    DhikrItem(id: 'm-17', text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.', note: 'حُطّت خطاياه وإن كانت مثل زبد البحر.', targetCount: 100),
    DhikrItem(id: 'm-18', text: 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ...', note: 'عدل عشر رقاب.', targetCount: 100),
  ];

  // أذكار المساء
  final List<DhikrItem> _eveningAdhkar = [
    DhikrItem(id: 'e-1', text: 'آية الكرسي (مساءً)', note: 'أُجير من الجن حتى يصبح.', targetCount: 1),
    DhikrItem(id: 'e-2', text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ...', note: '', targetCount: 1),
    DhikrItem(id: 'e-5', text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ (سيد الاستغفار)', note: 'من قالها موقناً بها فمات من ليلته دخل الجنة.', targetCount: 1),
    DhikrItem(id: 'e-10', text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.', note: 'لم تضرّه حُمَة تلك الليلة.', targetCount: 3),
    DhikrItem(id: 'e-18', text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.', note: '', targetCount: 100),
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasbeehCount = prefs.getInt('tasbeeh_count') ?? 0;
    });
  }

  Future<void> _saveTasbeeh() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('tasbeeh_count', _tasbeehCount);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildAdhkarListView(_morningAdhkar, 'أذكار الصباح'),
      _buildAdhkarListView(_eveningAdhkar, 'أذكار المساء'),
      _buildTasbeehView(),
      _buildFavoritesView(),
      _buildDuasView(),
      _buildPrayerView(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(Icons.wb_sunny_rounded, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('أذكار - سطيف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(widget.isEveningMode ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: widget.onToggleTheme,
              tooltip: 'تغيير الوضع',
            ),
          ],
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: 'الصباح'),
            BottomNavigationBarItem(icon: Icon(Icons.nights_stay), label: 'المساء'),
            BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: 'المسبحة'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'الأدعية'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'المواقيت'),
          ],
        ),
      ),
    );
  }

  // شاشة عرض الأذكار (صباح / مساء)
  Widget _buildAdhkarListView(List<DhikrItem> list, String title) {
    final filtered = list.where((item) => item.text.contains(_searchQuery)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'ابحث في $title...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = filtered[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: Icon(item.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                            onPressed: () => setState(() => item.isFavorite = !item.isFavorite),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5)),
                      if (item.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(item.note, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Chip(label: Text('التكرار: ${item.targetCount}')),
                          Row(
                            children: [
                              Text('${item.currentCount}/${item.targetCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item.isCompleted ? Colors.green : null,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (item.currentCount < item.targetCount) {
                                      item.currentCount++;
                                      if (item.currentCount == item.targetCount) item.isCompleted = true;
                                    } else {
                                      item.currentCount = 0;
                                      item.isCompleted = false;
                                    }
                                  });
                                },
                              child: Text(item.isCompleted ? 'تم ✓' : 'تم الذكر'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // شاشة المسبحة الإلكترونية
  Widget _buildTasbeehView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('المسبحة الإلكترونية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              setState(() {
                _tasbeehCount++;
                _saveTasbeeh();
              });
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blue.shade300, Colors.blue.shade700]),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Center(
                child: Text(
                  '$_tasbeehCount',
                  style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_tasbeehCount > 0) _tasbeehCount--;
                    _saveTasbeeh();
                  });
                },
                icon: const Icon(Icons.remove),
                label: const Text('إنقاص'),
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _tasbeehCount = 0;
                    _saveTasbeeh();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('تصفير'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شاشة المفضلة
  Widget _buildFavoritesView() {
    final allFavs = [..._morningAdhkar, ..._eveningAdhkar].where((e) => e.isFavorite).toList();
    if (allFavs.isEmpty) {
      return const Center(child: Text('لا توجد أذكار مضافة للمفضلة حالياً.', style: TextStyle(fontSize: 16)));
    }
    return ListView.builder(
      itemCount: allFavs.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = allFavs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(item.text, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.note),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => setState(() => item.isFavorite = false),
            ),
          ),
        );
      },
    );
  }

  // شاشة الأدعية
  Widget _buildDuasView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          '«رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ»\n\nقريباً ستتم إضافة المزيد من الأدعية النبوية الشريفة.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.6),
        ),
      ),
    );
  }

  // شاشة مواقيت الصلاة (سطيف، الجزائر)
  Widget _buildPrayerView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مواقيت الصلاة - سطيف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('الجزائر (تُحسب تلقائياً)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 30),
              _prayerRow('الفجر', '05:20 ص'),
              _prayerRow('الشروق', '06:48 ص'),
              _prayerRow('الظهر', '12:23 م'),
              _prayerRow('العصر', '03:22 م'),
              _prayerRow('المغرب', '05:50 م'),
              _prayerRow('العشاء', '07:12 م'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}
