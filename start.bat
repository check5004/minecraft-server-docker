@echo off
setlocal

rem サーバーが既に起動しているかチェック
echo サーバーの状態を確認しています...
docker-compose ps | findstr "Up" | findstr "mc" > nul
if %errorlevel% equ 0 (
    echo;
    echo Minecraftサーバーは既に起動しています。
    echo;
    exit /b 0
)

echo Dockerコンテナを起動しています...
docker-compose up -d
if %errorlevel% neq 0 (
    echo;
    echo エラー：Dockerコンテナの起動に失敗しました。
    echo;
    goto :error
)

echo Minecraftサーバーの起動を待機しています...

rem ログを監視するループ
set "timeout_count=0"
set "previous_log_lines=0"
set "total_lines_displayed=0"
:check_startup
timeout /t 2 /nobreak > nul
set /a "timeout_count+=1"
if %timeout_count% gtr 150 (
    echo;
    echo タイムアウト：サーバーの起動に5分以上かかっています。手動で確認してください。
    echo;
    goto :end
)

rem ログを一時ファイルに保存（より多くの行を取得）
set "temp_log_file=%TEMP%\mc_log_temp_%RANDOM%.txt"
docker-compose logs --tail=200 mc > "%temp_log_file%"

rem ログ行数を取得
for /f %%i in ('type "%temp_log_file%" ^| find /c /v ""') do set log_lines=%%i

rem 新しいログ部分だけを表示
if %log_lines% gtr %previous_log_lines% (
    rem 前回表示した以降の新しい行だけを表示
    set /a "lines_to_skip=%previous_log_lines%"
    set /a "new_lines=%log_lines% - %lines_to_skip%"

    rem すべての新しい行を表示
    setlocal enabledelayedexpansion
    set "line_num=0"
    for /f "tokens=*" %%a in ('type "%temp_log_file%"') do (
        set /a "line_num+=1"
        if !line_num! gtr !lines_to_skip! echo %%a
    )
    endlocal

    rem 今回のログ行数を保存
    set "previous_log_lines=%log_lines%"
)

rem "Done (...)"パターンをチェック
findstr /i "Done (.*)" "%temp_log_file%" > nul
if %errorlevel% equ 0 (
    del "%temp_log_file%" 2>nul
    goto :startup_complete
)

rem "Done"と"help"を含む行を検索（起動完了の典型的なパターン）
findstr /i "Done.*help" "%temp_log_file%" > nul
if %errorlevel% equ 0 (
    del "%temp_log_file%" 2>nul
    goto :startup_complete
)

rem 一時ファイルを削除
del "%temp_log_file%" 2>nul

goto check_startup

:startup_complete
echo;
echo Minecraftサーバーの起動が完了しました！
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