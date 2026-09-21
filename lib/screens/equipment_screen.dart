import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';

class EquipmentScreen extends StatefulWidget {
  final AppStore store;
  const EquipmentScreen({super.key, required this.store});
  @override State<EquipmentScreen> createState()=>_EquipmentScreenState();
}
class _EquipmentScreenState extends State<EquipmentScreen> {
  String q='';
  @override Widget build(BuildContext context) {
    final items=widget.store.equipment.where((e)=>'${e.tag} ${e.name} ${e.area}'.toLowerCase().contains(q.toLowerCase())).toList();
    return ListView(children:[
      const OperonHeader('Equipment', subtitle:'Status, notes and history'),
      Padding(padding:const EdgeInsets.symmetric(horizontal:20),child:TextField(onChanged:(v)=>setState(()=>q=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search tag or equipment'))),
      const SizedBox(height:12),
      ...items.map((e)=>Card(margin:const EdgeInsets.symmetric(horizontal:20,vertical:6),child:ListTile(
        onTap:()=>_details(e), title:Text(e.tag,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${e.name}\n${e.note.isEmpty ? e.area : e.note}'),isThreeLine:true,
        trailing:Text(e.state.name,style:const TextStyle(color:OperonTheme.teal,fontSize:11,fontWeight:FontWeight.w700)),
      ))),
      const SizedBox(height:100),
    ]);
  }
  void _details(Equipment e)=>showModalBottomSheet(context:context,isScrollControlled:true,showDragHandle:true,builder:(context)=>Padding(
    padding:const EdgeInsets.fromLTRB(20,0,20,40),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(e.tag,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text(e.name,style:const TextStyle(color:OperonTheme.muted)),const SizedBox(height:20),
      Wrap(spacing:8,runSpacing:8,children:EquipmentState.values.map((s)=>ChoiceChip(label:Text(s.name),selected:e.state==s,onSelected:(_){widget.store.setEquipmentState(e,s);Navigator.pop(context);})).toList()),
      const SizedBox(height:18),Text(e.note.isEmpty?'No active note':e.note),
    ]),
  ));
}
