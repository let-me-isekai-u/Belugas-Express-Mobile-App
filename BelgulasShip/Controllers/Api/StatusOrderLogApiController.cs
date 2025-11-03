using BelgulasShip.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatusOrderLogApiController : ControllerBase
    {
        private readonly ApplicationDbContext db = new ApplicationDbContext();

        [Authorize]
        [HttpPost("additional-transfer")]
        public IActionResult ChangStatus(AdditionalTransfer request)
        {
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            if (accountId <= 0)
                return Conflict("AccountId nhỏ hơn không, không tồn tại");
            var StatusOrder = new StatusOrderLog()
            {
                OrderId = request.OrderId,
                Status = "Đã thanh toán tiền thiếu",
                UpdateBy = accountId,
                UpdateDate = DateTime.UtcNow,
            };
            db.StatusOrderLogs.Add(StatusOrder);
            db.SaveChanges();
            return Ok();
        }

        public class AdditionalTransfer
        {
            public int OrderId { get; set; }
            public decimal Amount { get; set; }
        }
    }
}
