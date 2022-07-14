Windows

Check if Bitlocker is enabled, If not, then activate Bitlocker (see reference #1). The output of the script needs to be a json string containing these fields:
success - Indicates whether Bitlocker was turned on or not.
recoveryKey - The bitlocker recovery key that was used to encrypt the drive (if encryption started successfully) -see reference #2.
stdout - Stdout of the script.
stderr - Stderr of the script.
If the script successfully turns on Bitlocker then it should exit with an exit code 0.
If the script finish without enabling Bitlocker, the success field should be set to false, the recovery key field will be empty and the script should exit with an exit code of 3.
  Output must be consistent.
  
Linux

1.	Write a program that takes a command line argument for a directory path, the output will be the system mount point path for the given directory.
2.	Write a program that take a command line argument for directory path and remove execution privileges from all users for all files in that directory and subdirectories (without changing directories permissions).

References
 
1.	Enable-Bitlocker - [link](https://docs.microsoft.com/en-us/powershell/module/bitlocker/enable-bitlocker?view=windowsserver2022-ps)
2.	Get Bitlocker’s recovery key - [link](https://docs.microsoft.com/en-us/powershell/module/bitlocker/get-bitlockervolume?view=windowsserver2022-ps)
