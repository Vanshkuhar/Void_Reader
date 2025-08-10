// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:epub_decoder/epub_decoder.dart' as epu;
// import 'epub_models.dart';

// class ImageService {
//   static Future<Map<String, ImageInfo>> extractAllImages(epu.Epub epub) async {
//     print('=== EXTRACTING IMAGES ===');
//     Map<String, ImageInfo> extractedImages = {};

//     // null check for epub.items
//   if (epub.items == null || epub.items.isEmpty) {
//     print('⚠️ No items found in EPUB');
//     return extractedImages;
//   }

//     for (int i = 0; i < epub.items.length; i++) {
//       final item = epub.items[i];

//       // Better null checks
//       if (item?.href == null || item?.fileContent == null) {
//         continue; // Skip invalid items
//       }

//       if (item.href != null && item.fileContent != null) {
//         final href = item.href!.toLowerCase();

//         if (href.endsWith('.jpg') ||
//             href.endsWith('.jpeg') ||
//             href.endsWith('.png') ||
//             href.endsWith('.gif') ||
//             href.endsWith('.webp') ||
//             href.endsWith('.svg')) {
          
//           final filename = item.href!.split('/').last;
//           final imageInfo = await getImageInfo(item.fileContent!);

//           final pathVariations = [
//             filename,
//             item.href!,
//             '../Images/' + filename,
//             'Images/' + filename,
//             '../images/' + filename,
//             'images/' + filename,
//             './' + filename,
//             '../' + filename,
//           ];

//           for (final variation in pathVariations) {
//             extractedImages[variation] = imageInfo;
//           }

//           print('✅ Stored: $filename');
//         }
//       }
//     }

//     print('Total image entries: ${extractedImages.length}');
//     return extractedImages;
//   }

//   static Future<ImageInfo> getImageInfo(Uint8List imageBytes) async {
//     try {
//       final codec = await ui.instantiateImageCodec(imageBytes);
//       final frame = await codec.getNextFrame();
//       final image = frame.image;

//       return ImageInfo(
//         data: imageBytes,
//         width: image.width,
//         height: image.height,
//       );
//     } catch (e) {
//       print('Error getting image info: $e');
//       return ImageInfo(
//         data: imageBytes,
//         width: 300,
//         height: 400,
//       );
//     }
//   }

//   static ImageInfo? findImageByPath(String srcPath, Map<String, ImageInfo> extractedImages) {
//     String cleanPath = srcPath.trim();
//     cleanPath = cleanPath
//         .replaceAll('[', '')
//         .replaceAll(']', '')
//         .replaceAll('(', '')
//         .replaceAll(')', '');

//     if (extractedImages.containsKey(cleanPath)) {
//       return extractedImages[cleanPath];
//     }

//     final filename = cleanPath.split('/').last;
//     return extractedImages[filename];
//   }
// }



// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:epub_decoder/epub_decoder.dart' as epu;
// import 'epub_models.dart';

// class ImageService {
//   static Future<Map<String, ImageInfo>> extractAllImages(epu.Epub epub) async {
//     print('=== EXTRACTING IMAGES ===');
//     Map<String, ImageInfo> extractedImages = {};

//     // null check for epub.items
//     if (epub.items == null || epub.items.isEmpty) {
//       print('⚠️ No items found in EPUB');
//       return extractedImages;
//     }

//     for (int i = 0; i < epub.items.length; i++) {
//       try {
//         final item = epub.items[i];

//         // Better null checks
//         if (item?.href == null || item?.fileContent == null) {
//           continue; // Skip invalid items
//         }

//         if (item.href != null && item.fileContent != null) {
//           final href = item.href!.toLowerCase();

//           if (href.endsWith('.jpg') ||
//               href.endsWith('.jpeg') ||
//               href.endsWith('.png') ||
//               href.endsWith('.gif') ||
//               href.endsWith('.webp') ||
//               href.endsWith('.svg')) {
            
//             // FIXED: Safe filename extraction to prevent "No element" error
//             String filename;
//             if (item.href!.isNotEmpty) {
//               final pathParts = item.href!.split('/');
//               filename = pathParts.isNotEmpty ? pathParts.last : 'unknown_$i.jpg';
//               // Additional check for empty filename
//               if (filename.isEmpty) {
//                 filename = 'unknown_$i.jpg';
//               }
//             } else {
//               filename = 'unknown_$i.jpg';
//             }
            
//             final imageInfo = await getImageInfo(item.fileContent!);

//             // Safe path variations
//             final pathVariations = [
//               filename,
//               item.href!,
//               '../Images/' + filename,
//               'Images/' + filename,
//               '../images/' + filename,
//               'images/' + filename,
//               './' + filename,
//               '../' + filename,
//             ];

//             for (final variation in pathVariations) {
//               extractedImages[variation] = imageInfo;
//             }

//             print('✅ Stored: $filename');
//           }
//         }
//       } catch (e) {
//         print('⚠️ Error processing image $i: $e');
//         continue; // Skip corrupted image, don't crash entire EPUB
//       }
//     }

//     print('Total image entries: ${extractedImages.length}');
//     return extractedImages;
//   }

//   static Future<ImageInfo> getImageInfo(Uint8List imageBytes) async {
//     try {
//       // Validate image data before processing
//       if (imageBytes.isEmpty) {
//         throw Exception('Empty image data');
//       }
      
//       if (imageBytes.length < 10) {
//         throw Exception('Image data too small');
//       }
      
//       final codec = await ui.instantiateImageCodec(imageBytes);
//       final frame = await codec.getNextFrame();
//       final image = frame.image;

//       final info = ImageInfo(
//         data: imageBytes,
//         width: image.width,
//         height: image.height,
//       );
      
//       // Clean up memory
//       image.dispose();

//       return info;
//     } catch (e) {
//       print('Error getting image info: $e');
//       return ImageInfo(
//         data: imageBytes.isNotEmpty ? imageBytes : Uint8List(0),
//         width: 300,
//         height: 400,
//       );
//     }
//   }

//   static ImageInfo? findImageByPath(String srcPath, Map<String, ImageInfo> extractedImages) {
//     // Enhanced null safety
//     if (srcPath.isEmpty || extractedImages.isEmpty) {
//       return null;
//     }

//     String cleanPath = srcPath.trim();
//     cleanPath = cleanPath
//         .replaceAll('[', '')
//         .replaceAll(']', '')
//         .replaceAll('(', '')
//         .replaceAll(')', '');

//     if (extractedImages.containsKey(cleanPath)) {
//       return extractedImages[cleanPath];
//     }

//     // FIXED: Safe filename extraction
//     if (cleanPath.contains('/')) {
//       final pathParts = cleanPath.split('/');
//       if (pathParts.isNotEmpty) {
//         final filename = pathParts.last;
//         if (filename.isNotEmpty && extractedImages.containsKey(filename)) {
//           return extractedImages[filename];
//         }
//       }
//     }
    
//     return null;
//   }
// }





// the new loader only work swith this
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:epub_decoder/epub_decoder.dart' as epu;
import 'epub_models.dart';

class ImageService {
  /// Extract all images from EPUB with detailed debug logs and multiple normalized keys
  static Future<Map<String, ImageInfo>> extractAllImages(epu.Epub epub) async {
    print('=== EXTRACTING IMAGES ===');
    final extractedImages = <String, ImageInfo>{};
    if (epub.items == null || epub.items.isEmpty) {
      print(' No items found in EPUB');
      return extractedImages;
    }

    for (var i = 0; i < epub.items.length; i++) {
      final item = epub.items[i];
      if (item?.href == null || item?.fileContent == null) continue;

      final rawHref = item!.href!;
      final href = rawHref.toLowerCase();
      
      if (!RegExp(r'\.(jpe?g|png|gif|webp|svg)$').hasMatch(href)) continue;

      final info = await _getImageInfo(item.fileContent!);

      final filename = rawHref.split('/').last;
      final decodedHref = Uri.decodeFull(rawHref);
      final decodedFilename = Uri.decodeFull(filename);

      final keys = <String>{
        rawHref,
        rawHref.replaceAll('%20', ' '),
        rawHref.replaceAll('%20', ''),
        decodedHref,
        decodedHref.replaceAll(' ', ''),
        decodedHref.toLowerCase(),
        filename,
        filename.replaceAll(' ', ''),
        decodedFilename,
        decodedFilename.replaceAll(' ', ''),
        decodedFilename.toLowerCase(),
      };

      for (var key in keys) {
        final normalizedKey = _normalizeKey(key);
        extractedImages[normalizedKey] = info;
        print('Stored key: "$normalizedKey" for image: "$rawHref"');
      }
    }

    print('Total image entries stored: ${extractedImages.length}');
    return extractedImages;
  }

  static Future<ImageInfo> _getImageInfo(Uint8List bytes) async {
    try {
      if (bytes.length < 10) throw Exception('Image data too small');
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final info = ImageInfo(data: bytes, width: image.width, height: image.height);
      image.dispose();
      return info;
    } catch (e) {
      print('Error getting image info: $e');
      return ImageInfo(data: bytes, width: 300, height: 400);
    }
  }

  /// Normalize keys by stripping spaces, %20, brackets, case-insensitive
  static String _normalizeKey(String input) {
    var s = input.toLowerCase();
    s = s.replaceAll('%20', '');
    s = s.replaceAll(RegExp(r'\s+'), '');
    s = s.replaceAll(RegExp(r'[()\[\]]'), '');
    s = s.replaceAll('\\', '/'); // normalize slashes
    return s;
  }

  /// Find image info by matching normalized keys with detailed debug prints
  static ImageInfo? findImageByPath(String srcPath, Map<String, ImageInfo> extractedImages) {
    if (srcPath.isEmpty || extractedImages.isEmpty) {
      print('findImageByPath: srcPath empty or no images extracted');
      return null;
    }

    print('Looking up image for srcPath: "$srcPath"');
    final candidates = <String>{
      srcPath,
      Uri.decodeFull(srcPath),
      srcPath.replaceAll('%20', '').replaceAll(' ', ''),
      Uri.decodeFull(srcPath).replaceAll('%20', '').replaceAll(' ', ''),
      srcPath.split('/').last,
      Uri.decodeFull(srcPath.split('/').last),
      srcPath.split('/').last.replaceAll('%20', '').replaceAll(' ', ''),
      Uri.decodeFull(srcPath.split('/').last).replaceAll('%20', '').replaceAll(' ', ''),
    };

    for (var candidate in candidates) {
      final normalizedCandidate = _normalizeKey(candidate);
      if (extractedImages.containsKey(normalizedCandidate)) {
        print('Matched image with key: "$normalizedCandidate"');
        return extractedImages[normalizedCandidate];
      } else {
        print('No match for key: "$normalizedCandidate"');
      }
    }

    print('Image not found for srcPath: "$srcPath"');
    return null;
  }
}
