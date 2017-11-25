unit frmMultiClipboard;

interface

{$I Compiler.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, ToolsAPI,
  Controls, Forms, VirtualTrees, uMultiClipboard
  ;

type
  TMultiClipboardFrm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    FClipboardViewer: THandle;
    FMultiClipboard: TMultiClipboard;
    FTree: TVirtualStringTree;
    FEditBuffer: IOTAEditBuffer;

    procedure CreateTree;
    procedure CalcHeight;
    procedure DeleteItem(aNode: PVirtualNode);
    procedure InsertSelectedText(const aText: string);

    procedure DoGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                        TextType: TVSTTextType; var CellText: UnicodeString);
    procedure DoGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                              var Ghosted: Boolean; var ImageIndex: Integer);
    procedure DoColumnClick(Sender: TBaseVirtualTree; Column: TColumnIndex; Shift: TShiftState);
    procedure DoBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
                                Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);

//    function GetCurrentEditWindow: TCustomForm;

    // clipboard
    procedure WMChangeCBChain(var msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipBoard(var msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
  public
    class procedure ShowMultiClipboard(aPos: TPoint; aEditBuffer: IOTAEditBuffer);
    class procedure CreateForm;
    class procedure DestroyForm;
    class function  ActiveClipboardViewer: Boolean;
  end;

  {TVTBeforeCellPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect) of object;
  TVTAfterCellPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; CellRect: TRect) of object;}

implementation

{$R *.dfm}

uses
  uSetting
  , Utils
  , Math
  , uWizardManager
  , Clipbrd
  , StdCtrls
  , Menus
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
//  , dialogs
  ;

const
  cLineHeight = 16;
  cInvalideClipboardViewer = 99999999;

var
  frm: TMultiClipboardFrm;

{ TMultiClipboardFrm }

class function TMultiClipboardFrm.ActiveClipboardViewer: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.ActiveClipboardViewer');
  {$ENDIF}

  if Assigned(frm) then
    frm.FClipboardViewer := SetClipboardViewer(frm.Handle);

  Result := frm.FClipboardViewer <> cInvalideClipboardViewer;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.ActiveClipboardViewer');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.CalcHeight;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.CalcHeight');
  {$ENDIF}

  Height := FMultiClipboard.Count * Integer(FTree.DefaultNodeHeight) + FMultiClipboard.Count;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.CalcHeight');
  {$ENDIF}
end;

class procedure TMultiClipboardFrm.CreateForm;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.CreateForm');
  {$ENDIF}

  frm := TMultiClipboardFrm.Create(nil);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.CreateForm');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.CreateTree;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.CreateTree');
  {$ENDIF}

  FTree := TVirtualStringTree.Create(Self);
  FTree.Parent := Self;
  FTree.Align := alClient;
  FTree.BorderStyle := bsNone;
  FTree.NodeDataSize := SizeOf(TClipboardItem);
  FTree.RootNodeCount :=  Cardinal(FMultiClipboard.Count);
  FTree.Images := varWizardManager.GetImages;

  FTree.OnGetText := DoGetText;
  FTree.OnGetImageIndex := DoGetImageIndex;
  FTree.OnColumnClick := DoColumnClick;
  FTree.OnBeforeCellPaint := DoBeforeCellPaint;

  FTree.TreeOptions.PaintOptions := FTree.TreeOptions.PaintOptions - [toShowRoot];
  FTree.TreeOptions.PaintOptions := FTree.TreeOptions.PaintOptions + [toShowHorzGridLines];
  FTree.TreeOptions.SelectionOptions := FTree.TreeOptions.SelectionOptions + [toFullRowSelect];
  FTree.ScrollBarOptions.ScrollBars := ssNone;

  with FTree.Header.Columns.Add do
  begin
    Width := 20;
    MaxWidth := 20;
    MinWidth := 20;
    Alignment := taLeftJustify;
  end;

  with FTree.Header.Columns.Add do
  begin
    Alignment := taLeftJustify;
    MaxWidth := 750;
    MinWidth := 100;
  end;

  with FTree.Header.Columns.Add do
  begin
    Width := 20;
    MaxWidth := 20;
    MinWidth := 20;
    Alignment := taRightJustify;
  end;

  FTree.Header.MainColumn := 1;
  FTree.Header.Options := FTree.Header.Options + [hoAutoResize];

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.CreateTree');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.DeleteItem(aNode: PVirtualNode);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.DeleteItem');
  {$ENDIF}

  if Assigned(aNode) then
  begin
    FTree.BeginSynch;
    FTree.BeginUpdate;

    try
      FTree.FocusedNode := nil;
      FMultiClipboard.Delete(Integer(aNode.Index));
      FTree.DeleteNode(aNode);

      if FTree.RootNodeCount = 0 then
        Hide
      else
        CalcHeight;
    finally
      FTree.EndUpdate;
      FTree.EndSynch;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.DeleteItem');
  {$ENDIF}
end;

class procedure TMultiClipboardFrm.DestroyForm;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.DestroyForm');
  {$ENDIF}

  if frm <> nil then
    FreeAndNil(frm);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.DestroyForm');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.DoBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.DoBeforeCellPaint');
  {$ENDIF}

  if Column in [1, 3] then
    TargetCanvas.Brush.Color := clWhite;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.DoBeforeCellPaint');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.DoColumnClick(Sender: TBaseVirtualTree;
  Column: TColumnIndex; Shift: TShiftState);
var
  LNode: PVirtualNode;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.DoColumnClick');
  {$ENDIF}

  LNode := FTree.FocusedNode;

  if Assigned(LNode) then
  case Column of
    0: begin
         FMultiClipboard.Lock[Integer(LNode.Index)] := not FMultiClipboard.Lock[Integer(LNode.Index)];
         FTree.RepaintNode(LNode);
       end;

    1: begin
         InsertSelectedText(FMultiClipboard.Text[Integer(LNode.Index)]);
//         FEditBuffer.EditPosition.InsertText(FList.Text[Integer(LNode.Index)]);
         Hide;
       end;

    2: //if MessageBoxEx(Handle, PChar('Do you sure want to delete ?'), '',  MB_YESNO + MB_ICONQUESTION, LANG_ENGLISH) = IDYES then
       begin
         DeleteItem(LNode);
       end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.DoColumnClick');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.DoGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.DoGetImageIndex');
  {$ENDIF}

  if Kind in [ikNormal, ikSelected] then
  case Column of
    0: begin
         ImageIndex := 1;

         if Assigned(Node) and FMultiClipboard.Lock[Integer(Node.Index)] then
           ImageIndex := 0;
       end;

    2: ImageIndex := 2;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.DoGetImageIndex');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.DoGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: UnicodeString);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.DoGetText');
  {$ENDIF}

  if Assigned(Node) and (Column = 1) then
    CellText := FMultiClipboard.Text[Integer(Node.Index)]
  else
    CellText := EmptyStr;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.DoGetText');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.FormCreate(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.FormCreate');
  {$ENDIF}

  FClipboardViewer := cInvalideClipboardViewer;
  FMultiClipboard := TMultiClipboard.Create;
  CreateTree;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.FormCreate');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.FormDeactivate(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.FormDeactivate');
  {$ENDIF}

  Hide;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.FormDeactivate');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.FormDestroy(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.FormDestroy');
  {$ENDIF}

  if FClipboardViewer > 0 then
  begin
    ChangeClipboardChain(Handle, FClipboardViewer);
    FClipboardViewer := 0;
  end;

  try
    FMultiClipboard.Clear;
    FreeAndNil(FMultiClipboard);
  except
//    ShowMessage('зламалося');
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.FormDestroy');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.FormHide(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.FormHide');
  {$ENDIF}

  FEditBuffer := nil;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.FormHide');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  LNode: PVirtualNode;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.FormKeyDown');
  {$ENDIF}

  if Key = VK_ESCAPE then
    Hide
  else
  if ShortCut(Key, Shift) = TSetting.GetInstance.ClipboardToShortKey
  then
  begin
    LNode := FTree.FocusedNode;

    if Assigned(LNode) then
    begin
      InsertSelectedText(FMultiClipboard.Text[Integer(LNode.Index)]);
      Clipboard.AsText := FMultiClipboard.Text[Integer(LNode.Index)];
    end;

    Hide;
  end
  else
  if (Key = VK_RETURN)
    and (Shift = [])
  then
  begin
    LNode := FTree.FocusedNode;

    if Assigned(LNode) then
      InsertSelectedText(FMultiClipboard.Text[Integer(LNode.Index)]);

    Hide;
  end else
  if Key = VK_LEFT then
  begin
    LNode := FTree.FocusedNode;

    if Assigned(LNode) then
    begin
      FMultiClipboard.Lock[Integer(LNode.Index)] := True;
      FTree.RepaintNode(LNode);
    end;
  end else
  if Key = VK_RIGHT then
  begin
    LNode := FTree.FocusedNode;

    if Assigned(LNode) then
    begin
      if FMultiClipboard.Lock[Integer(LNode.Index)] then
        FMultiClipboard.Lock[Integer(LNode.Index)] := False
      else
        DeleteItem(LNode);

      FTree.RepaintNode(LNode);
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.FormKeyDown');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.InsertSelectedText(const aText: string);
var
  LList: TStringList;
  i: Integer;
  LView: IOTAEditView;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.InsertSelectedText');
  {$ENDIF}

  LList := TStringList.Create;
  try
    LList.Text := aText;
    LView := FEditBuffer.TopView;

    for i := 0 to LList.Count - 1 do
    begin
      if i > 0 then
      begin
        FEditBuffer.EditPosition.InsertText(#10#13);
        FEditBuffer.EditPosition.MoveBOL;
      end;

      FEditBuffer.EditPosition.InsertText(LList[i]);

      LView.MoveViewToCursor;
      LView.Paint;

//      FEditBuffer.EditPosition.Save;
    end;
  finally
    LList.Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.InsertSelectedText');
  {$ENDIF}
end;

//function TMultiClipboardFrm.GetCurrentEditWindow: TCustomForm;
//var
//  EditView: IOTAEditView;
//  EditWindow: INTAEditWindow;
//begin
//  EditView := FEditBuffer.TopView;
//
//  if Assigned(EditView) then
//  begin
//    EditWindow := EditView.GetEditWindow;
//
//    if Assigned(EditWindow) then
//    begin
//      Result := EditWindow.Form;
//      Exit;
//    end;
//  end;
//
//  Result := nil;
//end;

class procedure TMultiClipboardFrm.ShowMultiClipboard(aPos: TPoint; aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.ShowMultiClipboard');
  {$ENDIF}

  if frm = nil then Exit;

  with frm do
  if (FMultiClipboard.Count > 0) and Assigned(aEditBuffer) then
  begin
    FMultiClipboard.Sort;
//
    FEditBuffer := aEditBuffer;
//
////    LForm := GetCurrentEditWindow;
////    if Assigned(LForm) and Assigned(LForm.Monitor) then
////      with LForm.Monitor do
////        LWorkRect := Bounds(Left, Top, Width, Height)
////    else
////      LWorkRect := Bounds(0, 0, Screen.Width, Screen.Height);
////
////    if aPos.x + FTree.Width <= LWorkRect.Right then
////      Left := aPos.x
////    else
////      Left := Max(aPos.x - FTree.Width, LWorkRect.Left);
////
////    if aPos.y + cLineHeight + FTree.Height <= LWorkRect.Bottom then
////      Top := aPos.y + cLineHeight
////    else
////      Top := Max(aPos.y - FTree.Height - cLineHeight div 2, LWorkRect.Top);
//
    Left := aPos.X + 5;
    Top := aPos.Y + cLineHeight;
////    Left := aPos.X + 50;
////    Top := aPos.Y + 180;

    FTree.Clear;
    for i := 0 to FMultiClipboard.Count - 1 do
      FTree.AddChild(nil);

    FTree.BeginUpdate;
    FTree.Header.AutoFitColumns;
    FTree.EndUpdate;

    Width := FTree.Header.Columns.TotalWidth;
    CalcHeight;

    Show;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.ShowMultiClipboard');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.WMChangeCBChain(var msg: TWMChangeCBChain);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.WMChangeCBChain');
  {$ENDIF}

  if msg.Remove = FClipboardViewer then
    FClipboardViewer := msg.Next
  else if FClipboardViewer > 0 then
    SendMessage(FClipboardViewer, WM_CHANGECBCHAIN, msg.Remove, msg.Next);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.WMChangeCBChain');
  {$ENDIF}
end;

procedure TMultiClipboardFrm.WMDrawClipBoard(var msg: TWMDrawClipboard);
var
  Handle: THandle;
  DataSize: Cardinal;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboardFrm.WMDrawClipBoard');
  {$ENDIF}

  if (TSetting.GetInstance.UseOSClipboard
    or Application.Active)
    and ClipBoard.HasFormat(CF_TEXT)
  then
  try
    Clipboard.Open;

    try
      Handle := Clipboard.GetAsHandle(CF_TEXT);
      DataSize := GlobalSize(Handle);  // This function might over-estimate by a few bytes
    finally
      Clipboard.Close;
    end;

    // Don't try to save clipboard items over 512 KB for speed reasons
    if DataSize > ((1024 * 512) + 32) then
      Exit;

    FMultiClipboard.Add(ClipBoard.AsText);
  except
    on E: Exception do
    begin
      // Ignore exceptions
    end;
  end;

  if FClipboardViewer > 0 then
  begin
    SendMessage(FClipboardViewer, WM_DRAWCLIPBOARD, 0, 0);
    msg.Result := 0;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboardFrm.WMDrawClipBoard');
  {$ENDIF}
end;

end.
