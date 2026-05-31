using AmiClean.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Persistence;

public class AmiCleanContext : DbContext
{
    public AmiCleanContext(DbContextOptions<AmiCleanContext> options)
        : base(options)
    {
    }

    public DbSet<Artikal> Artikli => Set<Artikal>();
    public DbSet<Cjenovnik> Cjenovnici => Set<Cjenovnik>();
    public DbSet<Korisnik> Korisnici => Set<Korisnik>();
    public DbSet<Kupon> Kuponi => Set<Kupon>();
    public DbSet<Logistika> Logistike => Set<Logistika>();
    public DbSet<Narudzba> Narudzbe => Set<Narudzba>();
    public DbSet<Notifikacija> Notifikacije => Set<Notifikacija>();
    public DbSet<Placanje> Placanja => Set<Placanje>();
    public DbSet<Recenzija> Recenzije => Set<Recenzija>();
    public DbSet<StavkaNarudzbe> StavkeNarudzbe => Set<StavkaNarudzbe>();
    public DbSet<StavkaUsluga> StavkeUsluge => Set<StavkaUsluga>();
    public DbSet<StatusLogistike> StatusiLogistike => Set<StatusLogistike>();
    public DbSet<StatusNarudzbe> StatusiNarudzbe => Set<StatusNarudzbe>();
    public DbSet<StatusPlacanja> StatusiPlacanja => Set<StatusPlacanja>();
    public DbSet<StatusStavke> StatusiStavke => Set<StatusStavke>();
    public DbSet<Usluga> Usluge => Set<Usluga>();
    public DbSet<Zaposlenik> Zaposlenici => Set<Zaposlenik>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Artikal>(e =>
        {
            e.ToTable("Artikal");
            e.HasKey(x => x.ID_Artikla);
            e.Property(x => x.Kategorija).HasMaxLength(50);
        });

        modelBuilder.Entity<Cjenovnik>(e =>
        {
            e.ToTable("Cjenovnik");
            e.HasKey(x => x.ID_Cjenovnika);
            e.Property(x => x.Cijena).HasColumnType("decimal(10, 2)");
            e.Property(x => x.Cijena_Max).HasColumnType("decimal(10, 2)");
            e.HasIndex(x => new { x.FK_Artikal, x.FK_Usluga }).IsUnique();
            e.HasOne(x => x.Artikal).WithMany(a => a.Cjenovnici).HasForeignKey(x => x.FK_Artikal);
            e.HasOne(x => x.Usluga).WithMany(u => u.Cjenovnici).HasForeignKey(x => x.FK_Usluga);
        });

        modelBuilder.Entity<Korisnik>(e =>
        {
            e.ToTable("Korisnik");
            e.HasKey(x => x.ID_Korisnika);
            e.HasIndex(x => x.Email).IsUnique().HasFilter("[Email] IS NOT NULL");
        });

        modelBuilder.Entity<Kupon>(e =>
        {
            e.ToTable("Kupon");
            e.HasKey(x => x.ID_Kupona);
            e.Property(x => x.Postotak_Popusta).HasColumnType("decimal(5, 2)");
            e.Property(x => x.Min_Iznos_Narudzbe).HasColumnType("decimal(10, 2)");
            e.HasIndex(x => x.Kod).IsUnique();
        });

        modelBuilder.Entity<Logistika>(e =>
        {
            e.ToTable("Logistika");
            e.HasKey(x => x.ID_Logistike);
            e.HasOne(x => x.Narudzba).WithMany(n => n.Logistike).HasForeignKey(x => x.FK_Narudzba);
            e.HasOne(x => x.Vozac).WithMany(z => z.Logistike).HasForeignKey(x => x.FK_Vozac);
            e.HasOne(x => x.Status).WithMany(s => s.Logistike).HasForeignKey(x => x.FK_Status);
        });

        modelBuilder.Entity<Narudzba>(e =>
        {
            e.ToTable("Narudzba");
            e.HasKey(x => x.ID_Narudzbe);
            e.Property(x => x.Ukupna_Cijena).HasColumnType("decimal(10, 2)");
            e.Property(x => x.Popust_Iznos).HasColumnType("decimal(10, 2)");
            e.HasOne(x => x.Korisnik).WithMany(k => k.Narudzbe).HasForeignKey(x => x.FK_Korisnik);
            e.HasOne(x => x.Kupon).WithMany(k => k.Narudzbe).HasForeignKey(x => x.FK_Kupon);
            e.HasOne(x => x.PrimioZaposlenik).WithMany(z => z.NarudzbePrimljene).HasForeignKey(x => x.FK_Primio_Zaposlenik);
            e.HasOne(x => x.Status).WithMany(s => s.Narudzbe).HasForeignKey(x => x.FK_Status);
        });

        modelBuilder.Entity<Notifikacija>(e =>
        {
            e.ToTable("Notifikacija");
            e.HasKey(x => x.ID_Notifikacije);
            e.HasOne(x => x.Korisnik).WithMany(k => k.Notifikacije).HasForeignKey(x => x.FK_Korisnik);
            e.HasOne(x => x.Narudzba).WithMany(n => n.Notifikacije).HasForeignKey(x => x.FK_Narudzba);
        });

        modelBuilder.Entity<Placanje>(e =>
        {
            e.ToTable("Placanje");
            e.HasKey(x => x.ID_Placanja);
            e.Property(x => x.Iznos).HasColumnType("decimal(10, 2)");
            e.HasOne(x => x.Narudzba).WithMany(n => n.Placanja).HasForeignKey(x => x.FK_Narudzba);
            e.HasOne(x => x.Status).WithMany(s => s.Placanja).HasForeignKey(x => x.FK_Status);
        });

        modelBuilder.Entity<Recenzija>(e =>
        {
            e.ToTable("Recenzija");
            e.HasKey(x => x.ID_Recenzije);
            e.HasIndex(x => x.FK_Narudzba).IsUnique();
            e.HasOne(x => x.Korisnik).WithMany(k => k.Recenzije).HasForeignKey(x => x.FK_Korisnik);
            e.HasOne(x => x.Narudzba).WithOne(n => n.Recenzija).HasForeignKey<Recenzija>(x => x.FK_Narudzba);
        });

        modelBuilder.Entity<StavkaNarudzbe>(e =>
        {
            e.ToTable("Stavka_Narudzbe");
            e.HasKey(x => x.ID_Stavke);
            e.Property(x => x.Kolicina).HasColumnType("decimal(10, 2)");
            e.Property(x => x.Cijena_Jedinicna).HasColumnType("decimal(10, 2)");
            e.HasOne(x => x.Narudzba).WithMany(n => n.Stavke).HasForeignKey(x => x.FK_Narudzba);
            e.HasOne(x => x.Artikal).WithMany(a => a.Stavke).HasForeignKey(x => x.FK_Artikal);
            e.HasOne(x => x.Status).WithMany(s => s.Stavke).HasForeignKey(x => x.FK_Status);
        });

        modelBuilder.Entity<StavkaUsluga>(e =>
        {
            e.ToTable("Stavka_Usluga");
            e.HasKey(x => x.ID);
            e.Property(x => x.Cijena_Usluge).HasColumnType("decimal(10, 2)");
            e.HasOne(x => x.Stavka).WithMany(s => s.Usluge).HasForeignKey(x => x.FK_Stavka);
            e.HasOne(x => x.Usluga).WithMany(u => u.StavkeUsluge).HasForeignKey(x => x.FK_Usluga);
        });

        modelBuilder.Entity<StatusLogistike>(e =>
        {
            e.ToTable("StatusLogistike");
            e.HasKey(x => x.ID_Statusa);
        });

        modelBuilder.Entity<StatusNarudzbe>(e =>
        {
            e.ToTable("StatusNarudzbe");
            e.HasKey(x => x.ID_Statusa);
        });

        modelBuilder.Entity<StatusPlacanja>(e =>
        {
            e.ToTable("StatusPlacanja");
            e.HasKey(x => x.ID_Statusa);
        });

        modelBuilder.Entity<StatusStavke>(e =>
        {
            e.ToTable("StatusStavke");
            e.HasKey(x => x.ID_Statusa);
        });

        modelBuilder.Entity<Usluga>(e =>
        {
            e.ToTable("Usluga");
            e.HasKey(x => x.ID_Usluge);
        });

        modelBuilder.Entity<Zaposlenik>(e =>
        {
            e.ToTable("Zaposlenik");
            e.HasKey(x => x.ID_Zaposlenika);
            e.HasIndex(x => x.Korisnicko_Ime).IsUnique();
        });
    }
}
