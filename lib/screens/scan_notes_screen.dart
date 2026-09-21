import 'package:flutter/material.dart';
import '../data/app_store.dart';import '../services/note_ocr_service.dart';import '../services/note_interpreter.dart';import '../theme/operon_theme.dart';
class ScanNotesScreen extends StatefulWidget{final AppStore store;const ScanNotesScreen({super.key,required this.store});@override State<ScanNotesScreen> createState()=>_S();}
class _S extends State<ScanNotesScreen>{
 final ocr=NoteOcrService(),interpreter=NoteInterpreter();String raw='';List<ScanDraft> drafts=[];bool busy=false;
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Scan handwritten notes')),body:ListView(padding:const EdgeInsets.all(16),children:[
  const Card(child:ListTile(leading:Icon(Icons.document_scanner,color:OperonTheme.teal),title:Text('Photo → OCR → operator review'),subtitle:Text('Nothing is committed automatically. Review every extracted item before saving.'))),
  FilledButton.icon(onPressed:busy?null:_scan,icon:const Icon(Icons.camera_alt),label:Text(busy?'Reading…':'Photograph note')),
  if(raw.isNotEmpty)...[const SizedBox(height:16),TextField(controller:TextEditingController(text:raw),maxLines:7,readOnly:true,decoration:const InputDecoration(labelText:'Recognized text')),const SizedBox(height:16),const Text('Proposed entries',style:TextStyle(fontWeight:FontWeight.w800,fontSize:18)),...drafts.map((d)=>CheckboxListTile(value:d.selected,onChanged:(v)=>setState(()=>d.selected=v??false),title:Text(d.text),subtitle:Text('${d.kind.name.toUpperCase()} · ${d.tag??'No matched tag'}${d.tag!=null&&d.tagConfidence<.9?' · CHECK TAG ${(d.tagConfidence*100).round()}%':''}'))),FilledButton.icon(onPressed:_commit,icon:const Icon(Icons.verified_user),label:const Text('Confirm selected entries'))]
 ]));
 Future<void> _scan()async{setState(()=>busy=true);try{final r=await ocr.scan();if(r==null)return;setState((){raw=r.text;drafts=interpreter.interpret(raw,widget.store.equipment);});}finally{if(mounted)setState(()=>busy=false);}}
 void _commit(){for(final d in drafts.where((x)=>x.selected)){switch(d.kind){case DraftKind.log:widget.store.addLog(d.text,tag:d.tag);case DraftKind.action:widget.store.addTask(d.text,tag:d.tag);case DraftKind.watch:widget.store.addWatch('Scanned watch item',d.text,tag:d.tag);}}Navigator.pop(context);}
}
