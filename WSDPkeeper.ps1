<#
'##:::::'##::'######::'########:::::'##:::'##:'########:'########:'########::'########:'########::
 ##:'##: ##:'##... ##: ##.... ##:::: ##::'##:: ##.....:: ##.....:: ##.... ##: ##.....:: ##.... ##:
 ##: ##: ##: ##:::..:: ##:::: ##:::: ##:'##::: ##::::::: ##::::::: ##:::: ##: ##::::::: ##:::: ##:
 ##: ##: ##:. ######:: ########::::: #####:::: ######::: ######::: ########:: ######::: ########::
 ##: ##: ##::..... ##: ##.....:::::: ##. ##::: ##...:::: ##...:::: ##.....::: ##...:::: ##.. ##:::
 ##: ##: ##:'##::: ##: ##::::::::::: ##:. ##:: ##::::::: ##::::::: ##:::::::: ##::::::: ##::. ##::
. ###. ###::. ######:: ##::::::::::: ##::. ##: ########: ########: ##:::::::: ########: ##:::. ##:
:...::...::::......:::..::::::::::::..::::..::........::........::..:::::::::........::..:::::..::
Windows Spotlight Photo keeper                                            Version 0.0.2 by Rui Zhu
MIT License                                                                     Copyright (c) 2021
#>

$ErrorActionPreference = "stop"

function Get-Image{
    begin{        
        Add-Type -assembly System.Drawing
    } 
    process{
        $fi=[System.IO.FileInfo]$_.FullName
        if( $fi.Exists){
            $img = [System.Drawing.Image]::FromFile($_.FullName)
            $img.Clone()
            $img.Dispose()       
        }else{
            Write-Output ("File not found: " + $_.Name) -fore yellow       
        }
        Remove-Variable fi
    }    
}

function HVdiff {
    param (
        $targetF
    )
    Process
    {
        if($targetF)
        {
            $Metadata = ($targetF | Get-Image | Select-Object Width, Height)
            if($Metadata.Width -gt $Metadata.Height)
            {
                # Write-Host("Horizontal")
                return 0
            }
            elseif ($Metadata.Width -lt $Metadata.Height)
            {
                # Write-Host("Vertical")
                return 1
            }
            else
            {
                # Write-Host("Square")
                return 2
            }
        }
    }
}

function calcMvitems {
    param ($Target, $Local)
    Process{
        $moveItems = New-Object System.Collections.Generic.List[System.Object]
        if ($Local.Count -gt 0) {
            foreach ($itemT in $Target){
                if (-not ($Local -match $itemT.hash)){$moveItems.Add($itemT.Path)}
            }
        }else{
            foreach ($itemT in $Target){
                $moveItems.Add($itemT.Path)
            }
        }
        return $moveItems
    }
}

function cpAction {
    param (
        $moveItems,
        [String]$tarPath,
        [String]$Infix="_Windows_Spotlight_"
    )
    Process{
        $Metadata = New-Object System.Collections.Generic.List[System.Object]

        if ($moveItems) {
            $i=0
            foreach ($item in $moveItems)
            {
                $Metadata.Add((Get-ChildItem $item | Get-Image | Select-Object Width, Height))
                if($Metadata[-1].Width -gt $Metadata[-1].Height)
                { 
                    $shapeSpec = "H"
                }
                else{
                    $shapeSpec = "V"
                }
                $newItemName=($shapeSpec + $Infix + (Get-Date -UFormat "%Y%m%d%H%M_") + ("{0:d4}" -f $i) + ".jpg")
                $Resolution=("$($Metadata[-1].Width) x $($Metadata[-1].Height)")
                Write-Host ("Resolution:`t$Resolution`t$newItemName")
                Copy-Item $item ("$tarPath\$newItemName")
                Write-Host ("$tarPath\$newItemName")
                $i++
            }
            notify("Copying done!")
        }
    }
}

function notify ([String]$headString) {
    [Int]$strLength=99

    Write-Host("-" * $strLength)
    if($headString.Length -lt $strLength){
        if($headString.Length%2)
        {
            $strWidth=(($strLength-$headString.Length)/2 - 1)
            Write-Host("|"+(" "*$strWidth)+$headString+(" "*$strWidth)+"|")
        }
        else 
        {
            $strWidth=(($strLength-$headString.Length-1)/2 -1)
            Write-Host("|"+(" "*$strWidth)+$headString+(" "*($strWidth+1))+"|")
        }
    }else {
        Write-Host("|"+$(-join $headString[0..79])+"...|")
    }
    Write-Host("-"*$strLength)
}

function pathSolver {
    param (
        [String]$path,
        [bool]$type=1
    )
        process {
        if (-not (Test-Path $path)){
            switch ($type) {
                0 {New-Item -Path $path -ItemType Directory}
                1 {New-Item -Path $path -ItemType File}
                Default {}
            }
            return 1
        }
        else{
            return 0
        }
    }
}

function banner {
    $bannerString=
@"
'##:::::'##::'######::'########:::::'##:::'##:'########:'########:'########::'########:'########::
 ##:'##: ##:'##... ##: ##.... ##:::: ##::'##:: ##.....:: ##.....:: ##.... ##: ##.....:: ##.... ##:
 ##: ##: ##: ##:::..:: ##:::: ##:::: ##:'##::: ##::::::: ##::::::: ##:::: ##: ##::::::: ##:::: ##:
 ##: ##: ##:. ######:: ########::::: #####:::: ######::: ######::: ########:: ######::: ########::
 ##: ##: ##::..... ##: ##.....:::::: ##. ##::: ##...:::: ##...:::: ##.....::: ##...:::: ##.. ##:::
 ##: ##: ##:'##::: ##: ##::::::::::: ##:. ##:: ##::::::: ##::::::: ##:::::::: ##::::::: ##::. ##::
. ###. ###::. ######:: ##::::::::::: ##::. ##: ########: ########: ##:::::::: ########: ##:::. ##:
:...::...::::......:::..::::::::::::..::::..::........::........::..:::::::::........::..:::::..::
"@
    [Int]$strLength=99
    $dateString=(Get-Date -UFormat "%Y-%m-%d %H:%M")
    $authorInfo=" by: Rui Zhu"
    $versionInfo="Version 0.0.1"
    $fullNameString="Windows Spotlight Photo keeper."
    Write-Host("="*$strLength)
    Write-Host($dateString + " " * $($strLength - $dateString.Length))
    Write-Host($bannerString) -ForegroundColor Green
    Write-Host($fullNameString + " "*$($strLength - $fullNameString.Length - $versionInfo.Length -$authorInfo.Length) + $versionInfo + $authorInfo)
}

function main {

    $TargetPath  = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
    $workingDir  = "$env:USERPROFILE\Pictures"
    $LocalPath_H = "$workingDir\Saved Pictures\Horizontal"
    $LocalPath_V = "$workingDir\Saved Pictures\Vertical"
    $Local_HfhashP = "$PSScriptRoot\.H_imgHashes.log"
    $Local_VfhashP = "$PSScriptRoot\.V_imgHashes.log"

    (pathSolver $workingDir -type 0) | Out-Null
    if ($(Get-Location).Path -ne $workingDir) {
        Set-Location $workingDir
    }

    foreach ($item in $TargetPath,$LocalPath_H,$LocalPath_V) {
        (pathSolver $item -type 0) |Out-Null
    }

    foreach ($item in $Local_HfhashP,$Local_VfhashP) {
        if((pathSolver $item) -or ((Get-Content $item).Count) -eq 0){
            switch ($item){
                $Local_HfhashP{
                    Get-ChildItem -Path $LocalPath_H\* -Include *.jpg,*.png | ForEach-Object -Process {(Get-FileHash $_).hash} | Add-Content $Local_HfhashP}
                $Local_VfhashP{
                    Get-ChildItem -Path $LocalPath_V\* -Include *.jpg,*.png | ForEach-Object -Process {(Get-FileHash $_).hash} | Add-Content $Local_VfhashP}
                Default{}
            }
        }
    }

    # Write-Host("Dirs/files check complete!")

    if ((Test-Path $TargetPath) -and (Test-Path $LocalPath_H) -and (Test-Path $LocalPath_V)) {

        $TargetfHashes_H = New-Object System.Collections.Generic.List[System.Object]
        $TargetfHashes_V = New-Object System.Collections.Generic.List[System.Object]

        $MoveItems_H = New-Object System.Collections.Generic.List[System.Object]
        $MoveItems_V = New-Object System.Collections.Generic.List[System.Object]
    
        banner
        $TargetFiles =(Get-ChildItem $TargetPath)
    
        foreach($item in $TargetFiles){
            switch (HVdiff -targetF $item)
            {
                0 {$TargetfHashes_H += (Get-FileHash $item.FullName)}
                1 {$TargetfHashes_V += (Get-FileHash $item.FullName)}
                Default {}
            }
        }
    
        $LocalfHashes_H = Get-Content $Local_HfhashP
        $LocalfHashes_V = Get-Content $Local_VfhashP

        $MoveItems_H = (calcMvitems -Target $TargetfHashes_H -Local $LocalfHashes_H)
        $MoveItems_V = (calcMvitems -Target $TargetfHashes_V -Local $LocalfHashes_V)
        
        if ($MoveItems_H) {
            notify("Horizontal Photos")
            foreach ($item in $MoveItems_H){
                Write-Host(Split-Path $item -Leaf)
                Write-Host("-"*33)
            }        
        }
    
        if ($MoveItems_V) {
            notify("Vertical   Photos")
            foreach ($item in $MoveItems_V){
                Write-Host(Split-Path $item -Leaf)
                Write-Host("-"*33)
            }
        }
    
        if ($MoveItems_H -or $MoveItems_V) {
            notify("Copying new photo(s) to saving folder...")
            cpAction -MoveItems $MoveItems_H -tarPath $LocalPath_H
            (Get-FileHash $MoveItems_H).hash | Add-Content $Local_HfhashP
            cpAction -MoveItems $MoveItems_V -tarPath $LocalPath_V
            (Get-FileHash $MoveItems_V).hash | Add-Content $Local_VfhashP
        }else {
            notify("No new photo(s)!!!")
        }
    }
}

If ((Resolve-Path -Path $MyInvocation.InvocationName).ProviderPath -eq $MyInvocation.MyCommand.Path) {
    $startDTM=(Get-Date)
    main
    $endDTM=(Get-Date)
    Write-Host("Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds")
}