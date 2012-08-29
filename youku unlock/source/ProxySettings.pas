unit ProxySettings;
interface

uses Windows, Sysutils, Classes, messages, Wininet, registry;

function ChangeProxy(const Proxy, Port,ByPass: string; const bEnabled: boolean = True): boolean;

implementation

function ChangeProxy(const Proxy, Port,ByPass: string; const bEnabled: boolean = True): boolean;
var
  reg: Tregistry;
  info: INTERNET_PROXY_INFO;
  Fproxy: string;
begin
  Result := False;
  FProxy :=Format('%s:%s',[Proxy,Port]);
  reg :=Tregistry.Create;
  try
    reg.RootKey :=HKEY_CURRENT_USER;
    if reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Internet Settings', True) then
    begin
      reg.Writestring('ProxyServer', Fproxy);
      reg.WriteInteger('ProxyEnable', integer(bEnabled));
      info.dwAccessType :=INTERNET_OPEN_TYPE_PROXY;
      info.lpszProxy :=pchar(proxy);
      info.lpszProxyBypass :=pchar(ByPass);
      InternetSetOption(nil, INTERNET_OPTION_PROXY, @info, SizeOf(Info));
      InternetSetOption(nil, INTERNET_OPTION_SETTINGS_CHANGED, nil, 0);
      Result:=True;
    end
  finally
    reg.CloseKey;
    reg.free;
  end;
end;

end.
