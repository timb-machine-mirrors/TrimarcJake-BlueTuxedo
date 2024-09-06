function Invoke-BlueTuxedo {
    [CmdletBinding()]
    param (
        [string]$Forest = (Get-ADForest).Name,
        [string]$InputPath,
        [switch]$ShowSecurityDescriptors = $false,
        [switch]$Demo = $false
    )

    if ($Demo) { Clear-Host }
    Show-BTLogo -Version 'v2024.2-testing'

    $Domains = Get-BTTarget -Forest $Forest -InputPath $InputPath

    #region Get Data
    Write-Host 'Please hold. Collecting DNS data from the following domains:' -ForegroundColor Green
    Write-Host $Domains -ForegroundColor Yellow

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] ADI Zones" -Verbose
    $ADIZones = Get-BTADIZone -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Conditional Forwarders" -Verbose
    $ConditionalForwarders = Get-BTConditionalForwarder -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Dangling SPNs" -Verbose
    $DanglingSPNs = Get-BTDanglingSPN -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] DNS Admins Memberships" -Verbose
    $DnsAdminsMemberships = Get-BTDnsAdminsMembership -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] DNS Update Proxy Memberships" -Verbose
    $DnsUpdateProxyMemberships = Get-BTDnsUpdateProxyMembership -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Dynamic Update Service Accounts" -Verbose
    $DynamicUpdateServiceAccounts = Get-BTDynamicUpdateServiceAccount -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Forwarder Configuration" -Verbose
    $ForwarderConfigurations = Get-BTForwarderConfiguration -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Global Query Blocklists" -Verbose
    $GlobalQueryBlockLists = Get-BTGlobalQueryBlockList -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Name Protection Configuration Lists" -Verbose
    $NameProtectionConfigurationLists = Get-BTNameProtectionConfiguration -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Non ADI Zones" -Verbose
    $NonADIZones = Get-BTNonADIZone -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Query Resolution Policies" -Verbose
    $QueryResolutionPolicys = Get-BTQueryResolutionPolicy -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Security Descriptors" -Verbose
    $SecurityDescriptors = Get-BTSecurityDescriptor -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Socket Pool Sizes" -Verbose
    $SocketPoolSizes = Get-BTSocketPoolSize -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Tombstoned Nodes" -Verbose
    $TombstonedNodes = Get-BTTombstonedNode -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Wildcard Records" -Verbose
    $WildcardRecords = Get-BTWildcardRecord -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] WPAD Records" -Verbose
    $WPADRecords = Get-BTWPADRecord -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Zone Scopes" -Verbose
    $ZoneScopes = Get-BTZoneScope -Domains $Domains

    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Zone Scope Containers" -Verbose
    $ZoneScopeContainers = Get-BTZoneScopeContainer -ADIZones $ADIZones

    Write-Host 'Finished collecting DNS data from the following domains:' -ForegroundColor Green
    Write-Host $Domains -ForegroundColor Yellow

    $CollectedData = @{
        'ADIZones'                     = $ADIZones
        'ConditionalForwarders'        = $ConditionalForwarders
        'DanglingSPNs'                 = $DanglingSPNs
        'DnsAdminsMemberships'         = $DnsAdminsMemberships
        'DnsUpdateProxyMemberships'    = $DnsUpdateProxyMemberships
        'DynamicUpdateServiceAccounts' = $DynamicUpdateServiceAccounts
        'ForwarderConfigurations'      = $ForwarderConfigurations
        'GlobalQueryBlockLists'        = $GlobalQueryBlockLists
        #'NameProtectionLists'         = $NameProtectionConfigurationLists
        'NonADIZones'                  = $NonADIZones
        'QueryResolutionPolicys'       = $QueryResolutionPolicys
        'SecurityDescriptors'          = $SecurityDescriptors
        'SocketPoolSizes'              = $SocketPoolSizes
        'TombstonedNodes'              = $TombstonedNodes
        'WildcardRecords'              = $WildcardRecords
        'WPADRecords'                  = $WPADRecords
        'ZoneScopes'                   = $ZoneScopes
        'ZoneScopeContainers'          = $ZoneScopeContainers
    }
    #endregion Get Data

    # Display All Collected Data
    $show = Read-Host 'Show all collected DNS data? [Y]/n'
    if (($show -eq 'y') -or ($show -eq '') -or ($null -eq $show) ) {
        if ($Demo) {
            Show-BTCollectedData -Demo @CollectedData
        } elseif ($ShowSecurityDescriptors) {
            Show-BTCollectedData -ShowSecurityDescriptors @CollectedData
        } elseif ($Demo -and $ShowSecurityDescriptors) {
            Show-BTCollectedData -ShowSecurityDescriptors -Demo @CollectedData
        } else {
            Show-BTCollectedData @CollectedData
        }
    }

    # Test Data
    if ($Demo) { Clear-Host }
    Write-Host 'Currently testing collected DNS data to identify possible issues...' -ForegroundColor Green
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] ADI Legacy Zones"
    $TestedADILegacyZones = Test-BTADILegacyZone -ADIZones $ADIZones
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] ADI Insecure Update Zones"
    $TestedADIInsecureUpdateZones = Test-BTADIInsecureUpdateZone -ADIZones $ADIZones
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Dynamic Update Service Accounts"
    $TestedDynamicUpdateServiceAccounts = Test-BTDynamicUpdateServiceAccount -DynamicUpdateServiceAccounts $DynamicUpdateServiceAccounts
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Forwarder Configurations"
    $TestedForwarderConfigurations = Test-BTForwarderConfiguration -ForwarderConfigurations $ForwarderConfigurations
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Global Query Block Lists"
    $TestedGlobalQueryBlockLists = Test-BTGlobalQueryBlockList -GlobalQueryBlockLists $GlobalQueryBlockLists
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Security Descriptor ACE"
    $TestedSecurityDescriptorACEs = Test-BTSecurityDescriptorACE -SecurityDescriptors $SecurityDescriptors -DynamicUpdateServiceAccounts $DynamicUpdateServiceAccounts -Domains $Domains
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Security Descriptor Owner"
    $TestedSecurityDescriptorOwners = Test-BTSecurityDescriptorOwner -SecurityDescriptors $SecurityDescriptors -DynamicUpdateServiceAccounts $DynamicUpdateServiceAccounts -Domains $Domains
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Socket Pool Sizes"
    $TestedSocketPoolSizes = Test-BTSocketPoolSize -SocketPoolSizes $SocketPoolSizes
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Wildcard Records"
    $TestedWildcardRecords = Test-BTWildcardRecord -WildcardRecords $WildcardRecords
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] WPAD Records"
    $TestedWPADRecords = Test-BTWPADRecord -WPADRecords $WPADRecords
    Write-Verbose "[$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')] Zone Scope Containers"
    $TestedZoneScopeContainers = Test-BTZoneScopeContainer -ZoneScopeContainers $ZoneScopeContainers
    Write-Host 'Finished testing collected DNS data to identify possible issues.`n' -ForegroundColor Green

    $TestedData = @{
        'ConditionalForwarders'              = $ConditionalForwarders
        'DanglingSPNs'                       = $DanglingSPNs
        'DnsAdminsMemberships'               = $DnsAdminsMemberships
        'DnsUpdateProxyMemberships'          = $DnsUpdateProxyMemberships
        'NonADIZones'                        = $NonADIZones
        'QueryResolutionPolicys'             = $QueryResolutionPolicys
        'TombstonedNodes'                    = $TombstonedNodes
        'ZoneScopes'                         = $ZoneScopes
        'TestedADILegacyZones'               = $TestedADILegacyZones
        'TestedADIInsecureUpdateZones'       = $TestedADIInsecureUpdateZones
        'TestedDynamicUpdateServiceAccounts' = $TestedDynamicUpdateServiceAccounts
        'TestedForwarderConfigurations'      = $TestedForwarderConfigurations
        'TestedGlobalQueryBlockLists'        = $TestedGlobalQueryBlockLists
        'TestedSecurityDescriptorACEs'       = $TestedSecurityDescriptorACEs
        'TestedSecurityDescriptorOwners'     = $TestedSecurityDescriptorOwners
        'TestedSocketPoolSizes'              = $TestedSocketPoolSizes
        'TestedWildcardRecords'              = $TestedWildcardRecords
        'TestedWPADRecords'                  = $TestedWPADRecords
        'TestedZoneScopeContainers'          = $TestedZoneScopeContainers
    }

    # Display All Tested Data
    $show = Read-Host 'Show possible DNS issues in the environment? [Y]/n'
    if (($show -eq 'y') -or ($show -eq '') -or ($null -eq $show) ) {
        if ($Demo) {
            Show-BTTestedData -Demo @TestedData
        } elseif ($ShowSecurityDescriptors) {
            Show-BTTestedData -ShowSecurityDescriptors @TestedData
        } elseif ($Demo -and $ShowSecurityDescriptors) {
            Show-BTTestedData -ShowSecurityDescriptors -Demo @TestedData
        } else {
            Show-BTTestedData @TestedData
        }
    }

    # Display Fixes
    $show = Read-Host 'Show fixes for identified issues? [Y]/n'
    if (($show -eq 'y') -or ($show -eq '') -or ($null -eq $show) ) {
        if ($Demo) {
            Show-BTFixes -Demo @TestedData
        } elseif ($ShowSecurityDescriptors) {
            Show-BTFixes -ShowSecurityDescriptors @TestedData
        } elseif ($Demo -and $ShowSecurityDescriptors) {
            Show-BTFixes -ShowSecurityDescriptors -Demo @TestedData
        } else {
            Show-BTFixes @TestedData
        }
    }
}
