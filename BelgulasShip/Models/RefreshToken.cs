using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class RefreshToken
{
    public int Id { get; set; }

    public int? AccountId { get; set; }

    public string? Token { get; set; }

    public DateTime? ExpiryDate { get; set; }

    public bool? IsRevoked { get; set; }
}
