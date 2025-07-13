function Assert-KeyExists {
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )
  
  if (-not (Test-Path $Path)) {

    Write-Host "Registry path $($Path) not found. Creating it..."
    
    $Item = New-Item -Path $Path -Force

    Write-Verbose ($Item | Format-Table | Out-String)
    
  }

  return [string]$Path

}

function Set-Policy {
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

  # get properties of the policy key
  $PolicyProperties = (Get-ItemProperty $PolicyPath)

  # if the property's value is not already set to the desired value, set it.
  $CurrentValue = $PolicyProperties.$PropertyName

  if ($CurrentValue -eq $DesiredValue) {

    Write-Host "Policy '$($PropertyName)' is already set to '$($DesiredValue)'. No changes will be made."

  }
  else {

    Write-Host "Setting policy '$($PropertyName)' to '$($DesiredValue)' ($($Description))"

    Set-ItemProperty `
      -Path $PolicyPath `
      -Name $PropertyName `
      -Value $DesiredValue

  }

}

# Recommended: HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended
# Enforced: HKLM:\SOFTWARE\Policies\Microsoft\Edge
[string]$EdgeEnforcedPolicies = (Assert-KeyExists -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge')
[string]$EdgeRecommendedPolicies = (Assert-KeyExists -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended')

$EdgePolicies = @(

  # HideFirstRunExperience
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/hidefirstrunexperience
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'HideFirstRunExperience'
    DesiredValue = 1
    Description  = 'Disable the splash screens and preference menu at Edge startup'
  },

  # BackgroundModeEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/backgroundmodeenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'BackgroundModeEnabled'
    DesiredValue = 0
    Description  = 'Do not keep Edge running in the background when all windows are closed'
  },

  # NewTabPageHideDefaultTopSites
  # blocks the sponsored links in the quick links section of the new tab page
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagehidedefaulttopsites
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'NewTabPageHideDefaultTopSites'
    DesiredValue = 1
    Description  = 'Disable the "Promoted Links" section on the new tab page'
  },

  # NewTabPageContentEnabled
  # blocks the MSN content on the new tab page
  # if this is enforced, weather will be blocked, too (this is the only way to block weather)
  # 'recommending' this does not work unless you are signed in with an Azure AD account
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagecontentenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'NewTabPageContentEnabled'
    DesiredValue = 0
    Description  = 'Disable the "Web content" section (MSN) on the new tab page'
  },

  # NewTabPageBingChatEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagebingchatenabled
  @{
    PolicyPath   = $EdgeRecommendedPolicies
    PropertyName = 'NewTabPageBingChatEnabled'
    DesiredValue = 0
    Description  = 'Remove Bing Chat entrypoints from the New Tab page'
  },

  # HubsSidebarEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/hubssidebarenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'HubsSidebarEnabled'
    DesiredValue = 0
    Description  = 'Disable all the Copilot icons and links in the browser'
  },

  # DefaultBrowserSettingEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultbrowsersettingenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'DefaultBrowserSettingEnabled'
    DesiredValue = 0
    Description  = 'Disable the "Make Edge your default browser" prompt'
  },

  # DefaultNotificationsSetting
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultnotificationsetting
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'DefaultNotificationsSetting'
    DesiredValue = 2
    Description  = 'Disable all notifications from Edge'
  },

  # TyposquattingCheckerEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/typosquattingcheckerenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'TyposquattingCheckerEnabled'
    DesiredValue = 1
    Description  = 'Enable the "Typosquatting Checker" feature'
  },

  # NewTabPageQuickLinksEnabled
  # blocks ALL of the "quick links" on the new tab page, including the sponsored links
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagequicklinksenabled
  # @{
  #     PolicyPath = $EdgeEnforcedPolicies
  #     PropertyName = 'NewTabPageQuickLinksEnabled'
  #     DesiredValue = 0
  #     Description = 'Disable the "Quick Links" section on the New Tab page'
  # },

  # ScarewareBlockerProtectionEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/scarewareblockerprotectionenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'ScarewareBlockerProtectionEnabled'
    DesiredValue = 1
    Description  = 'Enable the "Scareware Blocker" feature'
  },

  # ShowDownloadsInsecureWarningsEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/showdownloadsinsecurewarningsenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'ShowDownloadsInsecureWarningsEnabled'
    DesiredValue = 1
    Description  = 'Enable the "Insecure downloads" warning'
  },

  # PaymentMethodQueryEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/paymentmethodqueryenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'PaymentMethodQueryEnabled'
    DesiredValue = 0
    Description  = 'Block sites from querying available payment methods'
  },

  # ShowMicrosoftRewards
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/showmicrosoftrewards
  # @{
  #     PolicyPath = $EdgeEnforcedPolicies
  #     PropertyName = 'ShowMicrosoftRewards'
  #     DesiredValue = 0
  #     Description = 'Disable the Microsoft Rewards program'
  # },

  # ShowRecommendationsEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/showrecommendationsenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'ShowRecommendationsEnabled'
    DesiredValue = 0
    Description  = 'Disable Edge feature recommendation popups'
  },

  # TrackingPrevention
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/trackingprevention
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'TrackingPrevention'
    DesiredValue = 2
    Description  = 'Enable "Balanced" tracking prevention'
  },

  # NewTabPageCompanyLogoEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagecompanylogoenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'NewTabPageCompanyLogoEnabled'
    DesiredValue = 0
    Description  = 'Disable company logo on the new tab page'
  },

  # NewTabPageSearchBox
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagesearchbox
  # this does not work with Bing
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'NewTabPageSearchBox'
    DesiredValue = 'bing'
    Description  = 'Configure the search box on the new tab page ("bing" always uses Bing, "redirect" is janky)'
  }

  # AddressBarTrendingSuggestEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/addressbartrendingsuggestenabled
  # This does not affect the New Tab page search box
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'AddressBarTrendingSuggestEnabled'
    DesiredValue = 0
    Description  = 'Disable "Trending" suggestions in the address bar'
  },

  # DefaultSearchProviderEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultsearchproviderenabled
  # @{
  #     PolicyPath = $EdgeRecommendedPolicies
  #     PropertyName = 'DefaultSearchProviderEnabled'
  #     DesiredValue = 1
  #     Description = 'Enable management of the default Edge search provider'
  # },

  # DefaultSearchProviderSearchURL
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultsearchprovidersearchurl
  # @{
  #     PolicyPath = $EdgeRecommendedPolicies
  #     PropertyName = 'DefaultSearchProviderSearchURL'
  #     DesiredValue = 'https://www.google.com/search?q={searchTerms}'
  #     Description = 'Set default search provider to Google'
  # },

  # EdgeShoppingAssistantEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/edgeshoppingassistantenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'EdgeShoppingAssistantEnabled'
    DesiredValue = 0
    Description  = 'Disable the "Shopping" feature in Edge'
  },

  # EdgeWalletCheckoutEnabled
  # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/edgewalletcheckoutenabled
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'EdgeWalletCheckoutEnabled'
    DesiredValue = 0
    Description  = 'Disable the "Wallet" feature in Edge'
  },
  @{
    PolicyPath   = $EdgeEnforcedPolicies
    PropertyName = 'PasswordManagerEnabled'
    DesiredValue = 0
    Description  = 'Disable the Edge password manager'
  }
)

<#
# ManagedFavorites
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/managedfavorites
Set-Policy `
  -PolicyPath $EdgeEnforcedPolicies `
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
Set-Policy `
  -PolicyPath $EdgeEnforcedPolicies `
  -PropertyName 'HomepageLocation' `
  -DesiredValue 'https://mycompany.sharepoint.com' `
  -Description 'Set the homepage to SharePoint Online'

# NewTabPageLocation
# https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/newtabpagelocation
Set-Policy `
  -PolicyPath $EdgeEnforcedPolicies `
  -PropertyName 'NewTabPageLocation' `
  -DesiredValue 'https://mycompany.sharepoint.com' `
  -Description 'Set the new tab page to SharePoint Online'
#>

foreach ($Policy in $EdgePolicies) {
  Set-Policy @Policy
}

# Recommended: HKLM:\SOFTWARE\Policies\Google\Chrome\Recommended
# Enforced: HKLM:\SOFTWARE\Policies\Googe\Chrome
[string]$ChromeEnforcedPolicies = (Assert-KeyExists -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome')
[string]$ChromeRecommendedPolicies = (Assert-KeyExists -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\Recommended')

$ChromeFeaturePolicies = @(

  # BrowserSignin
  # https://chromeenterprise.google/policies/#BrowserSignin
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'BrowserSignin'
    DesiredValue = 0
    Description  = 'Disable Google accounts in Chrome.'
  },

  # BrowserLabsEnabled
  # https://chromeenterprise.google/policies/#BrowserLabsEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'BrowserLabsEnabled'
    DesiredValue = 0
    Description  = 'Disable Browser Labs link on the toolbar.'
  },

  # DefaultBrowserSettingEnabled
  # https://chromeenterprise.google/policies/#DefaultBrowserSettingEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'DefaultBrowserSettingEnabled'
    DesiredValue = 0
    Description  = 'Do not prompt the user to set Chrome as their default browser.'
  },

  # PasswordManagerEnabled
  # https://chromeenterprise.google/policies/#PasswordManagerEnabled
  # I would only recommend disabling this if you supply your users another password manager.
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'PasswordManagerEnabled'
    DesiredValue = 0
    Description  = 'Disable built-in Chrome password manager'
  },

  # BackgroundModeEnabled
  # https://chromeenterprise.google/policies/#BackgroundModeEnabled
  # reduces memory usage at idle
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'BackgroundModeEnabled'
    DesiredValue = 0
    Description  = 'Prevent Chrome from running after its windows are closed.'
  },

  # ShoppingListEnabled
  # https://chromeenterprise.google/policies/#ShoppingListEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'ShoppingListEnabled'
    DesiredValue = 0
    Description  = 'Disable the price-tracking feature.'
  },

  # BuiltInDnsClientEnabled
  # https://chromeenterprise.google/policies/#BuiltInDnsClientEnabled
  # disables some privacy features; use only if needed
  # @{
  #   PolicyPath   = $ChromeEnforcedPolicies
  #   PropertyName = 'BuiltInDnsClientEnabled'
  #   DesiredValue = 0
  #   Description  = 'Force Chrome to use the system DNS client'
  # }

  # GenAILocalFoundationalModelSettings
  # https://chromeenterprise.google/policies/#GenAILocalFoundationalModelSettings
  # do not download LLMs for local inference
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'GenAILocalFoundationalModelSettings'
    DesiredValue = 1
    Description  = 'Do not download LLMs for local inference'
  },

  # AIModeSettings
  # https://chromeenterprise.google/policies/#AIModeSettings
  # this is the 'AI mode' tab, I believe.
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'AIModeSettings'
    DesiredValue = 1
    Description  = 'Disable AI mode in Chrome'
  },

  # GeminiSettings
  # https://chromeenterprise.google/policies/#GeminiSettings
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'GeminiSettings'
    DesiredValue = 1
    Description  = 'Disable Gemini integration in Chrome'
  },

  # AutofillPredictionSettings
  # https://chromeenterprise.google/policies/#AutofillPredictionSettings
  # set this to 1 if you'd like to enable but disable data collection
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'AutofillPredictionSettings'
    DesiredValue = 2
    Description  = 'Disable GenAI autofill (and data collection) in Chrome'
  },

  # HelpMeWriteSettings
  # https://chromeenterprise.google/policies/#HelpMeWriteSettings
  # set this to 1 if you'd like to enable but disable data collection
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'HelpMeWriteSettings'
    DesiredValue = 2
    Description  = 'Disable GenAI short-form autofill (and data collection) in Chrome'
  },

  # HistorySearchSettings
  # https://chromeenterprise.google/policies/#HistorySearchSettings
  # set this to 1 if you'd like to enable but disable data collection
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'HistorySearchSettings'
    DesiredValue = 2
    Description  = 'Disable GenAI history search (and data collection) in Chrome'
  },

  # TabCompareSettings
  # https://chromeenterprise.google/policies/#TabCompareSettings
  # set this to 1 if you'd like to enable but disable data collection
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'TabCompareSettings'
    DesiredValue = 2
    Description  = 'Disable GenAI tab comparison (and data collection) in Chrome'
  }

  # if you want to restrict extensions, define a 'block all',
  # then configure the ones you'd like to allow:

  # ExtensionInstallAllowlist
  # https://chromeenterprise.google/policies/#ExtensionInstallAllowlist
  # @{
  #   PolicyPath   = $ChromeEnforcedPolicies
  #   PropertyName = 'ExtensionInstallAllowlist\1'
  #   DesiredValue = 'ddkjiahejlhfcafbddmgiahcphecmpfh'
  #   Description  = 'Allow Chrome to use uBlock Origin Lite'
  # }

  # ExtensionInstallBlocklist
  # https://chromeenterprise.google/policies/#ExtensionInstallBlocklist
  # @{
  #   PolicyPath   = $ChromeEnforcedPolicies
  #   PropertyName = 'ExtensionInstallBlocklist\1'
  #   DesiredValue = '*'
  #   Description  = 'Block installation of all extensions by default'
  # }

)

$ChromeSecurityPolicies = @(

  # SitePerProcess
  # https://chromeenterprise.google/policies/#SitePerProcess
  # enforce the default site isolation settings
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SitePerProcess'
    DesiredValue = 1
    Description  = 'Enforce the default Chrome site isolation settings.'
  },

  # BlockThirdPartyCookies
  # https://chromeenterprise.google/policies/#BlockThirdPartyCookies
  # prevent 'alien' web elements from setting cookies for a page
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'BlockThirdPartyCookies'
    DesiredValue = 1
    Description  = 'Block third-party cookies by default.'
  },

  # HttpsUpgradesEnabled
  # https://chromeenterprise.google/policies/#HttpsUpgradesEnabled
  # enforce HTTPS upgrades (do not allow users to disable automatic upgrades from HTTP)
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'HttpsUpgradesEnabled'
    DesiredValue = 1
    Description  = 'Enforce automatic HTTPS upgrades.'
  },

  # SavingBrowserHistoryDisabled
  # https://chromeenterprise.google/policies/#SavingBrowserHistoryDisabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SavingBrowserHistoryDisabled'
    DesiredValue = 0
    Description  = 'Do not allow the user to disable browser history.'
  },

  # CACertificateManagementAllowed
  # https://chromeenterprise.google/policies/#CACertificateManagementAllowed
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'CACertificateManagementAllowed'
    DesiredValue = 2
    Description  = 'Do not allow users to manage CA certificates.'
  },

  # AuthSchemes
  # https://chromeenterprise.google/policies/#AuthSchemes
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'AuthSchemes'
    DesiredValue = 'ntlm,negotiate'
    Description  = 'Disable legacy HTTP authentication protocols.'
  }

)

$ChromeSafeBrowsingPolicies = @(

  # DisableSafeBrowsingProceedAnyway
  # https://chromeenterprise.google/policies/#DisableSafeBrowsingProceedAnyway
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'DisableSafeBrowsingProceedAnyway'
    DesiredValue = 1
    Description  = 'Do not allow the user to proceed to sites detected as phishing or malware.'
  },

  # SafeBrowsingDeepScanningEnabled
  # https://chromeenterprise.google/policies/#SafeBrowsingDeepScanningEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SafeBrowsingDeepScanningEnabled'
    DesiredValue = 1
    Description  = 'Enforce scanning the contents of suspicious downloads.'
  },

  # SafeBrowsingExtendedReportingEnabled
  # https://chromeenterprise.google/policies/#SafeBrowsingExtendedReportingEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SafeBrowsingExtendedReportingEnabled'
    DesiredValue = 1
    Description  = 'Send additional information to Google Safe Browsing service.'
  }

  # SafeBrowsingProtectionLevel
  # https://chromeenterprise.google/policies/#SafeBrowsingProtectionLevel
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SafeBrowsingProtectionLevel'
    DesiredValue = 2
    Description  = 'Set Safe Browsing to its Enhanced Protection mode.'
  }

  # SafeBrowsingProxiedRealTimeChecksAllowed
  # https://chromeenterprise.google/policies/#SafeBrowsingProxiedRealTimeChecksAllowed
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SafeBrowsingProxiedRealTimeChecksAllowed'
    DesiredValue = 1
    Description  = 'Enable proxied real-time URL security checks.'
  }

  # SafeBrowsingSurveysEnabled
  # https://chromeenterprise.google/policies/#SafeBrowsingSurveysEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'SafeBrowsingSurveysEnabled'
    DesiredValue = 0
    Description  = 'Do not show Google surveys about Safe Browsing.'
  }

)

$ChromePrivacySandboxPolicies = @(
  
  # PrivacySandboxAdMeasurementEnabled
  # https://chromeenterprise.google/policies/#PrivacySandboxAdMeasurementEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'PrivacySandboxAdMeasurementEnabled'
    DesiredValue = 0
    Description  = 'Disable the "private" ad performance measurement service.'
  }

  # PrivacySandboxAdTopicsEnabled
  # https://chromeenterprise.google/policies/#PrivacySandboxAdTopicsEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'PrivacySandboxAdTopicsEnabled'
    DesiredValue = 0
    Description  = 'Disable the "private" user profiling service.'
  }

  # PrivacySandboxIpProtectionEnabled
  # https://chromeenterprise.google/policies/#PrivacySandboxIpProtectionEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'PrivacySandboxIpProtectionEnabled'
    DesiredValue = 1
    Description  = 'Proxy some traffic to suspicious sites through Google.'
  }

  # PrivacySandboxPromptEnabled
  # https://chromeenterprise.google/policies/#PrivacySandboxPromptEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'PrivacySandboxPromptEnabled'
    DesiredValue = 0
    Description  = 'Do not show the Privacy Sandbox prompt to users.'
  }

  # PrivacySandboxSiteEnabledAdsEnabled
  # https://chromeenterprise.google/policies/#PrivacySandboxSiteEnabledAdsEnabled
  @{
    PolicyPath   = $ChromeEnforcedPolicies
    PropertyName = 'PrivacySandboxSiteEnabledAdsEnabled'
    DesiredValue = 0
    Description  = 'Do not show "privately profiled" site-suggested ads to users.'
  }
  
)

$ChromePolicies = $($ChromeFeaturePolicies; $ChromeSecurityPolicies; $ChromeSafeBrowsingPolicies; $ChromePrivacySandboxPolicies)

foreach ($Policy in $ChromePolicies) {
  Set-Policy @Policy
}

Write-Host 'Done.'
