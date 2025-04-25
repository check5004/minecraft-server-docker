@echo off
setlocal EnableDelayedExpansion

echo Minecraft�T�[�o�[�����Z�b�g���Ă��܂�...

rem ������Docker Compose�R���e�i���~
docker-compose down
if %errorlevel% neq 0 (
    echo �G���[�FDocker�R���e�i�̒�~�Ɏ��s���܂����B
    goto :error
)

rem ���t�����̎擾�iYYYYMMDDHHMMSS�t�H�[�}�b�g�j
for /f "tokens=2 delims==." %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,14%"

rem data�t�H���_�����݂���ꍇ�̓��l�[��
if exist data (
    echo ������data�t�H���_���o�b�N�A�b�v��...
    rename data data_backup_%timestamp%
    if !errorlevel! neq 0 (
        echo �G���[�Fdata�t�H���_�̃��l�[���Ɏ��s���܂����B
        goto :error
    )
)

rem �V����data�t�H���_���쐬
mkdir data
if !errorlevel! neq 0 (
    echo �G���[�F�V����data�t�H���_�̍쐬�Ɏ��s���܂����B
    goto :error
)
echo �V����data�t�H���_���쐬���܂����B

rem �o�b�N�A�b�v��3���ɐ����i�Â����̂���폜�j
set "count=0"
for /f "tokens=*" %%a in ('dir /b /ad /o:-d data_backup_* 2^>nul') do (
    set /a "count+=1"
    if !count! gtr 3 (
        echo �Â��o�b�N�A�b�v���폜��: %%a
        rmdir /s /q "%%a"
        if !errorlevel! neq 0 echo �x���F�o�b�N�A�b�v�̍폜�Ɏ��s���܂���: %%a
    )
)

rem �T�[�o�[���N��
echo �T�[�o�[���N����...
call start.bat
goto :end

:error
echo �������ɃG���[���������܂����B
exit /b 1

:end
endlocal
exit /b 0