function Set-SPClaimProviderAssignment
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, HelpMessage = 'Enter the web application URL')]
		[string]
		$WebApplicationUrl,
		
		[Parameter(Mandatory = $true, HelpMessage = 'Enter the zone')]
		[Microsoft.SharePoint.Administration.SPUrlZone]
		$Zone,
		
		[Parameter(Mandatory = $false, HelpMessage = 'Enter the Login Provider name')]
		[string]
		$LoginProvider,
		
		[Parameter(ParameterSetName = 'Set', Mandatory = $true, HelpMessage = 'Enter the Claims Providers')]
		[string[]]
		$ClaimsProviders,
		
		[Parameter(ParameterSetName = 'Clear', Mandatory = $true)]
		[switch]
		$Clear
	)
	
	$webApp = Get-SPWebApplication $WebApplicationUrl
	
	if ($webApp.IisSettings.ContainsKey($Zone))
	{
		$iis = $webApp.IisSettings[$Zone]
		
		if ($LoginProvider)
		{
			$cap = $iis.ClaimsAuthenticationProviders | ? { $_.DisplayName -eq $LoginProvider }
			if ($cap)
			{
				if ($Clear) {
					$cap.ClaimProviderName = $null
				} else {
					$cap.ClaimProviderName = $ClaimsProviders[0]
				}
				$save = $true
			}
		}
		else
		{
			if ($Clear) {
				$iis.ClaimsProviders = [String[]]@()
			} else {
				$iis.ClaimsProviders = $ClaimsProviders
			}
			$save = $true
		}
		
		if ($save) {
			$webApp.Update()
		}
	}
	else {
		Write-Error 'Zone not found on web application.'
	}
}

function Show-SPClaimProviderAssignment
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false, HelpMessage = 'Enter the web application URL')]
		[string[]]
		$WebApplicationUrl = (Get-SPWebApplication | Select -ExpandProperty Url)
	)
	
	foreach ($url in $WebApplicationUrl)
	{
		Write-Host
		$webApp = Get-SPWebApplication $url
		Write-Host $webApp.Url ':' $webApp.DisplayName
		
		foreach ($kv in $webApp.IisSettings.GetEnumerator())
		{
			Write-Host "  [$($kv.Key) Zone]"
			$iis = $kv.Value
			$cps = [String[]]$iis.ClaimsProviders
			
			Write-Host "    Claim Providers: {$cps}"
			
			Write-Host '    Login Providers:'
			foreach ($cap in $iis.ClaimsAuthenticationProviders)
			{
				Write-Host "      $($cap.DisplayName): {$($cap.ClaimProviderName)}"
			}
		}
	}
}

Export-ModuleMember -Function `
	Set-SPClaimProviderAssignment, `
	Show-SPClaimProviderAssignment