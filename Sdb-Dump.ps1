function Sdb-Dump {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)
        
        Dump the Shim database file.

    .EXAMPLE

        PS C:\> Sdb-Dump -Path .\putty_C.PuttyRider.dll.sdb

        Parse the shim database and dump its content.
#>

    [CmdletBinding()] 
    Param (
        [Parameter()] 
        [String] $Path
    )

    if ($Path) {
        if (Test-Path $Path) {
            if ($Path.Contains('.\')) {
                $FilePath = Split-Path $Path
                $Resolve = Resolve-Path $FilePath
                $ResolvedPath = $Resolve.Path
                $FileName = $Path.replace(".\","")
                $GetPath = "$ResolvedPath\$FileName"
            }
            else {
                $GetPath = $Path
            }
        }
        else {
            Write-Host "[*] Invalid file path!"
        }
    }
    else {
        Write-Host "[*] Error, please enter the file path with -Path parameter."
    }

    # from https://cyber-defense.sans.org/blog/2010/02/11/powershell-byte-array-hex-convert
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

    if ($GetPath) {
        $bytes = [System.IO.File]::ReadAllBytes($GetPath)
        $hex = ($bytes | Format-Hex | Select-Object -Expand Bytes | ForEach-Object { '{0:x2}' -f $_ }) -join ''
        $regexShimRef = "0000000970"
        $matchShimRef = [regex]::Match($hex, $regexShimRef)

        if ($matchShimRef.Index -ne 0) { $index = $matchShimRef.Index }
        $chop = $hex.Substring($index)
        $out = Convert-HexStringToByteArray $chop
        $output = [System.Text.Encoding]::ASCII.GetString($out)

        if ($output) {
            Write-Host "$output"
        }
    }
}