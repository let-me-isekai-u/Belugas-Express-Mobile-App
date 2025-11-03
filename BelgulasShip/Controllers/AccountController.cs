using BelgulasShip.Config;
using BelgulasShip.Models;
using BelgulasShip.Repository;
using BelgulasShip.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BelgulasShip.Controllers
{
    public class AccountController : Controller
    {
        public AccountRepository _accRepo = new AccountRepository();
        public ApplicationDbContext db= new ApplicationDbContext();
        private readonly EmailService _emailService;

        public AccountController(EmailService emailService)
        {
            _emailService = emailService;
        }
        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public IActionResult Login()
        {
            HttpContext.Session.Clear();
            return View();
        }

        [HttpGet]
        public JsonResult GetMoneyInWallet()
        {
            Account acc = _accRepo.GetByID(HttpContext.Session.GetInt32("AccountId") ?? 0) ?? new Account();
            decimal? data = acc.Wallet;
            return Json(data ?? 0);
        }
        public IActionResult Login(string Email, string Password)
        {
            string passwordHash = MaHoaMD5.EncryptPassword(Password);
            Account acc = _accRepo.GetAll().FirstOrDefault(x => x.PhoneNumber.ToLower() == Email.ToLower() && x.Password == passwordHash && x.IsDelete == false) ?? new Account();

            if (acc.Id <= 0)
            {
                return Json(new { success = false, message = "Tài khoản hoặc mật khẩu không chính xác!" });
            }

            if (acc.IsDelete == true)
            {
                return Json(new { success = false, message = "Tài khoản đã bị khóa! Không thể đăng nhập!" });
            }

            // ✅ Lưu Session (thời gian ngắn, ví dụ 30 phút)
            HttpContext.Session.SetInt32("AccountId", acc.Id);
            HttpContext.Session.SetString("FullName", acc.FullName ?? "");
            HttpContext.Session.SetInt32("AccountRole", acc.Role ?? 1);

            // ✅ Nếu chọn RememberMe -> lưu cookie 90 ngày
            CookieOptions option = new CookieOptions
            {
                Expires = DateTime.Now.AddDays(90), // 90 ngày
                HttpOnly = true,
                IsEssential = true
            };
            Response.Cookies.Append("RememberMeId", acc.Id.ToString(), option);

            string redirectUrl = acc.Role > 1 ? Url.Action("Index", "Admin") : Url.Action("Index", "Home");
            return Json(new { success = true, redirectUrl });
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            Response.Cookies.Delete("RememberMeId");
            return RedirectToAction("Login");
        }

        [HttpGet]
        public async Task<JsonResult> SendVerificationCode(string email)
        {
            if (string.IsNullOrEmpty(email))
                return Json(new { success = false, message = "Email không hợp lệ" });

            // Tạo mã ngẫu nhiên 6 chữ số
            var code = new Random().Next(100000, 999999).ToString();

            // Lưu mã vào Session
            HttpContext.Session.SetString("VerificationCode", code);
            HttpContext.Session.SetString("VerificationEmail", email);
            HttpContext.Session.SetString("VerificationTime", DateTime.UtcNow.ToString());

            // Gửi email
            var subject = "Mã xác nhận từ Begulas";
            var body = $"Mã xác nhận của bạn là: {code}.\nVui lòng sử dụng trong vòng 10 phút.";

            try
            {
                await _emailService.SendEmailAsync(email, subject, body);
                return Json(new { success = true, message = "Mã xác nhận đã được gửi đến: " });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Lỗi khi gửi email: " + ex.Message });
            }
        }



        

        [HttpGet]
        public IActionResult ForgotPassword()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> ForgotPassword(string email, string verificationCode)
        {
            if (
                string.IsNullOrWhiteSpace(verificationCode))
            {
                return Json(new { success = false, message = "Vui lòng điền đầy đủ thông tin." });
            }

            // Kiểm tra mã xác nhận
            var code = HttpContext.Session.GetString("VerificationCode");
            var emailSession = HttpContext.Session.GetString("VerificationEmail");
            var timeStr = HttpContext.Session.GetString("VerificationTime");

            if (code == null || emailSession == null || timeStr == null)
                return Json(new { success = false, message = "Mã xác nhận không tồn tại. Vui lòng gửi lại mã." });

            if (verificationCode.Trim() != code)
                return Json(new { success = false, message = "Mã xác nhận không chính xác." });

            if (DateTime.TryParse(timeStr, out var time) && (DateTime.UtcNow - time).TotalMinutes > 10)
                return Json(new { success = false, message = "Mã xác nhận đã hết hạn." });

            HttpContext.Session.Remove("VerificationCode");
            //HttpContext.Session.Remove("VerificationEmail");
            HttpContext.Session.Remove("VerificationTime");

            return Json(new { success = true });
        }

        [HttpPost]
        public async Task<IActionResult> ConfirmChangePassword(string password, string confirmPassword)
        {
            if (password == null || confirmPassword == null)
            {
                return Json(new { success = false, message = "Vui lòng điền đầy đủ thông tin!." });
            }

            if (password != confirmPassword)
                return Json(new { success = false, message = "Mật khẩu xác nhận không khớp." });

            // Tạo mật khẩu mới
            string? email = HttpContext.Session.GetString("VerificationEmail");
            //string sql = $"SELECT * FROM [Account] WHERE Email = '{email}'";
            //var acc = SQLHelper<Account>.SqlToList(sql).FirstOrDefault();
            var acc=db.Accounts.Where(a=>a.Email == email).FirstOrDefault();
            if (acc != null)
            {
                acc.Password = MaHoaMD5.EncryptPassword(password);
            }
            else
            {
                return Json(new { success = false, message = "Có lỗi xảy ra, vui lòng thử lại!" });
            }

            db.SaveChanges();

            HttpContext.Session.SetInt32("AccountId", acc.Id);
            HttpContext.Session.SetInt32("AccountRole", acc.Role??0);
            HttpContext.Session.SetString("FullName", acc.FullName ?? "");

            HttpContext.Session.Remove("VerificationEmail");

            return Json(new { success = true, redirectUrl = Url.Action("Index", "Home") });
        }

        [HttpGet]
        public IActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Check(string email, string password, string confirmPassword, string fullname, string phone)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password) ||
                string.IsNullOrWhiteSpace(confirmPassword) || string.IsNullOrWhiteSpace(fullname))
            {
                return Json(new { success = false, message = "Vui lòng điền đầy đủ thông tin." });
            }

            if (password != confirmPassword)
                return Json(new { success = false, message = "Mật khẩu xác nhận không khớp." });

            if (_accRepo.GetAll().Any(x => x.Email == email))
                return Json(new { success = false, message = "Email đã được sử dụng." });

            return Json(new { success = true, message = "Check thông tin thành công" });
        }

        [HttpPost]
        public async Task<IActionResult> Register(string email, string password, string confirmPassword, string fullname, string verificationCode, string phone)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password) ||
                string.IsNullOrWhiteSpace(confirmPassword) || string.IsNullOrWhiteSpace(fullname) ||
                string.IsNullOrWhiteSpace(verificationCode))
            {
                return Json(new { success = false, message = "Vui lòng điền đầy đủ thông tin." });
            }

            if (password != confirmPassword)
                return Json(new { success = false, message = "Mật khẩu xác nhận không khớp." });

            if (_accRepo.GetAll().Any(x => x.Email == email))
                return Json(new { success = false, message = "Email đã được sử dụng." });

            // Kiểm tra mã xác nhận
            var code = HttpContext.Session.GetString("VerificationCode");
            var emailSession = HttpContext.Session.GetString("VerificationEmail");
            var timeStr = HttpContext.Session.GetString("VerificationTime");

            if (code == null || emailSession == null || timeStr == null)
                return Json(new { success = false, message = "Mã xác nhận không tồn tại. Vui lòng gửi lại mã." });

            if (email != emailSession)
                return Json(new { success = false, message = "Email không khớp với email đã yêu cầu mã." });

            if (verificationCode.Trim() != code)
                return Json(new { success = false, message = "Mã xác nhận không chính xác." });

            if (DateTime.TryParse(timeStr, out var time) && (DateTime.UtcNow - time).TotalMinutes > 10)
                return Json(new { success = false, message = "Mã xác nhận đã hết hạn." });

            // Tạo tài khoản
            var acc = new Account
            {
                Email = email,
                Password = MaHoaMD5.EncryptPassword(password),
                FullName = fullname,
                PhoneNumber = phone,
                Role = 1,
                IsDelete = false,
                CreateDate = DateTime.Now,
                Wallet = 0
            };

            await _accRepo.CreateAsync(acc); 

            HttpContext.Session.SetInt32("AccountId", acc.Id);
            HttpContext.Session.SetInt32("AccountRole", acc.Role??0);
            HttpContext.Session.SetString("FullName", acc.FullName ?? "");

            HttpContext.Session.Remove("VerificationCode");
            HttpContext.Session.Remove("VerificationEmail");
            HttpContext.Session.Remove("VerificationTime");

            return Json(new { success = true, redirectUrl = Url.Action("Index", "Home") });
        }

    }
}
