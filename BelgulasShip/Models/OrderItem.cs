using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class OrderItem
{
    public int Id { get; set; }

    public int? OrderId { get; set; }

    public int? PricingTableId { get; set; }

    public decimal? WeightEstimate { get; set; }

    public decimal? WeightReal { get; set; }

    public decimal? Price { get; set; }

    public decimal? Amount { get; set; }
}
