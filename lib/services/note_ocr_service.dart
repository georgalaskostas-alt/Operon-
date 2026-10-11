import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class NoteOcrResult {
  final String imagePath;
  final String text;
  const NoteOcrResult(this.imagePath, this.text);
}

class NoteOcrService {
  final ImagePicker _picker = ImagePicker();

  Future<NoteOcrResult?> scan() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (photo == null) return null;

    final persistentPath = await _persistOriginal(photo.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(persistentPath),
      );
      return NoteOcrResult(persistentPath, result.text);
    } catch (_) {
      final file = File(persistentPath);
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    } finally {
      await recognizer.close();
    }
  }

  Future<void> discardUncommittedOriginal(String imagePath) async {
    if (imagePath.isEmpty) return;
    final root = await getApplicationSupportDirectory();
    final originals = Directory(p.join(root.path, 'operon', 'ocr_originals'));
    final expectedDirectory = p.normalize(originals.absolute.path);
    final file = File(imagePath);
    if (p.normalize(file.absolute.parent.path) != expectedDirectory) return;
    if (!p.basename(imagePath).startsWith('scan_')) return;
    if (await file.exists()) await file.delete();
  }

  Future<String> _persistOriginal(String sourcePath) async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'operon', 'ocr_originals'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final source = File(sourcePath);
    final extension = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath).toLowerCase();
    final id = DateTime.now().microsecondsSinceEpoch;
    final destination = p.join(dir.path, 'scan_$id$extension');
    final copied = await source.copy(destination);
    return copied.path;
  }
}
