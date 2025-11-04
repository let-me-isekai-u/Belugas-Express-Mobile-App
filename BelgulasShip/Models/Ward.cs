using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class Ward
{
    public int Id { get; set; }

    public int? ProvinceId { get; set; }

    public string? Name { get; set; }

    public string? CodeName { get; set; }

    public string? DivisionType { get; set; }

    public string? ShortCodeName { get; set; }

    public virtual Province? Province { get; set; }
}
