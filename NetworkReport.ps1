Param( 
  #$date = (Get-Date).dayofyear,
  $date = $args[0],
  [string]$path = "\\REDACTED\website\NetworkReport" + $date + ".html", 
  [array]$servers = @("server1","server2"),
  [array]$computers = (Get-ADComputer -Filter * -Property * -SearchBase 'OU=Used,OU=Desktops,OU=Computers - Assigned,dc=example,dc=local' | Sort-Object name).name,
  [array]$unusedcomputers = (Get-ADComputer -Filter * -Property * -SearchBase 'OU=Unused,OU=Desktops,OU=Computers - Assigned,dc=example,dc=local' | Sort-Object name).name,
  [array]$buildmachines = (Get-ADComputer -Filter * -Property * -SearchBase 'OU=Build Machines,OU=Computers - Assigned,dc=example,dc=local' | Sort-Object name).name,
#  [array]$computers = @("pc-1","pc-2","pc-3"),
  [string]$offlinecomputers = (": "),
  [string]$header = "The following report was run on $(get-date)"
) 
 
Function Get-UpTime 
{ 
  Param ([string[]]$devices) 
  Write-Host "`n Getting uptime for $devices"
  Foreach ($device in $devices)  
   {  
		Try
		{
			 $os = Get-WmiObject -class win32_OperatingSystem -cn $device -ErrorAction Stop
			 $uptime = (get-date) - $os.converttodatetime($os.lastbootuptime)
			 New-Object psobject -Property @{Server=$device; 
			   Uptime = $uptime.ToString("dd") + " days"} 
		}
		Catch
		{
		Write-Host "    Could not retrieve uptime information from $device"
		Write-Host "        $_"
		$offlinecomputers = $offlinecomputers + $device + ", "
		Write-Host "        Current list of offline computers$offlinecomputers"
		}
    } #end foreach $device		
} #end function Get-Uptime 
 
Function Get-DiskSpace 
{ 
 Param ([string[]]$devices,[string[]]$drive) 
 Write-Host "`n Getting $drive drive information from $devices"
  Foreach ($device in $devices)  
   {  
     Try
		{Get-WmiObject -Class Win32_logicaldisk -cn $device -Filter "Name like '$drive%'" -ErrorAction Stop |
		Select-Object @{LABEL='Computer';EXPRESSION={$device}}, 
         @{LABEL='Disk';EXPRESSION={$_.name}},
         @{LABEL='Free Space (GB)';EXPRESSION={"{0:N2}" -f ($_.freespace/1GB)}},
		 @{LABEL='Size (GB)';EXPRESSION={"{0:N2}" -f ($_.size/1GB)}}
		}
	Catch
		{
		Write-Host "    Could not retrieve $drive drive information from $device"
		Write-Host "        $_"
		}
	
    } #end foreach $device 
} #end function Get-DiskSpace 
 
# Entry Point *** 
while($true)
{
$date = Get-Date
Write-Host "Current date-time: " + $date
Write-Host "This script will run in a loop until cancelled (press Ctrl+C), producing an HTML network report."

$header = "The following report was run on $(get-date)"
$offlinecomputers = ": "
"Total offline computers$offlinecomputers"

$ServerupTime = Get-UpTime -devices $servers | ConvertTo-Html -As Table -Fragment -PreContent " <h2>Server Uptime</h2> " | Out-String 
$ComputerupTime = Get-UpTime -devices $computers | Sort-Object 'Uptime' –Descending | ConvertTo-Html -As Table -Fragment -PreContent " <h2>PC Uptime</h2> " | Out-String
$UnusedComputerupTime = Get-UpTime -devices $unusedcomputers | Sort-Object 'Uptime' –Descending | ConvertTo-Html -As Table -Fragment -PreContent " <h2>Unused PC Uptime</h2> " | Out-String
$BuildMachineupTime = Get-UpTime -devices $buildmachines | Sort-Object 'Uptime' –Descending | ConvertTo-Html -As Table -Fragment -PreContent " <h2>Build machine Uptime</h2> " | Out-String

$serverCdisks = Get-DiskSpace -devices $servers -drive "C" | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Server system disk space</h2>"| Out-String   
$serverDdisks = Get-DiskSpace -devices $servers -drive "D" | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Server data disk space</h2>"| Out-String   
$computerCdisks = Get-DiskSpace -devices $computers -drive "C" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>PC system disk space</h2>"| Out-String   
$computerIdisks = Get-DiskSpace -devices $computers -drive "I" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>PC data disk space</h2>"| Out-String
$unusedcomputerCdisks = Get-DiskSpace -devices $unusedcomputers -drive "C" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Unused PC system disk space</h2>"| Out-String   
$unusedcomputerIdisks = Get-DiskSpace -devices $unusedcomputers -drive "I" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Unused PC data disk space</h2>"| Out-String   
$buildmachineCdisks = Get-DiskSpace -devices $buildmachines -drive "C" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Build machine system disk space</h2>"| Out-String
$buildmachineIdisks = Get-DiskSpace -devices $buildmachines -drive "I" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Build machine data disk (I) space</h2>"| Out-String
$buildmachinePdisks = Get-DiskSpace -devices $buildmachines -drive "P" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Build machine data disk (P) space</h2>"| Out-String

"Total offline computers$offlinecomputers"

[string]$header = "The following report was run on $date"
ConvertTo-Html -Title "Network Summary" -Head '<link rel="stylesheet" type="text/css" href="http://REDACTED/NetworkReport.css">'`
 -Body `
 '<div class="section"><h1>Imaginati Network Summary</h1>', $header, '</div>', `
 '<div id="server" class=section>', `
 '<div id="serveruptime" class="column">', $ServerupTime, '</div>', `
 '<div id="servercdisks" class="column">', $serverCdisks, '</div>', `
 '<div id="serverddisks" class="column">', $serverDdisks, '</div>', `
 '</div>', `
 '<div id="Offline PCs" class="section">', `
 '<div id="offlinepclist" class="column">', "Offline PCs$offlinecomputers", '</div>', `
 '</div>', `
  '<div id="PCs" class="section">', `
 '<div id="computeruptime" class="column">', $ComputerupTime, '</div>', `
 '<div id="computercdisks" class="column">', $computerCdisks, '</div>', `
 '<div id="computerddisks" class="column">', $computerIdisks, '</div>', `
 '</div>', 
 '<div id="Unused PCs" class="section">', `
 '<div id="unusedcomputeruptime" class="column">', $UnusedComputerupTime, '</div>', `
 '<div id="unusedcomputercdisks" class="column">', $unusedcomputerCdisks, '</div>', `
 '<div id="unusedcomputerddisks" class="column">', $unusedcomputerIdisks, '</div>', `
 '</div>',  `
 '<div id="Build Machines" class="section">', `
 '<div id="BuildMachineuptime" class="column">', $buildmachineupTime, '</div>', `
 '<div id="buildmachinecdisks" class="column">', $buildmachineCdisks, '</div>', `
 '<div id="buildmachineIdisks" class="column">', $buildmachineIdisks, '</div>', `
 '<div id="buildmachinePdisks" class="column">', $buildmachinePdisks, '</div>', `
 '</div>'  `
 > $path  
#Invoke-Item $path 
$date = Get-Date
Write-Host "`n Report finished at $date, and available at http://REDACTED/website/NetworkReport.html. Will run again in 10 minutes."
Start-Sleep -Seconds 360 #ten minutes
"`n"
}
