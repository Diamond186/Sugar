unit Utils;

interface

{$I Compiler.inc}

uses
  Windows, SysUtils, Graphics, Classes, Forms, ToolsAPI, Controls;

type
  TResourceName = (rnMenu, rnClose, rnLock, rnUnlock, rnDelete, rnDuplicate,
                   rnSelect, rnMultiBuffer, rnSetting, rnAbout, rnAboutMain,
                   rnUpdate);

  TUtils = class
    private
      class function GetResourceName(aIcon: TResourceName): string;
      class function IsLoadModuleRes: Boolean;
      class procedure FreeModuleRes;
      class function FindComponentByClassName(AWinControl: TWinControl;
                                              const AClassName: string;
                                              const AComponentName: string = ''): TComponent;
    public
      class function GetModuleName: string;
      class function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean; overload;
      class function CharInSet(C: WideChar; const CharSet: TSysCharSet): Boolean; overload;
      class procedure LoadIcon(aIcon: TIcon; aName: TResourceName);
      class procedure LoadBitmap(aBitmap: TBitmap; aName: TResourceName);
      class function LoadRCDATAResource(aName: TResourceName): TResourceStream;
      class function GetCurrentVersion: string;
      class function GetNameDelphi: String;
      class function GetHomePath: string;

      class function OtaGetCurrentEditWindow: TCustomForm;
      class function OtaGetTopMostEditView: IOTAEditView;
      class function OtaGetEditBuffer: IOTAEditBuffer;
      class function OtaGetCurrentEditControl: TWinControl;
      class function OtaGetDefaultEditWindow: TWinControl;
      class function IsEditControl(AControl: TComponent): Boolean;
      class function GetTextFromReader(aReader: IOTAEditReader): string;

//      class function VK_ScanCodeToAscii(VKey: Word; Code: Word): AnsiChar;
//      class function ScanCodeToAscii(Code: Word): AnsiChar;
  end;

implementation


uses
   SHFolder
{$IFDEF TestRun}
   , TestRun
{$ENDIF}
  ;

const
  EditControlName = 'Editor';
  EditControlClassName = 'TEditControl';

var
  LModuleRes: THandle = 0;

const
  cModuleResName = 'SugarRes.dll';

{ TUtils }

class function TUtils.CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;

class function TUtils.CharInSet(C: WideChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := (C < #$0100) and (AnsiChar(C) in CharSet);
end;

class function TUtils.OtaGetCurrentEditControl: TWinControl;
var
  LEditWindow: TCustomForm;
  LComp: TComponent;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TUtils.OtaGetCurrentEditControl');
  {$ENDIF}

  Result := nil;
  LEditWindow := OtaGetCurrentEditWindow;

  if LEditWindow <> nil then
  begin
    LComp := FindComponentByClassName(LEditWindow, 'TEditControl', 'Editor');

    if (LComp <> nil) and (LComp is TWinControl) then
      Result := LComp as TWinControl;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TUtils.OtaGetCurrentEditControl');
  {$ENDIF}
end;

class function TUtils.FindComponentByClassName(AWinControl: TWinControl;
  const AClassName, AComponentName: string): TComponent;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to AWinControl.ComponentCount - 1 do
  begin
//    {$IFDEF TestRun}
//    TTestRun.AddMarker('ClassName:' + AWinControl.Components[i].ClassName);
//    TTestRun.AddMarker('Name:' + AWinControl.Components[i].Name);
//    {$ENDIF}

    if AWinControl.Components[i].ClassNameIs(AClassName)
      and ((AComponentName = '') or (SameText(AComponentName, AWinControl.Components[i].Name)))
    then
    begin
      Result := AWinControl.Components[i];
//      {$IFDEF TestRun}
//      TTestRun.AddMarker('ClassName:' + AWinControl.Components[i].ClassName);
//      TTestRun.AddMarker('Name:' + AWinControl.Components[i].Name);
//      {$ENDIF}
      Break;
    end;
  end;
end;

class procedure TUtils.FreeModuleRes;
begin
  if LModuleRes > 0 then
  begin
    LModuleRes := 0;
    FreeLibrary(LModuleRes);
  end;
end;

class function TUtils.OtaGetCurrentEditWindow: TCustomForm;
var
  EditView: IOTAEditView;
  EditWindow: INTAEditWindow;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TUtils.OtaGetCurrentEditWindow');
  {$ENDIF}

  Result := nil;
  EditView := OtaGetTopMostEditView;

  if Assigned(EditView) then
  begin
    EditWindow := EditView.GetEditWindow;

    if Assigned(EditWindow) then
      Result := EditWindow.Form;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TUtils.OtaGetCurrentEditWindow');
  {$ENDIF}
end;

class function TUtils.OtaGetDefaultEditWindow: TWinControl;
var
  LCom: TComponent;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TUtils.OtaGetDefaultEditWindow');
  {$ENDIF}

  Result := nil;
  LCom := FindComponentByClassName(Application.MainForm, 'TEditorDockPanel', EmptyStr);

  if Assigned(LCom) then
    Result := LCom as TWinControl;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TUtils.OtaGetDefaultEditWindow');
  {$ENDIF}
end;

class function TUtils.OtaGetEditBuffer: IOTAEditBuffer;
var
  iEditorServices: IOTAEditorServices;
begin
  Result := nil;

  if Supports(BorlandIDEServices, IOTAEditorServices, iEditorServices) then
    Result := iEditorServices.GetTopBuffer;
end;

class function TUtils.GetCurrentVersion: string;
var
  sFileName: String;
  iBufferSize: DWORD;
  iDummy: DWORD;
  pBuffer: Pointer;
  pFileInfo: Pointer;
  iVer: array[1..4] of Word;
begin
  // set default value
  Result := EmptyStr;

  // get filename of exe/dll if no filename is specified
  sFileName := GetModuleName;

  // get size of version info (0 if no version info exists)
  iBufferSize := GetFileVersionInfoSize(PChar(sFileName), iDummy);
  if iBufferSize > 0 then
  begin
    GetMem(pBuffer, iBufferSize);

    try
      // get fixed file info (language independent)
      GetFileVersionInfo(PChar(sFileName), 0, iBufferSize, pBuffer);
      VerQueryValue(pBuffer, '\', pFileInfo, iDummy);

      // read version blocks
      iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
      iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
      iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
      iVer[4] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
    finally
      FreeMem(pBuffer);
    end;

    // format result string
    Result := Format('%d.%d.%d.%d', [iVer[1], iVer[2], iVer[3], iVer[4]]);
  end;
end;

class function TUtils.GetHomePath: string;
var
  LStr: array[0 .. MAX_PATH] of Char;
begin
  SetLastError(ERROR_SUCCESS);

  if SHGetFolderPath(0, CSIDL_APPDATA, 0, 0, @LStr) = S_OK then
    Result := LStr;
end;

class function TUtils.GetModuleName: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, Length(ModName)));
end;

class function TUtils.GetNameDelphi: String;
begin
  {$IFDEF Tokyo}
  Result := 'Tokyo';
  {$ELSE}
    {$IFDEF Berlin}
    Result := 'Berlin';
    {$ELSE}
      {$IFDEF Seattle}
      Result := 'Seattle';
      {$ELSE}
        {$IFDEF XE8}
        Result := 'XE8';
        {$ELSE}
          {$IFDEF XE7}
          Result := 'XE7';
          {$ELSE}
            {$IFDEF XE6}
            Result := 'XE6';
            {$ELSE}
              {$IFDEF XE5}
              Result := 'XE5';
              {$ELSE}
                {$IFDEF XE4}
                Result := 'XE4';
                {$ELSE}
                  {$IFDEF XE3}
                  Result := 'XE3';
                  {$ELSE}
                    {$IFDEF XE2}
                    Result := 'XE2';
                    {$ELSE}
                      {$IFDEF XE}
                      Result := 'XE';
                      {$ELSE}
                        {$IFDEF D2010}
                        Result := 'D2010';
                        {$ELSE}
                          {$IFDEF D2009}
                          Result := 'D2009';
                          {$ELSE}
                            {$IFDEF D2007}
                            Result := 'D2007';
                            {$ELSE}
                              {$IFDEF D2006}
                              Result := 'D2006';
                              {$ELSE}
                                {$IFDEF D2005}
                                Result := 'D2005';
                                {$ELSE}
                                  {$IFDEF D7}
                                  Result := 'D7';
                                  {$ELSE}
                                    Result := 'D6';
                                  {$ENDIF D7}
                                {$ENDIF D2005}
                              {$ENDIF D2006}
                            {$ENDIF D2007}
                          {$ENDIF D2009}
                        {$ENDIF D2010}
                      {$ENDIF XE}
                    {$ENDIF XE2}
                  {$ENDIF XE3}
                {$ENDIF XE4}
              {$ENDIF XE5}
            {$ENDIF XE6}
          {$ENDIF XE7}
        {$ENDIF XE8}
      {$ENDIF Seattle}
    {$ENDIF Berlin}
  {$ENDIF Tokyo}
end;

class function TUtils.GetResourceName(aIcon: TResourceName): string;
begin
  case aIcon of
    rnClose: Result := 'CLOSE';
    rnLock: Result := 'LOCK';
    rnUnlock: Result := 'UNLOCK';
    rnDelete: Result := 'DELETE';
    rnMenu: Result := 'MAINMENU';
    rnDuplicate: Result := 'DUPLICATE';
    rnSelect: Result := 'SELECT';
    rnMultiBuffer: Result := 'MULTIBUFFER';
    rnSetting: Result := 'SETTING';
    rnAbout: Result := 'ABOUT';
    rnAboutMain: Result := 'ABOUTMAIN';
    rnUpdate: Result := 'UPDATE';
  else
    Result := 'MAINMENU';
  end;
end;

class function TUtils.GetTextFromReader(aReader: IOTAEditReader): string;
const
  cBufferSize = 1024 * 24;
var
  LBuffer: AnsiString;
  LEditReaderPos: Integer;
  LReadDataSize: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TUtils.GetTextFromReader');
  {$ENDIF}

  Result := EmptyStr;
  LEditReaderPos := 0;

  if Assigned(aReader) then
  repeat
    SetLength(LBuffer, cBufferSize);

    LReadDataSize := aReader.GetText(LEditReaderPos, PAnsiChar(LBuffer), cBufferSize);
    SetLength(LBuffer, LReadDataSize);

    Result := Result + string(LBuffer);

    Inc(LEditReaderPos, LReadDataSize);
  until LReadDataSize < cBufferSize;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TUtils.GetTextFromReader');
  {$ENDIF}
end;

class function TUtils.OtaGetTopMostEditView: IOTAEditView;
var
  iEditBuffer: IOTAEditBuffer;
begin
  Result := nil;
  iEditBuffer := OtaGetEditBuffer;

  if Assigned(iEditBuffer) then
    Result := iEditBuffer.GetTopView;
end;

{class function TUtils.ScanCodeToAscii(Code: Word): AnsiChar;
var
  i: Byte;
  C: Cardinal;
begin
  C := Code;
  if GetKeyState(VK_SHIFT) < 0 then
    C := C or $10000;
  if GetKeyState(VK_CONTROL) < 0 then
    C := C or $20000;
  if GetKeyState(VK_MENU) < 0 then
    C := C or $40000;

  for i := Low(Byte) to High(Byte) do
  if OemKeyScan(i) = C then
  begin
    Result := AnsiChar(i);
    Exit;
  end;

  Result := #0;
end;

class function TUtils.VK_ScanCodeToAscii(VKey, Code: Word): AnsiChar;

  function IsNumLockDown: Boolean;
  var
    KeyState: TKeyboardState;
  begin
    GetKeyboardState(KeyState);
    Result := Odd(KeyState[VK_NUMLOCK]);
  end;

begin
  if (VKey >= VK_NUMPAD0) and (VKey <= VK_DIVIDE) then
  begin
    case VKey of
      VK_NUMPAD0..VK_NUMPAD9:

        if IsNumLockDown then
          Result := AnsiChar(Ord('0') + VKey - VK_NUMPAD0)
        else
          Result := #0;

      VK_MULTIPLY: Result := '*';
      VK_ADD: Result := '+';
      VK_SEPARATOR: Result := #13;
      VK_SUBTRACT: Result := '-';
      VK_DECIMAL: Result := '.';
      VK_DIVIDE: Result := '/';
    else
      Result := #0;
    end;
  end
  else
  begin
    Result := ScanCodeToAscii(Code);
  end;
end; }

class function TUtils.IsEditControl(AControl: TComponent): Boolean;
begin
  Result := (AControl <> nil) and AControl.ClassNameIs(EditControlClassName)
    and SameText(AControl.Name, EditControlName);
end;

class function TUtils.IsLoadModuleRes: Boolean;
var
  LFile: string;
begin
  Result := LModuleRes > 0;

  if not Result then
  begin
    LFile := ExtractFilePath(TUtils.GetModuleName) + cModuleResName;

    if FileExists(LFile) then
    begin
      LModuleRes := LoadLibrary(PChar(LFile));
      Result := LModuleRes > 0;
    end;
  end;
end;

class procedure TUtils.LoadBitmap(aBitmap: TBitmap; aName: TResourceName);
var
  LIcon: TIcon;
  LPiconinfo: TIconInfo;
begin
  if Assigned(aBitmap) and IsLoadModuleRes then
  begin
    LIcon := TIcon.Create;
    try
      TUtils.LoadIcon(LIcon, aName);
       
      GetIconInfo(LIcon.Handle, LPiconinfo);
//      aBitmap.MaskHandle := LPiconinfo.hbmMask;
      aBitmap.Width := LIcon.Width;
      aBitmap.Height := LIcon.Height;
      aBitmap.Handle := LPiconinfo.hbmColor;
      aBitmap.Dormant;
    finally
      LIcon.Free;

      DeleteObject(LPiconinfo.hbmMask);
      DeleteObject(LPiconinfo.hbmColor);
    end;
  end;
end;

class procedure TUtils.LoadIcon(aIcon: TIcon; aName: TResourceName);
begin
  if Assigned(aIcon) and IsLoadModuleRes then
    aIcon.Handle := Windows.LoadIcon(LModuleRes, PChar(GetResourceName(aName)));
end;

class function TUtils.LoadRCDATAResource(aName: TResourceName): TResourceStream;
begin
  if IsLoadModuleRes then
    Result := TResourceStream.Create(LModuleRes, PChar(GetResourceName(aName)), RT_RCDATA)
  else
    Result := nil;
end;

initialization
  LModuleRes := 0;

finalization
  TUtils.FreeModuleRes;

end.
