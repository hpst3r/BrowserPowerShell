function Clear-EdgePolicy {
  $PolicyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'

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

Clear-EdgePolicy