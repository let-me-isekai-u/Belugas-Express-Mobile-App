using BelgulasShip.Models;
using BelgulasShip.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Net.Http;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentApiController : ControllerBase
    {
        private readonly ApplicationDbContext db = new ApplicationDbContext();
        private readonly HttpClient _httpClient;

        public PaymentApiController(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

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

        [HttpGet("check-transaction")]
        public async Task<IActionResult> CheckGoogleSheetTransaction([FromBody] CheckTransactionRequest request)
        {
            string url = "https://script.google.com/macros/s/AKfycbyB5JISCpIjFJp9ikNS00RP34ywViepMogpyjAXaLgimbYkqSFb2KiY5APofTMW2arP_A/exec";

            try
            {
                var response = await _httpClient.GetAsync(url);
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                //Console.WriteLine(json); // debug nếu cần

                var dataResponse = JsonConvert.DeserializeObject<GoogleSheetResponse>(json);

                if (dataResponse?.Data == null || dataResponse.Data.Count == 0)
                    return Ok(new { success = false, message = "Không có dữ liệu trong Google Sheet." });

                string normalizedContent = (request.Content ?? "").Trim().ToUpperInvariant();

                var match = dataResponse.Data.FirstOrDefault(item =>
                {
                    if (!decimal.TryParse(item.Values_0_2, out var amountValue))
                        return false; // bỏ qua dòng header hoặc dòng lỗi

                    return amountValue == request.Amount &&
                           !string.IsNullOrEmpty(item.Values_0_9) &&
                           item.Values_0_9.ToUpperInvariant().Contains(normalizedContent);
                });

                if (match != null)
                {
                    return Ok(new
                    {
                        success = true,
                        message = "✅ Tìm thấy giao dịch khớp.",
                        transaction = new
                        {
                            code = match.Values_0_3,
                            time = match.Values_0_1,
                            amount = match.Values_0_2,
                            content = match.Values_0_9
                        }
                    });
                }

                return Ok(new { success = false, message = "Không tìm thấy giao dịch phù hợp." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Lỗi: {ex.Message}" });
            }
        }


        public class CheckTransactionRequest
        {
            public decimal Amount { get; set; }
            public string Content { get; set; } = string.Empty;
        }
        public class GoogleSheetResponse
        {
            [JsonProperty("data")]
            public List<TransactionItem>? Data { get; set; }

            [JsonProperty("error")]
            public bool Error { get; set; }
        }

        public class TransactionItem
        {
            [JsonProperty("values_0_0")]
            public string? Values_0_0 { get; set; }

            [JsonProperty("values_0_1")]
            public string? Values_0_1 { get; set; }

            [JsonProperty("values_0_2")]
            public string? Values_0_2 { get; set; }

            [JsonProperty("values_0_3")]
            public string? Values_0_3 { get; set; }

            [JsonProperty("values_0_9")]
            public string? Values_0_9 { get; set; }
        }

    }
}
