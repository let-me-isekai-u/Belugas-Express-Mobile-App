using BelgulasShip.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class CountryApiController : ControllerBase
    {
        ApplicationDbContext db=new ApplicationDbContext();

        [HttpGet("get-country")]
        public IActionResult GetCountry()
        {
            var countries = db.Countries.Where(f=>f.IsActive == false)
                .Select(f => new
                {
                    f.Id,
                    f.Name,
                    f.Code,
                })
                .ToList();
            return Ok(countries);
        }
    }
}
