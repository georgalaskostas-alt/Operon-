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
  String get language => pick('Language', 'Γλώσσα');
  String get languageSub => pick('Choose app language', 'Επιλογή γλώσσας εφαρμογής');
  String get english => 'English';
  String get greek => 'Ελληνικά';
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
