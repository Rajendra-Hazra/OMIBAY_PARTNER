// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OmiBay Partner';

  @override
  String get indiaCountryCode => '+91';

  @override
  String get welcomeBackPartnerMock => 'Welcome back, Partner (Mock)!';

  @override
  String get onScheduledTime => 'On Scheduled Time';

  @override
  String get earning => 'Earning';

  @override
  String get rating => 'Rating';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get updatePhone => 'Update Phone';

  @override
  String get updateEmail => 'Update Email';

  @override
  String get newPhoneNumber => 'New Phone Number';

  @override
  String get newEmailAddress => 'New Email Address';

  @override
  String get pleaseEnterValid10DigitNumber =>
      'Please enter valid 10-digit number';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get otpSentSuccessfully => 'OTP sent successfully (Demo: 123456)';

  @override
  String get phoneUpdatedSuccessfully => 'Phone updated successfully!';

  @override
  String get emailUpdatedSuccessfully => 'Email updated successfully!';

  @override
  String get invalidOtpDemo => 'Invalid OTP. Use 123456 for demo.';

  @override
  String get confirmChange => 'Confirm Change';

  @override
  String get sendVerificationCode => 'Send Verification Code';

  @override
  String get fullName => 'Full Name';

  @override
  String get age => 'Age';

  @override
  String get address => 'Address';

  @override
  String get requiredFields => 'Required Fields';

  @override
  String get pleaseFillRequiredFields =>
      'Please fill in the following required fields:';

  @override
  String get profileSavedSuccessfully => 'Profile saved successfully!';

  @override
  String errorSavingProfile(Object error) {
    return 'Error saving profile: $error';
  }

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String enterOtpSentTo(Object type) {
    return 'Enter the 6-digit code sent to your new $type.';
  }

  @override
  String enterNewToReceiveCode(Object type) {
    return 'Enter your new $type below to receive a verification code.';
  }

  @override
  String get optional => '(Optional)';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get enterYourAge => 'Enter your age';

  @override
  String get exampleEmail => 'example@email.com';

  @override
  String get enterYourFullAddress => 'Enter your full address';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get verify => 'Verify';

  @override
  String get pleaseVerifyMobileToContinue =>
      'Please verify your mobile number to continue';

  @override
  String get pleaseEnterValid10DigitMobile =>
      'Please enter a valid 10-digit mobile number';

  @override
  String otpSentToWithDemo(Object phone) {
    return 'OTP sent to +91 $phone (Demo: 123456)';
  }

  @override
  String get verifyMobileNumber => 'Verify Mobile Number';

  @override
  String otpSentTo(Object phone) {
    return 'OTP sent to +91 $phone';
  }

  @override
  String get demoOtp => 'Demo OTP: 123456';

  @override
  String get mobileNumberVerifiedSuccessfully =>
      'Mobile number verified successfully!';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get appSlogan => 'Own Work. Own Boss';

  @override
  String get continuingToLogin => 'Continuing to login..';

  @override
  String get welcomePartner => 'Welcome Partner';

  @override
  String get welcome => 'Welcome';

  @override
  String get partner => 'Partner';

  @override
  String get loginSubtitle => 'Login to manage your service business';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberMustStartWith =>
      'Phone number must start with 6, 7, 8, or 9';

  @override
  String get phoneNumberMustBe10Digits => 'Phone number must be 10 digits';

  @override
  String get invalidPhoneFormat => 'Invalid phone number format';

  @override
  String get sendOtpToPhoneNumber => 'Send OTP to Phone Number';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get findMyAccount => 'Find my account';

  @override
  String get devSkipToVerification => 'Dev: Skip to Verification';

  @override
  String get enterOtp => 'Enter 6-digit OTP';

  @override
  String sentTo(String phoneNumber) {
    return 'Sent to +91 $phoneNumber';
  }

  @override
  String get backToPhoneNumber => 'Back to phone number';

  @override
  String get verifyAndContinue => 'Verify & Continue';

  @override
  String get didntReceiveOtp => 'Didn\'t receive OTP?';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendIn(String seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get selectYourAccount => 'Select your account';

  @override
  String get accountRecovered => 'Account Recovered';

  @override
  String get accountVerifiedSuccess =>
      'Your account has been successfully verified.';

  @override
  String get goToDashboard => 'Go to Dashboard';

  @override
  String get byContinyingYouAgree => 'By continuing, you agree to our';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get findMyAccountTitle => 'Find My Account';

  @override
  String get enterRegisteredInfo =>
      'Enter your registered information to find your account';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterPhoneNumber => 'Please enter a phone number';

  @override
  String get enterEmailAddress => 'Please enter an email address';

  @override
  String get accountFound => 'Account Found (Mock)';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get chatWithSupport => 'Chat with Support';

  @override
  String get whatsAppSupport => 'WhatsApp Support';

  @override
  String get accountIssueAndFaq => 'Account Issue & FAQ';

  @override
  String get commonQuestionsAndAccountHelp =>
      'Common questions and account help';

  @override
  String get signOutOfYourAccount => 'Sign out of your account';

  @override
  String get couldNotLaunchWhatsApp => 'Could not launch WhatsApp';

  @override
  String get documentVerification => 'Document Verification';

  @override
  String get signingUpTo => 'Signing up to';

  @override
  String get heresWhatYouNeedToDo =>
      'Here\'s what you need to do set up your account';

  @override
  String get profile => 'Profile';

  @override
  String get aadharCard => 'Aadhar Card';

  @override
  String get panCardOptional => 'PAN Card (Optional)';

  @override
  String get drivingLicenseOptional => 'Driving License (Optional)';

  @override
  String get workVerification => 'Work Verification';

  @override
  String get permission => 'Permission';

  @override
  String get skipForNowDevMode => 'Skip for now (Dev Mode)';

  @override
  String get pendingForVerification => 'Pending for verification';

  @override
  String get locationSelection => 'Location Selection';

  @override
  String get confirmLocationToEarn => 'Confirm the location you want to earn';

  @override
  String get searchForLocation => 'Search for location...';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get selected => 'Selected';

  @override
  String get whyWeNeedLocation => 'Why we need your location?';

  @override
  String get locationExplanation =>
      'Your location helps us connect you with nearby customers, ensure timely service delivery, and maximize your earning potential by reducing travel time.';

  @override
  String get useThisLocationForEarning => 'Use this location for earning';

  @override
  String get fetchingYourLocation => 'Fetching your location...';

  @override
  String get locationPermissionsDenied =>
      'Location permissions are permanently denied. Please enable them in settings.';

  @override
  String get unknown => 'Unknown';

  @override
  String get notAvailable => 'N/A';

  @override
  String get lessThanOneYear => '< 1 Yr';

  @override
  String get newLabel => 'New';

  @override
  String get aadharCardVerification => 'Aadhar Card Verification';

  @override
  String get enterAadharDetails => 'Enter Aadhar Details';

  @override
  String get fillAadharInfo => 'Fill in your Aadhar card information';

  @override
  String get aadharNumber => 'Aadhar Number';

  @override
  String get fullNameAsPerAadhar => 'Full Name (as per Aadhar)';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get uploadAadharCard => 'Upload Aadhar Card';

  @override
  String get uploadClearPhotos => 'Upload clear photos of both sides';

  @override
  String get frontSide => 'Front Side';

  @override
  String get backSide => 'Back Side';

  @override
  String get frontSidePhoto => 'Front Side Photo';

  @override
  String get backSidePhoto => 'Back Side Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get submitAndContinue => 'Submit & Continue';

  @override
  String get sample => 'Sample';

  @override
  String get sampleAadharCard => 'Sample Aadhar Card';

  @override
  String get aadharShouldLookLikeThis =>
      'Your Aadhar card should look like this. Make sure the photo is clear and all details are visible.';

  @override
  String get aadharDetailsSaved => 'Aadhar details saved successfully!';

  @override
  String get errorSavingData => 'Error saving data:';

  @override
  String get errorPickingImage => 'Error picking image:';

  @override
  String get couldNotLoadSample => 'Could not load sample';

  @override
  String get requestingCameraAccess => 'Requesting Camera Access...';

  @override
  String get cameraPermissionRequired => 'Camera permission is required';

  @override
  String get galleryPermissionRequired =>
      'Gallery permission is required to select photos';

  @override
  String get uploaded => 'Uploaded';

  @override
  String uploadedWithTitle(Object title) {
    return '$title Uploaded';
  }

  @override
  String get view => 'View';

  @override
  String get change => 'Change';

  @override
  String get uploadText => 'Upload';

  @override
  String get tapToCaptureOrSelect => 'Tap to capture or select';

  @override
  String get preview => 'Preview';

  @override
  String get panCardVerification => 'PAN Card Verification';

  @override
  String get enterPanDetails => 'Enter PAN Details';

  @override
  String get fillPanInfo => 'Fill in your PAN card information';

  @override
  String get panNumber => 'PAN Number';

  @override
  String get fullNameAsPerPan => 'Full Name (as per PAN)';

  @override
  String get enterNameAsOnPan => 'Enter your name as on PAN card';

  @override
  String get uploadPanCard => 'Upload PAN Card';

  @override
  String get samplePanCard => 'Sample PAN Card';

  @override
  String get panShouldLookLikeThis =>
      'Your PAN card should look like this. Make sure all details are visible.';

  @override
  String get panDetailsSaved => 'PAN details saved successfully!';

  @override
  String get panCardPreview => 'PAN Card Preview';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get drivingLicenseVerification => 'Driving License Verification';

  @override
  String get enterDlDetails => 'Enter DL Details';

  @override
  String get fillDlInfo => 'Fill in your driving license information';

  @override
  String get dlNumber => 'DL Number';

  @override
  String get fullNameAsPerDl => 'Full Name (as per DL)';

  @override
  String get enterNameAsOnDl => 'Enter your name as on driving license';

  @override
  String get uploadDrivingLicense => 'Upload Driving License';

  @override
  String get sampleDrivingLicense => 'Sample Driving License';

  @override
  String get dlShouldLookLikeThis =>
      'Your Driving License should look like this. Make sure all details are visible.';

  @override
  String get dlDetailsSaved => 'Driving License details saved successfully!';

  @override
  String get close => 'Close';

  @override
  String get selectServices => 'Select Your Services';

  @override
  String get chooseServicesToOffer => 'Choose the services you want to offer';

  @override
  String get plumber => 'Plumber';

  @override
  String get electrician => 'Electrician';

  @override
  String get carpenter => 'Carpenter';

  @override
  String get gardening => 'Gardening';

  @override
  String get cleaning => 'Cleaning';

  @override
  String get menSalon => 'Men Salon';

  @override
  String get womenSalon => 'Women Salon';

  @override
  String get makeupAndBeauty => 'Makeup & Beauty';

  @override
  String get quickTransport => 'Quick Transport';

  @override
  String get appliancesRepair => 'Appliances Repair & Replacement';

  @override
  String get ac => 'AC';

  @override
  String get airCooler => 'Air Cooler';

  @override
  String get chimney => 'Chimney';

  @override
  String get geyser => 'Geyser';

  @override
  String get laptop => 'Laptop';

  @override
  String get refrigerator => 'Refrigerator';

  @override
  String get washingMachine => 'Washing Machine';

  @override
  String get microwave => 'Microwave';

  @override
  String get television => 'Television';

  @override
  String get waterPurifier => 'Water Purifier';

  @override
  String get details => 'Details';

  @override
  String get totalExperience => 'Total Experience (Years)';

  @override
  String get specialSkills => 'Special Skills';

  @override
  String get workVideo => 'Work Video (30s - 1min)';

  @override
  String get selectVideoSource => 'Select Video Source';

  @override
  String get files => 'Files';

  @override
  String get videoPreview => 'Video Preview';

  @override
  String get videoMustBeBetween =>
      'Video must be between 5 seconds and 1 minute';

  @override
  String get videoUploadedSuccessfully => 'Video uploaded successfully!';

  @override
  String get workVerificationSaved =>
      'Work verification details saved successfully!';

  @override
  String get serviceSubmittedForVerification =>
      'Service submitted for verification! We will notify you once approved.';

  @override
  String get workSelection => 'Work Selection';

  @override
  String get selectServicesProvide => 'Select the services you provide';

  @override
  String countSelected(Object count) {
    return '$count selected';
  }

  @override
  String serviceDetails(Object name) {
    return '$name Details';
  }

  @override
  String get uploadServiceVideo => 'Upload Service Video';

  @override
  String get minMaxVideoDuration => 'Min 30s - Max 1min';

  @override
  String get selectAppliancesRepair => 'Select appliances you can repair:';

  @override
  String get aadharHint => 'XXXX XXXX XXXX';

  @override
  String get panHint => 'ABCDE1234F';

  @override
  String get dlHint => 'KA0120200012345';

  @override
  String get dobHint => 'DD/MM/YYYY';

  @override
  String get experienceHint => 'e.g., 5';

  @override
  String get skillsHint => 'e.g., Industrial Wiring';

  @override
  String get home => 'Home';

  @override
  String get jobs => 'Jobs';

  @override
  String get earnings => 'Earnings';

  @override
  String get account => 'Account';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get activeJobs => 'Active Jobs';

  @override
  String get noActiveJobs => 'No active jobs';

  @override
  String get goOnlineToReceiveJobs => 'Go online to receive jobs!';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get viewDetails => 'View Details';

  @override
  String get payNow => 'Pay Now';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get upiWithdraw => 'UPI Withdraw';

  @override
  String get addBankAccountDetails => 'First add your bank account details';

  @override
  String get addUpiId => 'Add UPI ID';

  @override
  String get add => 'Add';

  @override
  String withdrawVia(String method) {
    return 'Withdraw via $method';
  }

  @override
  String get enterAmountToWithdraw => 'Enter amount to withdraw:';

  @override
  String availableBalanceWithAmount(String amount) {
    return 'Available balance: ₹$amount';
  }

  @override
  String get invalidAmountOrInsufficientBalance =>
      'Invalid amount or insufficient balance';

  @override
  String withdrawalWithMethod(Object method) {
    return 'Withdrawal ($method)';
  }

  @override
  String get transferToPersonalAccount => 'Transfer to personal account';

  @override
  String get personalAccount => 'Personal Account';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String get withdrawalProcessed => 'Withdrawal request processed!';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get enterAmountToAddOrPay => 'Enter amount to add or pay:';

  @override
  String get quickAmounts => 'Quick Amounts:';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get dueAmountPaid => 'Due Amount Paid';

  @override
  String get paymentForPlatformFees => 'Payment for platform fees';

  @override
  String get paymentProcessedSuccessfully => 'Payment processed successfully!';

  @override
  String get proceedToPay => 'Proceed to Pay';

  @override
  String get tips => 'Tips';

  @override
  String get orders => 'Orders';

  @override
  String totalForMonth(String month) {
    return 'Total for $month';
  }

  @override
  String earningsForMonthAndDay(String month, String day) {
    return 'Earnings for $month $day';
  }

  @override
  String get incentivesAndOffers => 'Incentives & Offers';

  @override
  String get weeklyBonusChallenge => 'Weekly Bonus Challenge';

  @override
  String get weeklyBonusSubtitle => 'Complete 15 jobs to earn ₹500 extra';

  @override
  String jobsDoneWithProgress(String count) {
    return '$count/15 Jobs Done';
  }

  @override
  String potentialEarnings(String amount) {
    return '₹$amount potential';
  }

  @override
  String referAndEarnWithAmount(String amount) {
    return 'Refer & Earn ₹$amount';
  }

  @override
  String get referSubtitle => 'Invite your friends to join OmiBay Partner';

  @override
  String get invite => 'Invite';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get referAndEarn => 'Refer & Earn';

  @override
  String get referHeroTitle => 'Refer a Friend & Earn ₹200';

  @override
  String get referHeroSubtitle =>
      'Earn reward credits for every successful partner onboarding.';

  @override
  String get yourReferralCode => 'YOUR REFERRAL CODE';

  @override
  String get codeCopied => 'Code copied to clipboard!';

  @override
  String get howItWorks => 'HOW IT WORKS';

  @override
  String get step1Title => 'Invite Friends';

  @override
  String get step1Desc =>
      'Share your referral code with friends looking for service jobs.';

  @override
  String get step2Title => 'Onboarding';

  @override
  String get step2Desc =>
      'They register as a partner and complete document verification.';

  @override
  String get step3Title => 'Earn Rewards';

  @override
  String get step3Desc =>
      'Once they complete their 5th job, you get ₹200 in your wallet.';

  @override
  String get totalReferrals => 'Total Referrals';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get shareCode => 'Share Code';

  @override
  String get referralTermsTitle => 'Referral Terms & Conditions';

  @override
  String get referralTermsPoint1 =>
      '1. The referral reward is ₹200 for each successful partner onboarding.';

  @override
  String get referralTermsPoint2 =>
      '2. The reward is credited only after the referred partner completes their first 5 successful jobs.';

  @override
  String get referralTermsPoint3 =>
      '3. The referred partner must use your unique referral code during registration.';

  @override
  String get referralTermsPoint4 =>
      '4. Referral rewards are subject to verification and may be reversed in case of fraudulent activity.';

  @override
  String get referralTermsPoint5 =>
      '5. OmiBay reserves the right to modify or terminate the referral program at any time without prior notice.';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get paymentCredited => 'Payment Credited';

  @override
  String get feeDeducted => 'Fee Deducted';

  @override
  String get onlinePayment => 'Online Payment';

  @override
  String get cashPayAfterService => 'Cash (Pay After Service)';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get jobReference => 'Job Reference';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get description => 'Description';

  @override
  String get earningsBreakdown => 'EARNINGS BREAKDOWN';

  @override
  String get totalJobPrice => 'Total Job Price';

  @override
  String get serviceAmountExclTip => 'Service Amount (excl. tip)';

  @override
  String get gst => 'GST (5%)';

  @override
  String get platformFee => 'Platform Fee (20%)';

  @override
  String get tipToPartner => 'Tip (100% to Partner)';

  @override
  String get yourNetEarning => 'Your Net Earning';

  @override
  String get cashPaymentNote => 'Cash Payment Note';

  @override
  String collectedCashFromCustomer(String amount) {
    return 'You collected ₹$amount in cash from customer.';
  }

  @override
  String amountDueToOmiBay(String amount) {
    return 'Amount due to OmiBay: ₹$amount';
  }

  @override
  String get noTransactionHistoryFound => 'No transaction history found';

  @override
  String get exportHistory => 'Export History';

  @override
  String get processed => 'Processed';

  @override
  String get deducted => 'Deducted';

  @override
  String get activeJob => 'Active Job';

  @override
  String get totalDuration => 'TOTAL DURATION';

  @override
  String get jobInProgress => 'Job in Progress';

  @override
  String get serviceChecklist => 'SERVICE CHECKLIST';

  @override
  String get afterServicePhotos => 'AFTER SERVICE PHOTOS';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get howCanWeHelp => 'How can we help you?';

  @override
  String get chatNow => 'Chat Now';

  @override
  String get callNow => 'Call Now';

  @override
  String get couldNotLaunchDialer => 'Could not launch phone dialer';

  @override
  String get jobCompleted => 'Job Completed!';

  @override
  String earnedFromJob(String amount) {
    return 'You have earned ₹$amount from this job.';
  }

  @override
  String get amountCreditedToWallet => 'Amount credited to wallet';

  @override
  String get cashCollectedFeeDeducted =>
      'Cash collected - Platform fee deducted';

  @override
  String get customerRating => 'Customer Rating';

  @override
  String get ratingGivenByCustomer =>
      'Rating given by customer for your service';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get resumeWork => 'Resume Work';

  @override
  String get pauseWork => 'Pause Work';

  @override
  String get workResumed => 'Work Resumed';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get startJourney => 'Start Journey';

  @override
  String get arrived => 'Arrived';

  @override
  String get startWork => 'Start Work';

  @override
  String get completeJobQuestion => 'Complete Job?';

  @override
  String get completeJobConfirmation =>
      'Please confirm that the job is completed successfully.';

  @override
  String get receiveMoney => 'Receive Money';

  @override
  String get completionProof => 'COMPLETION PROOF';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get addVideo => 'Add Video';

  @override
  String get min10Sec => 'min 10 sec';

  @override
  String get prepaid => 'Prepaid';

  @override
  String get cash => 'Cash';

  @override
  String get showQr => 'Show QR';

  @override
  String get confirm => 'Confirm';

  @override
  String get jobMarkedAsCompleted => 'Job marked as completed!';

  @override
  String get scanToPay => 'Scan to Pay';

  @override
  String get scanToPayInstructions =>
      'Please ask the customer to scan this QR code to complete the payment.';

  @override
  String get totalAmountToPay => 'Total Amount to Pay';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String bookingId(Object id) {
    return 'Booking ID: $id';
  }

  @override
  String get fullHomeCleaning => 'Full Home Cleaning';

  @override
  String get kitchenDeepClean => 'Kitchen Deep Clean';

  @override
  String get bathroomSanitization => 'Bathroom Sanitization';

  @override
  String get sofaAndCarpetCleaning => 'Sofa & Carpet Cleaning';

  @override
  String get acServiceAndRepair => 'AC Service & Repair';

  @override
  String get pestControl => 'Pest Control';

  @override
  String get instant => 'Instant';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get awesome => 'AWESOME!';

  @override
  String get noProblem => 'NO PROBLEM';

  @override
  String get jobAccepted => 'JOB ACCEPTED';

  @override
  String get jobDeclined => 'JOB DECLINED';

  @override
  String get goodLuckWithNewMission => 'Good luck with your new mission!';

  @override
  String get takeABreak => 'Take a break, we\'ll bring more soon.';

  @override
  String get todaysPerformance => 'Today\'s Performance';

  @override
  String get business => 'Business';

  @override
  String get jobsDone => 'Jobs Done';

  @override
  String get onlineTime => 'Online Time';

  @override
  String get proTips => 'Pro Tips';

  @override
  String get weeklyChallenge => 'Weekly Challenge';

  @override
  String completeJobsToEarn(String count) {
    return 'Complete $count jobs to unlock bonus';
  }

  @override
  String get inviteFriendsToJoin => 'Invite friends to join OmiBay Partner';

  @override
  String get manageServiceRequests => 'Manage your service requests';

  @override
  String get searchByBookingIdOrService => 'Search by booking ID or service...';

  @override
  String get accepted => 'Accepted';

  @override
  String get completed => 'Completed';

  @override
  String get noJobsFound => 'No jobs found';

  @override
  String get whenYouAcceptJob => 'When you accept a job, it will appear here.';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get availableBalanceLabel => 'Available balance:';

  @override
  String get withdrawalRequestProcessed => 'Withdrawal request processed!';

  @override
  String get firstAddBankAccount => 'First add your bank account details';

  @override
  String get firstAddUpiId => 'First add your UPI ID';

  @override
  String get complete15JobsToEarn => 'Complete 15 jobs to earn ₹500 extra';

  @override
  String jobsDoneCount(String count) {
    return '$count/15 Jobs Done';
  }

  @override
  String get potential => 'potential';

  @override
  String get referAndEarnAmount => 'Refer & Earn ₹200';

  @override
  String get inviteYourFriends => 'Invite your friends to join OmiBay Partner';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get viewAll => 'View All';

  @override
  String get cashPayment => 'Cash Payment';

  @override
  String get myAccount => 'My Account';

  @override
  String get workWithUs => 'Work with Us';

  @override
  String get partnerId => 'Partner ID:';

  @override
  String get myDocuments => 'My Documents';

  @override
  String get myServices => 'My Services';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get accountAndSettings => 'Account & Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get manageLocation => 'Manage Location';

  @override
  String get managePermission => 'Manage Permission';

  @override
  String get settings => 'Settings';

  @override
  String get version => 'Version';

  @override
  String get preferences => 'Preferences';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get bengali => 'Bengali';

  @override
  String get appearances => 'Appearances';

  @override
  String get light => 'Light';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pleaseEnableNotificationPermission =>
      'Please enable notification permission in settings';

  @override
  String get accountSafety => 'Account Safety';

  @override
  String get deactivateAccount => 'Deactivate Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get legalDocuments => 'Legal Documents';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get suspensionPolicy => 'Suspension Policy';

  @override
  String get deactivationWarning =>
      'Deactivating your account is temporary. Your profile will be hidden from customers, but your data will be saved.';

  @override
  String get whyDeactivating => 'Why are you deactivating?';

  @override
  String get reasonBreak => 'Taking a break from the platform';

  @override
  String get reasonNotifications => 'Too many notifications';

  @override
  String get reasonOpportunities => 'Not getting enough job opportunities';

  @override
  String get reasonTechnical => 'Technical issues with the app';

  @override
  String get reasonPrivacy => 'Privacy concerns';

  @override
  String get reasonOther => 'Other';

  @override
  String get pleaseTellMore => 'Please tell us more...';

  @override
  String get whatHappensDeactivate => 'What happens when you deactivate?';

  @override
  String get deactivatePoint1 =>
      'Your profile won\'t be visible on the OmiBay platform.';

  @override
  String get deactivatePoint2 =>
      'You won\'t receive any new job notifications.';

  @override
  String get deactivatePoint3 =>
      'You can reactivate anytime by simply logging back in.';

  @override
  String get deactivatePoint4 =>
      'Ongoing jobs must be completed before deactivation.';

  @override
  String get deactivateMyAccount => 'Deactivate My Account';

  @override
  String get accountDeactivatedSuccess =>
      'Account deactivated successfully. You can reactivate it by logging in again.';

  @override
  String get pleaseSelectReason => 'Please select a reason for deactivation';

  @override
  String get confirmDeactivation => 'Confirm Deactivation';

  @override
  String get areYouSureDeactivate =>
      'Are you sure you want to temporarily deactivate your account?';

  @override
  String get verifyDeactivation => 'Verify Deactivation';

  @override
  String get enterOtpDeactivate =>
      'Please enter the 6-digit OTP sent to your registered mobile number to confirm.';

  @override
  String get otpResent => 'OTP Resent!';

  @override
  String get verifyAndDeactivate => 'Verify & Deactivate';

  @override
  String get deleteAccountCaution =>
      'ACCOUNT SAFETY CAUTION: This action is permanent and irreversible. Your entire professional history on OmiBay will be wiped.';

  @override
  String get sorryToSeeYouGo => 'We\'re sorry to see you go';

  @override
  String get deletingPermanent => 'Deleting your account is permanent:';

  @override
  String get deletePoint1 =>
      'All your personal profile data will be permanently erased.';

  @override
  String get deletePoint2 =>
      'Your entire earning history and transaction logs will be lost.';

  @override
  String get deletePoint3 =>
      'Any pending bonuses or incentives will be forfeited.';

  @override
  String get deletePoint4 =>
      'You will not be able to login or recover this account again.';

  @override
  String get understandIrreversible =>
      'I understand that this action is irreversible and I want to delete my account permanently.';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get changedMyMind => 'I changed my mind, go back';

  @override
  String get accountDeletedSuccess =>
      'Account deleted successfully. We hope to see you back soon!';

  @override
  String get finalWarning => 'Final Warning';

  @override
  String get finalWarningContent =>
      'This is your last chance. Once you click delete, your OmiBay Partner account will be gone forever. Are you absolutely sure?';

  @override
  String get verifyPermanentDeletion => 'Verify Permanent Deletion';

  @override
  String get enterOtpDeletePermanent =>
      'Please enter the 6-digit OTP sent to your registered mobile number to permanently delete your account.';

  @override
  String get searchHelp => 'Search for help...';

  @override
  String get all => 'All';

  @override
  String get categoryAccount => 'Account';

  @override
  String get categoryNotification => 'Notification';

  @override
  String get categoryService => 'Service';

  @override
  String get categoryJobs => 'Jobs';

  @override
  String get categoryPayments => 'Payments';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryAppFeature => 'App Feature';

  @override
  String get docVerificationPrompt =>
      'Most account issues are resolved by completing document verification.';

  @override
  String noResultsFoundFor(Object query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get tryDifferentKeywords => 'Try different keywords or check spelling';

  @override
  String get stillNeedHelp => 'Still Need Help?';

  @override
  String get stillNeedHelpContent =>
      'Please use the Help option in the main app to chat with WhatsApp Support. Our team is available 24/7 to assist you.';

  @override
  String get faqQuestion1 => 'How do I verify my account?';

  @override
  String get faqAnswer1 =>
      'To verify your account, go to the Document Verification screen and upload the required documents: ID Proof (Aadhar/PAN), Address Proof (Utility bill/Bank statement), and Professional Details (Profile photo and experience).';

  @override
  String get faqQuestion2 => 'What documents are required for ID Proof?';

  @override
  String get faqAnswer2 =>
      'We accept Aadhar Card or PAN Card. For Aadhar Card, both front and back sides must be uploaded. Ensure the images are clear and all details are legible.';

  @override
  String get faqQuestion3 => 'What if my documents are rejected?';

  @override
  String get faqAnswer3 =>
      'If your documents are rejected, you will receive a notification with the reason. Common reasons include blurry images, expired documents, or mismatched names. You can re-upload corrected documents immediately.';

  @override
  String get faqQuestion4 => 'How long does the verification process take?';

  @override
  String get faqAnswer4 =>
      'The verification process typically takes 24 to 48 hours. You will receive a notification once your account is verified and ready to accept jobs.';

  @override
  String get faqQuestion5 => 'Can I change my registered phone number?';

  @override
  String get faqAnswer5 =>
      'Yes, you can update your phone number in Account > Profile. You will need to verify the new number with an OTP.';

  @override
  String get faqQuestion6 => 'How do I set up my payment details?';

  @override
  String get faqAnswer6 =>
      'Go to Account > Payment Setup to add your Bank Account or UPI ID. This is where your earnings will be transferred.';

  @override
  String get faqQuestion7 => 'When will I receive my earnings?';

  @override
  String get faqAnswer7 =>
      'Earnings are usually settled within 24-48 hours after you initiate a withdrawal request from the Earnings dashboard.';

  @override
  String get faqQuestion8 => 'I am not receiving job notifications.';

  @override
  String get faqAnswer8 =>
      'Ensure your \"Online\" status is toggled on in the Home screen. Also, check if battery optimization is disabled for the app and all notification permissions are granted.';

  @override
  String get faqQuestion9 => 'How do I add or change my services?';

  @override
  String get faqAnswer9 =>
      'You can update the services you offer by going to Account > My Services. Select or deselect categories based on your expertise.';

  @override
  String get faqQuestion10 =>
      'What to do if a customer cancels at the last minute?';

  @override
  String get faqAnswer10 =>
      'If a customer cancels after you have already reached the location, you may be eligible for a cancellation fee. Contact support through the \"Help\" option for assistance.';

  @override
  String get faqQuestion11 => 'How do I use the Opportunity Map?';

  @override
  String get faqAnswer11 =>
      'The Opportunity Map shows high-demand zones in real-time. Move to areas marked in red or orange to increase your chances of receiving job requests.';

  @override
  String get faqQuestion12 => 'What are the photo requirements?';

  @override
  String get faqAnswer12 =>
      'Your profile photo should be a clear, front-facing headshot. Do not wear sunglasses or hats, and ensure the background is neutral.';

  @override
  String get faqQuestion13 => 'How do I logout of the app?';

  @override
  String get faqAnswer13 =>
      'You can logout by scrolling to the bottom of the Account screen and tapping the \"Logout\" button.';

  @override
  String get faqQuestion14 => 'How do I contact support for a live job?';

  @override
  String get faqAnswer14 =>
      'For active jobs, use the \"Help\" icon on the job screen to directly chat with our support team or call our helpline.';

  @override
  String get notUploaded => 'Not Uploaded';

  @override
  String get underReview => 'Under Review';

  @override
  String get partialUpload => 'Partial Upload';

  @override
  String get cannotRemove => 'Cannot Remove';

  @override
  String get mustHaveOneService =>
      'You must have at least one verified service to receive jobs.';

  @override
  String toSwitchServices(Object serviceName) {
    return 'To switch services:\n1. First verify a new service\n2. Then remove \"$serviceName\"';
  }

  @override
  String get verifyNewService => 'Verify New Service';

  @override
  String removeServiceConfirm(Object serviceName) {
    return 'Are you sure you want to remove \"$serviceName\" service?\n\nThis will delete your verification data including experience and video. You will need to verify again to add this service.';
  }

  @override
  String get noVerifiedServices => 'No Verified Services';

  @override
  String get verifyAtLeastOneService =>
      'You need to verify at least one service before you can start receiving jobs. Verify your skills now!';

  @override
  String get verifyYourServices => 'Verify Your Services';

  @override
  String get activeServices => 'Active Services';

  @override
  String get activeApplianceServices => 'Active Appliance Services';

  @override
  String get verificationPendingNotify =>
      'Verification pending - We will notify you once approved';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get pendingApplianceServices => 'Pending Appliance Services';

  @override
  String get videoUploaded => 'Video uploaded';

  @override
  String get cannotDeletePending =>
      'Cannot delete service while verification is pending';

  @override
  String serviceRemovedSuccess(Object serviceName) {
    return '$serviceName service removed successfully';
  }

  @override
  String errorRemovingService(Object error) {
    return 'Error removing service: $error';
  }

  @override
  String verifiedCount(Object count) {
    return '$count verified';
  }

  @override
  String pendingCount(Object count) {
    return '$count pending';
  }

  @override
  String get cannotDeleteWhilePending => 'Cannot delete while pending';

  @override
  String get addMoreServices => 'Add More Services';

  @override
  String get verifyFirstService => 'Verify Your First Service';

  @override
  String get chatWelcome => 'Hello! How can we help you today?';

  @override
  String get chatResponse =>
      'Thanks for reaching out! An agent will be with you shortly.';

  @override
  String get omibaySupport => 'OmiBay Support';

  @override
  String get appVersion => 'App Version';

  @override
  String get updateLanguage => 'Update Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get notificationJobTitle => 'New Job Request';

  @override
  String get notificationJobBody =>
      'You have a new request for Full Home Cleaning in Bellandur.';

  @override
  String get notificationPaymentTitle => 'Payment Received';

  @override
  String get notificationPaymentBody =>
      'Your earnings of ₹1,499 for job #OK123456 has been credited.';

  @override
  String get notificationSystemTitle => 'Verification Successful';

  @override
  String get notificationSystemBody =>
      'Your document verification is complete. You are now a verified partner.';

  @override
  String get notificationPromoTitle => 'Weekly Bonus!';

  @override
  String get notificationPromoBody =>
      'Complete 5 more jobs this week to earn an extra ₹500.';

  @override
  String get notificationCancelledTitle => 'Job Cancelled';

  @override
  String get notificationCancelledBody =>
      'Customer Rahul Sharma cancelled the request for Home Cleaning.';

  @override
  String get time2MinsAgo => '2 mins ago';

  @override
  String get time1HourAgo => '1 hour ago';

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String get time2DaysAgo => '2 days ago';

  @override
  String get time3DaysAgo => '3 days ago';

  @override
  String get welcomeBack => 'Welcome back, Partner!';

  @override
  String get debugOtpSent => 'DEBUG: OTP sent (Mock: 123456)';

  @override
  String get invalidOtp => 'Invalid OTP (Mock uses 123456)';

  @override
  String get failedToSignIn => 'Failed to sign in:';

  @override
  String earningsForDay(String month, String day) {
    return 'Earnings for $month $day';
  }

  @override
  String get help => 'Help';

  @override
  String get support => 'Support';

  @override
  String get location => 'Location';

  @override
  String get service => 'Service';

  @override
  String get customer => 'Customer';

  @override
  String get price => 'Price';

  @override
  String get tip => 'Tip';

  @override
  String get distance => 'Distance';

  @override
  String get eta => 'ETA';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get newJobRequest => 'New Job Request';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get incomingJob => 'Incoming Job';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get startJob => 'Start Job';

  @override
  String get completeJob => 'Complete Job';

  @override
  String get navigateToCustomer => 'Navigate to Customer';

  @override
  String get callCustomer => 'Call Customer';

  @override
  String get chatWithCustomer => 'Chat with Customer';

  @override
  String get referralCode => 'Referral Code';

  @override
  String get shareReferralCode => 'Share Referral Code';

  @override
  String get copied => 'Copied!';

  @override
  String get totalReferralEarnings => 'Total Referral Earnings';

  @override
  String get withdrawalHistory => 'Withdrawal History';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get amount => 'Amount';

  @override
  String get success => 'Success';

  @override
  String get pending => 'Pending';

  @override
  String get failed => 'Failed';

  @override
  String get documents => 'Documents';

  @override
  String get verified => 'Verified';

  @override
  String get notVerified => 'Not Verified';

  @override
  String get permissions => 'Permissions';

  @override
  String get locationPermission => 'Location Permission';

  @override
  String get cameraPermission => 'Camera Permission';

  @override
  String get storagePermission => 'Storage Permission';

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get permissionGranted => 'Permission Granted';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get faq => 'FAQ';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get opportunityMap => 'Opportunity Map';

  @override
  String get nearbyOpportunities => 'Nearby Opportunities';

  @override
  String get editServices => 'Edit Services';

  @override
  String get addNewService => 'Add New Service';

  @override
  String get paymentSetup => 'Payment Setup';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get upiId => 'UPI ID';

  @override
  String get addBankAccount => 'Add Bank Account';

  @override
  String get accountHolderName => 'Account Holder Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get ifscCode => 'IFSC Code';

  @override
  String get bankName => 'Bank Name';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get areYouSureDelete => 'Are you sure you want to delete this?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get continue_ => 'Continue';

  @override
  String get submit => 'Submit';

  @override
  String get update => 'Update';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get clear => 'Clear';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get more => 'More';

  @override
  String get less => 'Less';

  @override
  String get showMore => 'Show More';

  @override
  String get showLess => 'Show Less';

  @override
  String get seeAll => 'See All';

  @override
  String get noResults => 'No results found';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String minsAway(String mins) {
    return '$mins mins away';
  }

  @override
  String kmAway(String km) {
    return '$km km';
  }

  @override
  String get allProTips => 'All Pro Tips';

  @override
  String get proTip1 => 'Always wear your uniform for better rating.';

  @override
  String get proTip2 => 'Arrive 5 minutes early to the location.';

  @override
  String get proTip3 => 'Take clear photos before and after work.';

  @override
  String get proTip4 => 'Greet the customer with a professional smile.';

  @override
  String get proTip5 => 'Double-check your tools before leaving for a job.';

  @override
  String get proTip6 => 'Maintain high communication during the service.';

  @override
  String get proTip7 => 'Keep your work area clean during and after service.';

  @override
  String get proTip8 => 'Ask for feedback after completing the job.';

  @override
  String get proTip9 => 'Update your status immediately after finishing.';

  @override
  String get proTip10 => 'Stay hydrated and take short breaks between jobs.';

  @override
  String get complete15Jobs => 'Complete 15 jobs';

  @override
  String get earnExtraReward => 'Earn ₹500 extra';

  @override
  String get shareAndEarn => 'Share & Earn';

  @override
  String get goOnlineToStart =>
      'Go online to start receiving job requests in your area.';

  @override
  String setDefaultPayoutMethod(String type) {
    return 'Set as default $type payout method';
  }

  @override
  String get deletePaymentMethodTitle => 'Delete Payment Method?';

  @override
  String deletePaymentMethodConfirm(String type) {
    return 'Are you sure you want to remove this $type?';
  }

  @override
  String get savedOptions => 'SAVED OPTIONS';

  @override
  String get noPaymentMethodSaved => 'No payment method saved';

  @override
  String get bankAccountsLabel => 'Bank Accounts';

  @override
  String accountNumberLabel(String number) {
    return 'A/C: $number';
  }

  @override
  String get upiIdsLabel => 'UPI IDs';

  @override
  String get addNewOption => 'ADD NEW OPTION';

  @override
  String get directTransferToBank => 'Direct transfer to your bank';

  @override
  String get upiAppsSubtitle => 'Google Pay, PhonePe, Paytm etc.';

  @override
  String get secureSslEncryption => 'Secure 256-bit SSL Encryption';

  @override
  String get paymentSecurityNote =>
      'Your payment details are encrypted and stored securely.';

  @override
  String get bankAccountDetails => 'Bank Account Details';

  @override
  String get holderNameHint => 'Full name as per bank records';

  @override
  String get bankNameHint => 'e.g. HDFC Bank, SBI';

  @override
  String get enterAccountNumber => 'Enter your account number';

  @override
  String get reEnterAccountNumber => 'Re-enter Account Number';

  @override
  String get confirmAccountNumber => 'Confirm your account number';

  @override
  String get accountNumbersDoNotMatch => 'Account numbers do not match';

  @override
  String get ifscHint => 'e.g. HDFC0001234';

  @override
  String get correctDetailsWarning =>
      'Ensure account details are correct to avoid payment delays.';

  @override
  String get pleaseFillAllFields => 'Please fill all required fields';

  @override
  String get saveBankDetails => 'Save Bank Details';

  @override
  String get upiIdHint => 'e.g. name@okaxis';

  @override
  String get reEnterUpiId => 'Re-enter UPI ID';

  @override
  String get confirmUpiId => 'Confirm your UPI ID';

  @override
  String get upiIdsDoNotMatch => 'UPI IDs do not match';

  @override
  String get upiInstantCreditNote =>
      'Your payments will be credited to this UPI ID instantly.';

  @override
  String get pleaseEnterUpiId => 'Please enter UPI ID';

  @override
  String get saveUpi => 'Save UPI';

  @override
  String get selectNumberToCall => 'Select a number to call';

  @override
  String get supportLine1 => 'Support Line 1';

  @override
  String get supportLine2 => 'Support Line 2';

  @override
  String get supportLine3 => 'Support Line 3';

  @override
  String get frequentlyAskedQuestions => 'FREQUENTLY ASKED QUESTIONS';

  @override
  String get viewAllFaqs => 'View All FAQs';

  @override
  String get callUs => 'Call Us';

  @override
  String get support247 => '24/7 Support';

  @override
  String get whatsAppChat => 'WhatsApp Chat';

  @override
  String get connectQuickSupport =>
      'Connect with us for quick support and queries';

  @override
  String get whatsappResponseTime =>
      'Available 24/7 • Usually replies in 5 mins';

  @override
  String get contactInformation => 'CONTACT INFORMATION';

  @override
  String get emailUs => 'Email Us';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get workingHoursTime => 'Mon - Sun: 09:00 AM - 09:00 PM';

  @override
  String supportNumbers(String number) {
    return '$number & more';
  }

  @override
  String get supportFaqQuestion1 => 'How do I withdraw my earnings?';

  @override
  String get supportFaqAnswer1 =>
      'You can withdraw your earnings from the Earnings dashboard. Click on Withdraw and choose your preferred method.';

  @override
  String get supportFaqQuestion2 => 'What if a customer cancels the job?';

  @override
  String get supportFaqAnswer2 =>
      'If a customer cancels a job within 30 minutes of the start time, you may be eligible for a cancellation fee.';

  @override
  String get supportFaqQuestion3 => 'How to update my service locations?';

  @override
  String get supportFaqAnswer3 =>
      'Go to Account > Service Settings to update the areas where you want to receive job requests.';

  @override
  String get supportFaqQuestion4 => 'How do I change my profile picture?';

  @override
  String get supportFaqAnswer4 =>
      'You can update your profile picture by going to Account > Edit Profile and tapping on the camera icon.';

  @override
  String get supportFaqQuestion5 => 'What is the cancellation policy?';

  @override
  String get supportFaqAnswer5 =>
      'Jobs cancelled by the partner may incur a penalty fee. Please refer to our Terms of Service for detailed information.';

  @override
  String get webPermissionsNote =>
      'Permissions are handled by your browser on Web.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRequiredNote =>
      'This permission is required for the app to function properly. Please enable it in the system settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get managePermissions => 'Manage Permissions';

  @override
  String get permissionsNote =>
      'To provide the best experience, OmiBay requires the following permissions.';

  @override
  String get backgroundLocation => 'Background Location';

  @override
  String get backgroundLocationDesc =>
      'Allows OmiBay to track your location even when the app is in the background, ensuring you get job requests near you in real-time.';

  @override
  String get batteryOptimization => 'Battery Optimization';

  @override
  String get batteryOptimizationDesc =>
      'Disabling battery optimization for OmiBay ensures you don\'t miss job notifications due to system power-saving restrictions.';

  @override
  String get displayOverApps => 'Display Over Other Apps';

  @override
  String get displayOverAppsDesc =>
      'Allows OmiBay to show incoming job requests as a pop-up even when you are using other applications.';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacySection1Title => '1. Information We Collect';

  @override
  String get privacySection1Content =>
      'We collect personal information such as your name, phone number, email address, government-issued identification, and location data to provide our services effectively.';

  @override
  String get privacySection2Title => '2. How We Use Your Information';

  @override
  String get privacySection2Content =>
      'Your information is used to verify your identity, process payments, connect you with customers, and improve our application experience. We also use location data to send you job requests nearby.';

  @override
  String get privacySection3Title => '3. Data Sharing';

  @override
  String get privacySection3Content =>
      'We share necessary information (like your name and location) with customers when you accept their job requests. We do not sell your personal data to third-party marketing companies.';

  @override
  String get privacySection4Title => '4. Data Security';

  @override
  String get privacySection4Content =>
      'We implement industry-standard security measures to protect your data from unauthorized access, alteration, or disclosure. However, no method of transmission over the internet is 100% secure.';

  @override
  String get privacySection5Title => '5. Cookies';

  @override
  String get privacySection5Content =>
      'Our application may use cookies and similar technologies to enhance user experience and analyze app performance.';

  @override
  String get privacySection6Title => '6. Changes to Policy';

  @override
  String get privacySection6Content =>
      'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.';

  @override
  String get privacyContact =>
      'For privacy concerns, contact: privacy@apnakaam.com';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get termsSection1Title => '1. Acceptance of Terms';

  @override
  String get termsSection1Content =>
      'By accessing and using the OmiBay Partner app, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you must not use the application.';

  @override
  String get termsSection2Title => '2. Partner Eligibility';

  @override
  String get termsSection2Content =>
      'To be a Partner on OmiBay, you must be at least 18 years of age and possess the legal authority to enter into a binding agreement. You must provide accurate and complete documentation for verification.';

  @override
  String get termsSection3Title => '3. Service Standards';

  @override
  String get termsSection3Content =>
      'Partners are expected to maintain high-quality service standards. This includes punctuality, professional conduct, and adherence to safety guidelines during job execution.';

  @override
  String get termsSection4Title => '4. Payment & Fees';

  @override
  String get termsSection4Content =>
      'Payments are processed after job completion and verification. OmiBay reserves the right to deduct a service commission from the total job value as per the agreed commission structure.';

  @override
  String get termsSection5Title => '5. Account Security';

  @override
  String get termsSection5Content =>
      'You are responsible for maintaining the confidentiality of your account credentials. Any activity occurring under your account is your sole responsibility.';

  @override
  String get termsSection6Title => '6. Termination';

  @override
  String get termsSection6Content =>
      'OmiBay reserves the right to suspend or terminate your account for violations of these terms, poor service ratings, or fraudulent activities.';

  @override
  String get termsCopyright => '© 2026 OmiBay Technologies Pvt Ltd.';

  @override
  String get suspensionPolicyTitle => 'Partner Suspension Policy';

  @override
  String get suspensionPurposeTitle => 'Purpose';

  @override
  String get suspensionPurposeContent =>
      'This policy explains when and why a partner account can be suspended, either temporarily or permanently, to ensure service quality, user safety, and platform trust.';

  @override
  String get suspensionTypesTitle => 'Types of Suspension';

  @override
  String get suspensionTypesContent =>
      '1. Temporary Suspension: A partner may be suspended for a limited period (3 days, 7 days, 15 days, or 30 days) depending on the severity of the issue.\n\n2. Permanent Suspension: A partner may be permanently removed from the platform with no option to rejoin.';

  @override
  String get suspensionTempReasonsTitle => 'Reasons for Temporary Suspension';

  @override
  String get suspensionTempReasonsContent =>
      'A partner may face temporary suspension if they:\n• Frequently cancel accepted bookings without valid reasons.\n• Arrive late repeatedly or fail to complete assigned jobs.\n• Receive multiple customer complaints about behavior, hygiene, or professionalism.\n• Overcharge customers or demand extra payment outside the app.\n• Use abusive, rude, or inappropriate language with customers.\n• Share incorrect service information or misrepresent skills.\n• Maintain consistently low ratings below platform standards.\n• Violate platform guidelines for the first time.';

  @override
  String get suspensionTempActionTitle => 'Action (Temporary)';

  @override
  String get suspensionTempActionContent =>
      'The partner account will be suspended for a defined period. Training or re-verification may be required before reactivation.';

  @override
  String get suspensionPermReasonsTitle => 'Reasons for Permanent Suspension';

  @override
  String get suspensionPermReasonsContent =>
      'A partner will be permanently suspended if they:\n• Commit fraud such as fake bookings or reviews.\n• Harass, threaten, or physically harm customers or staff.\n• Engage in illegal activities while using the platform.\n• Share customer personal data without consent.\n• Use fake documents or false verification details.\n• Bypass platform payments or redirect customers off-platform.\n• Repeatedly violate policies after multiple warnings.\n• Cause intentional damage to customer property.';

  @override
  String get suspensionPermActionTitle => 'Action (Permanent)';

  @override
  String get suspensionPermActionContent =>
      'Immediate account termination. Outstanding payments may be withheld as per policy. Re-registration is not allowed.';

  @override
  String get suspensionNotifyTitle => 'Suspension Notification';

  @override
  String get suspensionNotifyContent =>
      'Partners will be notified via app notification, email, or SMS with reason and duration.';

  @override
  String get suspensionAppealTitle => 'Appeal Process';

  @override
  String get suspensionAppealContent =>
      'Partners may appeal within 7 days with valid proof. Final decision rests with the platform.';

  @override
  String get suspensionReactivateTitle => 'Reactivation Policy';

  @override
  String get suspensionReactivateContent =>
      'Temporary suspensions require review, training, or probation before reactivation.';

  @override
  String get suspensionFinalNoteTitle => 'Final Note';

  @override
  String get suspensionFinalNoteContent =>
      'The platform reserves the right to suspend or terminate accounts to protect customers and platform integrity.';

  @override
  String get suspensionContact =>
      'For any queries, contact: support@omibay.com';

  @override
  String get pauseWorkTitle => 'Pause Work';

  @override
  String get pauseWorkReasonPrompt =>
      'Please select a reason for pausing the work:';

  @override
  String get reasonNeedMaterials => 'Need more materials';

  @override
  String get reasonHealthEmergency => 'Health emergency';

  @override
  String get reasonCustomerRequested => 'Customer requested pause';

  @override
  String get reasonLunchBreak => 'Lunch/Break';

  @override
  String get workPaused => 'Work Paused';

  @override
  String get confirmPause => 'Confirm Pause';

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String get enterOtpInstruction =>
      'Please enter the 4-digit OTP shown on the customer\'s booking details screen to start work.';

  @override
  String get workStartedSuccess => 'Work started successfully!';

  @override
  String get invalidOtpTryAgain => 'Invalid OTP. Please try again.';

  @override
  String get verifyAndStart => 'Verify & Start';

  @override
  String get jobDetailsTitle => 'Job Details';

  @override
  String get onTheWay => 'On the way';

  @override
  String get started => 'Started';

  @override
  String get complete => 'Complete';

  @override
  String get customerReview => 'CUSTOMER REVIEW';

  @override
  String get excellentServiceMock =>
      'Excellent service! The partner arrived on time and did a very thorough job. Highly recommended for home cleaning services.';

  @override
  String get serviceSchedule => 'SERVICE SCHEDULE';

  @override
  String get reachLocationEarly =>
      'Important: Please reach the location 10 minutes before the scheduled time.';

  @override
  String get customerDetailsAndSpecification =>
      'CUSTOMER DETAILS & SERVICE SPECIFICATION';

  @override
  String get serviceLocation => 'SERVICE LOCATION';

  @override
  String get navigate => 'Navigate';

  @override
  String get mockCustomerName => 'Rahul Sharma';

  @override
  String get mockLocation => 'Bellandur, Bangalore';

  @override
  String get mockFullAddress =>
      'Flat 402, Green Glen Layout, Bellandur, Bangalore';

  @override
  String get mockScheduledTime => 'Scheduled for 12 Jan, 10:00 AM';

  @override
  String get appVersionValue => '1.0.0';

  @override
  String get justNow => 'Just now';

  @override
  String get jobPayment => 'Job Payment';

  @override
  String get manualTransaction => 'Manual Transaction';

  @override
  String get paymentTransaction => 'Payment transaction';

  @override
  String get amountLabel => 'Amount';

  @override
  String get currencySymbol => '₹';

  @override
  String dayLabel(String number) {
    return 'Day $number';
  }

  @override
  String earningsForDayTooltip(String day, String amount) {
    return 'Day $day: $amount';
  }

  @override
  String get transactionDefault => 'Transaction';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String jobWithService(Object service) {
    return 'Job: $service';
  }

  @override
  String get tipAmount => 'Tip Amount';

  @override
  String referralShareMessage(Object code) {
    return 'Join OmiBay Partner app and use my code $code to earn rewards! Download now: https://omibay.com/join';
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
  String get supportNumber3 => '+91 73188 47545';

  @override
  String get transactionIdPrefix => '#TXN';
}
