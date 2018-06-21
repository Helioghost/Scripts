




<#
Lone lines of code

This scans a PC and returns the user list
Invoke-Command -cn Example-PC -ScriptBlock {Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | select Name, Domain, Disabled | Format-Table }

This should change the password
"WinNT://$Example-PC/Administrator,user".psbase.invoke("setpassword","PASSWORDSTRING")


#>



#This script scans through all computers in computers.txt aand resets their administrator passwords.
"Hello World `n"

<# $password = Read-Host "Enter the password" -AsSecureString
$confirmpassword = Read-Host "Confirm the password" -AsSecureString
$pwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.
  InteropServices.Marshal]::SecureStringToBSTR($password))
$pwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.
  InteropServices.Marshal]::SecureStringToBSTR($confirmpassword))
if($pwd1_text -ne $pwd2_text) {
   Write-Error "Entered passwords are not same. Script is exiting"
exit
}
#>
#$Computers = get-content computers.txt
$Computers = (Get-ADComputer -Filter * -Property * -SearchBase 'OU=Desktops,OU=Computers - Assigned,dc=example,dc=local' | Sort-Object name).name
#$Computers = get-content computers_test.txt
$Computers = @("pc-1")
$UsersToDisable = @("admin","administrator","DefaultAccount","hp","User","temp")

$password = Read-Host -prompt "Enter new password for user" -assecurestring
$decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
Foreach($computer in $computers)
{
Try
	{
		$computer
		$localuserlist = (Invoke-Command -cn $computer -ScriptBlock {Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | select Name, Domain, Disabled | Format-Table }  -ErrorAction Stop)
		$localuserlist
		"Enabling LocalAdmin"
		$user = "LocalAdmin"
		"Setting user to $user"
		$account = [adsi]"WinNT://$computer/$user,user"
		#"User is set to $account"
		Try
		{
			If (! $account.Name)
			{
			Throw "$user does not exist. :-( `n"
			}
			"Enabling account"
			$account.psbase.invokeset("AccountDisabled", "False")
			$account.SetInfo()
			"Success! ^_^ `n"
		}
		Catch
		{
			"$_"
		}
		"Disabling unnecessary user accounts"
		Foreach($user in $UsersToDisable)
		{
			"Setting user to $user"
			$account = [adsi]"WinNT://$computer/$user,user"
			#"User is set to $account"
			Try
			{
				If (! $account.Name)
				{
				Throw "$user does not exist. :-( `n"
				}
				"Disabling account"
				$account.psbase.invokeset("AccountDisabled", "True")
				$account.SetInfo()
				"Success! ^_^ `n"
			}
			Catch
			{
				"$_"
			}
		}
		$localuserlist = (Invoke-Command -cn $computer -ScriptBlock {Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | select Name, Domain, Disabled | Format-Table }  -ErrorAction Stop)
		$localuserlist
		"Resetting admin passwords"
		Foreach($user in $Users)
		{
			"Setting user to $user"
			$account = [adsi]"WinNT://$computer/$user,user"
			#"User is set to $account"
			Try
			{
				If (! $account.Name)
				{
				Throw "$user does not exist. :-( `n"
				}
				"Setting password"
				$account.SetPassword($decodedpassword)
				$account.SetInfo()
				"Success! ^_^ `n"
			}
			Catch
			{
				"$_"
			}
		}
	}
Catch
	{
		"$_"
	}
}

<# $user = [adsi]"WinNT://$computer/admin,user"
 $user
 $user.SetPassword($decodedpassword)
 $user.SetInfo()
 $user = [adsi]"WinNT://$computer/LocalAdmin,user"
 $user
 $user.SetPassword($decodedpassword)
 $user.SetInfo()
}#>

<#
foreach ($Computer in $Computers) {
#Here is a line of code (to run locally) to check for accounts:
#e.g.
Invoke-Command -cn $Computer -ScriptBlock  `
{Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | where {$_.Disabled -ne "True"} | select Name, Domain, Disabled | Format-Table } `
#-ErrorAction Stop
#
#>

<#    $Computer    =    $Computer.toupper()
   $Isonline    =    "OFFLINE"
   $Status        =    "SUCCESS"
    Write-Verbose "Working on $Computer"
if((Test-Connection -ComputerName $Computer -count 1 -ErrorAction 0)) {
   $Isonline = "ONLINE"
   Write-Verbose "`t$Computer is Online"
} else { Write-Verbose "`t$Computer is OFFLINE" }
 
try {
   $account = [ADSI]("WinNT://$Computer/Administrator,user")
   $account.psbase.invoke("setpassword",$pwd1_text)
   Write-Verbose "`tPassword Change completed successfully"
}
catch {
  $status = "FAILED"
  Write-Verbose "`tFailed to Change the administrator password. Error: $_"
}
 
$obj = New-Object -TypeName PSObject -Property @{
  ComputerName = $Computer
  IsOnline = $Isonline
  PasswordChangeStatus = $Status
}
 
$obj | Select ComputerName, IsOnline, PasswordChangeStatus
 
if($Status -eq "FAILED" -or $Isonline -eq "OFFLINE") {
   $stream.writeline("$Computer `t $isonline `t $status")
}
 
}
 #>
<#
Lone lines of code
Invoke-Command -cn Example-PC -ScriptBlock {Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | select Name, Domain, Disabled | Format-Table }




#>