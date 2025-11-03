using BelgulasShip.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class PricingTableApiController : ControllerBase
    {
        private ApplicationDbContext db = new ApplicationDbContext();

        [HttpGet("get-pricing-table/{id}")]
        public IActionResult GetPrice(int id)
        {
            //if(id == 0)
            //{
            //    return StatusCode(101, "Lỗi mẹ nó rồi");
            //}
            var list=db.PricingTables.Where(p=> p.CountryId == id)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.Unit,
                    p.PricePerKilogram,
                    p.Descriptiion
                })
                .ToList();
            if(list.Count == 0 || list == null)
            {
                return StatusCode(100);
            }
            return Ok(list);
        }
    }
}
