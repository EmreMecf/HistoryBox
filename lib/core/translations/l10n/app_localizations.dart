import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'HistoryBox'**
  String get app_title;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @nav_bar_home_label.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_bar_home_label;

  /// No description provided for @nav_bar_history_label.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get nav_bar_history_label;

  /// No description provided for @nav_bar_calendar_label.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get nav_bar_calendar_label;

  /// No description provided for @nav_bar_create_label.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get nav_bar_create_label;

  /// No description provided for @login_screen_welcome_label.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HistoryBox'**
  String get login_screen_welcome_label;

  /// No description provided for @login_screen_slogan_label.
  ///
  /// In en, this message translates to:
  /// **'AI-powered stories for children'**
  String get login_screen_slogan_label;

  /// No description provided for @login_button_label.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get login_button_label;

  /// No description provided for @guest_login_label.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guest_login_label;

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get home_greeting;

  /// No description provided for @home_greeting_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create amazing stories together!'**
  String get home_greeting_subtitle;

  /// No description provided for @home_promo_heading.
  ///
  /// In en, this message translates to:
  /// **'Create Stories with AI'**
  String get home_promo_heading;

  /// No description provided for @home_promo_title.
  ///
  /// In en, this message translates to:
  /// **'HistoryBox uses AI to create personalized, fun, and educational stories for children. Start creating magical stories now!'**
  String get home_promo_title;

  /// No description provided for @home_promo_button.
  ///
  /// In en, this message translates to:
  /// **'Create Story'**
  String get home_promo_button;

  /// No description provided for @recent_stories_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Stories'**
  String get recent_stories_title;

  /// No description provided for @view_all_button.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all_button;

  /// No description provided for @no_stories_yet.
  ///
  /// In en, this message translates to:
  /// **'No stories yet. Create your first story!'**
  String get no_stories_yet;

  /// No description provided for @special_dates_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Special Dates'**
  String get special_dates_upcoming;

  /// No description provided for @special_dates_section_title.
  ///
  /// In en, this message translates to:
  /// **'Special Dates'**
  String get special_dates_section_title;

  /// No description provided for @no_special_dates.
  ///
  /// In en, this message translates to:
  /// **'No special dates added yet'**
  String get no_special_dates;

  /// No description provided for @days_left.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get days_left;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today!'**
  String get today;

  /// No description provided for @add_special_dates_tip.
  ///
  /// In en, this message translates to:
  /// **'Add birthdays and special occasions to get story reminders!'**
  String get add_special_dates_tip;

  /// No description provided for @story_categories_title.
  ///
  /// In en, this message translates to:
  /// **'Story Categories'**
  String get story_categories_title;

  /// No description provided for @category_fairy_tale.
  ///
  /// In en, this message translates to:
  /// **'Fairy Tale'**
  String get category_fairy_tale;

  /// No description provided for @category_adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get category_adventure;

  /// No description provided for @category_educational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get category_educational;

  /// No description provided for @category_bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get category_bedtime;

  /// No description provided for @category_fantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get category_fantasy;

  /// No description provided for @category_science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get category_science;

  /// No description provided for @category_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get category_history;

  /// No description provided for @category_moral.
  ///
  /// In en, this message translates to:
  /// **'Moral Stories'**
  String get category_moral;

  /// No description provided for @age_group_title.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get age_group_title;

  /// No description provided for @age_group_3_5.
  ///
  /// In en, this message translates to:
  /// **'3-5 years'**
  String get age_group_3_5;

  /// No description provided for @age_group_6_8.
  ///
  /// In en, this message translates to:
  /// **'6-8 years'**
  String get age_group_6_8;

  /// No description provided for @age_group_9_12.
  ///
  /// In en, this message translates to:
  /// **'9-12 years'**
  String get age_group_9_12;

  /// No description provided for @story_length_title.
  ///
  /// In en, this message translates to:
  /// **'Story Length'**
  String get story_length_title;

  /// No description provided for @story_length_short.
  ///
  /// In en, this message translates to:
  /// **'Short (5 min)'**
  String get story_length_short;

  /// No description provided for @story_length_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium (10 min)'**
  String get story_length_medium;

  /// No description provided for @story_length_long.
  ///
  /// In en, this message translates to:
  /// **'Long (15 min)'**
  String get story_length_long;

  /// No description provided for @topic_suggestions_title.
  ///
  /// In en, this message translates to:
  /// **'Topic Suggestions'**
  String get topic_suggestions_title;

  /// No description provided for @custom_topic_hint.
  ///
  /// In en, this message translates to:
  /// **'Or enter your own topic...'**
  String get custom_topic_hint;

  /// No description provided for @generate_story_button.
  ///
  /// In en, this message translates to:
  /// **'Generate Story'**
  String get generate_story_button;

  /// No description provided for @story_being_generated.
  ///
  /// In en, this message translates to:
  /// **'Your Story is Being Created'**
  String get story_being_generated;

  /// No description provided for @ai_creating_story.
  ///
  /// In en, this message translates to:
  /// **'AI is creating a magical story for you'**
  String get ai_creating_story;

  /// No description provided for @story_title_label.
  ///
  /// In en, this message translates to:
  /// **'Story Title'**
  String get story_title_label;

  /// No description provided for @story_content_label.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get story_content_label;

  /// No description provided for @save_story_button.
  ///
  /// In en, this message translates to:
  /// **'Save Story'**
  String get save_story_button;

  /// No description provided for @share_story_button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share_story_button;

  /// No description provided for @favorite_button.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite_button;

  /// No description provided for @read_again_button.
  ///
  /// In en, this message translates to:
  /// **'Read Again'**
  String get read_again_button;

  /// No description provided for @profile_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_screen_app_bar_label;

  /// No description provided for @profile_edit_button.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit_button;

  /// No description provided for @profile_menu_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_menu_settings;

  /// No description provided for @profile_menu_logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profile_menu_logout;

  /// No description provided for @edit_profile_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name & Surname'**
  String get edit_profile_name_label;

  /// No description provided for @edit_profile_email_label.
  ///
  /// In en, this message translates to:
  /// **'E-Mail'**
  String get edit_profile_email_label;

  /// No description provided for @edit_profile_submit_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get edit_profile_submit_button;

  /// No description provided for @edit_profile_photo_change_label.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get edit_profile_photo_change_label;

  /// No description provided for @edit_profile_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_app_bar_label;

  /// No description provided for @settings_language_label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language_label;

  /// No description provided for @settings_theme_label.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get settings_theme_label;

  /// No description provided for @settings_feedback_label.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settings_feedback_label;

  /// No description provided for @setting_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting_screen_app_bar_label;

  /// No description provided for @theme_settings_label.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get theme_settings_label;

  /// No description provided for @theme_setting_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get theme_setting_screen_app_bar_label;

  /// No description provided for @feedback_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback_screen_app_bar_label;

  /// No description provided for @feedback_description_heading.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback_description_heading;

  /// No description provided for @feedback_description_title.
  ///
  /// In en, this message translates to:
  /// **'If you like our app or have suggestions for improvement, feel free to contact us!'**
  String get feedback_description_title;

  /// No description provided for @calendar_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar_screen_app_bar_label;

  /// No description provided for @calendar_input_form_label.
  ///
  /// In en, this message translates to:
  /// **'Name & Date'**
  String get calendar_input_form_label;

  /// No description provided for @history_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'My Stories'**
  String get history_screen_app_bar_label;

  /// No description provided for @story_create_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Create New Story'**
  String get story_create_screen_app_bar_label;

  /// No description provided for @story_detail_screen_app_bar_label.
  ///
  /// In en, this message translates to:
  /// **'Story Details'**
  String get story_detail_screen_app_bar_label;

  /// No description provided for @total_tokens.
  ///
  /// In en, this message translates to:
  /// **'Total Tokens'**
  String get total_tokens;

  /// No description provided for @used_this_month.
  ///
  /// In en, this message translates to:
  /// **'Used This Month'**
  String get used_this_month;

  /// No description provided for @stories_created.
  ///
  /// In en, this message translates to:
  /// **'Stories Created'**
  String get stories_created;

  /// No description provided for @favorite_stories.
  ///
  /// In en, this message translates to:
  /// **'Favorite Stories'**
  String get favorite_stories;

  /// No description provided for @buyTokens.
  ///
  /// In en, this message translates to:
  /// **'Buy Tokens'**
  String get buyTokens;

  /// No description provided for @currentTokens.
  ///
  /// In en, this message translates to:
  /// **'Current Tokens: {count}'**
  String currentTokens(Object count);

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad ({count} Tokens)'**
  String watchAd(Object count);

  /// No description provided for @tokenInfoText.
  ///
  /// In en, this message translates to:
  /// **'Each story creation uses 1 token. Tokens can be earned by watching ads or purchasing.'**
  String get tokenInfoText;

  /// No description provided for @tokensPurchased.
  ///
  /// In en, this message translates to:
  /// **'You purchased {count} tokens!'**
  String tokensPurchased(Object count);

  /// No description provided for @insufficientTokens.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Tokens'**
  String get insufficientTokens;

  /// No description provided for @tokenWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'You need tokens to create stories. You can earn free tokens by watching ads or purchase tokens.'**
  String get tokenWarningMessage;

  /// No description provided for @rename_dialog_heading_label.
  ///
  /// In en, this message translates to:
  /// **'Rename Story'**
  String get rename_dialog_heading_label;

  /// No description provided for @rename_dialog_hint_label.
  ///
  /// In en, this message translates to:
  /// **'Enter New Title'**
  String get rename_dialog_hint_label;

  /// No description provided for @rename_dialog_save_label.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get rename_dialog_save_label;

  /// No description provided for @rename_dialog_cancel_label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rename_dialog_cancel_label;

  /// No description provided for @delete_story_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Story?'**
  String get delete_story_confirm;

  /// No description provided for @delete_story_message.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get delete_story_message;

  /// No description provided for @delete_button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_button;

  /// No description provided for @cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @home_login_required_title.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get home_login_required_title;

  /// No description provided for @home_login_required_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create and save your stories'**
  String get home_login_required_subtitle;

  /// No description provided for @back_button_label.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get back_button_label;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
