import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CounselorScreen extends StatelessWidget {
  const CounselorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> counselors = [
      {
        "name": "Astro Meena",
        "expertise": "Love & Marriage",
        "image": "https://cdn-icons-png.flaticon.com/512/4140/4140037.png",
      },
      {
        "name": "Pandit Rajesh",
        "expertise": "Career & Finance",
        "image": "https://cdn-icons-png.flaticon.com/512/4140/4140061.png",
      },
      {
        "name": "Guru Aditi",
        "expertise": "Health & Peace",
        "image": "https://cdn-icons-png.flaticon.com/512/4140/4140048.png",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF7F6FF),
      appBar: AppBar(
        title: Text(
          "Astro Counselors",
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: const Color(0xff1D1442),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xff3B3B98)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: counselors.length,
        itemBuilder: (context, index) {
          final c = counselors[index];
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.9, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xffE9E7FD), const Color(0xffF3EDFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xff3B3B98).withOpacity(0.1),
                  backgroundImage: NetworkImage(c["image"]!),
                ),
                title: Text(
                  c["name"]!,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xff1D1442),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    c["expertise"]!,
                    style: GoogleFonts.dmSans(
                      color: Colors.grey.shade700,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3B3B98),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 17,
                  ),
                  label: Text(
                    "Chat",
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
