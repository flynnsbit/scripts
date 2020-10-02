$ErrorActionPreference = "Stop"

Function Move-ExoDosCdImages([Parameter(Mandatory=$true)]$InputPath, [Parameter(Mandatory=$true)]$GameName, [Parameter(Mandatory=$true)]$OutputPath){

    $MainCdFileExtensions = ".iso", ".cue";
    $RedbookLabel = " (Redbook Audio)";
    $Ba1File = $Null;
    $HasRedbookAudio = $Null;
    
    $CdDir = Get-ChildItem -Path $InputPath.FullName -Recurse -Filter "Cd";

    if($CdDir){

        # scan any cue files to check for redbook audio tracks
        $HasRedbookAudio = ($CdDir | Get-ChildItem -Filter "*.cue" | Get-Content | Select-String "AUDIO" | Select -First 1)
        
        # make up our full destination path for cds
        $DestinationPath = Join-Path $ExtractedCds $GameName;
        if($HasRedbookAudio){
            $DestinationPath = $DestinationPath + $RedbookLabel;
        }

        # don't do anything if the dir is already present.
        if(Test-Path $DestinationPath){ 
            return 
        }

        # make the destination path
        New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null;

        $CdFiles = Get-ChildItem -Path $CdDir.FullName -Recurse;
        
        $CdsToRename = $CdFiles | Where Extension -In ($MainCdFileExtensions);

        $CountCds = ($CdsToRename | Measure-Object).Count;

        $i=1;

        $SortedCdFiles = $CdFiles | Sort-Object Name;
        
        $SortedCdFiles | ForEach-Object{                

            # only rename "main" files: 
            if ($_.Extension -in ($MainCdFileExtensions)){
                # handle multiple discs
                if($CountCds -gt 1){
                    $DestinationFile = Join-Path $DestinationPath ("{0} - Disc {1}{2}" -f $GameName, $i, $_.Extension);
                    $i++;                    
                    Copy-Item -LiteralPath $_.FullName -Destination $DestinationFile -Force | Out-Null;
                }
                # handle single discs
                else{
                    $DestinationFile  = Join-Path $DestinationPath ("{0}{1}" -f $GameName, $_.Extension);
                    Copy-Item -LiteralPath $_.FullName -Destination $DestinationFile -Force | Out-Null;                  
                }
            }
            # handle misc other files (bins, subs etc)
            else{
                Copy-Item -LiteralPath $_.FullName -Destination $DestinationPath -Force | Out-Null;
            }
        } 
    }
}

Function Get-ExoDosGameNameFromFolder([Parameter(Mandatory=$true)]$InputPath){
    # use .ba1 for full name if present
    $Ba1File = (Get-ChildItem -Path $InputPath.FullName -Filter "*.ba1" | Select -First 1)
    
    # else use foldername
    if($Ba1File){
        $GameName = $Ba1File.ToString().Replace(".ba1","");
    }
    else{
        $GameName = $InputPath.Name;
    }

    $GameName;
}

$ExodosRootPath = "E:\Exo";
$ExtractedCds = "E:\AO486CDS";

$Games = Get-ChildItem -Path $ExodosRootPath # | Where Name -In "comcon", "bsword1", "descent2", "7thguest", "doom"
if(!$Games){
    "no games found";
    exit;
};

$CountGames = ($Games | Measure-Object).Count;

$GamesProcessed = 1;

$Games | ForEach-Object{ 

    $GameName = Get-ExoDosGameNameFromFolder -InputPath $_;

    Write-Progress -Activity $GameName -PercentComplete ( $GamesProcessed / $CountGames * 100 );

    Move-ExoDosCdImages -InputPath $_ -GameName $GameName -OutputPath $ExtractedCds;

    $GamesProcessed++;
};