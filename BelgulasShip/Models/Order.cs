using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class Order
{
    public int Id { get; set; }

    public string? OrderCode { get; set; }

    public string? SenderName { get; set; }

    public string? ReceiverName { get; set; }

    public string? SenderPhone { get; set; }

    public string? ReceiverPhone { get; set; }

    public string? SenderAddress { get; set; }

    public string? ReceiverAddress { get; set; }

    public decimal? DownPayment { get; set; }

    public int? CountryId { get; set; }

    public int? Status { get; set; }

    public int? CreateBy { get; set; }

    public DateTime? CreateDate { get; set; }

    public DateTime? UpdateDate { get; set; }

    public decimal? PayWithBalance { get; set; }
}
