#Specific use script used to clean up an output directory where revisions of files were saved as _1.mp4 instead of overwriting the original

#Initialise location of source folder
$root = "\\REDACTED\"
Set-Location "$root"

#Now we start the core loop

while($true)
{
$date = Get-Date
"Current date-time: " + $date
"This script will run in a loop until cancelled (press Ctrl+C), cleaning up the Output folder"
"Files detected in subfolders of" + $root + ":`n"
#First list all files in the Output directories
$folders = (Get-Childitem -directory | Sort Name)

Foreach ($folder in $folders)
#Check each subfolder for files
	{
	$path = $folder.FullName
	"`n"
	"Scanning $path for revised files:"
	#Actually just check for second revision files
	$files = (Get-Childitem -Path $path -file | where {$_.Name -like "*_?.mp4"} | Select FullName | Sort Fullname)

	Foreach ($file in $files)
	#List each file, then delete its original revision and rename it
		{
		"`n"
		$fullName = $file.FullName
		"    Revised file detected: $fullName"
		
		$original = $file.FullName
		$original = $original.Replace("_1.mp4",".mp4")
		$original = $original.Replace("_2.mp4",".mp4")
		$original = $original.Replace("_3.mp4",".mp4")
		$original = $original.Replace("_4.mp4",".mp4")
		$original = $original.Replace("_5.mp4",".mp4")
		$original = $original.Replace("_6.mp4",".mp4")
		$original = $original.Replace("_7.mp4",".mp4")
		$original = $original.Replace("_8.mp4",".mp4")
		$original = $original.Replace("_9.mp4",".mp4")
		
		#Check whether the original file exists
		"    Trying to delete original file $original"
		$confirm = Test-Path $original
		$confirm
		If ($confirm) #the original file exists
			{	
				
				Try #deleting the original file
					{
					Remove-Item -path $original -ErrorAction Stop
					"        Successfully deleted original file"
					Try #renaming the revised file
						{
						
						Rename-Item -path $fullName -NewName $original -ErrorAction Stop
						"        Successfully renamed revised file to $original"
						}
					Catch
						{
						"        Could not rename file $fullName: $_"
						}
					}
				Catch
					{
					"        Could not delete original file: $_"
					}
			}
		Else #if there *is* no original
			{
			"        No original file detected"
			Try #Just rename the revised file and call it a day
				{
					
				Rename-Item -path $fullName -NewName $original -ErrorAction Stop
				"        Successfully renamed revised file to $original"
				}
			Catch
				{
				"        Could not rename file $fullName: $_"
				}
			}
		} #End single file loop
	} #End subfolder loop
"`n"
$date = Get-Date
"Loop ended at $date. Now waiting an hour before running again"
Start-Sleep -Seconds 3600 #one hour
#Start-Sleep -Seconds 60 #one minute
"`n"
}