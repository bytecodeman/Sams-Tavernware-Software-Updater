<#
  Sample commandline:
  .\UpdateSoftware.ps1 -checkOnly -source \\localhost\c$\testsource -dest C:\testdest\

  Works on:
  Major  Minor  Build  Revision
  -----  -----  -----  --------
  5      1      17134  407 
#>

param (
    [switch]$checkOnly = $false,
    [Parameter(Mandatory=$true)][string]$source,
    [Parameter(Mandatory=$true)][string]$dest
 )

function isDifferent($source, $dest) {
  $output = robocopy $source $dest /l /mir
  $output = $output -join "`r`n"
  #$regex = "\s+\d+\s+" + [RegEx]::Escape($source) + "\\[^`r`n]*`r`n(([^`r`n\\]+`r`n)+)"
  $regex = "\s+\d+\s+" + [RegEx]::Escape($source) + "\\?`r`n`r`n"
  -not ($output -match $regex) 
}

Add-Type -AssemblyName PresentationFramework

$software = "Tavernware"
$updatePrgmName = "$software Updater"


$message = "", "INFO"
if (isDifferent -source $source -dest $dest) {
   if ($checkOnly) {
      $message = "$software needs updating!!!", "INFO"
    }
    else {
      # First Kill Software
      Stop-Process -name $software -Force -PassThru -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue

      # Then Update Software
      robocopy $source $dest /mir | Out-Null
      if ($LASTEXITCODE -le 7) {
        $message = "$software has been successfully updated`r`nPlease to enjoy!", "INFO"
        }
      else {
        $message = "Error No: $LASTEXITCODE occurred in updating $software`r`nContact Software Developer!", "ERROR"
    }
   }
}
elseif (-not $checkOnly) {
      $message = "You are enjoying the latest version of $software.`r`nNo need for an update", "INFO"
   }

if ($message[0] -ne "") {
   [System.Windows.MessageBox]::Show($message[0], $updatePrgmName, "Ok", $message[1]) | Out-Null
}

