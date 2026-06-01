import 'dart:io';

void main() {
  final iconMap = {
    'ac_unit': 'snowflake',
    'account_balance_wallet_outlined': 'wallet',
    'add': 'plus',
    'add_a_photo_outlined': 'cameraPlus',
    'add_circle_outline': 'plusCircle',
    'arrow_back': 'arrowLeft',
    'arrow_back_ios': 'caretLeft',
    'arrow_back_ios_new': 'caretLeft',
    'arrow_back_ios_new_rounded': 'caretLeft',
    'arrow_forward': 'arrowRight',
    'arrow_forward_ios': 'caretRight',
    'badge_outlined': 'identificationCard',
    'bolt_rounded': 'lightning',
    'bookmark': 'bookmark',
    'bookmark_border': 'bookmark',
    'brush_outlined': 'paintBrush',
    'build': 'wrench',
    'calendar_month_outlined': 'calendar',
    'calendar_month_rounded': 'calendar',
    'calendar_today': 'calendarBlank',
    'calendar_today_outlined': 'calendarBlank',
    'call': 'phone',
    'camera_alt': 'camera',
    'camera_alt_outlined': 'camera',
    'cancel': 'xCircle',
    'category': 'squaresFour',
    'chat_bubble': 'chatCircle',
    'chat_bubble_outline': 'chatCircle',
    'chat_bubble_outline_rounded': 'chatCircle',
    'chat_bubble_rounded': 'chatCircle',
    'check': 'check',
    'check_circle': 'checkCircle',
    'check_circle_outline_rounded': 'checkCircle',
    'check_circle_rounded': 'checkCircle',
    'chevron_right': 'caretRight',
    'circle_outlined': 'circle',
    'cleaning_services': 'broom',
    'close': 'x',
    'cloud_off_outlined': 'cloudSlash',
    'cloud_outlined': 'cloud',
    'construction': 'barricade',
    'data_saver_on_outlined': 'database',
    'delete': 'trash',
    'description_outlined': 'fileText',
    'desktop_windows_outlined': 'desktop',
    'done_all': 'checks',
    'edit': 'pencilSimple',
    'edit_outlined': 'pencilSimple',
    'emoji_emotions_outlined': 'smiley',
    'engineering_outlined': 'hardHat',
    'error_outline': 'warningCircle',
    'error_outline_rounded': 'warningCircle',
    'explore_outlined': 'compass',
    'favorite': 'heart',
    'favorite_border': 'heart',
    'flash_on': 'lightning',
    'handyman': 'wrench',
    'handyman_outlined': 'wrench',
    'help_outline': 'question',
    'history': 'clockCounterClockwise',
    'home': 'house',
    'home_outlined': 'house',
    'home_rounded': 'house',
    'image': 'image',
    'image_outlined': 'image',
    'info_outline': 'info',
    'info_outline_rounded': 'info',
    'insert_drive_file_outlined': 'file',
    'landscape': 'mountains',
    'location_on': 'mapPin',
    'location_on_outlined': 'mapPin',
    'location_on_rounded': 'mapPin',
    'lock_outline': 'lock',
    'logout': 'signOut',
    'map': 'mapTrifold',
    'map_outlined': 'mapTrifold',
    'mark_email_unread_outlined': 'envelopeSimpleOpen',
    'message': 'chatTeardrop',
    'more_horiz': 'dotsThree',
    'more_vert': 'dotsThreeVertical',
    'navigation': 'navigationArrow',
    'navigation_outlined': 'navigationArrow',
    'notifications_none': 'bell',
    'notifications_outlined': 'bell',
    'palette': 'palette',
    'palette_outlined': 'palette',
    'payments_outlined': 'money',
    'person': 'user',
    'person_outline': 'user',
    'person_outline_rounded': 'user',
    'person_rounded': 'user',
    'phone_outlined': 'phone',
    'photo_library': 'images',
    'place_outlined': 'mapPin',
    'plumbing': 'drop',
    'privacy_tip_outlined': 'shieldCheck',
    'query_stats_outlined': 'chartLineUp',
    'radio_button_checked': 'radioButton',
    'radio_button_off': 'circle',
    'receipt_long': 'receipt',
    'report_problem_outlined': 'warning',
    'schedule': 'clock',
    'search': 'magnifyingGlass',
    'send_rounded': 'paperPlaneRight',
    'settings': 'gear',
    'settings_outlined': 'gear',
    'share_outlined': 'shareNetwork',
    'shield_outlined': 'shield',
    'star': 'star',
    'star_border': 'star',
    'star_outline': 'star',
    'star_outline_rounded': 'star',
    'star_rounded': 'star',
    'support_agent_outlined': 'headset',
    'timer_outlined': 'timer',
    'trending_up': 'trendUp',
    'trending_up_rounded': 'trendUp',
    'verified': 'sealCheck',
    'verified_user_rounded': 'shieldCheck',
    'videocam_outlined': 'videoCamera',
    'work_off_outlined': 'briefcase',
    'work_outline': 'briefcase',
  };

  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  final regex = RegExp(r'(?<!Phosphor)Icons\.([a-zA-Z0-9_]+)');

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // We do a loop replacing icons until no more match.
    String newContent = content.replaceAllMapped(regex, (match) {
      final materialIcon = match.group(1)!;
      final phosphorName = iconMap[materialIcon];
      if (phosphorName != null) {
        changed = true;
        return 'PhosphorIcons.$phosphorName()';
      }
      return match.group(0)!;
    });

    if (changed) {
      // Also add the import if not present
      if (!newContent.contains("import 'package:phosphor_flutter/phosphor_flutter.dart';")) {
        // Find the last material/cupertino/flutter import and insert after
        final importRegex = RegExp(r"import 'package:flutter/material\.dart';");
        newContent = newContent.replaceFirst(importRegex, "import 'package:flutter/material.dart';\nimport 'package:phosphor_flutter/phosphor_flutter.dart';");
      }
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
    }
  }
}
