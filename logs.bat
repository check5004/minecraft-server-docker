@echo off
setlocal

echo Minecraftサーバーのログを表示しています...
echo （終了するには Ctrl+C を押してください）
echo;

docker-compose logs -f mc

endlocal
exit /b 0