unit uCommonLibrary;

interface

{$I Compiler.inc}

uses
  Classes;

type
  ICommonLib = interface
    function IsExistsNewVersion: Boolean;
    function RunUpdate: Boolean;
    function SendEmail(const aMessage: string; const aFiles: array of String; out aError: WideString): Boolean;
    function DownloadManagerProject: WideString;
  end;

function GetCommonLib: ICommonLib;

implementation

uses
  Windows
  , SysUtils
  , Utils
  , uSetting
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

const
  cLibraryName = 'common.dll';
  cFunNameGetUpdate = 'GetUpdate';
  cFunNameRunUpdate = 'RunUpdate';
  cFunNameSendEmail = 'SendEmail';
  cFunNameDownloadPM = 'DownloadPM';

type
  TCommonLib = class(TInterfacedObject, ICommonLib)
    private
      FHandleLibrary: THandle;
      FNewVersion: WideString;

      function LoadCommonLibrary: Boolean;
      procedure FreeCommonLibrary;
    protected
      constructor Create;
      destructor  Destroy; override;
    public
      function IsExistsNewVersion: Boolean;
      function RunUpdate: Boolean;
      function SendEmail(const aMessage: string; const aFiles: array of String; out aError: WideString): Boolean;
      function DownloadManagerProject: WideString;
  end;

var
  FCommonLib: ICommonLib = nil;

function GetCommonLib: ICommonLib;
begin
  if not Assigned(FCommonLib) then
    FCommonLib := TCommonLib.Create;

  Result := FCommonLib;
end;

{ TCommonLib }

constructor TCommonLib.Create;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.Create');
  {$ENDIF}

  FHandleLibrary := 0;
  FNewVersion := EmptyStr;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TCommonLib.Create');
  {$ENDIF}
end;

destructor TCommonLib.Destroy;
begin
  FreeCommonLibrary;

  inherited;
end;

function TCommonLib.DownloadManagerProject: WideString;
var
  LDownloadPM: function: WideString; stdcall;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.RunDownloadManagerProject');
  {$ENDIF}

  Result := EmptyStr;

  if LoadCommonLibrary then
  begin
    LDownloadPM := GetProcAddress(FHandleLibrary, cFunNameDownloadPM);

    if Assigned(LDownloadPM) then
      Result := LDownloadPM;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TCommonLib.RunDownloadManagerProject');
  {$ENDIF}
end;

function TCommonLib.RunUpdate: Boolean;
var
  LRunUpdate: function(const aAllVersion: Boolean; const aCurDelphi: WideString): Boolean; stdcall;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.RunUpdate');
  TTestRun.AddMarker('AllVersionsUpdate: ' + BoolToStr(TSetting.GetInstance.AllVersionsUpdate, True));
  TTestRun.AddMarker('GetNameDelphi: ' + TUtils.GetNameDelphi);
  {$ENDIF}

  Result := False;

  if LoadCommonLibrary then
  begin
    LRunUpdate := GetProcAddress(FHandleLibrary, cFunNameRunUpdate);

    if Assigned(LRunUpdate) then
    begin
      Result := LRunUpdate(TSetting.GetInstance.AllVersionsUpdate, TUtils.GetNameDelphi);
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TCommonLib.RunUpdate');
  {$ENDIF}
end;

function TCommonLib.SendEmail(const aMessage: string; const aFiles: array of String; out aError: WideString): Boolean;
var
  LSendEnmil: function (const aMessage: WideString; const aFiles: array of String; out aError: WideString): Boolean; stdcall;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.SendEmail');
  {$ENDIF}

  Result := False;

  if LoadCommonLibrary then
  begin
    LSendEnmil := GetProcAddress(FHandleLibrary, cFunNameSendEmail);

    if Assigned(LSendEnmil) then
      Result := LSendEnmil(aMessage, aFiles, aError);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TCommonLib.SendEmail');
  {$ENDIF}
end;

procedure TCommonLib.FreeCommonLibrary;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.FreeCommonLibrary');
  {$ENDIF}

  if FHandleLibrary > 0 then
  begin
    FHandleLibrary := 0;
    FreeLibrary(FHandleLibrary);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TCommonLib.FreeCommonLibrary');
  {$ENDIF}
end;

function TCommonLib.IsExistsNewVersion: Boolean;
var
  LGetUpdate: function (const aCurrentVersion: WideString; out aNewVersion: WideString): Boolean; stdcall;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.IsExistsNewVersion');
  {$ENDIF}

  Result := False;

  if LoadCommonLibrary then
  begin
    LGetUpdate := GetProcAddress(FHandleLibrary, cFunNameGetUpdate);

    if Assigned(LGetUpdate) then

      Result := LGetUpdate(TUtils.GetCurrentVersion, FNewVersion);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('GetCurrentVersion: ' + TUtils.GetCurrentVersion);
  TTestRun.AddMarker('FNewVersion: ' + FNewVersion);
  TTestRun.AddMarker('end TCommonLib.IsExistsNewVersion');
  {$ENDIF}
end;

function TCommonLib.LoadCommonLibrary: Boolean;
var
  LFile: string;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TCommonLib.LoadCommonLibrary');
  {$ENDIF}

  Result := FHandleLibrary > 0;

  if not Result then
  begin
    LFile := ExtractFilePath(TUtils.GetModuleName) + cLibraryName;

    if FileExists(LFile) then
    begin
      FHandleLibrary := LoadLibrary(PChar(LFile));
      Result := FHandleLibrary > 0;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('LFile: ' + LFile);
  TTestRun.AddMarker('end TCommonLib.LoadCommonLibrary');
  {$ENDIF}
end;

initialization

finalization
  FCommonLib := nil;

end.
