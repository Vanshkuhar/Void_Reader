import 'package:flutter/material.dart';
import '../Content Extraction/epub_models.dart';
import '../Provider/provider.dart';
import 'package:provider/provider.dart';

class EpubDrawer extends StatelessWidget {
  final List<TocEntry> tocEntries;
  final Function(TocEntry) onTocEntryTap;

  const EpubDrawer({
    Key? key,
    required this.tocEntries,
    required this.onTocEntryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<EpubReaderProvider, ThemeProvider>(
    builder: (context, readerProvider, themeProvider, child) {
        return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(
                    Icons.menu_book,
                    color: Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({}),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'Table of Contents',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SFPRODISPLAY',
                    ),
                  ),
                  Text(
                    '${tocEntries.length} chapters',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: 12,
                      fontFamily: 'SFPRODISPLAY',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Table of Contents List
          Expanded(
            child: tocEntries.isEmpty
                ?  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No Table of Contents found\n(.ncx file not available)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tocEntries.length,
                    itemBuilder: (context, index) {
                      final entry = tocEntries[index];

                      return ListTile(
                        dense: false,
                        title: Text(
                          entry.title,
                          style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onTocEntryTap(entry),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).iconButtonTheme.style!.iconColor!.resolve({}),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  });}
}
