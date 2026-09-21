import '../models/models.dart';
enum DraftKind{log,action,watch}
class ScanDraft{final DraftKind kind;final String text;final String? tag;bool selected;ScanDraft(this.kind,this.text,{this.tag,this.selected=true});}
class NoteInterpreter{
 List<ScanDraft> interpret(String raw,List<Equipment> equipment){
  final drafts=<ScanDraft>[];
  for(final source in raw.split(RegExp(r'[\n;]+'))){
   final line=source.trim();if(line.isEmpty)continue;
   String? tag;
   final upper=line.toUpperCase();
   for(final e in equipment){if(upper.contains(e.tag.toUpperCase())){tag=e.tag;break;}}
   final low=line.toLowerCase();
   final kind=(low.contains('check')||low.contains('έλεγχ')||low.contains('να ')||low.contains('pending'))
    ?DraftKind.action
    :(low.contains('monitor')||low.contains('watch')||low.contains('παρακολ'))
      ?DraftKind.watch:DraftKind.log;
   drafts.add(ScanDraft(kind,line,tag:tag));
  }
  return drafts;
 }
}
