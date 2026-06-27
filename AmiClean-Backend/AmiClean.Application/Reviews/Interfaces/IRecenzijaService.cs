using AmiClean.Application.Reviews.Dtos;

namespace AmiClean.Application.Reviews.Interfaces;

public interface IRecenzijaService
{
    Task<RecenzijaDto> KreirajRecenzijuAsync(
        KreirajRecenzijuRequest request,
        CancellationToken cancellationToken = default);
}
