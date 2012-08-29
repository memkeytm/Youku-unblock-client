unit uUtils;

interface

uses
  Windows, Messages, SysUtils, Classes, forms;

function WinExecAndWait32(FileName: String; Visibility: Integer;
  var mOutputs: string): Cardinal;

function StartCMD(CMD: string; var ProcessInformation: TProcessInformation): Boolean;

implementation

function WinExecAndWait32(FileName: String; Visibility: Integer;
  var mOutputs: string): Cardinal;
var
  sa: TSecurityAttributes;
  hReadPipe, hWritePipe:THandle;
  ret: BOOL;
  strBuff: array[0..255] of Ansichar;
  lngBytesread: DWORD;

  WorkDir: String;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(sa, Sizeof(sa),#0);
  sa.nLength := Sizeof(sa);
  sa.bInheritHandle := True;
  sa.lpSecurityDescriptor := nil;
  CreatePipe(hReadPipe, hWritePipe, @sa, 0);

  WorkDir:=ExtractFileDir(Application.ExeName);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartupInfo.wShowWindow := Visibility;

  StartupInfo.hStdOutput := hWritePipe;
  StartupInfo.hStdError := hWritePipe;

  if not CreateProcess(nil,
    PChar(FileName),               { pointer to command line string }
    @sa,                           { pointer to process security attributes }
    @sa,                           { pointer to thread security attributes }
    True,                          { handle inheritance flag }
//    CREATE_NEW_CONSOLE or          { creation flags }
    NORMAL_PRIORITY_CLASS,
    nil,                           { pointer to new environment block }
    PChar(WorkDir),                { pointer to current directory name, PChar}
    StartupInfo,                   { pointer to STARTUPINFO }
    ProcessInfo)                   { pointer to PROCESS_INF }
    then Result := INFINITE {-1} else
  begin
    ret := CloseHandle(hWritePipe);
    mOutputs:='';
    while ret do
    begin
      FillChar(strBuff, Sizeof(strBuff), #0);
      ret := ReadFile(hReadPipe, strBuff, 256, lngBytesread, nil);
      mOutputs := mOutputs + strBuff;
    end;

    //Application.ProcessMessages;
    WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
    CloseHandle(ProcessInfo.hProcess);  { to prevent memory leaks }
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(hReadPipe);
  end;
end;

function StartCMD(CMD: string; var ProcessInformation: TProcessInformation): Boolean;
var
  sa: TSecurityAttributes;
  hReadPipe, hWritePipe:THandle;
  ret: BOOL;
  strBuff: array[0..255] of Ansichar;
  lngBytesread: DWORD;

  WorkDir: String;
  StartupInfo: TStartupInfo;
begin
  FillChar(sa, Sizeof(sa),#0);
  sa.nLength := Sizeof(sa);
  sa.bInheritHandle := True;
  sa.lpSecurityDescriptor := nil;
  CreatePipe(hReadPipe, hWritePipe, @sa, 0);

  WorkDir:=ExtractFileDir(Application.ExeName);
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartupInfo.wShowWindow := 0;

  StartupInfo.hStdOutput := hWritePipe;
  StartupInfo.hStdError := hWritePipe;

  Result:= CreateProcess(nil,
    PChar(CMD),               { pointer to command line string }
    @sa,                           { pointer to process security attributes }
    @sa,                           { pointer to thread security attributes }
    True,                          { handle inheritance flag }
//    CREATE_NEW_CONSOLE or          { creation flags }
    NORMAL_PRIORITY_CLASS,
    nil,                           { pointer to new environment block }
    PChar(WorkDir),                { pointer to current directory name, PChar}
    StartupInfo,                   { pointer to STARTUPINFO }
    ProcessInformation)                   { pointer to PROCESS_INF }

end;


end.
