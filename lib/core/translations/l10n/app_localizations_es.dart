// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_title => 'HistoryBox';

  @override
  String get account => 'Cuenta';

  @override
  String get nav_bar_home_label => 'Inicio';

  @override
  String get nav_bar_history_label => 'Historial';

  @override
  String get nav_bar_calendar_label => 'Calendario';

  @override
  String get nav_bar_create_label => 'Crear';

  @override
  String get login_screen_welcome_label => 'Bienvenido a HistoryBox';

  @override
  String get login_screen_slogan_label => 'Cuentos para niños con IA';

  @override
  String get login_button_label => 'Iniciar sesión con Google';

  @override
  String get guest_login_label => 'Continuar como invitado';

  @override
  String get home_greeting => 'Hola';

  @override
  String get home_greeting_subtitle => '¡Creemos cuentos increíbles juntos!';

  @override
  String get home_promo_heading => 'Crea cuentos con IA';

  @override
  String get home_promo_title =>
      'HistoryBox usa IA para crear cuentos personalizados, divertidos y educativos para niños. ¡Empieza a crear cuentos mágicos ahora!';

  @override
  String get home_promo_button => 'Crear cuento';

  @override
  String get recent_stories_title => 'Cuentos recientes';

  @override
  String get view_all_button => 'Ver todo';

  @override
  String get no_stories_yet => 'Aún no hay cuentos. ¡Crea tu primer cuento!';

  @override
  String get special_dates_upcoming => 'Próximas fechas especiales';

  @override
  String get special_dates_section_title => 'Fechas especiales';

  @override
  String get no_special_dates => 'Aún no se han añadido fechas especiales';

  @override
  String get days_left => 'días restantes';

  @override
  String get today => '¡Hoy!';

  @override
  String get add_special_dates_tip =>
      '¡Añade cumpleaños y ocasiones especiales para recibir recordatorios de cuentos!';

  @override
  String get story_categories_title => 'Categorías de cuentos';

  @override
  String get category_fairy_tale => 'Cuento de hadas';

  @override
  String get category_adventure => 'Aventura';

  @override
  String get category_educational => 'Educativo';

  @override
  String get category_bedtime => 'Para dormir';

  @override
  String get category_fantasy => 'Fantasía';

  @override
  String get category_science => 'Ciencia';

  @override
  String get category_history => 'Historia';

  @override
  String get category_moral => 'Cuentos con moraleja';

  @override
  String get age_group_title => 'Grupo de edad';

  @override
  String get age_group_3_5 => '3-5 años';

  @override
  String get age_group_6_8 => '6-8 años';

  @override
  String get age_group_9_12 => '9-12 años';

  @override
  String get story_length_title => 'Duración del cuento';

  @override
  String get story_length_short => 'Corto (5 min)';

  @override
  String get story_length_medium => 'Medio (10 min)';

  @override
  String get story_length_long => 'Largo (15 min)';

  @override
  String get topic_suggestions_title => 'Sugerencias de temas';

  @override
  String get custom_topic_hint => 'O introduce tu propio tema...';

  @override
  String get generate_story_button => 'Generar cuento';

  @override
  String get story_being_generated => 'Tu cuento se está creando';

  @override
  String get ai_creating_story => 'La IA está creando un cuento mágico para ti';

  @override
  String get story_title_label => 'Título del cuento';

  @override
  String get story_content_label => 'Cuento';

  @override
  String get save_story_button => 'Guardar cuento';

  @override
  String get share_story_button => 'Compartir';

  @override
  String get favorite_button => 'Favorito';

  @override
  String get read_again_button => 'Leer de nuevo';

  @override
  String get profile_screen_app_bar_label => 'Perfil';

  @override
  String get profile_edit_button => 'Editar perfil';

  @override
  String get profile_menu_settings => 'Ajustes';

  @override
  String get profile_menu_logout => 'Cerrar sesión';

  @override
  String get edit_profile_name_label => 'Nombre y apellidos';

  @override
  String get edit_profile_email_label => 'Correo electrónico';

  @override
  String get edit_profile_submit_button => 'Guardar';

  @override
  String get edit_profile_photo_change_label => 'Cambiar foto';

  @override
  String get edit_profile_app_bar_label => 'Editar perfil';

  @override
  String get settings_language_label => 'Idioma';

  @override
  String get settings_theme_label => 'Ajustes de tema';

  @override
  String get settings_feedback_label => 'Comentarios';

  @override
  String get setting_screen_app_bar_label => 'Ajustes';

  @override
  String get theme_settings_label => 'Modo oscuro';

  @override
  String get theme_setting_screen_app_bar_label => 'Ajustes de tema';

  @override
  String get feedback_screen_app_bar_label => 'Comentarios';

  @override
  String get feedback_description_heading => 'Comentarios';

  @override
  String get feedback_description_title =>
      'Si te gusta nuestra app o tienes sugerencias de mejora, ¡no dudes en contactarnos!';

  @override
  String get calendar_screen_app_bar_label => 'Calendario';

  @override
  String get calendar_input_form_label => 'Nombre y fecha';

  @override
  String get history_screen_app_bar_label => 'Mis cuentos';

  @override
  String get story_create_screen_app_bar_label => 'Crear nuevo cuento';

  @override
  String get story_detail_screen_app_bar_label => 'Detalles del cuento';

  @override
  String get total_tokens => 'Fichas totales';

  @override
  String get used_this_month => 'Usadas este mes';

  @override
  String get stories_created => 'Cuentos creados';

  @override
  String get favorite_stories => 'Cuentos favoritos';

  @override
  String get buyTokens => 'Comprar fichas';

  @override
  String currentTokens(Object count) {
    return 'Fichas actuales: $count';
  }

  @override
  String watchAd(Object count) {
    return 'Ver anuncio ($count fichas)';
  }

  @override
  String get tokenInfoText =>
      'Cada cuento usa 1 ficha. Puedes conseguir fichas viendo anuncios o comprándolas.';

  @override
  String tokensPurchased(Object count) {
    return '¡Has comprado $count fichas!';
  }

  @override
  String get insufficientTokens => 'Fichas insuficientes';

  @override
  String get tokenWarningMessage =>
      'Necesitas fichas para crear cuentos. Puedes conseguir fichas gratis viendo anuncios o comprarlas.';

  @override
  String get rename_dialog_heading_label => 'Renombrar cuento';

  @override
  String get rename_dialog_hint_label => 'Introduce un nuevo título';

  @override
  String get rename_dialog_save_label => 'Guardar';

  @override
  String get rename_dialog_cancel_label => 'Cancelar';

  @override
  String get delete_story_confirm => '¿Eliminar cuento?';

  @override
  String get delete_story_message => 'Esta acción no se puede deshacer.';

  @override
  String get delete_button => 'Eliminar';

  @override
  String get cancel_button => 'Cancelar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error_occurred => 'Se produjo un error';

  @override
  String get try_again => 'Intentar de nuevo';

  @override
  String get home_login_required_title => 'Inicia sesión, por favor';

  @override
  String get home_login_required_subtitle =>
      'Inicia sesión para crear y guardar tus cuentos';
}
