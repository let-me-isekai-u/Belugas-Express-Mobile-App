using BelgulasShip.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentApiController : ControllerBase
    {
        private readonly ApplicationDbContext db = new ApplicationDbContext();
        [Authorize]
        [HttpGet("get-history-payment")]
        public IActionResult HistoryPayment()
        {
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            if (accountId <= 0)
                return NotFound("Invalid token");
            var payments = db.Payments
                .Where(o => o.AccountId == accountId)
                .OrderByDescending(o => o.PaymentDate)
                .Select(o => new
                {
                    o.Id,
                    o.Amount,
                    o.PaymentFor,
                    o.PaymentDate
                })
                .ToList();

            return Ok(payments);
        }
    }
}
