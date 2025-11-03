using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class PricingTable
{
    public int Id { get; set; }

    public int? CountryId { get; set; }

    public string? Name { get; set; }

    public string? Unit { get; set; }

    public decimal? PricePerKilogram { get; set; }

    public string? Descriptiion { get; set; }
}
