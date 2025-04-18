import 'dart:io';
import 'dart:developer' as logger show log;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_widgets.dart';
import '../data/student.dart';

class PdfUtils {
  PdfUtils._();
  static String getCurrentDayDate() {
    DateTime now = DateTime.now();
    String dayWithOrdinal = getDayWithOrdinal(now.day);
    return DateFormat("d MMM, yyyy").format(now).replaceFirstMapped(
      RegExp(r'\d+'),
          (match) => dayWithOrdinal,
    );
  }

  static String getDayWithOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  static Future<String> downloadDir() async {
    if (Platform.isMacOS) {
      return '/Users/${Platform.environment['USER']}/Downloads';
    } else if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads';
    } else if (Platform.isLinux) {
      return '/home/${Platform.environment['USER']}/Downloads';
    } else if (Platform.isAndroid) {
      Directory directory = Directory('/storage/emulated/0/Download');
      return directory.path;
    } else {
      return '/';
    }
  }

  static Future<File> generatePdfFile(String fileName, pw.Document pdf) async {
    late File pdfFile;
    final path = await downloadDir();

    if (path.isNotEmpty) {
      try {
        pdfFile = File(join(path, '$fileName.pdf'));
        logger.log('Saved to: ${pdfFile.path}');
        await pdfFile.writeAsBytes(await pdf.save());
        return pdfFile;
      } catch (e) {
        logger.log("An error occurred while saving file.");
        logger.log("Error: $e");
      }
    } else {
      logger.log("Unable to determine the download path.");
    }
    return pdfFile;
  }

  static Future<File> generateSimplePDF() async {
    final pdf = pw.Document();

    final ByteData bytesImage =
    await rootBundle.load('assets/images/hand_phone.png');
    final Uint8List bgBytes = bytesImage.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(
                  pw.MemoryImage(bgBytes),
                  fit: pw.BoxFit.fitHeight,
                  height: 400,
                  width: 400,
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
    return await generatePdfFile('My PDF Example', pdf);
  }

  static Future<File> generateAdvancedPDF(List<Student> students) async {
    final pdf = pw.Document();

    final ByteData bytesImage =
    await rootBundle.load('assets/images/template.png');
    final Uint8List bgBytes = bytesImage.buffer.asUint8List();

    final ttfFont = await rootBundle.load('assets/fonts/PTSerif-Regular.ttf');
    final customFont = pw.Font.ttf(ttfFont);

    final normalFont = await rootBundle.load('assets/fonts/Roboto-LightItalic.ttf');
    final thinFont = pw.Font.ttf(normalFont);

    var textStyle1 = pw.TextStyle(fontSize: 10, font: thinFont,color: PdfColors.black);
    var textStyle2 = pw.TextStyle(
        fontSize: 10, color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: customFont,);
    var textStyle3 = pw.TextStyle(
        fontSize: 12, color: PdfColors.black, fontWeight: pw.FontWeight.bold, font: customFont,);

    var introductionTexts = pw.Table(
      columnWidths: {
        0: pw.FixedColumnWidth(120), // Set width of the first column
        1: pw.FlexColumnWidth(1),   // Second column takes remaining space
      },
      children: [
        pw.TableRow(
          children: [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                textItem(title: 'Name', style: textStyle2),
                textItem(title: 'Age:', style: textStyle2),
                textItem(title: 'Gender:', style: textStyle2),
                textItem(title: 'Report generated on:', style: textStyle2),
              ],
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                textItem(title: students[0].name, style: textStyle2),
                textItem(
                  title: students[0].age,
                  style: textStyle2,
                ),
                textItem(title: students[0].gender , style: textStyle2),
                textItem(title: getCurrentDayDate(), style: textStyle2),
              ],
            ),
          ],
        ),
      ],
    );

    var mainTexts = pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                textItem(title: 'ECG Analysis Summary', style: textStyle3),
                textItem(title: 'ST Segment:', style: textStyle2),
                textItem(title: students[0].ST_Segment, style: textStyle1),
                pw.SizedBox(height:10),
                textItem(title: 'Diagnostic Insights ', style: textStyle3),
                textItem(title: 'Condition Detected:', style: textStyle2),
                textItem(title: students[0].Condition, style: textStyle1),
                textItem(title: 'Localization:', style: textStyle2),
                textItem(title: students[0].localization, style: textStyle1),
                textItem(title: 'Risk Level:', style: textStyle2),
                textItem(title: students[0].risk_level, style: textStyle1),
                pw.SizedBox(height:10),

                textItem(title: 'Recommendations', style: textStyle3),
                textItem(title: 'Urgent Action:', style: textStyle2),
                textItem(title: students[0].urgent_action, style: textStyle1),
                textItem(title: 'Follow Up:', style: textStyle2),
                textItem(title: students[0].followup, style: textStyle1),
                textItem(title: 'Lifestyle:', style: textStyle2),
                textItem(title: students[0].lifestyle, style: textStyle1),
                pw.SizedBox(height:10),

                textItem(title: 'Generated By:', style: textStyle3),
                textItem(title: 'HeartLens, Empowering Lives with Early Detection', style: textStyle1),
              ],
            ),
          ],
        ),
      ],
    );



    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 15),
            decoration: pw.BoxDecoration(
              image: pw.DecorationImage(
                fit: pw.BoxFit.cover,
                image: pw.MemoryImage(bgBytes),
              ),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 150),
                introductionTexts,
                pw.Divider(thickness: 2, color: PdfColors.grey),
                pw.SizedBox(height:2),
                mainTexts,
              ],
            ),
          );
        },
      ),
    );
    return await generatePdfFile('STEMI Detection', pdf);
  }
}





// import 'dart:io';
// import 'dart:developer' as logger show log;
//
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// import '../data/student.dart';
// import 'pdf_widgets.dart';
//
//
// class PdfUtils {
//   PdfUtils._();
//
//   static String getCurrentDayDate() {
//     DateTime now = DateTime.now();
//     String dayWithOrdinal = getDayWithOrdinal(now.day);
//     return DateFormat("d MMM, yyyy").format(now).replaceFirstMapped(
//       RegExp(r'\d+'),
//           (match) => dayWithOrdinal,
//     );
//   }
//
//   static String getDayWithOrdinal(int day) {
//     if (day >= 11 && day <= 13) {
//       return '${day}th';
//     }
//     switch (day % 10) {
//       case 1:
//         return '${day}st';
//       case 2:
//         return '${day}nd';
//       case 3:
//         return '${day}rd';
//       default:
//         return '${day}th';
//     }
//   }
//
//   static Future<String> downloadDir() async {
//     if (Platform.isMacOS) {
//       return '/Users/${Platform.environment['USER']}/Downloads';
//     } else if (Platform.isWindows) {
//       return '${Platform.environment['USERPROFILE']}\\Downloads';
//     } else if (Platform.isLinux) {
//       return '/home/${Platform.environment['USER']}/Downloads';
//     } else if (Platform.isAndroid) {
//       Directory directory = Directory('/storage/emulated/0/Download');
//       return directory.path;
//     } else {
//       return '/';
//     }
//   }
//
//   static Future<File> generatePdfFile(String fileName, pw.Document pdf) async {
//     late File pdfFile;
//     final path = await downloadDir();
//
//     if (path.isNotEmpty) {
//       try {
//         pdfFile = File(join(path, '$fileName.pdf'));
//         logger.log('Saved to: ${pdfFile.path}');
//         await pdfFile.writeAsBytes(await pdf.save());
//         return pdfFile;
//       } catch (e) {
//         logger.log("An error occurred while saving file.");
//         logger.log("Error: $e");
//       }
//     } else {
//       logger.log("Unable to determine the download path.");
//     }
//     return pdfFile;
//   }
//
//   // Generate a simple PDF with a single image and a header
//   static Future<File> generateSimplePDF() async {
//     final pdf = pw.Document();
//
//     final ByteData bytesImage =
//     await rootBundle.load('assets/images/hand_phone.png');
//     final Uint8List bgBytes = bytesImage.buffer.asUint8List();
//
//     pdf.addPage(
//       pw.Page(
//         margin: const pw.EdgeInsets.all(10),
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Image(
//                   pw.MemoryImage(bgBytes),
//                   fit: pw.BoxFit.fitHeight,
//                   height: 400,
//                   width: 400,
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   "HeartLens Report",
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue900,
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Text(
//                   "Generated on: ${getCurrentDayDate()}",
//                   style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//     return await generatePdfFile('HeartLens_Simple_Report', pdf);
//   }
//
//   // Generate an advanced PDF with findings, diagnostic insights, and recommendations
//   static Future<File> generateAdvancedPDF(List<Student> students) async {
//     final pdf = pw.Document();
//
//     final ByteData bytesImage =
//     await rootBundle.load('assets/images/template.png');
//     final Uint8List bgBytes = bytesImage.buffer.asUint8List();
//
//     var titleStyle = pw.TextStyle(
//       fontSize: 18,
//       fontWeight: pw.FontWeight.bold,
//       color: PdfColors.blue900,
//     );
//
//     var headingStyle = pw.TextStyle(
//       fontSize: 14,
//       fontWeight: pw.FontWeight.bold,
//       color: PdfColors.black,
//     );
//     const textStyle = pw.TextStyle(fontSize: 12, color: PdfColors.black);
//
//     pdf.addPage(
//       pw.Page(
//         margin: const pw.EdgeInsets.all(10),
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             mainAxisAlignment: pw.MainAxisAlignment.start,
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text("HeartLens Report", style: titleStyle),
//               pw.SizedBox(height: 20),
//               pw.Text("Findings", style: headingStyle),
//               pw.SizedBox(height: 10),
//               pw.Text("ECG Analysis Summary", style: headingStyle),
//               pw.SizedBox(height: 10),
//               pw.Text("ST-Segment", style: headingStyle),
//               pw.SizedBox(height: 10),
//               // pw.Text(ST_segment, style: headingStyle),
//               pw.SizedBox(height: 10),
//
//
//
//               // pw.Text(findings, style: textStyle),
//               pw.SizedBox(height: 20),
//               pw.Text("Diagnostic Insights", style: headingStyle),
//               pw.SizedBox(height: 10),
//               // pw.Text(diagnosticInsights, style: textStyle),
//               pw.SizedBox(height: 20),
//               pw.Text("Recommendations", style: headingStyle),
//               pw.SizedBox(height: 10),
//               // pw.Text(recommendations, style: textStyle),
//             ],
//           );
//         },
//       ),
//     );
//     return await generatePdfFile('HeartLens_Advanced_Report', pdf);
//   }
// }



// import 'dart:io';
// import 'dart:developer' as logger show log;
//
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// import '../data/student.dart';
// import 'pdf_widgets.dart';
//
// class PdfUtils {
//   PdfUtils._();
//   static String getCurrentDayDate() {
//     DateTime now = DateTime.now();
//     String dayWithOrdinal = getDayWithOrdinal(now.day);
//     return DateFormat("d MMM, yyyy").format(now).replaceFirstMapped(
//       RegExp(r'\d+'),
//           (match) => dayWithOrdinal,
//     );
//   }
//
//   static String getDayWithOrdinal(int day) {
//     if (day >= 11 && day <= 13) {
//       return '${day}th';
//     }
//     switch (day % 10) {
//       case 1:
//         return '${day}st';
//       case 2:
//         return '${day}nd';
//       case 3:
//         return '${day}rd';
//       default:
//         return '${day}th';
//     }
//   }
//
//   static Future<String> downloadDir() async {
//     if (Platform.isMacOS) {
//       return '/Users/${Platform.environment['USER']}/Downloads';
//     } else if (Platform.isWindows) {
//       return '${Platform.environment['USERPROFILE']}\\Downloads';
//     } else if (Platform.isLinux) {
//       return '/home/${Platform.environment['USER']}/Downloads';
//     } else if (Platform.isAndroid) {
//       Directory directory = Directory('/storage/emulated/0/Download');
//       return directory.path;
//     } else {
//       return '/';
//     }
//   }
//
//   static Future<File> generatePdfFile(String fileName, pw.Document pdf) async {
//     late File pdfFile;
//     final path = await downloadDir();
//
//     if (path.isNotEmpty) {
//       try {
//         pdfFile = File(join(path, '$fileName.pdf'));
//         logger.log('Saved to: ${pdfFile.path}');
//         await pdfFile.writeAsBytes(await pdf.save());
//         return pdfFile;
//       } catch (e) {
//         logger.log("An error occurred while saving file.");
//         logger.log("Error: $e");
//       }
//     } else {
//       logger.log("Unable to determine the download path.");
//     }
//     return pdfFile;
//   }
//
//   static Future<File> generateSimplePDF() async {
//     final pdf = pw.Document();
//
//     final ByteData bytesImage =
//     await rootBundle.load('assets/images/hand_phone.png');
//     final Uint8List bgBytes = bytesImage.buffer.asUint8List();
//
//     pdf.addPage(
//       pw.Page(
//         margin: const pw.EdgeInsets.all(10),
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Image(
//                   pw.MemoryImage(bgBytes),
//                   fit: pw.BoxFit.fitHeight,
//                   height: 400,
//                   width: 400,
//                 ),
//                 pw.SizedBox(height: 20),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//     return await generatePdfFile('My PDF Example', pdf);
//   }
//
//   static Future<File> generateAdvancedPDF(List<Student> students) async {
//     final pdf = pw.Document();
//
//     final ByteData bytesImage =
//     await rootBundle.load('assets/images/template.png');
//     final Uint8List bgBytes = bytesImage.buffer.asUint8List();
//
//     const textStyle1 = pw.TextStyle(fontSize: 12);
//     var textStyle2 = pw.TextStyle(
//         fontSize: 12, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold);
//
//     var introductionTexts = pw.Table(
//       children: [
//         pw.TableRow(
//           children: [
//             pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 textItem(title: 'Class:', style: textStyle2),
//                 textItem(title: 'Course:', style: textStyle2),
//                 textItem(title: 'Date:', style: textStyle2),
//                 textItem(title: 'Lecturer:', style: textStyle2),
//               ],
//             ),
//             pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 textItem(title: 'BBIT23A', style: textStyle2),
//                 textItem(
//                   title: 'Object Oriented Programming OOP001',
//                   style: textStyle2,
//                 ),
//                 textItem(title: getCurrentDayDate(), style: textStyle2),
//                 textItem(title: 'Siro Devs', style: textStyle2),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//     List<pw.TableRow> rowItems = [];
//     rowItems.add(
//       pw.TableRow(
//         children: [
//           textItem(title: '', style: textStyle2),
//           textItem(title: 'Student', style: textStyle2),
//           textItem(title: 'Cat 1', style: textStyle2),
//           textItem(title: 'Cat 2', style: textStyle2),
//           textItem(title: 'End-Term', style: textStyle2),
//           textItem(title: 'Avg', style: textStyle2),
//         ],
//       ),
//     );
//     for (int i = 0; i < students.length; i++) {
//       Student student = students[i];
//       int avg =
//       (((((student.cat1 + student.cat2) / 60) * 100) + student.endterm) / 2)
//           .round();
//       rowItems.add(
//         pw.TableRow(
//           children: [
//             textItem(title: '${(i + 1)}.', style: textStyle1),
//             textItem(title: student.name, style: textStyle1),
//             textItem(title: student.cat1.toString(), style: textStyle1),
//             textItem(title: student.cat2.toString(), style: textStyle1),
//             textItem(title: student.endterm.toString(), style: textStyle1),
//             textItem(title: '$avg%', style: textStyle1),
//           ],
//         ),
//       );
//     }
//
//     var tableWidget = pw.Table(
//       border: pw.TableBorder.all(),
//       children: rowItems,
//     );
//
//
//     pdf.addPage(
//       pw.Page(
//         margin: const pw.EdgeInsets.all(10),
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Container(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 15),
//             decoration: pw.BoxDecoration(
//               image: pw.DecorationImage(
//                 fit: pw.BoxFit.cover,
//                 image: pw.MemoryImage(bgBytes),
//               ),
//             ),
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.SizedBox(height: 120),
//                 introductionTexts,
//                 pw.SizedBox(height: 10),
//                 tableWidget,
//               ],
//             ),
//           );
//         },
//       ),
//     );
//     return await generatePdfFile('My PDF Example', pdf);
//   }
// }
