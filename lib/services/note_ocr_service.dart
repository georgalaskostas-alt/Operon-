import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class NoteOcrResult{final String imagePath;final String text;const NoteOcrResult(this.imagePath,this.text);}
class NoteOcrService{
 final ImagePicker _picker=ImagePicker();
 Future<NoteOcrResult?> scan() async{
  final photo=await _picker.pickImage(source:ImageSource.camera,imageQuality:90);
  if(photo==null)return null;
  final recognizer=TextRecognizer(script:TextRecognitionScript.latin);
  try{final result=await recognizer.processImage(InputImage.fromFilePath(photo.path));return NoteOcrResult(photo.path,result.text);}
  finally{await recognizer.close();}
 }
}
