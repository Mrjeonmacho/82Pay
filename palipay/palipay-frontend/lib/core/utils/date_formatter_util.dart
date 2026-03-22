import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DateFormatterUtil {
  static String getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String formatHistoryHeader(BuildContext context, DateTime date) {
    final localeCode = context.locale.toString();
    final baseFormatted = DateFormat.yMMMMd(localeCode).format(date);
    
    // 영어(en)일 때만 서수 표현 추가
    if (context.locale.languageCode == 'en') {
      final day = date.day;
      final suffix = getOrdinalSuffix(day);
      // 포맷된 결과(예: "January 19, 2026")에서 "19"를 "19th"로 교체
      return baseFormatted.replaceFirst('$day', '$day$suffix');
    }
    
    return baseFormatted;
  }
}
