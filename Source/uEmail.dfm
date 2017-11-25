object frmEmail: TfrmEmail
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Email'
  ClientHeight = 200
  ClientWidth = 566
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    566
    200)
  PixelsPerInch = 96
  TextHeight = 13
  object mBody: TMemo
    Left = 0
    Top = 0
    Width = 566
    Height = 129
    Align = alTop
    BorderStyle = bsNone
    TabOrder = 0
    OnChange = mBodyChange
  end
  object bSend: TButton
    Left = 8
    Top = 167
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Send'
    Enabled = False
    TabOrder = 1
    OnClick = bSendClick
  end
  object bAttach: TButton
    Left = 8
    Top = 136
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Attach'
    TabOrder = 2
    OnClick = bAttachClick
  end
  object ScrollBox: TScrollBox
    Left = 89
    Top = 138
    Width = 472
    Height = 54
    HorzScrollBar.Visible = False
    VertScrollBar.Style = ssHotTrack
    VertScrollBar.Tracking = True
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    TabOrder = 3
    object FlowPanel: TPanel
      Left = 3
      Top = 0
      Width = 365
      Height = 25
      BevelOuter = bvNone
      TabOrder = 0
    end
  end
end
