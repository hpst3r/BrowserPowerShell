function Assert-PolicyKeyExists {
  param (
    [Parameter(Mandatory)]
    [string]$PolicyPath
  )

  $ParentPath = Split-Path -Path $PolicyPath -Parent
  
  if ((Split-Path -Path $ParentPath -Leaf) -eq 'Edge' -and -not (Test-Path $ParentPath)) {

    Write-Host "Parent registry path $($ParentPath) not found. Creating it..."

    New-Item -Path $ParentPath | Out-Null

  }

  if (-not (Test-Path $PolicyPath)) {

    Write-Host "Registry path $($PolicyPath) not found. Creating it..."
    
    New-Item -Path $PolicyPath | Out-Null
    
  }

  return [string]$PolicyPath

}

function Set-EdgePolicy {
  param (
    [Parameter(Mandatory)]
    [string]$PolicyPath
    ,
    [Parameter(Mandatory)]
    [string]$PropertyName
    ,
    [Parameter(Mandatory)]
    $DesiredValue
    ,
    [Parameter(Mandatory)]
    [string]$Description
  )

  # get properties of the Edge policy key
  $EdgeProps = (Get-ItemProperty $PolicyPath)

  # if the property's value is not already set to the desired value, set it.
  $CurrentValue = $EdgeProps.$PropertyName
  if ($CurrentValue -eq $DesiredValue) {

    Write-Host "Edge policy '$($PropertyName)' is already set to '$($DesiredValue)'. No changes will be made."

  } else {

    Write-Host "Setting Edge policy '$($PropertyName)' to '$($DesiredValue)' ($($Description))"

    Set-ItemProperty `
      -Path $PolicyPath `
      -Name $PropertyName `
      -Value $DesiredValue

  }

}

# Recommended: HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended
# Enforced: HKLM:\SOFTWARE\Policies\Microsoft\Edge
[string]$EnforcedPolicies = (Assert-PolicyKeyExists -PolicyPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge')
[string]$RecommendedPolicies = (Assert-PolicyKeyExists -PolicyPath 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended')

# HideFirstRunExperience
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/hidefirstrunexperience
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'HideFirstRunExperience' `
  -DesiredValue 1 `
  -Description 'Disable the splash screens and preference menu at Edge startup'

# BackgroundModeEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/backgroundmodeenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'BackgroundModeEnabled' `
  -DesiredValue 0 `
  -Description 'Do not keep Edge running in the background when all windows are closed'

# NewTabPageHideDefaultTopSites
# blocks the sponsored links in the quick links section of the new tab page
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagehidedefaulttopsites
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'NewTabPageHideDefaultTopSites' `
  -DesiredValue 1 `
  -Description 'Disable the "Promoted Links" section on the new tab page'

# NewTabPageContentEnabled
# blocks the MSN content on the new tab page
# if this is enforced, weather will be blocked, too (this is the only way to block weather)
# 'recommending' this does not work unless you are signed in with an Azure AD account
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagecontentenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'NewTabPageContentEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the "Web content" section (MSN) on the new tab page'

# NewTabPageBingChatEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagebingchatenabled
Set-EdgePolicy `
  -PolicyPath $RecommendedPolicies `
  -PropertyName 'NewTabPageBingChatEnabled' `
  -DesiredValue 0 `
  -Description 'Remove Bing Chat entrypoints from the New Tab page'

# HubsSidebarEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/hubssidebarenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'HubsSidebarEnabled' `
  -DesiredValue 0 `
  -Description 'Disable all the Copilot icons and links in the browser - this name is confusing'

# DefaultBrowserSettingEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultbrowsersettingenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'DefaultBrowserSettingEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the "Make Edge your default browser" prompt'

# DefaultNotificationsSetting
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultnotificationsetting
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'DefaultNotificationsSetting' `
  -DesiredValue 2 `
  -Description 'Disable all notifications from Edge'

# TyposquattingCheckerEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/typosquattingcheckerenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'TyposquattingCheckerEnabled' `
  -DesiredValue 1 `
  -Description 'Enable the "Typosquatting Checker" feature - provides warning messages when a user tries to visit a site with a domain name that is similar to a well-known site'

# NewTabPageQuickLinksEnabled
# blocks ALL of the "quick links" on the new tab page, including the sponsored links
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagequicklinksenabled
#Set-EdgePolicy `
#  -PolicyPath $EdgePolicies `
#  -PropertyName 'NewTabPageQuickLinksEnabled' `
#  -DesiredValue 0 `
#  -Description 'Disable the "Quick Links" section on the New Tab page - primarily going after the Sponsored Links section'

# ScarewareBlockerProtectionEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/scarewareblockerprotectionenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'ScarewareBlockerProtectionEnabled' `
  -DesiredValue 1 `
  -Description 'Enable the "Scareware Blocker" feature - tries to block fake tech scams'

# ShowDownloadsInsecureWarningsEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/showdownloadsinsecurewarningsenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'ShowDownloadsInsecureWarningsEnabled' `
  -DesiredValue 1 `
  -Description 'Enable the "Insecure downloads" warning'

# PaymentMethodQueryEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/paymentmethodqueryenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'PaymentMethodQueryEnabled' `
  -DesiredValue 0 `
  -Description 'Allow websites to query for available payment methods'

# ShowMicrosoftRewards
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/showmicrosoftrewards
#Set-EdgePolicy `
#  -PolicyPath $EnforcedPolicies `
#  -PropertyName 'ShowMicrosoftRewards' `
#  -DesiredValue 0 `
#  -Description 'Disable the Microsoft Rewards program'

# ShowRecommendationsEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/showrecommendationsenabled
Set-EdgePolicy `
  -PolicyPath $RecommendedPolicies `
  -PropertyName 'ShowRecommendationsEnabled' `
  -DesiredValue 0 `
  -Description 'Disable Edge feature recommendation popups'

# TrackingPrevention
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/trackingprevention
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'TrackingPrevention' `
  -DesiredValue 2 `
  -Description 'Enable the "Balanced" tracking prevention setting'

# NewTabPageCompanyLogoEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagecompanylogoenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'NewTabPageCompanyLogoEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the company logo on the new tab page'

# NewTabPageSearchBox
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagesearchbox
# this does not work with Bing
#Set-EdgePolicy `
#  -PolicyPath $EnforcedPolicies `
#  -PropertyName 'NewTabPageSearchBox' `
#  -DesiredValue 'bing' `
#  -Description 'Configure the search box on the new tab page ("bing" always uses Bing, "redirect" is janky)'

# AddressBarTrendingSuggestEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/addressbartrendingsuggestenabled
# This does not affect the New Tab page search box
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'AddressBarTrendingSuggestEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the "Trending" suggestions in the new tab address bar'

# DefaultSearchProviderEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultsearchproviderenabled
#Set-EdgePolicy `
#  -PolicyPath $RecommendedPolicies `
#  -PropertyName 'DefaultSearchProviderEnabled' `
#  -DesiredValue 1 `
#  -Description 'Enable management of the default Edge search provider'

# DefaultSearchProviderSearchURL
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultsearchprovidersearchurl
#Set-EdgePolicy `
#  -PolicyPath $RecommendedPolicies `
#  -PropertyName 'DefaultSearchProviderSearchURL' `
#  -DesiredValue '{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}ie={inputEncoding}' `
#  -Description 'Set the default search provider to Google'

# EdgeShoppingAssistantEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/edgeshoppingassistantenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'EdgeShoppingAssistantEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the "Shopping" feature in Edge'

# EdgeWalletCheckoutEnabled
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/edgewalletcheckoutenabled
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'EdgeWalletCheckoutEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the "Wallet" feature in Edge'

Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'PasswordManagerEnabled' `
  -DesiredValue 0 `
  -Description 'Disable the Edge password manager'

<#
# ManagedFavorites
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/managedfavorites
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'ManagedFavorites' `
  -DesiredValue '[
    {
      "toplevel_name": "Custom Bookmark Example"
    },
    {
      "name": "SharePoint Hub",
      "url": "https://sharepoint.com"
    },
    {
      "name": "Bing",
      "url": "https://www.bing.com"
    },
    {
      "name": "Matrix",
      "url": "www.matrix.org"
    }
    ]' `
  -Description 'Add custom bookmarks to the favorites bar'

# HomepageLocation
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/homelocation
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'HomepageLocation' `
  -DesiredValue 'https://mycompany.sharepoint.com' `
  -Description 'Set the homepage to SharePoint Online'

# NewTabPageLocation
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagelocation
Set-EdgePolicy `
  -PolicyPath $EnforcedPolicies `
  -PropertyName 'NewTabPageLocation' `
  -DesiredValue 'https://mycompany.sharepoint.com' `
  -Description 'Set the new tab page to SharePoint Online'
#>

Write-Host 'Done.'