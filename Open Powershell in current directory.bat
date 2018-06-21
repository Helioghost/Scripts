REM ECHO "%cd%"
REM SET %currentdirectory%="%cd%"
REM ECHO "%currentdirectory%"
powershell start-process powershell -verb runas -ArgumentList "{-NoExit -ExecutionPolicy bypass -Command cd %cd%}"