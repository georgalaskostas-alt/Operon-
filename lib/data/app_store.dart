import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/shift_handover.dart';
import '../models/equipment_knowledge.dart';
import '../models/process_circuit.dart';
import '../models/operator_note.dart';
import '../models/procedure_models.dart';
import '../models/audit_event.dart';
import 'local_repository.dart';

class AppStore extends ChangeNotifier {
  final LocalRepository _repository=LocalRepository();
  bool hydrated=false;
  ShiftSession? currentShift;
  final List<ShiftHandover> handovers=[];
  final Map<String,EquipmentKnowledge> knowledge={};
  final List<ProcessCircuit> circuits=[];
  final List<OperatorNote> notes=[];
  final List<ProcedureRun> procedureRuns=[];
  final List<ShiftSession> shiftHistory=[];
  final List<AuditEvent> auditEvents=[];

  Future<void> hydrate() async {
    final s=await _repository.load();
    if(s!=null){
      equipment..clear()..addAll(((s['equipment'] as List?)??[]).map((e)=>Equipment.fromJson(Map<String,dynamic>.from(e))));
      logs..clear()..addAll(((s['logs'] as List?)??[]).map((e)=>LogEntry.fromJson(Map<String,dynamic>.from(e))));
      watch..clear()..addAll(((s['watch'] as List?)??[]).map((e)=>WatchItem.fromJson(Map<String,dynamic>.from(e))));
      tasks..clear()..addAll(((s['tasks'] as List?)??[]).map((e)=>OperatorTask.fromJson(Map<String,dynamic>.from(e))));
      currentShift=s['currentShift']==null?null:ShiftSession.fromJson(Map<String,dynamic>.from(s['currentShift']));
      handovers..clear()..addAll(((s['handovers'] as List?)??[]).map((e)=>ShiftHandover.fromJson(Map<String,dynamic>.from(e))));
      knowledge..clear()..addEntries(((s['knowledge'] as List?)??[]).map((e){final k=EquipmentKnowledge.fromJson(Map<String,dynamic>.from(e));return MapEntry(k.tag,k);}));
      circuits..clear()..addAll(((s['circuits'] as List?)??[]).map((e)=>ProcessCircuit.fromJson(Map<String,dynamic>.from(e))));
      notes..clear()..addAll(((s['notes'] as List?)??[]).map((e)=>OperatorNote.fromJson(Map<String,dynamic>.from(e))));
      procedureRuns..clear()..addAll(((s['procedureRuns'] as List?)??[]).map((e)=>ProcedureRun.fromJson(Map<String,dynamic>.from(e))));
      shiftHistory..clear()..addAll(((s['shiftHistory'] as List?)??[]).map((e)=>ShiftSession.fromJson(Map<String,dynamic>.from(e))));
      auditEvents..clear()..addAll(((s['auditEvents'] as List?)??[]).map((e)=>AuditEvent.fromJson(Map<String,dynamic>.from(e))));
    }
    hydrated=true; notifyListeners();
  }
  Future<void> _persist()=>_repository.save({'equipment':equipment.map((e)=>e.toJson()).toList(),'logs':logs.map((e)=>e.toJson()).toList(),'watch':watch.map((e)=>e.toJson()).toList(),'tasks':tasks.map((e)=>e.toJson()).toList(),'currentShift':currentShift?.toJson(),'handovers':handovers.map((e)=>e.toJson()).toList(),'knowledge':knowledge.values.map((e)=>e.toJson()).toList(),'circuits':circuits.map((e)=>e.toJson()).toList(),'notes':notes.map((e)=>e.toJson()).toList(),'procedureRuns':procedureRuns.map((e)=>e.toJson()).toList(),'shiftHistory':shiftHistory.map((e)=>e.toJson()).toList(),'auditEvents':auditEvents.map((e)=>e.toJson()).toList()});
  void _changed(){notifyListeners();_persist();}
  String _id()=>DateTime.now().microsecondsSinceEpoch.toString();
  void _audit(String type,String summary,{String? tag,String source='app',String? entityId}){auditEvents.insert(0,AuditEvent(id:DateTime.now().microsecondsSinceEpoch.toString(),type:type,summary:summary,source:source,createdAt:DateTime.now(),equipmentTag:tag,shiftId:currentShift?.id,entityId:entityId));}

  final List<Equipment> equipment = [
    Equipment(tag:'P-2101A',name:'Process Pump A',area:'Unit',state:EquipmentState.maintenance,note:'Mechanical inspection pending'),
    Equipment(tag:'P-2101B',name:'Process Pump B',area:'Unit'),
    Equipment(tag:'E-2204',name:'Process Exchanger',area:'Unit',note:'Monitor ΔP'),
    Equipment(tag:'FV-2205',name:'Flow Control Valve',area:'Unit',note:'Operating watch item'),
  ];
  final List<LogEntry> logs = [
    LogEntry(id:'1',createdAt:DateTime.now().subtract(const Duration(minutes:30)),text:'P-2101A stopped',equipmentTag:'P-2101A'),
    LogEntry(id:'2',createdAt:DateTime.now().subtract(const Duration(minutes:28)),text:'P-2101B started',equipmentTag:'P-2101B'),
    LogEntry(id:'3',createdAt:DateTime.now().subtract(const Duration(minutes:22)),text:'Maintenance informed',equipmentTag:'P-2101A'),
  ];
  final List<WatchItem> watch = [
    WatchItem(id:'w1',title:'Maintenance',detail:'Mechanical inspection pending',equipmentTag:'P-2101A'),
    WatchItem(id:'w2',title:'Monitor ΔP',detail:'Shift watch item',equipmentTag:'E-2204'),
  ];
  final List<OperatorTask> tasks = [OperatorTask(id:'t1',title:'Follow up mechanical inspection',equipmentTag:'P-2101A')];
  final List<ControlledProcedure> controlledProcedures=const [ControlledProcedure(id:'handover',title:'Shift handover',category:'Operations',source:'OPERON controlled checklist',version:'1.0',steps:[ProcedureStep(id:'open',title:'Review open actions'),ProcedureStep(id:'equipment',title:'Review unavailable / maintenance equipment'),ProcedureStep(id:'watch',title:'Review active watch items'),ProcedureStep(id:'timers',title:'Review incomplete timers'),ProcedureStep(id:'accept',title:'Incoming operator confirms receipt')])];
  final List<ProcedureItem> procedures = const [
    ProcedureItem('Pump changeover','Operations','Approved procedure required'),
    ProcedureItem('Equipment isolation','Safety','Official LOTO/PTW procedure required'),
    ProcedureItem('Shift handover','Operations','OPERON checklist'),
  ];

  void addLog(String text,{String? tag,String source='manual',Priority priority=Priority.normal}){final clean=text.trim();if(clean.isEmpty)return;final id=DateTime.now().microsecondsSinceEpoch.toString();logs.insert(0,LogEntry(id:id,createdAt:DateTime.now(),text:clean,equipmentTag:tag,source:source,priority:priority));_audit('log.created',clean,tag:tag,source:source,entityId:id);_changed();}
  void setEquipmentState(Equipment item,EquipmentState state){item.state=state;addLog('${item.tag} → ${state.name}',tag:item.tag);}
  void addWatch(String title,String detail,{String? tag}){watch.insert(0,WatchItem(id:DateTime.now().microsecondsSinceEpoch.toString(),title:title,detail:detail,equipmentTag:tag));_changed();}
  void addTask(String title,{String? tag}){final clean=title.trim();if(clean.isEmpty)return;tasks.insert(0,OperatorTask(id:DateTime.now().microsecondsSinceEpoch.toString(),title:clean,equipmentTag:tag,createdShiftId:currentShift?.id));addLog('Action created: $clean',tag:tag);}
  void setTaskState(OperatorTask task,ActionState state){task.state=state;addLog('Action ${task.title} → ${state.name}',tag:task.equipmentTag);}
  void completeTask(OperatorTask task){setTaskState(task,ActionState.completed);}
  void startShift(String operatorName,ShiftType type){
    final clean=operatorName.trim();
    if(clean.isEmpty||currentShift?.active==true)return;
    final id=_id(),now=DateTime.now();
    for(final t in tasks.where((x)=>x.state!=ActionState.completed)){
      final existedBeforeShift=t.createdAt.isBefore(now);
      if(existedBeforeShift&&t.lastCarriedShiftId!=id){
        t.carriedShifts++;
        t.lastCarriedShiftId=id;
      }
    }
    currentShift=ShiftSession(id:id,operatorName:clean,type:type,startedAt:now,openingLogIndex:logs.length);
    _audit('shift.started','${type.name} · $clean',source:'shift',entityId:id);
    addLog('Shift started · ${type.name} · $clean',source:'shift');
  }
  void endShift(){
    final s=currentShift;
    if(s==null||!s.active)return;
    s.endedAt=DateTime.now();
    if(!shiftHistory.any((x)=>x.id==s.id))shiftHistory.insert(0,s);
    _audit('shift.ended','${s.type.name} · ${s.operatorName}',source:'shift',entityId:s.id);
    addLog('Shift ended · ${s.type.name} · ${s.operatorName}',source:'shift');
  }
  void saveHandover(ShiftHandover h){
    if(handovers.any((x)=>x.id==h.id))return;
    handovers.insert(0,h);
    _audit('handover.prepared','${h.outgoingOperator} · ${h.outgoingShift}',source:'handover',entityId:h.id);
    addLog('Handover prepared · ${h.outgoingOperator} · ${h.outgoingShift}',source:'handover');
  }
  void acceptHandover(ShiftHandover h,String incoming){
    final clean=incoming.trim();
    if(h.accepted||clean.isEmpty)return;
    h.incomingOperator=clean;
    h.acceptedAt=DateTime.now();
    _audit('handover.accepted','${h.outgoingOperator} → $clean',source:'handover',entityId:h.id);
    addLog('Handover accepted · ${h.outgoingOperator} → $clean',source:'handover');
  }
  EquipmentKnowledge knowledgeFor(String tag)=>knowledge.putIfAbsent(tag,()=>EquipmentKnowledge(tag:tag));
  void saveKnowledge(EquipmentKnowledge item){item.updatedAt=DateTime.now();knowledge[item.tag]=item;addLog('Knowledge updated · ${item.tag}',tag:item.tag);}
  void saveCircuit(ProcessCircuit circuit){circuit.updatedAt=DateTime.now();final i=circuits.indexWhere((e)=>e.id==circuit.id);if(i<0){circuits.add(circuit);}else{circuits[i]=circuit;}addLog('Process circuit updated · ${circuit.name}');}
  List<ProcessCircuit> circuitsForTag(String tag)=>circuits.where((c)=>c.nodes.any((n)=>n.tag==tag)).toList();
  void addNote(String title,String body,{String? tag,bool pinned=false}){final clean=body.trim();if(clean.isEmpty)return;notes.insert(0,OperatorNote(id:DateTime.now().microsecondsSinceEpoch.toString(),createdAt:DateTime.now(),title:title.trim().isEmpty?'Operator note':title.trim(),body:clean,equipmentTag:tag,pinned:pinned));_changed();}
  void toggleNotePin(OperatorNote n){n.pinned=!n.pinned;_changed();}
  void resolveNote(OperatorNote n){n.resolved=true;addLog('Note resolved · ${n.title}',tag:n.equipmentTag);}
  void resolveWatch(WatchItem w){w.active=false;addLog('Watch item resolved · ${w.title}',tag:w.equipmentTag);}
  ProcedureRun startProcedure(ControlledProcedure p){final r=ProcedureRun(id:DateTime.now().microsecondsSinceEpoch.toString(),procedureId:p.id,procedureTitle:p.title,version:p.version,source:p.source,operatorName:currentShift?.operatorName??'Operator',startedAt:DateTime.now(),records:p.steps.map((e)=>StepRecord(stepId:e.id)).toList());procedureRuns.insert(0,r);addLog('Procedure started · ${p.title} · v${p.version}');return r;}
  void setProcedureStep(ProcedureRun r,String stepId,bool confirmed,{String note=''}){final x=r.records.firstWhere((e)=>e.stepId==stepId);x.confirmed=confirmed;x.confirmedAt=confirmed?DateTime.now():null;x.note=note;addLog('Procedure ${r.procedureTitle} · step $stepId → ${confirmed?'confirmed':'reopened'}');}
  void setProcedureRunState(ProcedureRun r,ProcedureRunState state){r.state=state;if(state==ProcedureRunState.completed)r.completedAt=DateTime.now();addLog('Procedure ${r.procedureTitle} → ${state.name}');}
  ShiftHandover? get pendingHandover {for(final h in handovers){if(!h.accepted)return h;}return null;}
  List<OperatorTask> get carriedTasks=>tasks.where((e)=>e.state!=ActionState.completed&&e.carriedShifts>0).toList()..sort((a,b)=>b.carriedShifts.compareTo(a.carriedShifts));
  List<OperatorTask> get overdueTasks=>tasks.where((e)=>e.overdue).toList();
  List<OperatorTask> get newShiftTasks {final s=currentShift;if(s==null)return const[];return tasks.where((e)=>!e.createdAt.isBefore(s.startedAt)).toList();}
  List<LogEntry> get currentShiftLogs {final s=currentShift;if(s==null)return const[];return logs.where((e)=>!e.createdAt.isBefore(s.startedAt)&&(s.endedAt==null||!e.createdAt.isAfter(s.endedAt!))).toList();}
}
