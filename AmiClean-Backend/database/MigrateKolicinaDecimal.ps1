$ErrorActionPreference = 'Stop'
$connectionString = 'Server=localhost\SQLEXPRESS;Database=AmiCleanDb;Trusted_Connection=True;TrustServerCertificate=True'
$sqlPath = Join-Path $PSScriptRoot 'MigrateKolicinaDecimal.sql'
$sql = [System.IO.File]::ReadAllText($sqlPath)
$batches = [regex]::Split($sql, '(?m)^\s*GO\s*$')
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()
try {
    foreach ($batch in $batches) {
        $query = $batch.Trim()
        if ($query.Length -eq 0) { continue }
        $command = $connection.CreateCommand()
        $command.CommandText = $query
        [void]$command.ExecuteNonQuery()
    }
    Write-Host 'MigrateKolicinaDecimal zavrsen.'
} finally {
    $connection.Close()
}
