function Get-LibraryMS {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)

        Checks the %USERPROFILE% directory for any file with library-ms extension and extract the CLSID.
        In particular, <url> element with shell command.

        Blog: pending release

    .EXAMPLE
        
        PS C:\> Import-Module .\Get-LibraryMS.ps1
        PS C:\> Get-LibraryMS

        [*] Looking for library-ms in C:\Users
        [+] Found library-ms file:
        [+] C:\Users\jayden\Desktop\Documents.library-ms
        [*] Extracting CLSID from file
        [+] Found CLSID: {26A81239-BD1F-48E3-BED4-EB313CFCB041}
        [*] Extracting CLSID from HKCU hive
        [+] Dll: C:\ProgramData\beacon.dll
        [+] Reg: HKEY_CURRENT_USER\Software\Classes\CLSID\{26A81239-BD1F-48E3-BED4-EB313CFCB041}\InProcServer32}

        Return the InProcServer32 value of each CLSID registry key found.       
#>

    Write-Host "[*] Looking for library-ms in C:\Users"

    # Check the Users directory for library-ms extension
    Get-ChildItem -Path "C:\Users\" -Filter *.library-ms -Recurse | ForEach-Object {

        $Path = $_.FullName

        if ($Path) {
            Write-Host "[+] Found library-ms file:"
            Write-Host "[+] $Path "
            Write-Host "[*] Extracting CLSID from file"
        }

        # Regex for shell:::{CLSID}
        $Regex = '::{[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}}'

        $Content = Get-Content -Path $Path | Select-String -Pattern $Regex
        
        # Split library-ms file to get CLSID
        $Split1 = $Content -split '::'
        $Split2 = $Split1[1] -split '<'
        $GetCLSID = $Split2[0]

        if ($GetCLSID) {
            Write-Host "[+] Found CLSID: $GetCLSID "
            Write-Host "[*] Extracting CLSID from HKCU hive"
        }

        $Result = Get-ChildItem -Path "HKCU:\Software\Classes\CLSID" -Recurse | Where-Object {$_.PsPath -match $GetCLSID} | Get-ItemProperty | Where-Object {$_.PSChildName -match "InProcServer32"} | Select '(default)', PSPath

        # Split registry output
        $SplitResult = $Result -split ';'
        $RawDll = $SplitResult[0] -split '='
        $RawReg = $SplitResult[1] -split '::'
        $Dll = $RawDll[1]
        $Reg = $RawReg[1]

        if ($Result) {
            Write-Host "[+] Dll: $Dll"
            Write-Host "[+] Reg: $Reg `n"
        }
    }
}