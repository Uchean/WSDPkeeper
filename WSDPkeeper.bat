@echo off
setlocal
set workingPath=%userprofile%\Pictures
set localPath=%cd%
pushd %workingPath%
    @REM powershell -ExecutionPolicy RemoteSigned -File %localPath%\WSDPkeeper.ps1
    powershell -ExecutionPolicy RemoteSigned -File %localPath%\WSDPkeeper.ps1 2>&1 >> %localPath%\WSDPkeeper.log
    @REM start powershell -ExecutionPolicy RemoteSigned -File %localPath%\WSDPkeeper.ps1
    @REM start /wait powershell -ExecutionPolicy RemoteSigned -File %localPath%\WSDPkeeper.ps1
popd