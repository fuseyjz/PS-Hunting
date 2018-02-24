function Get-CustomSdb {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)
        
        Checks for custom installed shims database.

    .EXAMPLE

        PS C:\> Get-CustomSdb

        Return those installed sdb registry keys and content of the sdb.
#>

    #Function from https://cyber-defense.sans.org/blog/2010/02/11/powershell-byte-array-hex-convert
    function Convert-HexStringToByteArray
    {
        [CmdletBinding()]
        Param ( [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [String] $String )

        #Clean out whitespaces and any other non-hex crud.
        $String = $String.ToLower() -replace '[^a-f0-9\\,x\-\:]',"

        #Try to put into canonical colon-delimited format.
        $String = $String -replace '0x|\x|\-|,',':'

        #Remove beginning and ending colons, and other detritus.
        $String = $String -replace '^:+|:+$|x|\',"

        #Maybe there's nothing left over to convert...
        if ($String.Length -eq 0) { ,@() ; return }

        #Split string with or without colon delimiters.
        if ($String.Length -eq 1)
            { ,@([System.Convert]::ToByte($String,16)) }
        elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1))
            { ,@($String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}) }
        elseif ($String.IndexOf(":") -ne -1)
            { ,@($String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)}) }
        else
            { ,@() }
    }
   
    Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB" -Recurse | Get-ItemProperty |  ForEach-Object {

        $GetDesc = $_.DatabaseDescription
        $GetPath = $_.DatabasePath
        $GetChildName = $_.PSChildName
        
        Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom" -Recurse | Where-Object {$_.Property -match $GetChildName} | ForEach-Object {
            $GetName = $_.Name
            $SplitName = $GetName -split 'Custom\\'
            $KeyName = $SplitName[1]
            $GetProperty = $_.Property

            if ($GetProperty) {
                Write-Host "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom"
                Write-Host "Key Name: $KeyName"
                Write-Host "Sdb Name: $GetProperty `n"
            }
        }

        $bytes = [System.IO.File]::ReadAllBytes($GetPath)
        $hex = ($bytes | Format-Hex | Select-Object -Expand Bytes | ForEach-Object { '{0:x2}' -f $_ }) -join ''
        $index = $hex.IndexOf("0970")
        $chop = $hex.Substring($index)
        $out = Convert-HexStringToByteArray $chop
        $output = [System.Text.Encoding]::ASCII.GetString($out)

        if ($GetPath) {
            Write-Host "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB"
            Write-Host "Description: $GetDesc"
            Write-Host "Path: $GetPath"
            Write-Host "Content of sdb:"
            Write-Host "$output `n"
        }
    }
}
