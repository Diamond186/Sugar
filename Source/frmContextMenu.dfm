object frmMenu: TfrmMenu
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 141
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbMenu: TListBox
    Left = 0
    Top = 13
    Width = 447
    Height = 128
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
    OnKeyDown = lbMenuKeyDown
  end
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 447
    Height = 13
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 447
      Height = 13
      Align = alClient
      Shape = bsTopLine
      ExplicitHeight = 16
    end
  end
end
