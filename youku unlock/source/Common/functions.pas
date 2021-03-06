unit functions;

interface
uses
  SysUtils, Classes, windows, ActiveX;

const
  ATomName = 'WucmNeiHanTu';

function IsHeiHanImg(const Rect1: TRect): Boolean;
function CreateTempFile(const Path: string; const ext: string='.rar'): string;
function GetTempDir: string;
function AppDataPath: string;
function AppConfig: string;
function GetUpdateUrl: string;
procedure SaveUpdateUrl(const url: string);
function BrowseForFolder(const browseTitle:string;const initialFolder:string=''):string;

function Enc(const Str:String):String;
function Dec(const Str:String):String;
implementation

uses
  CnIni, shlobj;

function IsHeiHanImg(const Rect1: TRect): Boolean;
const
  Min_NeiHan_Width = 350;
  Min_NeiHan_Height = 300;
begin
  result:= ((Rect1.Right - Rect1.Left) >=Min_NeiHan_Width)
    and ((Rect1.Bottom - Rect1.Top) >=Min_NeiHan_Height);
end;

function CreateTempFile(const Path: string; const ext: string='.rar'): string;
var
  arr: array[0..MAX_PATH] of Char;
  num: DWORD;
  TmpGUID: TGUID;
  sGUID: string;
begin
  sGUID:= DateToStr(now());
  if CoCreateGUID(TmpGUID) = S_OK then
    sGUID := GUIDToString(TmpGUID);
  if(Path = '') then
  begin
    GetTempPath(MAX_PATH, arr);
    result:= IncludeTrailingPathDelimiter(string(arr)) + sGUID + ext;
  end
  else
  begin
    result:= IncludeTrailingPathDelimiter(Path) + sGUID + ext;
  end;
end;

function GetTempDir: string;
begin;
{$IFDEF LINUX}
    Result := GetEnv('TMPDIR');
    if Result = '' then
      Result := '/tmp/'
    else if Result[Length(Result)] <> PathDelim then
      Result := Result + PathDelim;
{$ENDIF}
{$IFDEF MSWINDOWS}
    SetLength(Result, 255);
    SetLength(Result, GetTempPath(255, (PChar(Result))));
{$ENDIF}
end;

function AppDataPath: string;
begin
  Result:= IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA'))  + 'DongRunSoft\';
end;

function AppConfig: string;
begin
  Result:= AppDataPath + 'config.ini';
end;

function GetUpdateUrl: string;
var
  Ini: TCnIniFile;
begin
  result:= dec('DA7DDE25A942AB32C26ED834F708AA2EC67CC430E01AE533D161CC3AFF09E1359C6AC538BC1EF026C660C97AE61DE026C66C8421EB19');
  Ini:= TCnIniFile.Create(AppConfig);
  try
    result:= Ini.ReadString('system', 'upgradeUrl', dec('DA7DDE25A942AB32C26ED834F708AA2EC67CC430E01AE533D161CC3AFF09E1359C6AC538BC1EF026C660C97AE61DE026C66C8421EB19'));
  finally
    FreeAndNil(Ini);
  end;
end;

procedure SaveUpdateUrl(const Url: string);
var
  Ini: TCnIniFile;
begin
  Ini:= TCnIniFile.Create(AppConfig);
  try
    Ini.WriteString('system', 'upgradeUrl', Url);
  finally
    FreeAndNil(Ini);
  end;
end;

var
lg_StartFolder:string;

function BrowseForFolderCallBack(Wnd:HWND;uMsg:UINT;lParam,lpData:LPARAM):Integer stdcall;
begin
  if uMsg=BFFM_INITIALIZED then
    SendMessage(Wnd,BFFM_SETSELECTION,1,Integer(@lg_StartFolder[1]));
  result:=0;
end;

function BrowseForFolder(const browseTitle:string;const initialFolder:string=''):string;
const
  BIF_NEWDIALOGSTYLE=$40;
var
  browse_info:TBrowseInfo;
  folder:array[0..MAX_PATH] of char;
  find_context:PItemIDList;
begin
  FillChar(browse_info,SizeOf(browse_info),#0);
  lg_StartFolder:=initialFolder;
  browse_info.pszDisplayName:=@folder[0];
  browse_info.lpszTitle:=PChar(browseTitle);
  browse_info.ulFlags:=BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  if initialFolder<>'' then
      browse_info.lpfn:=BrowseForFolderCallBack;

  find_context:=SHBrowseForFolder(browse_info);
  if Assigned(find_context) then
  begin
    if SHGetPathFromIDList(find_context,folder) then
      result:=folder
    else
      result:='';
    GlobalFreePtr(find_context);
  end
  else
    result:='';
end;

const
  XorKey:array[0..7] of Byte=($B2,$09,$AA,$55,$93,$6D,$84,$47);

function Enc(const Str:String):String;
var
 i,j:Integer;
begin
 Result:='';
 j:=0;
 for i:=1 to Length(Str) do
   begin
     Result:=Result+IntToHex(Byte(Str[i]) xor XorKey[j],2);
     j:=(j+1) mod 8;
   end;
end;

function Dec(const Str:String):String;//�ַ����ܺ���
var
 i,j:Integer;
begin
 Result:='';
 j:=0;
 for i:=1 to Length(Str) div 2 do
   begin
     Result:=Result+Char(StrToInt('$'+Copy(Str,i*2-1,2)) xor XorKey[j]);
     j:=(j+1) mod 8;
   end;
end;

end.
