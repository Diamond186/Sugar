object SettingFrm: TSettingFrm
  Left = 261
  Top = 96
  BorderStyle = bsDialog
  Caption = 'Setting'
  ClientHeight = 381
  ClientWidth = 574
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object pButton: TPanel
    Left = 0
    Top = 341
    Width = 574
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      574
      40)
    object Bevel: TBevel
      Left = 199
      Top = 0
      Width = 369
      Height = 12
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object bCancel: TButton
      Left = 493
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object bOk: TButton
      Left = 412
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 1
    end
  end
  object TreeView: TTreeView
    Left = 0
    Top = 0
    Width = 193
    Height = 341
    Align = alLeft
    HideSelection = False
    Indent = 19
    ReadOnly = True
    ShowRoot = False
    TabOrder = 1
    OnChange = TreeViewChange
    OnChanging = TreeViewChanging
    OnCollapsing = TreeViewCollapsing
  end
  object Notebook: TNotebook
    Left = 193
    Top = 0
    Width = 381
    Height = 341
    Align = alClient
    PageIndex = 3
    TabOrder = 2
    object TPage
      Left = 0
      Top = 0
      Caption = 'DublLine'
      DesignSize = (
        381
        341)
      object Label1: TLabel
        Left = 6
        Top = 32
        Width = 66
        Height = 13
        Caption = 'Action hotkey'
      end
      object Label3: TLabel
        Left = 329
        Top = 7
        Width = 46
        Height = 13
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        BiDiMode = bdRightToLeft
        Caption = 'VIEW GIF'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentFont = False
        OnClick = Label3Click
      end
      object Label6: TLabel
        Left = 6
        Top = 322
        Width = 337
        Height = 13
        Caption = 
          'Create duplicate current line below. Support duplicate a selecte' +
          'd text.'
      end
      object cbEnableDubleLine: TCheckBox
        Left = 6
        Top = 6
        Width = 51
        Height = 17
        Caption = 'Enable'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbEnableDubleLineClick
      end
      object hkDubleLine: THotKey
        Left = 100
        Top = 29
        Width = 121
        Height = 19
        HotKey = 16452
        Modifiers = [hkCtrl]
        TabOrder = 1
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'Selection'
      DesignSize = (
        381
        341)
      object Label2: TLabel
        Left = 6
        Top = 32
        Width = 79
        Height = 13
        Caption = 'Selection hotkey'
      end
      object Label4: TLabel
        Left = 329
        Top = 7
        Width = 46
        Height = 13
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        BiDiMode = bdRightToLeft
        Caption = 'VIEW GIF'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentFont = False
        OnClick = Label3Click
      end
      object Label5: TLabel
        Left = 6
        Top = 57
        Width = 91
        Height = 13
        Caption = 'Deselection hotkey'
      end
      object Label7: TLabel
        Left = 6
        Top = 322
        Width = 231
        Height = 13
        Caption = 'Selects a sequence of increasing blocks of code.'
      end
      object cbEnableSelection: TCheckBox
        Left = 6
        Top = 6
        Width = 97
        Height = 17
        Caption = 'Enable'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbEnableSelectionClick
      end
      object hkSelection: THotKey
        Left = 100
        Top = 29
        Width = 121
        Height = 19
        HotKey = 16471
        Modifiers = [hkCtrl]
        TabOrder = 1
      end
      object hkDeselection: THotKey
        Left = 100
        Top = 54
        Width = 121
        Height = 19
        HotKey = 24663
        Modifiers = [hkShift, hkCtrl]
        TabOrder = 2
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'Clipboard'
      DesignSize = (
        381
        341)
      object Label8: TLabel
        Left = 329
        Top = 7
        Width = 46
        Height = 13
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        BiDiMode = bdRightToLeft
        Caption = 'VIEW GIF'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentFont = False
        OnClick = Label3Click
      end
      object Label9: TLabel
        Left = 6
        Top = 311
        Width = 368
        Height = 26
        Caption = 
          'When use Ctrl+C or Ctrl+Ins a value of buffer will be saved. For' +
          ' use a buffer need press Alt+V. You can lock value or removing i' +
          'tem buffer system.'
        WordWrap = True
      end
      object Label10: TLabel
        Left = 6
        Top = 32
        Width = 66
        Height = 13
        Caption = 'Action hotkey'
      end
      object Label11: TLabel
        Left = 6
        Top = 50
        Width = 56
        Height = 26
        Caption = 'Copy item to clipboard'
        WordWrap = True
      end
      object Label12: TLabel
        Left = 6
        Top = 82
        Width = 63
        Height = 13
        Caption = 'Storage slots'
      end
      object cbEnableClipboard: TCheckBox
        Left = 6
        Top = 6
        Width = 97
        Height = 17
        Caption = 'Enable'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbEnableClipboardClick
      end
      object hkClipboard: THotKey
        Left = 100
        Top = 29
        Width = 121
        Height = 19
        HotKey = 32854
        TabOrder = 1
      end
      object hkClipboardCopyItem: THotKey
        Left = 100
        Top = 54
        Width = 121
        Height = 19
        HotKey = 16397
        Modifiers = [hkCtrl]
        TabOrder = 2
      end
      object seClipboardSlot: TSpinEdit
        Left = 100
        Top = 79
        Width = 121
        Height = 22
        MaxLength = 3
        MaxValue = 100
        MinValue = 1
        TabOrder = 3
        Value = 10
      end
      object cbOSClipboard: TCheckBox
        Left = 6
        Top = 107
        Width = 163
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Use OS clipboard'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'Other'
      DesignSize = (
        381
        341)
      object SplitterUpdate: TSplitter
        Left = 45
        Top = 11
        Width = 330
        Height = 1
        Align = alNone
        Color = clBtnShadow
        ParentColor = False
        ResizeStyle = rsLine
      end
      object Label13: TLabel
        Left = 6
        Top = 3
        Width = 35
        Height = 13
        Caption = 'Update'
      end
      object Label14: TLabel
        Left = 6
        Top = 80
        Width = 48
        Height = 13
        Caption = 'Text code'
      end
      object SplitterTextCode: TSplitter
        Left = 58
        Top = 87
        Width = 317
        Height = 1
        Align = alNone
        Color = clBtnShadow
        ParentColor = False
        ResizeStyle = rsLine
      end
      object Label15: TLabel
        Left = 210
        Top = 104
        Width = 160
        Height = 11
        Caption = '(except for a commentary and a string)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object SplitterPM: TSplitter
        Left = 88
        Top = 146
        Width = 287
        Height = 1
        Align = alNone
        Color = clBtnShadow
        ParentColor = False
        ResizeStyle = rsLine
      end
      object Label16: TLabel
        Left = 6
        Top = 139
        Width = 79
        Height = 13
        Caption = 'Project Manager'
      end
      object Label17: TLabel
        Left = 329
        Top = 157
        Width = 46
        Height = 13
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        BiDiMode = bdRightToLeft
        Caption = 'VIEW GIF'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentColor = False
        ParentFont = False
      end
      object Label18: TLabel
        Left = 210
        Top = 159
        Width = 76
        Height = 11
        Caption = '(will be download)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object cbAutoUpdate: TCheckBox
        Left = 6
        Top = 22
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Check new version with start IDE'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object cbAllVersionsUpdate: TCheckBox
        Left = 6
        Top = 45
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Update for all IDE versions of exists'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object cbEnglishKeyboard: TCheckBox
        Left = 6
        Top = 101
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Use English keyboard for code'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object cbUsePM: TCheckBox
        Left = 6
        Top = 156
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Enable Sugar progect manager'
        TabOrder = 3
        OnClick = cbUsePMClick
      end
      object cbIgnoreProject1: TCheckBox
        Left = 6
        Top = 179
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Ignore with name like Project1'
        Enabled = False
        TabOrder = 4
      end
      object cbIgnoreDefaultFolder: TCheckBox
        Left = 6
        Top = 202
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Ignore projects from default folder'
        Enabled = False
        TabOrder = 5
      end
      object cbStartupSugarPM: TCheckBox
        Left = 6
        Top = 225
        Width = 195
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Startup with Windows'
        TabOrder = 6
      end
    end
  end
end
