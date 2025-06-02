function Clear-EdgePolicy {
  # clear Edge policy settings by force deleting the appropriate registry keys
  Remove-Item `
    -Force `
    -Recurse `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
}

Clear-EdgePolicy