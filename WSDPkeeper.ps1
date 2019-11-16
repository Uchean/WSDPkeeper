<#
'##:::::'##::'######::'########:::::'##:::'##:'########:'########:'########::'########:'########::
 ##:'##: ##:'##... ##: ##.... ##:::: ##::'##:: ##.....:: ##.....:: ##.... ##: ##.....:: ##.... ##:
 ##: ##: ##: ##:::..:: ##:::: ##:::: ##:'##::: ##::::::: ##::::::: ##:::: ##: ##::::::: ##:::: ##:
 ##: ##: ##:. ######:: ########::::: #####:::: ######::: ######::: ########:: ######::: ########::
 ##: ##: ##::..... ##: ##.....:::::: ##. ##::: ##...:::: ##...:::: ##.....::: ##...:::: ##.. ##:::
 ##: ##: ##:'##::: ##: ##::::::::::: ##:. ##:: ##::::::: ##::::::: ##:::::::: ##::::::: ##::. ##::
. ###. ###::. ######:: ##::::::::::: ##::. ##: ########: ########: ##:::::::: ########: ##:::. ##:
:...::...::::......:::..::::::::::::..::::..::........::........::..:::::::::........::..:::::..::
Windows Spotlight Photo keeper                                            Version 0.0.1 by Rui Zhu
MIT License                                                                     Copyright (c) 2019
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
    Process
    {
        # Write-Host($Target.Count)
        # Write-Host($Local.Count)
        $moveItems = New-Object System.Collections.Generic.List[System.Object]
        if ($Target.Path -And $Local.Path)
        {
            foreach ($itemT in $Target)
            {
                $z=0
                foreach ($itemN in $Local)
                {
                    if ($itemT.Hash -eq $itemN.Hash){$z++;break}
                }
                if (-not $z){$moveItems.Add($itemT.Path)}
            }
        }
        elseif ($Target.Path -And -not $Local.Path)
        {
            foreach ($item in $Target)
            {
                $moveItems.add($item.Path)
            }
        }
        # Write-Host($moveItems.Count)
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

function pathSolver ([String]$path) {
    if (-not (Resolve-Path $path)) {
        New-Item -Path $path -ItemType Directory
    }
}
function main {

    $TargetPath  = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
    $workingDir  = "$env:USERPROFILE\Pictures"
    $LocalPath_H = "$workingDir\Saved Pictures\Horizontal"
    $LocalPath_V = "$workingDir\Saved Pictures\Vertical"
    

    pathSolver($workingDir)
    if ($(Get-Location).Path -eq $workingDir) {
        Set-Location $workingDir
    }

    foreach ($item in $TargetPath,$LocalPath_H,$LocalPath_V) {
        pathSolver($item)
    }

    if ((Resolve-Path $TargetPath) -and (Resolve-Path $LocalPath_H) -and (Resolve-Path $LocalPath_V)) {

        $TargetfHashes_H = New-Object System.Collections.Generic.List[System.Object]
        $TargetfHashes_V = New-Object System.Collections.Generic.List[System.Object]
        $LocalfHashes_H = New-Object System.Collections.Generic.List[System.Object]
        $LocalfHashes_V = New-Object System.Collections.Generic.List[System.Object]
    
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
    
        $LocalFiles_H = Get-ChildItem $LocalPath_H\* -Include *.jpg, *.png
        $LocalFiles_H | ForEach-Object -Process {$LocalfHashes_H += (Get-FileHash $_.FullName)}
    
        $LocalFiles_V = Get-ChildItem $LocalPath_V\* -Include *.jpg, *.png
        $LocalFiles_V | ForEach-Object -Process {$LocalfHashes_V += (Get-FileHash $_.FullName)}
    
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
            cpAction -MoveItems $MoveItems_V -tarPath $LocalPath_V
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