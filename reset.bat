@echo off
setlocal EnableDelayedExpansion

echo Minecraftサーバーをリセットしています...

rem 既存のDocker Composeコンテナを停止
docker-compose down
if %errorlevel% neq 0 (
    echo エラー：Dockerコンテナの停止に失敗しました。
    goto :error
)

rem 日付時刻の取得（YYYYMMDDHHMMSSフォーマット）
for /f "tokens=2 delims==." %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,14%"

rem dataフォルダが存在する場合はリネーム
if exist data (
    echo 既存のdataフォルダをバックアップ中...
    rename data data_backup_%timestamp%
    if !errorlevel! neq 0 (
        echo エラー：dataフォルダのリネームに失敗しました。
        goto :error
    )
)

rem 新しいdataフォルダを作成
mkdir data
if !errorlevel! neq 0 (
    echo エラー：新しいdataフォルダの作成に失敗しました。
    goto :error
)
echo 新しいdataフォルダを作成しました。

rem バックアップを3件に制限（古いものから削除）
set "count=0"
for /f "tokens=*" %%a in ('dir /b /ad /o:-d data_backup_* 2^>nul') do (
    set /a "count+=1"
    if !count! gtr 3 (
        echo 古いバックアップを削除中: %%a
        rmdir /s /q "%%a"
        if !errorlevel! neq 0 echo 警告：バックアップの削除に失敗しました: %%a
    )
)

rem サーバーを起動
echo サーバーを起動中...
call start.bat
goto :end

:error
echo 処理中にエラーが発生しました。
exit /b 1

:end
endlocal
exit /b 0