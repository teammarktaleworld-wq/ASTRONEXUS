import 'package:flutter/material.dart';
import 'package:astro_tale/core/responsive/responsive.dart';

import 'custompara.dart';
import 'customtext.dart';

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.text,
    required this.bg,

    required this.ontap,
    required this.paratext,
  });

  final String text;
  final Color bg;
  final VoidCallback ontap;
  final String paratext;

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = context.isSmallPhone;
    final panelHeight = context.responsiveValue(
      mobile: 300,
      tablet: 340,
      desktop: 360,
    );
    final sideInset = context.responsiveValue(
      mobile: 20,
      tablet: 28,
      desktop: 36,
    );

    return Container(
      width: double.infinity,
      height: panelHeight,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: sideInset, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Customtext(text: text, color: Color(0xffFFB200)),
          ),
          const SizedBox(height: 20),
          Center(child: Custompara(text: paratext)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(width: isSmallPhone ? 60 : 110),
              const Customtext(text: 'skip', color: Color(0xffFFB200)),
              const SizedBox(width: 8),
              const Icon(Icons.double_arrow_rounded, color: Color(0xffFFB400)),
              SizedBox(width: isSmallPhone ? 20 : 50),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                child: InkWell(
                  onTap: ontap,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xffFF7D00), Color(0xffFFB400)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
