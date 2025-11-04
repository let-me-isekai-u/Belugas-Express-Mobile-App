using BelgulasShip.Models;
using BelgulasShip.Service;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddHttpClient();
// ✅ Cần cache để lưu session
builder.Services.AddDistributedMemoryCache();

// ✅ Thêm session service
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30); // thời gian hết hạn session
    options.Cookie.HttpOnly = true;                 // bảo mật, chỉ cho server đọc cookie
    options.Cookie.IsEssential = true;              // bắt buộc, không bị block bởi GDPR
});

// Add DbContext
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Smtp config và email service
builder.Services.Configure<SmtpSettings>(builder.Configuration.GetSection("Smtp"));
builder.Services.AddTransient<EmailService>();

var key = Encoding.UTF8.GetBytes(builder.Configuration["Jwt:SecretKey"]);

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(key),

            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

// ✅ Thêm middleware Session
app.UseSession();

//Middleware khôi phục session từ cookie
app.Use(async (context, next) =>
{
    if (context.Session.GetInt32("AccountId") == null)
    {
        if (context.Request.Cookies.TryGetValue("RememberMeId", out string accountIdStr))
        {
            if (int.TryParse(accountIdStr, out int accountId))
            {
                using var scope = app.Services.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                var user = db.Accounts.FirstOrDefault(x => x.Id == accountId);
                if (user != null)
                {
                    context.Session.SetInt32("AccountId", user.Id);
                    context.Session.SetString("FullName", user.FullName ?? "");
                    context.Session.SetInt32("AccountRole", user.Role ?? 1);
                }
            }
        }
    }
    await next();
});

app.UseAuthentication();
app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "areas",
    pattern: "{area:exists}/{controller=Home}/{action=Index}/{id?}");

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
