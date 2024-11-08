import 'package:flutter/material.dart';
import 'package:flutter_medicine/global_bloc.dart';
import 'package:flutter_medicine/pages/home_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalBloc? globalBloc;

  @override
  void initState() {
    globalBloc = GlobalBloc();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>.value(
      value: globalBloc!,
      child: Sizer(builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'DoseElegance',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            primaryColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              toolbarHeight: 7.h,
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.red,
                size: 25.sp,
              ),
              titleTextStyle: TextStyle(
                  color: const Color.fromARGB(255, 39, 33, 33),
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.sp),
            ),
            textTheme: TextTheme(
              headlineMedium: TextStyle(
                  fontSize: 28.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w400),
              headlineLarge: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: const Color.fromARGB(255, 39, 33, 33),
              ),
              headlineSmall: TextStyle(
                fontSize: 14.sp,
                color: const Color.fromARGB(255, 39, 33, 33),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              labelMedium: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 59, 45, 45)),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 36, 81, 117),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 36, 81, 117),
                ),
              ),
            ),
          ),
          home: const HomePage(),
        );
      }),
    );
  }
}
