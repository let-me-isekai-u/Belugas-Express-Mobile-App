using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace BelgulasShip.Models;

public partial class ApplicationDbContext : DbContext
{
    public ApplicationDbContext()
    {
    }

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Account> Accounts { get; set; }

    public virtual DbSet<BillOrder> BillOrders { get; set; }

    public virtual DbSet<Country> Countries { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderItem> OrderItems { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<PricingTable> PricingTables { get; set; }

    public virtual DbSet<ProductType> ProductTypes { get; set; }

    public virtual DbSet<RefreshToken> RefreshTokens { get; set; }

    public virtual DbSet<StatusOrderLog> StatusOrderLogs { get; set; }

    public virtual DbSet<VerificationCode> VerificationCodes { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        => optionsBuilder.UseSqlServer("Data Source=MSI\\SQLEXPRESS;Initial Catalog=BegulasShipDB;user id=sang;password=123456;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Account>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_Account");

            entity.ToTable("account");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Address)
                .HasMaxLength(500)
                .HasColumnName("address");
            entity.Property(e => e.CreateDate)
                .HasColumnType("datetime")
                .HasColumnName("create_date");
            entity.Property(e => e.Email)
                .HasMaxLength(250)
                .HasColumnName("email");
            entity.Property(e => e.FullName)
                .HasMaxLength(250)
                .HasColumnName("full_name");
            entity.Property(e => e.IsDelete).HasColumnName("is_delete");
            entity.Property(e => e.Password).HasColumnName("password");
            entity.Property(e => e.PhoneNumber)
                .HasMaxLength(20)
                .HasColumnName("phone_number");
            entity.Property(e => e.ReferralCode)
                .HasMaxLength(50)
                .HasColumnName("referral_code");
            entity.Property(e => e.ReferredByCode)
                .HasMaxLength(50)
                .HasColumnName("referred_by_code");
            entity.Property(e => e.Role).HasColumnName("role");
            entity.Property(e => e.UpdateAt)
                .HasColumnType("datetime")
                .HasColumnName("update_at");
            entity.Property(e => e.Wallet)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("wallet");
        });

        modelBuilder.Entity<BillOrder>(entity =>
        {
            entity.ToTable("bill_order");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.BillReceive)
                .HasMaxLength(50)
                .HasColumnName("bill_receive");
            entity.Property(e => e.BillSend)
                .HasMaxLength(50)
                .HasColumnName("bill_send");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.ReceiveDate)
                .HasColumnType("datetime")
                .HasColumnName("receive_date");
            entity.Property(e => e.SendDate)
                .HasColumnType("datetime")
                .HasColumnName("send_date");
        });

        modelBuilder.Entity<Country>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_Fees");

            entity.ToTable("country");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Code)
                .HasMaxLength(50)
                .HasColumnName("code");
            entity.Property(e => e.CreateDate)
                .HasColumnType("datetime")
                .HasColumnName("create_date");
            entity.Property(e => e.IsActive).HasColumnName("is_active");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
            entity.Property(e => e.UpdateDate)
                .HasColumnType("datetime")
                .HasColumnName("update_date");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_orders");

            entity.ToTable("order");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.CountryId).HasColumnName("country_id");
            entity.Property(e => e.CreateBy).HasColumnName("create_by");
            entity.Property(e => e.CreateDate)
                .HasColumnType("datetime")
                .HasColumnName("create_date");
            entity.Property(e => e.DownPayment)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("down_payment");
            entity.Property(e => e.OrderCode)
                .HasMaxLength(20)
                .HasColumnName("order_code");
            entity.Property(e => e.PayWithBalance)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("pay_with_balance");
            entity.Property(e => e.ReceiverAddress).HasColumnName("receiver_address");
            entity.Property(e => e.ReceiverName)
                .HasMaxLength(50)
                .HasColumnName("receiver_name");
            entity.Property(e => e.ReceiverPhone)
                .HasMaxLength(15)
                .HasColumnName("receiver_phone");
            entity.Property(e => e.SenderAddress).HasColumnName("sender_address");
            entity.Property(e => e.SenderName)
                .HasMaxLength(50)
                .HasColumnName("sender_name");
            entity.Property(e => e.SenderPhone)
                .HasMaxLength(15)
                .HasColumnName("sender_phone");
            entity.Property(e => e.Status).HasColumnName("status");
            entity.Property(e => e.UpdateDate)
                .HasColumnType("datetime")
                .HasColumnName("update_date");
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.ToTable("order_item");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Amount)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("amount");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.Price)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("price");
            entity.Property(e => e.PricingTableId).HasColumnName("pricing_table_id");
            entity.Property(e => e.WeightEstimate)
                .HasColumnType("decimal(8, 2)")
                .HasColumnName("weight_estimate");
            entity.Property(e => e.WeightReal)
                .HasColumnType("decimal(8, 2)")
                .HasColumnName("weight_real");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_payments");

            entity.ToTable("payment");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AccountId).HasColumnName("account_id");
            entity.Property(e => e.Amount)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("amount");
            entity.Property(e => e.PaymentDate)
                .HasColumnType("datetime")
                .HasColumnName("payment_date");
            entity.Property(e => e.PaymentFor)
                .HasMaxLength(50)
                .HasColumnName("payment_for");
        });

        modelBuilder.Entity<PricingTable>(entity =>
        {
            entity.ToTable("pricing_table");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.CountryId).HasColumnName("country_id");
            entity.Property(e => e.Descriptiion)
                .HasMaxLength(500)
                .HasColumnName("descriptiion");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .HasColumnName("name");
            entity.Property(e => e.PricePerKilogram)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("price_per_kilogram");
            entity.Property(e => e.Unit)
                .HasMaxLength(50)
                .HasColumnName("unit");
        });

        modelBuilder.Entity<ProductType>(entity =>
        {
            entity.ToTable("product_types");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasMaxLength(500)
                .HasColumnName("description");
            entity.Property(e => e.Name)
                .HasMaxLength(250)
                .HasColumnName("name");
            entity.Property(e => e.Unit)
                .HasMaxLength(50)
                .HasColumnName("unit");
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.ToTable("refresh_token");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AccountId).HasColumnName("account_id");
            entity.Property(e => e.ExpiryDate)
                .HasColumnType("datetime")
                .HasColumnName("expiry_date");
            entity.Property(e => e.IsRevoked).HasColumnName("is_revoked");
            entity.Property(e => e.Token).HasColumnName("token");
        });

        modelBuilder.Entity<StatusOrderLog>(entity =>
        {
            entity.ToTable("status_order_log");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.Status)
                .HasMaxLength(250)
                .HasColumnName("status");
            entity.Property(e => e.UpdateBy).HasColumnName("update_by");
            entity.Property(e => e.UpdateDate)
                .HasColumnType("datetime")
                .HasColumnName("update_date");
        });

        modelBuilder.Entity<VerificationCode>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_verification_codes");

            entity.ToTable("verification_code");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Code)
                .HasMaxLength(10)
                .IsFixedLength()
                .HasColumnName("code");
            entity.Property(e => e.Email)
                .HasMaxLength(50)
                .HasColumnName("email");
            entity.Property(e => e.ExpireAt)
                .HasColumnType("datetime")
                .HasColumnName("expire_at");
            entity.Property(e => e.IsUsed).HasColumnName("is_used");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
