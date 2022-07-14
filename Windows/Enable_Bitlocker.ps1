### This program needs to be run with administrative privileges, in order to execute correctly! ###
### This program has been tested and found working on Windows 10 (version 21H2), other distributions of Windows (7, 10, 11 and their various )  Further testing requiered! ###
### This program checks if Bitlocker is enabled on the Windows OS, and if not, enables it. ###
### The command Out-Host was added as a workaround for known issues with the Transcript command, which sometimes fails to obtain all STDOUT outputs. ###
### According to the following Microsoft article, encryption of a new SSD drive might take more than 20 minutes. Therefor I set the offset to 1 hour. ###
### https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bitlocker-device-encryption-overview-windows-10 ###


Start-Transcript -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
$ErrorActionPreference = "Continue"
$success = "False"
$recoveryKey = ""


# Check if a TPM exists, if not, exit the program.
$check_tpm = (Get-Tpm).tpmpresent | Out-Host
if ($check_tpm -eq $false | Out-Host)
    {
    Write-Output "Computer has no TPM! Cannot turn Bitlocker on. Exiting..."
    Stop-Transcript
    $stdout = Get-Content -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Write-Output "{       'success': $success,
    'recoveryKey': $recoveryKey,
    'stdout': $stdout,
    'stderr': $Error }"
    Remove-Item -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Exit 3
    }
     
# Check if Bitlocker is enabled, if it is, exit the program.
$bitlocker_check = Get-BitlockerVolume -MountPoint $ENV:SystemDrive | Out-Host
if ($bitlocker_check.volumestatus -like "FullyEncrypted" | Out-Host) 
    {
    Write-Output "Bitlocker already enabled, nothing to do. Exiting..."
    Stop-Transcript
    $stdout = Get-Content -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Write-Output "{       'success': $success,
    'recoveryKey': $recoveryKey,
    'stdout': $stdout,
    'stderr': $Error }"
    Remove-Item -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Exit 3
    }
    
# If Bitlocker is not enabled, enable it.
else 
    {
    # The recovery key must be saved somewhere, it can be saved to a local disk, USB disk, a remote share and so on...
    # In order to save the key on a network drive, we will first need to map the drive with the following command: 
    # New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\Server01\Public"
    # Another option would be to save it on a cloud storage, like AWS S3 Bucket.
    Get-BitLockerVolume -MountPoint $ENV:SystemDrive | Enable-BitLocker -UsedSpaceOnly -RecoveryKeyPath "E:\" -RecoveryKeyProtector -ErrorAction Continue | Out-Host
    } 

# Check if the encryption process has started.
$bitlocker_check = Get-BitlockerVolume -MountPoint $ENV:SystemDrive | Out-Host
if ($bitlocker_check.volumestatus -like "EncryptionInProgress" | Out-Host)
    {
    # Check if the encryption process has finished, offset has been set to 1 hour.
    $timer = new-timespan -Hours 1
    $clock = [diagnostics.stopwatch]::StartNew()
    while ($clock.elapsed -lt $timer)
        {
        $bitlocker_check = Get-BitlockerVolume -MountPoint $ENV:SystemDrive | Out-Host
        if ($bitlocker_check.volumestatus -Notlike "EncryptionInProgress" | Out-Host)
            {
            break
            }
        start-sleep -Seconds 60
        }
    }

# If the encryption process has not started, exit the program.
else
    {
    Write-Output "Bitlocker encryption could not start. Exiting..."
    Stop-Transcript
    $stdout = Get-Content -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Write-Output "{       'success': $success,
    'recoveryKey': $recoveryKey,
    'stdout': $stdout,
    'stderr': $Error }"
    Remove-Item -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Exit 3
    }

# If the encryption process has failed to complete, due to any reason, exit the program.
if ($bitlocker_check.volumestatus -like "FullyDecrypted" | Out-Host)
    {
    Write-Output "Bitlocker encryption has failed due to an error. Exiting..."
    Stop-Transcript
    $stdout = Get-Content -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Write-Output "{       'success': $success,
    'recoveryKey': $recoveryKey,
    'stdout': $stdout,
    'stderr': $Error }"
    Remove-Item -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Exit 3
    }
    
# Once the encryption process is finished, get the Bitlocker recovery key and put it into a variable.
elseif ($bitlocker_check.volumestatus -like "FullyEncrypted" | Out-Host)
    {
    $success = "True"
    $recoveryKey = [string]($bitlocker_check).KeyProtector.recoverypassword | Out-Host
    Write-Output "Bitlocker encryption has been enabled successfully!"
    Stop-Transcript
    $stdout = Get-Content -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Write-Output "{       'success': $success,
    'recoveryKey': $recoveryKey,
    'stdout': $stdout,
    'stderr': $Error }"
    Remove-Item -Path $ENV:HOMEPATH\Enable_Bitlocker_Output.txt
    Exit 0
    }    
