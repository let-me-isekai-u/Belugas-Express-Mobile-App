using BelgulasShip.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BelgulasShip.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class HomeApiController : ControllerBase
    {
        public ApplicationDbContext db = new ApplicationDbContext();

        [Authorize]
        [HttpGet("profile")]
        public IActionResult GetProfile()
        {
            var email = User.FindFirst(ClaimTypes.Email)?.Value;
            var acc = db.Accounts.FirstOrDefault(x => x.Email == email);

            if (acc == null) return NotFound();

            return Ok(new
            {
                FullName = acc.FullName,
                Wallet = acc.Wallet,
                PhoneNumber = acc.PhoneNumber,
                Email = acc.Email,
            });
        }

    }
}
