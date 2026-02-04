// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'HistoryBox';

  @override
  String get account => 'Account';

  @override
  String get nav_bar_home_label => 'Home';

  @override
  String get nav_bar_history_label => 'History';

  @override
  String get nav_bar_calendar_label => 'Calendar';

  @override
  String get nav_bar_create_label => 'Create';

  @override
  String get login_screen_welcome_label => 'Welcome to HistoryBox';

  @override
  String get login_screen_slogan_label => 'AI-powered stories for children';

  @override
  String get login_button_label => 'Sign In with Google';

  @override
  String get guest_login_label => 'Continue as Guest';

  @override
  String get home_greeting => 'Hello';

  @override
  String get home_greeting_subtitle =>
      'Let\'s create amazing stories together!';

  @override
  String get home_promo_heading => 'Create Stories with AI';

  @override
  String get home_promo_title =>
      'HistoryBox uses AI to create personalized, fun, and educational stories for children. Start creating magical stories now!';

  @override
  String get home_promo_button => 'Create Story';

  @override
  String get recent_stories_title => 'Recent Stories';

  @override
  String get view_all_button => 'View All';

  @override
  String get no_stories_yet => 'No stories yet. Create your first story!';

  @override
  String get special_dates_upcoming => 'Upcoming Special Dates';

  @override
  String get special_dates_section_title => 'Special Dates';

  @override
  String get no_special_dates => 'No special dates added yet';

  @override
  String get days_left => 'days left';

  @override
  String get today => 'Today!';

  @override
  String get add_special_dates_tip =>
      'Add birthdays and special occasions to get story reminders!';

  @override
  String get story_categories_title => 'Story Categories';

  @override
  String get category_fairy_tale => 'Fairy Tale';

  @override
  String get category_adventure => 'Adventure';

  @override
  String get category_educational => 'Educational';

  @override
  String get category_bedtime => 'Bedtime';

  @override
  String get category_fantasy => 'Fantasy';

  @override
  String get category_science => 'Science';

  @override
  String get category_history => 'History';

  @override
  String get category_moral => 'Moral Stories';

  @override
  String get age_group_title => 'Age Group';

  @override
  String get age_group_3_5 => '3-5 years';

  @override
  String get age_group_6_8 => '6-8 years';

  @override
  String get age_group_9_12 => '9-12 years';

  @override
  String get story_length_title => 'Story Length';

  @override
  String get story_length_short => 'Short (5 min)';

  @override
  String get story_length_medium => 'Medium (10 min)';

  @override
  String get story_length_long => 'Long (15 min)';

  @override
  String get topic_suggestions_title => 'Topic Suggestions';

  @override
  String get custom_topic_hint => 'Or enter your own topic...';

  @override
  String get generate_story_button => 'Generate Story';

  @override
  String get story_being_generated => 'Your Story is Being Created';

  @override
  String get ai_creating_story => 'AI is creating a magical story for you';

  @override
  String get story_title_label => 'Story Title';

  @override
  String get story_content_label => 'Story';

  @override
  String get save_story_button => 'Save Story';

  @override
  String get share_story_button => 'Share';

  @override
  String get favorite_button => 'Add to Favorites';

  @override
  String get favorite_remove_button => 'Remove from Favorites';

  @override
  String get read_again_button => 'Read Again';

  @override
  String get profile_screen_app_bar_label => 'Profile';

  @override
  String get profile_edit_button => 'Edit Profile';

  @override
  String get profile_menu_settings => 'Settings';

  @override
  String get profile_menu_logout => 'Sign Out';

  @override
  String get edit_profile_name_label => 'Name & Surname';

  @override
  String get edit_profile_email_label => 'E-Mail';

  @override
  String get edit_profile_submit_button => 'Save';

  @override
  String get edit_profile_photo_change_label => 'Change Photo';

  @override
  String get edit_profile_app_bar_label => 'Edit Profile';

  @override
  String get settings_language_label => 'Language';

  @override
  String get settings_theme_label => 'Theme Settings';

  @override
  String get settings_feedback_label => 'Feedback';

  @override
  String get setting_screen_app_bar_label => 'Settings';

  @override
  String get theme_settings_label => 'Dark Mode';

  @override
  String get theme_setting_screen_app_bar_label => 'Theme Settings';

  @override
  String get feedback_screen_app_bar_label => 'Feedback';

  @override
  String get feedback_description_heading => 'Feedback';

  @override
  String get feedback_description_title =>
      'If you like our app or have suggestions for improvement, feel free to contact us!';

  @override
  String get calendar_screen_app_bar_label => 'Calendar';

  @override
  String get calendar_input_form_label => 'Name & Date';

  @override
  String get history_screen_app_bar_label => 'My Stories';

  @override
  String get story_create_screen_app_bar_label => 'Create New Story';

  @override
  String get story_detail_screen_app_bar_label => 'Story Details';

  @override
  String get total_tokens => 'Total Tokens';

  @override
  String get used_this_month => 'Used This Month';

  @override
  String get stories_created => 'Stories Created';

  @override
  String get favorite_stories => 'Favorite Stories';

  @override
  String get buyTokens => 'Buy Tokens';

  @override
  String currentTokens(Object count) {
    return 'Current Tokens: $count';
  }

  @override
  String watchAd(Object count) {
    return 'Watch Ad ($count Tokens)';
  }

  @override
  String get tokenInfoText =>
      'Each story creation uses 1 token. Tokens can be earned by watching ads or purchasing.';

  @override
  String tokensPurchased(Object count) {
    return 'You purchased $count tokens!';
  }

  @override
  String get insufficientTokens => 'Insufficient Tokens';

  @override
  String get tokenWarningMessage =>
      'You need tokens to create stories. You can earn free tokens by watching ads or purchase tokens.';

  @override
  String get rename_dialog_heading_label => 'Rename Story';

  @override
  String get rename_dialog_hint_label => 'Enter New Title';

  @override
  String get rename_dialog_save_label => 'Save';

  @override
  String get rename_dialog_cancel_label => 'Cancel';

  @override
  String get delete_story_confirm => 'Delete Story?';

  @override
  String get delete_story_message => 'This action cannot be undone.';

  @override
  String get delete_button => 'Delete';

  @override
  String get cancel_button => 'Cancel';

  @override
  String get loading => 'Loading...';

  @override
  String get error_occurred => 'An error occurred';

  @override
  String get try_again => 'Try Again';

  @override
  String get home_login_required_title => 'Please sign in';

  @override
  String get home_login_required_subtitle =>
      'Sign in to create and save your stories';
}
