@echo off
setlocal
set MWCDM_Path=%userprofile%\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy
set MWCDM_Settings=%MWCDM_Path%\Settings
set MWCDM_LSAssets=%MWCDM_Path%\LocalState\Assets


pushd %MWCDM_Settings%
    echo List files in %cd%
    for %%f in (%cd%\*.*) do echo %%f
    echo will remove all files in %MWCDM_Settings%
    del "%cd%\*.*" /f /q
    echo Done!
popd
pushd %MWCDM_LSAssets%
    echo List files in %cd%
    for %%f in (%cd%\*.*) do echo %%f
    echo will remove all files in %MWCDM_LSAssets%
    del "%cd%\*.*" /f /q
    echo Done!
popd
@REM PAUSE