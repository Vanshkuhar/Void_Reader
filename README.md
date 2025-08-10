# Void Reader

**Void Reader** is a clean and minimal **EPUB reader** built with **Flutter**, designed for a distraction-free, elegant reading experience.  

This is my first Flutter project, through which I learned and implemented:  
- Understanding **EPUB structure** and working with **XHTML content**  
- **Parsing HTML** and rendering it within Flutter  
- Implementing **navigation** and **animations** (e.g., AppBar slide-in, fullscreen toggle)  
- Managing **persistent storage** for bookmarks and reading progress  
- Using **AI-assisted coding** to handle complex tasks like **manual image placement**  
- Applying **dark mode theming** for better readability  
- Integrating **PageView** with **ScrollController** for a smooth reading experience

## ✨ Features
- **Table of Contents** – Navigate chapters instantly  
- **Bookmarks** – Save and revisit pages quickly  
- **Font Size Adjustment** – Customize text size for comfort  
- **Text Alignment Options** – Choose your preferred alignment  
- **Dark Mode** – Read comfortably at night  
- **Minimal UI** – Focus on your book, not the interface  

## 🎯 Design Philosophy
Void Reader is deliberately minimal — avoiding unnecessary visual elements — to keep your attention on the text itself.

## ⚠️ Compatibility Notes
Some EPUB files may not render correctly due to **limitations in the current EPUB parsing library** (`epub_decoder`). These issues are typically related to certain EPUB formatting styles and manifest file encodings.  

In the future, I may choose to **upgrade or replace the parsing system** to improve compatibility with a wider range of EPUB files.

## 🛠️ Tech Stack
**Core Framework**  
- **Flutter** – Cross-platform UI framework  
- **Dart** – Primary programming language  

**Packages & Libraries**  
- [`epub_decoder`](https://pub.dev/packages/epub_decoder) – Reading and parsing EPUB files  
- [`provider`](https://pub.dev/packages/provider) – State management  
- [`archive`](https://pub.dev/packages/archive) – ZIP/EPUB file handling and patching  

## 📥 Direct APK Download

You can download the latest **Void Reader APK** directly here:  
[**⬇ Download APK (v1.0)**](https://drive.google.com/file/d/1xZ6ShiBZhHXAPN8xBuWUND5dMeFFXXAP/view?usp=drive_link)

### 📌 Installing the APK (Enable Unknown Sources)
Since Void Reader is not on the Google Play Store, you’ll need to allow installation from **unknown sources**:

1. **Download the APK** using the link above.  
2. Once downloaded, tap on the file in your browser or file manager.  
3. Your phone will ask you to **Allow installation from this source** — enable it.  
4. Confirm the installation.  
5. After it finishes, you can open **Void Reader** from your app drawer.

