unit SettingForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, ExtCtrls, StdCtrls, ComCtrls,
  Spin;

type
  TSettingFrm = class(TForm)
    pButton: TPanel;
    bCancel: TButton;
    bOk: TButton;
    TreeView: TTreeView;
    Notebook: TNotebook;
    cbEnableDubleLine: TCheckBox;
    hkDubleLine: THotKey;
    Label1: TLabel;
    cbEnableSelection: TCheckBox;
    Label2: TLabel;
    hkSelection: THotKey;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    hkDeselection: THotKey;
    Bevel: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    cbEnableClipboard: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    hkClipboard: THotKey;
    Label11: TLabel;
    hkClipboardCopyItem: THotKey;
    Label12: TLabel;
    seClipboardSlot: TSpinEdit;
    cbOSClipboard: TCheckBox;
    SplitterUpdate: TSplitter;
    Label13: TLabel;
    cbAutoUpdate: TCheckBox;
    cbAllVersionsUpdate: TCheckBox;
    Label14: TLabel;
    SplitterTextCode: TSplitter;
    cbEnglishKeyboard: TCheckBox;
    Label15: TLabel;
    SplitterPM: TSplitter;
    Label16: TLabel;
    cbUsePM: TCheckBox;
    cbIgnoreProject1: TCheckBox;
    cbIgnoreDefaultPath: TCheckBox;
    Label17: TLabel;
    Label18: TLabel;
    cbStartupSugarPM: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure cbEnableDubleLineClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure cbEnableSelectionClick(Sender: TObject);
    procedure TreeViewChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure TreeViewCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure cbEnableClipboardClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbUsePMClick(Sender: TObject);
  private
    procedure EnabledDubleLine(aValue: Boolean);
    procedure EnabledSelection(aValue: Boolean);
    procedure EnabledClipboard(aValue: Boolean);

    procedure SetPageSetting(aPage: Integer);
    procedure SaveSetting;
    procedure InitTree;
  public
    class function ShowSetting: Boolean;
  end;

implementation

{$R *.dfm}

uses
  uFrmHelp
  , uSetting
  , Menus
  , uThreadUpdate
  , Utils
  , uWizardManager;

procedure TSettingFrm.cbEnableClipboardClick(Sender: TObject);
begin
  EnabledClipboard(cbEnableClipboard.Checked);
end;

procedure TSettingFrm.cbEnableDubleLineClick(Sender: TObject);
begin
  EnabledDubleLine(cbEnableDubleLine.Checked);
end;

procedure TSettingFrm.cbEnableSelectionClick(Sender: TObject);
begin
  EnabledSelection(cbEnableSelection.Checked);
end;

procedure TSettingFrm.cbUsePMClick(Sender: TObject);
begin
  cbIgnoreProject1.Enabled := cbUsePM.Checked;
  cbIgnoreDefaultPath.Enabled := cbUsePM.Checked;
end;

procedure TSettingFrm.EnabledClipboard(aValue: Boolean);
begin
  Label10.Enabled := aValue;
  Label11.Enabled := aValue;
  Label12.Enabled := aValue;
  hkClipboard.Enabled := aValue;
  hkClipboardCopyItem.Enabled := aValue;
  seClipboardSlot.Enabled := aValue;
  cbOSClipboard.Enabled := aValue;
end;

procedure TSettingFrm.EnabledDubleLine(aValue: Boolean);
begin
  Label1.Enabled := aValue;
  hkDubleLine.Enabled := aValue;
end;

procedure TSettingFrm.EnabledSelection(aValue: Boolean);
begin
  Label2.Enabled := aValue;
  Label5.Enabled := aValue;
  hkSelection.Enabled := aValue;
  hkDeselection.Enabled := aValue;
end;

procedure TSettingFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TSettingFrm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Screen.ActiveControl is THotKey then
  begin
    if (Key in [VK_RETURN, VK_SPACE, VK_BACK]) then
      (Screen.ActiveControl as THotKey).HotKey := ShortCut(Key, Shift);

    Key := 0;
    Shift := [];
  end;
end;

procedure TSettingFrm.InitTree;
var
  LEditorNode: TTreeNode;
begin
  LEditorNode := TreeView.Items.Add(nil, 'Editor');
  TreeView.Items.AddChildObject(LEditorNode, 'Dublication Line(s)', TObject(0));
  TreeView.Items.AddChildObject(LEditorNode, 'Selection block', TObject(1));
  TreeView.Items.AddChildObject(LEditorNode, 'History clipboard', TObject(2));

  TreeView.Items.AddObject(nil, 'Other', TObject(3));
end;

procedure TSettingFrm.Label3Click(Sender: TObject);
begin
  if Sender = Label3 then TfrmHelp.ShowHelp(hDuplicate) else
  if Sender = Label4 then TfrmHelp.ShowHelp(hSelect) else
  if Sender = Label8 then TfrmHelp.ShowHelp(hMultiBuffer);
end;

procedure TSettingFrm.SaveSetting;
begin
  TSetting.GetInstance.DuplicateLineEnable := cbEnableDubleLine.Checked;
  TSetting.GetInstance.DupleLineHotKey := hkDubleLine.HotKey;

  TSetting.GetInstance.SelectionEnable := cbEnableSelection.Checked;
  TSetting.GetInstance.SelectionShortKey := hkSelection.HotKey;
  TSetting.GetInstance.DeSelectionShortKey := hkDeselection.HotKey;

  TSetting.GetInstance.ClipboardEnable := cbEnableClipboard.Checked;
  TSetting.GetInstance.ClipboardStorageSlots := seClipboardSlot.Value;
  TSetting.GetInstance.ClipboardShortKey := hkClipboard.HotKey;
  TSetting.GetInstance.ClipboardToShortKey := hkClipboardCopyItem.HotKey;
  TSetting.GetInstance.UseOSClipboard := cbOSClipboard.Checked;

  TSetting.GetInstance.AutoUpdate := cbAutoUpdate.Checked;
  TSetting.GetInstance.AllVersionsUpdate := cbAllVersionsUpdate.Checked;
  TSetting.GetInstance.UseEnglishKeyboard := cbEnglishKeyboard.Checked;
  TSetting.GetInstance.UseProjectManager := cbUsePM.Checked;
  TSetting.GetInstance.StartupProjectManagerWithWindows := cbStartupSugarPM.Checked;
  TSetting.GetInstance.UseIgnoreProjectNameLikeProject1 := cbIgnoreProject1.Checked;
  TSetting.GetInstance.UseIgnoreDefaultProjectPath := cbIgnoreDefaultPath.Checked;
end;

procedure TSettingFrm.SetPageSetting(aPage: Integer);
begin
  case aPage of
    0: begin
         cbEnableDubleLine.Checked := TSetting.GetInstance.DuplicateLineEnable;
         hkDubleLine.HotKey := TSetting.GetInstance.DupleLineHotKey;
       end;

    1: begin
         cbEnableSelection.Checked := TSetting.GetInstance.SelectionEnable;
         hkSelection.HotKey := TSetting.GetInstance.SelectionShortKey;
         hkDeselection.HotKey := TSetting.GetInstance.DeSelectionShortKey;
       end;

    2: begin
         cbEnableClipboard.Checked := TSetting.GetInstance.ClipboardEnable;
         seClipboardSlot.Value := TSetting.GetInstance.ClipboardStorageSlots;
         hkClipboard.HotKey := TSetting.GetInstance.ClipboardShortKey;
         hkClipboardCopyItem.HotKey := TSetting.GetInstance.ClipboardToShortKey;
         cbOSClipboard.Checked := TSetting.GetInstance.UseOSClipboard;
       end;

    3: begin
         cbAutoUpdate.Checked := TSetting.GetInstance.AutoUpdate;
         cbAllVersionsUpdate.Checked := TSetting.GetInstance.AllVersionsUpdate;
         cbEnglishKeyboard.Checked := TSetting.GetInstance.UseEnglishKeyboard;
         cbUsePM.Checked := TSetting.GetInstance.UseProjectManager;
         Label18.Visible := not FileExists(TUtils.GetHomePath + '\Sugar for Delphi\SugarPM.exe');
         cbStartupSugarPM.Enabled := not Label18.Visible;
         cbStartupSugarPM.Checked := TSetting.GetInstance.StartupProjectManagerWithWindows;
         cbIgnoreProject1.Checked := TSetting.GetInstance.UseIgnoreProjectNameLikeProject1;
         cbIgnoreDefaultPath.Checked := TSetting.GetInstance.UseIgnoreDefaultProjectPath;
       end;
  end;
end;

class function TSettingFrm.ShowSetting: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSettingFrm.ShowSetting');
  {$ENDIF}

  with TSettingFrm.Create(nil) do
  try
    InitTree;

    TreeView.FullExpand;
    TreeView.Items[1].Selected := True;
    Notebook.PageIndex := 0;
    
    Result := ShowModal = mrOk;

    if Result then
    begin
      if cbUsePM.Checked
        and not FileExists(TUtils.GetHomePath + '\Sugar for Delphi\SugarPM.exe')
      then
        TThreadUpdate.RunDownloadMP;

      SaveSetting;
      varWizardManager.UpdateShortKey;
    end;
  finally
    Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSettingFrm.ShowSetting');
  {$ENDIF}
end;

procedure TSettingFrm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  Notebook.PageIndex := Integer(Node.Data);
end;

procedure TSettingFrm.TreeViewChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  AllowChange := Node.getFirstChild = nil;

  if AllowChange then
    SetPageSetting(Integer(Node.Data));
end;

procedure TSettingFrm.TreeViewCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  AllowCollapse := False;
end;

end.
