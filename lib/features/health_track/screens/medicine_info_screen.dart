import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'medicine_service.dart';
import 'medicine_viewer_widget.dart';

class medicineAnalysisScreen extends StatefulWidget {
  const medicineAnalysisScreen({super.key});

  @override
  _medicineAnalysisScreenState createState() => _medicineAnalysisScreenState();
}

class _medicineAnalysisScreenState extends State<medicineAnalysisScreen> {
  bool isLoading = false;
  bool isAnalyzing = false;
  List<Map<String, dynamic>> medicines = [];
  final MedicineService _medicineService = MedicineService();

  @override
  void initState() {
    super.initState();
    _loadmedicines();
  }

  Future<void> _loadmedicines() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    try {
      final loadedmedicines = await _medicineService.getmedicines();
      setState(() => medicines = loadedmedicines);
    } catch (e) {
      _showError('Error loading medicines', e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadmedicine() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() => isAnalyzing = true);

        final file = File(result.files.single.path!);
        await _medicineService.analyzemedicine(file);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('medicine analyzed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadmedicines();
      }
    } catch (e) {
      _showError('Error analyzing medicine', e);
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  void _showError(String title, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(error.toString(), style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 240, 244),
      appBar: AppBar(
        title: const Text('Know about your Medicine',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 12, 141, 145),
        elevation: 4,
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.teal))
          else if (medicines.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description_outlined,
                      size: 64, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text('No medicines Yet',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  const SizedBox(height: 8),
                  const Text(
                      'Upload an image of tablet sheet to know about your medicine',
                      style:
                          TextStyle(color: Color.fromARGB(255, 2, 116, 114))),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _uploadmedicine,
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text('Upload TableSheet',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            )
          else
            RefreshIndicator(
              color: Colors.teal,
              onRefresh: _loadmedicines,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  return medicineViewerWidget(medicine: medicines[index]);
                },
              ),
            ),
          if (isAnalyzing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing tablet...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !isLoading && !isAnalyzing
          ? FloatingActionButton.extended(
              onPressed: _uploadmedicine,
              icon: Image.asset('assets/icons/upload.png', height: 44),
              label:
                  const Text('Upload', style: TextStyle(color: Colors.white)),
              backgroundColor: const Color.fromARGB(255, 3, 106, 115),
            )
          : null,
    );
  }
}
