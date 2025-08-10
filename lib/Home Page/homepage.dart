import 'package:epuber/EpubReader/FileCard.dart';
import 'package:flutter/material.dart' hide ImageInfo;
import '../Provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class Librarypage extends StatefulWidget {
  const Librarypage({super.key});

  @override
  State<Librarypage> createState() => _LibrarypageState();
}

class _LibrarypageState extends State<Librarypage> {
  List<String> files = [];

  Future<void> saveFileToAppDirectory(BuildContext context) async {
    final epubProvider = Provider.of<EpubReaderProvider>(context, listen: false);

    try {
      // 1. Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
        withData: true,
      );
      if (result == null) return; // User cancelled

      // 2. Get file data
      Uint8List? fileBytes = result.files.single.bytes;
      String originalFileName = result.files.single.name;
      if (fileBytes == null && result.files.single.path != null) {
        fileBytes = await File(result.files.single.path!).readAsBytes();
      }
      if (fileBytes == null) return;

      // 3. Get app directory and filepath
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;
      String filePath = '${directory.path}/$originalFileName';

      // 4. Save file with error handling
      await File(filePath).writeAsBytes(fileBytes);

      // Verify saved file size
      final savedFile = File(filePath);
      final length = await savedFile.length();
      print('File saved: $originalFileName at $filePath - Size: $length bytes');
      if (length != fileBytes.length) {
        print('Warning: saved file size differs from original bytes.');
      }

      // 5. Refresh files list AFTER saving
      final List<String> fileNames = [];
      await for (var entity in Directory(directory.path).list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.epub')) {
          fileNames.add(entity.path);
        }
      }

      // 6. Update state and provider
      setState(() {
        files = fileNames;
      });
      epubProvider.filesSetter(fileNames);
      await epubProvider.updateIndex(epubProvider.fileIndex);
      epubProvider.setCurrentFilename(originalFileName);
      print('File saved successfully: $originalFileName at $filePath');
    } catch (e) {
      print('Error picking or saving file: $e');
    }
  }

  Future<void> refreshFiles() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      final List<String> fileNames = [];
      await for (var entity in Directory(directory.path).list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.epub')) {
          fileNames.add(entity.path);
        }
      }

      setState(() {
        files = fileNames;
      });

      final epubProvider = Provider.of<EpubReaderProvider>(context, listen: false);
      epubProvider.filesSetter(fileNames);
    } catch (e) {
      print('Error refreshing files: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will refresh files whenever the page becomes visible again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshFiles();
    });
  }

  @override
Widget build(BuildContext context) {
  return Consumer2<EpubReaderProvider, ThemeProvider>(
    builder: (context, readerProvider, themeProvider, child) {
      final hasFiles = readerProvider.files.isNotEmpty;

      return Scaffold(
        appBar: AppBar(
          title: Text('My books'),
          centerTitle: true,
          actions: [
            TextButton.icon(
              onPressed: () {
                saveFileToAppDirectory(context);
              },
              label: Text('Import book'),
              icon: Icon(Icons.add),
            ),
          ],
        ),
        body: hasFiles
            ? Padding(
                padding: EdgeInsets.only(left: 60, right: 60, top: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  children: List.generate(
                    readerProvider.files.length,
                    (index) => Dcoder(filepath: readerProvider.files[index]),
                  ),
                ),
              )
            : Center(
                child: Text(
                  'Import your first book to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
      );
    },
  );
}

}
