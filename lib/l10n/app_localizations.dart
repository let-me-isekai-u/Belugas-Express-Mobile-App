import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Beluga Express'**
  String get appTitle;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loginErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter both Phone number and Password'**
  String get loginErrorEmpty;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong phone number or password'**
  String get loginErrorWrong;

  /// No description provided for @loginErrorLocked.
  ///
  /// In en, this message translates to:
  /// **'Account is locked, cannot login'**
  String get loginErrorLocked;

  /// No description provided for @loginErrorOther.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get loginErrorOther;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Beluga Express'**
  String get registerTitle;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneHint;

  /// No description provided for @verificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCodeHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend ({count})'**
  String resendCode(Object count);

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get referralCodeHint;

  /// No description provided for @zaloHint.
  ///
  /// In en, this message translates to:
  /// **'Zalo number (optional)'**
  String get zaloHint;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to '**
  String get agreeTerms;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyAccount;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enterPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @agreeTermsWarning.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms of use'**
  String get agreeTermsWarning;

  /// No description provided for @sendCodeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to email!'**
  String get sendCodeSuccess;

  /// No description provided for @sendCodeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code!'**
  String get sendCodeError;

  /// No description provided for @sendCodeError500.
  ///
  /// In en, this message translates to:
  /// **'Error sending email, please try again'**
  String get sendCodeError500;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error: {error}'**
  String connectionError(Object error);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @enterEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get enterEmailLabel;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmailHint;

  /// No description provided for @enterCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get enterCodeLabel;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email'**
  String get enterCodeHint;

  /// No description provided for @sendVerificationCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendVerificationCodeButton;

  /// No description provided for @resendVerificationCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Resend ({seconds}s)'**
  String resendVerificationCodeButton(Object seconds);

  /// No description provided for @verifyCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyCodeButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @emailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailEmptyError;

  /// No description provided for @codeEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter verification code'**
  String get codeEmptyError;

  /// No description provided for @sendCodeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification code has been sent to your email!'**
  String get sendCodeSuccessMessage;

  /// No description provided for @sendCodeFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot send verification code!'**
  String get sendCodeFailedMessage;

  /// No description provided for @codeInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification code is invalid!'**
  String get codeInvalidMessage;

  /// No description provided for @verificationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification successful!'**
  String get verificationSuccessMessage;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @homeTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTabHome;

  /// No description provided for @homeTabRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get homeTabRecharge;

  /// No description provided for @homeTabCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get homeTabCreateOrder;

  /// No description provided for @homeTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get homeTabOrders;

  /// No description provided for @homeTabTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get homeTabTrade;

  /// No description provided for @homeTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeTabProfile;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTitle;

  /// No description provided for @welcomeAppName.
  ///
  /// In en, this message translates to:
  /// **'Beluga Express'**
  String get welcomeAppName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Beluga Express international delivery app.'**
  String get welcomeMessage;

  /// User wallet label
  ///
  /// In en, this message translates to:
  /// **'Wallet: {amount} VND'**
  String walletLabel(Object amount);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhone;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Thay đổi ngôn ngữ'**
  String get changeLanguage;

  /// No description provided for @rechargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Wallet'**
  String get rechargeTitle;

  /// No description provided for @rechargeAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to recharge'**
  String get rechargeAmountHint;

  /// No description provided for @rechargeMinAmountError.
  ///
  /// In en, this message translates to:
  /// **'Minimum recharge amount is 50,000 VND'**
  String get rechargeMinAmountError;

  /// No description provided for @rechargeUserIdError.
  ///
  /// In en, this message translates to:
  /// **'Cannot get user ID.'**
  String get rechargeUserIdError;

  /// No description provided for @rechargeQRCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR to pay'**
  String get rechargeQRCodeTitle;

  /// Label for recharge amount in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} VND'**
  String rechargeQRCodeAmount(Object amount);

  /// Content info in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Content: {content}'**
  String rechargeQRCodeContent(Object content);

  /// Countdown timer in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Time left: {minutes}:{seconds}'**
  String rechargeQRCodeCountdown(Object minutes, Object seconds);

  /// No description provided for @rechargeQRCodeCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close QR'**
  String get rechargeQRCodeCloseButton;

  /// No description provided for @rechargeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recharge successful!'**
  String get rechargeSuccess;

  /// No description provided for @rechargeTimeout.
  ///
  /// In en, this message translates to:
  /// **'⛔ Payment time expired!'**
  String get rechargeTimeout;

  /// No description provided for @tradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get tradeTitle;

  /// No description provided for @tradeNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get tradeNoTransactions;

  /// No description provided for @tradeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get tradeAmountLabel;

  /// No description provided for @tradePaymentForLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment for'**
  String get tradePaymentForLabel;

  /// No description provided for @tradePaymentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get tradePaymentDateLabel;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get orderTitle;

  /// No description provided for @orderNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders available'**
  String get orderNoOrders;

  /// No description provided for @orderStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderStatusAll;

  /// No description provided for @orderStatusPickup.
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup'**
  String get orderStatusPickup;

  /// No description provided for @orderStatusInTransitToHub.
  ///
  /// In en, this message translates to:
  /// **'En route to hub'**
  String get orderStatusInTransitToHub;

  /// No description provided for @orderStatusAtHub.
  ///
  /// In en, this message translates to:
  /// **'Arrived at hub'**
  String get orderStatusAtHub;

  /// No description provided for @orderStatusAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get orderStatusAwaitingPayment;

  /// No description provided for @orderStatusAwaitingShipment.
  ///
  /// In en, this message translates to:
  /// **'Waiting to ship'**
  String get orderStatusAwaitingShipment;

  /// No description provided for @orderStatusShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get orderStatusShipping;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// Label for order code
  ///
  /// In en, this message translates to:
  /// **'Order code: {code}'**
  String orderCodeLabel(Object code);

  /// Label for sender info
  ///
  /// In en, this message translates to:
  /// **'Sender: {name} ({phone})'**
  String orderSenderLabel(Object name, Object phone);

  /// Label for receiver name
  ///
  /// In en, this message translates to:
  /// **'Receiver: {name}'**
  String orderReceiverLabel(Object name);

  /// Label for receiver address
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String orderAddressLabel(Object address);

  /// Total order amount
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String orderTotalLabel(Object amount);

  /// Order down payment label
  ///
  /// In en, this message translates to:
  /// **'Deposit: {amount}'**
  String orderDownPaymentLabel(Object amount);

  /// Button to pay order using wallet
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String orderPaymentButton(Object amount);

  /// No description provided for @orderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderDialogTitle;

  /// No description provided for @orderInsufficientWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance is not enough. Please recharge.'**
  String get orderInsufficientWallet;

  /// No description provided for @orderExpiredSession.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get orderExpiredSession;

  /// No description provided for @orderPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get orderPaymentSuccess;

  /// No description provided for @orderQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR to pay'**
  String get orderQrTitle;

  /// Amount in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String orderQrAmount(Object amount);

  /// Content in QR dialog
  ///
  /// In en, this message translates to:
  /// **'Content: {content}'**
  String orderQrContent(Object content);

  /// No description provided for @orderQrCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close QR'**
  String get orderQrCloseButton;

  /// No description provided for @orderStatusDetailButton.
  ///
  /// In en, this message translates to:
  /// **'Status details'**
  String get orderStatusDetailButton;

  /// No description provided for @createOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrderTitle;

  /// No description provided for @createOrderSenderSection.
  ///
  /// In en, this message translates to:
  /// **'Sender Information'**
  String get createOrderSenderSection;

  /// No description provided for @createOrderReceiverSection.
  ///
  /// In en, this message translates to:
  /// **'Receiver Information'**
  String get createOrderReceiverSection;

  /// No description provided for @createOrderItemsSection.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get createOrderItemsSection;

  /// No description provided for @createOrderSenderPhone.
  ///
  /// In en, this message translates to:
  /// **'Sender Phone'**
  String get createOrderSenderPhone;

  /// No description provided for @createOrderSenderName.
  ///
  /// In en, this message translates to:
  /// **'Sender Name'**
  String get createOrderSenderName;

  /// No description provided for @createOrderSenderAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup Address'**
  String get createOrderSenderAddress;

  /// No description provided for @createOrderReceiverPhone.
  ///
  /// In en, this message translates to:
  /// **'Receiver Phone'**
  String get createOrderReceiverPhone;

  /// No description provided for @createOrderReceiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name'**
  String get createOrderReceiverName;

  /// No description provided for @createOrderReceiverAddress.
  ///
  /// In en, this message translates to:
  /// **'Receiver Address'**
  String get createOrderReceiverAddress;

  /// No description provided for @createOrderReceiverCountry.
  ///
  /// In en, this message translates to:
  /// **'Destination Country'**
  String get createOrderReceiverCountry;

  /// No description provided for @createOrderItemType.
  ///
  /// In en, this message translates to:
  /// **'Item Type'**
  String get createOrderItemType;

  /// No description provided for @createOrderItemWeight.
  ///
  /// In en, this message translates to:
  /// **'Unit ({unit})'**
  String createOrderItemWeight(Object unit);

  /// No description provided for @createOrderItemRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get createOrderItemRemove;

  /// No description provided for @createOrderAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get createOrderAddItem;

  /// No description provided for @createOrderConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get createOrderConfirmButton;

  /// No description provided for @createOrderErrorEmptyField.
  ///
  /// In en, this message translates to:
  /// **'Please check all required fields!'**
  String get createOrderErrorEmptyField;

  /// No description provided for @createOrderErrorCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country!'**
  String get createOrderErrorCountry;

  /// No description provided for @createOrderErrorInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid quantity for each item!'**
  String get createOrderErrorInvalidWeight;

  /// No description provided for @createOrderErrorNoItems.
  ///
  /// In en, this message translates to:
  /// **'Order must have at least one item!'**
  String get createOrderErrorNoItems;

  /// Error fetching wallet balance
  ///
  /// In en, this message translates to:
  /// **'Error fetching wallet balance: {code}'**
  String createOrderErrorWalletFetch(Object code);

  /// No description provided for @confirmOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrderTitle;

  /// No description provided for @confirmOrderSenderSection.
  ///
  /// In en, this message translates to:
  /// **'Sender Information'**
  String get confirmOrderSenderSection;

  /// No description provided for @confirmOrderReceiverSection.
  ///
  /// In en, this message translates to:
  /// **'Receiver Information'**
  String get confirmOrderReceiverSection;

  /// No description provided for @confirmOrderItemsSection.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get confirmOrderItemsSection;

  /// Current wallet balance
  ///
  /// In en, this message translates to:
  /// **'Current wallet balance: {balance} VND'**
  String confirmOrderWalletBalance(Object balance);

  /// No description provided for @confirmOrderDepositButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm deposit 500,000 VND'**
  String get confirmOrderDepositButton;

  /// No description provided for @confirmOrderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get confirmOrderDialogTitle;

  /// No description provided for @confirmOrderDialogFetchError.
  ///
  /// In en, this message translates to:
  /// **'Cannot fetch wallet balance.'**
  String get confirmOrderDialogFetchError;

  /// No description provided for @confirmOrderDialogInsufficientWallet.
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance to create order. Please top up.'**
  String get confirmOrderDialogInsufficientWallet;

  /// Order created success
  ///
  /// In en, this message translates to:
  /// **'Order created successfully! Code: {code}'**
  String confirmOrderDialogCreateSuccess(Object code);

  /// No description provided for @confirmOrderDialogCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Order creation failed!'**
  String get confirmOrderDialogCreateFailed;

  /// No description provided for @confirmOrderDialogSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get confirmOrderDialogSessionExpired;

  /// Unknown error
  ///
  /// In en, this message translates to:
  /// **'Unknown error. Code: {code}'**
  String confirmOrderDialogUnknownError(Object code);

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get changePasswordConfirm;

  /// No description provided for @againConfirmPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get againConfirmPasswordButton;

  /// No description provided for @changePasswordBackLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get changePasswordBackLogin;

  /// No description provided for @changePasswordErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get changePasswordErrorEmpty;

  /// No description provided for @changePasswordErrorWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must be ≥8 chars, include upper, lower, number, special'**
  String get changePasswordErrorWeak;

  /// No description provided for @changePasswordErrorConfirmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get changePasswordErrorConfirmEmpty;

  /// No description provided for @changePasswordErrorNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation does not match'**
  String get changePasswordErrorNotMatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordEmailNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is not registered!'**
  String get changePasswordEmailNotRegistered;

  /// No description provided for @changePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Password change failed!'**
  String get changePasswordFailed;

  /// Connection error
  ///
  /// In en, this message translates to:
  /// **'Connection error: {error}'**
  String changePasswordConnectionError(Object error);

  /// No description provided for @orderStatusScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get orderStatusScreenTitle;

  /// No description provided for @orderStatusTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderStatusTabAll;

  /// No description provided for @orderStatusTabPickup.
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup'**
  String get orderStatusTabPickup;

  /// No description provided for @orderStatusTabInTransit.
  ///
  /// In en, this message translates to:
  /// **'En route to hub'**
  String get orderStatusTabInTransit;

  /// No description provided for @orderStatusTabAtHub.
  ///
  /// In en, this message translates to:
  /// **'Arrived at hub'**
  String get orderStatusTabAtHub;

  /// No description provided for @orderStatusTabAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get orderStatusTabAwaitingPayment;

  /// No description provided for @orderStatusTabAwaitingShipment.
  ///
  /// In en, this message translates to:
  /// **'Waiting to ship'**
  String get orderStatusTabAwaitingShipment;

  /// No description provided for @orderStatusTabShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get orderStatusTabShipping;

  /// No description provided for @orderStatusTabDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusTabDelivered;

  /// No description provided for @orderStatusTabCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusTabCancelled;

  /// Label for order status
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String orderStatusLabel(Object status);

  /// Label for receiver phone
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String orderPhoneLabel(Object phone);

  /// Order remaining balance label
  ///
  /// In en, this message translates to:
  /// **'Remaining payment: {amount}'**
  String orderBalancePaymentLabel(Object amount);

  /// Order creation date
  ///
  /// In en, this message translates to:
  /// **'Created on: {date}'**
  String orderCreatedDateLabel(Object date);

  /// No description provided for @orderItemListLabel.
  ///
  /// In en, this message translates to:
  /// **'Item list:'**
  String get orderItemListLabel;

  /// No description provided for @orderUpdatedDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated details'**
  String get orderUpdatedDetailsLabel;

  /// No description provided for @orderUpdatedNotice.
  ///
  /// In en, this message translates to:
  /// **'Note: This content has been edited in the \'Update Order\' screen (not sent if the green action button was not pressed).'**
  String get orderUpdatedNotice;

  /// No description provided for @orderActionChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get orderActionChangeStatus;

  /// No description provided for @orderActionUpdateOrder.
  ///
  /// In en, this message translates to:
  /// **'Update order'**
  String get orderActionUpdateOrder;

  /// No description provided for @orderSnackUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully'**
  String get orderSnackUpdateSuccess;

  /// No description provided for @orderSnackUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update order'**
  String get orderSnackUpdateFailed;

  /// No description provided for @orderSnackSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again'**
  String get orderSnackSessionExpired;

  /// No description provided for @contractorHomeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Beluga Express'**
  String get contractorHomeAppBarTitle;

  /// No description provided for @contractorHomeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Beluga Express!'**
  String get contractorHomeWelcomeTitle;

  /// No description provided for @contractorHomeWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Select and update available order statuses.'**
  String get contractorHomeWelcomeMessage;

  /// No description provided for @contractorHomeViewOrdersButton.
  ///
  /// In en, this message translates to:
  /// **'View Available Orders'**
  String get contractorHomeViewOrdersButton;

  /// No description provided for @contractorHomeTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get contractorHomeTabHome;

  /// No description provided for @contractorHomeTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get contractorHomeTabOrders;

  /// No description provided for @contractorHomeTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get contractorHomeTabProfile;

  /// No description provided for @updateOrderAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get updateOrderAppBarTitle;

  /// No description provided for @updateOrderItemTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Type'**
  String get updateOrderItemTypeLabel;

  /// No description provided for @updateOrderQuantityLabelKg.
  ///
  /// In en, this message translates to:
  /// **'Kg'**
  String get updateOrderQuantityLabelKg;

  /// Label for quantity input for unit other than kg
  ///
  /// In en, this message translates to:
  /// **'{unit}'**
  String updateOrderQuantityLabelUnit(Object unit);

  /// No description provided for @updateOrderDeleteItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get updateOrderDeleteItemTooltip;

  /// No description provided for @updateOrderAddItemButton.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get updateOrderAddItemButton;

  /// No description provided for @updateOrderConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order Update'**
  String get updateOrderConfirmDialogTitle;

  /// No description provided for @updateOrderConfirmDialogChangesLabel.
  ///
  /// In en, this message translates to:
  /// **'Changes:'**
  String get updateOrderConfirmDialogChangesLabel;

  /// No description provided for @updateOrderConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get updateOrderConfirmButton;

  /// No description provided for @updateOrderCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get updateOrderCancelButton;

  /// No description provided for @updateOrderInvalidQuantityMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity for each item'**
  String get updateOrderInvalidQuantityMessage;

  /// No description provided for @updateOrderLoadingPricingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading pricing table...'**
  String get updateOrderLoadingPricingMessage;

  /// Error message when fetching pricing table
  ///
  /// In en, this message translates to:
  /// **'Error fetching pricing table: {error}'**
  String updateOrderPricingErrorMessage(Object error);

  /// Message showing number of pricing items loaded
  ///
  /// In en, this message translates to:
  /// **'{count} items loaded in pricing table'**
  String updateOrderPricingLoadedMessage(Object count);

  /// No description provided for @updateOrderNoItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'No items. Press Add to include.'**
  String get updateOrderNoItemsMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @createOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Create Delivery Order'**
  String get createOrderButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
