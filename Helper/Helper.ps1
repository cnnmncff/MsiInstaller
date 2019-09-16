function CheckDatabaseConnection($connectionString, [ref][string]$errorString){
    [bool]$ret = false;

    $sqlConn = new-object ("Data.SqlClient.SqlConnection") $connectionString

    try
    {
        $sqlConn.Open();
        $ret = true;
    }
    catch
    {
        $errorString = "Database TPCentralDB is " -NoNewLine
        $errorString += " UNAVAILABLE " -ForeGround White -BackGround Red
        $errorString += "`nInstallation is aborted"
        
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    }

    $sqlConn.Close();

    return $ret
}