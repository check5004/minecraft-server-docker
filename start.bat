@echo off
setlocal

rem �T�[�o�[�����ɋN�����Ă��邩�`�F�b�N
echo �T�[�o�[�̏�Ԃ��m�F���Ă��܂�...
docker-compose ps | findstr "Up" | findstr "mc" > nul
if %errorlevel% equ 0 (
    echo;
    echo Minecraft�T�[�o�[�͊��ɋN�����Ă��܂��B
    echo;
    exit /b 0
)

echo Docker�R���e�i���N�����Ă��܂�...
docker-compose up -d
if %errorlevel% neq 0 (
    echo;
    echo �G���[�FDocker�R���e�i�̋N���Ɏ��s���܂����B
    echo;
    goto :error
)

echo Minecraft�T�[�o�[�̋N����ҋ@���Ă��܂�...

rem ���O���Ď����郋�[�v
set "timeout_count=0"
set "previous_log_lines=0"
set "total_lines_displayed=0"
:check_startup
timeout /t 2 /nobreak > nul
set /a "timeout_count+=1"
if %timeout_count% gtr 150 (
    echo;
    echo �^�C���A�E�g�F�T�[�o�[�̋N����5���ȏォ�����Ă��܂��B�蓮�Ŋm�F���Ă��������B
    echo;
    goto :end
)

rem ���O���ꎞ�t�@�C���ɕۑ��i��葽���̍s���擾�j
set "temp_log_file=%TEMP%\mc_log_temp_%RANDOM%.txt"
docker-compose logs --tail=200 mc > "%temp_log_file%"

rem ���O�s�����擾
for /f %%i in ('type "%temp_log_file%" ^| find /c /v ""') do set log_lines=%%i

rem �V�������O����������\��
if %log_lines% gtr %previous_log_lines% (
    rem �O��\�������ȍ~�̐V�����s������\��
    set /a "lines_to_skip=%previous_log_lines%"
    set /a "new_lines=%log_lines% - %lines_to_skip%"

    rem ���ׂĂ̐V�����s��\��
    setlocal enabledelayedexpansion
    set "line_num=0"
    for /f "tokens=*" %%a in ('type "%temp_log_file%"') do (
        set /a "line_num+=1"
        if !line_num! gtr !lines_to_skip! echo %%a
    )
    endlocal

    rem ����̃��O�s����ۑ�
    set "previous_log_lines=%log_lines%"
)

rem "Done (...)"�p�^�[�����`�F�b�N
findstr /i "Done (.*)" "%temp_log_file%" > nul
if %errorlevel% equ 0 (
    del "%temp_log_file%" 2>nul
    goto :startup_complete
)

rem "Done"��"help"���܂ލs�������i�N�������̓T�^�I�ȃp�^�[���j
findstr /i "Done.*help" "%temp_log_file%" > nul
if %errorlevel% equ 0 (
    del "%temp_log_file%" 2>nul
    goto :startup_complete
)

rem �ꎞ�t�@�C�����폜
del "%temp_log_file%" 2>nul

goto check_startup

:startup_complete
echo;
echo Minecraft�T�[�o�[�̋N�����������܂����I
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