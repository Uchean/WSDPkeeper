![License](https://img.shields.io/github/license/zhurui1008/WSDPkeeper)


# WSDPkeeper (Windows Spotlight Daily Photo keeper)

PowerShell script and batch script for saving photos updated by Windows Spotlight.

Includes:

- WSDPkeeper.ps1
  
- WSDPkeeper.bat
  
- WSDPhotoUpdate.bat

# Features

- [x] Differentiating new photos in horizontal and vertical during processing, and then storing them separately

- [x] Repetition checking. (Only pulling new items)

- [x] Rename photos with format `{H|V}_WSDPhoto_{YYYY-MM-DD-hh-mm}_{nnnn}.jpg`

# Usages
## Executing directly
Download the zip file and extract the scripts where you like. (I put them in `C:\Users\{username}\Pictures`)

Then, execute the batch script `WSDPkeeper.bat` or the PowerShell script `WSDPkeeper.ps1` in PowerShell (Do need to set PowerShell [Set-ExecutionPolicy]("https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6") *-ExecutionPolicy* **RemoteSigned**).

The default keeping folders located in:

```
C:\Users\{username}\Saved Pictures\Horizontal <--for photos H_*.jpg
C:\Users\{username}\Saved Pictures\Vertical   <--for photos V_*.jpg
```

The batch script include multi lines for executing PowerShell script optionally. You can comment the default line and select the suitable one.

## By using Windows Task Scheduler

Go the task properties --> Action tab --> Edit --> Fill up as below:

1. Action: Start a program
2. Program/script: path to your batch script e.g. `C:\Users\{username}\WSDPkeeper.bat`
3. Add arguments (optional): \<if necessary - depending on your script\>
4. Start in (optional): Put the full path to your batch script location e.g. `C:\Users\{username}\` (Do not put quotes around Start In)

Then Click OK

It works fine for me. Good Luck!
