--1.1
SELECT 
    COLUMN_NAME AS ColumnName, 
    DATA_TYPE AS [Type]
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG = DB_NAME()
AND TABLE_SCHEMA = 'SalesLT'
AND TABLE_NAME = 'Product'
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

--1.2
DECLARE @SchemaName NVARCHAR(128) = 'SalesLT';
DECLARE @TableName NVARCHAR(128) = 'Product';
DECLARE @SearchTerm NVARCHAR(128) = 'Bike';
DECLARE @DynamicSQL NVARCHAR(MAX) = '';
WITH TextColumns AS (
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @SchemaName
      AND TABLE_NAME = @TableName
      AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext'))
SELECT @DynamicSQL = 
     'SELECT * FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' WHERE ' + 
     STRING_AGG(QUOTENAME(COLUMN_NAME) + ' LIKE ''%' + @SearchTerm + '%''', ' OR ')
FROM TextColumns;
PRINT @DynamicSQL;
EXEC sp_executesql @DynamicSQL;
GO

--2.1
ALTER PROCEDURE SalesLT.uspFindStringInTable
    @SchemaName sysname,
    @TableName sysname,
    @SearchTerm nvarchar(255)
AS
BEGIN
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @RowCount INT = 0;
    WITH TextColumns AS (
        SELECT 
            COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = @SchemaName
          AND TABLE_NAME = @TableName
          AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext'))
    SELECT @DynamicSQL = 
        'SELECT * FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' WHERE ' + 
         STRING_AGG(QUOTENAME(COLUMN_NAME) + ' LIKE ''%' + @SearchTerm + '%''', ' OR ')
    FROM TextColumns;
    SET @DynamicSQL = @DynamicSQL + '; SELECT @RowCount = COUNT(*) FROM (' + @DynamicSQL + ') AS Results;';
    EXEC sp_executesql @DynamicSQL, N'@RowCount INT OUTPUT', @RowCount OUTPUT;
    RETURN @RowCount;
END;
GO
--тест
DECLARE @RowsFound INT;
EXEC @RowsFound = SalesLT.uspFindStringInTable 
    @SchemaName = 'SalesLT', 
    @TableName = 'Product', 
    @SearchTerm = 'Bike';
PRINT 'Rows: ' + CAST(@RowsFound AS NVARCHAR(10));


--2.2
DECLARE @CurrentSchemaName sysname;
DECLARE @CurrentTableName sysname;
DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @SearchTerm NVARCHAR(255) = 'Bike';
DECLARE @RowsFound2 INT;
DECLARE TableCursor CURSOR FOR
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @CurrentSchemaName, @CurrentTableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC @RowsFound2 = SalesLT.uspFindStringInTable
        @SchemaName = @CurrentSchemaName, 
        @TableName = @CurrentTableName, 
        @SearchTerm = @SearchTerm;
    IF @RowsFound2 = 0
    BEGIN
        PRINT 'No rows ' + QUOTENAME(@CurrentSchemaName) + ' ' + QUOTENAME(@CurrentTableName);
    END
    ELSE
    BEGIN
        PRINT 'Found rows ' + QUOTENAME(@CurrentSchemaName) + ' ' + QUOTENAME(@CurrentTableName) + ' ' + CAST(@RowsFound2 AS NVARCHAR(10));
    END
    FETCH NEXT FROM TableCursor INTO @CurrentSchemaName, @CurrentTableName;
END;

CLOSE TableCursor;
DEALLOCATE TableCursor;
