namespace BelgulasShip.DTOs
{
    public class LoginResponse
    {
        public int Id { get; set; }
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public int Role { get; set; }
    }
}
