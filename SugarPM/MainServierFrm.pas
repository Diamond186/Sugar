unit MainServierFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, uProjetsJson,
  Vcl.ExtCtrls, System.Actions, Vcl.ActnList, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls, System.ImageList, Vcl.ImgList,
  VirtualTrees, Vcl.Menus, Winapi.ActiveX, System.Generics.Collections;

type
  TMainPMFrm = class(TForm)
    Bevel: TBevel;
    ActionManager: TActionManager;
    ActionToolBar: TActionToolBar;
    aProjRun: TAction;
    aProjDel: TAction;
    ImageList: TImageList;
    vstProject: TVirtualStringTree;
    aGroupAdd: TAction;
    pmProject: TPopupMenu;
    miProjOpen: TMenuItem;
    miProjRename: TMenuItem;
    miProjDelete: TMenuItem;
    ImageList_disable: TImageList;
    aGroupRename: TAction;
    aGroupDeleteWithProject: TAction;
    aRemoveFromGroup: TAction;
    aAddToGroup: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvProjectClick(Sender: TObject);
    procedure vstProjectGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstProjectNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure aProjRunExecute(Sender: TObject);
    procedure ActionManagerUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure vstProjectGetPopupMenu(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; const P: TPoint; var AskParent: Boolean; var PopupMenu: TPopupMenu);
    // delete project
    procedure aProjDelExecute(Sender: TObject);
    // Create new or rename group
    procedure aGroupAddExecute(Sender: TObject);

    procedure vstProjectExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstProjectCollapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure aGroupDeleteWithProjectExecute(Sender: TObject);
    procedure vstProjectDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure vstProjectDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure vstProjectDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure aRemoveFromGroupExecute(Sender: TObject);
  private
    const
      cRegKey = '\Software\DelphiPluginSugar\SugarPM';
      cDelphiNameIndex = 0;
      cProjectPathIndex = 1;

    var
      FStorage: TProjets;

    procedure SetHeightForm;
    procedure LoadSetting;
    procedure SaveSetting;
    procedure FillDataView;

    procedure AddProject(var Msg: TWMCopyData); message WM_COPYDATA;

    procedure UpdateLastCompile(const aGuid, aDelphi: string);
    procedure RunProject(const aPath, aDelphi: String);
    procedure RunGroupProject(const aNode: PVirtualNode; const aDelphi: string);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public

  end;

  TReadOnlyMemoryStream = class(TStringStream)
  public
    constructor Create(APtr: Pointer; ASize: NativeInt);

    function ReadString(const aCount: Integer): String;
  end;

var
  MainPMFrm: TMainPMFrm;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.Win.Registry, Winapi.ShellAPI, VCL.Dialogs;

procedure TMainPMFrm.ActionManagerUpdate(Action: TBasicAction; var Handled: Boolean);
var
  LNode: PVirtualNode;
begin
  LNode := vstProject.FocusedNode;

  aProjRun.Enabled := Assigned(LNode);
  aProjDel.Enabled := aProjRun.Enabled;

  aGroupAdd.Enabled := aProjRun.Enabled and (LNode.ChildCount = 0) and FStorage[LNode.GetData<string>].GroupName.IsEmpty;

  aGroupRename.Enabled := aProjRun.Enabled;

  aGroupDeleteWithProject.Enabled := aGroupRename.Enabled;

  aAddToGroup.Enabled := Assigned(LNode) and ((LNode.ChildCount > 0) or (LNode.Parent <> nil));

  aRemoveFromGroup.Enabled := Assigned(LNode) and (LNode.Parent <> vstProject.RootNode);
end;

procedure TMainPMFrm.AddProject(var Msg: TWMCopyData);
var
  LDPRFilePath, LDelphiName: string;
  LGuid: string;
  LMemoty: TReadOnlyMemoryStream;
  LList: TStringList;
begin
  LMemoty := TReadOnlyMemoryStream.Create(Msg.CopyDataStruct.lpData, Msg.CopyDataStruct.cbData);
  LList := TStringList.Create;
  try
    LList.Text := LMemoty.ReadString(Msg.CopyDataStruct.cbData);

    LDelphiName := LList[cDelphiNameIndex];
    LDPRFilePath := LList[cProjectPathIndex];

    LGuid := FStorage.Exists(LDPRFilePath);
    if not LGuid.IsEmpty then
    begin
      UpdateLastCompile(LGuid, LDelphiName);
    end
    else
    begin
      LGuid := FStorage.AddProject(LDPRFilePath, LDelphiName);

      vstProject.AddChild(nil)
                .SetData<string>(LGuid);

      SetHeightForm;
    end;
  finally
    LList.Free;
    LMemoty.Free;
  end;
end;

// Create new or rename group
procedure TMainPMFrm.aGroupAddExecute(Sender: TObject);
var
  LArr: TArray<string>;
  LNode: PVirtualNode;
begin
  SetLength(LArr, 1);
  LNode := vstProject.FocusedNode;

  if Assigned(LNode) then
  begin
    if LNode.ChildCount > 0 then
      LArr[0] := FStorage[LNode.FirstChild.GetData<string>].GroupName;

    if InputQuery(EmptyStr, ['Group name'], LArr,
      function(const Values: array of string): Boolean
      begin
        Result := not Values[0].IsEmpty;
      end) then
    begin
      if LNode.ChildCount > 0 then
      begin
        // rename group
        FStorage.GroupRemane(LArr[0], LNode.FirstChild.Index);
        vstProject.ReinitNode(LNode, False);
      end
      else
      begin
        // add new group
        FStorage.GroupRemane(LArr[0], LNode.Index);
        vstProject.NodeParent[LNode] := vstProject.AddChild(nil);
      end;
    end;
  end;
end;

procedure TMainPMFrm.aGroupDeleteWithProjectExecute(Sender: TObject);
const
  cText = 'Are you sure to delete "%s" from list?';
var
  LNode: PVirtualNode;
begin
  LNode := vstProject.FocusedNode;

  if Assigned(LNode) and (LNode.ChildCount > 0) then
    if MessageBox(Handle, PChar(Format(cText, [FStorage[LNode.FirstChild.GetData<string>].Name])), '', MB_YESNO + MB_ICONQUESTION) = ID_YES then
    begin
      FStorage.GroupDelete(LNode.FirstChild.GetData<string>);

      vstProject.DeleteNode(LNode);
      vstProject.ReinitNode(nil, False);
      vstProject.Repaint;
    end;
end;

// delete project
procedure TMainPMFrm.aProjDelExecute(Sender: TObject);
const
  cText = 'Are you sure to delete "%s" from list?';
var
  LNode, LNodeChild: PVirtualNode;
begin
  LNode := vstProject.FocusedNode;

  if Assigned(LNode) then
  begin
    if LNode.ChildCount = 0 then
      if MessageBox(Handle, PChar(Format(cText, [FStorage[LNode.GetData<string>].Name])), '', MB_YESNO + MB_ICONQUESTION) = ID_YES then
      begin
        FStorage.Detete(LNode.Index);
        vstProject.DeleteNode(LNode);
      end;

    if LNode.ChildCount > 0 then
      if MessageBox(Handle, PChar(Format(cText, [FStorage[LNode.FirstChild.GetData<string>].Name])), '', MB_YESNO + MB_ICONQUESTION) = ID_YES then
      begin
        FStorage.GroupDelete(LNode.FirstChild.GetData<string>);

        LNodeChild := LNode.FirstChild;
        while Assigned(LNodeChild) do
        begin
          vstProject.MoveTo(LNodeChild, nil, amAddChildLast, True);

          LNodeChild := LNodeChild.NextSibling;
        end;

        vstProject.DeleteNode(LNode);
        vstProject.ReinitNode(nil, False);
        vstProject.Repaint;
      end;
  end;
end;

procedure TMainPMFrm.aProjRunExecute(Sender: TObject);
var
  LNode: PVirtualNode;
begin
  LNode := vstProject.FocusedNode;

  if Assigned(LNode) then
    if LNode.ChildCount = 0 then
      RunProject(FStorage[LNode.GetData<string>].Path, FStorage[LNode.GetData<string>].Delphi)
    else
      RunGroupProject(LNode, FStorage[LNode.FirstChild.GetData<string>].Delphi);
end;

procedure TMainPMFrm.aRemoveFromGroupExecute(Sender: TObject);
var
  LNode, LGroupNode: PVirtualNode;
  LCount: Integer;
begin
  LNode := vstProject.FocusedNode;

  if Assigned(LNode) then
  begin
    LGroupNode := LNode.Parent;
    LCount := LGroupNode.ChildCount;

    vstProject.MoveTo(LNode, vstProject.RootNode, amAddChildLast, False);

    if LCount = 1 then
      vstProject.DeleteNode(LGroupNode);

    FStorage.RemoveProjectFromGroup(LNode.GetData<string>);
  end;
end;

procedure TMainPMFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  with Params do
  begin
//    Style := Style or TVS_NOSCROLL;
    WndParent := GetDesktopWindow;
  end;
end;

procedure TMainPMFrm.FillDataView;
var
  LGroupList: TDictionary<string, PVirtualNode>;
  LNode: PVirtualNode;
  i: Integer;
  LList: TStringList;
  LProj: TProject;
begin
  LGroupList := TDictionary<string, PVirtualNode>.Create;
  LList := TStringList.Create;
  try
    FStorage.ReadSections(LList);

    for i := 0 to LList.Count - 1 do
    begin
      LProj := FStorage[LList[i]];

      if LProj.GroupID.IsEmpty then
        LNode := vstProject.AddChild(nil)
      else
      begin
        if not LGroupList.TryGetValue(LProj.GroupID, LNode) then
        begin
          // create group node
          LNode := vstProject.AddChild(nil);

          if LProj.GroupExpanded then
            LNode.States := LNode.States + [vsExpanded];

          LGroupList.Add(LProj.GroupID, LNode);
        end;

        LNode := vstProject.AddChild(LNode);
      end;

      LNode.SetData<string>(LProj.ProjID);
    end;
  finally
    LGroupList.Free;
  end;

  SetHeightForm;
end;

procedure TMainPMFrm.FormActivate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);

  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TMainPMFrm.FormCreate(Sender: TObject);
begin
  FStorage := TProjets.LoadFromFile(TPath.GetHomePath + '\Sugar for Delphi\SugarPM.file');
  vstProject.NodeDataSize := SizeOf(ShortString);
  FillDataView;
  LoadSetting;

  {$IFDEF DEBUG}
  BorderIcons := [biSystemMenu];
  {$ENDIF}
end;

procedure TMainPMFrm.FormDestroy(Sender: TObject);
begin
  SaveSetting;
  FreeAndNil(FStorage);
end;

procedure TMainPMFrm.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TMainPMFrm.LoadSetting;
begin
  with TRegistry.Create do
  try
    if not KeyExists(cRegKey) then
    begin
      if Screen.MonitorCount > 0 then
      begin
        Left := Screen.Monitors[0].Width - Width - 10;
        Top := 10;
      end;
    end
    else if OpenKey(cRegKey, True) then
    begin
      Left := ReadInteger('LeftForm');
      Top := ReadInteger('TopForm');
    end;

    if OpenKey(cRegKey, True) then
    begin
      WriteInteger('LeftForm', Left);
      WriteInteger('TopForm', Top);
    end;
  finally
    Free;
  end;
end;

procedure TMainPMFrm.lvProjectClick(Sender: TObject);
begin
  Close;
end;

function TReadOnlyMemoryStream.ReadString(const aCount: Integer): String;
var
  _Bytes: TBytes;
begin
  SetLength(_Bytes, aCount);
  Self.ReadBuffer(PByte(_Bytes)^, aCount);
  Result := TEncoding.UTF8.GetString(_Bytes);
end;

procedure TMainPMFrm.RunGroupProject(const aNode: PVirtualNode; const aDelphi: string);
const
  cDocPath = 'Sugar Project Manager';
var
  LPath: string;
  LList: TStringList;
begin
  if Assigned(aNode) and (aNode.ChildCount > 0) then
  begin
    LPath := TPath.GetDocumentsPath + cDocPath;

    if not TDirectory.Exists(LPath) then
      TDirectory.CreateDirectory(LPath);

    LList := TStringList.Create;
    try

      LList.SaveToFile(LPath + '\' + FStorage[aNode.FirstChild.GetData<string>].GroupName + '.bpg');
    finally
      LList.Free;
    end;
  end;
end;

procedure TMainPMFrm.RunProject(const aPath, aDelphi: String);
var
  LDelphiPath, LKey: string;
  LRun, LParam: PChar;
begin
  if aDelphi = 'D6' then
    LKey := 'SOFTWARE%s\Borland\Delphi\6.0'
  else if aDelphi = 'D7' then
    LKey := 'SOFTWARE%s\Borland\Delphi\7.0'
  else if aDelphi = 'D2005' then
    LKey := 'SOFTWARE%s\Borland\BDS\3.0'
  else if aDelphi = 'D2006' then
    LKey := 'SOFTWARE%s\Borland\BDS\4.0'
  else if aDelphi = 'D2007' then
    LKey := 'SOFTWARE%s\Borland\BDS\5.0'
  else if aDelphi = 'D2009' then
    LKey := 'SOFTWARE%s\CodeGear\BDS\6.0'
  else if aDelphi = 'D2010' then
    LKey := 'SOFTWARE%s\CodeGear\BDS\7.0'
  else if aDelphi = 'XE' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\8.0'
  else if aDelphi = 'XE2' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\9.0'
  else if aDelphi = 'XE3' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\10.0'
  else if aDelphi = 'XE4' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\11.0'
  else if aDelphi = 'XE5' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\12.0'
  else if aDelphi = 'XE6' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\14.0'
  else if aDelphi = 'XE7' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\15.0'
  else if aDelphi = 'XE8' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\16.0'
  else if aDelphi = 'Seattle' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\17.0'
  else if aDelphi = 'Berlin' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\18.0'
  else if aDelphi = 'Tokyo' then
    LKey := 'SOFTWARE%s\Embarcadero\BDS\19.0';

  if TOSVersion.Architecture in [arARM64, arIntelX64] then
    LKey := Format(LKey, ['\WOW6432Node'])
  else
    LKey := Format(LKey, ['']);

  with TRegistry.Create do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly(LKey) then
    begin
      LDelphiPath := ReadString('App');
    end;
  finally
    Free;
  end;

  LRun := PChar('"' + LDelphiPath + '"');
  LParam := PChar('-pDelphi "' + aPath + '"');

  ShellExecute(Handle, 'open', LRun, LParam, nil, SW_SHOWNORMAL);
end;

procedure TMainPMFrm.SaveSetting;
begin
  with TRegistry.Create do
  try
    if OpenKey(cRegKey, True) then
    begin
      WriteInteger('LeftForm', Left);
      WriteInteger('TopForm', Top);
    end;
  finally
    Free;
  end;
end;

procedure TMainPMFrm.SetHeightForm;
var
  LHeight: Integer;
begin
  LHeight := (vstProject.RootNodeCount + 2) * vstProject.DefaultNodeHeight + vstProject.RootNodeCount;

  LHeight := LHeight + ActionToolBar.Height + 8;

  if LHeight > Height then
  begin
    Height := LHeight;
    Constraints.MinHeight := Height;
  end;

  if Constraints.MinHeight = 0 then
    Constraints.MinHeight := Height;
end;

procedure TMainPMFrm.UpdateLastCompile(const aGuid, aDelphi: string);
begin
  FStorage.UpdateProject(aGuid, aDelphi);

  vstProject.ReinitNode(nil, False);
  vstProject.Repaint;
end;

procedure TMainPMFrm.vstProjectCollapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  if Node.ChildCount > 0 then
    FStorage.GroupExpanded(False, Node.FirstChild.Index);
end;

procedure TMainPMFrm.vstProjectDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := Assigned(Node) and (Node.ChildCount = 0);
end;

procedure TMainPMFrm.vstProjectDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  LSource, LTarget, LGroupNode: PVirtualNode;
  LProj: string;
  LIndex: Integer;
  LEmptyGroup: Boolean;
begin
  if Assigned(Source) and (Source is TVirtualStringTree) then
  begin
    LSource := (Source as TVirtualStringTree).FocusedNode;
    LProj := FStorage[LSource.GetData<string>].ProjID;

    LTarget := Sender.DropTargetNode;

    LEmptyGroup := Assigned(LSource) and (LSource.Parent.ChildCount = 1);

    if Assigned(LTarget) then
    begin
      if LTarget.ChildCount = 0 then
      begin
        if LEmptyGroup then
          LGroupNode := LSource.Parent
        else
          LGroupNode := nil;

        Sender.MoveTo(LSource, LTarget, amInsertAfter, False);
        LIndex := LTarget.Index;

        if LEmptyGroup then
        begin
          FStorage.GroupDelete(LSource.GetData<string>);
          Sender.DeleteNode(LGroupNode);
        end;
      end
      else
      begin
        Sender.MoveTo(LSource, LTarget, amAddChildLast, False);
        LIndex := LTarget.FirstChild.Index;
      end;

      FStorage.AddProjectToGroup(LProj, LIndex);
    end;
  end;
end;

procedure TMainPMFrm.vstProjectDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := (Sender = Source) and (Sender.DropTargetNode <> Sender.FocusedNode);
end;

procedure TMainPMFrm.vstProjectExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  if Node.ChildCount > 0 then
    FStorage.GroupExpanded(True, Node.FirstChild.Index);
end;

procedure TMainPMFrm.vstProjectGetPopupMenu(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; const P: TPoint; var AskParent: Boolean; var PopupMenu: TPopupMenu);
begin
  PopupMenu := pmProject;
end;

procedure TMainPMFrm.vstProjectGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LProjID: string;
begin
  LProjID := Node.GetData<string>;

  case Column of
    0:
      if Node.ChildCount > 0 then
        CellText := FStorage[Node.FirstChild.GetData<string>].GroupName
      else if not LProjID.IsEmpty then
        CellText := FStorage[LProjID].Name;

    1:
      if Node.ChildCount > 0 then
        CellText := EmptyStr
      else if not LProjID.IsEmpty then
        CellText := DateTimeToStr(FStorage[LProjID].LastCompile);

    2:
      if Node.ChildCount > 0 then
        CellText := EmptyStr
      else if not LProjID.IsEmpty then
        CellText := FStorage[LProjID].Delphi;
  end;
end;

procedure TMainPMFrm.vstProjectNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
begin
  vstProject.FocusedNode := HitInfo.HitNode;

  with FStorage[HitInfo.HitNode.GetData<string>] do
    RunProject(Path, Delphi);
end;

{ TReadOnlyMemoryStream }

constructor TReadOnlyMemoryStream.Create(APtr: Pointer; ASize: NativeInt);
begin
  inherited Create;

  SetPointer(APtr, ASize);
end;

end.

