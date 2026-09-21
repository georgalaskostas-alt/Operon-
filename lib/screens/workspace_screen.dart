import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';

class WorkspaceScreen extends StatelessWidget {
  final AppStore store;
  const WorkspaceScreen({super.key, required this.store});
  @override Widget build(BuildContext context)=>ListView(children:[
    const OperonHeader('Workspace',subtitle:'Memory tools for the shift'),
    _tile(Icons.visibility_rounded,'Watch items','Equipment limits, abnormal conditions and things to remember'),
    _tile(Icons.timer_rounded,'Timers & reminders','Multiple operational timers with local notifications'),
    _tile(Icons.note_alt_rounded,'Notes','Personal and shift notes, linked to equipment'),
    _tile(Icons.document_scanner_rounded,'Scan handwritten notes','Photo → OCR → review → structured draft'),
    _tile(Icons.fact_check_rounded,'Procedures','Approved procedures and checklists with source/version'),
    _tile(Icons.account_tree_rounded,'Process circuits','Unit circuits, equipment relationships and references'),
    _tile(Icons.handshake_rounded,'Shift handover','Open items and shift summary'),
    _tile(Icons.auto_awesome_rounded,'Private AI','Local/RAG assistant — no paid chat API required'),
    const SizedBox(height:100),
  ]);
  Widget _tile(IconData i,String t,String s)=>Card(margin:const EdgeInsets.symmetric(horizontal:20,vertical:6),child:ListTile(leading:Icon(i,color:OperonTheme.teal),title:Text(t,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(s),trailing:const Icon(Icons.chevron_right)));
}
