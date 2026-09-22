import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, el }

class AppLanguageController extends ChangeNotifier {
  static const _key = 'operon_language';
  AppLanguage _language = AppLanguage.en;

  AppLanguage get language => _language;
  Locale get locale => Locale(_language.name);

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == AppLanguage.el.name) {
      _language = AppLanguage.el;
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}

class OperonStrings {
  final AppLanguage language;
  const OperonStrings(this.language);

  bool get isGreek => language == AppLanguage.el;
  String pick(String en, String el) => isGreek ? el : en;

  String get home => pick('Home', 'Αρχική');
  String get equipment => pick('Equipment', 'Εξοπλισμός');
  String get logbook => pick('Logbook', 'Ημερολόγιο');
  String get more => pick('More', 'Περισσότερα');
  String get quickEntry => pick('Quick entry', 'Γρήγορη καταχώρηση');
  String get quickEntryHelp => pick(
    'Write only what happened. Time and source are automatic.',
    'Γράψε μόνο τι συνέβη. Η ώρα και η πηγή καταγράφονται αυτόματα.',
  );
  String get quickEntryHint => pick(
    'e.g. P-2101A seal leak, maintenance informed',
    'π.χ. P-2101A διαρροή σαλαμάστρας, ενημερώθηκε η συντήρηση',
  );
  String get scanNotes => pick('Scan notes', 'Σάρωση σημειώσεων');
  String get interpret => pick('Interpret', 'Ερμηνεία');
  String get workspace => pick('Workspace', 'Χώρος εργασίας');
  String get workspaceSubtitle => pick(
    'Memory tools for the shift',
    'Εργαλεία μνήμης για τη βάρδια',
  );
  String get pendingActions => pick('Pending actions', 'Εκκρεμείς ενέργειες');
  String get pendingActionsSub => pick(
    'Open, waiting and completed work',
    'Ανοιχτές, σε αναμονή και ολοκληρωμένες εργασίες',
  );
  String get watchItems => pick('Watch items', 'Σημεία παρακολούθησης');
  String get watchItemsSub => pick(
    'Limits, abnormal conditions and things to remember',
    'Όρια, μη κανονικές συνθήκες και σημεία που χρειάζονται προσοχή',
  );
  String get timers => pick('Timers & reminders', 'Χρονόμετρα & υπενθυμίσεις');
  String get timersSub => pick(
    'Operational timers and alerts',
    'Λειτουργικά χρονόμετρα και ειδοποιήσεις',
  );
  String get notes => pick('Notes', 'Σημειώσεις');
  String get notesSub => pick(
    'Personal and shift notes linked to equipment',
    'Προσωπικές σημειώσεις και σημειώσεις βάρδιας συνδεδεμένες με εξοπλισμό',
  );
  String get scanHandwritten => pick('Scan handwritten notes', 'Σάρωση χειρόγραφων σημειώσεων');
  String get scanHandwrittenSub => pick(
    'Photo → OCR → review → structured draft',
    'Φωτογραφία → OCR → έλεγχος → δομημένο προσχέδιο',
  );
  String get procedures => pick('Procedures', 'Διαδικασίες');
  String get proceduresSub => pick(
    'Approved procedures with source/version',
    'Εγκεκριμένες διαδικασίες με πηγή/έκδοση',
  );
  String get processCircuits => pick('Process circuits', 'Κυκλώματα διεργασίας');
  String get processCircuitsSub => pick(
    'Equipment relationships and references',
    'Συσχετίσεις εξοπλισμού και αναφορές',
  );
  String get handover => pick('Shift handover', 'Παράδοση βάρδιας');
  String get handoverSub => pick(
    'Open items and shift summary',
    'Ανοιχτά θέματα και σύνοψη βάρδιας',
  );
  String get privateAi => pick('Private AI', 'Ιδιωτικό AI');
  String get privateAiSub => pick(
    'Grounded assistant; local/RAG model milestone',
    'Βοηθός με τεκμηρίωση· στόχος τοπικού/RAG μοντέλου',
  );
  String get languageLabel => pick('Language', 'Γλώσσα');
  String get languageSub => pick('Choose app language', 'Επιλογή γλώσσας εφαρμογής');
  String get english => 'English';
  String get greek => 'Ελληνικά';

  String get statusNotesHistory => pick('Status, notes and history', 'Κατάσταση, σημειώσεις και ιστορικό');
  String get searchTagEquipment => pick('Search tag or equipment', 'Αναζήτηση TAG ή εξοπλισμού');
  String get immutableTimeline => pick('Immutable operator timeline', 'Αμετάβλητο χρονολόγιο χειριστή');
  String get general => pick('General', 'Γενικά');
  String get newAction => pick('New action', 'Νέα ενέργεια');
  String get action => pick('Action', 'Ενέργεια');
  String get equipmentTagOptional => pick('Equipment tag (optional)', 'TAG εξοπλισμού (προαιρετικό)');
  String get add => pick('Add', 'Προσθήκη');
  String get shiftHandover => pick('Shift handover', 'Παράδοση βάρδιας');
  String get waitingAcceptance => pick('HANDOVER WAITING FOR ACCEPTANCE', 'ΠΑΡΑΔΟΣΗ ΣΕ ΑΝΑΜΟΝΗ ΑΠΟΔΟΧΗΣ');
  String get incomingOperator => pick('Incoming operator', 'Παραλαμβάνων χειριστής');
  String get acceptHandover => pick('Accept handover', 'Αποδοχή παράδοσης');
  String get openActions => pick('Open actions', 'Ανοιχτές ενέργειες');
  String get unavailableMaintenance => pick('Equipment unavailable / maintenance', 'Μη διαθέσιμος εξοπλισμός / συντήρηση');
  String get timerReminders => pick('Timers / reminders', 'Χρονόμετρα / υπενθυμίσεις');
  String get noActiveTimers => pick('No active timers', 'Δεν υπάρχουν ενεργά χρονόμετρα');
  String get handoverNotes => pick('Handover notes', 'Σημειώσεις παράδοσης');
  String get prepareHandover => pick('Prepare handover', 'Προετοιμασία παράδοσης');
  String get handoverHistory => pick('Handover history', 'Ιστορικό παραδόσεων');
  String get pending => pick('Pending', 'Σε αναμονή');
  String get accepted => pick('Accepted', 'Αποδεκτή');
  String get awaitingAcceptance => pick('Awaiting acceptance', 'Αναμονή αποδοχής');
  String get timersReminders => pick('Timers & reminders', 'Χρονόμετρα & υπενθυμίσεις');
  String get completed => pick('COMPLETED', 'ΟΛΟΚΛΗΡΩΜΕΝΑ');
  String get acknowledge => pick('Acknowledge', 'Επιβεβαίωση');
  String get complete => pick('Complete', 'Ολοκλήρωση');
  String get newOperatorTimer => pick('New operator timer', 'Νέο χρονόμετρο χειριστή');
  String get reminder => pick('Reminder', 'Υπενθύμιση');
  String get startTimer => pick('Start timer', 'Έναρξη χρονομέτρου');
  String get check => pick('Check', 'Έλεγχος');
  String get proceduresChecklists => pick('Procedures & checklists', 'Διαδικασίες & checklists');
  String get procedureSafety => pick(
    'Use only site-controlled procedures. OPERON records operator progress; it does not replace the approved procedure, DCS/SIS, PTW or LOTO.',
    'Χρησιμοποίησε μόνο ελεγχόμενες διαδικασίες της εγκατάστασης. Το OPERON καταγράφει την πρόοδο του χειριστή· δεν αντικαθιστά την εγκεκριμένη διαδικασία, DCS/SIS, PTW ή LOTO.',
  );
  String get runHistory => pick('RUN HISTORY', 'ΙΣΤΟΡΙΚΟ ΕΚΤΕΛΕΣΕΩΝ');
  String get scanHandwrittenTitle => pick('Scan handwritten notes', 'Σάρωση χειρόγραφων σημειώσεων');
  String get ocrReview => pick('Photo → OCR → operator review', 'Φωτογραφία → OCR → έλεγχος χειριστή');
  String get ocrSafety => pick(
    'Nothing is committed automatically. Review every extracted item before saving.',
    'Τίποτα δεν καταχωρείται αυτόματα. Έλεγξε κάθε στοιχείο που εξήχθη πριν την αποθήκευση.',
  );
  String get reading => pick('Reading…', 'Ανάγνωση…');
  String get photographNote => pick('Photograph note', 'Φωτογράφιση σημείωσης');
  String get recognizedText => pick('Recognized text', 'Αναγνωρισμένο κείμενο');
  String get proposedEntries => pick('Proposed entries', 'Προτεινόμενες καταχωρήσεις');
  String get noMatchedTag => pick('No matched tag', 'Δεν βρέθηκε TAG');
  String get checkTag => pick('CHECK TAG', 'ΕΛΕΓΧΟΣ TAG');
  String get confirmSelected => pick('Confirm selected entries', 'Επιβεβαίωση επιλεγμένων καταχωρήσεων');
  String get scannedWatchItem => pick('Scanned watch item', 'Σαρωμένο σημείο παρακολούθησης');
  String get assistant => 'OPERON Assistant';
  String get groundedPrivate => pick('Grounded · private-first', 'Τεκμηριωμένο · private-first');
  String get assistantSafety => pick(
    'Answers are assembled only from recorded OPERON data and verified knowledge. Local LLM/RAG comes later.',
    'Οι απαντήσεις συντίθενται μόνο από καταγεγραμμένα δεδομένα OPERON και επαληθευμένη γνώση. Το τοπικό LLM/RAG θα προστεθεί αργότερα.',
  );
  String get askHint => pick('Ask about a TAG or this shift', 'Ρώτησε για ένα TAG ή για αυτή τη βάρδια');
  String get askOperon => pick('Ask OPERON', 'Ρώτησε το OPERON');
  String get sourcesUsed => pick('SOURCES USED', 'ΠΗΓΕΣ ΠΟΥ ΧΡΗΣΙΜΟΠΟΙΗΘΗΚΑΝ');
  String get shiftQuestion => pick('What should I know this shift?', 'Τι πρέπει να γνωρίζω σε αυτή τη βάρδια;');
  String get overdueActions => pick('Overdue actions', 'Εκπρόθεσμες ενέργειες');
}

extension OperonLocalization on BuildContext {
  OperonStrings get tr {
    final scope = dependOnInheritedWidgetOfExactType<OperonLanguageScope>();
    return OperonStrings(scope?.controller.language ?? AppLanguage.en);
  }

  AppLanguageController get languageController {
    final scope = dependOnInheritedWidgetOfExactType<OperonLanguageScope>();
    assert(scope != null, 'OperonLanguageScope not found');
    return scope!.controller;
  }
}

class OperonLanguageScope extends InheritedNotifier<AppLanguageController> {
  const OperonLanguageScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  AppLanguageController get controller => notifier!;

  @override
  bool updateShouldNotify(OperonLanguageScope oldWidget) =>
      controller.language != oldWidget.controller.language ||
      super.updateShouldNotify(oldWidget);
}
