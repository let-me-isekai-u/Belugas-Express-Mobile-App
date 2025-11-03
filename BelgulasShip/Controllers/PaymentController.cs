using BelgulasShip.Models;
using Microsoft.AspNetCore.Mvc;

namespace BelgulasShip.Controllers
{
    public class PaymentController : Controller
    {
        private ApplicationDbContext db = new ApplicationDbContext();
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult GetAllPayment()
        {
            return View();
        }
    }
}
