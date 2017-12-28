unit uSetting;

interface

{$I Compiler.inc}

uses
  Windows, Classes;

type
  TSetting = class
    private
        FDubleLineEnable: Boolean;
        FSelectionEnable: Boolean;
        FClipboardEnable: Boolean;
        FClipboardStorageSlots: Integer;
        FUseOSClipboard: Boolean;
        FAllVersionsUpdate: Boolean;
        FAutoUpdate: Boolean;
        FUseEnglishKeyboard: Boolean;
        FUseProjectManager: Boolean;
        FStartupProjectManagerWithWindows: Boolean;
        FUseIgnoreProjectNameLikeProject1: Boolean;

        FDubleLineHotKey: TShortCut;
        FSelectionShortKey: TShortCut;
        FDeSelectionShortKey: TShortCut;
        FClipboardShortKey: TShortCut;
        FClipboardToShortKey: TShortCut;

        procedure init;

        function GetDubleLineEnable: Boolean;
        function GetSelectionEnable: Boolean;
        function GetClipboardEnable: Boolean;
        function GetClipboardStorageSlots: Integer;
        function GetUseOSClipboard: Boolean;

        function GetDubleLineHotKey: TShortCut;
        function GetSelectionShortKey: TShortCut;
        function GetDeSelectionShortKey: TShortCut;
        function GetClipboardShortKey: TShortCut;
        function GetClipboardToShortKey: TShortCut;

        function GetAllVersionsUpdate: Boolean;
        function GetAutoUpdate: Boolean;
        function GetUseEnglishKeyboard: Boolean;
        function GetUseProjectManager: Boolean;
        function GetStartupProjectManagerWithWindows: Boolean;
        function GetUseIgnoreProjectNameLikeProject1: Boolean;

        procedure SetSelectionEnable(const Value: Boolean);
        procedure SetDubleLineEnable(const Value: Boolean);
        procedure SetClipboardEnable(const Value: Boolean);
        procedure SetClipboardStorageSlots(const Value: Integer);
        procedure SetUseOSClipboard(const Value: Boolean);

        procedure SetDubleLineHotKey(aShortCut: TShortCut);
        procedure SetSelectionShortKey(aShortCut: TShortCut);
        procedure SetDeSelectionShortKey(aShortCut: TShortCut);
        procedure SetClipboardShortKey(aShortCut: TShortCut);
        procedure SetClipboardToShortKey(aShortCut: TShortCut);

        procedure SetAllVersionsUpdate(const Value: Boolean);
        procedure SetAutoUpdate(const Value: Boolean);
        procedure SetUseEnglishKeyboard(const Value: Boolean);
        procedure SetUseProjectManager(const Value: Boolean);
        procedure SetStartupProjectManagerWithWindows(const Value: Boolean);
        procedure SetUseIgnoreProjectNameLikeProject1(const Value: Boolean);
    public
      class function GetInstance: TSetting;

      property DuplicateLineEnable: Boolean read GetDubleLineEnable write SetDubleLineEnable;
      property DupleLineHotKey: TShortCut read GetDubleLineHotKey write SetDubleLineHotKey;

      property SelectionEnable: Boolean read GetSelectionEnable write SetSelectionEnable;
      property SelectionShortKey: TShortCut read GetSelectionShortKey write SetSelectionShortKey;
      property DeSelectionShortKey: TShortCut read GetDeSelectionShortKey write SetDeSelectionShortKey;

      property ClipboardEnable: Boolean read GetClipboardEnable write SetClipboardEnable;
      property ClipboardStorageSlots: Integer read GetClipboardStorageSlots write SetClipboardStorageSlots;
      property ClipboardShortKey: TShortCut read GetClipboardShortKey write SetClipboardShortKey;
      property ClipboardToShortKey: TShortCut read GetClipboardToShortKey write SetClipboardToShortKey;
      property UseOSClipboard: Boolean read GetUseOSClipboard write SetUseOSClipboard;

      property AllVersionsUpdate: Boolean read GetAllVersionsUpdate write SetAllVersionsUpdate;
      property AutoUpdate: Boolean read GetAutoUpdate write SetAutoUpdate;
      property UseEnglishKeyboard: Boolean read GetUseEnglishKeyboard write SetUseEnglishKeyboard;
      property UseProjectManager: Boolean read GetUseProjectManager write SetUseProjectManager;
      property StartupProjectManagerWithWindows: Boolean read GetStartupProjectManagerWithWindows write SetStartupProjectManagerWithWindows;
      property UseIgnoreProjectNameLikeProject1: Boolean read GetUseIgnoreProjectNameLikeProject1 write SetUseIgnoreProjectNameLikeProject1;
  end;

implementation

uses
  Registry
  , Utils
  , Menus
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

const
  cMyAppName = 'Sugar for Delphi';

var
  INSTANCE: TSetting;

const
  cSettingKey = '\Software\DelphiPluginSugar\';
  cDuplicateLine = 'DuplicateLine';
  cSelection = 'Selection';
  cMultiClipboard = 'MultiClipboard';
  cClipboardStorageSlots = 'ClipboardStorageSlots';
  cInitMaxItemClipboard = 10;
  cShortKey = 'ShortKey';
  cEnable = 'Enable';

{ TSetting }

function TSetting.GetDubleLineHotKey: TShortCut;
begin
  Result := FDubleLineHotKey;
end;

class function TSetting.GetInstance: TSetting;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.GetInstance');
  {$ENDIF}

  if not Assigned(INSTANCE) then
  begin
    INSTANCE := TSetting.Create;
    INSTANCE.init;
  end;

  Result := INSTANCE;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.GetInstance');
  {$ENDIF}
end;

function TSetting.GetClipboardShortKey: TShortCut;
begin
  Result := FClipboardShortKey;
end;

function TSetting.GetClipboardStorageSlots: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.GetMaxItemClipboard');
  {$ENDIF}

  Result := FClipboardStorageSlots;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.GetMaxItemClipboard');
  {$ENDIF}
end;

function TSetting.GetClipboardToShortKey: TShortCut;
begin
  Result := FClipboardToShortKey;
end;

//function TSetting.GetSettingKey: string;
//begin
//
//end;

function TSetting.GetDeSelectionShortKey: TShortCut;
begin
  Result := FDeSelectionShortKey;
end;

function TSetting.GetDubleLineEnable: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.GetUseDuplicateLine');
  {$ENDIF}

  Result := GetInstance.FDubleLineEnable;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.GetUseDuplicateLine');
  {$ENDIF}
end;

function TSetting.GetAllVersionsUpdate: Boolean;
begin
  Result := FAllVersionsUpdate;
end;

function TSetting.GetAutoUpdate: Boolean;
begin
  Result := FAutoUpdate;
end;

function TSetting.GetClipboardEnable: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.GetUseMultiClipboard');
  {$ENDIF}

  Result := GetInstance.FClipboardEnable;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.GetUseMultiClipboard');
  {$ENDIF}
end;

function TSetting.GetSelectionEnable: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.GetUseSelectWordsInCaret');
  {$ENDIF}

  Result := GetInstance.FSelectionEnable;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.GetUseSelectWordsInCaret');
  {$ENDIF}
end;

function TSetting.GetSelectionShortKey: TShortCut;
begin
  Result := FSelectionShortKey;
end;

function TSetting.GetStartupProjectManagerWithWindows: Boolean;
begin
  Result := FStartupProjectManagerWithWindows;
end;

function TSetting.GetUseEnglishKeyboard: Boolean;
begin
  Result := FUseEnglishKeyboard;
end;

function TSetting.GetUseIgnoreProjectNameLikeProject1: Boolean;
begin
  Result := FUseIgnoreProjectNameLikeProject1;
end;

function TSetting.GetUseOSClipboard: Boolean;
begin
  Result := FUseOSClipboard;
end;

function TSetting.GetUseProjectManager: Boolean;
begin
  Result := FUseProjectManager;
end;

procedure TSetting.init;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.init');
  {$ENDIF}

  with TRegistry.Create do
  try
    RootKey := HKEY_CURRENT_USER;

    if OpenKey(cSettingKey, True) then
    begin
      // DuplicateLine
      if ValueExists(cDuplicateLine + cEnable) then
        FDubleLineEnable := ReadBool(cDuplicateLine + cEnable)
      else
        FDubleLineEnable := True;

      if ValueExists(cDuplicateLine + cShortKey) then
        FDubleLineHotKey := ReadInteger(cDuplicateLine + cShortKey)
      else
        FDubleLineHotKey := ShortCut(Ord('D'), [ssCtrl]);


      // Selection
      if ValueExists(cSelection + cEnable) then
        FSelectionEnable := ReadBool(cSelection + cEnable)
      else
        FSelectionEnable := True;

      if ValueExists(cSelection + cShortKey) then
        FSelectionShortKey := ReadInteger(cSelection + cShortKey)
      else
        FSelectionShortKey := ShortCut(Ord('W'), [ssCtrl]);

      if ValueExists('De' + cSelection + cShortKey) then
        FDeSelectionShortKey := ReadInteger('De' + cSelection + cShortKey)
      else
        FDeSelectionShortKey := ShortCut(Ord('W'), [ssCtrl, ssShift]);


      // Clipboard
      if ValueExists(cMultiClipboard + cEnable) then
        FClipboardEnable := ReadBool(cMultiClipboard + cEnable)
      else
        FClipboardEnable := True;

      if ValueExists(cMultiClipboard + cShortKey) then
        FClipboardShortKey := ReadInteger(cMultiClipboard + cShortKey)
      else
        FClipboardShortKey := ShortCut(Ord('V'), [ssAlt]);

      if ValueExists(cMultiClipboard + 'To' + cShortKey) then
        FClipboardToShortKey := ReadInteger(cMultiClipboard + 'To' + cShortKey)
      else
        FClipboardToShortKey := ShortCut(VK_RETURN, [ssCtrl]);

      if ValueExists(cClipboardStorageSlots) then
        FClipboardStorageSlots := ReadInteger(cClipboardStorageSlots)
      else
        FClipboardStorageSlots := cInitMaxItemClipboard;

      if ValueExists(cMultiClipboard + 'Global') then
        FUseOSClipboard := ReadBool(cMultiClipboard + 'Global')
      else
        FUseOSClipboard := True;

      // Update
      if ValueExists('AllVersionsUpdate') then
        FAllVersionsUpdate := ReadBool('AllVersionsUpdate')
      else
        FAllVersionsUpdate := True;

      if ValueExists('AutoUpdate') then
        FAutoUpdate := ReadBool('AutoUpdate')
      else
        FAutoUpdate := True;

      if ValueExists('UseEnglishKeyboard') then
        FUseEnglishKeyboard := ReadBool('UseEnglishKeyboard')
      else
        FUseEnglishKeyboard := True;

      if ValueExists('UseProjectManager') then
        FUseProjectManager := ReadBool('UseProjectManager')
      else
        FUseProjectManager := False;

      with TRegistry.Create do
      try
        RootKey := HKEY_CURRENT_USER;

        if OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
          FStartupProjectManagerWithWindows := ValueExists('SugarManagerProject')
        else
          FStartupProjectManagerWithWindows := False;
      finally
        Free;
      end;

      if ValueExists('UseIgnoreProjectNameLikeProject1') then
        FUseProjectManager := ReadBool('UseIgnoreProjectNameLikeProject1')
      else
        FUseProjectManager := False;
    end;
  finally
    Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.init');
  {$ENDIF}
end;

procedure TSetting.SetDubleLineHotKey(aShortCut: TShortCut);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetDupleLineHotKey');
  {$ENDIF}

  if aShortCut <> FDubleLineHotKey then
  begin
    FDubleLineHotKey := aShortCut;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteInteger(cDuplicateLine + cShortKey, FDubleLineHotKey);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetDupleLineHotKey');
  {$ENDIF}
end;

procedure TSetting.SetClipboardShortKey(aShortCut: TShortCut);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetClipboardShortKey');
  {$ENDIF}

  if aShortCut <> FClipboardShortKey then
  begin
    FClipboardShortKey := aShortCut;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteInteger(cMultiClipboard + cShortKey, FClipboardShortKey);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetClipboardShortKey');
  {$ENDIF}
end;

procedure TSetting.SetClipboardStorageSlots(const Value: Integer);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetMaxItemClipboard');
  {$ENDIF}

  if Value = 0 then
    FClipboardStorageSlots := cInitMaxItemClipboard
  else
    FClipboardStorageSlots := Value;

  with TRegistry.Create do
  try
    RootKey := HKEY_CURRENT_USER;

    if OpenKey(cSettingKey, True) then
    begin
      WriteInteger(cClipboardStorageSlots, FClipboardStorageSlots);
    end;
  finally
    Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetMaxItemClipboard');
  {$ENDIF}
end;

procedure TSetting.SetClipboardToShortKey(aShortCut: TShortCut);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetClipboardToShortKey');
  {$ENDIF}

  if aShortCut <> FClipboardToShortKey then
  begin
    FClipboardToShortKey := aShortCut;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteInteger(cMultiClipboard + 'To' + cShortKey, FClipboardToShortKey);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetClipboardToShortKey');
  {$ENDIF}
end;

procedure TSetting.SetDeSelectionShortKey(aShortCut: TShortCut);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetDeSelectionShortKey');
  {$ENDIF}

  if aShortCut <> FDeSelectionShortKey then
  begin
    FDeSelectionShortKey := aShortCut;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteInteger('De' + cSelection + cShortKey, FDeSelectionShortKey);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetDeSelectionShortKey');
  {$ENDIF}
end;

procedure TSetting.SetDubleLineEnable(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseDuplicateLine');
  {$ENDIF}

  if FDubleLineEnable <> Value then
  begin
    FDubleLineEnable := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool(cDuplicateLine + cEnable, Value);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseDuplicateLine');
  {$ENDIF}
end;

procedure TSetting.SetAllVersionsUpdate(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetAllVersionsUpdate');
  {$ENDIF}

  if FAllVersionsUpdate <> Value then
  begin
    FAllVersionsUpdate := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool('AllVersionsUpdate', Value);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetAllVersionsUpdate');
  {$ENDIF}
end;

procedure TSetting.SetAutoUpdate(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetAutoUpdate');
  {$ENDIF}

  if FAutoUpdate <> Value then
  begin
    FAutoUpdate := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool('AutoUpdate', Value);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetAutoUpdate');
  {$ENDIF}
end;

procedure TSetting.SetClipboardEnable(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseMultiClipboard');
  {$ENDIF}

  if FClipboardEnable <> Value then
  begin
    FClipboardEnable := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool(cMultiClipboard, Value);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseMultiClipboard');
  {$ENDIF}
end;

procedure TSetting.SetSelectionEnable(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseSelectWordsInCaret');
  {$ENDIF}

  if FSelectionEnable <> Value then
  begin
    FSelectionEnable := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool(cSelection, Value);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseSelectWordsInCaret');
  {$ENDIF}
end;

procedure TSetting.SetSelectionShortKey(aShortCut: TShortCut);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetSelectionShortKey');
  {$ENDIF}

  if aShortCut <> FSelectionShortKey then
  begin
    FSelectionShortKey := aShortCut;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteInteger(cSelection + cShortKey, FSelectionShortKey);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetSelectionShortKey');
  {$ENDIF}
end;

procedure TSetting.SetStartupProjectManagerWithWindows(const Value: Boolean);
var
  LPath: string;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetStartupProjectManagerWithWindows');
  {$ENDIF}

  if Value <> FStartupProjectManagerWithWindows then
  begin
    FStartupProjectManagerWithWindows := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
      begin
        LPath := TUtils.GetHomePath + '\' + cMyAppName + '\SugarPM.exe';

        if FStartupProjectManagerWithWindows then
          WriteString('SugarManagerProject', '"' + LPath + '"')
        else
          DeleteValue('SugarManagerProject');
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetStartupProjectManagerWithWindows');
  {$ENDIF}
end;

procedure TSetting.SetUseEnglishKeyboard(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseEnglishKeyboard');
  {$ENDIF}

  if Value <> FUseEnglishKeyboard then
  begin
    FUseEnglishKeyboard := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool('UseEnglishKeyboard', FUseEnglishKeyboard);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseEnglishKeyboard');
  {$ENDIF}
end;

procedure TSetting.SetUseIgnoreProjectNameLikeProject1(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseIgnoreProjectNameLikeProject1');
  {$ENDIF}

  if Value <> FUseIgnoreProjectNameLikeProject1 then
  begin
    FUseIgnoreProjectNameLikeProject1 := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool('UseIgnoreProjectNameLikeProject1', FUseIgnoreProjectNameLikeProject1);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseIgnoreProjectNameLikeProject1');
  {$ENDIF}
end;

procedure TSetting.SetUseOSClipboard(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseOSClipboard');
  {$ENDIF}

  if Value <> FUseOSClipboard then
  begin
    FUseOSClipboard := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool(cMultiClipboard + 'Global', FUseOSClipboard);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseOSClipboard');
  {$ENDIF}
end;

procedure TSetting.SetUseProjectManager(const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSetting.SetUseProjectManager');
  {$ENDIF}

  if Value <> FUseProjectManager then
  begin
    FUseProjectManager := Value;

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;

      if OpenKey(cSettingKey, True) then
      begin
        WriteBool('UseProjectManager', FUseProjectManager);
      end;
    finally
      Free;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSetting.SetUseProjectManager');
  {$ENDIF}
end;

end.
