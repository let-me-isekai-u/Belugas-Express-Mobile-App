using BelgulasShip.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class ContractorApiController : ControllerBase
    {
        private readonly ApplicationDbContext db = new ApplicationDbContext();

        
        [HttpGet("orders")]
        [Authorize]
        public async Task<IActionResult> OrderByContractor()
        {
            // Lấy accountId từ token
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            if (accountId <= 0)
                return NotFound("Invalid token");
            int countryid = db.Accounts.FirstOrDefault(a => a.Id == accountId).CountryId ?? 0;

            var orders = await db.Orders
           .Where(o => o.CountryId == countryid)
           .Select(o => new
           {
               o.Id,
               o.OrderCode,
               //o.SenderName,
               o.ReceiverName,
               //o.SenderPhone,
               o.ReceiverPhone,
               //o.SenderAddress,
               o.ReceiverAddress,
               o.DownPayment,
               o.CountryId,
               o.Status,
               o.CreateDate,
               o.UpdateDate,
               o.PayWithBalance,

               // Lấy items kèm thông tin PricingTable
               Items = db.OrderItems
                   .Where(oi => oi.OrderId == o.Id)
                   .Join(db.PricingTables,
                         oi => oi.PricingTableId,
                         pt => pt.Id,
                         (oi, pt) => new
                         {
                             oi.Id,
                             oi.WeightEstimate,
                             oi.WeightReal,
                             oi.Price,
                             oi.Amount,
                             pt.Name,
                             pt.Unit
                         })
                   .ToList()
           })
           .ToListAsync();

            if (!orders.Any())
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng nào của user này." });
            }

            return Ok(orders);
        }
    }
}
