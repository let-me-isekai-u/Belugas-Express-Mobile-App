using BelgulasShip.DTOs;
using BelgulasShip.Models;
using Humanizer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class OrderApiController : ControllerBase
    {
        private readonly ApplicationDbContext db=new ApplicationDbContext();

        /// <summary>
        /// Lấy chi tiết đơn hàng theo Id
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderById(int id)
        {
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            if (accountId <= 0)
                return Unauthorized("Invalid token");

            var orders = await db.Orders
           .Where(o => o.CreateBy == accountId && o.Id == id)
           .Select(o => new
           {
               o.Id,
               o.OrderCode,
               o.SenderName,
               o.ReceiverName,
               o.SenderPhone,
               o.ReceiverPhone,
               o.SenderAddress,
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
           }).FirstOrDefaultAsync();

            if (orders == null)
                return NotFound("Không tìm thấy đơn hàng");

            return Ok(orders);
        }


        [HttpGet("my-orders")]
        public async Task<IActionResult> GetMyOrders()
        {
            // Lấy accountId từ token
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            if (accountId <= 0)
                return NotFound("Invalid token");

            var orders = await db.Orders
           .Where(o => o.CreateBy == accountId)
           .Select(o => new
           {
               o.Id,
               o.OrderCode,
               o.SenderName,
               o.ReceiverName,
               o.SenderPhone,
               o.ReceiverPhone,
               o.SenderAddress,
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

        [HttpPost("create")]
        public IActionResult CreateOrder([FromBody] CreateOrderRequest request)
        {
            try
            {
                // Lấy accountId từ token
                var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);

                // Sinh OrderCode
                string orderCode = "BS" + accountId + DateTime.Now.ToString("yyMMddHHmmss");

                var order = new Order
                {
                    OrderCode = orderCode,
                    SenderName = request.SenderName,
                    ReceiverName = request.ReceiverName,
                    SenderPhone = request.SenderPhone,
                    ReceiverPhone = request.ReceiverPhone,
                    SenderAddress = request.SenderAddress,
                    ReceiverAddress = request.ReceiverAddress,
                    DownPayment = request.DownPayment,
                    CountryId = request.CountryId,
                    Status = 1, // mặc định: 1 = chờ xử lý
                    CreateDate = DateTime.Now,
                    UpdateDate = DateTime.Now,
                    CreateBy = accountId,
                    PayWithBalance = request.PayWithBalance
                };

                db.Orders.Add(order);
                db.SaveChanges();

                foreach (var item in request.OrderItems)
                {
                    var orderItem = new OrderItem
                    {
                        OrderId = order.Id,
                        PricingTableId = item.PricingTableId,
                        WeightEstimate = item.WeightEstimate,
                        Price = item.Price,
                        Amount=item.WeightEstimate * item.Price
                    };
                    db.OrderItems.Add(orderItem);
                }

                var ac = db.Accounts.FirstOrDefault(a => a.Id == accountId);
                if (request.PayWithBalance != 0)
                {                  
                    if (request.PayWithBalance >= request.DownPayment)
                    {
                        ac.Wallet = ac.Wallet - request.DownPayment;
                        var payment = new Payment
                        {
                            AccountId = accountId,
                            Amount = -request.DownPayment,
                            PaymentFor = "Tiền cọc đơn hàng " + orderCode,
                            PaymentDate = DateTime.Now
                        };
                        db.Payments.Add(payment);
                    }
                    else
                    {
                        ac.Wallet = ac.Wallet - request.PayWithBalance;
                        var payment = new Payment
                        {
                            AccountId = accountId,
                            Amount = -request.PayWithBalance,
                            PaymentFor = "Tiền cọc đơn hàng " + orderCode,
                            PaymentDate = DateTime.Now
                        };
                        var payment2 = new Payment
                        {
                            AccountId = accountId,
                            Amount = -(request.DownPayment - request.PayWithBalance),
                            PaymentFor = "Chuyển khoản cọc đơn hàng " + orderCode,
                            PaymentDate = DateTime.Now
                        };
                        db.Payments.Add(payment);
                        db.Payments.Add(payment2);
                    }
                }
                else
                {
                    var payment = new Payment
                    {
                        AccountId = accountId,
                        Amount = -request.DownPayment,
                        PaymentFor = "Chuyển khoản cọc đơn hàng " + orderCode,
                        PaymentDate = DateTime.Now
                    };
                    db.Payments.Add(payment);
                }
                
                var orderStatus = new StatusOrderLog
                {
                    OrderId = order.Id,
                    Status = "Chờ xác nhận",
                    UpdateBy = accountId,
                    UpdateDate = DateTime.Now
                };
                db.StatusOrderLogs.Add(orderStatus);
                db.SaveChanges();
                return Ok(new
                {
                    success = true,
                    message = "Tạo đơn hàng thành công " + orderCode,
                    orderId = order.Id,
                    orderCode = order.OrderCode
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi tạo đơn, có thể các kiểu dữ liệu bị sai: " + ex.Message
                });
            }
        }
    }
}
