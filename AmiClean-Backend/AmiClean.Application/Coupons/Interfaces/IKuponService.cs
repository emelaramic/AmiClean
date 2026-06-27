using AmiClean.Application.Coupons.Dtos;
using AmiClean.Domain.Entities;

namespace AmiClean.Application.Coupons.Interfaces;

public interface IKuponService
{
    Task<KuponProvjeraDto> ProvjeriAsync(
        string kod,
        decimal ukupnaCijena,
        CancellationToken cancellationToken = default);

    Task<KuponPrimjenaRezultat> RijesiZaNarudzbuAsync(
        string kod,
        decimal ukupnaCijena,
        CancellationToken cancellationToken = default);
}

public sealed class KuponPrimjenaRezultat
{
    public required Kupon Kupon { get; init; }
    public required decimal PopustIznos { get; init; }
}
