function Get-JunctionFolder {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)

        Checks the start menu directory for any folder name with CLSID.
        
        Blog: https://www.countercept.com/our-thinking/hunting-for-junction-folder-persistence/

    .EXAMPLE

        PS C:\> Get-JunctionFolder

        Return the InProcServer32 value of each CLSID registry key found.
#>

param (
    # Get %APPDATA%
    $AppData = [Environment]::GetFolderPath('ApplicationData')
    )

    # Check Start Menu directory for any filename contain CLSID
    Get-ChildItem -Path "$AppData\Microsoft\Windows\Start Menu\" -Recurse | Where-Object {$_.Name -match '{[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}}'} | ForEach-Object {

        $FileName = $_.Name
        $GetCLSID = $FileName.split(".")[1]
        $Path = $_.FullName

        # Retrieve Registry Key by comparing above found CLSID
        $Result = Get-ChildItem -Path "HKCU:\Software\Classes\CLSID" -Recurse | Where-Object {$_.PsPath -match $GetCLSID} | Get-ItemProperty | Where-Object {$_.PSChildName -match "InProcServer32"} | Select '(default)', PSPath
    
        # Split output
        $SplitResult = $Result -split ';'
        $RawDll = $SplitResult[0] -split '='
        $RawReg = $SplitResult[1] -split '::'
        $Dll = $RawDll[1]
        $Reg = $RawReg[1]

        # Print to screen
        if ($Result) {
            Write-Host "Path: $Path"
            Write-Host "Dll: $Dll"
            Write-Host "Reg: $Reg `n"
        }    
    }
}
