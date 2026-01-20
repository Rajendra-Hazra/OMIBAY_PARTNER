// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ওমিবে পার্টনার';

  @override
  String get indiaCountryCode => '+91';

  @override
  String get welcomeBackPartnerMock => 'স্বাগতম ফিরে, পার্টনার (মক)!';

  @override
  String get onScheduledTime => 'নির্ধারিত সময়ে';

  @override
  String get earning => 'আয়';

  @override
  String get rating => 'রেটিং';

  @override
  String get languageUpdated => 'ভাষা আপডেট হয়েছে';

  @override
  String get verifyOtp => 'OTP যাচাই করুন';

  @override
  String get updatePhone => 'ফোন নম্বর আপডেট করুন';

  @override
  String get updateEmail => 'ইমেইল আপডেট করুন';

  @override
  String get newPhoneNumber => 'নতুন ফোন নম্বর';

  @override
  String get newEmailAddress => 'নতুন ইমেইল ঠিকানা';

  @override
  String get pleaseEnterValid10DigitNumber =>
      'দয়া করে সঠিক 10 সংখ্যার নম্বর দিন';

  @override
  String get pleaseEnterValidEmail => 'দয়া করে একটি সঠিক ইমেইল দিন';

  @override
  String get otpSentSuccessfully => 'OTP সফলভাবে পাঠানো হয়েছে (ডেমো: 123456)';

  @override
  String get phoneUpdatedSuccessfully => 'ফোন নম্বর সফলভাবে আপডেট হয়েছে!';

  @override
  String get emailUpdatedSuccessfully => 'ইমেইল সফলভাবে আপডেট হয়েছে!';

  @override
  String get invalidOtpDemo => 'অবৈধ OTP। ডেমোর জন্য 123456 ব্যবহার করুন।';

  @override
  String get confirmChange => 'পরিবর্তন নিশ্চিত করুন';

  @override
  String get sendVerificationCode => 'যাচাইকরণ কোড পাঠান';

  @override
  String get fullName => 'পুরো নাম';

  @override
  String get age => 'বয়স';

  @override
  String get address => 'ঠিকানা';

  @override
  String get requiredFields => 'প্রয়োজনীয় ক্ষেত্র';

  @override
  String get pleaseFillRequiredFields =>
      'দয়া করে নিচের প্রয়োজনীয় ক্ষেত্রগুলো পূরণ করুন:';

  @override
  String get profileSavedSuccessfully => 'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে!';

  @override
  String errorSavingProfile(Object error) {
    return 'প্রোফাইল সংরক্ষণে ত্রুটি: $error';
  }

  @override
  String get profilePhoto => 'প্রোফাইল ছবি';

  @override
  String enterOtpSentTo(Object type) {
    return 'আপনার নতুন $type-এ পাঠানো 6-সংখ্যার কোডটি দিন।';
  }

  @override
  String enterNewToReceiveCode(Object type) {
    return 'যাচাইকরণ কোড পেতে আপনার নতুন $type নিচে দিন।';
  }

  @override
  String get optional => '(ঐচ্ছিক)';

  @override
  String get personalInformation => 'ব্যক্তিগত তথ্য';

  @override
  String get enterYourFullName => 'আপনার পুরো নাম লিখুন';

  @override
  String get enterYourAge => 'আপনার বয়স লিখুন';

  @override
  String get exampleEmail => 'example@email.com';

  @override
  String get enterYourFullAddress => 'আপনার পুরো ঠিকানা লিখুন';

  @override
  String get mobileNumber => 'মোবাইল নম্বর';

  @override
  String get verify => 'যাচাই করুন';

  @override
  String get pleaseVerifyMobileToContinue =>
      'চালিয়ে যেতে আপনার মোবাইল নম্বর যাচাই করুন';

  @override
  String get pleaseEnterValid10DigitMobile =>
      'দয়া করে সঠিক 10 সংখ্যার মোবাইল নম্বর দিন';

  @override
  String otpSentToWithDemo(Object phone) {
    return '+91 $phone-এ OTP পাঠানো হয়েছে (ডেমো: 123456)';
  }

  @override
  String get verifyMobileNumber => 'মোবাইল নম্বর যাচাই করুন';

  @override
  String otpSentTo(Object phone) {
    return '+91 $phone-এ OTP পাঠানো হয়েছে';
  }

  @override
  String get demoOtp => 'ডেমো OTP: 123456';

  @override
  String get mobileNumberVerifiedSuccessfully =>
      'মোবাইল নম্বর সফলভাবে যাচাই করা হয়েছে!';

  @override
  String get saveProfile => 'প্রোফাইল সংরক্ষণ করুন';

  @override
  String get pressBackAgainToExit => 'প্রস্থান করতে আবার পেছনে টিপুন';

  @override
  String get appSlogan => 'নিজের কাজ। নিজের বস।';

  @override
  String get continuingToLogin => 'লগইনে চলছে..';

  @override
  String get welcomePartner => 'স্বাগতম পার্টনার';

  @override
  String get welcome => 'স্বাগতম';

  @override
  String get partner => 'পার্টনার';

  @override
  String get loginSubtitle => 'আপনার সার্ভিস ব্যবসা পরিচালনা করতে লগইন করুন';

  @override
  String get phoneNumber => 'ফোন নম্বর';

  @override
  String get phoneNumberMustStartWith =>
      'ফোন নম্বর 6, 7, 8 বা 9 দিয়ে শুরু হতে হবে';

  @override
  String get phoneNumberMustBe10Digits => 'ফোন নম্বর 10 সংখ্যার হতে হবে';

  @override
  String get invalidPhoneFormat => 'অবৈধ ফোন নম্বর ফরম্যাট';

  @override
  String get sendOtpToPhoneNumber => 'ফোন নম্বরে OTP পাঠান';

  @override
  String get or => 'অথবা';

  @override
  String get continueWithGoogle => 'গুগল দিয়ে চালিয়ে যান';

  @override
  String get findMyAccount => 'আমার অ্যাকাউন্ট খুঁজুন';

  @override
  String get devSkipToVerification => 'ডেভ: যাচাইকরণে যান';

  @override
  String get enterOtp => '6-সংখ্যার OTP লিখুন';

  @override
  String sentTo(String phoneNumber) {
    return '+91 $phoneNumber-এ পাঠানো হয়েছে';
  }

  @override
  String get backToPhoneNumber => 'ফোন নম্বরে ফিরে যান';

  @override
  String get verifyAndContinue => 'যাচাই করুন এবং চালিয়ে যান';

  @override
  String get didntReceiveOtp => 'OTP পাননি?';

  @override
  String get resendOtp => 'আবার OTP পাঠান';

  @override
  String resendIn(String seconds) {
    return '$secondsসে পরে আবার পাঠান';
  }

  @override
  String get selectYourAccount => 'আপনার অ্যাকাউন্ট নির্বাচন করুন';

  @override
  String get accountRecovered => 'অ্যাকাউন্ট পুনরুদ্ধার হয়েছে';

  @override
  String get accountVerifiedSuccess =>
      'আপনার অ্যাকাউন্ট সফলভাবে যাচাই করা হয়েছে।';

  @override
  String get goToDashboard => 'ড্যাশবোর্ডে যান';

  @override
  String get byContinyingYouAgree =>
      'চালিয়ে যাওয়ার মাধ্যমে, আপনি সম্মত হচ্ছেন আমাদের';

  @override
  String get termsOfService => 'সেবার শর্তাবলী';

  @override
  String get and => 'এবং';

  @override
  String get privacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get findMyAccountTitle => 'আমার অ্যাকাউন্ট খুঁজুন';

  @override
  String get enterRegisteredInfo => 'আপনার অ্যাকাউন্ট খুঁজতে নিবন্ধিত তথ্য দিন';

  @override
  String get phone => 'ফোন';

  @override
  String get email => 'ইমেইল';

  @override
  String get emailAddress => 'ইমেইল ঠিকানা';

  @override
  String get enterPhoneNumber => 'একটি ফোন নম্বর লিখুন';

  @override
  String get enterEmailAddress => 'একটি ইমেইল ঠিকানা লিখুন';

  @override
  String get accountFound => 'অ্যাকাউন্ট পাওয়া গেছে (মক)';

  @override
  String get logout => 'লগআউট';

  @override
  String get logoutConfirmation => 'আপনি কি লগআউট করতে চান?';

  @override
  String get cancel => 'বাতিল';

  @override
  String get helpAndSupport => 'সহায়তা ও সাপোর্ট';

  @override
  String get chatWithSupport => 'সাপোর্টে চ্যাট করুন';

  @override
  String get whatsAppSupport => 'হোয়াটসঅ্যাপ সাপোর্ট';

  @override
  String get accountIssueAndFaq => 'অ্যাকাউন্ট সমস্যা ও FAQ';

  @override
  String get commonQuestionsAndAccountHelp =>
      'সাধারণ প্রশ্ন এবং অ্যাকাউন্ট সহায়তা';

  @override
  String get signOutOfYourAccount => 'আপনার অ্যাকাউন্ট থেকে সাইন আউট করুন';

  @override
  String get couldNotLaunchWhatsApp => 'হোয়াটসঅ্যাপ চালু করা যায়নি';

  @override
  String get documentVerification => 'ডকুমেন্ট যাচাইকরণ';

  @override
  String get signingUpTo => 'সাইন আপ করছেন';

  @override
  String get heresWhatYouNeedToDo => 'আপনার অ্যাকাউন্ট সেট আপ করতে যা করতে হবে';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get aadharCard => 'আধার কার্ড';

  @override
  String get panCardOptional => 'প্যান কার্ড (ঐচ্ছিক)';

  @override
  String get drivingLicenseOptional => 'ড্রাইভিং লাইসেন্স (ঐচ্ছিক)';

  @override
  String get workVerification => 'কাজের যাচাইকরণ';

  @override
  String get permission => 'অনুমতি';

  @override
  String get skipForNowDevMode => 'এখনকার জন্য এড়িয়ে যান (ডেভ মোড)';

  @override
  String get pendingForVerification => 'যাচাইয়ের জন্য অপেক্ষমাণ';

  @override
  String get locationSelection => 'অবস্থান নির্বাচন';

  @override
  String get confirmLocationToEarn =>
      'আপনি যেখানে আয় করতে চান সেই অবস্থান নিশ্চিত করুন';

  @override
  String get searchForLocation => 'অবস্থান অনুসন্ধান করুন...';

  @override
  String get useCurrentLocation => 'বর্তমান অবস্থান ব্যবহার করুন';

  @override
  String get selected => 'নির্বাচিত';

  @override
  String get whyWeNeedLocation => 'আমাদের আপনার অবস্থান কেন দরকার?';

  @override
  String get locationExplanation =>
      'আপনার অবস্থান আমাদের কাছাকাছি গ্রাহকদের সাথে সংযোগ করতে, সময়মত সেবা প্রদান নিশ্চিত করতে এবং ভ্রমণের সময় কমিয়ে আপনার আয়ের সম্ভাবনা বাড়াতে সাহায্য করে।';

  @override
  String get useThisLocationForEarning => 'আয়ের জন্য এই অবস্থান ব্যবহার করুন';

  @override
  String get fetchingYourLocation => 'আপনার অবস্থান আনা হচ্ছে...';

  @override
  String get locationPermissionsDenied =>
      'অবস্থানের অনুমতি স্থায়ীভাবে অস্বীকার করা হয়েছে। দয়া করে সেটিংসে এটি সক্রিয় করুন।';

  @override
  String get unknown => 'অজানা';

  @override
  String get notAvailable => 'প্রযোজ্য নয়';

  @override
  String get lessThanOneYear => '< ১ বছর';

  @override
  String get newLabel => 'নতুন';

  @override
  String get aadharCardVerification => 'আধার কার্ড যাচাইকরণ';

  @override
  String get enterAadharDetails => 'আধারের বিবরণ দিন';

  @override
  String get fillAadharInfo => 'আপনার আধার কার্ডের তথ্য দিন';

  @override
  String get aadharNumber => 'আধার নম্বর';

  @override
  String get fullNameAsPerAadhar => 'পুরো নাম (আধার অনুযায়ী)';

  @override
  String get enterYourName => 'আপনার নাম লিখুন';

  @override
  String get dateOfBirth => 'জন্ম তারিখ';

  @override
  String get uploadAadharCard => 'আধার কার্ড আপলোড করুন';

  @override
  String get uploadClearPhotos => 'উভয় পাশের স্পষ্ট ছবি আপলোড করুন';

  @override
  String get frontSide => 'সামনের দিক';

  @override
  String get backSide => 'পেছনের দিক';

  @override
  String get frontSidePhoto => 'সামনের দিকের ছবি';

  @override
  String get backSidePhoto => 'পেছনের দিকের ছবি';

  @override
  String get camera => 'ক্যামেরা';

  @override
  String get gallery => 'গ্যালারি';

  @override
  String get submitAndContinue => 'জমা দিন এবং চালিয়ে যান';

  @override
  String get sample => 'নমুনা';

  @override
  String get sampleAadharCard => 'নমুনা আধার কার্ড';

  @override
  String get aadharShouldLookLikeThis =>
      'আপনার আধার কার্ড এরকম দেখতে হওয়া উচিত। নিশ্চিত করুন ছবি স্পষ্ট এবং সব বিবরণ দৃশ্যমান।';

  @override
  String get aadharDetailsSaved => 'আধারের বিবরণ সফলভাবে সংরক্ষিত হয়েছে!';

  @override
  String get errorSavingData => 'ডেটা সংরক্ষণে ত্রুটি:';

  @override
  String get errorPickingImage => 'ছবি নির্বাচনে ত্রুটি:';

  @override
  String get couldNotLoadSample => 'নমুনা লোড করা যায়নি';

  @override
  String get requestingCameraAccess => 'ক্যামেরা অ্যাক্সেস অনুরোধ করা হচ্ছে...';

  @override
  String get cameraPermissionRequired => 'ক্যামেরার অনুমতি প্রয়োজন';

  @override
  String get galleryPermissionRequired =>
      'ছবি নির্বাচনের জন্য গ্যালারির অনুমতি প্রয়োজন';

  @override
  String get uploaded => 'আপলোড হয়েছে';

  @override
  String uploadedWithTitle(Object title) {
    return '$title আপলোড হয়েছে';
  }

  @override
  String get view => 'দেখুন';

  @override
  String get change => 'পরিবর্তন';

  @override
  String get uploadText => 'আপলোড';

  @override
  String get tapToCaptureOrSelect => 'ক্যাপচার বা নির্বাচন করতে ট্যাপ করুন';

  @override
  String get preview => 'প্রাকদর্শন';

  @override
  String get panCardVerification => 'প্যান কার্ড যাচাইকরণ';

  @override
  String get enterPanDetails => 'প্যানের বিবরণ দিন';

  @override
  String get fillPanInfo => 'আপনার প্যান কার্ডের তথ্য দিন';

  @override
  String get panNumber => 'প্যান নম্বর';

  @override
  String get fullNameAsPerPan => 'পুরো নাম (প্যান অনুযায়ী)';

  @override
  String get enterNameAsOnPan => 'প্যান কার্ডে যেমন আছে তেমন নাম লিখুন';

  @override
  String get uploadPanCard => 'প্যান কার্ড আপলোড করুন';

  @override
  String get samplePanCard => 'নমুনা প্যান কার্ড';

  @override
  String get panShouldLookLikeThis =>
      'আপনার প্যান কার্ড এরকম দেখতে হওয়া উচিত। নিশ্চিত করুন সব বিবরণ দৃশ্যমান।';

  @override
  String get panDetailsSaved => 'প্যানের বিবরণ সফলভাবে সংরক্ষিত হয়েছে!';

  @override
  String get panCardPreview => 'প্যান কার্ড প্রিভিউ';

  @override
  String get saveAndContinue => 'সংরক্ষণ করুন এবং চালিয়ে যান';

  @override
  String get drivingLicenseVerification => 'ড্রাইভিং লাইসেন্স যাচাইকরণ';

  @override
  String get enterDlDetails => 'DL বিবরণ দিন';

  @override
  String get fillDlInfo => 'আপনার ড্রাইভিং লাইসেন্সের তথ্য দিন';

  @override
  String get dlNumber => 'DL নম্বর';

  @override
  String get fullNameAsPerDl => 'পুরো নাম (DL অনুযায়ী)';

  @override
  String get enterNameAsOnDl => 'ড্রাইভিং লাইসেন্সে যেমন আছে তেমন নাম লিখুন';

  @override
  String get uploadDrivingLicense => 'ড্রাইভিং লাইসেন্স আপলোড করুন';

  @override
  String get sampleDrivingLicense => 'নমুনা ড্রাইভিং লাইসেন্স';

  @override
  String get dlShouldLookLikeThis =>
      'আপনার ড্রাইভিং লাইসেন্স এরকম দেখতে হওয়া উচিত। নিশ্চিত করুন সব বিবরণ দৃশ্যমান।';

  @override
  String get dlDetailsSaved =>
      'ড্রাইভিং লাইসেন্সের বিবরণ সফলভাবে সংরক্ষিত হয়েছে!';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get selectServices => 'আপনার সেবা নির্বাচন করুন';

  @override
  String get chooseServicesToOffer => 'আপনি যে সেবাগুলি দিতে চান তা বেছে নিন';

  @override
  String get plumber => 'প্লাম্বার';

  @override
  String get electrician => 'ইলেকট্রিশিয়ান';

  @override
  String get carpenter => 'কার্পেন্টার';

  @override
  String get gardening => 'বাগান করা';

  @override
  String get cleaning => 'পরিষ্কার করা';

  @override
  String get menSalon => 'পুরুষদের সেলুন';

  @override
  String get womenSalon => 'মহিলাদের সেলুন';

  @override
  String get makeupAndBeauty => 'মেকআপ ও বিউটি';

  @override
  String get quickTransport => 'দ্রুত পরিবহন';

  @override
  String get appliancesRepair => 'যন্ত্রপাতি মেরামত ও প্রতিস্থাপন';

  @override
  String get ac => 'এসি';

  @override
  String get airCooler => 'এয়ার কুলার';

  @override
  String get chimney => 'চিমনি';

  @override
  String get geyser => 'গিজার';

  @override
  String get laptop => 'ল্যাপটপ';

  @override
  String get refrigerator => 'রেফ্রিজারেটর';

  @override
  String get washingMachine => 'ওয়াশিং মেশিন';

  @override
  String get microwave => 'মাইক্রোওয়েভ';

  @override
  String get television => 'টেলিভিশন';

  @override
  String get waterPurifier => 'ওয়াটার পিউরিফায়ার';

  @override
  String get details => 'বিবরণ';

  @override
  String get totalExperience => 'মোট অভিজ্ঞতা (বছর)';

  @override
  String get specialSkills => 'বিশেষ দক্ষতা';

  @override
  String get workVideo => 'কাজের ভিডিও (30সে - 1মিনিট)';

  @override
  String get selectVideoSource => 'ভিডিও সোর্স নির্বাচন করুন';

  @override
  String get files => 'ফাইল';

  @override
  String get videoPreview => 'ভিডিও প্রিভিউ';

  @override
  String get videoMustBeBetween =>
      'ভিডিও 5 সেকেন্ড থেকে 1 মিনিটের মধ্যে হতে হবে';

  @override
  String get videoUploadedSuccessfully => 'ভিডিও সফলভাবে আপলোড হয়েছে!';

  @override
  String get workVerificationSaved =>
      'কাজের যাচাইকরণের বিবরণ সফলভাবে সংরক্ষিত হয়েছে!';

  @override
  String get serviceSubmittedForVerification =>
      'সেবা যাচাইয়ের জন্য জমা দেওয়া হয়েছে! অনুমোদন হলে আমরা আপনাকে জানাব।';

  @override
  String get workSelection => 'কাজের নির্বাচন';

  @override
  String get selectServicesProvide =>
      'আপনি যে সেবা প্রদান করেন তা নির্বাচন করুন';

  @override
  String countSelected(Object count) {
    return '$countটি নির্বাচিত';
  }

  @override
  String serviceDetails(Object name) {
    return '$name এর বিবরণ';
  }

  @override
  String get uploadServiceVideo => 'সার্ভিস ভিডিও আপলোড করুন';

  @override
  String get minMaxVideoDuration => 'ন্যূনতম 30সে - সর্বোচ্চ 1মি';

  @override
  String get selectAppliancesRepair =>
      'মেরামত করতে পারেন এমন সরঞ্জাম নির্বাচন করুন:';

  @override
  String get aadharHint => 'XXXX XXXX XXXX';

  @override
  String get panHint => 'ABCDE1234F';

  @override
  String get dlHint => 'KA0120200012345';

  @override
  String get dobHint => 'দিন/মাস/বছর';

  @override
  String get experienceHint => 'উদা: 5';

  @override
  String get skillsHint => 'উদা: ইন্ডাস্ট্রিয়াল ওয়্যারিং';

  @override
  String get home => 'হোম';

  @override
  String get jobs => 'কাজ';

  @override
  String get earnings => 'আয়';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String hello(String name) {
    return 'হ্যালো, $name';
  }

  @override
  String get offline => 'অফলাইন';

  @override
  String get online => 'অনলাইন';

  @override
  String get activeJobs => 'সক্রিয় কাজ';

  @override
  String get noActiveJobs => 'কোন সক্রিয় কাজ নেই';

  @override
  String get goOnlineToReceiveJobs => 'কাজ পেতে অনলাইন হন!';

  @override
  String get ongoing => 'চলমান';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get payNow => 'এখনই পে করুন';

  @override
  String get bankTransfer => 'ব্যাংক ট্রান্সফার';

  @override
  String get upiWithdraw => 'UPI উইথড্র';

  @override
  String get addBankAccountDetails =>
      'প্রথমে আপনার ব্যাংক অ্যাকাউন্টের বিবরণ যোগ করুন';

  @override
  String get addUpiId => 'UPI আইডি যোগ করুন';

  @override
  String get add => 'যোগ করুন';

  @override
  String withdrawVia(String method) {
    return '$method দিয়ে উইথড্র করুন';
  }

  @override
  String get enterAmountToWithdraw => 'উইথড্রয়ের পরিমাণ লিখুন:';

  @override
  String availableBalanceWithAmount(String amount) {
    return 'উপলব্ধ ব্যালেন্স: ₹$amount';
  }

  @override
  String get invalidAmountOrInsufficientBalance =>
      'অবৈধ পরিমাণ বা অপর্যাপ্ত ব্যালেন্স';

  @override
  String withdrawalWithMethod(Object method) {
    return 'উত্তোলন ($method)';
  }

  @override
  String get transferToPersonalAccount => 'ব্যক্তিগত অ্যাকাউন্টে স্থানান্তর';

  @override
  String get personalAccount => 'ব্যক্তিগত অ্যাকাউন্ট';

  @override
  String get withdrawal => 'উত্তোলন';

  @override
  String get withdrawalProcessed => 'উত্তোলনের অনুরোধ সম্পন্ন হয়েছে!';

  @override
  String get withdraw => 'উইথড্র';

  @override
  String get enterAmountToAddOrPay => 'যোগ বা পে করার পরিমাণ লিখুন:';

  @override
  String get quickAmounts => 'দ্রুত পরিমাণ:';

  @override
  String get invalidAmount => 'অবৈধ পরিমাণ';

  @override
  String get dueAmountPaid => 'বকেয়া পরিশোধ করা হয়েছে';

  @override
  String get paymentForPlatformFees => 'প্ল্যাটফর্ম ফি-র জন্য পেমেন্ট';

  @override
  String get paymentProcessedSuccessfully =>
      'পেমেন্ট সফলভাবে প্রক্রিয়া হয়েছে!';

  @override
  String get proceedToPay => 'পে করতে এগিয়ে যান';

  @override
  String get tips => 'টিপস';

  @override
  String get orders => 'অর্ডার';

  @override
  String totalForMonth(String month) {
    return '$month-এর জন্য মোট';
  }

  @override
  String earningsForMonthAndDay(String month, String day) {
    return '$month $day-এর আয়';
  }

  @override
  String get incentivesAndOffers => 'ইনসেনটিভ ও অফার';

  @override
  String get weeklyBonusChallenge => 'সাপ্তাহিক বোনাস চ্যালেঞ্জ';

  @override
  String get weeklyBonusSubtitle =>
      'অতিরিক্ত ₹500 আয় করতে 15টি কাজ সম্পন্ন করুন';

  @override
  String jobsDoneWithProgress(String count) {
    return '$count/15টি কাজ সম্পন্ন';
  }

  @override
  String potentialEarnings(String amount) {
    return '₹$amount সম্ভাব্য আয়';
  }

  @override
  String referAndEarnWithAmount(String amount) {
    return 'রেফার করুন এবং ₹$amount আয় করুন';
  }

  @override
  String get referSubtitle =>
      'আপনার বন্ধুদের ওমিবে পার্টনারে যোগ দিতে আমন্ত্রণ জানান';

  @override
  String get invite => 'আমন্ত্রণ';

  @override
  String get noTransactionsYet => 'এখনও কোন লেনদেন নেই';

  @override
  String get referAndEarn => 'রেফার করুন ও আয় করুন';

  @override
  String get referHeroTitle => 'বন্ধুকে রেফার করুন এবং ₹200 আয় করুন';

  @override
  String get referHeroSubtitle =>
      'প্রতিটি সফল পার্টনার যোগদানের জন্য রিওয়ার্ড ক্রেডিট আয় করুন।';

  @override
  String get yourReferralCode => 'আপনার রেফারেল কোড';

  @override
  String get codeCopied => 'কোডটি ক্লিপবোর্ডে কপি করা হয়েছে!';

  @override
  String get howItWorks => 'এটি যেভাবে কাজ করে';

  @override
  String get step1Title => 'বন্ধুদের আমন্ত্রণ জানান';

  @override
  String get step1Desc =>
      'পরিষেবার কাজ খুঁজছেন এমন বন্ধুদের সাথে আপনার রেফারেল কোড শেয়ার করুন।';

  @override
  String get step2Title => 'পার্টনার যোগদান';

  @override
  String get step2Desc =>
      'তারা পার্টনার হিসেবে রেজিস্টার করবে এবং ডকুমেন্ট ভেরিফিকেশন সম্পন্ন করবে।';

  @override
  String get step3Title => 'রিওয়ার্ড আয় করুন';

  @override
  String get step3Desc =>
      'তারা তাদের 5ম কাজ সম্পন্ন করলে, আপনি আপনার ওয়ালেটে ₹200 পাবেন।';

  @override
  String get totalReferrals => 'মোট রেফারেল';

  @override
  String get totalEarned => 'মোট আয়';

  @override
  String get shareCode => 'কোড শেয়ার করুন';

  @override
  String get referralTermsTitle => 'রেফারেল শর্তাবলী';

  @override
  String get referralTermsPoint1 =>
      '1. প্রতিটি সফল পার্টনার যোগদানের জন্য রেফারেল রিওয়ার্ড হল ₹200।';

  @override
  String get referralTermsPoint2 =>
      '2. রেফার করা পার্টনার তাদের প্রথম 5টি সফল কাজ সম্পন্ন করার পরেই রিওয়ার্ড ক্রেডিট করা হয়।';

  @override
  String get referralTermsPoint3 =>
      '3. রেফার করা পার্টনারকে রেজিস্ট্রেশনের সময় আপনার অনন্য রেফারেল কোড ব্যবহার করতে হবে।';

  @override
  String get referralTermsPoint4 =>
      '4. রেফারেল রিওয়ার্ড যাচাই সাপেক্ষে এবং প্রতারণামূলক কার্যকলাপের ক্ষেত্রে তা বাতিল হতে পারে।';

  @override
  String get referralTermsPoint5 =>
      '5. ওমিবে কোনও পূর্ব বিজ্ঞপ্তি ছাড়াই রেফারেল প্রোগ্রাম পরিবর্তন বা বন্ধ করার অধিকার রাখে।';

  @override
  String get transactionDetails => 'লেনদেনের বিবরণ';

  @override
  String get paymentCredited => 'পেমেন্ট জমা হয়েছে';

  @override
  String get feeDeducted => 'ফি কাটা হয়েছে';

  @override
  String get onlinePayment => 'অনলাইন পেমেন্ট';

  @override
  String get cashPayAfterService => 'নগদ (পরিষেবার পরে পরিশোধ)';

  @override
  String get transactionId => 'লেনদেন আইডি';

  @override
  String get dateTime => 'তারিখ ও সময়';

  @override
  String get jobReference => 'কাজের রেফারেন্স';

  @override
  String get paymentMethod => 'পেমেন্ট পদ্ধতি';

  @override
  String get transactionType => 'লেনদেনের ধরন';

  @override
  String get description => 'বিবরণ';

  @override
  String get earningsBreakdown => 'আয়ের ব্রেকডাউন';

  @override
  String get totalJobPrice => 'কাজের মোট মূল্য';

  @override
  String get serviceAmountExclTip => 'পরিষেবার মূল্য (টিপস ছাড়া)';

  @override
  String get gst => 'জিএসটি (5%)';

  @override
  String get platformFee => 'প্ল্যাটফর্ম ফি (20%)';

  @override
  String get tipToPartner => 'টিপস (100% পার্টনারের)';

  @override
  String get yourNetEarning => 'আপনার নিট আয়';

  @override
  String get cashPaymentNote => 'নগদ পেমেন্ট নোট';

  @override
  String collectedCashFromCustomer(String amount) {
    return 'আপনি গ্রাহকের কাছ থেকে নগদে ₹$amount সংগ্রহ করেছেন।';
  }

  @override
  String amountDueToOmiBay(String amount) {
    return 'ওমিবে-কে প্রদেয় পরিমাণ: ₹$amount';
  }

  @override
  String get noTransactionHistoryFound => 'কোনও লেনদেনের ইতিহাস পাওয়া যায়নি';

  @override
  String get exportHistory => 'ইতিহাস ডাউনলোড করুন';

  @override
  String get processed => 'সম্পন্ন';

  @override
  String get deducted => 'কাটা হয়েছে';

  @override
  String get activeJob => 'চলতি কাজ';

  @override
  String get totalDuration => 'মোট সময়কাল';

  @override
  String get jobInProgress => 'কাজ চলছে';

  @override
  String get serviceChecklist => 'পরিষেবা চেকলিস্ট';

  @override
  String get afterServicePhotos => 'পরিষেবার পরের ছবি';

  @override
  String get markAsCompleted => 'সম্পন্ন হিসেবে চিহ্নিত করুন';

  @override
  String get howCanWeHelp => 'আমরা কীভাবে আপনাকে সাহায্য করতে পারি?';

  @override
  String get chatNow => 'চ্যাট করুন';

  @override
  String get callNow => 'কল করুন';

  @override
  String get couldNotLaunchDialer => 'ফোন ডায়ালার চালু করা যায়নি';

  @override
  String get jobCompleted => 'কাজ সম্পন্ন!';

  @override
  String earnedFromJob(String amount) {
    return 'আপনি এই কাজ থেকে ₹$amount আয় করেছেন।';
  }

  @override
  String get amountCreditedToWallet => 'ওয়ালেটে টাকা জমা হয়েছে';

  @override
  String get cashCollectedFeeDeducted =>
      'নগদ সংগ্রহ করা হয়েছে - প্ল্যাটফর্ম ফি কাটা হয়েছে';

  @override
  String get customerRating => 'গ্রাহক রেটিং';

  @override
  String get ratingGivenByCustomer =>
      'আপনার পরিষেবার জন্য গ্রাহকের দেওয়া রেটিং';

  @override
  String get backToHome => 'হোমে ফিরে যান';

  @override
  String get resumeWork => 'কাজ পুনরায় শুরু করুন';

  @override
  String get pauseWork => 'কাজ বিরতি দিন';

  @override
  String get workResumed => 'কাজ পুনরায় শুরু হয়েছে';

  @override
  String get markComplete => 'সম্পন্ন চিহ্নিত করুন';

  @override
  String get startJourney => 'যাত্রা শুরু করুন';

  @override
  String get arrived => 'পৌঁছেছি';

  @override
  String get startWork => 'কাজ শুরু করুন';

  @override
  String get completeJobQuestion => 'কাজটি কি সম্পন্ন?';

  @override
  String get completeJobConfirmation =>
      'অনুগ্রহ করে নিশ্চিত করুন যে কাজটি সফলভাবে সম্পন্ন হয়েছে।';

  @override
  String get receiveMoney => 'টাকা গ্রহণ করুন';

  @override
  String get completionProof => 'সম্পন্ন হওয়ার প্রমাণ';

  @override
  String get addPhoto => 'ছবি যোগ করুন';

  @override
  String get addVideo => 'ভিডিও যোগ করুন';

  @override
  String get min10Sec => 'কমপক্ষে 10 সেকেন্ড';

  @override
  String get prepaid => 'প্রিপেইড';

  @override
  String get cash => 'নগদ';

  @override
  String get showQr => 'QR দেখান';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get jobMarkedAsCompleted => 'কাজটি সম্পন্ন হিসেবে চিহ্নিত হয়েছে!';

  @override
  String get scanToPay => 'স্ক্যান করে পেমেন্ট করুন';

  @override
  String get scanToPayInstructions =>
      'পেমেন্ট সম্পন্ন করতে অনুগ্রহ করে গ্রাহককে এই QR কোডটি স্ক্যান করতে বলুন।';

  @override
  String get totalAmountToPay => 'মোট প্রদেয় পরিমাণ';

  @override
  String get paymentReceived => 'পেমেন্ট পাওয়া গেছে';

  @override
  String bookingId(Object id) {
    return 'বুকিং আইডি: $id';
  }

  @override
  String get fullHomeCleaning => 'সম্পূর্ণ বাড়ি পরিষ্কার';

  @override
  String get kitchenDeepClean => 'রান্নাঘর গভীর পরিষ্কার';

  @override
  String get bathroomSanitization => 'বাথরুম স্যানিটাইজেশন';

  @override
  String get sofaAndCarpetCleaning => 'সোফা ও কার্পেট পরিষ্কার';

  @override
  String get acServiceAndRepair => 'এসি সার্ভিস ও মেরামত';

  @override
  String get pestControl => 'পেস্ট কন্ট্রোল';

  @override
  String get instant => 'তাৎক্ষণিক';

  @override
  String get scheduled => 'নির্ধারিত';

  @override
  String get awesome => 'অসাধারণ!';

  @override
  String get noProblem => 'কোন সমস্যা নেই';

  @override
  String get jobAccepted => 'কাজ গৃহীত';

  @override
  String get jobDeclined => 'কাজ প্রত্যাখ্যাত';

  @override
  String get goodLuckWithNewMission => 'আপনার নতুন মিশনে শুভকামনা!';

  @override
  String get takeABreak => 'একটু বিশ্রাম নিন, আমরা শীঘ্রই আরও আনব।';

  @override
  String get todaysPerformance => 'আজকের পারফরম্যান্স';

  @override
  String get business => 'ব্যবসা';

  @override
  String get jobsDone => 'সম্পন্ন কাজ';

  @override
  String get onlineTime => 'অনলাইন সময়';

  @override
  String get proTips => 'প্রো টিপস';

  @override
  String get weeklyChallenge => 'সাপ্তাহিক চ্যালেঞ্জ';

  @override
  String completeJobsToEarn(String count) {
    return 'বোনাস পেতে $countটি কাজ সম্পূর্ণ করুন';
  }

  @override
  String get inviteFriendsToJoin =>
      'বন্ধুদের ওমিবে পার্টনারে যোগ দিতে আমন্ত্রণ জানান';

  @override
  String get manageServiceRequests => 'আপনার সার্ভিস রিকোয়েস্ট পরিচালনা করুন';

  @override
  String get searchByBookingIdOrService =>
      'বুকিং আইডি বা সার্ভিস দিয়ে খুঁজুন...';

  @override
  String get accepted => 'গৃহীত';

  @override
  String get completed => 'সম্পন্ন';

  @override
  String get noJobsFound => 'কোন কাজ পাওয়া যায়নি';

  @override
  String get whenYouAcceptJob =>
      'আপনি যখন কোন কাজ গ্রহণ করবেন, তা এখানে দেখাবে।';

  @override
  String get availableBalance => 'উপলব্ধ ব্যালেন্স';

  @override
  String get availableBalanceLabel => 'উপলব্ধ ব্যালেন্স:';

  @override
  String get withdrawalRequestProcessed =>
      'উইথড্রয়ের অনুরোধ প্রক্রিয়া করা হয়েছে!';

  @override
  String get firstAddBankAccount =>
      'প্রথমে আপনার ব্যাংক অ্যাকাউন্টের বিবরণ যোগ করুন';

  @override
  String get firstAddUpiId => 'প্রথমে আপনার UPI আইডি যোগ করুন';

  @override
  String get complete15JobsToEarn =>
      '₹500 অতিরিক্ত আয় করতে 15টি কাজ সম্পন্ন করুন';

  @override
  String jobsDoneCount(String count) {
    return '$count/15 কাজ সম্পন্ন';
  }

  @override
  String get potential => 'সম্ভাব্য';

  @override
  String get referAndEarnAmount => 'রেফার করুন ও ₹200 আয় করুন';

  @override
  String get inviteYourFriends =>
      'আপনার বন্ধুদের ওমিবে পার্টনারে যোগ দিতে আমন্ত্রণ জানান';

  @override
  String get transactionHistory => 'লেনদেনের ইতিহাস';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get cashPayment => 'নগদ পেমেন্ট';

  @override
  String get myAccount => 'আমার অ্যাকাউন্ট';

  @override
  String get workWithUs => 'আমাদের সাথে কাজ';

  @override
  String get partnerId => 'পার্টনার আইডি:';

  @override
  String get myDocuments => 'আমার ডকুমেন্ট';

  @override
  String get myServices => 'আমার সেবা';

  @override
  String get helpCenter => 'সহায়তা কেন্দ্র';

  @override
  String get accountAndSettings => 'অ্যাকাউন্ট ও সেটিংস';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get manageLocation => 'অবস্থান পরিচালনা';

  @override
  String get managePermission => 'অনুমতি পরিচালনা';

  @override
  String get settings => 'সেটিংস';

  @override
  String get version => 'সংস্করণ';

  @override
  String get preferences => 'পছন্দ';

  @override
  String get appLanguage => 'অ্যাপের ভাষা';

  @override
  String get english => 'ইংরেজি';

  @override
  String get bengali => 'বাংলা';

  @override
  String get appearances => 'উপস্থিতি';

  @override
  String get light => 'হালকা';

  @override
  String get lightMode => 'হালকা মোড';

  @override
  String get pushNotifications => 'পুশ নোটিফিকেশন';

  @override
  String get pleaseEnableNotificationPermission =>
      'দয়া করে সেটিংসে নোটিফিকেশনের অনুমতি সক্রিয় করুন';

  @override
  String get accountSafety => 'অ্যাকাউন্ট সুরক্ষা';

  @override
  String get deactivateAccount => 'অ্যাকাউন্ট নিষ্ক্রিয় করুন';

  @override
  String get deleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get legalDocuments => 'আইনি নথি';

  @override
  String get termsAndConditions => 'শর্তাবলী';

  @override
  String get suspensionPolicy => 'স্থগিতাদেশ নীতি';

  @override
  String get deactivationWarning =>
      'আপনার অ্যাকাউন্ট নিষ্ক্রিয় করা অস্থায়ী। আপনার প্রোফাইল গ্রাহকদের থেকে লুকানো থাকবে, কিন্তু আপনার ডেটা সংরক্ষিত থাকবে।';

  @override
  String get whyDeactivating => 'আপনি কেন নিষ্ক্রিয় করছেন?';

  @override
  String get reasonBreak => 'প্ল্যাটফর্ম থেকে বিরতি নিচ্ছি';

  @override
  String get reasonNotifications => 'খুব বেশি নোটিফিকেশন';

  @override
  String get reasonOpportunities => 'যথেষ্ট কাজের সুযোগ পাচ্ছি না';

  @override
  String get reasonTechnical => 'অ্যাপের সাথে প্রযুক্তিগত সমস্যা';

  @override
  String get reasonPrivacy => 'গোপনীয়তা উদ্বেগ';

  @override
  String get reasonOther => 'অন্যান্য';

  @override
  String get pleaseTellMore => 'আমাদের আরও বলুন...';

  @override
  String get whatHappensDeactivate => 'নিষ্ক্রিয় করলে কী হয়?';

  @override
  String get deactivatePoint1 =>
      'আপনার প্রোফাইল ওমিবে প্ল্যাটফর্মে দৃশ্যমান হবে না।';

  @override
  String get deactivatePoint2 => 'আপনি কোনো নতুন কাজের নোটিফিকেশন পাবেন না।';

  @override
  String get deactivatePoint3 =>
      'আপনি যেকোনো সময় শুধু লগইন করে আবার সক্রিয় করতে পারেন।';

  @override
  String get deactivatePoint4 =>
      'নিষ্ক্রিয় করার আগে চলমান কাজগুলো অবশ্যই সম্পন্ন করতে হবে।';

  @override
  String get deactivateMyAccount => 'আমার অ্যাকাউন্ট নিষ্ক্রিয় করুন';

  @override
  String get accountDeactivatedSuccess =>
      'অ্যাকাউন্ট সফলভাবে নিষ্ক্রিয় করা হয়েছে। আপনি আবার লগইন করে এটি সক্রিয় করতে পারেন।';

  @override
  String get pleaseSelectReason =>
      'দয়া করে নিষ্ক্রিয় করার একটি কারণ নির্বাচন করুন';

  @override
  String get confirmDeactivation => 'নিষ্ক্রিয়করণ নিশ্চিত করুন';

  @override
  String get areYouSureDeactivate =>
      'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট সাময়িকভাবে নিষ্ক্রিয় করতে চান?';

  @override
  String get verifyDeactivation => 'নিষ্ক্রিয়করণ যাচাই করুন';

  @override
  String get enterOtpDeactivate =>
      'নিশ্চিত করতে আপনার নিবন্ধিত মোবাইল নম্বরে পাঠানো 6-সংখ্যার OTP লিখুন।';

  @override
  String get otpResent => 'OTP আবার পাঠানো হয়েছে!';

  @override
  String get verifyAndDeactivate => 'যাচাই করুন এবং নিষ্ক্রিয় করুন';

  @override
  String get deleteAccountCaution =>
      'অ্যাকাউন্ট সুরক্ষার সতর্কতা: এই পদক্ষেপটি স্থায়ী এবং অপরিবর্তনীয়। ওমিবে-তে আপনার পুরো পেশাদার ইতিহাস মুছে ফেলা হবে।';

  @override
  String get sorryToSeeYouGo => 'আমরা আপনাকে বিদায় জানাতে দুঃখিত';

  @override
  String get deletingPermanent => 'অ্যাকাউন্ট মুছে ফেলা স্থায়ী:';

  @override
  String get deletePoint1 =>
      'আপনার সমস্ত ব্যক্তিগত প্রোফাইল ডেটা স্থায়ীভাবে মুছে ফেলা হবে।';

  @override
  String get deletePoint2 =>
      'আপনার সম্পূর্ণ আয়ের ইতিহাস এবং লেনদেনের লগ হারিয়ে যাবে।';

  @override
  String get deletePoint3 =>
      'যেকোনো অপেক্ষমাণ বোনাস বা ইনসেনটিভ বাজেয়াপ্ত করা হবে।';

  @override
  String get deletePoint4 =>
      'আপনি আর এই অ্যাকাউন্টে লগইন করতে বা এটি পুনরুদ্ধার করতে পারবেন না।';

  @override
  String get understandIrreversible =>
      'আমি বুঝতে পারছি যে এই পদক্ষেপটি অপরিবর্তনীয় এবং আমি স্থায়ীভাবে আমার অ্যাকাউন্ট মুছতে চাই।';

  @override
  String get deletePermanently => 'স্থায়ীভাবে মুছুন';

  @override
  String get changedMyMind => 'আমি মত পরিবর্তন করেছি, ফিরে যান';

  @override
  String get accountDeletedSuccess =>
      'অ্যাকাউন্ট সফলভাবে মুছে ফেলা হয়েছে। আমরা আশা করি শীঘ্রই আপনাকে আবার দেখব!';

  @override
  String get finalWarning => 'চূড়ান্ত সতর্কতা';

  @override
  String get finalWarningContent =>
      'এটি আপনার শেষ সুযোগ। একবার আপনি মুছুন ক্লিক করলে, আপনার ওমিবে পার্টনার অ্যাকাউন্ট চিরতরে চলে যাবে। আপনি কি নিশ্চিত?';

  @override
  String get verifyPermanentDeletion => 'স্থায়ী মুছে ফেলা যাচাই করুন';

  @override
  String get enterOtpDeletePermanent =>
      'স্থায়ীভাবে আপনার অ্যাকাউন্ট মুছতে আপনার নিবন্ধিত মোবাইল নম্বরে পাঠানো 6-সংখ্যার OTP লিখুন।';

  @override
  String get searchHelp => 'সাহায্যের জন্য খুঁজুন...';

  @override
  String get all => 'সব';

  @override
  String get categoryAccount => 'অ্যাকাউন্ট';

  @override
  String get categoryNotification => 'নোটিফিকেশন';

  @override
  String get categoryService => 'সেবা';

  @override
  String get categoryJobs => 'কাজ';

  @override
  String get categoryPayments => 'পেমেন্ট';

  @override
  String get categoryDocuments => 'ডকুমেন্ট';

  @override
  String get categoryAppFeature => 'অ্যাপ বৈশিষ্ট্য';

  @override
  String get docVerificationPrompt =>
      'বেশিরভাগ অ্যাকাউন্ট সমস্যা ডকুমেন্ট যাচাইকরণ সম্পন্ন করার মাধ্যমে সমাধান করা হয়।';

  @override
  String noResultsFoundFor(Object query) {
    return '\"$query\"-এর জন্য কোনো ফলাফল পাওয়া যায়নি';
  }

  @override
  String get tryDifferentKeywords =>
      'বিভিন্ন কীওয়ার্ড চেষ্টা করুন বা বানান পরীক্ষা করুন';

  @override
  String get stillNeedHelp => 'এখনও সাহায্য প্রয়োজন?';

  @override
  String get stillNeedHelpContent =>
      'হোয়াটসঅ্যাপ সাপোর্টের সাথে চ্যাট করতে দয়া করে মূল অ্যাপে সহায়তা অপশনটি ব্যবহার করুন। আমাদের দল আপনাকে সহায়তা করতে 24/7 উপলব্ধ।';

  @override
  String get faqQuestion1 => 'আমি কীভাবে আমার অ্যাকাউন্ট যাচাই করব?';

  @override
  String get faqAnswer1 =>
      'আপনার অ্যাকাউন্ট যাচাই করতে, ডকুমেন্ট যাচাইকরণ স্ক্রিনে যান এবং প্রয়োজনীয় ডকুমেন্টগুলি আপলোড করুন: পরিচয়পত্র (আধার/প্যান), ঠিকানার প্রমাণ (ইউটিলিটি বিল/ব্যাংক স্টেটমেন্ট), এবং পেশাদার বিবরণ (প্রোফাইল ছবি এবং অভিজ্ঞতা)।';

  @override
  String get faqQuestion2 => 'পরিচয়পত্রের জন্য কোন কোন ডকুমেন্ট প্রয়োজন?';

  @override
  String get faqAnswer2 =>
      'আমরা আধার কার্ড বা প্যান কার্ড গ্রহণ করি। আধার কার্ডের জন্য, সামনে এবং পেছনে উভয় দিক আপলোড করতে হবে। নিশ্চিত করুন ছবিগুলো স্পষ্ট এবং সব বিবরণ পাঠযোগ্য।';

  @override
  String get faqQuestion3 => 'আমার ডকুমেন্ট প্রত্যাখ্যান করা হলে কী হবে?';

  @override
  String get faqAnswer3 =>
      'যদি আপনার ডকুমেন্ট প্রত্যাখ্যান করা হয়, আপনি কারণসহ একটি নোটিফিকেশন পাবেন। সাধারণ কারণগুলোর মধ্যে রয়েছে ঝাপসা ছবি, মেয়াদোত্তীর্ণ ডকুমেন্ট বা নামের অমিল। আপনি অবিলম্বে সংশোধিত ডকুমেন্ট পুনরায় আপলোড করতে পারেন।';

  @override
  String get faqQuestion4 => 'যাচাইকরণ প্রক্রিয়া কতক্ষণ সময় নেয়?';

  @override
  String get faqAnswer4 =>
      'যাচাইকরণ প্রক্রিয়া সাধারণত 24 থেকে 48 ঘন্টা সময় নেয়। আপনার অ্যাকাউন্ট যাচাই হয়ে গেলে এবং কাজ করার জন্য প্রস্তুত হলে আপনি একটি নোটিফিকেশন পাবেন।';

  @override
  String get faqQuestion5 =>
      'আমি কি আমার নিবন্ধিত ফোন নম্বর পরিবর্তন করতে পারি?';

  @override
  String get faqAnswer5 =>
      'হ্যাঁ, আপনি অ্যাকাউন্ট > প্রোফাইল-এ আপনার ফোন নম্বর আপডেট করতে পারেন। আপনাকে একটি OTP দিয়ে নতুন নম্বরটি যাচাই করতে হবে।';

  @override
  String get faqQuestion6 => 'আমি কীভাবে আমার পেমেন্টের বিবরণ সেট আপ করব?';

  @override
  String get faqAnswer6 =>
      'আপনার ব্যাংক অ্যাকাউন্ট বা UPI আইডি যোগ করতে অ্যাকাউন্ট > পেমেন্ট সেটআপ-এ যান। এখান থেকেই আপনার আয় স্থানান্তরিত হবে।';

  @override
  String get faqQuestion7 => 'আমি কখন আমার আয় পাব?';

  @override
  String get faqAnswer7 =>
      'আয় সাধারণত আর্নিংস ড্যাশবোর্ড থেকে উইথড্রয়াল রিকোয়েস্ট শুরু করার 24-48 ঘন্টার মধ্যে সেটেল করা হয়।';

  @override
  String get faqQuestion8 => 'আমি কাজের নোটিফিকেশন পাচ্ছি না।';

  @override
  String get faqAnswer8 =>
      'হোম স্ক্রিনে আপনার \"অনলাইন\" স্ট্যাটাস চালু আছে কি না তা নিশ্চিত করুন। এছাড়াও, অ্যাপের জন্য ব্যাটারি অপ্টিমাইজেশন নিষ্ক্রিয় করা আছে কি না এবং সব নোটিফিকেশন অনুমতি দেওয়া আছে কি না তা পরীক্ষা করুন।';

  @override
  String get faqQuestion9 => 'আমি কীভাবে আমার সেবা যোগ বা পরিবর্তন করব?';

  @override
  String get faqAnswer9 =>
      'আপনি আপনার অফার করা সেবাগুলি অ্যাকাউন্ট > আমার সেবা-এ গিয়ে আপডেট করতে পারেন। আপনার দক্ষতার ভিত্তিতে ক্যাটাগরিগুলো নির্বাচন বা অপছন্দ করুন।';

  @override
  String get faqQuestion10 => 'গ্রাহক শেষ মুহূর্তে বাতিল করলে কী হবে?';

  @override
  String get faqAnswer10 =>
      'যদি গ্রাহক আপনি অবস্থানে পৌঁছানোর পরে বাতিল করেন, তবে আপনি একটি বাতিলকরণ ফি-এর জন্য যোগ্য হতে পারেন। সহায়তার জন্য \"সহায়তা\" অপশনের মাধ্যমে সাপোর্টের সাথে যোগাযোগ করুন।';

  @override
  String get faqQuestion11 => 'আমি কীভাবে সুযোগের মানচিত্র ব্যবহার করব?';

  @override
  String get faqAnswer11 =>
      'সুযোগের মানচিত্র রিয়েল-টাইমে উচ্চ-চাহিদা সম্পন্ন জোন দেখায়। কাজের রিকোয়েস্ট পাওয়ার সম্ভাবনা বাড়াতে লাল বা কমলা চিহ্নিত এলাকায় যান।';

  @override
  String get faqQuestion12 => 'ছবির প্রয়োজনীয়তা কী কী?';

  @override
  String get faqAnswer12 =>
      'আপনার প্রোফাইল ছবি একটি স্পষ্ট, সামনের দিকে মুখ করা হেডশট হওয়া উচিত। সানগ্লাস বা টুপি পরবেন না এবং ব্যাকগ্রাউন্ডটি নিরপেক্ষ হওয়া নিশ্চিত করুন।';

  @override
  String get faqQuestion13 => 'আমি কীভাবে অ্যাপ থেকে লগআউট করব?';

  @override
  String get faqAnswer13 =>
      'আপনি অ্যাকাউন্ট স্ক্রিনের নিচে স্ক্রোল করে এবং \"লগআউট\" বাটনে ট্যাপ করে লগআউট করতে পারেন।';

  @override
  String get faqQuestion14 =>
      'চলমান কাজের জন্য আমি কীভাবে সাপোর্টের সাথে যোগাযোগ করব?';

  @override
  String get faqAnswer14 =>
      'সক্রিয় কাজের জন্য, আমাদের সাপোর্ট টিমের সাথে সরাসরি চ্যাট করতে বা আমাদের হেল্পলাইনে কল করতে কাজের স্ক্রিনের \"সহায়তা\" আইকনটি ব্যবহার করুন।';

  @override
  String get notUploaded => 'আপলোড করা হয়নি';

  @override
  String get underReview => 'পর্যালোচনার অধীনে';

  @override
  String get partialUpload => 'আংশিক আপলোড';

  @override
  String get cannotRemove => 'সরানো যাবে না';

  @override
  String get mustHaveOneService =>
      'কাজ পেতে আপনাকে অবশ্যই অন্তত একটি যাচাইকৃত সেবা থাকতে হবে।';

  @override
  String toSwitchServices(Object serviceName) {
    return 'সেবা পরিবর্তন করতে:\n1. প্রথমে একটি নতুন সেবা যাচাই করুন\n2. তারপর \"$serviceName\" সরান';
  }

  @override
  String get verifyNewService => 'নতুন সেবা যাচাই করুন';

  @override
  String removeServiceConfirm(Object serviceName) {
    return 'আপনি কি নিশ্চিত যে আপনি \"$serviceName\" সেবাটি সরাতে চান?\n\nএটি অভিজ্ঞতা এবং ভিডিওসহ আপনার যাচাইকরণের ডেটা মুছে ফেলবে। এই সেবাটি যোগ করতে আপনাকে আবার যাচাই করতে হবে।';
  }

  @override
  String get noVerifiedServices => 'কোনো যাচাইকৃত সেবা নেই';

  @override
  String get verifyAtLeastOneService =>
      'আপনি কাজ শুরু করার আগে আপনাকে অন্তত একটি সেবা যাচাই করতে হবে। এখন আপনার দক্ষতা যাচাই করুন!';

  @override
  String get verifyYourServices => 'আপনার সেবা যাচাই করুন';

  @override
  String get activeServices => 'সক্রিয় সেবা';

  @override
  String get activeApplianceServices => 'সক্রিয় অ্যাপ্লায়েন্স সেবা';

  @override
  String get verificationPendingNotify =>
      'যাচাইকরণ অমীমাংসিত - অনুমোদিত হলে আমরা আপনাকে জানাব';

  @override
  String get pendingVerification => 'যাচাইকরণ অমীমাংসিত';

  @override
  String get pendingApplianceServices => 'অমীমাংসিত অ্যাপ্লায়েন্স সেবা';

  @override
  String get videoUploaded => 'ভিডিও আপলোড করা হয়েছে';

  @override
  String get cannotDeletePending =>
      'যাচাইকরণ অমীমাংসিত থাকা অবস্থায় সেবা মুছে ফেলা যাবে না';

  @override
  String serviceRemovedSuccess(Object serviceName) {
    return '$serviceName সেবা সফলভাবে সরানো হয়েছে';
  }

  @override
  String errorRemovingService(Object error) {
    return 'সেবা সরাতে ত্রুটি: $error';
  }

  @override
  String verifiedCount(Object count) {
    return '$countটি যাচাইকৃত';
  }

  @override
  String pendingCount(Object count) {
    return '$countটি অমীমাংসিত';
  }

  @override
  String get cannotDeleteWhilePending =>
      'অমীমাংসিত থাকা অবস্থায় মুছে ফেলা যাবে না';

  @override
  String get addMoreServices => 'আরও সেবা যোগ করুন';

  @override
  String get verifyFirstService => 'আপনার প্রথম সেবা যাচাই করুন';

  @override
  String get chatWelcome => 'হ্যালো! আমরা আজ আপনাকে কীভাবে সাহায্য করতে পারি?';

  @override
  String get chatResponse =>
      'যোগাযোগ করার জন্য ধন্যবাদ! একজন প্রতিনিধি শীঘ্রই আপনার সাথে থাকবেন।';

  @override
  String get omibaySupport => 'ওমিবে সাপোর্ট';

  @override
  String get appVersion => 'অ্যাপ সংস্করণ';

  @override
  String get updateLanguage => 'ভাষা আপডেট করুন';

  @override
  String get notifications => 'নোটিফিকেশন';

  @override
  String get noNotifications => 'এখনও কোন নোটিফিকেশন নেই';

  @override
  String get markAllAsRead => 'সব পঠিত হিসেবে চিহ্নিত করুন';

  @override
  String get notificationJobTitle => 'নতুন কাজের রিকোয়েস্ট';

  @override
  String get notificationJobBody =>
      'বেলান্দুরে সম্পূর্ণ বাড়ি পরিষ্কারের জন্য আপনার একটি নতুন রিকোয়েস্ট আছে।';

  @override
  String get notificationPaymentTitle => 'পেমেন্ট পাওয়া গেছে';

  @override
  String get notificationPaymentBody =>
      'কাজ #OK123456 এর জন্য আপনার ₹1,499 আয় জমা হয়েছে।';

  @override
  String get notificationSystemTitle => 'যাচাইকরণ সফল';

  @override
  String get notificationSystemBody =>
      'আপনার ডকুমেন্ট যাচাইকরণ সম্পন্ন হয়েছে। আপনি এখন একজন যাচাইকৃত পার্টনার।';

  @override
  String get notificationPromoTitle => 'সাপ্তাহিক বোনাস!';

  @override
  String get notificationPromoBody =>
      'অতিরিক্ত ₹500 আয় করতে এই সপ্তাহে আরও 5টি কাজ সম্পূর্ণ করুন।';

  @override
  String get notificationCancelledTitle => 'কাজ বাতিল করা হয়েছে';

  @override
  String get notificationCancelledBody =>
      'গ্রাহক রাহুল শর্মা বাড়ি পরিষ্কারের রিকোয়েস্টটি বাতিল করেছেন।';

  @override
  String get time2MinsAgo => '2 মিনিট আগে';

  @override
  String get time1HourAgo => '1 ঘণ্টা আগে';

  @override
  String get timeYesterday => 'গতকাল';

  @override
  String get time2DaysAgo => '2 দিন আগে';

  @override
  String get time3DaysAgo => '3 দিন আগে';

  @override
  String get welcomeBack => 'স্বাগতম ফিরে, পার্টনার!';

  @override
  String get debugOtpSent => 'ডিবাগ: OTP পাঠানো হয়েছে (মক: 123456)';

  @override
  String get invalidOtp => 'অবৈধ OTP (মক 123456 ব্যবহার করে)';

  @override
  String get failedToSignIn => 'সাইন ইন ব্যর্থ:';

  @override
  String earningsForDay(String month, String day) {
    return '$month $day-এর আয়';
  }

  @override
  String get help => 'সহায়তা';

  @override
  String get support => 'সাপোর্ট';

  @override
  String get location => 'অবস্থান';

  @override
  String get service => 'সেবা';

  @override
  String get customer => 'গ্রাহক';

  @override
  String get price => 'মূল্য';

  @override
  String get tip => 'টিপ';

  @override
  String get distance => 'দূরত্ব';

  @override
  String get eta => 'আনুমানিক সময়';

  @override
  String get accept => 'গ্রহণ করুন';

  @override
  String get decline => 'প্রত্যাখ্যান করুন';

  @override
  String get newJobRequest => 'নতুন কাজের অনুরোধ';

  @override
  String get timeRemaining => 'অবশিষ্ট সময়';

  @override
  String get incomingJob => 'আগত কাজ';

  @override
  String get jobDetails => 'কাজের বিবরণ';

  @override
  String get startJob => 'কাজ শুরু করুন';

  @override
  String get completeJob => 'কাজ সম্পূর্ণ করুন';

  @override
  String get navigateToCustomer => 'গ্রাহকের কাছে নেভিগেট করুন';

  @override
  String get callCustomer => 'গ্রাহককে কল করুন';

  @override
  String get chatWithCustomer => 'গ্রাহকের সাথে চ্যাট করুন';

  @override
  String get referralCode => 'রেফারেল কোড';

  @override
  String get shareReferralCode => 'রেফারেল কোড শেয়ার করুন';

  @override
  String get copied => 'কপি হয়েছে!';

  @override
  String get totalReferralEarnings => 'মোট রেফারেল আয়';

  @override
  String get withdrawalHistory => 'উইথড্রয়ের ইতিহাস';

  @override
  String get date => 'তারিখ';

  @override
  String get status => 'স্ট্যাটাস';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get success => 'সফল';

  @override
  String get pending => 'অপেক্ষমাণ';

  @override
  String get failed => 'ব্যর্থ';

  @override
  String get documents => 'ডকুমেন্ট';

  @override
  String get verified => 'যাচাইকৃত';

  @override
  String get notVerified => 'যাচাই করা হয়নি';

  @override
  String get permissions => 'অনুমতি';

  @override
  String get locationPermission => 'অবস্থানের অনুমতি';

  @override
  String get cameraPermission => 'ক্যামেরার অনুমতি';

  @override
  String get storagePermission => 'স্টোরেজের অনুমতি';

  @override
  String get notificationPermission => 'নোটিফিকেশনের অনুমতি';

  @override
  String get grantPermission => 'অনুমতি দিন';

  @override
  String get permissionGranted => 'অনুমতি দেওয়া হয়েছে';

  @override
  String get permissionDenied => 'অনুমতি অস্বীকার করা হয়েছে';

  @override
  String get contactUs => 'যোগাযোগ করুন';

  @override
  String get faq => 'সাধারণ প্রশ্ন';

  @override
  String get liveChat => 'লাইভ চ্যাট';

  @override
  String get sendMessage => 'মেসেজ পাঠান';

  @override
  String get typeYourMessage => 'আপনার মেসেজ লিখুন...';

  @override
  String get opportunityMap => 'সুযোগের মানচিত্র';

  @override
  String get nearbyOpportunities => 'কাছাকাছি সুযোগ';

  @override
  String get editServices => 'সেবা সম্পাদনা';

  @override
  String get addNewService => 'নতুন সেবা যোগ করুন';

  @override
  String get paymentSetup => 'পেমেন্ট সেটআপ';

  @override
  String get bankAccount => 'ব্যাংক অ্যাকাউন্ট';

  @override
  String get upiId => 'UPI আইডি';

  @override
  String get addBankAccount => 'ব্যাংক অ্যাকাউন্ট যোগ করুন';

  @override
  String get accountHolderName => 'অ্যাকাউন্ট হোল্ডারের নাম';

  @override
  String get accountNumber => 'অ্যাকাউন্ট নম্বর';

  @override
  String get ifscCode => 'IFSC কোড';

  @override
  String get bankName => 'ব্যাংকের নাম';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get confirmDelete => 'মোছার নিশ্চিতকরণ';

  @override
  String get areYouSureDelete => 'আপনি কি এটি মুছতে চান?';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get error => 'ত্রুটি';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get next => 'পরবর্তী';

  @override
  String get back => 'পেছনে';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get continue_ => 'চালিয়ে যান';

  @override
  String get submit => 'জমা দিন';

  @override
  String get update => 'আপডেট';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get remove => 'সরান';

  @override
  String get clear => 'পরিষ্কার করুন';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get filter => 'ফিল্টার';

  @override
  String get sort => 'সাজান';

  @override
  String get refresh => 'রিফ্রেশ';

  @override
  String get more => 'আরও';

  @override
  String get less => 'কম';

  @override
  String get showMore => 'আরও দেখুন';

  @override
  String get showLess => 'কম দেখুন';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get noResults => 'কোন ফলাফল পাওয়া যায়নি';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get somethingWentWrong => 'কিছু ভুল হয়েছে';

  @override
  String get pleaseWait => 'অনুগ্রহ করে অপেক্ষা করুন...';

  @override
  String get today => 'আজ';

  @override
  String get yesterday => 'গতকাল';

  @override
  String get thisWeek => 'এই সপ্তাহ';

  @override
  String get thisMonth => 'এই মাস';

  @override
  String get lastMonth => 'গত মাস';

  @override
  String minsAway(String mins) {
    return '$mins মিনিট দূরে';
  }

  @override
  String kmAway(String km) {
    return '$km কিমি';
  }

  @override
  String get allProTips => 'সব প্রো টিপস';

  @override
  String get proTip1 => 'ভালো রেটিং-এর জন্য সর্বদা আপনার ইউনিফর্ম পরুন।';

  @override
  String get proTip2 => 'অবস্থানে 5 মিনিট আগে পৌঁছান।';

  @override
  String get proTip3 => 'কাজের আগে এবং পরে স্পষ্ট ছবি তুলুন।';

  @override
  String get proTip4 => 'পেশাদার হাসি দিয়ে গ্রাহককে অভ্যর্থনা জানান।';

  @override
  String get proTip5 => 'কাজে যাওয়ার আগে আপনার সরঞ্জাম দুবার পরীক্ষা করুন।';

  @override
  String get proTip6 => 'সেবার সময় উচ্চ যোগাযোগ বজায় রাখুন।';

  @override
  String get proTip7 => 'সেবার সময় এবং পরে আপনার কাজের জায়গা পরিষ্কার রাখুন।';

  @override
  String get proTip8 => 'কাজ শেষ করার পর প্রতিক্রিয়া চান।';

  @override
  String get proTip9 => 'শেষ করার সাথে সাথে আপনার স্ট্যাটাস আপডেট করুন।';

  @override
  String get proTip10 => 'হাইড্রেটেড থাকুন এবং কাজের মাঝে ছোট বিরতি নিন।';

  @override
  String get complete15Jobs => '15টি কাজ সম্পন্ন করুন';

  @override
  String get earnExtraReward => 'অতিরিক্ত ₹500 আয় করুন';

  @override
  String get shareAndEarn => 'শেয়ার করুন ও আয় করুন';

  @override
  String get goOnlineToStart => 'আপনার এলাকায় কাজের অনুরোধ পেতে অনলাইন যান।';

  @override
  String setDefaultPayoutMethod(String type) {
    return 'ডিফল্ট $type পেমেন্ট পদ্ধতি হিসেবে সেট করা হয়েছে';
  }

  @override
  String get deletePaymentMethodTitle => 'পেমেন্ট পদ্ধতি মুছে ফেলবেন?';

  @override
  String deletePaymentMethodConfirm(String type) {
    return 'আপনি কি নিশ্চিত যে আপনি এই $type মুছে ফেলতে চান?';
  }

  @override
  String get savedOptions => 'সংরক্ষিত বিকল্পসমূহ';

  @override
  String get noPaymentMethodSaved => 'কোনো পেমেন্ট পদ্ধতি সংরক্ষিত নেই';

  @override
  String get bankAccountsLabel => 'ব্যাংক অ্যাকাউন্ট';

  @override
  String accountNumberLabel(String number) {
    return 'A/C: $number';
  }

  @override
  String get upiIdsLabel => 'UPI আইডি';

  @override
  String get addNewOption => 'নতুন বিকল্প যোগ করুন';

  @override
  String get directTransferToBank => 'সরাসরি আপনার ব্যাংকে ট্রান্সফার';

  @override
  String get upiAppsSubtitle => 'Google Pay, PhonePe, Paytm ইত্যাদি';

  @override
  String get secureSslEncryption => 'নিরাপদ 256-বিট SSL এনক্রিপশন';

  @override
  String get paymentSecurityNote =>
      'আপনার পেমেন্টের বিবরণ এনক্রিপ্ট করা এবং নিরাপদে সংরক্ষিত।';

  @override
  String get bankAccountDetails => 'ব্যাংক অ্যাকাউন্টের বিবরণ';

  @override
  String get holderNameHint => 'ব্যাংক রেকর্ড অনুযায়ী পূর্ণ নাম';

  @override
  String get bankNameHint => 'যেমন: HDFC ব্যাংক, SBI';

  @override
  String get enterAccountNumber => 'আপনার অ্যাকাউন্ট নম্বর লিখুন';

  @override
  String get reEnterAccountNumber => 'অ্যাকাউন্ট নম্বর পুনরায় লিখুন';

  @override
  String get confirmAccountNumber => 'আপনার অ্যাকাউন্ট নম্বর নিশ্চিত করুন';

  @override
  String get accountNumbersDoNotMatch => 'অ্যাকাউন্ট নম্বর মেলেনি';

  @override
  String get ifscHint => 'যেমন: HDFC0001234';

  @override
  String get correctDetailsWarning =>
      'পেমেন্টে বিলম্ব এড়াতে অ্যাকাউন্টের বিবরণ সঠিক কিনা নিশ্চিত করুন।';

  @override
  String get pleaseFillAllFields =>
      'অনুগ্রহ করে সব প্রয়োজনীয় ক্ষেত্র পূরণ করুন';

  @override
  String get saveBankDetails => 'ব্যাংক বিবরণ সংরক্ষণ করুন';

  @override
  String get upiIdHint => 'যেমন: name@okaxis';

  @override
  String get reEnterUpiId => 'UPI আইডি পুনরায় লিখুন';

  @override
  String get confirmUpiId => 'আপনার UPI আইডি নিশ্চিত করুন';

  @override
  String get upiIdsDoNotMatch => 'UPI আইডি মেলেনি';

  @override
  String get upiInstantCreditNote =>
      'আপনার পেমেন্ট তাৎক্ষণিকভাবে এই UPI আইডিতে জমা হবে।';

  @override
  String get pleaseEnterUpiId => 'অনুগ্রহ করে UPI আইডি লিখুন';

  @override
  String get saveUpi => 'UPI সংরক্ষণ করুন';

  @override
  String get selectNumberToCall => 'কল করার জন্য একটি নম্বর নির্বাচন করুন';

  @override
  String get supportLine1 => 'সাপোর্ট লাইন 1';

  @override
  String get supportLine2 => 'সাপোর্ট লাইন 2';

  @override
  String get supportLine3 => 'সাপোর্ট লাইন 3';

  @override
  String get frequentlyAskedQuestions => 'সাধারণ জিজ্ঞাসা (FAQ)';

  @override
  String get viewAllFaqs => 'সব FAQ দেখুন';

  @override
  String get callUs => 'আমাদের কল করুন';

  @override
  String get support247 => '24/7 সাপোর্ট';

  @override
  String get whatsAppChat => 'হোয়াটসঅ্যাপ চ্যাট';

  @override
  String get connectQuickSupport =>
      'দ্রুত সাপোর্ট এবং জিজ্ঞাসার জন্য আমাদের সাথে যোগাযোগ করুন';

  @override
  String get whatsappResponseTime =>
      '24/7 উপলব্ধ • সাধারণত 5 মিনিটের মধ্যে উত্তর দেওয়া হয়';

  @override
  String get contactInformation => 'যোগাযোগের তথ্য';

  @override
  String get emailUs => 'আমাদের ইমেইল করুন';

  @override
  String get workingHours => 'কাজের সময়';

  @override
  String get workingHoursTime => 'সোম - রবি: সকাল 09:00 - রাত 09:00';

  @override
  String supportNumbers(String number) {
    return '$number এবং আরও';
  }

  @override
  String get supportFaqQuestion1 => 'আমি কীভাবে আমার আয় উইথড্র করব?';

  @override
  String get supportFaqAnswer1 =>
      'আপনি আর্নিংস ড্যাশবোর্ড থেকে আপনার আয় উইথড্র করতে পারেন। উইথড্র-এ ক্লিক করুন এবং আপনার পছন্দসই পদ্ধতি বেছে নিন।';

  @override
  String get supportFaqQuestion2 => 'গ্রাহক কাজ বাতিল করলে কী হবে?';

  @override
  String get supportFaqAnswer2 =>
      'যদি কোনো গ্রাহক শুরুর সময়ের 30 মিনিটের মধ্যে কাজ বাতিল করেন, তবে আপনি বাতিলকরণ ফি-এর জন্য যোগ্য হতে পারেন।';

  @override
  String get supportFaqQuestion3 => 'আমি কীভাবে আমার সেবার অবস্থান আপডেট করব?';

  @override
  String get supportFaqAnswer3 =>
      'আপনি যেখানে কাজের রিকোয়েস্ট পেতে চান সেই এলাকাগুলো আপডেট করতে অ্যাকাউন্ট > সার্ভিস সেটিংস-এ যান।';

  @override
  String get supportFaqQuestion4 =>
      'আমি কীভাবে আমার প্রোফাইল ছবি পরিবর্তন করব?';

  @override
  String get supportFaqAnswer4 =>
      'আপনি অ্যাকাউন্ট > প্রোফাইল সম্পাদনা-এ গিয়ে এবং ক্যামেরা আইকনে ট্যাপ করে আপনার প্রোফাইল ছবি আপডেট করতে পারেন।';

  @override
  String get supportFaqQuestion5 => 'বাতিলকরণ নীতি কী?';

  @override
  String get supportFaqAnswer5 =>
      'পার্টনার দ্বারা বাতিল করা কাজের জন্য জরিমানা হতে পারে। বিস্তারিত তথ্যের জন্য আমাদের সেবার শর্তাবলী দেখুন।';

  @override
  String get webPermissionsNote =>
      'ওয়েবে অনুমতিগুলি আপনার ব্রাউজার দ্বারা পরিচালিত হয়।';

  @override
  String get permissionRequired => 'অনুমতি প্রয়োজন';

  @override
  String get permissionRequiredNote =>
      'অ্যাপটি সঠিকভাবে কাজ করার জন্য এই অনুমতি প্রয়োজন। দয়া করে সিস্টেম সেটিংসে এটি সক্রিয় করুন।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String get managePermissions => 'অনুমতি পরিচালনা করুন';

  @override
  String get permissionsNote =>
      'সেরা অভিজ্ঞতা প্রদানের জন্য ওমিবে-এর নিচের অনুমতিগুলোর প্রয়োজন।';

  @override
  String get backgroundLocation => 'ব্যাকগ্রাউন্ড অবস্থান';

  @override
  String get backgroundLocationDesc =>
      'ওমিবে-কে আপনার অবস্থান ট্র্যাক করতে অনুমতি দেয় এমনকি যখন অ্যাপটি ব্যাকগ্রাউন্ডে থাকে, যা আপনার কাছাকাছি রিয়েল-টাইমে কাজের রিকোয়েস্ট পাওয়া নিশ্চিত করে।';

  @override
  String get batteryOptimization => 'ব্যাটারি অপ্টিমাইজেশন';

  @override
  String get batteryOptimizationDesc =>
      'ওমিবে-এর জন্য ব্যাটারি অপ্টিমাইজেশন নিষ্ক্রিয় করা নিশ্চিত করে যে আপনি সিস্টেম পাওয়ার-সেভিং বিধিনিষেধের কারণে কাজের নোটিফিকেশন মিস করবেন না।';

  @override
  String get displayOverApps => 'অন্যান্য অ্যাপের উপরে প্রদর্শন';

  @override
  String get displayOverAppsDesc =>
      'অন্যান্য অ্যাপ্লিকেশন ব্যবহার করার সময়ও ওমিবে-কে ইনকামিং কাজের রিকোয়েস্ট একটি পপ-আপ হিসেবে দেখানোর অনুমতি দেয়।';

  @override
  String lastUpdated(String date) {
    return 'সর্বশেষ আপডেট: $date';
  }

  @override
  String get privacyPolicyTitle => 'গোপনীয়তা নীতি';

  @override
  String get privacySection1Title => '1. আমরা যে তথ্য সংগ্রহ করি';

  @override
  String get privacySection1Content =>
      'আমাদের সেবাগুলো কার্যকরভাবে প্রদান করতে আমরা আপনার নাম, ফোন নম্বর, ইমেল ঠিকানা, সরকারি পরিচয়পত্র এবং অবস্থানের ডেটার মতো ব্যক্তিগত তথ্য সংগ্রহ করি।';

  @override
  String get privacySection2Title => '2. আমরা কীভাবে আপনার তথ্য ব্যবহার করি';

  @override
  String get privacySection2Content =>
      'আপনার পরিচয় যাচাই করতে, পেমেন্ট প্রক্রিয়া করতে, গ্রাহকদের সাথে আপনাকে সংযোগ করতে এবং আমাদের অ্যাপ্লিকেশন অভিজ্ঞতা উন্নত করতে আপনার তথ্য ব্যবহার করা হয়। আপনার কাছাকাছি কাজের রিকোয়েস্ট পাঠাতে আমরা অবস্থানের ডেটাও ব্যবহার করি।';

  @override
  String get privacySection3Title => '3. তথ্য শেয়ারিং';

  @override
  String get privacySection3Content =>
      'আপনি যখন কোনো কাজের রিকোয়েস্ট গ্রহণ করেন, তখন আমরা গ্রাহকদের সাথে প্রয়োজনীয় তথ্য (যেমন আপনার নাম এবং অবস্থান) শেয়ার করি। আমরা তৃতীয় পক্ষের মার্কেটিং কোম্পানিগুলোর কাছে আপনার ব্যক্তিগত তথ্য বিক্রি করি না।';

  @override
  String get privacySection4Title => '4. তথ্য নিরাপত্তা';

  @override
  String get privacySection4Content =>
      'আপনার ডেটাকে অননুমোদিত অ্যাক্সেস, পরিবর্তন বা প্রকাশ থেকে রক্ষা করতে আমরা ইন্ডাস্ট্রি-স্ট্যান্ডার্ড নিরাপত্তা ব্যবস্থা বাস্তবায়ন করি। তবে ইন্টারনেটের মাধ্যমে ট্রান্সমিশনের কোনো পদ্ধতি 100% নিরাপদ নয়।';

  @override
  String get privacySection5Title => '5. কুকিজ';

  @override
  String get privacySection5Content =>
      'ব্যবহারকারীর অভিজ্ঞতা উন্নত করতে এবং অ্যাপের পারফরম্যান্স বিশ্লেষণ করতে আমাদের অ্যাপ্লিকেশন কুকিজ এবং অনুরূপ প্রযুক্তি ব্যবহার করতে পারে।';

  @override
  String get privacySection6Title => '6. নীতি পরিবর্তন';

  @override
  String get privacySection6Content =>
      'আমরা সময়ে সময়ে আমাদের গোপনীয়তা নীতি আপডেট করতে পারি। আমরা এই পৃষ্ঠায় নতুন নীতি পোস্ট করে আপনাকে যেকোনো পরিবর্তনের কথা জানাব।';

  @override
  String get privacyContact =>
      'গোপনীয়তা সংক্রান্ত উদ্বেগের জন্য যোগাযোগ করুন: privacy@apnakaam.com';

  @override
  String get termsOfServiceTitle => 'সেবার শর্তাবলী';

  @override
  String get termsSection1Title => '1. শর্তাবলী গ্রহণ';

  @override
  String get termsSection1Content =>
      'ওমিবে পার্টনার অ্যাপ অ্যাক্সেস এবং ব্যবহার করার মাধ্যমে, আপনি এই সেবার শর্তাবলী দ্বারা আবদ্ধ হতে সম্মত হন। আপনি যদি এই শর্তাবলীর কোনো অংশের সাথে সম্মত না হন, তবে আপনাকে অবশ্যই অ্যাপ্লিকেশনটি ব্যবহার করা বন্ধ করতে হবে।';

  @override
  String get termsSection2Title => '2. পার্টনার যোগ্যতা';

  @override
  String get termsSection2Content =>
      'ওমিবে-তে পার্টনার হওয়ার জন্য আপনার বয়স অন্তত 18 বছর হতে হবে এবং একটি আইনি চুক্তিতে আবদ্ধ হওয়ার ক্ষমতা থাকতে হবে। আপনাকে যাচাইকরণের জন্য সঠিক এবং সম্পূর্ণ ডকুমেন্ট প্রদান করতে হবে।';

  @override
  String get termsSection3Title => '3. সেবার মান';

  @override
  String get termsSection3Content =>
      'পার্টনারদের উচ্চ-মানের সেবার মান বজায় রাখার আশা করা হয়। এর মধ্যে সময়ানুবর্তিতা, পেশাদার আচরণ এবং কাজ চলাকালীন নিরাপত্তা নির্দেশিকা মেনে চলা অন্তর্ভুক্ত।';

  @override
  String get termsSection4Title => '4. পেমেন্ট ও ফি';

  @override
  String get termsSection4Content =>
      'কাজ সম্পন্ন এবং যাচাইকরণের পরে পেমেন্ট প্রক্রিয়া করা হয়। ওমিবে সম্মত কমিশন কাঠামো অনুযায়ী মোট কাজের মূল্য থেকে একটি সার্ভিস কমিশন কেটে নেওয়ার অধিকার সংরক্ষণ করে।';

  @override
  String get termsSection5Title => '5. অ্যাকাউন্ট নিরাপত্তা';

  @override
  String get termsSection5Content =>
      'আপনার অ্যাকাউন্টের তথ্যের গোপনীয়তা বজায় রাখার জন্য আপনি দায়ী। আপনার অ্যাকাউন্টের অধীনে সংঘটিত যেকোনো কার্যকলাপের জন্য আপনিই একমাত্র দায়ী।';

  @override
  String get termsSection6Title => '6. সমাপ্তি';

  @override
  String get termsSection6Content =>
      'এই শর্তাবলী লঙ্ঘন, নিম্নমানের সার্ভিস রেটিং বা প্রতারণামূলক কার্যকলাপের জন্য ওমিবে আপনার অ্যাকাউন্ট স্থগিত বা বন্ধ করার অধিকার সংরক্ষণ করে।';

  @override
  String get termsCopyright => '© 2026 ওমিবে টেকনোলজিস প্রাঃ লিঃ';

  @override
  String get suspensionPolicyTitle => 'পার্টনার স্থগিতাদেশ নীতি';

  @override
  String get suspensionPurposeTitle => 'উদ্দেশ্য';

  @override
  String get suspensionPurposeContent =>
      'সেবার মান, ব্যবহারকারীর নিরাপত্তা এবং প্ল্যাটফর্মের বিশ্বাসযোগ্যতা নিশ্চিত করতে কেন এবং কখন একজন পার্টনারের অ্যাকাউন্ট সাময়িক বা স্থায়ীভাবে স্থগিত করা যেতে পারে তা এই নীতি ব্যাখ্যা করে।';

  @override
  String get suspensionTypesTitle => 'স্থগিতাদেশের ধরন';

  @override
  String get suspensionTypesContent =>
      '1. সাময়িক স্থগিতাদেশ: সমস্যার গুরুত্বের ওপর ভিত্তি করে একজন পার্টনারকে একটি নির্দিষ্ট সময়ের জন্য (3 দিন, 7 দিন, 15 দিন বা 30 দিন) স্থগিত করা যেতে পারে।\n\n2. স্থায়ী স্থগিতাদেশ: একজন পার্টনারকে স্থায়ীভাবে প্ল্যাটফর্ম থেকে সরিয়ে দেওয়া হতে পারে এবং পুনরায় যোগদানের কোনো সুযোগ থাকবে না।';

  @override
  String get suspensionTempReasonsTitle => 'সাময়িক স্থগিতাদেশের কারণসমূহ';

  @override
  String get suspensionTempReasonsContent =>
      'একজন পার্টনার সাময়িক স্থগিতাদেশের সম্মুখীন হতে পারেন যদি তারা:\n• বারবার কোনো বৈধ কারণ ছাড়াই গ্রহণ করা বুকিং বাতিল করেন।\n• বারবার দেরিতে পৌঁছান বা বরাদ্দকৃত কাজ সম্পন্ন করতে ব্যর্থ হন।\n• আচরণ, পরিচ্ছন্নতা বা পেশাদারিত্ব সম্পর্কে গ্রাহকদের কাছ থেকে একাধিক অভিযোগ পান।\n• গ্রাহকদের কাছ থেকে অতিরিক্ত চার্জ আদায় করেন বা অ্যাপের বাইরে পেমেন্ট চান।\n• গ্রাহকদের সাথে গালিগালাজ, রূঢ় বা অনুপযুক্ত ভাষা ব্যবহার করেন।\n• ভুল সেবার তথ্য শেয়ার করেন বা দক্ষতার ভুল উপস্থাপন করেন।\n• প্ল্যাটফর্ম স্ট্যান্ডার্ডের নিচে ধারাবাহিকভাবে কম রেটিং বজায় রাখেন।\n• প্রথমবারের মতো প্ল্যাটফর্মের নির্দেশিকা লঙ্ঘন করেন।';

  @override
  String get suspensionTempActionTitle => 'পদক্ষেপ (সাময়িক)';

  @override
  String get suspensionTempActionContent =>
      'পার্টনার অ্যাকাউন্টটি একটি নির্দিষ্ট সময়ের জন্য স্থগিত করা হবে। পুনরায় সক্রিয় করার আগে প্রশিক্ষণ বা পুনরায় যাচাইকরণের প্রয়োজন হতে পারে।';

  @override
  String get suspensionPermReasonsTitle => 'স্থায়ী স্থগিতাদেশের কারণসমূহ';

  @override
  String get suspensionPermReasonsContent =>
      'একজন পার্টনার স্থায়ীভাবে স্থগিত হবেন যদি তারা:\n• জাল বুকিং বা রিভিউ-এর মতো প্রতারণা করেন।\n• গ্রাহক বা কর্মীদের হয়রানি, হুমকি বা শারীরিক ক্ষতি করেন।\n• প্ল্যাটফর্ম ব্যবহারের সময় কোনো অবৈধ কার্যকলাপে লিপ্ত হন।\n• সম্মতি ছাড়াই গ্রাহকের ব্যক্তিগত তথ্য শেয়ার করেন।\n• জাল ডকুমেন্ট বা মিথ্যা যাচাইকরণ তথ্য ব্যবহার করেন।\n• প্ল্যাটফর্ম পেমেন্ট এড়িয়ে যান বা গ্রাহককে প্ল্যাটফর্মের বাইরে নিয়ে যান।\n• একাধিক সতর্কতার পরেও বারবার নীতি লঙ্ঘন করেন।\n• গ্রাহকের সম্পত্তির ইচ্ছাকৃত ক্ষতি করেন।';

  @override
  String get suspensionPermActionTitle => 'পদক্ষেপ (স্থায়ী)';

  @override
  String get suspensionPermActionContent =>
      'অবিলম্বে অ্যাকাউন্ট বন্ধ করা হবে। নীতি অনুযায়ী বকেয়া পেমেন্ট আটকে রাখা হতে পারে। পুনরায় রেজিস্ট্রেশন করার অনুমতি নেই।';

  @override
  String get suspensionNotifyTitle => 'স্থগিতাদেশের বিজ্ঞপ্তি';

  @override
  String get suspensionNotifyContent =>
      'পার্টনারদের অ্যাপ নোটিফিকেশন, ইমেল বা SMS-এর মাধ্যমে কারণ ও সময়কালসহ জানানো হবে।';

  @override
  String get suspensionAppealTitle => 'আপিল প্রক্রিয়া';

  @override
  String get suspensionAppealContent =>
      'পার্টনাররা বৈধ প্রমাণসহ 7 দিনের মধ্যে আপিল করতে পারেন। চূড়ান্ত সিদ্ধান্ত প্ল্যাটফর্মের হাতে থাকবে।';

  @override
  String get suspensionReactivateTitle => 'পুনরায় সক্রিয়করণ নীতি';

  @override
  String get suspensionReactivateContent =>
      'সাময়িক স্থগিতাদেশের ক্ষেত্রে পুনরায় সক্রিয় করার আগে পর্যালোচনা, প্রশিক্ষণ বা প্রবেশন পিরিয়ডের প্রয়োজন হয়।';

  @override
  String get suspensionFinalNoteTitle => 'চূড়ান্ত নোট';

  @override
  String get suspensionFinalNoteContent =>
      'গ্রাহকদের এবং প্ল্যাটফর্মের অখণ্ডতা রক্ষা করতে প্ল্যাটফর্ম যেকোনো অ্যাকাউন্ট স্থগিত বা বন্ধ করার অধিকার সংরক্ষণ করে।';

  @override
  String get suspensionContact =>
      'যেকোনো জিজ্ঞাসার জন্য যোগাযোগ করুন: support@omibay.com';

  @override
  String get pauseWorkTitle => 'কাজে বিরতি দিন';

  @override
  String get pauseWorkReasonPrompt =>
      'দয়া করে বিরতি দেওয়ার একটি কারণ নির্বাচন করুন:';

  @override
  String get reasonNeedMaterials => 'আরও উপকরণের প্রয়োজন';

  @override
  String get reasonHealthEmergency => 'জরুরি স্বাস্থ্য সমস্যা';

  @override
  String get reasonCustomerRequested => 'গ্রাহক বিরতি অনুরোধ করেছেন';

  @override
  String get reasonLunchBreak => 'দুপুরের খাবার/বিরতি';

  @override
  String get workPaused => 'কাজ বিরতি দেওয়া হয়েছে';

  @override
  String get confirmPause => 'বিরতি নিশ্চিত করুন';

  @override
  String get verifyOtpTitle => 'OTP যাচাই করুন';

  @override
  String get enterOtpInstruction =>
      'কাজ শুরু করতে গ্রাহকের বুকিং বিবরণ স্ক্রিনে দেখানো 4-সংখ্যার OTP লিখুন।';

  @override
  String get workStartedSuccess => 'কাজ সফলভাবে শুরু হয়েছে!';

  @override
  String get invalidOtpTryAgain => 'অবৈধ OTP। দয়া করে আবার চেষ্টা করুন।';

  @override
  String get verifyAndStart => 'যাচাই করুন এবং শুরু করুন';

  @override
  String get jobDetailsTitle => 'কাজের বিবরণ';

  @override
  String get onTheWay => 'পথে আছি';

  @override
  String get started => 'শুরু হয়েছে';

  @override
  String get complete => 'সম্পন্ন';

  @override
  String get customerReview => 'গ্রাহক পর্যালোচনা';

  @override
  String get excellentServiceMock =>
      'চমৎকার সেবা! পার্টনার সময়মতো পৌঁছেছেন এবং খুব ভালো কাজ করেছেন। হোম ক্লিনিং সার্ভিসের জন্য অত্যন্ত সুপারিশকৃত।';

  @override
  String get serviceSchedule => 'পরিষেবার সময়সূচী';

  @override
  String get reachLocationEarly =>
      'গুরুত্বপূর্ণ: দয়া করে নির্ধারিত সময়ের 10 মিনিট আগে অবস্থানে পৌঁছান।';

  @override
  String get customerDetailsAndSpecification =>
      'গ্রাহকের বিবরণ এবং পরিষেবার স্পেসিফিকেশন';

  @override
  String get serviceLocation => 'পরিষেবার অবস্থান';

  @override
  String get navigate => 'নেভিগেট করুন';

  @override
  String get mockCustomerName => 'রাহুল শর্মা';

  @override
  String get mockLocation => 'বেল্লান্দুর, বেঙ্গালুরু';

  @override
  String get mockFullAddress =>
      'ফ্ল্যাট 402, গ্রিন গ্লেন লেআউট, বেল্লান্দুর, বেঙ্গালুরু';

  @override
  String get mockScheduledTime => 'নির্ধারিত 12 জানুয়ারি, সকাল 10:00';

  @override
  String get appVersionValue => '1.0.0';

  @override
  String get justNow => 'এইমাত্র';

  @override
  String get jobPayment => 'কাজের পেমেন্ট';

  @override
  String get manualTransaction => 'ম্যানুয়াল লেনদেন';

  @override
  String get paymentTransaction => 'পেমেন্ট লেনদেন';

  @override
  String get amountLabel => 'পরিমাণ';

  @override
  String get currencySymbol => '₹';

  @override
  String dayLabel(String number) {
    return 'দিন $number';
  }

  @override
  String earningsForDayTooltip(String day, String amount) {
    return 'দিন $day: $amount';
  }

  @override
  String get transactionDefault => 'লেনদেন';

  @override
  String get monthJan => 'জানুয়ারি';

  @override
  String get monthFeb => 'ফেব্রুয়ারি';

  @override
  String get monthMar => 'মার্চ';

  @override
  String get monthApr => 'এপ্রিল';

  @override
  String get monthMay => 'মে';

  @override
  String get monthJun => 'জুন';

  @override
  String get monthJul => 'জুলাই';

  @override
  String get monthAug => 'আগস্ট';

  @override
  String get monthSep => 'সেপ্টেম্বর';

  @override
  String get monthOct => 'অক্টোবর';

  @override
  String get monthNov => 'নভেম্বর';

  @override
  String get monthDec => 'ডিসেম্বর';

  @override
  String jobWithService(Object service) {
    return 'কাজ: $service';
  }

  @override
  String get tipAmount => 'টিপসের পরিমাণ';

  @override
  String referralShareMessage(Object code) {
    return 'ওমিবে পার্টনার অ্যাপে যোগ দিন এবং পুরস্কার জিততে আমার কোড $code ব্যবহার করুন! এখনই ডাউনলোড করুন: https://omibay.com/join';
  }

  @override
  String accountNumberMask(Object last4) {
    return 'XXXX XXXX $last4';
  }

  @override
  String get mockPartnerId => '#AP12345';

  @override
  String get mockPhoneNumber => '+91 99999 99999';

  @override
  String get placeholderPhotoUrl => 'https://via.placeholder.com/150';

  @override
  String get quickAmount1 => '500';

  @override
  String get quickAmount2 => '1000';

  @override
  String get quickAmount3 => '2000';

  @override
  String get supportEmail => 'support@omibay.com';

  @override
  String get whatsappSupportNumber => '918016867006';

  @override
  String get supportNumber1 => '+91 8016867006';

  @override
  String get supportNumber2 => '+91 8967429449';

  @override
  String get supportNumber3 => '+91 73188 475 45';

  @override
  String get transactionIdPrefix => '#TXN';
}
