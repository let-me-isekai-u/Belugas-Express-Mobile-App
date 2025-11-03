using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class Payment
{
    public int Id { get; set; }

    public int? AccountId { get; set; }

    public decimal? Amount { get; set; }

    public string? PaymentFor { get; set; }

    public DateTime? PaymentDate { get; set; }
}
