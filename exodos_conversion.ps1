$workingdir = "D:\working" #empty folder for processing zips (extracts and rezips)
$newdir = "D:\EXO2" #empty folder where all processed zips will be stored
$filedir = "D:\EXODOS\EXODOS\Games" #folder with current zip files, script does not change these files and will leave originals alone
 
$items = Get-ChildItem -Path $filedir
 
#Creates copy of all zips but moves files from the single folder to root
foreach($item in $items)
{
    Expand-Archive -Path $item.FullName -DestinationPath $workingdir
    $folder = Get-ChildItem $workingdir
    Compress-Archive -Path "$($folder.FullName)\*" -DestinationPath "$newdir\$($item.name)" -Update
    Remove-Item "$workingdir\*" -Recurse -Force
}
