# Author: Pat Kaeowichien
# Date: 2016-03-22

function Get-SPFieldInfo
{
    [CmdletBinding()]
    param(
	    [Parameter(ParameterSetName = 'List', Mandatory = $true, ValueFromPipeline = $true)]
	    [Microsoft.SharePoint.SPList]
        $List,
	    
        [Parameter(ParameterSetName = 'ListItem', Mandatory = $true, ValueFromPipeline = $true)]
	    [Microsoft.SharePoint.SPListItem]
        $ListItem,

        [switch]
        $Formatted
    )
    begin
    {
    }
    process
    {
        if (-not $fields)
        {
            if ($List) {
	            $fields = $list.Fields
            }
            elseif ($ListItem) {
		        $fields = $ListItem.Fields
            }
        }
    }
    end
    {
        $fieldsInfo = $fields | % {
		    $tmp = @{
			    Title = $_.Title;
			    StaticName = $_.StaticName;
			    InternalName = $_.InternalName;
			    MaxLength = $_.MaxLength;
			    Type = $_.Type;
		    }
            if ($ListItem) {
                $tmp.Value = $ListItem[$_.InternalName]
            }
            New-Object PSObject -Property $tmp
	    }

	    if ($Formatted) {
		    if ($ListItem) {
			    $fieldsInfo | sort -property InternalName,Title | ft -Property Title,InternalName,StaticName,Type,MaxLength,Value
		    } else {
			    $fieldsInfo | sort -property InternalName,Title | ft -Property Title,InternalName,StaticName,Type,MaxLength
		    }
	    }
	    else {
		    $fieldsInfo
	    }
    }
}

function Select-SPFieldValue
{
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	    [Microsoft.SharePoint.SPListItem]
        $ListItem,

        [Parameter(Mandatory = $true)]
        [string[]]
        $Field,

        [switch]
        $Formatted
    )
    begin
    {
        $items = @()
    }
    process
    {
        $fieldValues = @{}
        $Field | % {
            $fieldValues[$_] = $ListItem[$_]
        }
        
        if ($Formatted) {
           $items += New-Object PSObject -Property $fieldValues
        } else {
            Write-Output (New-Object PSObject -Property $fieldValues)
        }
	    
    }
    end
    {
        if ($Formatted) {
		    $items | ft -AutoSize -Property $Field
	    }
    }
}