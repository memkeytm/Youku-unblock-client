object MainForm: TMainForm
  Left = 296
  Top = 211
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Youku unblock'
  ClientHeight = 75
  ClientWidth = 222
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 21
    Width = 31
    Height = 13
    Caption = 'State :'
  end
  object btnPause: TButton
    Left = 45
    Top = 14
    Width = 75
    Height = 25
    Caption = 'Pause'
    TabOrder = 1
    OnClick = btnRunClick
  end
  object btnRun: TButton
    Left = 45
    Top = 14
    Width = 75
    Height = 25
    Caption = 'Run'
    TabOrder = 0
    OnClick = btnRunClick
  end
  object cbAutoStart: TCheckBox
    Left = 8
    Top = 45
    Width = 209
    Height = 17
    Caption = 'Follow the system automatically start'
    TabOrder = 2
    OnClick = cbAutoStartClick
  end
  object btnHelp: TButton
    Left = 139
    Top = 14
    Width = 54
    Height = 25
    Caption = 'Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object TrayIcon1: TTrayIcon
    Hint = 'youku unblock'
    PopupMenu = trayiconPopMenu
    Visible = True
    OnClick = TrayIcon1Click
    Left = 8
    Top = 64
  end
  object trayiconPopMenu: TPopupMenu
    OnPopup = trayiconPopMenuPopup
    Left = 40
    Top = 64
    object Start1: TMenuItem
      Caption = 'Start'
      OnClick = Start1Click
    end
    object Help1: TMenuItem
      Caption = 'Help'
      OnClick = Help1Click
    end
    object exit1: TMenuItem
      Caption = 'Exit'
      OnClick = exit1Click
    end
  end
  object tmrStartDelay: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = tmrStartDelayTimer
    Left = 80
    Top = 64
  end
end
