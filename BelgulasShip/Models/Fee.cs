using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class Fee
{
    public int Id { get; set; }

    public string? Flag { get; set; }

    public string? CountryName { get; set; }

    public decimal? PricePerKilogram { get; set; }

    public DateTime? CreateDate { get; set; }

    public DateTime? UpdateDate { get; set; }

    public bool? IsActive { get; set; }
}
