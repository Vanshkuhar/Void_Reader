import 'dart:typed_data';
import 'package:epub_decoder/models/models.dart';
import 'package:epuber/EpubReader/epub_reader_screen.dart';
import 'package:flutter/material.dart' hide ImageInfo;
import 'package:epub_decoder/epub_decoder.dart' as epu;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../Content Extraction/image_service.dart';
import '../Provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:archive/archive_io.dart';

class Dcoder extends StatefulWidget {
  final String filepath;
  
  const Dcoder({
    super.key,
    required this.filepath,
  });

  @override
  State<Dcoder> createState() => _DcoderState();
}

class _DcoderState extends State<Dcoder> {
  String title = 'Title will be here';
  String? cover = 'hello';
  String ite = 'hi';
  Uint8List? bytes;
  Item? coverItem;
  bool isLoading = true;
  String author = "";
  List<String> files = [];

  @override
  void initState() {
    super.initState();
    debugPath();
    loader(widget.filepath);
  }

  Future<void> debugPath() async {
    final appDir = await getExternalStorageDirectory();
    print('App directory: ${appDir?.path}');
    
    // List ALL files
    final dir = Directory(appDir!.path);
    print('All files in directory:');
    await for (var entity in dir.list()) {
      final stat = await entity.stat();
      print('${entity.path} (${stat.size} bytes)');
    }
  }

  // In-memory patch loader
  Future<epu.Epub> loadPatchedEpub(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final patchedArchive = Archive();

    for (final f in archive) {
      if (f.isFile && f.name.toLowerCase().endsWith('.opf')) {
        final content = String.fromCharCodes(f.content);
        final patchedContent = content.replaceAll('%20', ' ');
        final modified = Uint8List.fromList(patchedContent.codeUnits);
        patchedArchive.addFile(ArchiveFile(f.name, modified.length, modified)
          ..mode = f.mode
          ..lastModTime = f.lastModTime);
      } else {
        patchedArchive.addFile(f);
      }
    }

    final patchedBytes = ZipEncoder().encode(patchedArchive)!;
    final asUint8List = Uint8List.fromList(patchedBytes);
    return epu.Epub.fromBytes(asUint8List);
  }

  // The loader itself
  Future<void> loader(String filepath) async {
    try {
      final file = File(filepath);
      print(await file.exists());

      epu.Epub? epub;
      try {
        epub = await loadPatchedEpub(file);
        print('Parsed EPUB with manifest patch');
      } catch (e) {
        print('Patch failed, falling back to original EPUB loader: $e');
        epub = epu.Epub.fromFile(file);
      }

      // Extract all images with robust normalization/fuzzy logic
      final extractedImages = await ImageService.extractAllImages(epub);

      // Find cover image by all normalized/fuzzy means
      Uint8List? coverBytes;
      if (epub.cover?.href != null) {
        final coverInfo = ImageService.findImageByPath(epub.cover!.href, extractedImages);
        coverBytes = coverInfo?.data;
      }

      // Fallback: use first available image if cover not found
      if (coverBytes == null && extractedImages.isNotEmpty) {
        coverBytes = extractedImages.values.first.data;
      }

      setState(() {
        title = epub!.title;
        coverItem = epub.cover;
        bytes = coverBytes;
        print('Cover bytes length: ${bytes?.length}');
        isLoading = false;
        author = epub.authors.join(', ');
      });
    } catch (e) {
      print('Error loading EPUB: $e');
      setState(() {
        isLoading = false;
        title = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EpubReaderProvider, ThemeProvider>(
      builder: (context, readerProvider, themeProvider, child) {
        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              'File Details',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SFPRODISPLAY',
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            subtitle: Text(
                              '${widget.filepath}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'SFPRODISPLAY',
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 3,
                            ),
                            leading: Icon(
                              Icons.folder,
                              color: Theme.of(context).iconButtonTheme.style?.iconColor?.resolve({}),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Title',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SFPRODISPLAY',
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            subtitle: Text(
                              title,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'SFPRODISPLAY',
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            leading: Icon(
                              Icons.book,
                              color: Theme.of(context).iconButtonTheme.style?.iconColor?.resolve({}),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Author',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SFPRODISPLAY',
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            subtitle: Text(
                              author,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'SFPRODISPLAY',
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).iconButtonTheme.style?.iconColor?.resolve({}),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete file?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await File(widget.filepath).delete();
                                Navigator.pop(context);

                                // Get provider and remove from list
                                final epubProvider = Provider.of<EpubReaderProvider>(context, listen: false);
                                List<String> updatedFiles = List.from(epubProvider.files);
                                updatedFiles.remove(widget.filepath);

                                // Update provider immediately
                                epubProvider.filesSetter(updatedFiles);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Screen(filepath: widget.filepath),
                    ),
                  );
                },
                child: Card(
                  color: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      bytes != null
                          ? Column(
                              children: [
                                Image.memory(
                                  bytes!,
                                  fit: BoxFit.contain,
                                  height: 200,
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 200,
                              child: const Text('No cover'),
                            ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Spacer(),
                          Container(
                            padding: EdgeInsets.all(4),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  offset: Offset.fromDirection(11, 1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ],
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Theme.of(context).textTheme.bodyMedium!.color,
                                    fontFamily: 'SFPRODISPLAY',
                                  ),
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Center(
                                  child: Text(
                                    '$author',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium!.color,
                                      fontSize: 7,
                                      fontFamily: 'SFPRODISPLAY',
                                    ),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
