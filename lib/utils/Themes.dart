import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstant {
  static String AppMainName = "Weather Guy";
  static String AppPoweredBy = "Powered by wahab";
  static Color primary2 = const Color(0xFF63EB6A);
  static Color primary = const Color.fromARGB(255, 56, 177, 62);
  static String domain = "3.109.157.254:3000";
  static String domain2 = "192.168.18.37:3000";
}

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        brightness: Brightness.light,
        primaryColorLight: const Color.fromARGB(255, 165, 165, 165),
        primaryColorDark: Colors.black,
        primaryColor: const Color.fromARGB(255, 56, 177, 62),
        canvasColor: const Color.fromARGB(255, 236, 243, 234),
        cardColor: Colors.white,
        highlightColor: const Color.fromARGB(255, 46, 128, 50),
        shadowColor: const Color.fromARGB(255, 46, 128, 73),
        indicatorColor: const Color.fromARGB(255, 250, 242, 255),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppConstant.primary,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.black,
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(color: Colors.black),
          ),
        ),
      );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.poppins().fontFamily,
        primaryColor: const Color.fromARGB(255, 99, 235, 106),
        primaryColorDark: Colors.white,
        primaryColorLight: const Color.fromARGB(255, 189, 189, 189),
        canvasColor: const Color.fromARGB(255, 22, 22, 22),
        cardColor: const Color.fromARGB(255, 27, 27, 27),
        highlightColor: Colors.white,
        shadowColor: const Color.fromARGB(255, 19, 18, 18),
        indicatorColor: const Color.fromARGB(255, 82, 82, 82),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppConstant.primary,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(color: Colors.white),
          ),
        ),
      );
}
