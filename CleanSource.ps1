#Specific use script to clean up a folder where files were written to subfolders instead of the main directory

#Initialise location of source folder
$root = "\\REDACTED\"
Set-Location "$root"

#Now we start the core loop

while($true)
{
$date = Get-Date
"Current date-time: " + $date
"This script will run (every hour) until cancelled (press Ctrl+C), cleaning up the Source folder"
"Files detected in subfolders of" + $root + ":`n"
#First check for subfolders of Source (ideally there should be none)
$folders = (Get-Childitem -directory | Sort LastWriteTime)

Foreach ($folder in $folders)
#Check each subfolder for files
	{
	$path = $root + $folder.Name
	$files = (Get-Childitem -Path $path -file | Sort LastWriteTime)

	Foreach ($file in $files)
	#List each file, delete its original, then move the new one to root
		{

		#$fullfilepath = $path + "\" + $file.Name
		#$fullfilepath
		$original = $root + "\" + $file.Name
		Try
			{
			Remove-Item -path $original -ErrorAction Stop
			"Original file $original deleted from Source"
			}
		Catch
			{
			"Could not delete original file $original - $_"
			}
		Try
			{
			#Move-Item $fullfilepath $root -force -ErrorAction Stop
			Move-Item $file.FullName $root -force -ErrorAction Stop
			"New file $file moved back into Source successfully"
			}
		Catch
			{
			"Could not move new file $file - $_"
			}
		}
	#Then delete the folder
	#$path
	Try
		{
		Remove-Item -path $path -ErrorAction Stop
		"$path deleted"
		}
	Catch
		{
		"Could not delete $path - $_"
		
		}
	}
"`n"
$date = Get-Date
"Loop ended at $date. Now waiting an hour before running again"
Start-Sleep -Seconds 3600
"`n"
}