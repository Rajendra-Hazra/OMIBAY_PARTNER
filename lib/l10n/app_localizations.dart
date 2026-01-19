import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'OmiBay Partner'**
  String get appTitle;

  /// No description provided for @indiaCountryCode.
  ///
  /// In en, this message translates to:
  /// **'+91'**
  String get indiaCountryCode;

  /// No description provided for @welcomeBackPartnerMock.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Partner (Mock)!'**
  String get welcomeBackPartnerMock;

  /// No description provided for @onScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'On Scheduled Time'**
  String get onScheduledTime;

  /// No description provided for @earning.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get earning;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @updatePhone.
  ///
  /// In en, this message translates to:
  /// **'Update Phone'**
  String get updatePhone;

  /// No description provided for @updateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update Email'**
  String get updateEmail;

  /// No description provided for @newPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'New Phone Number'**
  String get newPhoneNumber;

  /// No description provided for @newEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'New Email Address'**
  String get newEmailAddress;

  /// No description provided for @pleaseEnterValid10DigitNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid 10-digit number'**
  String get pleaseEnterValid10DigitNumber;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully (Demo: 123456)'**
  String get otpSentSuccessfully;

  /// No description provided for @phoneUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Phone updated successfully!'**
  String get phoneUpdatedSuccessfully;

  /// No description provided for @emailUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully!'**
  String get emailUpdatedSuccessfully;

  /// No description provided for @invalidOtpDemo.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Use 123456 for demo.'**
  String get invalidOtpDemo;

  /// No description provided for @confirmChange.
  ///
  /// In en, this message translates to:
  /// **'Confirm Change'**
  String get confirmChange;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @requiredFields.
  ///
  /// In en, this message translates to:
  /// **'Required Fields'**
  String get requiredFields;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the following required fields:'**
  String get pleaseFillRequiredFields;

  /// No description provided for @profileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccessfully;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String errorSavingProfile(Object error);

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your new {type}.'**
  String enterOtpSentTo(Object type);

  /// No description provided for @enterNewToReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your new {type} below to receive a verification code.'**
  String enterNewToReceiveCode(Object type);

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterYourAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterYourAge;

  /// No description provided for @exampleEmail.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get exampleEmail;

  /// No description provided for @enterYourFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your full address'**
  String get enterYourFullAddress;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @pleaseVerifyMobileToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please verify your mobile number to continue'**
  String get pleaseVerifyMobileToContinue;

  /// No description provided for @pleaseEnterValid10DigitMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get pleaseEnterValid10DigitMobile;

  /// No description provided for @otpSentToWithDemo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to +91 {phone} (Demo: 123456)'**
  String otpSentToWithDemo(Object phone);

  /// No description provided for @verifyMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Mobile Number'**
  String get verifyMobileNumber;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to +91 {phone}'**
  String otpSentTo(Object phone);

  /// No description provided for @demoOtp.
  ///
  /// In en, this message translates to:
  /// **'Demo OTP: 123456'**
  String get demoOtp;

  /// No description provided for @mobileNumberVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Mobile number verified successfully!'**
  String get mobileNumberVerifiedSuccessfully;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Own Work. Own Boss'**
  String get appSlogan;

  /// No description provided for @continuingToLogin.
  ///
  /// In en, this message translates to:
  /// **'Continuing to login..'**
  String get continuingToLogin;

  /// No description provided for @welcomePartner.
  ///
  /// In en, this message translates to:
  /// **'Welcome Partner'**
  String get welcomePartner;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @partner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partner;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to manage your service business'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberMustStartWith.
  ///
  /// In en, this message translates to:
  /// **'Phone number must start with 6, 7, 8, or 9'**
  String get phoneNumberMustStartWith;

  /// No description provided for @phoneNumberMustBe10Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get phoneNumberMustBe10Digits;

  /// No description provided for @invalidPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get invalidPhoneFormat;

  /// No description provided for @sendOtpToPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Send OTP to Phone Number'**
  String get sendOtpToPhoneNumber;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @findMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Find my account'**
  String get findMyAccount;

  /// No description provided for @devSkipToVerification.
  ///
  /// In en, this message translates to:
  /// **'Dev: Skip to Verification'**
  String get devSkipToVerification;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtp;

  /// No description provided for @sentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to +91 {phoneNumber}'**
  String sentTo(String phoneNumber);

  /// No description provided for @backToPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Back to phone number'**
  String get backToPhoneNumber;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @didntReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP?'**
  String get didntReceiveOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(String seconds);

  /// No description provided for @selectYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Select your account'**
  String get selectYourAccount;

  /// No description provided for @accountRecovered.
  ///
  /// In en, this message translates to:
  /// **'Account Recovered'**
  String get accountRecovered;

  /// No description provided for @accountVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully verified.'**
  String get accountVerifiedSuccess;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @byContinyingYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get byContinyingYouAgree;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @findMyAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Find My Account'**
  String get findMyAccountTitle;

  /// No description provided for @enterRegisteredInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered information to find your account'**
  String get enterRegisteredInfo;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get enterEmailAddress;

  /// No description provided for @accountFound.
  ///
  /// In en, this message translates to:
  /// **'Account Found (Mock)'**
  String get accountFound;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @chatWithSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat with Support'**
  String get chatWithSupport;

  /// No description provided for @whatsAppSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsAppSupport;

  /// No description provided for @accountIssueAndFaq.
  ///
  /// In en, this message translates to:
  /// **'Account Issue & FAQ'**
  String get accountIssueAndFaq;

  /// No description provided for @commonQuestionsAndAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'Common questions and account help'**
  String get commonQuestionsAndAccountHelp;

  /// No description provided for @signOutOfYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutOfYourAccount;

  /// No description provided for @couldNotLaunchWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not launch WhatsApp'**
  String get couldNotLaunchWhatsApp;

  /// No description provided for @documentVerification.
  ///
  /// In en, this message translates to:
  /// **'Document Verification'**
  String get documentVerification;

  /// No description provided for @signingUpTo.
  ///
  /// In en, this message translates to:
  /// **'Signing up to'**
  String get signingUpTo;

  /// No description provided for @heresWhatYouNeedToDo.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you need to do set up your account'**
  String get heresWhatYouNeedToDo;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @aadharCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Card'**
  String get aadharCard;

  /// No description provided for @panCardOptional.
  ///
  /// In en, this message translates to:
  /// **'PAN Card (Optional)'**
  String get panCardOptional;

  /// No description provided for @drivingLicenseOptional.
  ///
  /// In en, this message translates to:
  /// **'Driving License (Optional)'**
  String get drivingLicenseOptional;

  /// No description provided for @workVerification.
  ///
  /// In en, this message translates to:
  /// **'Work Verification'**
  String get workVerification;

  /// No description provided for @permission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permission;

  /// No description provided for @skipForNowDevMode.
  ///
  /// In en, this message translates to:
  /// **'Skip for now (Dev Mode)'**
  String get skipForNowDevMode;

  /// No description provided for @pendingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending for verification'**
  String get pendingForVerification;

  /// No description provided for @locationSelection.
  ///
  /// In en, this message translates to:
  /// **'Location Selection'**
  String get locationSelection;

  /// No description provided for @confirmLocationToEarn.
  ///
  /// In en, this message translates to:
  /// **'Confirm the location you want to earn'**
  String get confirmLocationToEarn;

  /// No description provided for @searchForLocation.
  ///
  /// In en, this message translates to:
  /// **'Search for location...'**
  String get searchForLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @whyWeNeedLocation.
  ///
  /// In en, this message translates to:
  /// **'Why we need your location?'**
  String get whyWeNeedLocation;

  /// No description provided for @locationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your location helps us connect you with nearby customers, ensure timely service delivery, and maximize your earning potential by reducing travel time.'**
  String get locationExplanation;

  /// No description provided for @useThisLocationForEarning.
  ///
  /// In en, this message translates to:
  /// **'Use this location for earning'**
  String get useThisLocationForEarning;

  /// No description provided for @fetchingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching your location...'**
  String get fetchingYourLocation;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. Please enable them in settings.'**
  String get locationPermissionsDenied;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @lessThanOneYear.
  ///
  /// In en, this message translates to:
  /// **'< 1 Yr'**
  String get lessThanOneYear;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @aadharCardVerification.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Card Verification'**
  String get aadharCardVerification;

  /// No description provided for @enterAadharDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Aadhar Details'**
  String get enterAadharDetails;

  /// No description provided for @fillAadharInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill in your Aadhar card information'**
  String get fillAadharInfo;

  /// No description provided for @aadharNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Number'**
  String get aadharNumber;

  /// No description provided for @fullNameAsPerAadhar.
  ///
  /// In en, this message translates to:
  /// **'Full Name (as per Aadhar)'**
  String get fullNameAsPerAadhar;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @uploadAadharCard.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhar Card'**
  String get uploadAadharCard;

  /// No description provided for @uploadClearPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload clear photos of both sides'**
  String get uploadClearPhotos;

  /// No description provided for @frontSide.
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get frontSide;

  /// No description provided for @backSide.
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get backSide;

  /// No description provided for @frontSidePhoto.
  ///
  /// In en, this message translates to:
  /// **'Front Side Photo'**
  String get frontSidePhoto;

  /// No description provided for @backSidePhoto.
  ///
  /// In en, this message translates to:
  /// **'Back Side Photo'**
  String get backSidePhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @submitAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Submit & Continue'**
  String get submitAndContinue;

  /// No description provided for @sample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sample;

  /// No description provided for @sampleAadharCard.
  ///
  /// In en, this message translates to:
  /// **'Sample Aadhar Card'**
  String get sampleAadharCard;

  /// No description provided for @aadharShouldLookLikeThis.
  ///
  /// In en, this message translates to:
  /// **'Your Aadhar card should look like this. Make sure the photo is clear and all details are visible.'**
  String get aadharShouldLookLikeThis;

  /// No description provided for @aadharDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Aadhar details saved successfully!'**
  String get aadharDetailsSaved;

  /// No description provided for @errorSavingData.
  ///
  /// In en, this message translates to:
  /// **'Error saving data:'**
  String get errorSavingData;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image:'**
  String get errorPickingImage;

  /// No description provided for @couldNotLoadSample.
  ///
  /// In en, this message translates to:
  /// **'Could not load sample'**
  String get couldNotLoadSample;

  /// No description provided for @requestingCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Requesting Camera Access...'**
  String get requestingCameraAccess;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get cameraPermissionRequired;

  /// No description provided for @galleryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery permission is required to select photos'**
  String get galleryPermissionRequired;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @uploadedWithTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} Uploaded'**
  String uploadedWithTitle(Object title);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @uploadText.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadText;

  /// No description provided for @tapToCaptureOrSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture or select'**
  String get tapToCaptureOrSelect;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @panCardVerification.
  ///
  /// In en, this message translates to:
  /// **'PAN Card Verification'**
  String get panCardVerification;

  /// No description provided for @enterPanDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter PAN Details'**
  String get enterPanDetails;

  /// No description provided for @fillPanInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill in your PAN card information'**
  String get fillPanInfo;

  /// No description provided for @panNumber.
  ///
  /// In en, this message translates to:
  /// **'PAN Number'**
  String get panNumber;

  /// No description provided for @fullNameAsPerPan.
  ///
  /// In en, this message translates to:
  /// **'Full Name (as per PAN)'**
  String get fullNameAsPerPan;

  /// No description provided for @enterNameAsOnPan.
  ///
  /// In en, this message translates to:
  /// **'Enter your name as on PAN card'**
  String get enterNameAsOnPan;

  /// No description provided for @uploadPanCard.
  ///
  /// In en, this message translates to:
  /// **'Upload PAN Card'**
  String get uploadPanCard;

  /// No description provided for @samplePanCard.
  ///
  /// In en, this message translates to:
  /// **'Sample PAN Card'**
  String get samplePanCard;

  /// No description provided for @panShouldLookLikeThis.
  ///
  /// In en, this message translates to:
  /// **'Your PAN card should look like this. Make sure all details are visible.'**
  String get panShouldLookLikeThis;

  /// No description provided for @panDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'PAN details saved successfully!'**
  String get panDetailsSaved;

  /// No description provided for @panCardPreview.
  ///
  /// In en, this message translates to:
  /// **'PAN Card Preview'**
  String get panCardPreview;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @drivingLicenseVerification.
  ///
  /// In en, this message translates to:
  /// **'Driving License Verification'**
  String get drivingLicenseVerification;

  /// No description provided for @enterDlDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter DL Details'**
  String get enterDlDetails;

  /// No description provided for @fillDlInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill in your driving license information'**
  String get fillDlInfo;

  /// No description provided for @dlNumber.
  ///
  /// In en, this message translates to:
  /// **'DL Number'**
  String get dlNumber;

  /// No description provided for @fullNameAsPerDl.
  ///
  /// In en, this message translates to:
  /// **'Full Name (as per DL)'**
  String get fullNameAsPerDl;

  /// No description provided for @enterNameAsOnDl.
  ///
  /// In en, this message translates to:
  /// **'Enter your name as on driving license'**
  String get enterNameAsOnDl;

  /// No description provided for @uploadDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Upload Driving License'**
  String get uploadDrivingLicense;

  /// No description provided for @sampleDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Sample Driving License'**
  String get sampleDrivingLicense;

  /// No description provided for @dlShouldLookLikeThis.
  ///
  /// In en, this message translates to:
  /// **'Your Driving License should look like this. Make sure all details are visible.'**
  String get dlShouldLookLikeThis;

  /// No description provided for @dlDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Driving License details saved successfully!'**
  String get dlDetailsSaved;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectServices.
  ///
  /// In en, this message translates to:
  /// **'Select Your Services'**
  String get selectServices;

  /// No description provided for @chooseServicesToOffer.
  ///
  /// In en, this message translates to:
  /// **'Choose the services you want to offer'**
  String get chooseServicesToOffer;

  /// No description provided for @plumber.
  ///
  /// In en, this message translates to:
  /// **'Plumber'**
  String get plumber;

  /// No description provided for @electrician.
  ///
  /// In en, this message translates to:
  /// **'Electrician'**
  String get electrician;

  /// No description provided for @carpenter.
  ///
  /// In en, this message translates to:
  /// **'Carpenter'**
  String get carpenter;

  /// No description provided for @gardening.
  ///
  /// In en, this message translates to:
  /// **'Gardening'**
  String get gardening;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @menSalon.
  ///
  /// In en, this message translates to:
  /// **'Men Salon'**
  String get menSalon;

  /// No description provided for @womenSalon.
  ///
  /// In en, this message translates to:
  /// **'Women Salon'**
  String get womenSalon;

  /// No description provided for @makeupAndBeauty.
  ///
  /// In en, this message translates to:
  /// **'Makeup & Beauty'**
  String get makeupAndBeauty;

  /// No description provided for @quickTransport.
  ///
  /// In en, this message translates to:
  /// **'Quick Transport'**
  String get quickTransport;

  /// No description provided for @appliancesRepair.
  ///
  /// In en, this message translates to:
  /// **'Appliances Repair & Replacement'**
  String get appliancesRepair;

  /// No description provided for @ac.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get ac;

  /// No description provided for @airCooler.
  ///
  /// In en, this message translates to:
  /// **'Air Cooler'**
  String get airCooler;

  /// No description provided for @chimney.
  ///
  /// In en, this message translates to:
  /// **'Chimney'**
  String get chimney;

  /// No description provided for @geyser.
  ///
  /// In en, this message translates to:
  /// **'Geyser'**
  String get geyser;

  /// No description provided for @laptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get laptop;

  /// No description provided for @refrigerator.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get refrigerator;

  /// No description provided for @washingMachine.
  ///
  /// In en, this message translates to:
  /// **'Washing Machine'**
  String get washingMachine;

  /// No description provided for @microwave.
  ///
  /// In en, this message translates to:
  /// **'Microwave'**
  String get microwave;

  /// No description provided for @television.
  ///
  /// In en, this message translates to:
  /// **'Television'**
  String get television;

  /// No description provided for @waterPurifier.
  ///
  /// In en, this message translates to:
  /// **'Water Purifier'**
  String get waterPurifier;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @totalExperience.
  ///
  /// In en, this message translates to:
  /// **'Total Experience (Years)'**
  String get totalExperience;

  /// No description provided for @specialSkills.
  ///
  /// In en, this message translates to:
  /// **'Special Skills'**
  String get specialSkills;

  /// No description provided for @workVideo.
  ///
  /// In en, this message translates to:
  /// **'Work Video (30s - 1min)'**
  String get workVideo;

  /// No description provided for @selectVideoSource.
  ///
  /// In en, this message translates to:
  /// **'Select Video Source'**
  String get selectVideoSource;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @videoPreview.
  ///
  /// In en, this message translates to:
  /// **'Video Preview'**
  String get videoPreview;

  /// No description provided for @videoMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Video must be between 5 seconds and 1 minute'**
  String get videoMustBeBetween;

  /// No description provided for @videoUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully!'**
  String get videoUploadedSuccessfully;

  /// No description provided for @workVerificationSaved.
  ///
  /// In en, this message translates to:
  /// **'Work verification details saved successfully!'**
  String get workVerificationSaved;

  /// No description provided for @serviceSubmittedForVerification.
  ///
  /// In en, this message translates to:
  /// **'Service submitted for verification! We will notify you once approved.'**
  String get serviceSubmittedForVerification;

  /// No description provided for @workSelection.
  ///
  /// In en, this message translates to:
  /// **'Work Selection'**
  String get workSelection;

  /// No description provided for @selectServicesProvide.
  ///
  /// In en, this message translates to:
  /// **'Select the services you provide'**
  String get selectServicesProvide;

  /// No description provided for @countSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String countSelected(Object count);

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'{name} Details'**
  String serviceDetails(Object name);

  /// No description provided for @uploadServiceVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Service Video'**
  String get uploadServiceVideo;

  /// No description provided for @minMaxVideoDuration.
  ///
  /// In en, this message translates to:
  /// **'Min 30s - Max 1min'**
  String get minMaxVideoDuration;

  /// No description provided for @selectAppliancesRepair.
  ///
  /// In en, this message translates to:
  /// **'Select appliances you can repair:'**
  String get selectAppliancesRepair;

  /// No description provided for @aadharHint.
  ///
  /// In en, this message translates to:
  /// **'XXXX XXXX XXXX'**
  String get aadharHint;

  /// No description provided for @panHint.
  ///
  /// In en, this message translates to:
  /// **'ABCDE1234F'**
  String get panHint;

  /// No description provided for @dlHint.
  ///
  /// In en, this message translates to:
  /// **'KA0120200012345'**
  String get dlHint;

  /// No description provided for @dobHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dobHint;

  /// No description provided for @experienceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5'**
  String get experienceHint;

  /// No description provided for @skillsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Industrial Wiring'**
  String get skillsHint;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobs;

  /// No description provided for @noActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'No active jobs'**
  String get noActiveJobs;

  /// No description provided for @goOnlineToReceiveJobs.
  ///
  /// In en, this message translates to:
  /// **'Go online to receive jobs!'**
  String get goOnlineToReceiveJobs;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @upiWithdraw.
  ///
  /// In en, this message translates to:
  /// **'UPI Withdraw'**
  String get upiWithdraw;

  /// No description provided for @addBankAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'First add your bank account details'**
  String get addBankAccountDetails;

  /// No description provided for @addUpiId.
  ///
  /// In en, this message translates to:
  /// **'Add UPI ID'**
  String get addUpiId;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @withdrawVia.
  ///
  /// In en, this message translates to:
  /// **'Withdraw via {method}'**
  String withdrawVia(String method);

  /// No description provided for @enterAmountToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to withdraw:'**
  String get enterAmountToWithdraw;

  /// No description provided for @availableBalanceWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Available balance: ₹{amount}'**
  String availableBalanceWithAmount(String amount);

  /// No description provided for @invalidAmountOrInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount or insufficient balance'**
  String get invalidAmountOrInsufficientBalance;

  /// No description provided for @withdrawalWithMethod.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal ({method})'**
  String withdrawalWithMethod(Object method);

  /// No description provided for @transferToPersonalAccount.
  ///
  /// In en, this message translates to:
  /// **'Transfer to personal account'**
  String get transferToPersonalAccount;

  /// No description provided for @personalAccount.
  ///
  /// In en, this message translates to:
  /// **'Personal Account'**
  String get personalAccount;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @withdrawalProcessed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request processed!'**
  String get withdrawalProcessed;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @enterAmountToAddOrPay.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to add or pay:'**
  String get enterAmountToAddOrPay;

  /// No description provided for @quickAmounts.
  ///
  /// In en, this message translates to:
  /// **'Quick Amounts:'**
  String get quickAmounts;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @dueAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Due Amount Paid'**
  String get dueAmountPaid;

  /// No description provided for @paymentForPlatformFees.
  ///
  /// In en, this message translates to:
  /// **'Payment for platform fees'**
  String get paymentForPlatformFees;

  /// No description provided for @paymentProcessedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment processed successfully!'**
  String get paymentProcessedSuccessfully;

  /// No description provided for @proceedToPay.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Pay'**
  String get proceedToPay;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @totalForMonth.
  ///
  /// In en, this message translates to:
  /// **'Total for {month}'**
  String totalForMonth(String month);

  /// No description provided for @earningsForMonthAndDay.
  ///
  /// In en, this message translates to:
  /// **'Earnings for {month} {day}'**
  String earningsForMonthAndDay(String month, String day);

  /// No description provided for @incentivesAndOffers.
  ///
  /// In en, this message translates to:
  /// **'Incentives & Offers'**
  String get incentivesAndOffers;

  /// No description provided for @weeklyBonusChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bonus Challenge'**
  String get weeklyBonusChallenge;

  /// No description provided for @weeklyBonusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete 15 jobs to earn ₹500 extra'**
  String get weeklyBonusSubtitle;

  /// No description provided for @jobsDoneWithProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/15 Jobs Done'**
  String jobsDoneWithProgress(String count);

  /// No description provided for @potentialEarnings.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} potential'**
  String potentialEarnings(String amount);

  /// No description provided for @referAndEarnWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn ₹{amount}'**
  String referAndEarnWithAmount(String amount);

  /// No description provided for @referSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends to join OmiBay Partner'**
  String get referSubtitle;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @referAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referAndEarn;

  /// No description provided for @referHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer a Friend & Earn ₹200'**
  String get referHeroTitle;

  /// No description provided for @referHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn reward credits for every successful partner onboarding.'**
  String get referHeroSubtitle;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'YOUR REFERRAL CODE'**
  String get yourReferralCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopied;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'HOW IT WORKS'**
  String get howItWorks;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Share your referral code with friends looking for service jobs.'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'They register as a partner and complete document verification.'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Earn Rewards'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Once they complete their 5th job, you get ₹200 in your wallet.'**
  String get step3Desc;

  /// No description provided for @totalReferrals.
  ///
  /// In en, this message translates to:
  /// **'Total Referrals'**
  String get totalReferrals;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get shareCode;

  /// No description provided for @referralTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral Terms & Conditions'**
  String get referralTermsTitle;

  /// No description provided for @referralTermsPoint1.
  ///
  /// In en, this message translates to:
  /// **'1. The referral reward is ₹200 for each successful partner onboarding.'**
  String get referralTermsPoint1;

  /// No description provided for @referralTermsPoint2.
  ///
  /// In en, this message translates to:
  /// **'2. The reward is credited only after the referred partner completes their first 5 successful jobs.'**
  String get referralTermsPoint2;

  /// No description provided for @referralTermsPoint3.
  ///
  /// In en, this message translates to:
  /// **'3. The referred partner must use your unique referral code during registration.'**
  String get referralTermsPoint3;

  /// No description provided for @referralTermsPoint4.
  ///
  /// In en, this message translates to:
  /// **'4. Referral rewards are subject to verification and may be reversed in case of fraudulent activity.'**
  String get referralTermsPoint4;

  /// No description provided for @referralTermsPoint5.
  ///
  /// In en, this message translates to:
  /// **'5. OmiBay reserves the right to modify or terminate the referral program at any time without prior notice.'**
  String get referralTermsPoint5;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @paymentCredited.
  ///
  /// In en, this message translates to:
  /// **'Payment Credited'**
  String get paymentCredited;

  /// No description provided for @feeDeducted.
  ///
  /// In en, this message translates to:
  /// **'Fee Deducted'**
  String get feeDeducted;

  /// No description provided for @onlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get onlinePayment;

  /// No description provided for @cashPayAfterService.
  ///
  /// In en, this message translates to:
  /// **'Cash (Pay After Service)'**
  String get cashPayAfterService;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @jobReference.
  ///
  /// In en, this message translates to:
  /// **'Job Reference'**
  String get jobReference;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @earningsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'EARNINGS BREAKDOWN'**
  String get earningsBreakdown;

  /// No description provided for @totalJobPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Job Price'**
  String get totalJobPrice;

  /// No description provided for @serviceAmountExclTip.
  ///
  /// In en, this message translates to:
  /// **'Service Amount (excl. tip)'**
  String get serviceAmountExclTip;

  /// No description provided for @gst.
  ///
  /// In en, this message translates to:
  /// **'GST (5%)'**
  String get gst;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee (20%)'**
  String get platformFee;

  /// No description provided for @tipToPartner.
  ///
  /// In en, this message translates to:
  /// **'Tip (100% to Partner)'**
  String get tipToPartner;

  /// No description provided for @yourNetEarning.
  ///
  /// In en, this message translates to:
  /// **'Your Net Earning'**
  String get yourNetEarning;

  /// No description provided for @cashPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment Note'**
  String get cashPaymentNote;

  /// No description provided for @collectedCashFromCustomer.
  ///
  /// In en, this message translates to:
  /// **'You collected ₹{amount} in cash from customer.'**
  String collectedCashFromCustomer(String amount);

  /// No description provided for @amountDueToOmiBay.
  ///
  /// In en, this message translates to:
  /// **'Amount due to OmiBay: ₹{amount}'**
  String amountDueToOmiBay(String amount);

  /// No description provided for @noTransactionHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No transaction history found'**
  String get noTransactionHistoryFound;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get exportHistory;

  /// No description provided for @processed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processed;

  /// No description provided for @deducted.
  ///
  /// In en, this message translates to:
  /// **'Deducted'**
  String get deducted;

  /// No description provided for @activeJob.
  ///
  /// In en, this message translates to:
  /// **'Active Job'**
  String get activeJob;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DURATION'**
  String get totalDuration;

  /// No description provided for @jobInProgress.
  ///
  /// In en, this message translates to:
  /// **'Job in Progress'**
  String get jobInProgress;

  /// No description provided for @serviceChecklist.
  ///
  /// In en, this message translates to:
  /// **'SERVICE CHECKLIST'**
  String get serviceChecklist;

  /// No description provided for @afterServicePhotos.
  ///
  /// In en, this message translates to:
  /// **'AFTER SERVICE PHOTOS'**
  String get afterServicePhotos;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelp;

  /// No description provided for @chatNow.
  ///
  /// In en, this message translates to:
  /// **'Chat Now'**
  String get chatNow;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @jobCompleted.
  ///
  /// In en, this message translates to:
  /// **'Job Completed!'**
  String get jobCompleted;

  /// No description provided for @earnedFromJob.
  ///
  /// In en, this message translates to:
  /// **'You have earned ₹{amount} from this job.'**
  String earnedFromJob(String amount);

  /// No description provided for @amountCreditedToWallet.
  ///
  /// In en, this message translates to:
  /// **'Amount credited to wallet'**
  String get amountCreditedToWallet;

  /// No description provided for @cashCollectedFeeDeducted.
  ///
  /// In en, this message translates to:
  /// **'Cash collected - Platform fee deducted'**
  String get cashCollectedFeeDeducted;

  /// No description provided for @customerRating.
  ///
  /// In en, this message translates to:
  /// **'Customer Rating'**
  String get customerRating;

  /// No description provided for @ratingGivenByCustomer.
  ///
  /// In en, this message translates to:
  /// **'Rating given by customer for your service'**
  String get ratingGivenByCustomer;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @resumeWork.
  ///
  /// In en, this message translates to:
  /// **'Resume Work'**
  String get resumeWork;

  /// No description provided for @pauseWork.
  ///
  /// In en, this message translates to:
  /// **'Pause Work'**
  String get pauseWork;

  /// No description provided for @workResumed.
  ///
  /// In en, this message translates to:
  /// **'Work Resumed'**
  String get workResumed;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get startJourney;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @startWork.
  ///
  /// In en, this message translates to:
  /// **'Start Work'**
  String get startWork;

  /// No description provided for @completeJobQuestion.
  ///
  /// In en, this message translates to:
  /// **'Complete Job?'**
  String get completeJobQuestion;

  /// No description provided for @completeJobConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that the job is completed successfully.'**
  String get completeJobConfirmation;

  /// No description provided for @receiveMoney.
  ///
  /// In en, this message translates to:
  /// **'Receive Money'**
  String get receiveMoney;

  /// No description provided for @completionProof.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION PROOF'**
  String get completionProof;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @min10Sec.
  ///
  /// In en, this message translates to:
  /// **'min 10 sec'**
  String get min10Sec;

  /// No description provided for @prepaid.
  ///
  /// In en, this message translates to:
  /// **'Prepaid'**
  String get prepaid;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @showQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get showQr;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @jobMarkedAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Job marked as completed!'**
  String get jobMarkedAsCompleted;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to Pay'**
  String get scanToPay;

  /// No description provided for @scanToPayInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please ask the customer to scan this QR code to complete the payment.'**
  String get scanToPayInstructions;

  /// No description provided for @totalAmountToPay.
  ///
  /// In en, this message translates to:
  /// **'Total Amount to Pay'**
  String get totalAmountToPay;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID: {id}'**
  String bookingId(Object id);

  /// No description provided for @fullHomeCleaning.
  ///
  /// In en, this message translates to:
  /// **'Full Home Cleaning'**
  String get fullHomeCleaning;

  /// No description provided for @kitchenDeepClean.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Deep Clean'**
  String get kitchenDeepClean;

  /// No description provided for @bathroomSanitization.
  ///
  /// In en, this message translates to:
  /// **'Bathroom Sanitization'**
  String get bathroomSanitization;

  /// No description provided for @sofaAndCarpetCleaning.
  ///
  /// In en, this message translates to:
  /// **'Sofa & Carpet Cleaning'**
  String get sofaAndCarpetCleaning;

  /// No description provided for @acServiceAndRepair.
  ///
  /// In en, this message translates to:
  /// **'AC Service & Repair'**
  String get acServiceAndRepair;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pestControl;

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'AWESOME!'**
  String get awesome;

  /// No description provided for @noProblem.
  ///
  /// In en, this message translates to:
  /// **'NO PROBLEM'**
  String get noProblem;

  /// No description provided for @jobAccepted.
  ///
  /// In en, this message translates to:
  /// **'JOB ACCEPTED'**
  String get jobAccepted;

  /// No description provided for @jobDeclined.
  ///
  /// In en, this message translates to:
  /// **'JOB DECLINED'**
  String get jobDeclined;

  /// No description provided for @goodLuckWithNewMission.
  ///
  /// In en, this message translates to:
  /// **'Good luck with your new mission!'**
  String get goodLuckWithNewMission;

  /// No description provided for @takeABreak.
  ///
  /// In en, this message translates to:
  /// **'Take a break, we\'ll bring more soon.'**
  String get takeABreak;

  /// No description provided for @todaysPerformance.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Performance'**
  String get todaysPerformance;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @jobsDone.
  ///
  /// In en, this message translates to:
  /// **'Jobs Done'**
  String get jobsDone;

  /// No description provided for @onlineTime.
  ///
  /// In en, this message translates to:
  /// **'Online Time'**
  String get onlineTime;

  /// No description provided for @proTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips'**
  String get proTips;

  /// No description provided for @weeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenge'**
  String get weeklyChallenge;

  /// No description provided for @completeJobsToEarn.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} jobs to unlock bonus'**
  String completeJobsToEarn(String count);

  /// No description provided for @inviteFriendsToJoin.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to join OmiBay Partner'**
  String get inviteFriendsToJoin;

  /// No description provided for @manageServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'Manage your service requests'**
  String get manageServiceRequests;

  /// No description provided for @searchByBookingIdOrService.
  ///
  /// In en, this message translates to:
  /// **'Search by booking ID or service...'**
  String get searchByBookingIdOrService;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get noJobsFound;

  /// No description provided for @whenYouAcceptJob.
  ///
  /// In en, this message translates to:
  /// **'When you accept a job, it will appear here.'**
  String get whenYouAcceptJob;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @availableBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Available balance:'**
  String get availableBalanceLabel;

  /// No description provided for @withdrawalRequestProcessed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request processed!'**
  String get withdrawalRequestProcessed;

  /// No description provided for @firstAddBankAccount.
  ///
  /// In en, this message translates to:
  /// **'First add your bank account details'**
  String get firstAddBankAccount;

  /// No description provided for @firstAddUpiId.
  ///
  /// In en, this message translates to:
  /// **'First add your UPI ID'**
  String get firstAddUpiId;

  /// No description provided for @complete15JobsToEarn.
  ///
  /// In en, this message translates to:
  /// **'Complete 15 jobs to earn ₹500 extra'**
  String get complete15JobsToEarn;

  /// No description provided for @jobsDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/15 Jobs Done'**
  String jobsDoneCount(String count);

  /// No description provided for @potential.
  ///
  /// In en, this message translates to:
  /// **'potential'**
  String get potential;

  /// No description provided for @referAndEarnAmount.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn ₹200'**
  String get referAndEarnAmount;

  /// No description provided for @inviteYourFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends to join OmiBay Partner'**
  String get inviteYourFriends;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment'**
  String get cashPayment;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @workWithUs.
  ///
  /// In en, this message translates to:
  /// **'Work with Us'**
  String get workWithUs;

  /// No description provided for @partnerId.
  ///
  /// In en, this message translates to:
  /// **'Partner ID:'**
  String get partnerId;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @myServices.
  ///
  /// In en, this message translates to:
  /// **'My Services'**
  String get myServices;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @accountAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountAndSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @manageLocation.
  ///
  /// In en, this message translates to:
  /// **'Manage Location'**
  String get manageLocation;

  /// No description provided for @managePermission.
  ///
  /// In en, this message translates to:
  /// **'Manage Permission'**
  String get managePermission;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @appearances.
  ///
  /// In en, this message translates to:
  /// **'Appearances'**
  String get appearances;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pleaseEnableNotificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Please enable notification permission in settings'**
  String get pleaseEnableNotificationPermission;

  /// No description provided for @accountSafety.
  ///
  /// In en, this message translates to:
  /// **'Account Safety'**
  String get accountSafety;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @legalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get legalDocuments;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @suspensionPolicy.
  ///
  /// In en, this message translates to:
  /// **'Suspension Policy'**
  String get suspensionPolicy;

  /// No description provided for @deactivationWarning.
  ///
  /// In en, this message translates to:
  /// **'Deactivating your account is temporary. Your profile will be hidden from customers, but your data will be saved.'**
  String get deactivationWarning;

  /// No description provided for @whyDeactivating.
  ///
  /// In en, this message translates to:
  /// **'Why are you deactivating?'**
  String get whyDeactivating;

  /// No description provided for @reasonBreak.
  ///
  /// In en, this message translates to:
  /// **'Taking a break from the platform'**
  String get reasonBreak;

  /// No description provided for @reasonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Too many notifications'**
  String get reasonNotifications;

  /// No description provided for @reasonOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Not getting enough job opportunities'**
  String get reasonOpportunities;

  /// No description provided for @reasonTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical issues with the app'**
  String get reasonTechnical;

  /// No description provided for @reasonPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy concerns'**
  String get reasonPrivacy;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @pleaseTellMore.
  ///
  /// In en, this message translates to:
  /// **'Please tell us more...'**
  String get pleaseTellMore;

  /// No description provided for @whatHappensDeactivate.
  ///
  /// In en, this message translates to:
  /// **'What happens when you deactivate?'**
  String get whatHappensDeactivate;

  /// No description provided for @deactivatePoint1.
  ///
  /// In en, this message translates to:
  /// **'Your profile won\'t be visible on the OmiBay platform.'**
  String get deactivatePoint1;

  /// No description provided for @deactivatePoint2.
  ///
  /// In en, this message translates to:
  /// **'You won\'t receive any new job notifications.'**
  String get deactivatePoint2;

  /// No description provided for @deactivatePoint3.
  ///
  /// In en, this message translates to:
  /// **'You can reactivate anytime by simply logging back in.'**
  String get deactivatePoint3;

  /// No description provided for @deactivatePoint4.
  ///
  /// In en, this message translates to:
  /// **'Ongoing jobs must be completed before deactivation.'**
  String get deactivatePoint4;

  /// No description provided for @deactivateMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate My Account'**
  String get deactivateMyAccount;

  /// No description provided for @accountDeactivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated successfully. You can reactivate it by logging in again.'**
  String get accountDeactivatedSuccess;

  /// No description provided for @pleaseSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for deactivation'**
  String get pleaseSelectReason;

  /// No description provided for @confirmDeactivation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deactivation'**
  String get confirmDeactivation;

  /// No description provided for @areYouSureDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to temporarily deactivate your account?'**
  String get areYouSureDeactivate;

  /// No description provided for @verifyDeactivation.
  ///
  /// In en, this message translates to:
  /// **'Verify Deactivation'**
  String get verifyDeactivation;

  /// No description provided for @enterOtpDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP sent to your registered mobile number to confirm.'**
  String get enterOtpDeactivate;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'OTP Resent!'**
  String get otpResent;

  /// No description provided for @verifyAndDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Verify & Deactivate'**
  String get verifyAndDeactivate;

  /// No description provided for @deleteAccountCaution.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SAFETY CAUTION: This action is permanent and irreversible. Your entire professional history on OmiBay will be wiped.'**
  String get deleteAccountCaution;

  /// No description provided for @sorryToSeeYouGo.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry to see you go'**
  String get sorryToSeeYouGo;

  /// No description provided for @deletingPermanent.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account is permanent:'**
  String get deletingPermanent;

  /// No description provided for @deletePoint1.
  ///
  /// In en, this message translates to:
  /// **'All your personal profile data will be permanently erased.'**
  String get deletePoint1;

  /// No description provided for @deletePoint2.
  ///
  /// In en, this message translates to:
  /// **'Your entire earning history and transaction logs will be lost.'**
  String get deletePoint2;

  /// No description provided for @deletePoint3.
  ///
  /// In en, this message translates to:
  /// **'Any pending bonuses or incentives will be forfeited.'**
  String get deletePoint3;

  /// No description provided for @deletePoint4.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to login or recover this account again.'**
  String get deletePoint4;

  /// No description provided for @understandIrreversible.
  ///
  /// In en, this message translates to:
  /// **'I understand that this action is irreversible and I want to delete my account permanently.'**
  String get understandIrreversible;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @changedMyMind.
  ///
  /// In en, this message translates to:
  /// **'I changed my mind, go back'**
  String get changedMyMind;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully. We hope to see you back soon!'**
  String get accountDeletedSuccess;

  /// No description provided for @finalWarning.
  ///
  /// In en, this message translates to:
  /// **'Final Warning'**
  String get finalWarning;

  /// No description provided for @finalWarningContent.
  ///
  /// In en, this message translates to:
  /// **'This is your last chance. Once you click delete, your OmiBay Partner account will be gone forever. Are you absolutely sure?'**
  String get finalWarningContent;

  /// No description provided for @verifyPermanentDeletion.
  ///
  /// In en, this message translates to:
  /// **'Verify Permanent Deletion'**
  String get verifyPermanentDeletion;

  /// No description provided for @enterOtpDeletePermanent.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP sent to your registered mobile number to permanently delete your account.'**
  String get enterOtpDeletePermanent;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get searchHelp;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @categoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get categoryAccount;

  /// No description provided for @categoryNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get categoryNotification;

  /// No description provided for @categoryService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get categoryService;

  /// No description provided for @categoryJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get categoryJobs;

  /// No description provided for @categoryPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get categoryPayments;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// No description provided for @categoryAppFeature.
  ///
  /// In en, this message translates to:
  /// **'App Feature'**
  String get categoryAppFeature;

  /// No description provided for @docVerificationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Most account issues are resolved by completing document verification.'**
  String get docVerificationPrompt;

  /// No description provided for @noResultsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String noResultsFoundFor(Object query);

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check spelling'**
  String get tryDifferentKeywords;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still Need Help?'**
  String get stillNeedHelp;

  /// No description provided for @stillNeedHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Please use the Help option in the main app to chat with WhatsApp Support. Our team is available 24/7 to assist you.'**
  String get stillNeedHelpContent;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I verify my account?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'To verify your account, go to the Document Verification screen and upload the required documents: ID Proof (Aadhar/PAN), Address Proof (Utility bill/Bank statement), and Professional Details (Profile photo and experience).'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'What documents are required for ID Proof?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'We accept Aadhar Card or PAN Card. For Aadhar Card, both front and back sides must be uploaded. Ensure the images are clear and all details are legible.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'What if my documents are rejected?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'If your documents are rejected, you will receive a notification with the reason. Common reasons include blurry images, expired documents, or mismatched names. You can re-upload corrected documents immediately.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'How long does the verification process take?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'The verification process typically takes 24 to 48 hours. You will receive a notification once your account is verified and ready to accept jobs.'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'Can I change my registered phone number?'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can update your phone number in Account > Profile. You will need to verify the new number with an OTP.'**
  String get faqAnswer5;

  /// No description provided for @faqQuestion6.
  ///
  /// In en, this message translates to:
  /// **'How do I set up my payment details?'**
  String get faqQuestion6;

  /// No description provided for @faqAnswer6.
  ///
  /// In en, this message translates to:
  /// **'Go to Account > Payment Setup to add your Bank Account or UPI ID. This is where your earnings will be transferred.'**
  String get faqAnswer6;

  /// No description provided for @faqQuestion7.
  ///
  /// In en, this message translates to:
  /// **'When will I receive my earnings?'**
  String get faqQuestion7;

  /// No description provided for @faqAnswer7.
  ///
  /// In en, this message translates to:
  /// **'Earnings are usually settled within 24-48 hours after you initiate a withdrawal request from the Earnings dashboard.'**
  String get faqAnswer7;

  /// No description provided for @faqQuestion8.
  ///
  /// In en, this message translates to:
  /// **'I am not receiving job notifications.'**
  String get faqQuestion8;

  /// No description provided for @faqAnswer8.
  ///
  /// In en, this message translates to:
  /// **'Ensure your \"Online\" status is toggled on in the Home screen. Also, check if battery optimization is disabled for the app and all notification permissions are granted.'**
  String get faqAnswer8;

  /// No description provided for @faqQuestion9.
  ///
  /// In en, this message translates to:
  /// **'How do I add or change my services?'**
  String get faqQuestion9;

  /// No description provided for @faqAnswer9.
  ///
  /// In en, this message translates to:
  /// **'You can update the services you offer by going to Account > My Services. Select or deselect categories based on your expertise.'**
  String get faqAnswer9;

  /// No description provided for @faqQuestion10.
  ///
  /// In en, this message translates to:
  /// **'What to do if a customer cancels at the last minute?'**
  String get faqQuestion10;

  /// No description provided for @faqAnswer10.
  ///
  /// In en, this message translates to:
  /// **'If a customer cancels after you have already reached the location, you may be eligible for a cancellation fee. Contact support through the \"Help\" option for assistance.'**
  String get faqAnswer10;

  /// No description provided for @faqQuestion11.
  ///
  /// In en, this message translates to:
  /// **'How do I use the Opportunity Map?'**
  String get faqQuestion11;

  /// No description provided for @faqAnswer11.
  ///
  /// In en, this message translates to:
  /// **'The Opportunity Map shows high-demand zones in real-time. Move to areas marked in red or orange to increase your chances of receiving job requests.'**
  String get faqAnswer11;

  /// No description provided for @faqQuestion12.
  ///
  /// In en, this message translates to:
  /// **'What are the photo requirements?'**
  String get faqQuestion12;

  /// No description provided for @faqAnswer12.
  ///
  /// In en, this message translates to:
  /// **'Your profile photo should be a clear, front-facing headshot. Do not wear sunglasses or hats, and ensure the background is neutral.'**
  String get faqAnswer12;

  /// No description provided for @faqQuestion13.
  ///
  /// In en, this message translates to:
  /// **'How do I logout of the app?'**
  String get faqQuestion13;

  /// No description provided for @faqAnswer13.
  ///
  /// In en, this message translates to:
  /// **'You can logout by scrolling to the bottom of the Account screen and tapping the \"Logout\" button.'**
  String get faqAnswer13;

  /// No description provided for @faqQuestion14.
  ///
  /// In en, this message translates to:
  /// **'How do I contact support for a live job?'**
  String get faqQuestion14;

  /// No description provided for @faqAnswer14.
  ///
  /// In en, this message translates to:
  /// **'For active jobs, use the \"Help\" icon on the job screen to directly chat with our support team or call our helpline.'**
  String get faqAnswer14;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not Uploaded'**
  String get notUploaded;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @partialUpload.
  ///
  /// In en, this message translates to:
  /// **'Partial Upload'**
  String get partialUpload;

  /// No description provided for @cannotRemove.
  ///
  /// In en, this message translates to:
  /// **'Cannot Remove'**
  String get cannotRemove;

  /// No description provided for @mustHaveOneService.
  ///
  /// In en, this message translates to:
  /// **'You must have at least one verified service to receive jobs.'**
  String get mustHaveOneService;

  /// No description provided for @toSwitchServices.
  ///
  /// In en, this message translates to:
  /// **'To switch services:\n1. First verify a new service\n2. Then remove \"{serviceName}\"'**
  String toSwitchServices(Object serviceName);

  /// No description provided for @verifyNewService.
  ///
  /// In en, this message translates to:
  /// **'Verify New Service'**
  String get verifyNewService;

  /// No description provided for @removeServiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{serviceName}\" service?\n\nThis will delete your verification data including experience and video. You will need to verify again to add this service.'**
  String removeServiceConfirm(Object serviceName);

  /// No description provided for @noVerifiedServices.
  ///
  /// In en, this message translates to:
  /// **'No Verified Services'**
  String get noVerifiedServices;

  /// No description provided for @verifyAtLeastOneService.
  ///
  /// In en, this message translates to:
  /// **'You need to verify at least one service before you can start receiving jobs. Verify your skills now!'**
  String get verifyAtLeastOneService;

  /// No description provided for @verifyYourServices.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Services'**
  String get verifyYourServices;

  /// No description provided for @activeServices.
  ///
  /// In en, this message translates to:
  /// **'Active Services'**
  String get activeServices;

  /// No description provided for @activeApplianceServices.
  ///
  /// In en, this message translates to:
  /// **'Active Appliance Services'**
  String get activeApplianceServices;

  /// No description provided for @verificationPendingNotify.
  ///
  /// In en, this message translates to:
  /// **'Verification pending - We will notify you once approved'**
  String get verificationPendingNotify;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// No description provided for @pendingApplianceServices.
  ///
  /// In en, this message translates to:
  /// **'Pending Appliance Services'**
  String get pendingApplianceServices;

  /// No description provided for @videoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded'**
  String get videoUploaded;

  /// No description provided for @cannotDeletePending.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete service while verification is pending'**
  String get cannotDeletePending;

  /// No description provided for @serviceRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{serviceName} service removed successfully'**
  String serviceRemovedSuccess(Object serviceName);

  /// No description provided for @errorRemovingService.
  ///
  /// In en, this message translates to:
  /// **'Error removing service: {error}'**
  String errorRemovingService(Object error);

  /// No description provided for @verifiedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verified'**
  String verifiedCount(Object count);

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String pendingCount(Object count);

  /// No description provided for @cannotDeleteWhilePending.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete while pending'**
  String get cannotDeleteWhilePending;

  /// No description provided for @addMoreServices.
  ///
  /// In en, this message translates to:
  /// **'Add More Services'**
  String get addMoreServices;

  /// No description provided for @verifyFirstService.
  ///
  /// In en, this message translates to:
  /// **'Verify Your First Service'**
  String get verifyFirstService;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can we help you today?'**
  String get chatWelcome;

  /// No description provided for @chatResponse.
  ///
  /// In en, this message translates to:
  /// **'Thanks for reaching out! An agent will be with you shortly.'**
  String get chatResponse;

  /// No description provided for @omibaySupport.
  ///
  /// In en, this message translates to:
  /// **'OmiBay Support'**
  String get omibaySupport;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @updateLanguage.
  ///
  /// In en, this message translates to:
  /// **'Update Language'**
  String get updateLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @notificationJobTitle.
  ///
  /// In en, this message translates to:
  /// **'New Job Request'**
  String get notificationJobTitle;

  /// No description provided for @notificationJobBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new request for Full Home Cleaning in Bellandur.'**
  String get notificationJobBody;

  /// No description provided for @notificationPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get notificationPaymentTitle;

  /// No description provided for @notificationPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Your earnings of ₹1,499 for job #OK123456 has been credited.'**
  String get notificationPaymentBody;

  /// No description provided for @notificationSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful'**
  String get notificationSystemTitle;

  /// No description provided for @notificationSystemBody.
  ///
  /// In en, this message translates to:
  /// **'Your document verification is complete. You are now a verified partner.'**
  String get notificationSystemBody;

  /// No description provided for @notificationPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bonus!'**
  String get notificationPromoTitle;

  /// No description provided for @notificationPromoBody.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 more jobs this week to earn an extra ₹500.'**
  String get notificationPromoBody;

  /// No description provided for @notificationCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Cancelled'**
  String get notificationCancelledTitle;

  /// No description provided for @notificationCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Customer Rahul Sharma cancelled the request for Home Cleaning.'**
  String get notificationCancelledBody;

  /// No description provided for @time2MinsAgo.
  ///
  /// In en, this message translates to:
  /// **'2 mins ago'**
  String get time2MinsAgo;

  /// No description provided for @time1HourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get time1HourAgo;

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @time2DaysAgo.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get time2DaysAgo;

  /// No description provided for @time3DaysAgo.
  ///
  /// In en, this message translates to:
  /// **'3 days ago'**
  String get time3DaysAgo;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Partner!'**
  String get welcomeBack;

  /// No description provided for @debugOtpSent.
  ///
  /// In en, this message translates to:
  /// **'DEBUG: OTP sent (Mock: 123456)'**
  String get debugOtpSent;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP (Mock uses 123456)'**
  String get invalidOtp;

  /// No description provided for @failedToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in:'**
  String get failedToSignIn;

  /// No description provided for @earningsForDay.
  ///
  /// In en, this message translates to:
  /// **'Earnings for {month} {day}'**
  String earningsForDay(String month, String day);

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @newJobRequest.
  ///
  /// In en, this message translates to:
  /// **'New Job Request'**
  String get newJobRequest;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @incomingJob.
  ///
  /// In en, this message translates to:
  /// **'Incoming Job'**
  String get incomingJob;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @startJob.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get startJob;

  /// No description provided for @completeJob.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get completeJob;

  /// No description provided for @navigateToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Customer'**
  String get navigateToCustomer;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call Customer'**
  String get callCustomer;

  /// No description provided for @chatWithCustomer.
  ///
  /// In en, this message translates to:
  /// **'Chat with Customer'**
  String get chatWithCustomer;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCode;

  /// No description provided for @shareReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Share Referral Code'**
  String get shareReferralCode;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @totalReferralEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Referral Earnings'**
  String get totalReferralEarnings;

  /// No description provided for @withdrawalHistory.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal History'**
  String get withdrawalHistory;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerified;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermission;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get cameraPermission;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission'**
  String get storagePermission;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission Granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @opportunityMap.
  ///
  /// In en, this message translates to:
  /// **'Opportunity Map'**
  String get opportunityMap;

  /// No description provided for @nearbyOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Nearby Opportunities'**
  String get nearbyOpportunities;

  /// No description provided for @editServices.
  ///
  /// In en, this message translates to:
  /// **'Edit Services'**
  String get editServices;

  /// No description provided for @addNewService.
  ///
  /// In en, this message translates to:
  /// **'Add New Service'**
  String get addNewService;

  /// No description provided for @paymentSetup.
  ///
  /// In en, this message translates to:
  /// **'Payment Setup'**
  String get paymentSetup;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// No description provided for @upiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// No description provided for @addBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Bank Account'**
  String get addBankAccount;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get areYouSureDelete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @minsAway.
  ///
  /// In en, this message translates to:
  /// **'{mins} mins away'**
  String minsAway(String mins);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String kmAway(String km);

  /// No description provided for @allProTips.
  ///
  /// In en, this message translates to:
  /// **'All Pro Tips'**
  String get allProTips;

  /// No description provided for @proTip1.
  ///
  /// In en, this message translates to:
  /// **'Always wear your uniform for better rating.'**
  String get proTip1;

  /// No description provided for @proTip2.
  ///
  /// In en, this message translates to:
  /// **'Arrive 5 minutes early to the location.'**
  String get proTip2;

  /// No description provided for @proTip3.
  ///
  /// In en, this message translates to:
  /// **'Take clear photos before and after work.'**
  String get proTip3;

  /// No description provided for @proTip4.
  ///
  /// In en, this message translates to:
  /// **'Greet the customer with a professional smile.'**
  String get proTip4;

  /// No description provided for @proTip5.
  ///
  /// In en, this message translates to:
  /// **'Double-check your tools before leaving for a job.'**
  String get proTip5;

  /// No description provided for @proTip6.
  ///
  /// In en, this message translates to:
  /// **'Maintain high communication during the service.'**
  String get proTip6;

  /// No description provided for @proTip7.
  ///
  /// In en, this message translates to:
  /// **'Keep your work area clean during and after service.'**
  String get proTip7;

  /// No description provided for @proTip8.
  ///
  /// In en, this message translates to:
  /// **'Ask for feedback after completing the job.'**
  String get proTip8;

  /// No description provided for @proTip9.
  ///
  /// In en, this message translates to:
  /// **'Update your status immediately after finishing.'**
  String get proTip9;

  /// No description provided for @proTip10.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated and take short breaks between jobs.'**
  String get proTip10;

  /// No description provided for @complete15Jobs.
  ///
  /// In en, this message translates to:
  /// **'Complete 15 jobs'**
  String get complete15Jobs;

  /// No description provided for @earnExtraReward.
  ///
  /// In en, this message translates to:
  /// **'Earn ₹500 extra'**
  String get earnExtraReward;

  /// No description provided for @shareAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Share & Earn'**
  String get shareAndEarn;

  /// No description provided for @goOnlineToStart.
  ///
  /// In en, this message translates to:
  /// **'Go online to start receiving job requests in your area.'**
  String get goOnlineToStart;

  /// No description provided for @setDefaultPayoutMethod.
  ///
  /// In en, this message translates to:
  /// **'Set as default {type} payout method'**
  String setDefaultPayoutMethod(String type);

  /// No description provided for @deletePaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment Method?'**
  String get deletePaymentMethodTitle;

  /// No description provided for @deletePaymentMethodConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this {type}?'**
  String deletePaymentMethodConfirm(String type);

  /// No description provided for @savedOptions.
  ///
  /// In en, this message translates to:
  /// **'SAVED OPTIONS'**
  String get savedOptions;

  /// No description provided for @noPaymentMethodSaved.
  ///
  /// In en, this message translates to:
  /// **'No payment method saved'**
  String get noPaymentMethodSaved;

  /// No description provided for @bankAccountsLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get bankAccountsLabel;

  /// No description provided for @accountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'A/C: {number}'**
  String accountNumberLabel(String number);

  /// No description provided for @upiIdsLabel.
  ///
  /// In en, this message translates to:
  /// **'UPI IDs'**
  String get upiIdsLabel;

  /// No description provided for @addNewOption.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW OPTION'**
  String get addNewOption;

  /// No description provided for @directTransferToBank.
  ///
  /// In en, this message translates to:
  /// **'Direct transfer to your bank'**
  String get directTransferToBank;

  /// No description provided for @upiAppsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Google Pay, PhonePe, Paytm etc.'**
  String get upiAppsSubtitle;

  /// No description provided for @secureSslEncryption.
  ///
  /// In en, this message translates to:
  /// **'Secure 256-bit SSL Encryption'**
  String get secureSslEncryption;

  /// No description provided for @paymentSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Your payment details are encrypted and stored securely.'**
  String get paymentSecurityNote;

  /// No description provided for @bankAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Details'**
  String get bankAccountDetails;

  /// No description provided for @holderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name as per bank records'**
  String get holderNameHint;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HDFC Bank, SBI'**
  String get bankNameHint;

  /// No description provided for @enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your account number'**
  String get enterAccountNumber;

  /// No description provided for @reEnterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Re-enter Account Number'**
  String get reEnterAccountNumber;

  /// No description provided for @confirmAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Confirm your account number'**
  String get confirmAccountNumber;

  /// No description provided for @accountNumbersDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Account numbers do not match'**
  String get accountNumbersDoNotMatch;

  /// No description provided for @ifscHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HDFC0001234'**
  String get ifscHint;

  /// No description provided for @correctDetailsWarning.
  ///
  /// In en, this message translates to:
  /// **'Ensure account details are correct to avoid payment delays.'**
  String get correctDetailsWarning;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllFields;

  /// No description provided for @saveBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Bank Details'**
  String get saveBankDetails;

  /// No description provided for @upiIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. name@okaxis'**
  String get upiIdHint;

  /// No description provided for @reEnterUpiId.
  ///
  /// In en, this message translates to:
  /// **'Re-enter UPI ID'**
  String get reEnterUpiId;

  /// No description provided for @confirmUpiId.
  ///
  /// In en, this message translates to:
  /// **'Confirm your UPI ID'**
  String get confirmUpiId;

  /// No description provided for @upiIdsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'UPI IDs do not match'**
  String get upiIdsDoNotMatch;

  /// No description provided for @upiInstantCreditNote.
  ///
  /// In en, this message translates to:
  /// **'Your payments will be credited to this UPI ID instantly.'**
  String get upiInstantCreditNote;

  /// No description provided for @pleaseEnterUpiId.
  ///
  /// In en, this message translates to:
  /// **'Please enter UPI ID'**
  String get pleaseEnterUpiId;

  /// No description provided for @saveUpi.
  ///
  /// In en, this message translates to:
  /// **'Save UPI'**
  String get saveUpi;

  /// No description provided for @selectNumberToCall.
  ///
  /// In en, this message translates to:
  /// **'Select a number to call'**
  String get selectNumberToCall;

  /// No description provided for @supportLine1.
  ///
  /// In en, this message translates to:
  /// **'Support Line 1'**
  String get supportLine1;

  /// No description provided for @supportLine2.
  ///
  /// In en, this message translates to:
  /// **'Support Line 2'**
  String get supportLine2;

  /// No description provided for @supportLine3.
  ///
  /// In en, this message translates to:
  /// **'Support Line 3'**
  String get supportLine3;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'FREQUENTLY ASKED QUESTIONS'**
  String get frequentlyAskedQuestions;

  /// No description provided for @viewAllFaqs.
  ///
  /// In en, this message translates to:
  /// **'View All FAQs'**
  String get viewAllFaqs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// No description provided for @whatsAppChat.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Chat'**
  String get whatsAppChat;

  /// No description provided for @connectQuickSupport.
  ///
  /// In en, this message translates to:
  /// **'Connect with us for quick support and queries'**
  String get connectQuickSupport;

  /// No description provided for @whatsappResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Available 24/7 • Usually replies in 5 mins'**
  String get whatsappResponseTime;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'CONTACT INFORMATION'**
  String get contactInformation;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @workingHoursTime.
  ///
  /// In en, this message translates to:
  /// **'Mon - Sun: 09:00 AM - 09:00 PM'**
  String get workingHoursTime;

  /// No description provided for @supportNumbers.
  ///
  /// In en, this message translates to:
  /// **'{number} & more'**
  String supportNumbers(String number);

  /// No description provided for @supportFaqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I withdraw my earnings?'**
  String get supportFaqQuestion1;

  /// No description provided for @supportFaqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your earnings from the Earnings dashboard. Click on Withdraw and choose your preferred method.'**
  String get supportFaqAnswer1;

  /// No description provided for @supportFaqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'What if a customer cancels the job?'**
  String get supportFaqQuestion2;

  /// No description provided for @supportFaqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'If a customer cancels a job within 30 minutes of the start time, you may be eligible for a cancellation fee.'**
  String get supportFaqAnswer2;

  /// No description provided for @supportFaqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'How to update my service locations?'**
  String get supportFaqQuestion3;

  /// No description provided for @supportFaqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Go to Account > Service Settings to update the areas where you want to receive job requests.'**
  String get supportFaqAnswer3;

  /// No description provided for @supportFaqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'How do I change my profile picture?'**
  String get supportFaqQuestion4;

  /// No description provided for @supportFaqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'You can update your profile picture by going to Account > Edit Profile and tapping on the camera icon.'**
  String get supportFaqAnswer4;

  /// No description provided for @supportFaqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'What is the cancellation policy?'**
  String get supportFaqQuestion5;

  /// No description provided for @supportFaqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'Jobs cancelled by the partner may incur a penalty fee. Please refer to our Terms of Service for detailed information.'**
  String get supportFaqAnswer5;

  /// No description provided for @webPermissionsNote.
  ///
  /// In en, this message translates to:
  /// **'Permissions are handled by your browser on Web.'**
  String get webPermissionsNote;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'This permission is required for the app to function properly. Please enable it in the system settings.'**
  String get permissionRequiredNote;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @managePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get managePermissions;

  /// No description provided for @permissionsNote.
  ///
  /// In en, this message translates to:
  /// **'To provide the best experience, OmiBay requires the following permissions.'**
  String get permissionsNote;

  /// No description provided for @backgroundLocation.
  ///
  /// In en, this message translates to:
  /// **'Background Location'**
  String get backgroundLocation;

  /// No description provided for @backgroundLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Allows OmiBay to track your location even when the app is in the background, ensuring you get job requests near you in real-time.'**
  String get backgroundLocationDesc;

  /// No description provided for @batteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization'**
  String get batteryOptimization;

  /// No description provided for @batteryOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Disabling battery optimization for OmiBay ensures you don\'t miss job notifications due to system power-saving restrictions.'**
  String get batteryOptimizationDesc;

  /// No description provided for @displayOverApps.
  ///
  /// In en, this message translates to:
  /// **'Display Over Other Apps'**
  String get displayOverApps;

  /// No description provided for @displayOverAppsDesc.
  ///
  /// In en, this message translates to:
  /// **'Allows OmiBay to show incoming job requests as a pop-up even when you are using other applications.'**
  String get displayOverAppsDesc;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'We collect personal information such as your name, phone number, email address, government-issued identification, and location data to provide our services effectively.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'Your information is used to verify your identity, process payments, connect you with customers, and improve our application experience. We also use location data to send you job requests nearby.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Sharing'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Content.
  ///
  /// In en, this message translates to:
  /// **'We share necessary information (like your name and location) with customers when you accept their job requests. We do not sell your personal data to third-party marketing companies.'**
  String get privacySection3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Security'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures to protect your data from unauthorized access, alteration, or disclosure. However, no method of transmission over the internet is 100% secure.'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Cookies'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'Our application may use cookies and similar technologies to enhance user experience and analyze app performance.'**
  String get privacySection5Content;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Changes to Policy'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Content.
  ///
  /// In en, this message translates to:
  /// **'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.'**
  String get privacySection6Content;

  /// No description provided for @privacyContact.
  ///
  /// In en, this message translates to:
  /// **'For privacy concerns, contact: privacy@apnakaam.com'**
  String get privacyContact;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @termsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Content.
  ///
  /// In en, this message translates to:
  /// **'By accessing and using the OmiBay Partner app, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you must not use the application.'**
  String get termsSection1Content;

  /// No description provided for @termsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Partner Eligibility'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Content.
  ///
  /// In en, this message translates to:
  /// **'To be a Partner on OmiBay, you must be at least 18 years of age and possess the legal authority to enter into a binding agreement. You must provide accurate and complete documentation for verification.'**
  String get termsSection2Content;

  /// No description provided for @termsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Service Standards'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Content.
  ///
  /// In en, this message translates to:
  /// **'Partners are expected to maintain high-quality service standards. This includes punctuality, professional conduct, and adherence to safety guidelines during job execution.'**
  String get termsSection3Content;

  /// No description provided for @termsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Payment & Fees'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Content.
  ///
  /// In en, this message translates to:
  /// **'Payments are processed after job completion and verification. OmiBay reserves the right to deduct a service commission from the total job value as per the agreed commission structure.'**
  String get termsSection4Content;

  /// No description provided for @termsSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Account Security'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account credentials. Any activity occurring under your account is your sole responsibility.'**
  String get termsSection5Content;

  /// No description provided for @termsSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Termination'**
  String get termsSection6Title;

  /// No description provided for @termsSection6Content.
  ///
  /// In en, this message translates to:
  /// **'OmiBay reserves the right to suspend or terminate your account for violations of these terms, poor service ratings, or fraudulent activities.'**
  String get termsSection6Content;

  /// No description provided for @termsCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 OmiBay Technologies Pvt Ltd.'**
  String get termsCopyright;

  /// No description provided for @suspensionPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Suspension Policy'**
  String get suspensionPolicyTitle;

  /// No description provided for @suspensionPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get suspensionPurposeTitle;

  /// No description provided for @suspensionPurposeContent.
  ///
  /// In en, this message translates to:
  /// **'This policy explains when and why a partner account can be suspended, either temporarily or permanently, to ensure service quality, user safety, and platform trust.'**
  String get suspensionPurposeContent;

  /// No description provided for @suspensionTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Types of Suspension'**
  String get suspensionTypesTitle;

  /// No description provided for @suspensionTypesContent.
  ///
  /// In en, this message translates to:
  /// **'1. Temporary Suspension: A partner may be suspended for a limited period (3 days, 7 days, 15 days, or 30 days) depending on the severity of the issue.\n\n2. Permanent Suspension: A partner may be permanently removed from the platform with no option to rejoin.'**
  String get suspensionTypesContent;

  /// No description provided for @suspensionTempReasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reasons for Temporary Suspension'**
  String get suspensionTempReasonsTitle;

  /// No description provided for @suspensionTempReasonsContent.
  ///
  /// In en, this message translates to:
  /// **'A partner may face temporary suspension if they:\n• Frequently cancel accepted bookings without valid reasons.\n• Arrive late repeatedly or fail to complete assigned jobs.\n• Receive multiple customer complaints about behavior, hygiene, or professionalism.\n• Overcharge customers or demand extra payment outside the app.\n• Use abusive, rude, or inappropriate language with customers.\n• Share incorrect service information or misrepresent skills.\n• Maintain consistently low ratings below platform standards.\n• Violate platform guidelines for the first time.'**
  String get suspensionTempReasonsContent;

  /// No description provided for @suspensionTempActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Action (Temporary)'**
  String get suspensionTempActionTitle;

  /// No description provided for @suspensionTempActionContent.
  ///
  /// In en, this message translates to:
  /// **'The partner account will be suspended for a defined period. Training or re-verification may be required before reactivation.'**
  String get suspensionTempActionContent;

  /// No description provided for @suspensionPermReasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reasons for Permanent Suspension'**
  String get suspensionPermReasonsTitle;

  /// No description provided for @suspensionPermReasonsContent.
  ///
  /// In en, this message translates to:
  /// **'A partner will be permanently suspended if they:\n• Commit fraud such as fake bookings or reviews.\n• Harass, threaten, or physically harm customers or staff.\n• Engage in illegal activities while using the platform.\n• Share customer personal data without consent.\n• Use fake documents or false verification details.\n• Bypass platform payments or redirect customers off-platform.\n• Repeatedly violate policies after multiple warnings.\n• Cause intentional damage to customer property.'**
  String get suspensionPermReasonsContent;

  /// No description provided for @suspensionPermActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Action (Permanent)'**
  String get suspensionPermActionTitle;

  /// No description provided for @suspensionPermActionContent.
  ///
  /// In en, this message translates to:
  /// **'Immediate account termination. Outstanding payments may be withheld as per policy. Re-registration is not allowed.'**
  String get suspensionPermActionContent;

  /// No description provided for @suspensionNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspension Notification'**
  String get suspensionNotifyTitle;

  /// No description provided for @suspensionNotifyContent.
  ///
  /// In en, this message translates to:
  /// **'Partners will be notified via app notification, email, or SMS with reason and duration.'**
  String get suspensionNotifyContent;

  /// No description provided for @suspensionAppealTitle.
  ///
  /// In en, this message translates to:
  /// **'Appeal Process'**
  String get suspensionAppealTitle;

  /// No description provided for @suspensionAppealContent.
  ///
  /// In en, this message translates to:
  /// **'Partners may appeal within 7 days with valid proof. Final decision rests with the platform.'**
  String get suspensionAppealContent;

  /// No description provided for @suspensionReactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivation Policy'**
  String get suspensionReactivateTitle;

  /// No description provided for @suspensionReactivateContent.
  ///
  /// In en, this message translates to:
  /// **'Temporary suspensions require review, training, or probation before reactivation.'**
  String get suspensionReactivateContent;

  /// No description provided for @suspensionFinalNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Final Note'**
  String get suspensionFinalNoteTitle;

  /// No description provided for @suspensionFinalNoteContent.
  ///
  /// In en, this message translates to:
  /// **'The platform reserves the right to suspend or terminate accounts to protect customers and platform integrity.'**
  String get suspensionFinalNoteContent;

  /// No description provided for @suspensionContact.
  ///
  /// In en, this message translates to:
  /// **'For any queries, contact: support@omibay.com'**
  String get suspensionContact;

  /// No description provided for @pauseWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause Work'**
  String get pauseWorkTitle;

  /// No description provided for @pauseWorkReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for pausing the work:'**
  String get pauseWorkReasonPrompt;

  /// No description provided for @reasonNeedMaterials.
  ///
  /// In en, this message translates to:
  /// **'Need more materials'**
  String get reasonNeedMaterials;

  /// No description provided for @reasonHealthEmergency.
  ///
  /// In en, this message translates to:
  /// **'Health emergency'**
  String get reasonHealthEmergency;

  /// No description provided for @reasonCustomerRequested.
  ///
  /// In en, this message translates to:
  /// **'Customer requested pause'**
  String get reasonCustomerRequested;

  /// No description provided for @reasonLunchBreak.
  ///
  /// In en, this message translates to:
  /// **'Lunch/Break'**
  String get reasonLunchBreak;

  /// No description provided for @workPaused.
  ///
  /// In en, this message translates to:
  /// **'Work Paused'**
  String get workPaused;

  /// No description provided for @confirmPause.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pause'**
  String get confirmPause;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @enterOtpInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 4-digit OTP shown on the customer\'s booking details screen to start work.'**
  String get enterOtpInstruction;

  /// No description provided for @workStartedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Work started successfully!'**
  String get workStartedSuccess;

  /// No description provided for @invalidOtpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOtpTryAgain;

  /// No description provided for @verifyAndStart.
  ///
  /// In en, this message translates to:
  /// **'Verify & Start'**
  String get verifyAndStart;

  /// No description provided for @jobDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetailsTitle;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onTheWay;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @customerReview.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER REVIEW'**
  String get customerReview;

  /// No description provided for @excellentServiceMock.
  ///
  /// In en, this message translates to:
  /// **'Excellent service! The partner arrived on time and did a very thorough job. Highly recommended for home cleaning services.'**
  String get excellentServiceMock;

  /// No description provided for @serviceSchedule.
  ///
  /// In en, this message translates to:
  /// **'SERVICE SCHEDULE'**
  String get serviceSchedule;

  /// No description provided for @reachLocationEarly.
  ///
  /// In en, this message translates to:
  /// **'Important: Please reach the location 10 minutes before the scheduled time.'**
  String get reachLocationEarly;

  /// No description provided for @customerDetailsAndSpecification.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER DETAILS & SERVICE SPECIFICATION'**
  String get customerDetailsAndSpecification;

  /// No description provided for @serviceLocation.
  ///
  /// In en, this message translates to:
  /// **'SERVICE LOCATION'**
  String get serviceLocation;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @mockCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Rahul Sharma'**
  String get mockCustomerName;

  /// No description provided for @mockLocation.
  ///
  /// In en, this message translates to:
  /// **'Bellandur, Bangalore'**
  String get mockLocation;

  /// No description provided for @mockFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Flat 402, Green Glen Layout, Bellandur, Bangalore'**
  String get mockFullAddress;

  /// No description provided for @mockScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for 12 Jan, 10:00 AM'**
  String get mockScheduledTime;

  /// No description provided for @appVersionValue.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersionValue;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @jobPayment.
  ///
  /// In en, this message translates to:
  /// **'Job Payment'**
  String get jobPayment;

  /// No description provided for @manualTransaction.
  ///
  /// In en, this message translates to:
  /// **'Manual Transaction'**
  String get manualTransaction;

  /// No description provided for @paymentTransaction.
  ///
  /// In en, this message translates to:
  /// **'Payment transaction'**
  String get paymentTransaction;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'₹'**
  String get currencySymbol;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayLabel(String number);

  /// No description provided for @earningsForDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Day {day}: {amount}'**
  String earningsForDayTooltip(String day, String amount);

  /// No description provided for @transactionDefault.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionDefault;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @jobWithService.
  ///
  /// In en, this message translates to:
  /// **'Job: {service}'**
  String jobWithService(Object service);

  /// No description provided for @tipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip Amount'**
  String get tipAmount;

  /// No description provided for @referralShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join OmiBay Partner app and use my code {code} to earn rewards! Download now: https://omibay.com/join'**
  String referralShareMessage(Object code);

  /// No description provided for @accountNumberMask.
  ///
  /// In en, this message translates to:
  /// **'XXXX XXXX {last4}'**
  String accountNumberMask(Object last4);

  /// No description provided for @mockPartnerId.
  ///
  /// In en, this message translates to:
  /// **'#AP12345'**
  String get mockPartnerId;

  /// No description provided for @mockPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'+91 99999 99999'**
  String get mockPhoneNumber;

  /// No description provided for @placeholderPhotoUrl.
  ///
  /// In en, this message translates to:
  /// **'https://via.placeholder.com/150'**
  String get placeholderPhotoUrl;

  /// No description provided for @quickAmount1.
  ///
  /// In en, this message translates to:
  /// **'500'**
  String get quickAmount1;

  /// No description provided for @quickAmount2.
  ///
  /// In en, this message translates to:
  /// **'1000'**
  String get quickAmount2;

  /// No description provided for @quickAmount3.
  ///
  /// In en, this message translates to:
  /// **'2000'**
  String get quickAmount3;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@omibay.com'**
  String get supportEmail;

  /// No description provided for @whatsappSupportNumber.
  ///
  /// In en, this message translates to:
  /// **'918016867006'**
  String get whatsappSupportNumber;

  /// No description provided for @supportNumber1.
  ///
  /// In en, this message translates to:
  /// **'+91 8016867006'**
  String get supportNumber1;

  /// No description provided for @supportNumber2.
  ///
  /// In en, this message translates to:
  /// **'+91 8967429449'**
  String get supportNumber2;

  /// No description provided for @supportNumber3.
  ///
  /// In en, this message translates to:
  /// **'+91 73188 47545'**
  String get supportNumber3;

  /// No description provided for @transactionIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'#TXN'**
  String get transactionIdPrefix;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
