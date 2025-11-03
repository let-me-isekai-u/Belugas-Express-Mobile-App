using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class StatusOrderLog
{
    public int Id { get; set; }

    public int? OrderId { get; set; }

    public string? Status { get; set; }

    public int? UpdateBy { get; set; }

    public DateTime? UpdateDate { get; set; }
}
