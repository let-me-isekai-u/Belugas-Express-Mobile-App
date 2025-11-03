using BelgulasShip.Models;
using BelgulasShip.DTOs;
using Microsoft.AspNetCore.Mvc;
using BelgulasShip.Config;
using System.Security.Cryptography;
using BelgulasShip.Repository;

namespace P2P.Controllers
{
    public class AccountDetailsController : Controller
    {
        public AccountRepository _accRepo = new AccountRepository();
        public IActionResult Index()
        {
            Account acc = _accRepo.GetByID(HttpContext.Session.GetInt32("AccountId") ?? 0) ?? new Account();
            if (acc.Id <= 0)
            {
                return Redirect("/Home/Index");
            }

            //acc.AvatarUrl = string.IsNullOrWhiteSpace(acc.AvatarUrl) ? "/assets/images/user.png" : acc.AvatarUrl;
            ViewBag.Account = acc;

            return View();
        }

        [HttpPost]
        public async Task<JsonResult> UpdateAccount([FromBody] Account account)
        {
            Account accSesion = _accRepo.GetByID(HttpContext.Session.GetInt32("AccountId") ?? 0) ?? new Account();
            if (accSesion.Id <= 0)
            {
                return  Json(new { status = 0, message = "Đã hết phiên đăng nhập! Vui lòng đăng nhập lại để sử dụng chức năng!" });
            }


            Account model = _accRepo.GetByID(account.Id) ?? new Account();
            if (model.Id <= 0) return Json(new { status = 0, message = "Không tìm thấy tài khoản!" });

            model.PhoneNumber = account.PhoneNumber;
            model.FullName = account.FullName;
            _accRepo.Update(model);


            return Json(new { status = 1, message = "Cập nhật thành công!", data = model });
        }
        
        [HttpPost]
        public async Task<JsonResult> UpdatePassword([FromBody] PasswordDTO data)
        {
            Account account = _accRepo.GetByID(data.AccountID) ?? new Account();
            if(account.Id <= 0)
            {
                return Json(new { status = 0, message = "Không tìm thấy tài khoản!" });
            }
            else if (string.IsNullOrWhiteSpace(data.OldPassword))
            {
                return Json(new { status = 0, message = "Mật khẩu cũ không được để trống!" });
            }
            else if (string.IsNullOrWhiteSpace(data.NewPassword))
            {
                return Json(new { status = 0, message = "Mật khẩu mới không được để trống!" });
            }
            else if (string.IsNullOrWhiteSpace(data.ConfirmPassword))
            {
                return Json(new { status = 0, message = "Mật khẩu xác thực không được để trống!" });
            }
            else if (data.ConfirmPassword.Trim() != data.NewPassword)
            {
                return Json(new { status = 0, message = "Mật khẩu xác thực không chính xác! Vui lòng nhập lại!" });
            }
            else if (data.OldPassword.Trim() != MaHoaMD5.DecryptPassword(account.Password ?? "MQA="))
            {
                return Json(new { status = 0, message = "Mật khẩu cũ không chính xác! Vui lòng nhập lại!" });
            }

            account.Password = MaHoaMD5.EncryptPassword(data.NewPassword);
            _accRepo.Update(account);
            return Json(new { status = 1, message = "Cập nhật thành công!" });
        }

        public class PasswordDTO
        {
            public int AccountID { get; set; }
            public string OldPassword { get; set; }
            public string NewPassword { get; set; }
            public string ConfirmPassword { get; set; }
        }
    }
}
