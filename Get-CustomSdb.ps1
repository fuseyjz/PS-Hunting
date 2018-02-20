function Get-CustomSdb {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)
        
        Company: Countercept (@countercept)

        Checks for custom installed shims database.

    .EXAMPLE

        PS C:\> Get-CustomSdb

        Return those installed sdb registry keys.
#>
    Write-Host "Checking: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom"

    Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom" -Recurse | ForEach-Object {


        $GetName = $_.Name
        $SplitName = $GetName -split 'Custom\\'
        $KeyName = $SplitName[1]
        $GetProperty = $_.Property

        if ($GetProperty) {
            Write-Host "Key Name: $KeyName"
            Write-Host "Sdb Name: $GetProperty `n"
        }

    }

    Write-Host "Checking: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB"

    Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB" -Recurse | Get-ItemProperty |  ForEach-Object {

        $GetDesc = $_.DatabaseDescription
        $GetPath = $_.DatabasePath

        if ($GetDesc) {
            Write-Host "Description: $GetDesc"
            Write-Host "Path: $GetPath"
        }
    }
}
