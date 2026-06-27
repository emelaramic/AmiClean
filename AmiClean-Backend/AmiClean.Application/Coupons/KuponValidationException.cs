namespace AmiClean.Application.Coupons;

public class KuponValidationException : Exception
{
    public KuponValidationException(string message) : base(message) { }
}
