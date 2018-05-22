function Get-CustomSdb {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)
        
        Checks for custom installed shims database.

    .EXAMPLE

        PS C:\> Get-CustomSdb

        Return those installed sdb registry keys.
#>
  
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

        if ($GetPath) {
            Write-Host "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB"
            Write-Host "Description: $GetDesc"
            Write-Host "Path: $GetPath"
        }
    }
}
