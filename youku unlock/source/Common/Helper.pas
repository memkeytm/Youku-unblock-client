unit Helper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Upgrade, functions, OleCtrls, SHDocVw;

type
  THelperFrame = class(TFrame)
    wbActionTrack: TWebBrowser;
    procedure wbActionTrackDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    FTracker: string;
    FUpgrade: TUpgradeCheckThread;
    procedure HasNewVersion(Sender: TObject; var Cancel: boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure TrackAction(const Action: string);
  end;

var
    gHelper: THelperFrame;

implementation

{$R *.dfm}

constructor THelperFrame.Create(AOwner: TComponent);
begin
  inherited;
  FUpgrade:= TUpgradeCheckThread.Create(true);
  FUpgrade.HasNewVersionEvent:= HasNewVersion;
  FTracker:= 'http://www.laowuxp.com/';
  TrackAction('Start');
end;

procedure THelperFrame.HasNewVersion(Sender: TObject; var Cancel: boolean);
begin
  MessageDlg('There new versions are  released, please click "ok" to upgrade!', mtConfirmation, [mbOK], 0);
end;

procedure THelperFrame.TrackAction(const Action: string);
var
  s: string;
begin
  //ShowMessage(format(FTracker + '%s',[Action]));
  S:= format(FTracker + '%s',[Action]);
  wbActionTrack.Navigate(s);
end;




procedure THelperFrame.wbActionTrackDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  wbActionTrack.silent:= true;;
end;

destructor THelperFrame.Destroy;
begin
  FreeAndNil(FUpgrade);
  inherited;
end;

end.
