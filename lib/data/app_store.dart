import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/shift_handover.dart';
import 'local_repository.dart';

class AppStore extends ChangeNotifier {
  final LocalRepository _repository=LocalRepository();
  bool hydrated=false;
  ShiftSession? currentShift;
  final List<ShiftHandover> handovers=[];

  Future<void> hydrate() async {
    final s=await _repository.load();
    if(s!=null){
      equipment..clear()..addAll(((s['equipment'] as List?)??[]).map((e)=>Equipment.fromJson(Map<String,dynamic>.from(e))));
      logs..clear()..addAll(((s['logs'] as List?)??[]).map((e)=>LogEntry.fromJson(Map<String,dynamic>.from(e))));
      watch..clear()..addAll(((s['watch'] as List?)??[]).map((e)=>WatchItem.fromJson(Map<String,dynamic>.from(e))));
      tasks..clear()..addAll(((s['tasks'] as List?)??[]).map((e)=>OperatorTask.fromJson(Map<String,dynamic>.from(e))));
      if(s['currentShift']!=null) currentShift=ShiftSession.fromJson(Map<String,dynamic>.from(s['currentShift']));
      handovers..clear()..addAll(((s['handovers'] as List?)??[]).map((e)=>ShiftHandover.fromJson(Map<String,dynamic>.from(e))));
    }
    hydrated=true; notifyListeners();
  }
  Future<void> _persist()=>_repository.save({'equipment':equipment.map((e)=>e.toJson()).toList(),'logs':logs.map((e)=>e.toJson()).toList(),'watch':watch.map((e)=>e.toJson()).toList(),'tasks':tasks.map((e)=>e.toJson()).toList(),'currentShift':currentShift?.toJson(),'handovers':handovers.map((e)=>e.toJson()).toList()});
  void _changed(){notifyListeners();_persist();}

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
  final List<ProcedureItem> procedures = const [
    ProcedureItem('Pump changeover','Operations','Approved procedure required'),
    ProcedureItem('Equipment isolation','Safety','Official LOTO/PTW procedure required'),
    ProcedureItem('Shift handover','Operations','OPERON checklist'),
  ];

  void addLog(String text,{String? tag}){final clean=text.trim();if(clean.isEmpty)return;logs.insert(0,LogEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),createdAt:DateTime.now(),text:clean,equipmentTag:tag));_changed();}
  void setEquipmentState(Equipment item,EquipmentState state){item.state=state;addLog('${item.tag} → ${state.name}',tag:item.tag);}
  void addWatch(String title,String detail,{String? tag}){watch.insert(0,WatchItem(id:DateTime.now().microsecondsSinceEpoch.toString(),title:title,detail:detail,equipmentTag:tag));_changed();}
  void addTask(String title,{String? tag}){final clean=title.trim();if(clean.isEmpty)return;tasks.insert(0,OperatorTask(id:DateTime.now().microsecondsSinceEpoch.toString(),title:clean,equipmentTag:tag));addLog('Action created: $clean',tag:tag);}
  void setTaskState(OperatorTask task,ActionState state){task.state=state;addLog('Action ${task.title} → ${state.name}',tag:task.equipmentTag);}
  void completeTask(OperatorTask task){setTaskState(task,ActionState.completed);}
  void startShift(String operatorName,ShiftType type){if(currentShift?.active==true)return;for(final t in tasks.where((x)=>x.state!=ActionState.completed)){t.carriedShifts++;}currentShift=ShiftSession(id:DateTime.now().microsecondsSinceEpoch.toString(),operatorName:operatorName.trim(),type:type,startedAt:DateTime.now(),openingLogIndex:logs.length);addLog('Shift started · ${type.name} · ${operatorName.trim()}');}
  void endShift(){final s=currentShift;if(s==null||!s.active)return;s.endedAt=DateTime.now();addLog('Shift ended · ${s.type.name} · ${s.operatorName}');}
  void saveHandover(ShiftHandover h){handovers.insert(0,h);addLog('Handover prepared · ${h.outgoingOperator} · ${h.outgoingShift}');}
  void acceptHandover(ShiftHandover h,String incoming){if(h.accepted)return;h.incomingOperator=incoming.trim();h.acceptedAt=DateTime.now();addLog('Handover accepted · ${h.outgoingOperator} → ${incoming.trim()}');}
  ShiftHandover? get pendingHandover {for(final h in handovers){if(!h.accepted)return h;}return null;}
  List<OperatorTask> get carriedTasks=>tasks.where((e)=>e.state!=ActionState.completed&&e.carriedShifts>0).toList()..sort((a,b)=>b.carriedShifts.compareTo(a.carriedShifts));
  List<OperatorTask> get overdueTasks=>tasks.where((e)=>e.overdue).toList();
  List<OperatorTask> get newShiftTasks {final s=currentShift;if(s==null)return const[];return tasks.where((e)=>!e.createdAt.isBefore(s.startedAt)).toList();}
  List<LogEntry> get currentShiftLogs {final s=currentShift;if(s==null)return const[];return logs.where((e)=>!e.createdAt.isBefore(s.startedAt)&&(s.endedAt==null||!e.createdAt.isAfter(s.endedAt!))).toList();}
}
