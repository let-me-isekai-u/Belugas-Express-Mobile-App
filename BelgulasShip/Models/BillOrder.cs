using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class BillOrder
{
    public int Id { get; set; }

    public int? OrderId { get; set; }

    public string? BillReceive { get; set; }

    public string? BillSend { get; set; }

    public DateTime? ReceiveDate { get; set; }

    public DateTime? SendDate { get; set; }
}
