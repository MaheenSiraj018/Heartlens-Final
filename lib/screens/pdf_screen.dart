import 'dart:io';
import 'dart:developer' as logger show log;
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfScreen extends StatefulWidget {
  final File pdf;
  const PdfScreen({Key? key, required this.pdf}) : super(key: key);

  @override
  PdfScreenState createState() => PdfScreenState();
}

class PdfScreenState extends State<PdfScreen> {
  bool _isDownloading = false;
  late PDFDocument _pdfDocument;

  @override
  void initState() {
    super.initState();
    _pdfDocument = PDFDocument();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final loadedDoc = await PDFDocument.fromFile(widget.pdf);
      setState(() => _pdfDocument = loadedDoc);
    } catch (e) {
      logger.log('PDF loading error: $e');
      _showError('Failed to load PDF');
    }
  }

  Future<void> _downloadPDF() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      // 1. Check and request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // 2. Get valid download directory
      final directory = await _getDownloadDirectory();
      final fileName = path.basename(widget.pdf.path);
      final savePath = '${directory.path}/$fileName';

      // 3. Copy file and verify
      await widget.pdf.copy(savePath);
      if (!await File(savePath).exists()) {
        throw Exception('File not saved');
      }

      // 4. Show success
      _showSuccess('Saved to Downloads');
    } catch (e) {
      _showError('Download failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    try {
      final dir = await DownloadsPathProvider.downloadsDirectory;
      if (dir != null) return dir;
    } catch (_) {}
    return Directory('/storage/emulated/0/Download');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD1D1),
        title: Text(
          path.basename(widget.pdf.path),
          style: TextStyle(
            color: Color(0xFF1B0E0E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? CircularProgressIndicator(color: Color(0xFF1B0E0E))
                : Icon(Icons.download, color: Color(0xFF1B0E0E)),
            onPressed: _downloadPDF,
          ),
        ],
      ),
      body: _pdfDocument.count > 0
          ? PDFViewer(
        document: _pdfDocument,
        scrollDirection: Axis.vertical,
        showNavigation: false,
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 60, color: Colors.red),
            SizedBox(height: 20),
            Text('Loading PDF...'),
          ],
        ),
      ),
    );
  }
}

//
//
// import 'dart:io';
// import 'dart:developer' as logger show log;
//
// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// class PdfScreen extends StatefulWidget {
//   final File pdf;
//   const PdfScreen({Key? key, required this.pdf}) : super(key: key);
//
//   @override
//   PdfScreenState createState() => PdfScreenState();
// }
//
// @visibleForTesting
// class PdfScreenState extends State<PdfScreen> {
//   Future<PDFViewer> preparePdfDocument() async {
//     try {
//       final pdfDoc = await PDFDocument.fromFile(widget.pdf);
//       return PDFViewer(
//         document: pdfDoc,
//         scrollDirection: Axis.vertical,
//         showNavigation: false,
//       );
//     } catch (e) {
//       logger
//           .log('Error Log: We are unable to open that PDF. We ran into an $e');
//       return PDFViewer(document: PDFDocument());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String pdfTitle = basename(widget.pdf.path);
//
//     return Scaffold(
//       appBar: AppBar(
//         // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // color: Colors.#ffa2a2,FFFFA2A2, FFD23939
//         backgroundColor: Color(0xFFFFD1D1),
//         title: Text(pdfTitle , style: TextStyle(
//           color: Color(0xFF1B0E0E),
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),),
//         actions: [
//           InkWell(
//             onTap: () async {},
//             child: const Padding(
//               padding: EdgeInsets.all(10),
//               child: Icon(Icons.share, size: 35),
//             ),
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//         future: preparePdfDocument(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return Center(child: snapshot.data);
//           } else {
//             return const Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.warning, size: 160),
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Text('Just a minute',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.red, fontSize: 16)),
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
// }
