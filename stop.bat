@echo off
setlocal

rem サーバーが既に停止しているかチェック
echo サーバーの状態を確認しています...
docker-compose ps | findstr "Up" | findstr "mc" > nul
if %errorlevel% neq 0 (
    echo;
    echo Minecraftサーバーは既に停止しています。
    echo;
    exit /b 0
)

echo Minecraftサーバーを停止しています...
docker-compose down
if %errorlevel% neq 0 (
    echo エラー：Dockerコンテナの停止に失敗しました。
    goto :error
)

echo;
echo Minecraftサーバーが正常に停止しました。
echo;
goto :end

:error
echo;
echo 処理中にエラーが発生しました。
echo;
exit /b 1

:end
endlocal
exit /b 0