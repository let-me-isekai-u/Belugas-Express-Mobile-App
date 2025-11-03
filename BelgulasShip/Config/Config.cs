namespace BelgulasShip.Config
{
    public class Config
    {
        private const string strUrlServer = @"https://localhost:7114/";
        //private const string strUrlServer = @"https://milkteaheaven-g9gzbdgzamhwgmap.eastasia-01.azurewebsites.net/";
        public static string Connection()
        {
            string conn = @"Data Source=MSI\SQLEXPRESS;Initial Catalog=BegulasShipDB;user id=sang;password=123456;TrustServerCertificate=True";
            //string conn = @"Data Source=202.92.4.31\MSSQLSERVER2022;Initial Catalog=P2P;User ID=nhatanh;Password=UP6v$4eq*ah8jOdu;Trust Server Certificate=True";
            return conn;
        }
    }
}
