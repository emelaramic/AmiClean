-- Promjena Kolicina s INT na DECIMAL(10,2) — tepisi mogu imati npr. 12.5 m².
USE AmiCleanDb;
GO

DECLARE @defaultName NVARCHAR(200);
SELECT @defaultName = dc.name
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE dc.parent_object_id = OBJECT_ID(N'Stavka_Narudzbe')
  AND c.name = N'Kolicina';

IF @defaultName IS NOT NULL
BEGIN
    EXEC(N'ALTER TABLE Stavka_Narudzbe DROP CONSTRAINT [' + @defaultName + N']');
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns c
    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(N'Stavka_Narudzbe')
      AND c.name = N'Kolicina'
      AND t.name = N'int'
)
BEGIN
    ALTER TABLE Stavka_Narudzbe ALTER COLUMN Kolicina DECIMAL(10,2) NOT NULL;
    ALTER TABLE Stavka_Narudzbe ADD CONSTRAINT DF_Stavka_Narudzbe_Kolicina DEFAULT 1 FOR Kolicina;
    PRINT N'Kolicina promijenjena u DECIMAL(10,2).';
END
ELSE IF EXISTS (
    SELECT 1
    FROM sys.columns c
    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(N'Stavka_Narudzbe')
      AND c.name = N'Kolicina'
      AND t.name = N'decimal'
)
BEGIN
    PRINT N'Kolicina je već DECIMAL — preskačem.';
END
GO
