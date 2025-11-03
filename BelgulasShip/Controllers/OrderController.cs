using BelgulasShip.Models;
using Microsoft.AspNetCore.Mvc;

namespace BelgulasShip.Controllers
{
    public class OrderController : Controller
    {
        private ApplicationDbContext db = new ApplicationDbContext();
        public IActionResult Index()
        {
            return View();
        }
        public IActionResult FindOrder()
        {
            int accoutId = HttpContext.Session.GetInt32("AccountId") ?? 0;
            if (accoutId <= 0)
            {
                return Redirect("/Home/Login");
            }
            return View();
        }

        
        public IActionResult FindOrderCode(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return Json(new { success = false, message = "Thiếu mã giao dịch." });
            }

            Order result = db.Orders.FirstOrDefault(o => o.OrderCode == id);

            if (result != null)
            {
                return Json(new { success = true, data = result });
            }

            return Json(new { success = false, message = "Không tìm thấy giao dịch." });
        }
    }
}
