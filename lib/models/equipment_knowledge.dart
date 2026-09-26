class EquipmentKnowledge{
 final String tag;String normalRange,operatorNotes,valvePosition,processCircuit;List<String> relatedTags,procedureRefs;String source;DateTime updatedAt;
 EquipmentKnowledge({required this.tag,this.normalRange='',this.operatorNotes='',this.valvePosition='',this.processCircuit='',this.relatedTags=const[],this.procedureRefs=const[],this.source='',DateTime? updatedAt}):updatedAt=updatedAt??DateTime.now();
 Map<String,dynamic> toJson()=>{'tag':tag,'normalRange':normalRange,'operatorNotes':operatorNotes,'valvePosition':valvePosition,'processCircuit':processCircuit,'relatedTags':relatedTags,'procedureRefs':procedureRefs,'source':source,'updatedAt':updatedAt.toIso8601String()};
 factory EquipmentKnowledge.fromJson(Map<String,dynamic> j)=>EquipmentKnowledge(tag:j['tag']??'',normalRange:j['normalRange']??'',operatorNotes:j['operatorNotes']??'',valvePosition:j['valvePosition']??'',processCircuit:j['processCircuit']??'',relatedTags:List<String>.from(j['relatedTags']??[]),procedureRefs:List<String>.from(j['procedureRefs']??[]),source:j['source']??'',updatedAt:DateTime.tryParse(j['updatedAt']??''));
 bool get hasContent=>normalRange.isNotEmpty||operatorNotes.isNotEmpty||valvePosition.isNotEmpty||processCircuit.isNotEmpty||relatedTags.isNotEmpty||procedureRefs.isNotEmpty;
}
