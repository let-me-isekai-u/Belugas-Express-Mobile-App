using BelgulasShip.DTOs;
using BelgulasShip.Models;
using Humanizer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class OrderApiController : ControllerBase
    {
        private readonly ApplicationDbContext db=new ApplicationDbContext();

        //Cập nhật lại danh sách đơn hàng
        [HttpPost("update-order-item")]
        public async Task<IActionResult> UpdateOrderItems([FromBody] UpdateOrderItemsRequest request)
        {
            //check token xem có phải nhà thầu không
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            int role = db.Accounts.FirstOrDefault(a => a.Id == accountId).Role ?? 0;
            if (role != 2)
                return Unauthorized("Account không có vai trò là nhà thầu");
            //Kiểm tra đơn hàng có tồn tại không
            var order = await db.Orders.FindAsync(request.OrderId);
            if (order == null)
                return NotFound(new { success = false, message = "Không tìm thấy đơn hàng." });

            // Lấy danh sách OrderItem cũ
            var existingItems = db.OrderItems.Where(x => x.OrderId == request.OrderId).ToList();

            // 1️⃣ Xóa toàn bộ item cũ
            if (existingItems.Any())
                db.OrderItems.RemoveRange(existingItems);

            // 2️⃣ Thêm lại toàn bộ item mới
            decimal total = 0;
            foreach (var item in request.OrderItems)
            {
                var newItem = new OrderItem
                {
                    OrderId = request.OrderId,
                    PricingTableId = item.PricingTableId,
                    WeightEstimate = item.WeightEstimate,
                    Price = item.Price,
                    Amount = item.WeightEstimate * item.Price
                };
                total += item.WeightEstimate * item.Price;
                db.OrderItems.Add(newItem);
            }

            // 3️⃣ Cập nhật thời gian sửa đơn
            order.Status = 4;
            order.UpdateDate = DateTime.Now;
            //cập nhật trạng thái
            var orderStatus = new StatusOrderLog
            {
                OrderId = order.Id,
                Status = "Chờ thanh toán",
                UpdateBy = accountId,
                UpdateDate = DateTime.Now
            };
            db.StatusOrderLogs.Add(orderStatus);
            //Kiểm tra nếu tiền cọc đủ thì chuyển luôn sang trạng thái 5
            if(total <= order.DownPayment)
            {
                // 3️⃣ Cập nhật thời gian sửa đơn
                order.Status = 5;
                order.UpdateDate = DateTime.Now;
                //cập nhật trạng thái
                var orderStatus1 = new StatusOrderLog
                {
                    OrderId = order.Id,
                    Status = "Chờ gửi hàng",
                    UpdateBy = accountId,
                    UpdateDate = DateTime.Now
                };
                db.StatusOrderLogs.Add(orderStatus1);

                if (total < order.DownPayment)
                {
                    db.Accounts.FirstOrDefault(a => a.Id == accountId).Wallet += order.DownPayment - total;
                }
            }

            await db.SaveChangesAsync();

            return Ok(new { success = true, message = "Cập nhật chi tiết đơn hàng thành công." });
        }
        public class UpdateOrderItemsRequest
        {
            public int OrderId { get; set; }
            public List<OrderItemDto> OrderItems { get; set; }
        }


        //Thay đổi trạng thái từ 2 sang 3
        [HttpPut("change-status")]        
        public async Task<ActionResult> ChangeStatus2To3([FromBody] ChangeStatusRequest request)
        {
            //check token xem có phải nhà thầu không
            var accountId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            int role = db.Accounts.FirstOrDefault(a => a.Id == accountId).Role ?? 0;
            if (role != 2)
                return Unauthorized("Account không có vai trò là nhà thầu");

            //check xem đơn hàng tồn tại hay không
            var order = await db.Orders.FirstOrDefaultAsync(o => o.Id == request.OrderId);
            if (order == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng." });
            }

            //Không được đổi trạng thái 1 sang 2, và từ 4 sang 5
            if (order.Status == 1 || order.Status == 4)
            {
                return StatusCode(222, new {message="Không thể thay đổi trạng thái 1 sang 2 hoặc 4 sang 5 từ api này!" });
            }

            // 3. Kiểm tra hợp lệ — chỉ được tăng 1 đơn vị
            if (request.NewStatus != order.Status + 1)
            {
                return BadRequest(new
                {
                    message = $"Không thể chuyển trạng thái từ {order.Status} sang {request.NewStatus}. " +
                              $"Chỉ được phép chuyển sang {order.Status + 1}."
                });
            }

            // Cập nhật trạng thái
            order.Status = request.NewStatus;
            order.UpdateDate = DateTime.Now;

            var orderStatus = new StatusOrderLog
            {
                OrderId = order.Id,
                Status = "Đã đến kho",
                UpdateBy = accountId,
                UpdateDate = DateTime.Now
            };
            db.StatusOrderLogs.Add(orderStatus);
            await db.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = $"Cập nhật trạng thái đơn hàng {order.OrderCode} thành công.",
                newStatus = order.Status,
                orderId = order.Id,

            });
        }
        public class ChangeStatusRequest
        {
            public int OrderId { get; set; }
            public int NewStatus { get; set; }
        }

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
                    Status = "Đang đến lấy hàng",
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
