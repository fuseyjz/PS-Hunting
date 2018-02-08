function Get-CustomSdb {
<#
    .SYNOPSIS

        Author: Jayden Zheng (@fuseyjz)

        Company: Countercept
        
        Checks for custom installed shims database.

    .EXAMPLE

        PS C:\> Get-CustomSdb

        Return those installed sdb registry keys and content.
#>
    Write-Host "Query: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom `n"

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

    Write-Host "============================================== `n"
    Write-Host "Query: HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB `n"

    Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB" -Recurse | Get-ItemProperty |  ForEach-Object {

        $GetDesc = $_.DatabaseDescription
        $GetPath = $_.DatabasePath
        $GetCont = Get-Content -Path $GetPath | Select-Object -Last 1

        if ($GetDesc) {
            Write-Host "Description: $GetDesc"
            Write-Host "Path: $GetPath"
            Write-Host "Content of sdb: `n"
            Write-Host "$GetCont `n"
        }
    }
}
