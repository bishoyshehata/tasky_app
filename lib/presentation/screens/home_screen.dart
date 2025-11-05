import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                          'Good Evening ,Bishoy ',
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
    );
  }
}
