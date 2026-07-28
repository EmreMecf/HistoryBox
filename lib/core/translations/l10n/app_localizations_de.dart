// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get app_title => 'HistoryBox';

  @override
  String get account => 'Konto';

  @override
  String get nav_bar_home_label => 'Start';

  @override
  String get nav_bar_history_label => 'Verlauf';

  @override
  String get nav_bar_calendar_label => 'Kalender';

  @override
  String get nav_bar_create_label => 'Erstellen';

  @override
  String get login_screen_welcome_label => 'Willkommen bei HistoryBox';

  @override
  String get login_screen_slogan_label => 'KI-gestützte Geschichten für Kinder';

  @override
  String get login_button_label => 'Mit Google anmelden';

  @override
  String get guest_login_label => 'Als Gast fortfahren';

  @override
  String get home_greeting => 'Hallo';

  @override
  String get home_greeting_subtitle =>
      'Lass uns zusammen tolle Geschichten erschaffen!';

  @override
  String get home_promo_heading => 'Geschichten mit KI erstellen';

  @override
  String get home_promo_title =>
      'HistoryBox nutzt KI, um personalisierte, unterhaltsame und lehrreiche Geschichten für Kinder zu erstellen. Erschaffe jetzt magische Geschichten!';

  @override
  String get home_promo_button => 'Geschichte erstellen';

  @override
  String get recent_stories_title => 'Neueste Geschichten';

  @override
  String get view_all_button => 'Alle ansehen';

  @override
  String get no_stories_yet =>
      'Noch keine Geschichten. Erstelle deine erste Geschichte!';

  @override
  String get special_dates_upcoming => 'Kommende besondere Tage';

  @override
  String get special_dates_section_title => 'Besondere Tage';

  @override
  String get no_special_dates => 'Noch keine besonderen Tage hinzugefügt';

  @override
  String get days_left => 'Tage übrig';

  @override
  String get today => 'Heute!';

  @override
  String get add_special_dates_tip =>
      'Füge Geburtstage und besondere Anlässe hinzu, um Erinnerungen zu erhalten!';

  @override
  String get story_categories_title => 'Geschichtenkategorien';

  @override
  String get category_fairy_tale => 'Märchen';

  @override
  String get category_adventure => 'Abenteuer';

  @override
  String get category_educational => 'Lehrreich';

  @override
  String get category_bedtime => 'Gutenachtgeschichte';

  @override
  String get category_fantasy => 'Fantasy';

  @override
  String get category_science => 'Wissenschaft';

  @override
  String get category_history => 'Geschichte';

  @override
  String get category_moral => 'Moralgeschichten';

  @override
  String get age_group_title => 'Altersgruppe';

  @override
  String get age_group_3_5 => '3-5 Jahre';

  @override
  String get age_group_6_8 => '6-8 Jahre';

  @override
  String get age_group_9_12 => '9-12 Jahre';

  @override
  String get story_length_title => 'Länge der Geschichte';

  @override
  String get story_length_short => 'Kurz (5 Min.)';

  @override
  String get story_length_medium => 'Mittel (10 Min.)';

  @override
  String get story_length_long => 'Lang (15 Min.)';

  @override
  String get topic_suggestions_title => 'Themenvorschläge';

  @override
  String get custom_topic_hint => 'Oder gib dein eigenes Thema ein...';

  @override
  String get generate_story_button => 'Geschichte erstellen';

  @override
  String get story_being_generated => 'Deine Geschichte wird erstellt';

  @override
  String get ai_creating_story =>
      'Die KI erstellt eine magische Geschichte für dich';

  @override
  String get story_title_label => 'Titel der Geschichte';

  @override
  String get story_content_label => 'Geschichte';

  @override
  String get save_story_button => 'Geschichte speichern';

  @override
  String get share_story_button => 'Teilen';

  @override
  String get favorite_button => 'Favorit';

  @override
  String get read_again_button => 'Erneut lesen';

  @override
  String get profile_screen_app_bar_label => 'Profil';

  @override
  String get profile_edit_button => 'Profil bearbeiten';

  @override
  String get profile_menu_settings => 'Einstellungen';

  @override
  String get profile_menu_logout => 'Abmelden';

  @override
  String get edit_profile_name_label => 'Vor- & Nachname';

  @override
  String get edit_profile_email_label => 'E-Mail';

  @override
  String get edit_profile_submit_button => 'Speichern';

  @override
  String get edit_profile_photo_change_label => 'Foto ändern';

  @override
  String get edit_profile_app_bar_label => 'Profil bearbeiten';

  @override
  String get settings_language_label => 'Sprache';

  @override
  String get settings_theme_label => 'Design-Einstellungen';

  @override
  String get settings_feedback_label => 'Feedback';

  @override
  String get setting_screen_app_bar_label => 'Einstellungen';

  @override
  String get theme_settings_label => 'Dunkelmodus';

  @override
  String get theme_setting_screen_app_bar_label => 'Design-Einstellungen';

  @override
  String get feedback_screen_app_bar_label => 'Feedback';

  @override
  String get feedback_description_heading => 'Feedback';

  @override
  String get feedback_description_title =>
      'Wenn dir unsere App gefällt oder du Verbesserungsvorschläge hast, kontaktiere uns gerne!';

  @override
  String get calendar_screen_app_bar_label => 'Kalender';

  @override
  String get calendar_input_form_label => 'Name & Datum';

  @override
  String get history_screen_app_bar_label => 'Meine Geschichten';

  @override
  String get story_create_screen_app_bar_label => 'Neue Geschichte erstellen';

  @override
  String get story_detail_screen_app_bar_label => 'Details der Geschichte';

  @override
  String get total_tokens => 'Gesamte Token';

  @override
  String get used_this_month => 'Diesen Monat verwendet';

  @override
  String get stories_created => 'Erstellte Geschichten';

  @override
  String get favorite_stories => 'Lieblingsgeschichten';

  @override
  String get buyTokens => 'Token kaufen';

  @override
  String currentTokens(Object count) {
    return 'Aktuelle Token: $count';
  }

  @override
  String watchAd(Object count) {
    return 'Werbung ansehen ($count Token)';
  }

  @override
  String get tokenInfoText =>
      'Jede Geschichte verbraucht 1 Token. Token können durch das Ansehen von Werbung oder durch Kauf erworben werden.';

  @override
  String tokensPurchased(Object count) {
    return 'Du hast $count Token gekauft!';
  }

  @override
  String get insufficientTokens => 'Nicht genügend Token';

  @override
  String get tokenWarningMessage =>
      'Du brauchst Token, um Geschichten zu erstellen. Du kannst kostenlose Token durch Werbung verdienen oder Token kaufen.';

  @override
  String get rename_dialog_heading_label => 'Geschichte umbenennen';

  @override
  String get rename_dialog_hint_label => 'Neuen Titel eingeben';

  @override
  String get rename_dialog_save_label => 'Speichern';

  @override
  String get rename_dialog_cancel_label => 'Abbrechen';

  @override
  String get delete_story_confirm => 'Geschichte löschen?';

  @override
  String get delete_story_message =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get delete_button => 'Löschen';

  @override
  String get cancel_button => 'Abbrechen';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get error_occurred => 'Ein Fehler ist aufgetreten';

  @override
  String get try_again => 'Erneut versuchen';

  @override
  String get home_login_required_title => 'Bitte anmelden';

  @override
  String get home_login_required_subtitle =>
      'Melde dich an, um deine Geschichten zu erstellen und zu speichern';
}
