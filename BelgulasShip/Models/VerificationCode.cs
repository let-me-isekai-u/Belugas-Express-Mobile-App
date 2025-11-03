using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class VerificationCode
{
    public int Id { get; set; }

    public string? Email { get; set; }

    public string? Code { get; set; }

    public DateTime? ExpireAt { get; set; }

    public bool? IsUsed { get; set; }
}
