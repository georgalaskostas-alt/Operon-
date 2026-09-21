import '../models/models.dart';
enum DraftKind{log,action,watch}
class ScanDraft{final DraftKind kind;final String text;final String? tag;final double tagConfidence;bool selected;ScanDraft(this.kind,this.text,{this.tag,this.tagConfidence=0,this.selected=true});}
class _Match{final String? tag;final double confidence;const _Match(this.tag,this.confidence);}
class NoteInterpreter{
 List<ScanDraft> interpret(String raw,List<Equipment> equipment){
  final drafts=<ScanDraft>[];
  for(final source in raw.split(RegExp(r'[\n;]+'))){
   final line=source.trim();if(line.isEmpty)continue;
   final m=_matchTag(line,equipment),low=line.toLowerCase();
   final kind=(low.contains('check')||low.contains('έλεγχ')||low.contains('να ')||low.contains('pending')||low.contains('εκκρεμ'))?DraftKind.action:(low.contains('monitor')||low.contains('watch')||low.contains('παρακολ')||low.contains('πρόσεχε'))?DraftKind.watch:DraftKind.log;
   drafts.add(ScanDraft(kind,line,tag:m.tag,tagConfidence:m.confidence));
  }return drafts;
 }
 _Match _matchTag(String line,List<Equipment> equipment){
  final normalized=_norm(line);
  for(final e in equipment){if(normalized.contains(_norm(e.tag)))return _Match(e.tag,1);}
  final tokens=line.toUpperCase().split(RegExp(r'\s+')).map(_norm).where((x)=>x.length>=4);
  String? best;var score=0.0;
  for(final token in tokens){for(final e in equipment){final tag=_norm(e.tag);final d=_lev(token,tag);final s=1-d/(token.length>tag.length?token.length:tag.length);if(s>score){score=s;best=e.tag;}}}
  return score>=.72?_Match(best,score):const _Match(null,0);
 }
 String _norm(String s)=>s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'),'').replaceAll('O','0').replaceAll('I','1');
 int _lev(String a,String b){final p=List<int>.generate(b.length+1,(i)=>i);for(var i=1;i<=a.length;i++){var prev=p[0];p[0]=i;for(var j=1;j<=b.length;j++){final old=p[j];p[j]=a[i-1]==b[j-1]?prev:[prev,p[j],p[j-1]].reduce((x,y)=>x<y?x:y)+1;prev=old;}}return p[b.length];}
}
