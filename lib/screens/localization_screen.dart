import 'package:flutter/material.dart';

class LocalizationScreen extends StatefulWidget {
  final String miType;

  const LocalizationScreen({super.key, required this.miType});

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen>
    with SingleTickerProviderStateMixin {
  late List<String> affectedLeads;
  final Map<String, String> leadToWall = {
    "I": "Lateral Wall",
    "II": "Inferior Wall",
    "III": "Inferior Wall",
    "aVR": "Right Atrium",
    "aVL": "Lateral Wall",
    "aVF": "Inferior Wall",
    "V1": "Septal Wall",
    "V2": "Septal Wall",
    "V3": "Anterior Wall",
    "V4": "Anterior Wall",
    "V5": "Lateral Wall",
    "V6": "Lateral Wall",
  };

  final List<List<String>> leadGrid = const [
    ['I', 'II', 'III'],
    ['aVR', 'aVL', 'aVF'],
    ['V1', 'V2', 'V3'],
    ['V4', 'V5', 'V6'],
  ];

  String? selectedLead;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize affected leads based on MI type
    affectedLeads = _getAffectedLeads(widget.miType);

    // Set up heart animation
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _heartAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  List<String> _getAffectedLeads(String miType) {
    // Return empty list if no MI type specified
    if (miType.isEmpty || miType == 'No MI Detected') {
      return [];
    }

    // Normalize the input
    final normalizedType = miType.toLowerCase().trim();

    // Map MI types to affected leads
    if (normalizedType.contains('anterior')) {
      return ['V1', 'V2', 'V3', 'V4'];
    } else if (normalizedType.contains('lateral')) {
      return ['I', 'aVL', 'V5', 'V6'];
    } else if (normalizedType.contains('inferior')) {
      return ['II', 'III', 'aVF'];
    } else if (normalizedType.contains('septal')) {
      return ['V1', 'V2'];
    }

    return []; // Default for unknown types
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text(
          'Localization of STEMI',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF932828),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Beating Heart Image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ScaleTransition(
                scale: _heartAnimation,
                child: Image.asset(
                  'assets/heart.png',
                  height: 300,
                  width: 250,
                  fit: BoxFit.fill,
                ),
              ),
            ),

            // Instruction Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffe3dede),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xffe0513f),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF856404)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'View affected heart regions by clicking on the affected leads',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lead Buttons Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: leadGrid.map((row) {
                  return Row(
                    children: row.map((lead) {
                      final isAffected = affectedLeads.contains(lead);
                      final isSelected = selectedLead == lead;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAffected
                                  ? const Color(0xFFD23939)
                                  : const Color(0xFFFFD1D1),
                              foregroundColor:
                              isAffected ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: isSelected
                                    ? const BorderSide(
                                    color: Color(0xFF932828), width: 2)
                                    : BorderSide.none,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isAffected
                                ? () {
                              setState(() {
                                selectedLead = lead;
                              });
                            }
                                : null,
                            child: Text(
                              lead == 'I' || lead == 'II' || lead == 'III'
                                  ? 'Lead $lead'
                                  : lead,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isAffected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),

            // Information Section
            if (selectedLead != null && affectedLeads.contains(selectedLead))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA2A2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD23939)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLead!.length <= 2
                            ? 'Lead $selectedLead'
                            : selectedLead!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF932828),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Affected Region: ${leadToWall[selectedLead]}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// class LocalizationScreen extends StatefulWidget {
//   final String miType;
//
//   const LocalizationScreen({super.key, required this.miType});
//   @override
//   State<LocalizationScreen> createState() => _LocalizationScreenState();
// }
//
// class _LocalizationScreenState extends State<LocalizationScreen>
//     with SingleTickerProviderStateMixin {
//   late List<String> affectedLeads; // Changed to late since we'll initialize it in initState
//   final Map<String, String> leadToWall = {
//     "I": "Lateral Wall",
//     "II": "Inferior Wall",
//     "III": "Inferior Wall",
//     "aVR": "Right Atrium",
//     "aVL": "Lateral Wall",
//     "aVF": "Inferior Wall",
//     "V1": "Septal Wall",
//     "V2": "Septal Wall",
//     "V3": "Anterior Wall",
//     "V4": "Anterior Wall",
//     "V5": "Lateral Wall",
//     "V6": "Lateral Wall",
//   };
//
//   final List<List<String>> leadGrid = const [
//     ['I', 'II', 'III'],
//     ['aVR', 'aVL', 'aVF'],
//     ['V1', 'V2', 'V3'],
//     ['V4', 'V5', 'V6'],
//   ];
//
//   String? selectedLead;
//   late AnimationController _heartController;
//   late Animation<double> _heartAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize affected leads based on MI type
//     affectedLeads = _getAffectedLeads(widget.miType);
//
//     _heartController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..repeat(reverse: true);
//
//     _heartAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
//     );
//   }
//
//   List<String> _getAffectedLeads(String miType) {
//     // Default to empty list if no MI or type not specified
//     if (miType.isEmpty || miType == 'No MI Detected') {
//       return [];
//     }
//
//     // Map MI types to affected leads
//     switch (miType.toLowerCase()) {
//       case 'anterior':
//       case 'anterior wall':
//         return ['V1', 'V2', 'V3', 'V4']; // Anterior leads
//       case 'lateral':
//       case 'lateral wall':
//         return ['I', 'aVL', 'V5', 'V6']; // Lateral leads
//       case 'inferior':
//       case 'inferior wall':
//         return ['II', 'III', 'aVF']; // Inferior leads
//       case 'septal':
//         return ['V1', 'V2']; // Septal leads
//       case 'posterior':
//         return []; // Posterior would need special handling (reciprocal changes)
//       default:
//         return []; // Unknown type
//     }
//   }
//
//   String? selectedLead;
//   late AnimationController _heartController;
//   late Animation<double> _heartAnimation;
//
//
//
//
//   @override
//   void dispose() {
//     _heartController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: const Color(0xffefe4e7),
//       backgroundColor: const Color(0xffffffff),
//       appBar: AppBar(
//         title: const Text(
//           'Localization of STEMI',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF932828),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.zero,
//         child: Column(
//           children: [
//             // Beating Heart Image
//             Padding(
//               //padding: const EdgeInsets.all(13.0),
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//               child: ScaleTransition(
//                 scale: _heartAnimation,
//                 child: Image.asset(
//                   'assets/heart.png',
//                   height: 300,
//                   width: 250,
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//
//             // Alert-style instruction box
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
//               decoration: BoxDecoration(
//                 //color: const Color(0xFFFFF3CD),
//                 color: const Color(0xffe3dede),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   //color: const Color(0xFFFFEEBA),
//                   color: const Color(0xffe0513f),
//                   width: 1.5,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.info_outline, color: Color(0xFF856404)),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'View affected heart regions by clicking on the affected leads',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Lead buttons grid
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 children: leadGrid.map((row) {
//                   return Row(
//                     children: row.map((lead) {
//                       bool isAffected = affectedLeads.contains(lead);
//                       bool isSelected = selectedLead == lead;
//
//                       return Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: isAffected
//                                       ? const Color(0xFFD23939)
//                                       : const Color(0xFFFFD1D1),
//                                   foregroundColor:
//                                   isAffected ? Colors.white : Colors.black,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     side: isSelected
//                                         ? const BorderSide(
//                                         color: Color(0xFF932828), width: 2)
//                                         : BorderSide.none,
//                                   ),
//                                   padding:
//                                   const EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     if (isAffected) {
//                                       selectedLead = lead;
//                                     }
//                                   });
//                                 },
//                                 child: Text(
//                                   lead == 'I' || lead == 'II' || lead == 'III'
//                                       ? 'Lead $lead'
//                                       : lead,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: isAffected
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                                   ),
//                                 ),
//                               ),
//                               // if (isAffected)
//                               //Container(
//                               //decoration: BoxDecoration(
//                               //borderRadius: BorderRadius.circular(8),
//                               //boxShadow: [
//                               //BoxShadow(
//                               //color: const Color(0xFFD23939)
//                               // .withOpacity(0.5),
//                               //spreadRadius: 3,
//                               //blurRadius: 10,
//                               //offset: const Offset(0, 0),
//                               //),
//                               //],
//                               //),
//                               // ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 }).toList(),
//               ),
//             ),
//
//             // Information section
//             if (selectedLead != null && affectedLeads.contains(selectedLead))
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFA2A2),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFD23939)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         selectedLead!.length <= 2
//                             ? 'Lead $selectedLead'
//                             : selectedLead!,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF932828),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Affected Region: ${leadToWall[selectedLead]}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
