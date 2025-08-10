import 'dart:typed_data';
import 'package:flutter/material.dart'  hide ImageInfo;
import 'package:epub_decoder/epub_decoder.dart' as epu;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'epub_models.dart';
import 'epub_service.dart';
import 'image_service.dart';
import 'epub_content_widget.dart';
import 'epub_drawer.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';



class Screen extends StatefulWidget {
  final String filepath;
  const Screen({super.key,
  required this.filepath });

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> with TickerProviderStateMixin {
  // State variables
  Uint8List? sections;
  int? sectionno;
  var indexsection;
  bool _isLoading = true;
  Map<String, ImageInfo> extractedImages = {};
  List<TocEntry> tocEntries = [];
  epu.Epub? epub;
  String title = 'Unknown title';
  bool isNavigating = false;
  double currentSection = 0;
  double scrollProgress = 0;
  
  // Controllers
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);

  late AnimationController _appBarAnimationController;
late Animation<Offset> _appBarSlideAnimation;



  @override
  void initState() {
    super.initState();


     // Initialize animation controller
  _appBarAnimationController = AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this, // You'll need to add TickerProviderStateMixin
  );
  
  _appBarSlideAnimation = Tween<Offset>(
    begin: Offset(0, -1), // Start above screen
    end: Offset.zero,     // End at normal position
  ).animate(CurvedAnimation(
    parent: _appBarAnimationController,
    curve: Curves.easeInOut,
  ));
    loader(widget.filepath);
    
    scrollController.addListener(_updateScrollProgress);
    scrollController.addListener(updatescrollProgress);
    pageController.addListener(updateCurrentSection);

  }

// Add this method to listen for fullscreen changes
void _handleFullscreenChange(bool isFullscreen) {
  if (isFullscreen) {
    _appBarAnimationController.forward();
  } else {
    _appBarAnimationController.reverse();
  }
}

void updatescrollProgress(){
  if(pageController.hasClients){
    scrollProgress = scrollController.offset;
  }
}

  void updateCurrentSection(){
    if(pageController.hasClients){
      currentSection = pageController.page ?? 0; 
    }
  }

  void _updateScrollProgress() {
    if (scrollController.hasClients) {
      progressNotifier.value = scrollController.position.pixels /
          scrollController.position.maxScrollExtent;
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    scrollController.removeListener(_updateScrollProgress);
    scrollController.dispose();
    progressNotifier.dispose();
    super.dispose();
  }


Future<epu.Epub> loadPatchedEpub(File file) async {
  final bytes = await file.readAsBytes();
  
  // Decode original ZIP archive
  final archive = ZipDecoder().decodeBytes(bytes);

  // Create new Archive object in memory for modified EPUB
  final patchedArchive = Archive();

  for (final file in archive) {
    if (file.isFile && file.name.toLowerCase().endsWith('.opf')) {
      // Found an OPF manifest file - patch it
      
      final content = String.fromCharCodes(file.content as List<int>);
      
      // Replace all '%20' (percent-encoded spaces) with actual spaces
      final patchedContent = content.replaceAll('%20', ' ');
      
      final patchedBytes = Uint8List.fromList(patchedContent.codeUnits);

      // Add patched manifest file to new archive
      patchedArchive.addFile(ArchiveFile(file.name, patchedBytes.length, patchedBytes)
        ..mode = file.mode
        ..lastModTime = file.lastModTime);
    } else {
      // Copy other files unchanged
      patchedArchive.addFile(file);
    }
  }

  final patchedBytes = ZipEncoder().encode(patchedArchive)!;
// Convert List<int> to Uint8List
final asUint8List = Uint8List.fromList(patchedBytes);
// Pass patched bytes to EPUB parser (no file is modified on disk)
return epu.Epub.fromBytes(asUint8List);

}





  Future<void> loader(String filepath) async {
  setState(() {
    _isLoading = true;
  });

  final file = File(filepath);
  if (!await file.exists()) {
    throw Exception('File does not exist: $filepath');
  }

  try {
    // Use patched loader first (in-memory patch of OPF)
    final epub = await loadPatchedEpub(file);
    print('✅ Parsed patched EPUB successfully');

    // Proceed with your existing flow...
    extractedImages = await ImageService.extractAllImages(epub);
    tocEntries = await EpubService.extractTableOfContents(epub);

    setState(() {
      this.epub = epub;
      indexsection = epub.sections;
      sectionno = epub.sections.length;
      title = epub.title;
      _isLoading = false;
    });
  } catch (e) {
    print('⚠️ Failed loading patched EPUB: $e');

    // Fallback to your original loader methods if patching fails
    try {
      final epub = epu.Epub.fromFile(file);
      print('✅ Parsed EPUB with fromFile fallback');
      extractedImages = await ImageService.extractAllImages(epub);
      tocEntries = await EpubService.extractTableOfContents(epub);

      setState(() {
        this.epub = epub;
        indexsection = epub.sections;
        sectionno = epub.sections.length;
        title = epub.title;
        _isLoading = false;
      });
    } catch (e2) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Failed to load EPUB: $e2');
    }
  }
}


  void navigateToTocEntry(TocEntry entry) {
    print('🎯 Navigating to: ${entry.title} (Section ${entry.sectionIndex})');

    setState(() {
      isNavigating = true;
    });

    pageController.jumpToPage(
      entry.sectionIndex,
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.easeInOut,
    );

    setState(() {
      isNavigating= false;
    });

    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    // final uniqueImages = extractedImages.values.toSet().length;

   return Consumer2<EpubReaderProvider, ThemeProvider>(
    builder: (context, readerProvider, themeProvider, child) {
    // Trigger animation when fullscreen state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFullscreenChange(readerProvider.isFullscreen);
    });
        return Scaffold(
          // endDrawer:Drawer(),

          bottomNavigationBar: readerProvider.isFullscreen
              ? BottomAppBar(
                
            elevation: 10,
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // mainAxisAlignment : MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(onPressed: (){setState(() {
                  themeProvider.toggleTheme();
                });}, 
                icon:
                Icon(Icons.sunny,
                color:Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({}))
                ),
                IconButton(
                  style: ButtonStyle(
                    
                  ), onPressed: () {
                  updateCurrentSection();
                  updatescrollProgress();
                  readerProvider.updateScrollProgress(scrollProgress, currentSection);
                  print(readerProvider.bookmarkScrollProgress);
                  print(readerProvider.bookmarkSection);


                  }, icon: Icon( Icons.bookmark_add_outlined, 
                color: Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({}))),
                IconButton(onPressed: (){
                  Provider.of<ThemeProvider>(context, listen : false).setAlignment();
                }, icon: Icon(themeProvider.justified ? Icons.format_align_justify : Icons.format_align_left,
                color: Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({}))),
                IconButton(onPressed: (){
                   Provider.of<ThemeProvider>(context, listen: false ).setFontSize(themeProvider.fontSize + 0.5);
                   print('Test: Set font size to 5');
                }, icon: Icon(Icons.text_increase,
                color: Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({})),
                ),
                IconButton(onPressed: (){
                   Provider.of<ThemeProvider>(context, listen: false ).setFontSize(themeProvider.fontSize - 0.5);
                }, icon: Icon(Icons.text_decrease,
                color: Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({})),)
              ],
            ),
          ) : null,
          // Floating Action Button

          // floatingActionButton: IconButton(
          //   onPressed: () {
          //     setState(() {
          //       readerProvider.toggleFullscreen();
          //     });
          //   },
          //   icon: readerProvider.isFullscreen
          //       ? Icon(Icons.fullscreen)
          //       : Icon(Icons.fullscreen_exit),
          // ),

          // App Bar
          appBar: readerProvider.isFullscreen
    ? PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: _appBarSlideAnimation,
          child: AppBar(
            centerTitle: true,
            title: Text('$title'),
            actions: [
              IconButton(
                icon: Icon(Icons.bookmark),
                onPressed: () async {
                  pageController.jumpToPage(readerProvider.bookmarkSection.toInt());
                  scrollController.jumpTo(1.0);
                  await Future.delayed(Duration(milliseconds: 100));
                  scrollController.jumpTo(readerProvider.bookmarkScrollProgress);
                }
              )
            ]
          ),
        ),
      )
    : null,


          // Drawer
          drawer: EpubDrawer(
            tocEntries: tocEntries,
            onTocEntryTap: navigateToTocEntry,
          ),

          // Body
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : sectionno != null && sectionno! > 0
                  ? PageView.builder(
                      controller: pageController,
                      itemCount: sectionno!,
                      itemBuilder: (context, index) {
                        final rawHtml = utf8.decode(
                          indexsection[index].content.fileContent!,
                        );

                        if(isNavigating){return CircularProgressIndicator();}
                        else {return GestureDetector(
                                onTap: () {
              setState(() {
                readerProvider.toggleFullscreen();
              });
            },
                                child: Stack(
                          children: [
                          
                             
                            // Progress Bar
                            ValueListenableBuilder<double>(
                              valueListenable: progressNotifier,
                              builder: (context, percentage, child) {
                                return LinearProgressIndicator(
                                  value: progressNotifier.value,
                                  color:Theme.of(context).textTheme.bodyMedium!.color,
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                );
                              },
                            ),

                            // Scrollable Content
                            SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section Header
                                    Container(
                                      
                                      width: double.infinity,
                                      child: Text(
                                        'Section ${index + 1} of $sectionno',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 193, 194, 196),
                                          fontFamily: 'SFPRODISPLAY',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                
                                    // Section Content
                                    EpubContentWidget(
                                      htmlContent: rawHtml,
                                      extractedImages: extractedImages,
                                    ),
                                  ],
                                ),
                              ),
                            
          //                      
                          ],
                                ));
                      }
      })
                  : const Center(
                      child: Text('Failed to load EPUB content'),
                    ),
        );
      },
    );
  }
}
