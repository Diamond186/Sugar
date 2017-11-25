unit uWizardManager;

interface

{$I Compiler.inc}

uses
  Windows, SysUtils, ToolsAPI, Menus, Graphics
  , uMenuSugar
  , dmImages
  , Controls
  , AppEvnts
  , WidePasParser
//  , Dialogs
  ;

type
  TWizardManager = class(TNotifierObject, IOTAWizard)
  private
    FWizardIndex: Integer;
    FKeyboardIndex: Integer;
    FIDENotiferIndex: Integer;
    FDMImages: TImagesDM;

    {$IFDEF D2005}
    FEditorNotifierIndex: Integer;
    FSplashScreen    : TBitmap;
    FAboutPluginIndex : Integer;
    {$ENDIF}

    FMenuWizards: TMenuSugar;
    FEvents: TApplicationEvents;
    FParser: TWidePasStructParser;

    FLastIdleTick: Cardinal;

    procedure InstalKeyBinding;

    procedure DoApplicationIdle(Sender: TObject; var Done: Boolean);
    procedure DoApplicationMessage(var Msg: TMsg; var Handled: Boolean);

    function IsPositionCommitOrText(aView: IOTAEditView): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure FinalizeWizard;
    function  InitializeWizard(const aBorlandIDEServices: IBorlandIDEServices): Boolean;
    function  GetImages: TImageList;

    procedure RemoveKeyBinding;
    procedure UpdateShortKey;

    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    property WizardIndex: Integer read FWizardIndex;
    property KeyboardIndex: Integer read FKeyboardIndex;
    {$IFDEF D2005}
    property AboutPluginIndex: Integer read FAboutPluginIndex;
    {$ENDIF}
  end;

//procedure register;

var
  varWizardManager: TWizardManager;

implementation

uses
  frmMultiClipboard
  , KeyboardBinding
  , uThreadUpdate
  , uMessageEditor
  , uIDENotifier
  , mPasLexTypes
  , uSetting
  , Messages
  , Classes
  , Forms
  , Utils
  {$IFDEF D2005}
  //, EditorNotifier
  {$ENDIF}
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
//  , Dialogs
  ;

const
  InvalidIndex = -1;
  csIdleMinInterval = 50;

const
  {$IFDEF XE}
  strSplashScreenName = 'Sugar for Embarcadero RAD Studio';
  {$ENDIF}

  {$IFNDEF XE}
    {$IFDEF D2007}
    strSplashScreenName = 'Sugar for CodeGear Delphi';
    {$ENDIF}

    {$IFNDEF D2007}
    strSplashScreenName = 'Sugar for Borland Delphi';
    {$ENDIF}
  {$ENDIF}

{procedure register;
begin
  varWizardManager := TWizardManager.Create;
  varWizardManager.InitializeWizard(BorlandIDEServices);
end;}

{ TWizardManager }

procedure TWizardManager.AfterSave;
begin

end;

procedure TWizardManager.BeforeSave;
begin

end;

constructor TWizardManager.Create;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.Create');
  {$ENDIF}

  inherited Create;

  FWizardIndex := InvalidIndex;
  FKeyboardIndex := InvalidIndex;

//  FIsActiveClipBoard := False;

  {$IFDEF D2005}
  FEditorNotifierIndex := InvalidIndex;
  FAboutPluginIndex := InvalidIndex;

  FSplashScreen := TBitmap.Create;
  TUtils.LoadBitmap(FSplashScreen, rnMenu);
  {$ENDIF}

  FDMImages := TImagesDM.Create(nil);
  FMenuWizards := TMenuSugar.Create;
  FEvents := TApplicationEvents.Create(nil);

  FParser := TWidePasStructParser.Create;
  FParser.UseTabKey := True;
  FParser.TabWidth := 2;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.Create');
  {$ENDIF}
end;

destructor TWizardManager.Destroy;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.Destroy');
  {$ENDIF}

  {$IFDEF D2005}
  FreeAndNil(FSplashScreen);
  {$ENDIF}

  FreeAndNil(FParser);
  FreeAndNil(FEvents);
  FreeAndNil(FDMImages);
  FreeAndNil(FMenuWizards);

  inherited;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.Destroy');
  {$ENDIF}
end;


procedure TWizardManager.Destroyed;
begin
end;

procedure TWizardManager.DoApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TWizardManager.DoApplicationIdle');
  {$ENDIF}

  if (GetTickCount - FLastIdleTick) > csIdleMinInterval then
  begin
    FEvents.OnIdle := nil;

    RemoveKeyBinding;
    InstalKeyBinding;

    TMultiClipboardFrm.ActiveClipboardViewer;

    TThreadUpdate.RunUpdateAuto(True);

    FLastIdleTick := GetTickCount;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.DoApplicationIdle');
  {$ENDIF}
end;

procedure TWizardManager.DoApplicationMessage(var Msg: TMsg; var Handled: Boolean);
var
//  Key: Word;
//  ScanCode: Word;
  buf: array [0..$ff] of Char;
//  Shift: TShiftState;
begin
  if ((Msg.message = WM_KEYDOWN) {or (Msg.message = WM_KEYUP)})
    and (Msg.wParam in [65..90])
    and TUtils.IsEditControl(Screen.ActiveControl)
    and TSetting.GetInstance.UseEnglishKeyboard
  then
  begin
    GetKeyboardLayoutName(buf);

    if StrPas(buf) <> '00000409' then
    begin
      if not IsPositionCommitOrText(TUtils.OtaGetTopMostEditView) then
        LoadKeyboardLayout('00000409', KLF_ACTIVATE);
    end;
  end;
end;

procedure TWizardManager.Execute;
begin
end;

procedure TWizardManager.FinalizeWizard;
var
  LWizardServices: IOTAWizardServices;
  LServices: IOTAServices;
  LKeyboardServices: IOTAKeyboardServices;
  {$IFDEF D2005}
  LEditorServices: IOTAEditorServices;
  LAboutBoxServices: IOTAAboutBoxServices;
  {$ENDIF}
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.FinalizeWizard');
  {$ENDIF}

  if Assigned(varWizardManager) then
  begin
    Assert(Assigned(BorlandIDEServices));

    LWizardServices := BorlandIDEServices as IOTAWizardServices;
    LServices := BorlandIDEServices as IOTAServices;
    LKeyboardServices := BorlandIDEServices as IOTAKeyboardServices;
    {$IFDEF D2005}
    LEditorServices := BorlandIDEServices as IOTAEditorServices;
    LAboutBoxServices := BorlandIDEServices as IOTAAboutBoxServices;
    {$ENDIF}

    Assert(Assigned(LWizardServices));
    Assert(Assigned(LKeyboardServices));
    Assert(Assigned(LServices), 'IOTAServices not available');
    {$IFDEF D2005}
    Assert(Assigned(LAboutBoxServices));
    Assert(Assigned(LEditorServices));
    {$ENDIF}

    FEvents.OnIdle := nil;
    FEvents.OnMessage := nil;

    TMultiClipboardFrm.DestroyForm;

    if FIDENotiferIndex <> InvalidIndex then
    begin
      LServices.RemoveNotifier(FIDENotiferIndex);
    end;

    if FKeyboardIndex <> InvalidIndex then
    try
      LKeyboardServices.RemoveKeyboardBinding(FKeyboardIndex);
      FKeyboardIndex := InvalidIndex;
    except
      on E: Exception do
      begin
        // ignore
      end;
    end;

    {$IFDEF D2005}
    // Remove Editor Notifier Interface
    if FEditorNotifierIndex <> InvalidIndex then
    try
      LEditorServices.RemoveNotifier(FEditorNotifierIndex);
      FEditorNotifierIndex := InvalidIndex;
    except
      on E: Exception do
      begin
        // ignore
      end;
    end;

    // Remove Aboutbox Plugin Interface
    if AboutPluginIndex <> InvalidIndex then
    try
      LAboutBoxServices.RemovePluginInfo(AboutPluginIndex);
      FAboutPluginIndex := InvalidIndex;
    except
      on E: Exception do
      begin
        // ignore
      end;
    end;
    {$ENDIF}

    if FWizardIndex <> InvalidIndex then
    try
      LWizardServices.RemoveWizard(FWizardIndex);
      FWizardIndex := InvalidIndex;
    except
      on E: Exception do
      begin
        // ignore
      end;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.FinalizeWizard');
  {$ENDIF}
end;

function TWizardManager.GetIDString: string;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.GetIDString');
  {$ENDIF}

  Result := 'Sugar Plugin';

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.GetIDString');
  {$ENDIF}
end;

function TWizardManager.GetImages: TImageList;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.GetImages');
  {$ENDIF}

  Result := FDMImages.Images;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.GetImages');
  {$ENDIF}
end;

function TWizardManager.GetName: string;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.GetName');
  {$ENDIF}

  Result := 'Sugar';

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.GetName');
  {$ENDIF}
end;

function TWizardManager.GetState: TWizardState;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.GetState');
  {$ENDIF}

  Result := [wsEnabled];

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.GetState');
  {$ENDIF}
end;

function TWizardManager.InitializeWizard(const aBorlandIDEServices: IBorlandIDEServices): Boolean;
var
  LWizardServices: IOTAWizardServices;
  LServices: IOTAServices;
  {$IFDEF D2005}
  LEditorServices: IOTAEditorServices;
  LAboutBoxServices: IOTAAboutBoxServices;
  LSplashScreenBuild: string;
  {$ENDIF}
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.InitializeWizard');
  {$ENDIF}

  Result := Assigned(aBorlandIDEServices);

  if Result then
  begin
    LWizardServices := aBorlandIDEServices as IOTAWizardServices;
    LServices := BorlandIDEServices as IOTAServices;
    {$IFDEF D2005}
    LEditorServices := aBorlandIDEServices as IOTAEditorServices;
    LAboutBoxServices := aBorlandIDEServices as IOTAAboutBoxServices;
    {$ENDIF}

    Assert(Assigned(LWizardServices));
    Assert(Assigned(LServices), 'IOTAServices not available');
    {$IFDEF D2005}
    Assert(Assigned(LAboutBoxServices));
    Assert(Assigned(LEditorServices));
    {$ENDIF}

    FWizardIndex := LWizardServices.AddWizard(varWizardManager as IOTAWizard);
    Result := FWizardIndex >= 0;

    if Result then
    begin
      FIDENotiferIndex := LServices.AddNotifier(TIdeNotifier.Create);
    end;

    {$IFDEF D2005}
    // Create Editor Notifier Interface
//    if Result then
//    begin
//      FEditorNotifierIndex := LEditorServices.AddNotifier(TEditorNotifier.Create);
//      Result := FEditorNotifierIndex >= 0;
//    end;

    // Create about plugin info
    if Result then
    begin
      LSplashScreenBuild := 'build ' + TUtils.GetCurrentVersion;
      if Assigned(SplashScreenServices) then
        SplashScreenServices.AddPluginBitmap(strSplashScreenName,
                                             FSplashScreen.Handle,
                                             False,
                                             LSplashScreenBuild);

      FAboutPluginIndex := LAboutBoxServices.AddPluginInfo(strSplashScreenName,
                                                           '$WIZARDDESCRIPTION$.',
                                                           FSplashScreen.Handle,
                                                           False,
                                                           LSplashScreenBuild);
      Result := FAboutPluginIndex >= 0;
    end;
    {$ENDIF}

    if Result then
      FMenuWizards.AddMenuItems;

    TMultiClipboardFrm.CreateForm;

    FEvents.OnIdle := DoApplicationIdle;
    FEvents.OnMessage := DoApplicationMessage;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.InitializeWizard');
  {$ENDIF}
end;

procedure TWizardManager.Modified;
begin

end;

procedure TWizardManager.InstalKeyBinding;
var
  LKeyboardServices: IOTAKeyboardServices;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.InstalKeyBinding');
  {$ENDIF}

  LKeyboardServices := nil;
  LKeyboardServices := BorlandIDEServices as IOTAKeyboardServices;
  Assert(Assigned(LKeyboardServices));

  // Create Keyboard Binding Interface
  FKeyboardIndex := LKeyboardServices.AddKeyboardBinding(TKeyBinding.Create);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.InstalKeyBinding');
  {$ENDIF}
end;

function TWizardManager.IsPositionCommitOrText(aView: IOTAEditView): Boolean;
var
  LReader: IOTAEditReader;
  LText: WideString;
  i, LPos, LStart, LEnd: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.IsPositionCommitOrText');
  {$ENDIF}

  Result := False;

  if Assigned(aView) then
  begin
    FParser.Clear;

    LReader := aView.Buffer.CreateReader;
    try
      LText := TUtils.GetTextFromReader(LReader);
      FParser.ParseSource(PWideChar(LText), False, False);

      LPos := aView.Position.Column;

      for i := 0 to FParser.Count - 1 do
      if FParser.Tokens[i].LineNumber >= aView.Position.Row - 1 then
      begin
        if FParser.Tokens[i].LineNumber > aView.Position.Row - 1 then
          Break;

        LStart := FParser.Tokens[i].ColumnNumber;
        LEnd := FParser.Tokens[i].ColumnNumber + FParser.Tokens[i].TokenLength;
        if ((LStart < LPos) and (LEnd > LPos))
          or ((LStart < LPos) and (FParser.Tokens[i].TokenID = tkSlashesComment))
        then
          Result := FParser.Tokens[i].TokenID in [tkBorComment, tkAnsiComment, tkSlashesComment, tkString];
      end;
    finally
      LReader := nil;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.IsPositionCommitOrText');
  {$ENDIF}
end;

procedure TWizardManager.RemoveKeyBinding;
var
  LKeyboardServices: IOTAKeyboardServices;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.RemoveKeyBinding');
  {$ENDIF}

  if FKeyboardIndex <> InvalidIndex then
  begin
    LKeyboardServices := nil;
    LKeyboardServices := BorlandIDEServices as IOTAKeyboardServices;
    Assert(Assigned(LKeyboardServices));

    try
      LKeyboardServices.RemoveKeyboardBinding(FKeyboardIndex);
    except
      on E: Exception do
        raise E.Create('Error removing keyboard shortcuts from IDE: ' +E.Message);
    end;

    FKeyboardIndex := InvalidIndex;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.RemoveKeyBinding');
  {$ENDIF}
end;

procedure TWizardManager.UpdateShortKey;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TWizardManager.UpdateShortKey');
  {$ENDIF}

  RemoveKeyBinding;
  InstalKeyBinding;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TWizardManager.UpdateShortKey');
  {$ENDIF}
end;

end.

