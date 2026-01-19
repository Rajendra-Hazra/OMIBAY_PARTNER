import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class LocalizationHelper {
  /// Get English service name for PDF export
  static String getEnglishServiceName(String? nameOrKey) {
    if (nameOrKey == null || nameOrKey.isEmpty) return 'Service';

    final Map<String, String> nameMap = {
      'plumber': 'Plumber',
      'Plumber': 'Plumber',
      'electrician': 'Electrician',
      'Electrician': 'Electrician',
      'carpenter': 'Carpenter',
      'Carpenter': 'Carpenter',
      'gardening': 'Gardening',
      'Gardening': 'Gardening',
      'cleaning': 'Cleaning',
      'Cleaning': 'Cleaning',
      'menSalon': 'Men\'s Salon',
      'MenSalon': 'Men\'s Salon',
      'men_salon': 'Men\'s Salon',
      'womenSalon': 'Women\'s Salon',
      'WomenSalon': 'Women\'s Salon',
      'women_salon': 'Women\'s Salon',
      'makeupAndBeauty': 'Makeup & Beauty',
      'makeup_beauty': 'Makeup & Beauty',
      'quickTransport': 'Quick Transport',
      'quick_transport': 'Quick Transport',
      'appliancesRepair': 'Appliances Repair',
      'appliances_repair': 'Appliances Repair',
      'ac': 'AC',
      'AC': 'AC',
      'airCooler': 'Air Cooler',
      'air_cooler': 'Air Cooler',
      'chimney': 'Chimney',
      'geyser': 'Geyser',
      'laptop': 'Laptop',
      'refrigerator': 'Refrigerator',
      'washingMachine': 'Washing Machine',
      'washing_machine': 'Washing Machine',
      'microwave': 'Microwave',
      'television': 'Television',
      'waterPurifier': 'Water Purifier',
      'fullHomeCleaning': 'Full Home Cleaning',
      'Full Home Cleaning': 'Full Home Cleaning',
      'kitchenDeepClean': 'Kitchen Deep Clean',
      'Kitchen Deep Clean': 'Kitchen Deep Clean',
      'bathroomSanitization': 'Bathroom Sanitization',
      'Bathroom Sanitization': 'Bathroom Sanitization',
      'sofaAndCarpetCleaning': 'Sofa And Carpet Cleaning',
      'Sofa And Carpet Cleaning': 'Sofa And Carpet Cleaning',
      'acServiceAndRepair': 'AC Service And Repair',
      'AC Service And Repair': 'AC Service And Repair',
      'pestControl': 'Pest Control',
      'Pest Control': 'Pest Control',
      'প্লাম্বার': 'Plumber',
      'ইলেকট্রিশিয়ান': 'Electrician',
      'কার্পেন্টার': 'Carpenter',
      'বাগান করা': 'Gardening',
      'পরিষ্কার করা': 'Cleaning',
      'পুরুষদের সেলুন': 'Men\'s Salon',
      'মহিলাদের সেলুন': 'Women\'s Salon',
      'মেকআপ ও বিউটি': 'Makeup & Beauty',
      'দ্রুত পরিবহন': 'Quick Transport',
      'যন্ত্রপাতি মেরামত ও প্রতিস্থাপন': 'Appliances Repair',
      'এসি': 'AC',
      'এয়ার কুলার': 'Air Cooler',
      'চিমনি': 'Chimney',
      'গিজার': 'Geyser',
      'ল্যাপটপ': 'Laptop',
      'রেফ্রিজারেটর': 'Refrigerator',
      'ওয়াশিং মেশিন': 'Washing Machine',
      'মাইক্রোওয়েভ': 'Microwave',
      'টেলিভিশন': 'Television',
      'ওয়াটার পিউরিফায়ার': 'Water Purifier',
      'সম্পূর্ণ বাড়ি পরিষ্কার': 'Full Home Cleaning',
      'রান্নাঘর গভীর পরিষ্কার': 'Kitchen Deep Clean',
      'বাথরুম স্যানিটাইজেশন': 'Bathroom Sanitization',
      'সোফা ও কার্পেট পরিষ্কার': 'Sofa And Carpet Cleaning',
      'এসি সার্ভিস ও মেরামত': 'AC Service And Repair',
      'পেস্ট কন্ট্রোল': 'Pest Control',
    };

    return nameMap[nameOrKey] ?? nameOrKey;
  }

  /// Get English customer name for PDF export
  static String getEnglishCustomerName(dynamic customer) {
    final String cust = customer?.toString() ?? '';
    if (cust.isEmpty ||
        cust == 'null' ||
        cust == 'Customer' ||
        cust == 'গ্রাহক') {
      return 'Customer';
    }

    // Mock customers mapping
    if (cust == 'Rahul Sharma' || cust == 'রাহুল শর্মা') return 'Rahul Sharma';
    if (cust == 'Priya Patel' || cust == 'প্রিয়া প্যাটেল') {
      return 'Priya Patel';
    }
    if (cust == 'Amit Kumar' || cust == 'অমিত কুমার') return 'Amit Kumar';
    if (cust == 'Sneha Reddy' || cust == 'স্নেহা রেড্ডি') return 'Sneha Reddy';
    if (cust == 'Vikram Singh' || cust == 'বিক্রম সিং') return 'Vikram Singh';
    if (cust == 'Meera Nair' || cust == 'মীরা নায়ার') return 'Meera Nair';
    if (cust == 'Partner' || cust == 'পার্টনার') return 'Partner';
    if (cust == 'OmiBay System' || cust == 'ওমিবে সিস্টেম') {
      return 'OmiBay System';
    }
    if (cust == 'Personal Account' || cust == 'ব্যক্তিগত অ্যাকাউন্ট') {
      return 'Personal Account';
    }

    return cust;
  }

  /// Get English transaction title for PDF export
  static String getEnglishTransactionTitle(Map<String, dynamic> tx) {
    if (tx['titleKey'] != null) {
      final key = tx['titleKey'].toString();
      if (key == 'withdrawalWithMethod') {
        final methodKey = tx['methodKey'];
        final method = methodKey == 'bankTransfer'
            ? 'Bank Transfer'
            : 'UPI Withdraw';
        return 'Withdrawal via $method';
      }
      if (key == 'dueAmountPaid') return 'Due Amount Paid';
    }

    final String title = tx['title']?.toString() ?? '';
    final bool isJob =
        tx['isJob'] == true ||
        title.startsWith('Job:') ||
        title.startsWith('কাজ:');

    if (isJob) {
      final serviceKey =
          tx['serviceKey'] ??
          tx['service'] ??
          title.replaceFirst('Job: ', '').replaceFirst('কাজ: ', '');
      return 'Job: ${getEnglishServiceName(serviceKey.toString())}';
    }

    // Fallback normalization for title if it's already localized in Bengali
    if (title == 'উত্তোলন' || title.contains('উত্তোলন')) return 'Withdrawal';
    if (title == 'প্রাপ্য পরিমাণ পরিশোধ' || title.contains('পরিশোধ')) {
      return 'Due Amount Paid';
    }

    return title;
  }

  /// Get English transaction subtitle for PDF export
  static String getEnglishTransactionSubtitle(Map<String, dynamic> tx) {
    if (tx['subtitleKey'] != null) {
      final key = tx['subtitleKey'].toString();
      if (key == 'transferToPersonalAccount') {
        return 'Transfer to Personal Account';
      }
      if (key == 'paymentForPlatformFees') return 'Payment for Platform Fees';
    }

    final bool isCredit = tx['isCredit'] == true;
    final bool isJob =
        tx['isJob'] == true ||
        tx['title']?.toString().startsWith('Job:') == true ||
        tx['title']?.toString().startsWith('কাজ:') == true;

    if (isJob) {
      return isCredit ? 'Online Payment' : 'Cash Pay After Service';
    }

    return tx['subtitle'] ?? getEnglishCustomerName(tx['customer']);
  }

  /// Get localized service name from a key or localized string
  static String getLocalizedServiceName(
    BuildContext context,
    String? nameOrKey,
  ) {
    if (nameOrKey == null || nameOrKey.isEmpty) {
      return AppLocalizations.of(context)!.service;
    }

    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> nameMap = {
      'plumber': l10n.plumber,
      'Plumber': l10n.plumber,
      'electrician': l10n.electrician,
      'Electrician': l10n.electrician,
      'carpenter': l10n.carpenter,
      'Carpenter': l10n.carpenter,
      'gardening': l10n.gardening,
      'Gardening': l10n.gardening,
      'cleaning': l10n.cleaning,
      'Cleaning': l10n.cleaning,
      'menSalon': l10n.menSalon,
      'MenSalon': l10n.menSalon,
      'men_salon': l10n.menSalon,
      'womenSalon': l10n.womenSalon,
      'WomenSalon': l10n.womenSalon,
      'women_salon': l10n.womenSalon,
      'makeupAndBeauty': l10n.makeupAndBeauty,
      'makeup_beauty': l10n.makeupAndBeauty,
      'quickTransport': l10n.quickTransport,
      'quick_transport': l10n.quickTransport,
      'appliancesRepair': l10n.appliancesRepair,
      'appliances_repair': l10n.appliancesRepair,
      'ac': l10n.ac,
      'AC': l10n.ac,
      'airCooler': l10n.airCooler,
      'air_cooler': l10n.airCooler,
      'chimney': l10n.chimney,
      'geyser': l10n.geyser,
      'laptop': l10n.laptop,
      'refrigerator': l10n.refrigerator,
      'washingMachine': l10n.washingMachine,
      'washing_machine': l10n.washingMachine,
      'microwave': l10n.microwave,
      'television': l10n.television,
      'waterPurifier': l10n.waterPurifier,
      'fullHomeCleaning': l10n.fullHomeCleaning,
      'Full Home Cleaning': l10n.fullHomeCleaning,
      'kitchenDeepClean': l10n.kitchenDeepClean,
      'Kitchen Deep Clean': l10n.kitchenDeepClean,
      'bathroomSanitization': l10n.bathroomSanitization,
      'Bathroom Sanitization': l10n.bathroomSanitization,
      'sofaAndCarpetCleaning': l10n.sofaAndCarpetCleaning,
      'Sofa And Carpet Cleaning': l10n.sofaAndCarpetCleaning,
      'acServiceAndRepair': l10n.acServiceAndRepair,
      'AC Service And Repair': l10n.acServiceAndRepair,
      'pestControl': l10n.pestControl,
      'Pest Control': l10n.pestControl,
      // Bengali specific values normalization
      'প্লাম্বার': l10n.plumber,
      'ইলেকট্রিশিয়ান': l10n.electrician,
      'কার্পেন্টার': l10n.carpenter,
      'বাগান করা': l10n.gardening,
      'পরিষ্কার করা': l10n.cleaning,
      'পুরুষদের সেলুন': l10n.menSalon,
      'মহিলাদের সেলুন': l10n.womenSalon,
      'মেকআপ ও বিউটি': l10n.makeupAndBeauty,
      'দ্রুত পরিবহন': l10n.quickTransport,
      'যন্ত্রপাতি মেরামত ও প্রতিস্থাপন': l10n.appliancesRepair,
      'এসি': l10n.ac,
      'এয়ার কুলার': l10n.airCooler,
      'চিমনি': l10n.chimney,
      'গিজার': l10n.geyser,
      'ল্যাপটপ': l10n.laptop,
      'রেফ্রিজারেটর': l10n.refrigerator,
      'ওয়াশিং মেশিন': l10n.washingMachine,
      'মাইক্রোওয়েভ': l10n.microwave,
      'টেলিভিশন': l10n.television,
      'ওয়াটার পিউরিফায়ার': l10n.waterPurifier,
      'সম্পূর্ণ বাড়ি পরিষ্কার': l10n.fullHomeCleaning,
      'রান্নাঘর গভীর পরিষ্কার': l10n.kitchenDeepClean,
      'বাথরুম স্যানিটাইজেশন': l10n.bathroomSanitization,
      'সোফা ও কার্পেট পরিষ্কার': l10n.sofaAndCarpetCleaning,
      'এসি সার্ভিস ও মেরামত': l10n.acServiceAndRepair,
      'পেস্ট কন্ট্রোল': l10n.pestControl,
    };

    return nameMap[nameOrKey] ?? nameOrKey;
  }

  /// Get localized payment type
  static String getLocalizedPaymentType(BuildContext context, String? key) {
    if (key == null || key.isEmpty) {
      return AppLocalizations.of(context)!.onlinePayment;
    }
    final l10n = AppLocalizations.of(context)!;
    if (key == 'online' || key == 'অনলাইন পেমেন্ট') return l10n.onlinePayment;
    if (key == 'cash' || key == 'নগদ পেমেন্ট' || key == 'নগদ') {
      return l10n.cashPayment;
    }
    if (key == 'prepaid' || key == 'প্রিপেইড') return l10n.prepaid;
    return key;
  }

  /// Get localized time type
  static String getLocalizedTimeType(
    BuildContext context,
    Map<String, dynamic> job,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (job['isScheduled'] == 'true' || job['isScheduled'] == true) {
      String date = job['scheduledDate']?.toString() ?? '';
      String time = job['scheduledTime']?.toString() ?? '';

      // Normalize date/time strings if they contain Bengali terms
      date = _normalizeDateTimeString(context, date);
      time = _normalizeDateTimeString(context, time);

      return '${l10n.scheduled}: $date, $time';
    }

    final String timeType = job['timeType']?.toString() ?? '';
    if (timeType == 'Instant' || timeType == 'তাৎক্ষণিক') return l10n.instant;
    if (timeType == 'Scheduled' || timeType == 'নির্ধারিত') {
      return l10n.scheduled;
    }

    return timeType.isEmpty ? l10n.instant : timeType;
  }

  /// Get localized ETA
  static String getLocalizedEta(
    BuildContext context,
    Map<String, dynamic> job,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (job['isScheduled'] == 'true' || job['isScheduled'] == true) {
      return l10n.onScheduledTime;
    }
    final String eta = job['eta']?.toString() ?? '';
    if (eta == 'On Scheduled Time' || eta == 'নির্ধারিত সময়ে') {
      return l10n.onScheduledTime;
    }

    final mins =
        int.tryParse(
          convertBengaliToEnglish(job['etaMins']?.toString() ?? ''),
        ) ??
        15;
    return l10n.minsAway(mins.toString());
  }

  /// Get localized customer name
  static String getLocalizedCustomerName(
    BuildContext context,
    dynamic customer,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final String cust = customer?.toString() ?? '';
    if (cust.isEmpty ||
        cust == 'null' ||
        cust == 'Customer' ||
        cust == 'গ্রাহক') {
      return l10n.customer;
    }

    final isBengali = Localizations.localeOf(context).languageCode == 'bn';

    // Mock customers mapping
    if (isBengali) {
      if (cust == 'Rahul Sharma') return l10n.mockCustomerName;
      if (cust == 'Priya Patel') return 'প্রিয়া প্যাটেল';
      if (cust == 'Amit Kumar') return 'অমিত কুমার';
      if (cust == 'Sneha Reddy') return 'স্নেহা রেড্ডি';
      if (cust == 'Vikram Singh') return 'বিক্রম সিং';
      if (cust == 'Meera Nair') return 'মীরা নায়ার';
      if (cust == 'Partner') return l10n.partner;
      if (cust == 'OmiBay System') return 'ওমিবে সিস্টেম';
      if (cust == 'Personal Account') return l10n.personalAccount;
    } else {
      if (cust == 'রাহুল শর্মা') return l10n.mockCustomerName;
      if (cust == 'প্রিয়া প্যাটেল') return 'Priya Patel';
      if (cust == 'অমিত কুমার') return 'Amit Kumar';
      if (cust == 'স্নেহা রেড্ডি') return 'Sneha Reddy';
      if (cust == 'বিক্রম সিং') return 'Vikram Singh';
      if (cust == 'মীরা নায়ার') return 'Meera Nair';
      if (cust == 'পার্টনার') return l10n.partner;
      if (cust == 'ওমিবে সিস্টেম') return 'OmiBay System';
      if (cust == 'ব্যক্তিগত অ্যাকাউন্ট') return l10n.personalAccount;
    }

    return cust;
  }

  /// Get localized location
  static String getLocalizedLocation(BuildContext context, dynamic location) {
    final l10n = AppLocalizations.of(context)!;
    final String loc = location?.toString() ?? '';
    if (loc.isEmpty ||
        loc == 'null' ||
        loc == 'Location' ||
        loc == 'অবস্থান' ||
        loc == 'N/A' ||
        loc == 'প্রযোজ্য নয়') {
      return l10n.location;
    }

    final isBengali = Localizations.localeOf(context).languageCode == 'bn';

    // Mock locations translation
    if (isBengali) {
      if (loc == 'Bellandur, Bangalore' || loc == 'Bellandur, Bengaluru') {
        return l10n.mockLocation;
      }
      if (loc == 'Bellandur') return 'বেল্লান্দুর';
      if (loc == 'Bangalore' || loc == 'Bengaluru') return 'বেঙ্গালুরু';
    } else {
      if (loc == 'বেল্লান্দুর, বেঙ্গালুরু') {
        return l10n.mockLocation;
      }
      if (loc == 'বেল্লান্দুর') return 'Bellandur';
      if (loc == 'বেঙ্গালুরু') return 'Bengaluru';
    }

    return loc;
  }

  /// Normalize date/time strings (months, AM/PM)
  static String _normalizeDateTimeString(BuildContext context, String input) {
    if (input.isEmpty) return input;
    final l10n = AppLocalizations.of(context)!;

    String result = convertBengaliToEnglish(input);

    // Map of Bengali terms to localized versions
    final Map<String, String> termMap = {
      'জানুয়ারি': l10n.monthJan,
      'ফেব্রুয়ারি': 'Feb', // Need more month keys if available
      'মার্চ': 'Mar',
      'এপ্রিল': 'Apr',
      'মে': 'May',
      'জুন': 'Jun',
      'জুলাই': 'Jul',
      'আগস্ট': 'Aug',
      'সেপ্টেম্বর': 'Sep',
      'অক্টোবর': 'Oct',
      'নভেম্বর': 'Nov',
      'ডিসেম্বর': 'Dec',
      'সকাল': 'AM',
      'দুপুর': 'PM',
      'বিকাল': 'PM',
      'সন্ধ্যা': 'PM',
      'রাত': 'PM',
    };

    termMap.forEach((bengali, replacement) {
      result = result.replaceAll(bengali, replacement);
    });

    return result;
  }

  /// Get localized transaction title
  static String getTransactionTitle(
    BuildContext context,
    Map<String, dynamic> tx,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Check for titleKey first
    if (tx['titleKey'] != null) {
      final key = tx['titleKey'].toString();
      if (key == 'withdrawalWithMethod') {
        final methodKey = tx['methodKey'];
        final method = methodKey == 'bankTransfer'
            ? l10n.bankTransfer
            : l10n.upiWithdraw;
        return l10n.withdrawalWithMethod(method);
      }
      if (key == 'dueAmountPaid') return l10n.dueAmountPaid;
    }

    // Check if it's a job
    final String title = tx['title']?.toString() ?? '';
    final bool isJob =
        tx['isJob'] == true ||
        title.startsWith('Job:') ||
        title.startsWith('কাজ:');

    if (isJob) {
      final serviceKey =
          tx['serviceKey'] ??
          tx['service'] ??
          title.replaceFirst('Job: ', '').replaceFirst('কাজ: ', '');
      return l10n.jobWithService(
        getLocalizedServiceName(context, serviceKey.toString()),
      );
    }

    return title;
  }

  /// Get localized transaction subtitle
  static String getTransactionSubtitle(
    BuildContext context,
    Map<String, dynamic> tx,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (tx['subtitleKey'] != null) {
      final key = tx['subtitleKey'].toString();
      if (key == 'transferToPersonalAccount') {
        return l10n.transferToPersonalAccount;
      }
      if (key == 'paymentForPlatformFees') return l10n.paymentForPlatformFees;
    }

    final bool isCredit = tx['isCredit'] == true;
    final bool isJob =
        tx['isJob'] == true ||
        tx['title']?.toString().startsWith('Job:') == true ||
        tx['title']?.toString().startsWith('কাজ:') == true;

    if (isJob) {
      return isCredit ? l10n.onlinePayment : l10n.cashPayAfterService;
    }

    return tx['subtitle'] ??
        getLocalizedCustomerName(context, tx['customer']) ??
        l10n.unknown;
  }

  /// Converts Bengali digits to English digits
  static String convertBengaliToEnglish(dynamic input) {
    if (input == null) return '';
    String str = input.toString();
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < 10; i++) {
      str = str.replaceAll(bengali[i], english[i]);
    }
    return str;
  }
}

/// A [TextInputFormatter] that converts Bengali digits to English digits.
class EnglishDigitFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final convertedText = LocalizationHelper.convertBengaliToEnglish(
      newValue.text,
    );

    if (convertedText == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(
      text: convertedText,
      selection: newValue.selection,
    );
  }
}
