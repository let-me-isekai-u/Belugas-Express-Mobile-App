using Azure.Core;
using BelgulasShip.Models;
using BelgulasShip.DTOs;
using BelgulasShip.Repository;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity.Data;
using Microsoft.AspNetCore.Mvc;
using BelgulasShip.Config;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;
using System.Linq;
using BelgulasShip.Service;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountApiController : ControllerBase
    {
        public ApplicationDbContext db=new ApplicationDbContext();
        public AccountRepository _accRepo = new AccountRepository();
        public RefreshTokenRepository _refreshRepo = new RefreshTokenRepository();
        private readonly IConfiguration _config;
        private readonly EmailService _emailService;
        public AccountApiController(IConfiguration config, EmailService emailService)
        {
            _config = config;
            _emailService = emailService;
        }

        [HttpPost("forgot-password")]
        public IActionResult ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var mail=db.Accounts.FirstOrDefault(a=>a.Email==request.Email);
            if (mail == null)
            {
                return BadRequest(new { success = false, message = "Tài khoản email này chưa được đăng ký tài khoản!" });
            }
            mail.Password=MaHoaMD5.EncryptPassword(request.Password);
            db.SaveChanges();
            return Ok();
        }

        [HttpPost("verify-code")]
        public IActionResult VerifyCode([FromBody] VerifyCodeRequest request)
        {
            var record = db.VerificationCodes
                .FirstOrDefault(x => x.Email == request.Email
                                  && x.Code == request.Code
                                  && x.IsUsed == false
                                  && x.ExpireAt > DateTime.UtcNow);

            if (record == null)
                return BadRequest(new { success = false, message = "Mã không hợp lệ hoặc đã hết hạn" });

            record.IsUsed = true;
            db.SaveChanges();

            return Ok(new { success = true, message = "Xác minh thành công" });
        }

        public class VerifyCodeRequest
        {
            public string Email { get; set; }
            public string Code { get; set; }
        }

        public class ForgotPasswordRequest
        {
            public string Email { get; set; }
            public string Password { get; set; }
        }

        [HttpPost("send-verification-code")]
        public async Task<IActionResult> SendVerificationCode([FromBody] string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return BadRequest(new { success = false, message = "Email không hợp lệ" });

            // Tạo mã ngẫu nhiên 6 chữ số
            var code = new Random().Next(100000, 999999).ToString();

            // Soạn email
            var subject = "Mã xác nhận từ Begulas";
            var body = $"Mã xác nhận của bạn là: {code}.\nVui lòng sử dụng trong vòng 10 phút.";

            try
            {
                await _emailService.SendEmailAsync(email, subject, body);

                var vercode=db.VerificationCodes.FirstOrDefault(x=>x.Email==email);
                if(vercode == null)
                {
                    db.VerificationCodes.Add(new VerificationCode
                    {
                        Email = email,
                        Code = code,
                        ExpireAt = DateTime.UtcNow.AddMinutes(10),
                        IsUsed = false
                    });
                    db.SaveChanges();
                }
                else
                {
                    vercode.Code = code;
                    vercode.ExpireAt = DateTime.UtcNow.AddMinutes(10);
                    vercode.IsUsed = false;
                    db.SaveChanges();
                }

                return Ok(new
                {
                    success = true,
                    message = "Mã xác nhận đã được gửi thành công",
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi gửi email: " + ex.Message
                });
            }
        }


        [HttpPost("register")]
        public IActionResult Register([FromBody] DTOs.RegisterRequest request)
        {
            if (_accRepo.GetAll().Any(x => x.Email == request.Email)) return Conflict("Email đã được liên kết với tài khoản khác!");
            if (_accRepo.GetAll().Any(x => x.PhoneNumber == request.PhoneNumber)) return Conflict("Số điện thoại đã được đăng ký!");

            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password) ||
                string.IsNullOrWhiteSpace(request.FullName) || string.IsNullOrWhiteSpace(request.PhoneNumber) ||
                string.IsNullOrWhiteSpace(request.Code))
            {
                return BadRequest("Lỗi dữ liệu");
            }

            var record = db.VerificationCodes.FirstOrDefault(x => x.Email == request.Email
                          && x.Code == request.Code
                          && x.IsUsed == false
                          && x.ExpireAt > DateTime.UtcNow);

            if (record == null) { 
                return Unauthorized(new { success = false, message = "Mã không hợp lệ hoặc đã hết hạn" });
            }
            record.IsUsed = true;
            db.SaveChanges();

            var account = new Account
            {
                Email = request.Email,
                Password = MaHoaMD5.EncryptPassword(request.Password),
                FullName = request.FullName,
                PhoneNumber = request.PhoneNumber,
                Address = "",
                Role = 1,                     // mặc định user
                Wallet = 0,                   // mặc định 0
                CreateDate = DateTime.Now,
                UpdateAt = DateTime.Now,
                IsDelete = false,
                ReferredByCode = request.ReferredByCode,
                ReferralCode = GenerateReferralCode(),
                PhoneZalo=request.PhoneZalo
            };
            _accRepo.Create(account);
            return Ok("Đăng ký thành công");
        }

        public string GenerateReferralCode()
        {
            string code;
            do
            {
                code =Convert.ToBase64String(Guid.NewGuid().ToByteArray())
                                    .Replace("=", "")
                                    .Replace("+", "")
                                    .Replace("/", "")
                                    .Substring(0, 8)
                                    .ToUpper();
            }
            while (db.Accounts.Any(a => a.ReferralCode == code)); // ✅ Check trùng

            return code;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] DTOs.LoginRequest request)
        {
            string passwordHash = MaHoaMD5.EncryptPassword(request.Password);
            Account acc = _accRepo.GetAll().FirstOrDefault(x => x.PhoneNumber.ToLower() == request.PhoneNumber.ToLower() && x.Password == passwordHash) ?? new Account();

            if (acc.Id <= 0)
            {
                return Unauthorized("Sai số điện thoại hoặc mật khẩu");
            }
            if (acc.IsDelete == true)
            {
                return NotFound("Tài khoản đã bị khóa! Không thể đăng nhập!");
            }
            string accessToken = JwtHelper.GenerateAccessToken(acc, _config["Jwt:SecretKey"]);
            string refreshToken = JwtHelper.GenerateRefreshToken();

            var userToken = db.RefreshTokens
                .FirstOrDefault(rt => rt.AccountId == acc.Id);

            //Nếu đăng nhập lại, hoặc đăng nhập ở máy khác thì sẽ cập nhật refresh token chứ không tạo mới
            if (userToken != null)
            {
                // Cập nhật refresh token
                userToken.Token = refreshToken;
                userToken.ExpiryDate = DateTime.UtcNow.AddDays(7);
                db.SaveChanges();
            }
            // Lưu refresh token vào DB
            var newRefresh = new RefreshToken
            {
                AccountId = acc.Id,
                Token = refreshToken,
                ExpiryDate = DateTime.UtcNow.AddDays(90),
                IsRevoked = false
            };
            _refreshRepo.Create(newRefresh);

            return Ok(new LoginResponse
            {
                Id = acc.Id,
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                FullName = acc.FullName,
                Email = acc.Email,
                Role = acc.Role ?? 1
            });
        }

        [HttpPost("refresh")]
        public IActionResult Refresh([FromBody] RefreshTokenRequest request)
        {
            var refreshToken = db.RefreshTokens
                .FirstOrDefault(rt => rt.Token == request.RefreshToken);

            if (refreshToken == null || refreshToken.ExpiryDate < DateTime.UtcNow)
            {
                return Unauthorized("Token hết hạn, vui lòng đăng nhập lại");
            }

            var acc = _accRepo.GetByID(refreshToken.AccountId ?? -1);
            string newAccessToken = JwtHelper.GenerateAccessToken(acc, _config["Jwt:SecretKey"]);
            string newRefreshToken = JwtHelper.GenerateRefreshToken();

            // Cập nhật refresh token
            refreshToken.Token = newRefreshToken;
            refreshToken.ExpiryDate = DateTime.UtcNow.AddDays(90);
            db.SaveChanges();

            return Ok(new RefreshTokenResponse
            {
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken
            });
        }
    }
}
