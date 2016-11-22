$_claimProviderNames = @{}

function Find-SPClaimsUser
{
	param(
		[Parameter(Mandatory = $true)]
		[string]
		$Web,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Text,
		
		[string[]]
		$Providers = $null,
		
		[int]
		$MaxResults = 10
	)
	
	$uri = New-Object Uri -ArgumentList $Web
	$entityTypes = @([Microsoft.SharePoint.Administration.Claims.SPClaimEntityTypes]::User)
	$results = [Microsoft.SharePoint.Administration.Claims.SPClaimProviderOperations]::Search(
		$uri,
		[Microsoft.SharePoint.Administration.Claims.SPClaimProviderOperationOptions]::None,
		$Providers,
		$entityTypes,
		$Text,
		$MaxResults
	)
	
	$pickerItems = @()
	
	_FlattenResultsTree $results ([ref]$pickerItems)

	return ($pickerItems | _CreateUserEntry)
}

function Get-SPClaimsUser
{
	param(
		[Parameter(Mandatory = $true)]
		[string]$Web,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "A string that identifies the user.")]
		[string]$Identity,
		[string[]]$Providers = $null
	)
	
	begin
	{
		$uri = New-Object Uri -ArgumentList $Web
		$entityTypes = @([Microsoft.SharePoint.Administration.Claims.SPClaimEntityTypes]::User)
	}
	process
	{
		$results = [Microsoft.SharePoint.Administration.Claims.SPClaimProviderOperations]::Resolve(
			$uri,
			[Microsoft.SharePoint.Administration.Claims.SPClaimProviderOperationOptions]::None,
			$Providers,
			$entityTypes,
			$Identity
		)
		if ($results -eq $null) {
			return
		}
		
		if ($results.Length -eq 1 -and $results[0].IsResolved) {
			Write-Output (_CreateUserEntry $results[0])
		}
	}
}

function _FlattenResultsTree
{
	param(
		[Microsoft.SharePoint.WebControls.SPProviderHierarchyTree[]] $results,
		[ref]$userList
	)
	foreach ($node in $results)
	{
		foreach ($entity in $node.EntityData)
		{
			$userList.value += $entity
		}
		_FlattenResultsNode $node.Children ([ref]$userList.value)
	}
}

function _FlattenResultsNode
{
	param(
		[Microsoft.SharePoint.WebControls.SPProviderHierarchyNode[]] $nodes,
		[ref]$userList
	)
	foreach ($node in $nodes)
	{
		foreach ($entity in $node.EntityData)
		{
			$userList.value += $entity
		}

		_FlattenResultsNode $node.Children ([ref]$userList.value)
	}
}

function _CreateUserEntry
{
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Microsoft.SharePoint.WebControls.PickerEntity] $entity
	)
	process {
		$user = @{
			"Id" = $entity.Key;
			"DisplayText" = $entity.DisplayText;
			"Description" = $entity.Description;

			"Email" = $entity.EntityData[[Microsoft.SharePoint.WebControls.PeopleEditorEntityDataKeys]::Email];
			"DisplayName" = $entity.EntityData[[Microsoft.SharePoint.WebControls.PeopleEditorEntityDataKeys]::DisplayName];
			"AccountName" = $entity.EntityData[[Microsoft.SharePoint.WebControls.PeopleEditorEntityDataKeys]::AccountName];
			"ProviderName" = (_GetDisplayName $entity.ProviderName)
		}
		Write-Output (New-Object PSObject -Property $user)
	}
}

function _GetDisplayName
{
	param(
		[string] $claimProviderName
	)
	$displayName = $_claimProviderNames[$claimProviderName]
	if (!$displayName)
	{
		$claimProvider = [Microsoft.SharePoint.Administration.Claims.SPClaimProviderManager]::Local.GetClaimProvider($claimProviderName)
		$displayName = $_claimProviderNames[$claimProviderName] = if ($claimProvider -ne $null) { $claimProvider.DisplayName } else { $null }
	}

	return $displayName;
}

Export-ModuleMember -Function `
	Find-SPClaimsUser, `
	Get-SPClaimsUser`
	