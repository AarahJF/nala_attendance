import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qr_image_generator/qr_image_generator.dart';



class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key, required this.title});

  final String title;

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter CMS id',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              TextFormField(
                controller: textEditingController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: saveQRImage,
                child: const Text('Save QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future saveQRImage() async {
    FocusScope.of(context).unfocus();
    String? filePath = await FilePicker.platform.saveFile(
      fileName: textEditingController.text+".png",
      type: FileType.image,
    );
    if (filePath == null) {
      return;
    }

    final generator = QRGenerator();

    await generator.generate(
      data: textEditingController.text,
      filePath: filePath,
      scale: 10,
      padding: 2,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      errorCorrectionLevel: ErrorCorrectionLevel.medium,
    );
  }
}