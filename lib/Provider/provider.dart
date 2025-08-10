// import 'package:flutter/foundation.dart';

// import 'package:flutter/material.dart';
// import 'shared_pref.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class EpubReaderProvider extends ChangeNotifier {
//   double _scrollProgress = 0.0;
//   int _currentSection = 0;
//   bool _isFullscreen = false;
//   double bookmarkScrollProgress = 0;
//   double bookmarkSection = 0;
//    String? _currentFilename;
//    List<String> files = [];


//    int _fileIndex = 0;
//     int get fileIndex => _fileIndex;


//     Future<void> filesSetter(List<String> files) async {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setStringList('files', files) ;
//       files = prefs.getStringList('files')!;
//       notifyListeners();
//     }

// Future<void> filesGetter() async {
//       final prefs = await SharedPreferences.getInstance();
      
//       files = prefs.getStringList('files')!;
      
//     }



//      Future <void> updateIndex(int index) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setInt('fileIndex', index + 1);
//   notifyListeners();
    
//   }

//   Future <void> getIndex() async {
//   final prefs = await SharedPreferences.getInstance();
//   _fileIndex = await prefs.getInt('fileIndex') ?? 0;
//   notifyListeners();
    
//   }



//   double get scrollProgress => _scrollProgress;
//   int get currentSection => _currentSection;
//   bool get isFullscreen => _isFullscreen;
// String? get currentFilename => _currentFilename;


// EpubReaderProvider(){
//   getBookmark();
//   getIndex();
//   filesGetter();
// }

// Future<void> getBookmark() async {
//   final prefs = await SharedPreferences.getInstance();
//   bookmarkSection = prefs.getDouble('$currentFilename page index')?? 0;
//   bookmarkScrollProgress = prefs.getDouble('$currentFilename Scroll progress')?? 0;
//   notifyListeners();
  
//  }


   
// void setCurrentFilename(String filename) {
//     _currentFilename = filename;
//     notifyListeners();
//   }

//    // Update scroll progress without rebuilding entire widget tree
//  Future <void> updateScrollProgress(double progress, double page) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setDouble('$currentFilename page index', page);
//   bookmarkSection = prefs.getDouble('$currentFilename page index')?? 0;
//   await prefs.setDouble('$currentFilename Scroll progress', progress);
//   bookmarkScrollProgress = prefs.getDouble('$currentFilename Scroll progress')?? 0;
//   notifyListeners();
    
//   }

//    // Update current section
//   void updateCurrentSection(int section) {
//     if (_currentSection != section) {
//       _currentSection = section;
//       notifyListeners();
//     }
//   }
  
//   // Toggle fullscreen
//   void toggleFullscreen() {
//     _isFullscreen = !_isFullscreen;
//     notifyListeners();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class ThemeProvider extends ChangeNotifier {

  double _fontSize = 14;
double get fontSize => _fontSize;
bool _justified = false;
bool get justified => _justified;


ThemeMode _themeMode = ThemeMode.light;

ThemeMode get themeMode => _themeMode;

void toggleTheme() {
  _themeMode = (_themeMode == ThemeMode.light)
      ? ThemeMode.dark
      : ThemeMode.light;
  setTheme(_themeMode); // Pass the theme mode directly
}

void setTheme(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme', mode == ThemeMode.dark ? 'dark' : 'light');
  _themeMode = mode;
  notifyListeners();
}

void getTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('theme') ?? 'light'; // Add null safety
  _themeMode = (themeString == 'dark')
      ? ThemeMode.dark
      : ThemeMode.light;
  notifyListeners();
}



Future<void> loadAlignment() async {
  final prefs = await SharedPreferences.getInstance();
  _justified = prefs.getBool('justified') ?? false ;
  notifyListeners();
}

Future<void> setAlignment() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('justified', !_justified);
  _justified = !_justified;
  notifyListeners();
}


ThemeProvider(){
  // Constructor calls getFontSize when provider is created
  getFontSize();
  loadAlignment();
  getTheme();
}




  Future<void> getFontSize() async {
  final prefs = await SharedPreferences.getInstance();
  _fontSize = prefs.getDouble('fontSize') ?? 14 ;
  notifyListeners();
  
 }
 Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    _fontSize = size;
    notifyListeners();
  }

  
  
  
 double margins = 1;
 final  startAlign = TextAlign.start;
 final  justifyAlign = TextAlign.start;





}



class EpubReaderProvider extends ChangeNotifier {
  // State fields
  double _scrollProgress = 0.0;
  int _currentSection = 0;
  bool _isFullscreen = false;
  double bookmarkScrollProgress = 0;
  double bookmarkSection = 0;
  String? _currentFilename;
  List<String> files = [];
  int _fileIndex = 0;

  int get fileIndex => _fileIndex;

  EpubReaderProvider() {
    getBookmark();
    getIndex();
    filesGetter();
  }

  // -- FILES --
  Future<void> filesSetter(List<String> newFiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('files', newFiles);
    files = newFiles;
    notifyListeners();
  }

  Future<void> filesGetter() async {
    final prefs = await SharedPreferences.getInstance();
    files = prefs.getStringList('files') ?? [];
    notifyListeners();
  }

  // -- FILE INDEX --
  Future<void> updateIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fileIndex', index + 1);
    _fileIndex = index + 1;
    notifyListeners();
  }

  Future<void> getIndex() async {
    final prefs = await SharedPreferences.getInstance();
    _fileIndex = prefs.getInt('fileIndex') ?? 0;
    notifyListeners();
  }

  // -- BOOKMARK --
  Future<void> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    bookmarkSection = prefs.getDouble('$_currentFilename page index') ?? 0;
    bookmarkScrollProgress = prefs.getDouble('$_currentFilename Scroll progress') ?? 0;
    notifyListeners();
  }

  // -- FILENAME --
  String? get currentFilename => _currentFilename;

  void setCurrentFilename(String? filename) {
    _currentFilename = filename;
    notifyListeners();
  }

  // -- UI STATE --
  double get scrollProgress => _scrollProgress;
  int get currentSection => _currentSection;
  bool get isFullscreen => _isFullscreen;

  Future<void> updateScrollProgress(double progress, double page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_currentFilename page index', page);
    bookmarkSection = prefs.getDouble('$_currentFilename page index') ?? 0;
    await prefs.setDouble('$_currentFilename Scroll progress', progress);
    bookmarkScrollProgress = prefs.getDouble('$_currentFilename Scroll progress') ?? 0;
    notifyListeners();
  }

  void updateCurrentSection(int section) {
    if (_currentSection != section) {
      _currentSection = section;
      notifyListeners();
    }
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }
}
