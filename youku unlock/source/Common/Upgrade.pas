unit upgrade;

interface

uses
  Sysutils, classes, windows, Forms, cninetUtils;

type
  TSimpleVersion=record
    dwProductVersionMS: DWORD;
    dwProductVersionLS: DWORD;
  end;

  TUpdate=record      { Structure of update information }
    Name:String[63];
    Version:TSimpleVersion;
    Date:TDateTime;
    URL:ShortString;
  end;

  TCancelNotifyEvent = procedure(Sender: TObject; var Cancel: boolean) of object;
  TUpgradeCheckThread = class(TThread)
  private
    Cancel: boolean;
    FFileName: string;
    FHasNewVersionEvent: TCancelNotifyEvent;
    FGotoUpdateEvent: TCancelNotifyEvent;
    procedure NotifyHasNewVersion();
    procedure NotifyGotoUpdate();
    procedure DoDownloadedComplete();
    function DownloadString(const Url: string): string;
    function DownloadFile(const Url: string): boolean;
    procedure SetHasNewVersionEvent(const Value: TCancelNotifyEvent);
    procedure SetGotoUpdateEvent(const Value: TCancelNotifyEvent);
  protected
    procedure Execute; override;
  public
    property HasNewVersionEvent: TCancelNotifyEvent read FHasNewVersionEvent write SetHasNewVersionEvent;
    property GotoUpdateEvent: TCancelNotifyEvent read FGotoUpdateEvent write SetGotoUpdateEvent;
  end;

function GetBuildInfo(const FName:string):TSimpleVersion;
function SeparateVerStr(const s:String):TSimpleVersion;
function CenterStr(const Src,Before,After:string):string;
function VersionCheck(const OriVer,NewVer:TSimpleVersion):Boolean;
function AnalyseUpdate(const Body:String; const Update_Ori: TUpdate; var Update:TUpdate):Boolean;
procedure DoUpdate(const InstallName: string);

implementation

uses
  Shellapi, functions;

function GetBuildInfo(const FName:string):TSimpleVersion;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(FName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    Result.dwProductVersionMS := dwFileVersionMS;
    Result.dwProductVersionLS := dwFileVersionLS;
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

function SeparateVerStr(const s:String):TSimpleVersion;
const
  Separator = '.';
var
  p:WORD;
  v1,v2,v3,v4:WORD;
  Temp: string;
begin
  if Length(s)=0 then Exit;
  Temp:= S;
  p:=pos(Separator, s);
  v1:=StrToInt(copy(s,1,p-1));
  Delete(Temp,1,p);
  p:=Pos(Separator,Temp);
  v2:=StrToInt(copy(Temp,1,p-1));
  Delete(Temp,1,p);
  p:=Pos(Separator,Temp);
  v3:=StrToInt(copy(Temp,1,p-1));
  Delete(Temp,1,p);
  v4:=StrToInt(Temp);

  Result.dwProductVersionMS:=v1*$10000+v2;
  Result.dwProductVersionLS:=v3*$10000+v4;
end;

function CenterStr(const Src, Before,After:string):string;
var
  Pos1,Pos2:WORD;
begin
  Pos1:=Pos(Before,Src)+Length(Before);
  Pos2:=Pos(After,Src);
  Result:=Copy(Src,Pos1,Pos2-Pos1);
end;

function VersionCheck(const OriVer,NewVer:TSimpleVersion):Boolean;
begin
  if (OriVer.dwProductVersionMS=NewVer.dwProductVersionMS) then
  begin
    Result:=OriVer.dwProductVersionLS<NewVer.dwProductVersionLS;
  end else
  begin
    Result:=OriVer.dwProductVersionMS<NewVer.dwProductVersionMS
  end;
end;


function AnalyseUpdate(const Body:string;const Update_Ori: TUpdate; var Update:TUpdate):Boolean;
var
  TmpStr,Ver:String;
begin
  TmpStr:=CenterStr(Body,Format('[%s]',[LowerCase(Update_Ori.Name)]),Format('[/%s]',[LowerCase(Update_Ori.Name)]));
  if TmpStr='' then
    Result:=False else
  begin
    Ver:=CenterStr(TmpStr,'<ver>','</ver>');
    Update.Version:=SeparateVerStr(Ver);
    Update.Date:=StrToDate(CenterStr(TmpStr,'<date>','</date>'));
    Update.URL:=CenterStr(TmpStr,'<url>','</url>');
    Result:=True;
    //Memo1.Lines.Add('Version:'+Ver);
    //Memo1.Lines.Add('Date:'+DateToStr(Update.Date));
    //Memo1.Lines.Add('URL:'+Update.URL);
  end;
end;

function GetOriUpdateInfp(): TUpdate;
var
  Update_Ori: TUpdate;
begin
  Update_Ori.Name:='Update';
  Update_Ori.Version:=GetBuildInfo(ParamStr(0));
  Update_Ori.Date:= FileDateToDateTime(FileAge(ParamStr(0)));
  Update_Ori.URL:= '';
  Result:= Update_Ori;
end;


procedure DoUpdate(const InstallName: string);
begin
  //Application.MessageBox(PChar(InstallName),'');
  //PChar('/VERYSILENT')*/
  ShellExecute(0, 'open', PChar(InstallName), PChar('/VERYSILENT'), nil, SW_Show);
  Application.Terminate;
end;


function TUpgradeCheckThread.DownloadFile(const Url: string): boolean;
var
  HTTPDownload: TCnHTTP;
begin
  try
    try
      HTTPDownload:= TCnHTTP.Create;

      //HTTPDownload.OnProgress:= OnProgress;
      Result:= HTTPDownload.GetFile(URL, FFileName);
    except
      Result:= false;
    end;
  finally
    FreeAndNil(HTTPDownload);
  end;
end;

function TUpgradeCheckThread.DownloadString(const Url: string): string;
var
  HTTPDownload: TCnHTTP;
begin
  try
    try
      HTTPDownload:= TCnHTTP.Create;
      Result:= HTTPDownload.GetString(Url);
    except
      on E: Exception do begin
        Result:= '';
        MessageBox(0, PChar(Url),'',0);
      end;
    end;
  finally
    FreeAndNil(HTTPDownload);
  end;
end;

procedure TUpgradeCheckThread.Execute;
var
  Update_Ori, Update_New: TUpdate;
  b: boolean;
  body, TempFileName: string;
begin
  Update_Ori:= GetOriUpdateInfp();
  body:= DownloadString(GetUpdateUrl());
  //MessageBox(0, PChar(Body),'', 0);
  if (body<>'')and AnalyseUpdate(body, Update_Ori, Update_New) then
  begin
    b:= VersionCheck(Update_Ori.Version,Update_New.Version);
    if(b) then
    begin
      Cancel:= false;
      Synchronize(NotifyHasNewVersion);
      if(not Cancel) then
      begin
        FFileName:= CreateTempFile(GetTempDir,'.exe');
        if(DownloadFile(Update_New.URL)) then
        begin
          Cancel:= false;
          Synchronize(NotifyGotoUpdate);
          if(not Cancel) then
          begin
            SaveUpdateUrl(Update_New.URL);
            Synchronize(DoDownloadedComplete);
          end;
        end;
      end;
    end;
  end;
end;

procedure TUpgradeCheckThread.DoDownloadedComplete;
begin
  DoUpdate(FFileName);
end;

procedure TUpgradeCheckThread.NotifyGotoUpdate;
begin

end;

procedure TUpgradeCheckThread.NotifyHasNewVersion;
begin
  if Assigned(HasNewVersionEvent) then
    HasNewVersionEvent(self, Cancel);
end;

procedure TUpgradeCheckThread.SetGotoUpdateEvent(
  const Value: TCancelNotifyEvent);
begin
  FGotoUpdateEvent := Value;
end;


procedure TUpgradeCheckThread.SetHasNewVersionEvent(
  const Value: TCancelNotifyEvent);
begin
  FHasNewVersionEvent := Value;
end;

end.
