// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Beluga Express';

  @override
  String get phone => 'Phone number';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get register => 'Register';

  @override
  String get loginErrorEmpty => 'Please enter both Phone number and Password';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginErrorWrong => 'Wrong phone number or password';

  @override
  String get loginErrorLocked => 'Account is locked, cannot login';

  @override
  String get loginErrorOther => 'An error occurred, please try again';

  @override
  String get registerTitle => 'Beluga Express';

  @override
  String get nameHint => 'Name';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get phoneHint => 'Phone number';

  @override
  String get verificationCodeHint => 'Verification code';

  @override
  String get sendCode => 'Send code';

  @override
  String resendCode(Object count) {
    return 'Resend ($count)';
  }

  @override
  String get referralCodeHint => 'Referral code';

  @override
  String get zaloHint => 'Zalo number (optional)';

  @override
  String get agreeTerms => 'I agree to ';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyAccount => 'Already have an account? Login';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get enterPhone => 'Please enter phone number';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get enterVerificationCode => 'Enter verification code';

  @override
  String get agreeTermsWarning => 'You must agree to the terms of use';

  @override
  String get sendCodeSuccess => 'Verification code sent to email!';

  @override
  String get sendCodeError => 'Failed to send code!';

  @override
  String get sendCodeError500 => 'Error sending email, please try again';

  @override
  String connectionError(Object error) {
    return 'Connection error: $error';
  }

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get enterEmailLabel => 'Email';

  @override
  String get enterEmailHint => 'Enter your email';

  @override
  String get enterCodeLabel => 'Verification code';

  @override
  String get enterCodeHint => 'Enter the verification code sent to your email';

  @override
  String get sendVerificationCodeButton => 'Send code';

  @override
  String resendVerificationCodeButton(Object seconds) {
    return 'Resend (${seconds}s)';
  }

  @override
  String get verifyCodeButton => 'Verify';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get emailEmptyError => 'Please enter your email';

  @override
  String get codeEmptyError => 'Please enter verification code';

  @override
  String get sendCodeSuccessMessage => 'Verification code has been sent to your email!';

  @override
  String get sendCodeFailedMessage => 'Cannot send verification code!';

  @override
  String get codeInvalidMessage => 'Verification code is invalid!';

  @override
  String get verificationSuccessMessage => 'Verification successful!';

  @override
  String get defaultUserName => 'User';

  @override
  String get homeTabHome => 'Home';

  @override
  String get homeTabRecharge => 'Recharge';

  @override
  String get homeTabCreateOrder => 'Create Order';

  @override
  String get homeTabOrders => 'Orders';

  @override
  String get homeTabTrade => 'Trade';

  @override
  String get homeTabProfile => 'Profile';

  @override
  String get welcomeTitle => 'Welcome to';

  @override
  String get welcomeAppName => 'Beluga Express';

  @override
  String get welcomeMessage => 'Welcome to the Beluga Express international delivery app.';

  @override
  String walletLabel(Object amount) {
    return 'Wallet: $amount VND';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Full name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone number';

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get logoutButton => 'Logout';

  @override
  String get changeLanguage => 'Thay đổi ngôn ngữ';

  @override
  String get rechargeTitle => 'Recharge Wallet';

  @override
  String get rechargeAmountHint => 'Enter amount to recharge';

  @override
  String get rechargeMinAmountError => 'Minimum recharge amount is 50,000 VND';

  @override
  String get rechargeUserIdError => 'Cannot get user ID.';

  @override
  String get rechargeQRCodeTitle => 'Scan QR to pay';

  @override
  String rechargeQRCodeAmount(Object amount) {
    return 'Amount: $amount VND';
  }

  @override
  String rechargeQRCodeContent(Object content) {
    return 'Content: $content';
  }

  @override
  String rechargeQRCodeCountdown(Object minutes, Object seconds) {
    return 'Time left: $minutes:$seconds';
  }

  @override
  String get rechargeQRCodeCloseButton => 'Close QR';

  @override
  String get rechargeSuccess => 'Recharge successful!';

  @override
  String get rechargeTimeout => '⛔ Payment time expired!';

  @override
  String get tradeTitle => 'Transaction History';

  @override
  String get tradeNoTransactions => 'No transactions yet';

  @override
  String get tradeAmountLabel => 'Amount';

  @override
  String get tradePaymentForLabel => 'Payment for';

  @override
  String get tradePaymentDateLabel => 'Payment date';

  @override
  String get orderTitle => 'Order List';

  @override
  String get orderNoOrders => 'No orders available';

  @override
  String get orderStatusAll => 'All';

  @override
  String get orderStatusPickup => 'Waiting for pickup';

  @override
  String get orderStatusInTransitToHub => 'En route to hub';

  @override
  String get orderStatusAtHub => 'Arrived at hub';

  @override
  String get orderStatusAwaitingPayment => 'Awaiting payment';

  @override
  String get orderStatusAwaitingShipment => 'Waiting to ship';

  @override
  String get orderStatusShipping => 'Shipping';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String orderCodeLabel(Object code) {
    return 'Order code: $code';
  }

  @override
  String orderSenderLabel(Object name, Object phone) {
    return 'Sender: $name ($phone)';
  }

  @override
  String orderReceiverLabel(Object name) {
    return 'Receiver: $name';
  }

  @override
  String orderAddressLabel(Object address) {
    return 'Address: $address';
  }

  @override
  String orderTotalLabel(Object amount) {
    return 'Total: $amount';
  }

  @override
  String orderDownPaymentLabel(Object amount) {
    return 'Deposit: $amount';
  }

  @override
  String orderPaymentButton(Object amount) {
    return 'Pay $amount';
  }

  @override
  String get orderDialogTitle => 'Order';

  @override
  String get orderInsufficientWallet => 'Wallet balance is not enough. Please recharge.';

  @override
  String get orderExpiredSession => 'Session expired. Please login again.';

  @override
  String get orderPaymentSuccess => 'Payment successful';

  @override
  String get orderQrTitle => 'Scan QR to pay';

  @override
  String orderQrAmount(Object amount) {
    return 'Amount: $amount';
  }

  @override
  String orderQrContent(Object content) {
    return 'Content: $content';
  }

  @override
  String get orderQrCloseButton => 'Close QR';

  @override
  String get orderStatusDetailButton => 'Status details';

  @override
  String get createOrderTitle => 'Create Order';

  @override
  String get createOrderSenderSection => 'Sender Information';

  @override
  String get createOrderReceiverSection => 'Receiver Information';

  @override
  String get createOrderItemsSection => 'Order Items';

  @override
  String get createOrderSenderPhone => 'Sender Phone';

  @override
  String get createOrderSenderName => 'Sender Name';

  @override
  String get createOrderSenderAddress => 'Pickup Address';

  @override
  String get createOrderReceiverPhone => 'Receiver Phone';

  @override
  String get createOrderReceiverName => 'Receiver Name';

  @override
  String get createOrderReceiverAddress => 'Receiver Address';

  @override
  String get createOrderReceiverCountry => 'Destination Country';

  @override
  String get createOrderItemType => 'Item Type';

  @override
  String createOrderItemWeight(Object unit) {
    return 'Weight ($unit)';
  }

  @override
  String get createOrderItemRemove => 'Remove item';

  @override
  String get createOrderAddItem => 'Add Item';

  @override
  String get createOrderConfirmButton => 'Confirm Order';

  @override
  String get createOrderErrorEmptyField => 'Please check all required fields!';

  @override
  String get createOrderErrorCountry => 'Please select a country!';

  @override
  String get createOrderErrorInvalidWeight => 'Please enter valid quantity for each item!';

  @override
  String get createOrderErrorNoItems => 'Order must have at least one item!';

  @override
  String createOrderErrorWalletFetch(Object code) {
    return 'Error fetching wallet balance: $code';
  }

  @override
  String get confirmOrderTitle => 'Confirm Order';

  @override
  String get confirmOrderSenderSection => 'Sender Information';

  @override
  String get confirmOrderReceiverSection => 'Receiver Information';

  @override
  String get confirmOrderItemsSection => 'Order Items';

  @override
  String confirmOrderWalletBalance(Object balance) {
    return 'Current wallet balance: $balance VND';
  }

  @override
  String get confirmOrderDepositButton => 'Confirm deposit 500,000 VND';

  @override
  String get confirmOrderDialogTitle => 'Notification';

  @override
  String get confirmOrderDialogFetchError => 'Cannot fetch wallet balance.';

  @override
  String get confirmOrderDialogInsufficientWallet => 'Insufficient wallet balance to create order. Please top up.';

  @override
  String confirmOrderDialogCreateSuccess(Object code) {
    return 'Order created successfully! Code: $code';
  }

  @override
  String get confirmOrderDialogCreateFailed => 'Order creation failed!';

  @override
  String get confirmOrderDialogSessionExpired => 'Session expired. Please login again.';

  @override
  String confirmOrderDialogUnknownError(Object code) {
    return 'Unknown error. Code: $code';
  }

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordNew => 'New Password';

  @override
  String get changePasswordConfirm => 'Confirm Password';

  @override
  String get againConfirmPasswordButton => 'Confirm';

  @override
  String get changePasswordBackLogin => 'Back to Login';

  @override
  String get changePasswordErrorEmpty => 'Please enter a new password';

  @override
  String get changePasswordErrorWeak => 'Password must be ≥8 chars, include upper, lower, number, special';

  @override
  String get changePasswordErrorConfirmEmpty => 'Please confirm password';

  @override
  String get changePasswordErrorNotMatch => 'Password confirmation does not match';

  @override
  String get changePasswordSuccess => 'Password changed successfully!';

  @override
  String get changePasswordEmailNotRegistered => 'This email is not registered!';

  @override
  String get changePasswordFailed => 'Password change failed!';

  @override
  String changePasswordConnectionError(Object error) {
    return 'Connection error: $error';
  }

  @override
  String get orderStatusScreenTitle => 'Order List';

  @override
  String get orderStatusTabAll => 'All';

  @override
  String get orderStatusTabPickup => 'Waiting for pickup';

  @override
  String get orderStatusTabInTransit => 'En route to hub';

  @override
  String get orderStatusTabAtHub => 'Arrived at hub';

  @override
  String get orderStatusTabAwaitingPayment => 'Awaiting payment';

  @override
  String get orderStatusTabAwaitingShipment => 'Waiting to ship';

  @override
  String get orderStatusTabShipping => 'Shipping';

  @override
  String get orderStatusTabDelivered => 'Delivered';

  @override
  String get orderStatusTabCancelled => 'Cancelled';

  @override
  String orderStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String orderPhoneLabel(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String orderBalancePaymentLabel(Object amount) {
    return 'Remaining payment: $amount';
  }

  @override
  String orderCreatedDateLabel(Object date) {
    return 'Created on: $date';
  }

  @override
  String get orderItemListLabel => 'Item list:';

  @override
  String get orderUpdatedDetailsLabel => 'Updated details';

  @override
  String get orderUpdatedNotice => 'Note: This content has been edited in the \'Update Order\' screen (not sent if the green action button was not pressed).';

  @override
  String get orderActionChangeStatus => 'Change status';

  @override
  String get orderActionUpdateOrder => 'Update order';

  @override
  String get orderSnackUpdateSuccess => 'Order updated successfully';

  @override
  String get orderSnackUpdateFailed => 'Failed to update order';

  @override
  String get orderSnackSessionExpired => 'Session expired. Please login again';

  @override
  String get contractorHomeAppBarTitle => 'Beluga Express';

  @override
  String get contractorHomeWelcomeTitle => 'Welcome to Beluga Express!';

  @override
  String get contractorHomeWelcomeMessage => 'Select and update available order statuses.';

  @override
  String get contractorHomeViewOrdersButton => 'View Available Orders';

  @override
  String get contractorHomeTabHome => 'Home';

  @override
  String get contractorHomeTabOrders => 'Orders';

  @override
  String get contractorHomeTabProfile => 'Profile';

  @override
  String get updateOrderAppBarTitle => 'Update Order';

  @override
  String get updateOrderItemTypeLabel => 'Item Type';

  @override
  String get updateOrderQuantityLabelKg => 'Kg';

  @override
  String updateOrderQuantityLabelUnit(Object unit) {
    return '$unit';
  }

  @override
  String get updateOrderDeleteItemTooltip => 'Delete item';

  @override
  String get updateOrderAddItemButton => 'Add Item';

  @override
  String get updateOrderConfirmDialogTitle => 'Confirm Order Update';

  @override
  String get updateOrderConfirmDialogChangesLabel => 'Changes:';

  @override
  String get updateOrderConfirmButton => 'Confirm';

  @override
  String get updateOrderCancelButton => 'Cancel';

  @override
  String get updateOrderInvalidQuantityMessage => 'Please enter a valid quantity for each item';

  @override
  String get updateOrderLoadingPricingMessage => 'Loading pricing table...';

  @override
  String updateOrderPricingErrorMessage(Object error) {
    return 'Error fetching pricing table: $error';
  }

  @override
  String updateOrderPricingLoadedMessage(Object count) {
    return '$count items loaded in pricing table';
  }

  @override
  String get updateOrderNoItemsMessage => 'No items. Press Add to include.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get update => 'Update';
}
