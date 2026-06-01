namespace AmiClean.Application.Orders;

public class NarudzbaValidationException : Exception
{
    public NarudzbaValidationException(string message) : base(message)
    {
    }
}
