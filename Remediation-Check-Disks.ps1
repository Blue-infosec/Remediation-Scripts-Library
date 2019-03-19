<#
.Synopsis
   Aternity - Remediation Script: Remediation-Check-Disks
.DESCRIPTION
	Perform a Repair Volume scan and fix errors online
	
	Aternity References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Check Disks - spotFix
   Description: Perform a check disk diagnostic and fix errors
   Run the script in the System account: checked
   
#>

#region Remediation action logic

$all_repairStatus=@()
Get-Volume | % {
	$driveLetter=$_.DriveLetter
	if ($driveLetter) {
		$scanStatus=Repair-Volume $driveLetter -Scan
		$repairStatus=(Repair-Volume $driveLetter -SpotFix)
		$all_repairStatus += "$driveLetter $repairStatus"		
	}
}
$result = $all_repairStatus -join ";"
 
#endregion

#region Aternity remediation status monitoring 
try
{
	# Set the path of the Agent on user device
	$env:STEELCENTRAL_ATERNITY_AGENT_HOME="C:\Program Files (x86)\Aternity Information Systems\Agent"

	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	
	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
#endregion
