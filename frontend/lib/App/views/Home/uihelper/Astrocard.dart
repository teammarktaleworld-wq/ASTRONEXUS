import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AstrologerSuggestionCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final VoidCallback onChat;

  const AstrologerSuggestionCard({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            price,
            style: GoogleFonts.dmSans(
              color: Color(0xff17313E),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            child: ElevatedButton(
              onPressed: onChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff386641),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
              ),
              child: Text(
                'Chat',
                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
