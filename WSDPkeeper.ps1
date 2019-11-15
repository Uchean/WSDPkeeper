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
        if ($Target.Count -gt 0 -And $Local.Count -gt 0)
        {
            for ($i=0;$i -lt $Target.Count; $i++)
            {
                $z=0
                for($n=0; $n -lt $Local.Count; $n++)
                {
                    if ($Target[$i].Hash -eq $Local[$n].Hash)
                    {
                        $z++
                    }
                    if ($z) {break}
                }
                if ($z -eq 0)
                {
                $moveItems.Add($Target[$i])
                }
            }
        }
        elseif ($Target.Count -gt 0 -And $Local.Count -eq 0)
        {
            for ($i=0; $i -lt $Target.Count; $i++)
            {
                $moveItems.add($Target[$i])
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
        [String]$shapeSpec=""
    )
    Process{
        $Metadata = New-Object System.Collections.Generic.List[System.Object]

        if ($moveItems.Path.Count) {
            $i=0
            foreach ($item in $moveItems)
            {
                $Metadata.Add((Get-ChildItem $item.Path | Get-Image | Select-Object Width, Height))
                if($Metadata[-1].Width -gt $Metadata[-1].Height)
                { 
                    $shapeSpec = "H"
                }
                else{
                    $shapeSpec = "V"
                }

                Write-Host ("Resolution: " + $Metadata[-1].Width + " x " + $Metadata[-1].Height + $item.Name + "`t" + $shapeSpec)
                Copy-Item $item.Path ($tarPath + "\" + $shapeSpec + "_Windows10_Focus_" + (Get-Date -UFormat "%Y%m%d%H%M_") + ("{0:d4}" -f $i) + ".jpg")
                Write-Host ($tarPath + "\" + $shapeSpec + "_Windows10_Focus_" + (Get-Date -UFormat "%Y%m%d%H%M_") + ("{0:d4}" -f $i) + ".jpg")
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
        $TargetFiles = Get-ChildItem $TargetPath
    
        foreach($i in $TargetFiles){
            switch (HVdiff -targetF $i)
            {
                0 {$TargetfHashes_H += (Get-FileHash $i.FullName)}
                1 {$TargetfHashes_V += (Get-FileHash $i.FullName)}
                Default {}
            }
        }
    
        $LocalFiles_H = Get-ChildItem $LocalPath_H\* -Include *.jpg, *.png
        $LocalFiles_H | ForEach-Object -Process {$LocalfHashes_H += (Get-FileHash $_.FullName)}
    
        $LocalFiles_V = Get-ChildItem $LocalPath_V\* -Include *.jpg, *.png
        $LocalFiles_V | ForEach-Object -Process {$LocalfHashes_V += (Get-FileHash $_.FullName)}
    
        $MoveItems_H = (calcMvitems -Target $TargetfHashes_H -Local $LocalfHashes_H)
        $MoveItems_V = (calcMvitems -Target $TargetfHashes_V -Local $LocalfHashes_V)
        
        if ($MoveItems_H.Path.Count) {
            notify("Horizontal Photos")
            foreach ($item in $MoveItems_H){
                Write-Host($item.Path)
                Write-Host("="*48)
            }        
        }
    
        if ($MoveItems_V.Path.Count) {
            notify("Vertical   Photos")
            foreach ($item in $MoveItems_V){
                Write-Host($item.Path)
                Write-Host("="*48)
            }
        }
    
        if ($MoveItems_H.Path.Count -or $MoveItems_V.Path.Count) {
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