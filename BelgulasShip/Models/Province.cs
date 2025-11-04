using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class Province
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public string? CodeName { get; set; }

    public string? DivisionType { get; set; }

    public int? PhoneCode { get; set; }

    public int? CountryId { get; set; }

    public virtual ICollection<Ward> Wards { get; set; } = new List<Ward>();
}
