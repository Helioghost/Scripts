#Script to add text to the start of the name of every file in a folder
$path = "\\REDACTED\"
Set-Location "$path"
#List files
$files = (Get-Childitem -Path $path -file | Sort LastWriteTime)
write $files

Foreach ($file in $files)
#List each file, then rename 
	{
	$original = $path + $file.Name
	$new = $path + "TEXT TO PREPEND HERE" + $file.Name
    Try #renaming the revised file
        {
			
        Rename-Item -path $original -NewName $new -ErrorAction Stop
        "        Successfully renamed $original to $new"
        }
    Catch
        {
        "        Could not rename $original"
        }
    }