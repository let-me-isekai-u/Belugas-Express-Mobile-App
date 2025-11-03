namespace BelgulasShip.DTOs
{
    public class CreateOrderRequest
    {
        public string SenderName { get; set; }
        public string ReceiverName { get; set; }
        public string SenderPhone { get; set; }
        public string ReceiverPhone { get; set; }
        public string SenderAddress { get; set; }
        public string ReceiverAddress { get; set; }
        public int CountryId { get; set; }
        public decimal PayWithBalance { get; set; }
        public decimal DownPayment { get; set; }
        public List<OrderItemDto> OrderItems { get; set; }
    }
}
