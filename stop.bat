@echo off
setlocal

rem �T�[�o�[�����ɒ�~���Ă��邩�`�F�b�N
echo �T�[�o�[�̏�Ԃ��m�F���Ă��܂�...
docker-compose ps | findstr "Up" | findstr "mc" > nul
if %errorlevel% neq 0 (
    echo;
    echo Minecraft�T�[�o�[�͊��ɒ�~���Ă��܂��B
    echo;
    exit /b 0
)

echo Minecraft�T�[�o�[���~���Ă��܂�...
docker-compose down
if %errorlevel% neq 0 (
    echo �G���[�FDocker�R���e�i�̒�~�Ɏ��s���܂����B
    goto :error
)

echo;
echo Minecraft�T�[�o�[������ɒ�~���܂����B
echo;
goto :end

:error
echo;
echo �������ɃG���[���������܂����B
echo;
exit /b 1

:end
endlocal
exit /b 0