// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:epub_decoder/epub_decoder.dart' as epu;
// import 'package:html/parser.dart';
// import 'epub_models.dart';

// class EpubService {
//   static Future<epu.Epub> loadEpubFromAssets(String assetPath) async {
//     final epubFile = await rootBundle.load(assetPath);
//     return epu.Epub.fromBytes(epubFile.buffer.asUint8List());
//   }

//   static Future<epu.Epub> loadEpubFromFile(String filepath) async {
//     final epubFile = await rootBundle.load(filepath);
//     return epu.Epub.fromBytes(epubFile.buffer.asUint8List());
//   }



//   static Future<List<TocEntry>> extractTableOfContents(epu.Epub epub) async {
//     print('=== EXTRACTING TABLE OF CONTENTS ===');
//     List<TocEntry> tocEntries = [];

//     for (int i = 0; i < epub.items.length; i++) {
//       final item = epub.items[i];

//       if (item.href != null && item.fileContent != null) {
//         final href = item.href!.toLowerCase();

//         if (href.endsWith('.ncx')) {
//           try {
//             final ncxContent = utf8.decode(item.fileContent!);
//             print('✅ Found NCX file: ${item.href}');
//             await parseNcxContent(ncxContent, tocEntries, epub);
//           } catch (e) {
//             print('❌ Error processing NCX file ${item.href}: $e');
//           }
//         }
//       }
//     }

//     print('Total TOC entries extracted: ${tocEntries.length}');
//     return tocEntries;
//   }

//   static Future<void> parseNcxContent(String ncxContent, List<TocEntry> tocEntries, epu.Epub epub) async {
//     try {
//       final document = parse(ncxContent);
//       final navPoints = document.querySelectorAll('navPoint');

//       for (final navPoint in navPoints) {
//         final navLabel = navPoint.querySelector('navLabel text');
//         final content = navPoint.querySelector('content');

//         if (navLabel != null && content != null) {
//           final title = navLabel.text.trim();
//           final src = content.attributes['src'];

//           if (title.isNotEmpty && src != null) {
//             final parts = src.split('#');
//             final filename = parts[0];
//             final anchor = parts.length > 1 ? parts[1] : '';
//             final sectionIndex = findSectionIndexByFilename(filename, epub);

//             if (sectionIndex != -1) {
//               tocEntries.add(TocEntry(
//                 title: title,
//                 filename: filename,
//                 anchor: anchor,
//                 sectionIndex: sectionIndex,
//               ));

//               print('✅ Added TOC entry: $title -> Section $sectionIndex${anchor.isNotEmpty ? " #$anchor" : ""}');
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('❌ Error parsing NCX content: $e');
//     }
//   }

//   static int findSectionIndexByFilename(String targetFilename, epu.Epub epub) {
//     for (int i = 0; i < epub.sections.length; i++) {
//       final section = epub.sections[i];

//       if (section.content.href != null) {
//         final sectionHref = section.content.href!;
//         final sectionFilename = sectionHref.split('/').last;

//         if (sectionFilename == targetFilename ||
//             sectionHref.endsWith(targetFilename) ||
//             targetFilename.endsWith(sectionFilename)) {
//           return i;
//         }
//       }
//     }

//     // Fallback: try content matching
//     for (int i = 0; i < epub.sections.length; i++) {
//       final section = epub.sections[i];
//       final htmlContent = utf8.decode(section.content.fileContent!);

//       if (htmlContent.contains(targetFilename.replaceAll('.html', ''))) {
//         return i;
//       }
//     }

//     return -1;
//   }
// }





import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:epub_decoder/epub_decoder.dart' as epu;
import 'package:html/parser.dart';
import 'epub_models.dart';

class EpubService {
  static Future<epu.Epub> loadEpubFromAssets(String assetPath) async {
    try {
      final epubFile = await rootBundle.load(assetPath);
      return epu.Epub.fromBytes(epubFile.buffer.asUint8List());
    } catch (e) {
      print('Error loading EPUB from assets: $e');
      rethrow;
    }
  }

  static Future<epu.Epub> loadEpubFromFile(String filepath) async {
    try {
      final epubFile = await rootBundle.load(filepath);
      return epu.Epub.fromBytes(epubFile.buffer.asUint8List());
    } catch (e) {
      print('Error loading EPUB from file: $e');
      rethrow;
    }
  }

  static Future<List<TocEntry>> extractTableOfContents(epu.Epub epub) async {
    print('=== EXTRACTING TABLE OF CONTENTS ===');
    List<TocEntry> tocEntries = [];

    try {
      if (epub == null || epub.items == null || epub.items.isEmpty) {
        print('No items found in EPUB');
        return tocEntries;
      }

      print('Processing ${epub.items.length} items for TOC');

      for (int i = 0; i < epub.items.length; i++) {
        try {
          final item = epub.items[i];

          if (item == null || item.href == null || item.fileContent == null) {
            continue;
          }

          if (item.href!.isEmpty) {
            continue;
          }

          final href = item.href!.toLowerCase();

          // Look for NCX files (EPUB 2.0) or nav.xhtml files (EPUB 3.0)
          if (href.endsWith('.ncx') || href.endsWith('nav.xhtml')) {
            try {
              final content = utf8.decode(item.fileContent!);
              print('Found navigation file: ${item.href}');
              
              if (href.endsWith('.ncx')) {
                await _parseNcxContent(content, tocEntries, epub);
              } else {
                await _parseNavContent(content, tocEntries, epub);
              }
            } catch (e) {
              print('Error processing navigation file ${item.href}: $e');
              continue;
            }
          }
        } catch (e) {
          print('Error processing item $i: $e');
          continue;
        }
      }

      print('Total TOC entries extracted: ${tocEntries.length}');
    } catch (e, stackTrace) {
      print('Critical error in extractTableOfContents: $e');
      print('Stack trace: $stackTrace');
    }

    return tocEntries;
  }

  // Parse NCX content (EPUB 2.0 format)
  static Future<void> _parseNcxContent(String ncxContent, List<TocEntry> tocEntries, epu.Epub epub) async {
    try {
      final document = parse(ncxContent);
      final navPoints = document.querySelectorAll('navPoint');

      print('Found ${navPoints.length} navigation points in NCX');

      for (int i = 0; i < navPoints.length; i++) {
        try {
          final navPoint = navPoints[i];
          final navLabel = navPoint.querySelector('navLabel text');
          final content = navPoint.querySelector('content');

          if (navLabel != null && content != null) {
            final title = navLabel.text.trim();
            final src = content.attributes['src'];

            if (title.isNotEmpty && src != null && src.isNotEmpty) {
              final cleanSrc = _cleanPath(src);
              final parts = cleanSrc.split('#');
              final filename = parts[0];
              final anchor = parts.length > 1 ? parts[1] : '';
              
              final sectionIndex = _findSectionIndexByFilename(filename, epub);

              if (sectionIndex != -1) {
                tocEntries.add(TocEntry(
                  title: title,
                  filename: filename,
                  anchor: anchor,
                  sectionIndex: sectionIndex,
                ));

                print('Added TOC entry: $title -> Section $sectionIndex${anchor.isNotEmpty ? " #$anchor" : ""}');
              } else {
                print('Section not found for: $title ($filename)');
              }
            }
          }
        } catch (e) {
          print('Error processing navPoint $i: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error parsing NCX content: $e');
    }
  }

  // Parse nav.xhtml content (EPUB 3.0 format)
  static Future<void> _parseNavContent(String navContent, List<TocEntry> tocEntries, epu.Epub epub) async {
    try {
      final document = parse(navContent);
      
      final navElements = document.querySelectorAll('nav[epub\\:type="toc"] ol li a, nav ol li a, ol li a');
      
      print('Found ${navElements.length} navigation elements in nav.xhtml');

      for (int i = 0; i < navElements.length; i++) {
        try {
          final anchor = navElements[i];
          final title = anchor.text.trim();
          final href = anchor.attributes['href'];

          if (title.isNotEmpty && href != null && href.isNotEmpty) {
            final cleanHref = _cleanPath(href);
            final parts = cleanHref.split('#');
            final filename = parts[0];
            final anchorName = parts.length > 1 ? parts[1] : '';
            
            final sectionIndex = _findSectionIndexByFilename(filename, epub);

            if (sectionIndex != -1) {
              tocEntries.add(TocEntry(
                title: title,
                filename: filename,
                anchor: anchorName,
                sectionIndex: sectionIndex,
              ));

              print('Added TOC entry: $title -> Section $sectionIndex${anchorName.isNotEmpty ? " #$anchorName" : ""}');
            } else {
              print('Section not found for: $title ($filename)');
            }
          }
        } catch (e) {
          print('Error processing nav element $i: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error parsing nav.xhtml content: $e');
    }
  }

  // Clean path by removing URL encoding and normalizing
  static String _cleanPath(String path) {
    try {
      String cleaned = path.trim();
      
      // Remove URL encoding
      cleaned = Uri.decodeFull(cleaned);
      
      // Remove fragments and queries for filename extraction
      if (cleaned.contains('?')) {
        cleaned = cleaned.split('?')[0];
      }
      
      return cleaned;
    } catch (e) {
      print('Error cleaning path $path: $e');
      return path;
    }
  }

  // Enhanced section finding with multiple fallback strategies
  static int _findSectionIndexByFilename(String targetFilename, epu.Epub epub) {
    try {
      if (targetFilename.isEmpty) return -1;
      
      String normalizedTarget = _normalizeFilename(targetFilename);
      
      print('Looking for section with filename: $targetFilename (normalized: $normalizedTarget)');

      // Strategy 1: Direct href matching
      for (int i = 0; i < epub.sections.length; i++) {
        try {
          final section = epub.sections[i];

          if (section?.content?.href != null) {
            final sectionHref = section.content.href!;
            final sectionFilename = _extractFilename(sectionHref);
            final normalizedSection = _normalizeFilename(sectionFilename);

            if (sectionFilename == targetFilename ||
                normalizedSection == normalizedTarget ||
                sectionHref.endsWith(targetFilename) ||
                targetFilename.endsWith(sectionFilename)) {
              print('Found section $i by direct matching: $sectionFilename');
              return i;
            }
          }
        } catch (e) {
          print('Error checking section $i: $e');
          continue;
        }
      }

      // Strategy 2: Content-based matching (fallback)
      for (int i = 0; i < epub.sections.length; i++) {
        try {
          final section = epub.sections[i];
          
          if (section?.content?.fileContent != null) {
            final htmlContent = utf8.decode(section.content.fileContent!);
            
            String baseFilename = targetFilename.replaceAll('.xhtml', '').replaceAll('.html', '');
            if (htmlContent.toLowerCase().contains(baseFilename.toLowerCase())) {
              print('Found section $i by content matching: $baseFilename');
              return i;
            }
          }
        } catch (e) {
          print('Error checking section content $i: $e');
          continue;
        }
      }

      print('No section found for filename: $targetFilename');
      return -1;
    } catch (e) {
      print('Error in _findSectionIndexByFilename: $e');
      return -1;
    }
  }

  // Extract filename from path manually
  static String _extractFilename(String path) {
    try {
      if (path.isEmpty) return '';
      
      String cleanPath = path;
      
      if (cleanPath.contains('?')) {
        cleanPath = cleanPath.split('?')[0];
      }
      if (cleanPath.contains('#')) {
        cleanPath = cleanPath.split('#')[0];
      }
      
      cleanPath = cleanPath.replaceAll('\\', '/');
      
      List<String> parts = cleanPath.split('/');
      
      for (int i = parts.length - 1; i >= 0; i--) {
        if (parts[i].isNotEmpty) {
          return parts[i];
        }
      }
      
      return cleanPath;
    } catch (e) {
      print('Error extracting filename from $path: $e');
      return path;
    }
  }

  // Normalize filename for consistent matching
  static String _normalizeFilename(String filename) {
    try {
      return filename
          .replaceAll('%20', '')
          .replaceAll(' ', '')
          .toLowerCase();
    } catch (e) {
      return filename.toLowerCase();
    }
  }
}
     


    //  trying to make a changein the code to test the git commit