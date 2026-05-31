# Pokreni: powershell -ExecutionPolicy Bypass -File SeedKatalog.ps1

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$connectionString = 'Server=localhost\SQLEXPRESS;Database=AmiCleanDb;Trusted_Connection=True;TrustServerCertificate=True'
$sqlPath = Join-Path $PSScriptRoot 'SeedKatalog.sql'

$sql = [System.IO.File]::ReadAllText($sqlPath, [System.Text.UTF8Encoding]::new($false))
$batches = [regex]::Split($sql, '(?m)^\s*GO\s*$')

$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

try {
    foreach ($batch in $batches) {
        $query = $batch.Trim()
        if ($query.Length -eq 0) { continue }

        $command = $connection.CreateCommand()
        $command.CommandText = $query
        $command.CommandTimeout = 120
        [void]$command.ExecuteNonQuery()
    }

    $verify = $connection.CreateCommand()
    $verify.CommandText = @'
SELECT
    (SELECT COUNT(*) FROM Artikal) AS BrojArtikala,
    (SELECT COUNT(*) FROM Usluga) AS BrojUsluga,
    (SELECT COUNT(*) FROM Cjenovnik) AS BrojCijena;
SELECT TOP 3 Naziv FROM Usluga ORDER BY ID_Usluge;
'@

    $reader = $verify.ExecuteReader()
    if ($reader.Read()) {
        Write-Host ("Artikala: {0}, Usluga: {1}, Cijena: {2}" -f $reader[0], $reader[1], $reader[2])
    }
    [void]$reader.NextResult()
    while ($reader.Read()) {
        Write-Host ("Usluga: {0}" -f $reader.GetString(0))
    }
}
finally {
    $connection.Close()
}

Write-Host 'SeedKatalog zavrsen.'
