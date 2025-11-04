using System;
using System.Collections.Generic;

namespace BelgulasShip.Models;

public partial class Account
{
    public int Id { get; set; }

    public string? Email { get; set; }

    public string? Password { get; set; }

    public string? FullName { get; set; }

    public int? Role { get; set; }

    public string? PhoneNumber { get; set; }

    public string? Address { get; set; }

    public decimal? Wallet { get; set; }

    public DateTime? CreateDate { get; set; }

    public DateTime? UpdateAt { get; set; }

    public bool? IsDelete { get; set; }

    public string? ReferralCode { get; set; }

    public string? ReferredByCode { get; set; }

    public int? CountryId { get; set; }

    public string? PhoneZalo { get; set; }
}
