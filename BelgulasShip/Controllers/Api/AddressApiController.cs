using BelgulasShip.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class AddressApiController : ControllerBase
    {
        private readonly ApplicationDbContext db = new ApplicationDbContext();

        [HttpGet("provinces")]
        public async Task<IActionResult> GetProvinces()
        {
            var provinces = await db.Provinces
                .Select(p => new { p.Id, p.Name })
                .OrderBy(p => p.Id)
                .ToListAsync();

            return Ok(provinces);
        }

        // GET: api/location/wards/{province_id}
        [HttpGet("wards/{province_id}")]
        public async Task<IActionResult> GetWardsByProvince(int province_id)
        {
            var wards = await db.Wards
                .Where(w => w.ProvinceId == province_id)
                .Select(w => new { w.Id, w.Name })
                .OrderBy(w => w.Id)
                .ToListAsync();

            if (!wards.Any())
                return NotFound(new { message = "Không tìm thấy phường/xã cho tỉnh này." });

            return Ok(wards);
        }
    }
}
