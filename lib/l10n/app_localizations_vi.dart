// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Beluga Express';

  @override
  String get phone => 'Số điện thoại';

  @override
  String get password => 'Mật khẩu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get forgotPassword => 'Quên mật khẩu';

  @override
  String get register => 'Đăng ký';

  @override
  String get loginErrorEmpty => 'Vui lòng nhập đầy đủ Số điện thoại và Mật khẩu';

  @override
  String get loginSuccess => 'Đăng nhập thành công';

  @override
  String get loginErrorWrong => 'Sai số điện thoại hoặc Mật khẩu';

  @override
  String get loginErrorLocked => 'Tài khoản đã bị khóa, không thể đăng nhập';

  @override
  String get loginErrorOther => 'Có lỗi xảy ra, vui lòng thử lại';

  @override
  String get registerTitle => 'Beluga Express';

  @override
  String get nameHint => 'Tên';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Mật khẩu';

  @override
  String get confirmPasswordHint => 'Xác nhận mật khẩu';

  @override
  String get phoneHint => 'Số điện thoại';

  @override
  String get verificationCodeHint => 'Mã xác nhận';

  @override
  String get sendCode => 'Nhận mã';

  @override
  String resendCode(Object count) {
    return 'Gửi lại ($count)';
  }

  @override
  String get referralCodeHint => 'Mã giới thiệu';

  @override
  String get zaloHint => 'Số Zalo (tùy chọn)';

  @override
  String get agreeTerms => 'Tôi đồng ý với ';

  @override
  String get termsOfUse => 'Điều khoản sử dụng';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get alreadyAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get enterName => 'Vui lòng nhập tên';

  @override
  String get enterEmail => 'Vui lòng nhập email';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String get enterPassword => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordMismatch => 'Mật khẩu không khớp';

  @override
  String get enterPhone => 'Vui lòng nhập số điện thoại';

  @override
  String get invalidPhone => 'Số điện thoại không hợp lệ';

  @override
  String get enterVerificationCode => 'Nhập mã xác thực để xác nhận xoá tài khoản người dùng này';

  @override
  String get agreeTermsWarning => 'Bạn cần đồng ý với điều khoản sử dụng';

  @override
  String get sendCodeSuccess => 'Đã gửi mã xác nhận về email!';

  @override
  String get sendCodeError => 'Gửi mã thất bại!';

  @override
  String get sendCodeError500 => 'Lỗi khi gửi email, vui lòng thử lại';

  @override
  String connectionError(Object error) {
    return 'Lỗi kết nối: $error';
  }

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get enterEmailLabel => 'Email';

  @override
  String get enterEmailHint => 'Nhập email của bạn';

  @override
  String get enterCodeLabel => 'Mã xác nhận';

  @override
  String get enterCodeHint => 'Nhập mã xác nhận đã gửi đến email';

  @override
  String get sendVerificationCodeButton => 'Nhận mã';

  @override
  String resendVerificationCodeButton(Object seconds) {
    return 'Gửi lại (${seconds}s)';
  }

  @override
  String get verifyCodeButton => 'Xác nhận';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get emailEmptyError => 'Vui lòng nhập email';

  @override
  String get codeEmptyError => 'Vui lòng nhập mã xác nhận';

  @override
  String get sendCodeSuccessMessage => 'Mã xác nhận đã được gửi về email!';

  @override
  String get sendCodeFailedMessage => 'Không thể gửi mã xác nhận!';

  @override
  String get codeInvalidMessage => 'Mã xác nhận không hợp lệ!';

  @override
  String get verificationSuccessMessage => 'Xác minh thành công!';

  @override
  String get defaultUserName => 'Người dùng';

  @override
  String get homeTabHome => 'Trang chủ';

  @override
  String get homeTabRecharge => 'Nạp tiền';

  @override
  String get homeTabCreateOrder => 'Tạo đơn';

  @override
  String get homeTabOrders => 'Đơn hàng';

  @override
  String get homeTabTrade => 'Giao dịch';

  @override
  String get homeTabProfile => 'Tài khoản';

  @override
  String get welcomeTitle => 'Chào mừng bạn đến với';

  @override
  String get welcomeAppName => 'Beluga Express';

  @override
  String get welcomeMessage => 'Chào mừng bạn đã đến với ứng dụng giao nhận quốc tế Beluga Express.';

  @override
  String walletLabel(Object amount) {
    return 'Ví: $amount VND';
  }

  @override
  String get profileTitle => 'Trang cá nhân';

  @override
  String get profileName => 'Họ tên';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Số điện thoại';

  @override
  String get changePasswordButton => 'Đổi mật khẩu';

  @override
  String get logoutButton => 'Đăng xuất';

  @override
  String get changeLanguage => 'Thay đổi ngôn ngữ';

  @override
  String get rechargeTitle => 'Nạp tiền vào ví';

  @override
  String get rechargeAmountHint => 'Nhập số tiền nạp';

  @override
  String get rechargeMinAmountError => 'Số tiền nạp tối thiểu là 50.000 VND';

  @override
  String get rechargeUserIdError => 'Không lấy được ID người dùng.';

  @override
  String get rechargeQRCodeTitle => 'Quét mã QR để thanh toán';

  @override
  String rechargeQRCodeAmount(Object amount) {
    return 'Số tiền: $amount VND';
  }

  @override
  String rechargeQRCodeContent(Object content) {
    return 'Nội dung: $content';
  }

  @override
  String rechargeQRCodeCountdown(Object minutes, Object seconds) {
    return 'Thời gian còn lại: $minutes:$seconds';
  }

  @override
  String get rechargeQRCodeCloseButton => 'Đóng mã QR';

  @override
  String get rechargeSuccess => '✅ Nạp tiền thành công!';

  @override
  String get rechargeTimeout => '⛔ Hết thời gian thanh toán!';

  @override
  String get tradeTitle => 'Lịch sử giao dịch';

  @override
  String get tradeNoTransactions => 'Chưa có giao dịch nào';

  @override
  String get tradeAmountLabel => 'Số tiền';

  @override
  String get tradePaymentForLabel => 'Thanh toán cho';

  @override
  String get tradePaymentDateLabel => 'Ngày thanh toán';

  @override
  String get orderTitle => 'Danh sách đơn hàng';

  @override
  String get orderNoOrders => 'Không có đơn hàng.';

  @override
  String get orderStatusAll => 'Tất cả';

  @override
  String get orderStatusPickup => 'Đang đến lấy hàng';

  @override
  String get orderStatusInTransitToHub => 'Đang trên đường đến kho trung chuyển';

  @override
  String get orderStatusAtHub => 'Đã đến kho';

  @override
  String get orderStatusAwaitingPayment => 'Chờ thanh toán';

  @override
  String get orderStatusAwaitingShipment => 'Chờ gửi hàng';

  @override
  String get orderStatusShipping => 'Đang vận chuyển';

  @override
  String get orderStatusDelivered => 'Giao hàng thành công';

  @override
  String get orderStatusCancelled => 'Đã hủy';

  @override
  String orderCodeLabel(Object code) {
    return 'Mã đơn: $code';
  }

  @override
  String orderSenderLabel(Object name, Object phone) {
    return 'Người gửi: $name ($phone)';
  }

  @override
  String orderReceiverLabel(Object name) {
    return 'Người nhận: $name';
  }

  @override
  String orderAddressLabel(Object address) {
    return 'Địa chỉ: $address';
  }

  @override
  String orderTotalLabel(Object amount) {
    return 'Tổng: $amount';
  }

  @override
  String orderDownPaymentLabel(Object amount) {
    return 'Đặt cọc: $amount';
  }

  @override
  String orderPaymentButton(Object amount) {
    return 'Thanh toán $amount';
  }

  @override
  String get orderDialogTitle => 'Đơn hàng';

  @override
  String get orderInsufficientWallet => 'Số dư ví không đủ. Vui lòng nạp thêm.';

  @override
  String get orderExpiredSession => 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get orderPaymentSuccess => 'Thanh toán thành công';

  @override
  String get orderQrTitle => 'Quét mã QR để thanh toán';

  @override
  String orderQrAmount(Object amount) {
    return 'Số tiền: $amount';
  }

  @override
  String orderQrContent(Object content) {
    return 'Nội dung: $content';
  }

  @override
  String get orderQrCloseButton => 'Đóng mã QR';

  @override
  String get orderStatusDetailButton => 'Chi tiết trạng thái';

  @override
  String get createOrderTitle => 'Tạo đơn hàng';

  @override
  String get createOrderSenderSection => 'Thông tin người gửi';

  @override
  String get createOrderReceiverSection => 'Thông tin người nhận';

  @override
  String get createOrderItemsSection => 'Thông tin mặt hàng';

  @override
  String get createOrderSenderPhone => 'Số điện thoại người gửi';

  @override
  String get createOrderSenderName => 'Họ tên người gửi';

  @override
  String get createOrderSenderAddress => 'Địa chỉ lấy hàng';

  @override
  String get createOrderReceiverPhone => 'Số điện thoại người nhận';

  @override
  String get createOrderReceiverName => 'Họ tên người nhận';

  @override
  String get createOrderReceiverAddress => 'Địa chỉ người nhận';

  @override
  String get createOrderReceiverCountry => 'Quốc gia nhận';

  @override
  String get createOrderItemType => 'Loại hàng';

  @override
  String createOrderItemWeight(Object unit) {
    return 'Đơn vị ($unit)';
  }

  @override
  String get createOrderItemRemove => 'Xoá mặt hàng';

  @override
  String get createOrderAddItem => 'Thêm mặt hàng';

  @override
  String get createOrderConfirmButton => 'Xác nhận đơn hàng';

  @override
  String get createOrderErrorEmptyField => 'Vui lòng kiểm tra lại thông tin!';

  @override
  String get createOrderErrorCountry => 'Vui lòng chọn quốc gia!';

  @override
  String get createOrderErrorInvalidWeight => 'Vui lòng nhập số lượng hợp lệ cho mỗi mặt hàng!';

  @override
  String get createOrderErrorNoItems => 'Đơn hàng phải có ít nhất một mặt hàng!';

  @override
  String createOrderErrorWalletFetch(Object code) {
    return 'Lỗi khi lấy số dư ví: $code';
  }

  @override
  String get confirmOrderTitle => 'Xác nhận đơn hàng';

  @override
  String get confirmOrderSenderSection => 'Thông tin người gửi';

  @override
  String get confirmOrderReceiverSection => 'Thông tin người nhận';

  @override
  String get confirmOrderItemsSection => 'Chi tiết hàng hoá';

  @override
  String confirmOrderWalletBalance(Object balance) {
    return 'Số dư ví hiện tại: $balance VND';
  }

  @override
  String get confirmOrderDepositButton => 'Xác nhận đặt cọc 500.000 VND';

  @override
  String get confirmOrderDialogTitle => 'Thông báo';

  @override
  String get confirmOrderDialogFetchError => 'Không thể lấy số dư ví.';

  @override
  String get confirmOrderDialogInsufficientWallet => 'Số dư ví không đủ để tạo đơn hàng. Vui lòng nạp thêm.';

  @override
  String confirmOrderDialogCreateSuccess(Object code) {
    return 'Tạo đơn hàng thành công! Mã đơn: $code';
  }

  @override
  String get confirmOrderDialogCreateFailed => 'Tạo đơn thất bại!';

  @override
  String get confirmOrderDialogSessionExpired => 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';

  @override
  String confirmOrderDialogUnknownError(Object code) {
    return 'Lỗi không xác định. Mã lỗi: $code';
  }

  @override
  String get changePasswordTitle => 'Đổi mật khẩu';

  @override
  String get changePasswordNew => 'Mật khẩu mới';

  @override
  String get changePasswordConfirm => 'Xác nhận mật khẩu';

  @override
  String get againConfirmPasswordButton => 'Xác nhận';

  @override
  String get changePasswordBackLogin => 'Quay về đăng nhập';

  @override
  String get changePasswordErrorEmpty => 'Vui lòng nhập mật khẩu mới';

  @override
  String get changePasswordErrorWeak => 'Mật khẩu phải ≥8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt';

  @override
  String get changePasswordErrorConfirmEmpty => 'Vui lòng nhập lại mật khẩu';

  @override
  String get changePasswordErrorNotMatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công!';

  @override
  String get changePasswordEmailNotRegistered => 'Tài khoản email này chưa được đăng ký!';

  @override
  String get changePasswordFailed => 'Đổi mật khẩu thất bại!';

  @override
  String changePasswordConnectionError(Object error) {
    return 'Lỗi kết nối: $error';
  }

  @override
  String get orderStatusScreenTitle => 'Danh sách đơn hàng';

  @override
  String get orderStatusTabAll => 'Tất cả';

  @override
  String get orderStatusTabPickup => 'Đang đến lấy hàng';

  @override
  String get orderStatusTabInTransit => 'Đang trên đường đến kho';

  @override
  String get orderStatusTabAtHub => 'Đã đến kho';

  @override
  String get orderStatusTabAwaitingPayment => 'Chờ thanh toán';

  @override
  String get orderStatusTabAwaitingShipment => 'Chờ gửi hàng';

  @override
  String get orderStatusTabShipping => 'Đang vận chuyển';

  @override
  String get orderStatusTabDelivered => 'Giao hàng thành công';

  @override
  String get orderStatusTabCancelled => 'Đã hủy';

  @override
  String orderStatusLabel(Object status) {
    return 'Trạng thái: $status';
  }

  @override
  String orderPhoneLabel(Object phone) {
    return 'SĐT: $phone';
  }

  @override
  String orderBalancePaymentLabel(Object amount) {
    return 'Thanh toán số dư: $amount';
  }

  @override
  String orderCreatedDateLabel(Object date) {
    return 'Ngày tạo: $date';
  }

  @override
  String get orderItemListLabel => 'Danh sách hàng hóa:';

  @override
  String get orderUpdatedDetailsLabel => 'Chi tiết sau cập nhật';

  @override
  String get orderUpdatedNotice => 'Lưu ý: Đây là nội dung đã chỉnh trong màn hình \'Cập nhật đơn hàng\' (chưa gửi nếu chưa bấm nút hành động màu xanh).';

  @override
  String get orderActionChangeStatus => 'Đổi trạng thái';

  @override
  String get orderActionUpdateOrder => 'Cập nhật đơn hàng';

  @override
  String get orderSnackUpdateSuccess => 'Cập nhật đơn hàng thành công';

  @override
  String get orderSnackUpdateFailed => 'Cập nhật đơn hàng thất bại';

  @override
  String get orderSnackSessionExpired => 'Phiên đăng nhập hết hạn';

  @override
  String get contractorHomeAppBarTitle => 'Beluga Express';

  @override
  String get contractorHomeWelcomeTitle => 'Chào mừng đến với Beluga Express!';

  @override
  String get contractorHomeWelcomeMessage => 'Lựa chọn và cập nhật trạng thái đơn hàng khả dụng.';

  @override
  String get contractorHomeViewOrdersButton => 'Xem đơn khả dụng';

  @override
  String get contractorHomeTabHome => 'Trang chủ';

  @override
  String get contractorHomeTabOrders => 'Đơn hàng';

  @override
  String get contractorHomeTabProfile => 'Tài khoản';

  @override
  String get updateOrderAppBarTitle => 'Cập nhật đơn hàng';

  @override
  String get updateOrderItemTypeLabel => 'Loại hàng';

  @override
  String get updateOrderQuantityLabelKg => 'Kg';

  @override
  String updateOrderQuantityLabelUnit(Object unit) {
    return '$unit';
  }

  @override
  String get updateOrderDeleteItemTooltip => 'Xoá mặt hàng';

  @override
  String get updateOrderAddItemButton => 'Thêm mặt hàng';

  @override
  String get updateOrderConfirmDialogTitle => 'Xác nhận cập nhật đơn hàng';

  @override
  String get updateOrderConfirmDialogChangesLabel => 'Chi tiết thay đổi:';

  @override
  String get updateOrderConfirmButton => 'Cập nhật';

  @override
  String get updateOrderCancelButton => 'Huỷ';

  @override
  String get updateOrderInvalidQuantityMessage => 'Vui lòng nhập số lượng hợp lệ cho mỗi mặt hàng';

  @override
  String get updateOrderLoadingPricingMessage => 'Đang tải bảng giá...';

  @override
  String updateOrderPricingErrorMessage(Object error) {
    return 'Lỗi khi lấy bảng giá: $error';
  }

  @override
  String updateOrderPricingLoadedMessage(Object count) {
    return 'Đã tải $count mục trong bảng giá';
  }

  @override
  String get updateOrderNoItemsMessage => 'Chưa có hàng hóa. Nhấn Thêm để thêm.';

  @override
  String get cancel => 'Huỷ';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get update => 'Cập nhật';

  @override
  String get createOrderButton => 'Tạo đơn vận chuyển';

  @override
  String get profileContactUs => 'Liên hệ với chúng tôi';

  @override
  String get deleteAccountButton => 'xoá tài khoản';

  @override
  String get verificationCode => 'Mã OTP';

  @override
  String get confirmDeleteAccount => 'Bạn có chắc chắn xoá tài khoản này không?';
}
