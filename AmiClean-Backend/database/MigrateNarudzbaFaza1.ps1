$ErrorActionPreference = 'Stop'
$connectionString = 'Server=localhost\SQLEXPRESS;Database=AmiCleanDb;Trusted_Connection=True;TrustServerCertificate=True'
$sqlPath = Join-Path $PSScriptRoot 'MigrateNarudzbaFaza1.sql'
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
    Write-Host 'MigrateNarudzbaFaza1 zavrsen.'
} finally {
    $connection.Close()
}
