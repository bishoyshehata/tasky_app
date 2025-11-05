import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/file.jpg'),
                  ),
                  SizedBox(width: 4),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Evening ,$name ',
                          style: TextStyle(
                            color: Color(0xffFFFCFC),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'One task at a time.One step closer.',
                          style: TextStyle(
                            color: Color(0xffC6C6C6),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Color(0xff282828),
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.light_mode, color: Color(0xffFFFCFC)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Yuhuu ,Your work Is ',
                style: TextStyle(color: Color(0xffFFFCFC), fontSize: 30),
              ),
              Row(
                children: [
                  Text(
                    'almost done ! ',
                    style: TextStyle(color: Color(0xffFFFCFC), fontSize: 30),
                  ),
                  SvgPicture.asset(
                    'assets/images/hand.svg',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},

        backgroundColor: const Color(0xff15B86C),
        foregroundColor: Color(0xffFFFCFC),
        label: const Text(
          '+ Add New Task',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
