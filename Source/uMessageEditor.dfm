object MesEditorForm: TMesEditorForm
  Left = 578
  Top = 308
  Anchors = [akRight, akBottom]
  BorderStyle = bsNone
  ClientHeight = 76
  ClientWidth = 270
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object gbMessage: TGroupBox
    Left = 3
    Top = 0
    Width = 264
    Height = 74
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'gbMessage'
    TabOrder = 0
    DesignSize = (
      264
      74)
    object ImageClose: TImage
      Left = 245
      Top = 3
      Width = 16
      Height = 16
      Cursor = crHandPoint
      Anchors = [akTop, akRight]
      Proportional = True
      Transparent = True
      OnClick = ImageCloseClick
    end
  end
end
