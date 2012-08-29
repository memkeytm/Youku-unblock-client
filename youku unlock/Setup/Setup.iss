; �ű��� Inno Setup �ű��� ���ɡ�
; �����ĵ���ȡ���� INNO SETUP �ű��ļ�����ϸ���ϣ�

#define MyAppName "youku unblock"
#define MyAppVersion "1.0.0.0"
#define MyAppPublisher "����С��"
#define MyAppURL "http://www.laowuxp.com"
#define MyAppName "youkuUnblock"
#define MyAppExeName MyAppName + ".exe"
#define ReleasePath "..\Bin"
[Setup]
; ע��: AppId ��ֵ��Ψһʶ���������ı�־��
; ��Ҫ������������ʹ����ͬ�� AppId ֵ��
; (�ڱ������е���˵������� -> ���� GUID�����Բ���һ���µ� GUID)
AppMutex={#MyAppName}
AppId={{6FB1253D-DC18-4386-896B-2DE8941F6945}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
VersionInfoVersion = {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=output
OutputBaseFilename=Youku-Unblock
SetupIconFile={#ReleasePath}\crab.ico
Compression=lzma
SolidCompression=yes
DisableProgramGroupPage = yes
//DisableDirPage = yes
DisableReadyPage = yes

[Languages]


[Files]
Source: "..\bin\nodejs\*.*"; DestDir: "{app}\nodejs"; Flags: ignoreversion recursesubdirs
Source: "..\bin\Youku\*.*"; DestDir: "{app}\Youku"; Flags: ignoreversion recursesubdirs
Source: "..\bin\youkuUnblock.exe"; DestDir: "{app}"; Flags: ignoreversion
; ע��: ��Ҫ���κι����ϵͳ�ļ�ʹ�� "Flags: ignoreversion"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}";

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[ISFormDesigner]
WizardForm=FF0A005457495A415244464F524D0030101903000054504630F10B5457697A617264466F726D0A57697A617264466F726D0C436C69656E744865696768740368010B436C69656E74576964746803F1010C4578706C696369744C65667402000B4578706C69636974546F7002000D4578706C69636974576964746803F9010E4578706C69636974486569676874038A010D506978656C73506572496E636802600A54657874486569676874020D00F10C544E65774E6F7465626F6F6B0D4F757465724E6F7465626F6F6B00F110544E65774E6F7465626F6F6B506167650B57656C636F6D65506167650D4578706C69636974576964746803F1010E4578706C696369744865696768740339010000F110544E65774E6F7465626F6F6B5061676509496E6E6572506167650D4578706C69636974576964746803F1010E4578706C6963697448656967687403390100F10C544E65774E6F7465626F6F6B0D496E6E65724E6F7465626F6F6B00F110544E65774E6F7465626F6F6B506167650B4C6963656E7365506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650D53656C656374446972506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167651653656C65637450726F6772616D47726F75705061676507456E61626C6564080D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650F53656C6563745461736B735061676507456E61626C6564080D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650952656164795061676507456E61626C6564080D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650E496E7374616C6C696E67506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED00000000000000

[Registry]
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\windows\CurrentVersion\Run"; Permissions:everyone-full 

[Tasks]

[Components]

[Code]
{ RedesignWizardFormBegin } // ��Ҫɾ����һ�д��롣
// ��Ҫ�޸���һ�δ��룬�����Զ����ɵġ�
procedure RedesignWizardForm;
begin
  with WizardForm.SelectProgramGroupPage do
  begin
    Enabled := False;
  end;

  with WizardForm.SelectTasksPage do
  begin
    Enabled := False;
  end;

  with WizardForm.ReadyPage do
  begin
    Enabled := False;
  end;

{ ReservationBegin }
  // ��һ�������ṩ����ģ����������������һЩ������롣

{ ReservationEnd }
end;
// ��Ҫ�޸���һ�δ��룬�����Զ����ɵġ�
{ RedesignWizardFormEnd } // ��Ҫɾ����һ�д��롣

procedure InitializeWizard();
begin
  RedesignWizardForm;
end;


function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if(pageId = wpSelectTasks) then
    result:= true;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  Errorcode: integer;
begin
  if (CurPageId = wpFinished) then
  begin
    ShellExec('open', ExpandConstant('{#MyAppURL}'), '','', SW_SHOWMAXIMIZED, ewNoWait, Errorcode);
    if(WizardSilent) then
    begin
      ShellExec('open', ExpandConstant('{app}\{#MyAppExeName}'), '','', SW_SHOWNORMAL , ewNoWait, Errorcode);
    end;
  end;
end;



