import 'package:flutter/material.dart';
import 'package:zr3te/Navigation%20Bar%20Pages/myplants_page.dart';
import 'Main Pages/camera_page.dart';
import 'Main Pages/chatbot_page.dart';
import 'Main Pages/splash_screen.dart';
import 'Navigation Bar Pages/info_page.dart';
import 'Widgets/bnb_custom_painter.dart';
import 'Widgets/care_tool_card.dart';
import 'Widgets/custom_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Set the initial index to 0 (HomePage)
  late PageController _pageController;
  String _appBarTitle = 'Home';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _updateAppBarTitle(index);
    });

    _pageController.jumpToPage(index);
  }

  void _updateAppBarTitle(int index) {
    switch (index) {
      case 0:
        _appBarTitle = 'Home';
        break;
      case 1:
        _appBarTitle = 'My Plants';
        break;
      case 2:
        _appBarTitle = 'Info';
        break;
      case 3:
        _appBarTitle = 'Profile';
        break;
      default:
        _appBarTitle = 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                spreadRadius: 8,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _appBarTitle,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _updateAppBarTitle(index);
          });
        },
        children: [
          _buildHomePageContent(),
          const MyPlantsPage(),
          const InfoPage(),
          const Center(child: Text('Profile Page')),
        ],
      ),
      bottomNavigationBar: SizedBox(
        width: size.width,
        height: 80,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size.width, 80),
              painter: BNBCustomPainter(),
            ),
            Center(
              heightFactor: 0.6,
              child: SizedBox(
                width: 62,
                height: 62,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      _fadeAndScaleTransitionRoute(const CameraPage()),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 44, 188, 169),
                  elevation: 0.1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(35)),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavBarItem(
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: _selectedIndex == 0,
                  ),
                  _buildNavBarItem(
                    icon: Icons.history,
                    label: 'My Plants',
                    index: 1,
                    isSelected: _selectedIndex == 1,
                  ),
                  Container(width: size.width * .20),
                  _buildNavBarItem(
                    icon: Icons.info_outline,
                    label: 'Info',
                    index: 2,
                    isSelected: _selectedIndex == 2,
                  ),
                  _buildNavBarItem(
                    icon: Icons.account_circle,
                    label: 'Profile',
                    index: 3,
                    isSelected: _selectedIndex == 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePageContent() {
    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(255, 246, 246, 246),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              title: 'Diagnose',
              icon: Icons.camera_alt_outlined,
              color: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  _fadeAndScaleTransitionRoute(const CameraPage()),
                );
              },
              imagePath: 'assets/best.png',
            ),
            const SizedBox(height: 16),
            CustomCard(
              title: 'ChatBot',
              icon: Icons.chat_outlined,
              color: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  _fadeAndScaleTransitionRoute(const ChatPage()),
                );
              },
              imagePath: 'assets/2.png',
            ),
            const SizedBox(height: 32),
            const Text(
              'Care Tools',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CareToolCard(
                      title: 'Water',
                      icon: Icons.alarm,
                      color: Colors.white,
                      onTap: () {
                        // Handle Water action
                      },
                      imagePath: 'assets/water.png',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CareToolCard(
                      title: 'Sunlight',
                      icon: Icons.wb_sunny,
                      color: Colors.white,
                      onTap: () {
                        // Handle Sunlight action
                      },
                      imagePath: 'assets/sun.png',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    double iconSize = 29,
    double textSize = 15,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            _onItemTapped(index);
          },
          icon: Icon(
            icon,
            color: isSelected
                ? const Color.fromARGB(255, 44, 188, 169)
                : Colors.grey,
            size: iconSize,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color.fromARGB(255, 44, 188, 169)
                    : Colors.grey,
                fontSize: textSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  PageRouteBuilder _fadeAndScaleTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var fadeTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var fadeAnimation = animation.drive(fadeTween);
        var scaleAnimation = animation.drive(scaleTween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
