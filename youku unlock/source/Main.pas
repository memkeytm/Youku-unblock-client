unit Main;
//Download by http://www.codefans.net
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellApi, ExtCtrls, StdCtrls, Menus;

type
  TMainForm = class(TForm)
    btnRun: TButton;
    Label1: TLabel;
    btnPause: TButton;
    cbAutoStart: TCheckBox;
    TrayIcon1: TTrayIcon;
    trayiconPopMenu: TPopupMenu;
    Start1: TMenuItem;
    exit1: TMenuItem;
    Help1: TMenuItem;
    btnHelp: TButton;
    tmrStartDelay: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure cbAutoStartClick(Sender: TObject);
    procedure Start1Click(Sender: TObject);
    procedure exit1Click(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure trayiconPopMenuPopup(Sender: TObject);
    procedure tmrStartDelayTimer(Sender: TObject);
  private
    FLoading: Boolean;
    Fproxyenabled: Boolean;
    procedure LancheProxy;
    procedure KillProcxy();
    procedure EnableIE(Enable:Boolean);
    procedure EnableFirefox(Enable: Boolean);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  ReadOut, WriteOut, ReadIn, WriteIn: THandle;
  ProcessInfo: TProcessInformation;
implementation

uses
  ShlObj, ShFolder, ProxySettings, IniFiles, Registry, Helper, Upgrade;

{$R *.dfm}

procedure SetAutoRun(const Exe: string; AutoRun: Boolean);
var
  Reg:TRegistry;                                                     //首先定义一个TRegistry类型的变量Reg
begin
  Reg:=TRegistry.Create;                                     //创建一个新键
  try
    Reg.RootKey:=HKEY_LOCAL_MACHINE;     //将根键设置为HKEY_LOCAL_MACHINE
    Reg.OpenKey('SOFTWARE\Microsoft\windows\CurrentVersion\Run',true);//打开一个键
    if AutoRun then
      Reg.WriteString(ChangeFileExt(ExtractFileName(Exe),''), Format('"%s" AutoStart',[EXE]))           //在Reg这个键中写入数据名称和数据数值
    else
      Reg.DeleteValue(ChangeFileExt(ExtractFileName(Exe),''));
  finally
    Reg.CloseKey;                                                    //关闭键
  end;

end;

function IsAutoRun(const Exe: string): Boolean;
var
  Reg:TRegistry;                                                     //首先定义一个TRegistry类型的变量Reg
begin
  Reg:=TRegistry.Create;
  try                                   //创建一个新键
    Reg.RootKey:=HKEY_LOCAL_MACHINE;     //将根键设置为HKEY_LOCAL_MACHINE
    Reg.OpenKey('SOFTWARE\Microsoft\windows\CurrentVersion\Run',true);//打开一个键
    Result:= Reg.ValueExists(ChangeFileExt(ExtractFileName(Exe),''));
  finally
    Reg.CloseKey;                                                    //关闭键
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  KillProcxy();
  if(Fproxyenabled) then
  begin
    EnableIE(False);
    EnableFirefox(False);
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  top:= Screen.WorkAreaRect.Bottom - Height;
  left:= Screen.WorkAreaRect.Right - Width;
  if (ParamCount= 1)and(ParamStr(1)='AutoStart') then
  begin
    tmrStartDelay.Enabled:= true;
    btnRun.Enabled:= false;
  end
  else
  begin
    btnRun.Click;
  end;
end;

procedure TMainForm.Help1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://www.laowuxp.com/youku-unblock.html','',nil,SW_SHOWMAXIMIZED);
end;

procedure TMainForm.KillProcxy();
begin
  WinExec(PAnsiChar('youku\KillProxy.bat'), SW_HIDE);
  sleep(1000);
end;

procedure TMainForm.LancheProxy;
begin
  ShowMessage('1231313');
  WinExec(PAnsiChar('youku\RunProxy.bat'), SW_SHOWNORMAL);
  sleep(1000);
end;


procedure TMainForm.Start1Click(Sender: TObject);
begin
  if Fproxyenabled then
    btnPause.Click
  else
    btnRun.Click;
end;

procedure TMainForm.tmrStartDelayTimer(Sender: TObject);
begin
  tmrStartDelay.Enabled:= false;
  KillProcxy();
  LancheProxy();
  btnRun.Enabled:= true;
  btnRun.Click;
end;

procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
  Show();
end;

procedure TMainForm.trayiconPopMenuPopup(Sender: TObject);
begin
  if(Fproxyenabled)then
    Start1.Caption:= 'Pause'
  else
    Start1.Caption:= 'Start';
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  gHelper:= THelperFrame.Create(Self);
  gHelper.Parent:= self;
  gHelper.Left:= 5000;
  gHelper.Top:= 5000;
  gHelper.Width:= 0;
  gHelper.Height:= 0;

  if (ParamCount= 0)then
  begin
    KillProcxy();
    LancheProxy();
  end;
  FLoading:= true;
  cbAutoStart.Checked:= IsAutoRun(Application.ExeName);
  FLoading:= false;
  TrayIcon1.Hint:= caption;
end;

function GetFirefoxAppdataFolder: string;
begin
  Result:= GetEnvironmentVariable('appdata') + '\Mozilla\firefox\';
end;

function FileGetSize(const FileName: string): integer;
begin
  Result:= 0;
end;

procedure TMainForm.btnHelpClick(Sender: TObject);
begin
  Help1Click(nil);
end;

procedure TMainForm.btnRunClick(Sender: TObject);
begin
  if Fproxyenabled then
  begin
    btnRun.BringToFront;
    btnRun.SetFocus;
  end
  else
  begin
    btnPause.BringToFront;
    btnPause.SetFocus;
  end;

  Fproxyenabled:= not Fproxyenabled;
  EnableIE(Fproxyenabled);
  EnableFirefox(Fproxyenabled);
end;

procedure TMainForm.cbAutoStartClick(Sender: TObject);
begin
  if(not FLoading) then
    SetAutoRun(Application.ExeName,cbAutoStart.Checked);
end;

procedure TMainForm.EnableFirefox(Enable: Boolean);
var
  NetscapeProfiles: TStrings;
  RegDat: string;
  fileSize : integer;
  currPos : PChar;
  dirStr : string;
  currProfile : integer;
  currLine : integer;
  NetscapeIgnore : string;
  ini: TIniFile;
  path: string;
begin
// first, find profiles from file
  NetscapeProfiles := TStringList.Create;
  try
    RegDat := GetFirefoxAppdataFolder + 'profiles.ini';

    // work only if the file exists
    if FileExists(RegDat) then
    begin
      ini:= TIniFile.Create(RegDat);
      path:= ini.ReadString('Profile0','Path','');
      if Path<>'' then
      begin
        Path:= GetFirefoxAppdataFolder + Path;
        NetscapeProfiles.Add(Path);
      end;
    end
    else
      exit;

    // starts working with the profiles files
    for currProfile := 0 to NetscapeProfiles.Count - 1 do
    begin
      // if the file pref.js exists in the profile directory
      if FileExists(NetscapeProfiles[currProfile] + '\prefs.js') then
      begin
        // create a string list to store the content of the file
        with TStringList.Create() do
        begin
          // load it
          LoadFromFile(NetscapeProfiles[currProfile]+'\prefs.js');

          // then modify it

          // suppress the lines about proxy
          currLine := 0;
          repeat
            if pos('network.proxy', Strings[currLine]) = 0 then
            begin
              inc(currLine);
            end
            else
            begin
              Delete(currLine);
            end;
          until currLine > count-1;

          // add the new lines about the proxies
          Add('user_pref("network.proxy.http", "127.0.0.1");');
          Add('user_pref("network.proxy.http_port", "8080");');
          if Enable then
            Add('user_pref("network.proxy.type", 5);')//1 为指定代理， 5为系统代理
          else
            Add('user_pref("network.proxy.type", 0);');

          SaveToFile(NetscapeProfiles[currProfile]+'\prefs.js');
          // free the string list
          free;
        end;
      end;
    end;
  finally
    NetscapeProfiles.Free;
  end;
end;

procedure TMainForm.EnableIE(Enable:Boolean);
begin
  ChangeProxy('127.0.0.1','8080','1', Enable);
end;

procedure TMainForm.exit1Click(Sender: TObject);
begin
  close();
end;

end.

