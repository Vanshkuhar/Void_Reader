// import 'package:epuber/provider.dart';
// import 'package:flutter/material.dart' hide ImageInfo;
// import 'package:flutter_html/flutter_html.dart' as html;
// import 'package:provider/provider.dart';
// import 'epub_models.dart';
// import 'image_service.dart';

// class EpubContentWidget extends StatelessWidget  {
//   final String htmlContent;
//   final Map<String, ImageInfo> extractedImages;

//   const EpubContentWidget({
//     Key? key,
//     required this.htmlContent,
//     required this.extractedImages,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
    
//     return Consumer2<EpubReaderProvider, ThemeProvider>(
//     builder: (context, readerProvider, themeProvider, child) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: buildContentWithPositionedImages(context,themeProvider),
//       );},
//     );
//   }

//   List<Widget> buildContentWithPositionedImages(BuildContext context, ThemeProvider themeProvider) {
//     List<Widget> widgets = [];
//     List<ImagePosition> imagePositions = [];

//     // Find all image positions
//     int startIndex = 0;
//     while (true) {
//       final imgStart = htmlContent.indexOf('<img', startIndex);
//       if (imgStart == -1) break;

//       final imgEnd = htmlContent.indexOf('>', imgStart);
//       if (imgEnd == -1) break;

//       final imgTag = htmlContent.substring(imgStart, imgEnd + 1);
//       final srcStart = imgTag.indexOf('src=');

//       if (srcStart != -1) {
//         final quoteStart = srcStart + 4;
//         if (quoteStart < imgTag.length) {
//           String quote = '';
//           if (imgTag[quoteStart] == '"') quote = '"';
//           else if (imgTag[quoteStart] == "'") quote = "'";

//           if (quote.isNotEmpty) {
//             final srcValueStart = quoteStart + 1;
//             final srcValueEnd = imgTag.indexOf(quote, srcValueStart);

//             if (srcValueEnd != -1) {
//               final srcValue = imgTag.substring(srcValueStart, srcValueEnd);
//               final imageInfo = ImageService.findImageByPath(srcValue, extractedImages);

//               if (imageInfo != null) {
//                 imagePositions.add(ImagePosition(
//                   start: imgStart,
//                   end: imgEnd + 1,
//                   imageInfo: imageInfo,
//                   srcValue: srcValue,
//                 ));
//                 print('✅ Found image at position $imgStart: ${srcValue.split('/').last}');
//               }
//             }
//           }
//         }
//       }

//       startIndex = imgEnd + 1;
//     }

//     // Build HTML style
//     final htmlStyle = {
//       "body": html.Style(
//         color: Theme.of(context).textTheme.bodyMedium?.color,
//         fontSize: html.FontSize(themeProvider.fontSize),
//         margin: html.Margins.only( left : themeProvider.margins , right: themeProvider.margins ),
//       ),
//       "p": html.Style(
//         color: Theme.of(context).textTheme.bodyMedium?.color,
//         fontSize: html.FontSize(themeProvider.fontSize),
//         textAlign: themeProvider.justified ? TextAlign.justify : TextAlign.start,
//         margin: html.Margins.only(bottom: 16, left : themeProvider.margins , right: themeProvider.margins ),
//         lineHeight: html.LineHeight(1.45),

//       ),
//     };

//     // If no images, return simple HTML
//     if (imagePositions.isEmpty) {
//       widgets.add(
//         html.Html(
//           data: htmlContent,
//           style: htmlStyle,
//         ),
//       );
//       return widgets;
//     }

//     // Sort image positions
//     imagePositions.sort((a, b) => a.start.compareTo(b.start));

//     // Build content with positioned images
//     int currentPos = 0;

//     for (final imagePos in imagePositions) {
//       // Add HTML content before image
//       if (imagePos.start > currentPos) {
//         final htmlBefore = htmlContent.substring(currentPos, imagePos.start);
//         if (htmlBefore.trim().isNotEmpty) {
//           widgets.add(
//             html.Html(
//               data: htmlBefore,
//               style: htmlStyle,
//             ),
//           );
//         }
//       }

//       // Add image
//       widgets.add(
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Center(
//             child: Image.memory(imagePos.imageInfo.data),
//           ),
//         ),
//       );
//       print('✅ Positioned image: ${imagePos.srcValue.split('/').last}');

//       currentPos = imagePos.end;
//     }

//     // Add remaining HTML content
//     if (currentPos < htmlContent.length) {
//       final remainingHtml = htmlContent.substring(currentPos);
//       if (remainingHtml.trim().isNotEmpty) {
//         widgets.add(
//           html.Html(
//             data: remainingHtml,
//             style: htmlStyle,
//           ),
//         );
//       }
//     }

//     return widgets;
//   }
// }




















import 'package:epuber/Provider/provider.dart';
import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:provider/provider.dart';
import 'epub_models.dart';
import 'image_service.dart';

class EpubContentWidget extends StatelessWidget {
  final String htmlContent;
  final Map<String, ImageInfo> extractedImages;

  const EpubContentWidget({
    Key? key,
    required this.htmlContent,
    required this.extractedImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<EpubReaderProvider, ThemeProvider>(
      builder: (context, readerProvider, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: buildContentWithPositionedImages(context, themeProvider),
        );
      },
    );
  }

  List<Widget> buildContentWithPositionedImages(BuildContext context, ThemeProvider themeProvider) {
    List<Widget> widgets = [];
    List<ImagePosition> imagePositions = [];

    // Find all image positions - both <img> tags and <svg> elements
    _findImagePositions(imagePositions);
    _findSvgImagePositions(imagePositions);

    // Build HTML style
    final htmlStyle = {
      "body": html.Style(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: html.FontSize(themeProvider.fontSize),
        margin: html.Margins.only(
          left: themeProvider.margins,
          right: themeProvider.margins,
        ),
      ),
      "p": html.Style(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: html.FontSize(themeProvider.fontSize),
        textAlign: themeProvider.justified ? TextAlign.justify : TextAlign.start,
        margin: html.Margins.only(
          bottom: 16,
          left: themeProvider.margins,
          right: themeProvider.margins,
        ),
        lineHeight: html.LineHeight(1.45),
      ),
      "hr": html.Style(
        margin: html.Margins.symmetric(vertical: 16),
        color: Colors.grey,
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
    };

    // If no images, return simple HTML
    if (imagePositions.isEmpty) {
      widgets.add(
        html.Html(
          data: htmlContent,
          style: htmlStyle,
        ),
      );
      return widgets;
    }

    // Sort image positions
    imagePositions.sort((a, b) => a.start.compareTo(b.start));

    // Build content with positioned images
    int currentPos = 0;

    for (final imagePos in imagePositions) {
      // Add HTML content before image
      if (imagePos.start > currentPos) {
        final htmlBefore = htmlContent.substring(currentPos, imagePos.start);
        if (htmlBefore.trim().isNotEmpty) {
          widgets.add(
            html.Html(
              data: htmlBefore,
              style: htmlStyle,
            ),
          );
        }
      }

      // Add image
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Image.memory(imagePos.imageInfo.data),
          ),
        ),
      );
      print('Positioned image: ${imagePos.srcValue.split('/').last}');

      currentPos = imagePos.end;
    }

    // Add remaining HTML content
    if (currentPos < htmlContent.length) {
      final remainingHtml = htmlContent.substring(currentPos);
      if (remainingHtml.trim().isNotEmpty) {
        widgets.add(
          html.Html(
            data: remainingHtml,
            style: htmlStyle,
          ),
        );
      }
    }

    return widgets;
  }

  // Find regular <img> tag positions
  void _findImagePositions(List<ImagePosition> imagePositions) {
    int startIndex = 0;
    while (true) {
      final imgStart = htmlContent.indexOf('<img', startIndex);
      if (imgStart == -1) break;

      final imgEnd = htmlContent.indexOf('>', imgStart);
      if (imgEnd == -1) break;

      final imgTag = htmlContent.substring(imgStart, imgEnd + 1);
      final srcStart = imgTag.indexOf('src=');

      if (srcStart != -1) {
        final quoteStart = srcStart + 4;
        if (quoteStart < imgTag.length) {
          String quote = '';
          if (imgTag[quoteStart] == '"') quote = '"';
          else if (imgTag[quoteStart] == "'") quote = "'";

          if (quote.isNotEmpty) {
            final srcValueStart = quoteStart + 1;
            final srcValueEnd = imgTag.indexOf(quote, srcValueStart);

            if (srcValueEnd != -1) {
              final srcValue = imgTag.substring(srcValueStart, srcValueEnd);
              final imageInfo = ImageService.findImageByPath(srcValue, extractedImages);

              if (imageInfo != null) {
                imagePositions.add(ImagePosition(
                  start: imgStart,
                  end: imgEnd + 1,
                  imageInfo: imageInfo,
                  srcValue: srcValue,
                ));
                print('Found IMG image at position $imgStart: ${srcValue.split('/').last}');
              } else {
                print('IMG image not found: $srcValue');
              }
            }
          }
        }
      }

      startIndex = imgEnd + 1;
    }
  }

  // Find SVG elements with embedded <image> tags
  void _findSvgImagePositions(List<ImagePosition> imagePositions) {
    int startIndex = 0;
    while (true) {
      final svgStart = htmlContent.indexOf('<svg', startIndex);
      if (svgStart == -1) break;

      // Find the end of the SVG element
      int svgEnd = _findSvgEndPosition(svgStart);
      if (svgEnd == -1) {
        startIndex = svgStart + 4;
        continue;
      }

      // Extract SVG content
      final svgContent = htmlContent.substring(svgStart, svgEnd + 1);
      
      // Look for <image> tags within the SVG
      String? imageHref = _extractImageHrefFromSvg(svgContent);
      
      if (imageHref != null) {
        final imageInfo = ImageService.findImageByPath(imageHref, extractedImages);
        
        if (imageInfo != null) {
          imagePositions.add(ImagePosition(
            start: svgStart,
            end: svgEnd + 1,
            imageInfo: imageInfo,
            srcValue: imageHref,
          ));
          print('Found SVG image at position $svgStart: ${imageHref.split('/').last}');
        } else {
          print('SVG image not found: $imageHref');
        }
      }

      startIndex = svgEnd + 1;
    }
  }

  // Find the end position of an SVG element (handles nested tags)
  int _findSvgEndPosition(int svgStart) {
    int pos = svgStart;
    int depth = 0;
    
    while (pos < htmlContent.length) {
      if (pos + 4 < htmlContent.length && 
          htmlContent.substring(pos, pos + 4) == '<svg') {
        depth++;
        pos += 4;
      } else if (pos + 6 < htmlContent.length && 
                 htmlContent.substring(pos, pos + 6) == '</svg>') {
        depth--;
        if (depth == 0) {
          return pos + 5; // Return position of closing >
        }
        pos += 6;
      } else if (htmlContent[pos] == '<' && 
                 pos + 1 < htmlContent.length && 
                 htmlContent[pos + 1] != '/') {
        // Self-closing tag check
        int tagEnd = htmlContent.indexOf('>', pos);
        if (tagEnd != -1 && tagEnd > 0 && htmlContent[tagEnd - 1] == '/') {
          pos = tagEnd + 1; // Skip self-closing tags
        } else {
          pos++;
        }
      } else {
        pos++;
      }
    }
    
    return -1; // SVG end not found
  }

  // Extract image href from SVG content (manual parsing)
  String? _extractImageHrefFromSvg(String svgContent) {
    int imagePos = svgContent.indexOf('<image');
    if (imagePos == -1) return null;
    
    int imageTagEnd = svgContent.indexOf('>', imagePos);
    if (imageTagEnd == -1) return null;
    
    String imageTag = svgContent.substring(imagePos, imageTagEnd + 1);
    
    // Look for xlink:href first, then href
    String? href = _extractAttributeValue(imageTag, 'xlink:href');
    if (href == null || href.isEmpty) {
      href = _extractAttributeValue(imageTag, 'href');
    }
    
    return href;
  }

  // Extract attribute value from tag (manual parsing)
  String? _extractAttributeValue(String tag, String attributeName) {
    try {
      int attrIndex = tag.indexOf('$attributeName=');
      if (attrIndex == -1) return null;
      
      int valueStart = attrIndex + attributeName.length + 1;
      
      // Skip whitespace
      while (valueStart < tag.length && tag[valueStart] == ' ') {
        valueStart++;
      }
      
      if (valueStart >= tag.length) return null;
      
      // Find quote character
      String quote = tag[valueStart];
      if (quote != '"' && quote != "'") return null;
      
      // Find closing quote
      int valueEnd = tag.indexOf(quote, valueStart + 1);
      if (valueEnd == -1) return null;
      
      return tag.substring(valueStart + 1, valueEnd);
    } catch (e) {
      return null;
    }
  }
}




