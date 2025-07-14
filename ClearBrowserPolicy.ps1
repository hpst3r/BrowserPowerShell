param (
  [switch]$Chrome,
  [switch]$Edge,
  [switch]$Firefox
)

function Clear-Policy {
  param (
    [string]$PolicyPath
  )

  # clear Edge policy settings by deleting the appropriate registry keys
  if (Test-Path $PolicyPath 2> $null) {
    
    Remove-Item `
      -Force `
      -Recurse `
      -Path $PolicyPath

  } else {
    Write-Warning `
      "Key $($PolicyPath) does not exist! I've got nothing to clear. No changes were made."
  }

}

$PolicyPaths = @{
  Chrome  = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
  Edge    = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
  Firefox = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox'
}

$SelectedBrowsers = @()
if ($Chrome)  { $SelectedBrowsers += 'Chrome' }
if ($Edge)    { $SelectedBrowsers += 'Edge' }
if ($Firefox) { $SelectedBrowsers += 'Firefox' }

foreach ($Browser in $SelectedBrowsers) {
  Clear-Policy -PolicyPath $PolicyPaths[$Browser]
}
