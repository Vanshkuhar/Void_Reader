import 'package:epuber/Home%20Page/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/provider.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EpubReaderProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

final ThemeData light = ThemeData(
        bottomAppBarTheme: BottomAppBarTheme(
          color:Color.fromRGBO(255, 255, 255, 1),),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              iconColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(0, 0, 0, 1)),
            ),
          ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 1),
            fontFamily: 'Merriweather'
            
          )
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBarTheme: AppBarTheme(
          titleTextStyle : TextStyle(fontFamily: 'SFPRODISPLAY', 
          color: Color.fromRGBO(0, 0, 0, 1)),
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          foregroundColor: Color.fromRGBO(0, 0, 0, 1)

        ),
        drawerTheme:DrawerThemeData(
          
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          shape:RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.zero)

          )
        )
      );



final ThemeData dark = ThemeData(
          bottomAppBarTheme: BottomAppBarTheme(
            color:Color.fromARGB(255, 22, 23, 23),
            
          ),
           iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              iconColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(255, 255, 255, 1)),
            ),
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontFamily: 'Merriweather'
              
            )
          ),
          scaffoldBackgroundColor: Color.fromARGB(255, 22, 23, 23),
          appBarTheme: AppBarTheme(
            titleTextStyle : TextStyle(fontFamily: 'SFPRODISPLAY'),
            backgroundColor: Color.fromARGB(255, 22, 23, 23),
            foregroundColor: Color.fromRGBO(220,220,220, 1)
      
          ),
          drawerTheme:DrawerThemeData(
      
            backgroundColor: Color.fromARGB(255, 22, 23, 23),
            shape:RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.zero)
      
            )
          )
        );


  // This widget is the root of your application.
 
  @override
  Widget build(BuildContext context) {
     
   return Consumer2<EpubReaderProvider, ThemeProvider>(
    builder: (context, readerProvider, themeProvider, child) {
        return MaterialApp(
        

        
        theme: light,
      darkTheme: dark,
      themeMode: themeProvider.themeMode,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: Librarypage());
    });}
   
}