object Form1: TForm1
  Left = 197
  Top = 124
  Width = 616
  Height = 558
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '‚l‚r ‚oƒSƒVƒbƒN'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Memo1: TMemo
    Left = 50
    Top = 90
    Width = 466
    Height = 261
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 480
    Top = 35
    Width = 81
    Height = 41
    Caption = 'Button1'
    TabOrder = 1
  end
  object Button2: TButton
    Left = 95
    Top = 25
    Width = 61
    Height = 41
    Caption = 'Button2'
    TabOrder = 2
  end
  object Button3: TButton
    Left = 80
    Top = 390
    Width = 161
    Height = 66
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
  object GlobalHotKey1: TGlobalHotKey
    VKCode = 90
    OnHotKey = GlobalHotKey1HotKey
    Left = 460
    Top = 415
  end
end
