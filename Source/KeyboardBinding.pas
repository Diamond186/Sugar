{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q-,R-,S-,T-,U-,V+,W+,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit KeyboardBinding;

interface

{$I Compiler.inc}

uses
  Windows,
  ToolsAPI
  , SysUtils
  , SelectBlockCodeU
  , Classes
  ;

const                
  strKeyboardName = 'SugarPlugin';

type
  TKeyBinding = Class(TNotifierObject, IUnknown, IOTANotifier, IOTAKeyboardBinding)
    private
      FSelectBlockCode: TSelectBlockCode;
    
      // Ctrl+D
      procedure DupLine(Const Context: IOTAKeyContext; KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);
      // Ctrl+W
      procedure SelectBlockCode(Const Context: IOTAKeyContext; KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);
      // Ctrl+Shift+W
      procedure DeSelectBlockCode(Const Context: IOTAKeyContext; KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);
      // Alt+V
      procedure GetToMultiClipboard(Const Context: IOTAKeyContext; KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);

      {$IFDEF DEBUG}
      // Alt+ENTER
      procedure ContextMenu(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
      // Alt+J
      procedure MultiCursor(Const Context: IOTAKeyContext; KeyCode: TShortcut; Var BindingResult: TKeyBindingResult);
      {$ENDIF}

      function GetCaretPosition(var Pt: TPoint): Boolean;
    public
      constructor Create;
      destructor Destroy; override;

      { IOTAKeyboardBinding }
      procedure BindKeyboard(Const BindingServices: IOTAKeyBindingServices);
      function GetBindingType: TBindingType;
      function GetDisplayName: String;
      function GetName: String;

      class procedure OutputMessage(const strText: String);
  End;

implementation

uses
  //Dialogs, frmContextMenu,
   uSetting
  , frmMultiClipboard
  , Utils
  , Menus
  , uWizardManager
  , uMessageEditor
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

const
  strIDENotifierMessages = 'Debug Suger Messages';

{ TKeybinding }

class procedure TKeybinding.OutputMessage(const strText: String);
{$IFDEF D2006}
var
  Group: IOTAMessageGroup;
{$ENDIF}
Begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.OutputMessage');
  {$ENDIF}

  {$IFDEF D2006}
  With (BorlandIDEServices As IOTAMessageServices) Do
  Begin
    Group := GetGroup(strIDENotifierMessages);

    If Group = Nil Then
      Group := AddMessageGroup(strIDENotifierMessages);

    AddTitleMessage(strText, Group);
  End;
  {$ELSE}
  (BorlandIDEServices As IOTAMessageServices).AddTitleMessage(strText);
  {$ENDIF}

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.OutputMessage');
  {$ENDIF}
end;

{$IFDEF DEBUG}
procedure TKeyBinding.ContextMenu(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
var
  foo: TPoint;
  ListItem: TStringList;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.ContextMenu');
  {$ENDIF}

  TKeyBinding.OutputMessage('ContextMenu');

  ListItem := TStringList.Create;
  try
    ListItem.Add('ñòðîêà 1');
    ListItem.Add('ñò 22');
    ListItem.Add('ñòzssfd.kdsjkuAHdjAGðîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');
    ListItem.Add('ñòzssfd.kdsjîêà 3554');

    GetCaretPos(foo);

//    TfrmMenu.showMenu('create variable', foo, ListItem,
//      procedure(aItem: TArray<Integer>)
//      begin
//        if Length(aItem) >= 0 then
//        begin
//          TKeyBinding.OutputMessage(aItem[0].ToString);
//        end;
//      end);
  finally
    ListItem.Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.ContextMenu');
  {$ENDIF}
end;
{$ENDIF}

procedure TKeyBinding.DeSelectBlockCode(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.DeSelectBlockCode');
  {$ENDIF}

  if Assigned(FSelectBlockCode) then
    FSelectBlockCode.DeSelectBlockCode(Context.EditBuffer);

  BindingResult := krHandled;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.DeSelectBlockCode');
  {$ENDIF}
end;

destructor TKeyBinding.Destroy;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.Destroy');
  {$ENDIF}

  if FSelectBlockCode <> nil then
    FreeAndNil(FSelectBlockCode);
  //varWizardManager.RemoveKeyBinding;

  //inherited;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.Destroy');
  {$ENDIF}
end;

procedure TKeybinding.DupLine(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
var
  EditPosition: IOTAEditPosition;
  EditBlock: IOTAEditBlock;
  CurrentRowEnd: Integer;
  BlockSize: Integer;
  IsAutoIndent: Boolean;
  CodeLine: String;
  CP: TOTAEditPos;
Begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.DupLine');
  {$ENDIF}

  EditPosition := Context.EditBuffer.EditPosition;
  EditBlock := Context.EditBuffer.EditBlock;
  //Save the current edit block and edit position
  EditBlock.Save;
  EditPosition.Save;
  try
    CP := Context.EditBuffer.EditViews[0].CursorPos;

    // Length of the selected block (0 means no block)
    BlockSize := EditBlock.Size;
    // Store AutoIndent property
    IsAutoIndent := Context.EditBuffer.BufferOptions.AutoIndent;
    // Turn off AutoIndent, if necessary
    if IsAutoIndent then
      Context.EditBuffer.BufferOptions.AutoIndent := False;

    try
      // If no block is selected, or the selected block is a single line,
      // then duplicate just the current line
      if (BlockSize = 0)
          or ((EditBlock.StartingRow = EditPosition.Row) and (EditBlock.EndingRow = EditPosition.Row))
//         or ((BlockSize <> 0)
//             and ((EditBlock.StartingRow + 1) =(EditPosition.Row))
//             and (EditBlock.EndingColumn = 1))
      then
      begin
        //Only a single line to duplicate
        //Move to end of current line
        EditPosition.MoveEOL;
        //Get the column position
        CurrentRowEnd := EditPosition.Column;
        //Move to beginning of current line
        EditPosition.MoveBOL;
        //Get the text of the current line, less the EOL marker
        CodeLine := EditPosition.Read(CurrentRowEnd - 1) + #10#13;
        if Trim(CodeLine) = EmptyStr then Exit;
        //Insert the copied line
        EditPosition.InsertText(CodeLine);
        // set cursor to new line
        CP.Line := CP.Line + 1;
      end
      else
      begin
        // More than one line selected. Get block text
        CodeLine := Editblock.Text;

        if Trim(CodeLine) = EmptyStr then Exit;

        if EditBlock.StartingRow > EditBlock.EndingRow then
        begin
          CP.Col := Smallint(EditBlock.StartingColumn);
          CP.Line := EditBlock.StartingRow;
        end
        else
        begin
          CP.Col := Smallint(EditBlock.EndingColumn);
          CP.Line := EditBlock.EndingRow;
        end;

        // Move to the end of the block
        EditPosition.Move(CP.Line, CP.Col);
        //Insert block text
        EditPosition.InsertText(CodeLine);
      end;
    finally
      // Restore AutoIndent, if necessary
      if IsAutoIndent then
        Context.EditBuffer.BufferOptions.AutoIndent := True;

      BindingResult := krHandled;
    end;
  finally
    EditPosition.Move(CP.Line, CP.Col);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.DupLine');
  {$ENDIF}
end;

procedure TKeybinding.BindKeyboard(const BindingServices: IOTAKeyBindingServices);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.BindKeyboard');
  {$ENDIF}

  try
    if TSetting.GetInstance.DuplicateLineEnable then
      BindingServices.AddKeyBinding([TSetting.GetInstance.DupleLineHotKey], DupLine, nil);

    if TSetting.GetInstance.SelectionEnable then
    begin
      BindingServices.AddKeyBinding([TSetting.GetInstance.SelectionShortKey], SelectBlockCode, nil);
      BindingServices.AddKeyBinding([TSetting.GetInstance.DeSelectionShortKey], DeSelectBlockCode, nil);
    end;

    if TSetting.GetInstance.ClipboardEnable then
      BindingServices.AddKeyBinding([TSetting.GetInstance.ClipboardShortKey], GetToMultiClipboard, nil);
  except
    on E: Exception do
    begin
      // ignore exception
    end;
  end;

  {$IFDEF DEBUG}
  //BindingServices.AddKeyBinding([ShortCut(VK_RETURN, [ssAlt])], ContextMenu, Nil);
  //BindingServices.AddKeyBinding([TextToShortCut('Alt+J')], MultiCursor, Nil);
  {$ENDIF}

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.BindKeyboard');
  {$ENDIF}
end;

function TKeybinding.GetBindingType: TBindingType;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.GetBindingType');
  {$ENDIF}

  Result := btPartial;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.GetBindingType');
  {$ENDIF}
end;

function TKeyBinding.GetCaretPosition(var Pt: TPoint): Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.GetCaretPosition');
  {$ENDIF}

  Result := Windows.GetCaretPos(Pt);

  if Result then
  begin
    Windows.ClientToScreen(Windows.GetFocus(), Pt);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.GetCaretPosition');
  {$ENDIF}
end;

function TKeybinding.GetDisplayName: String;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.GetDisplayName');
  {$ENDIF}

  Result := 'Sugar Keybindings';

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.GetDisplayName');
  {$ENDIF}
end;

function TKeybinding.GetName: String;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.GetName');
  {$ENDIF}

  Result := strKeyboardName;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.GetName');
  {$ENDIF}
end;

procedure TKeyBinding.GetToMultiClipboard(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
var
  LPos: TPoint;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.GetToMultiClipboard');
  {$ENDIF}

  GetCaretPosition(LPos);
  TMultiClipboardFrm.ShowMultiClipboard(LPos, Context.EditBuffer);

  BindingResult := krHandled;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.GetToMultiClipboard');
  {$ENDIF}
end;

{$IFDEF DEBUG}
procedure TKeyBinding.MultiCursor(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.MultiCursor');
  {$ENDIF}

  TKeybinding.OutputMessage('BeforeSave');
  SelectBlockCode(Context, KeyCode, BindingResult);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.MultiCursor');
  {$ENDIF}
end;
{$ENDIF}

procedure TKeyBinding.SelectBlockCode(const Context: IOTAKeyContext; KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TKeybinding.SelectBlockCode');
  {$ENDIF}

  if not Assigned(FSelectBlockCode) then
    FSelectBlockCode := TSelectBlockCode.Create;

    FSelectBlockCode.SelectBlockCode(Context.EditBuffer);

  BindingResult := krHandled;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TKeybinding.SelectBlockCode');
  {$ENDIF}
end;

constructor TKeyBinding.Create;
begin
  FSelectBlockCode := nil;
end;

end.
