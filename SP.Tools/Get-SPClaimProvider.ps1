# Author: Pat Kaeowichien
# Date: 2016-03-22

function Get-SPClaimProvider
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [Microsoft.SharePoint.PowerShell.SPClaimProviderPipeBind]
        ${Identity},

        [Parameter(ValueFromPipeline=$true)]
        [Microsoft.SharePoint.PowerShell.SPAssignmentCollection]
        ${AssignmentCollection},


        [Parameter(ValueFromPipeline=$false)]
        [string]
        $DisplayNameFilter
    )

    begin
    {
        try {
            # Need to remove custom parameter so it does not get passed to the proxied command
            if ($PSBoundParameters.ContainsKey('DisplayNameFilter'))
            {
                [void]$PSBoundParameters.Remove('DisplayNameFilter')
            }

            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Get-SPClaimProvider', [System.Management.Automation.CommandTypes]::Cmdlet)
            
			if ($DisplayNameFilter)
            {
                $scriptCmd = { & $wrappedCmd @PSBoundParameters | ? { $_.DisplayName -like $DisplayNameFilter } } 
            }
            else
            {
               $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            }
			
			$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Get-SPClaimProvider
    .ForwardHelpCategory Cmdlet

    #>
}

Export-ModuleMember -Function `
	Get-SPClaimProvider