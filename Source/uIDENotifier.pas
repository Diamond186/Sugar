unit uIDENotifier;

interface

{$I Compiler.inc}

uses
  ToolsApi, Windows, SysUtils, Classes;

type
  TIdeNotifier = class(TNotifierObject, IOTANotifier, IOTAIDENotifier)
  private
    FProjectPath: WideString;
    FStream: TMemoryStream;

    function ProjectNameLikeProject1(const aProjectName: WideString): Boolean;
  protected
    procedure AfterCompile(Succeeded: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
  public
    constructor Create;
    destructor  Destroy; override;
  end;

implementation

uses
   uSetting
   , ShellAPI
   , StrUtils
   , Utils
   , Forms
  {$IFDEF TestRun}
  , TestRun
//  , Dialogs
  {$ENDIF}
  ;

const
  WM_COPYDATA = $004A;

function MsgServices: IOTAMessageServices;
begin
  Result := (BorlandIDEServices as IOTAMessageServices);
  Assert(Result <> nil, 'IOTAMessageServices not available');
end;

procedure TIdeNotifier.AfterCompile(Succeeded: Boolean);
var
  LList: TStringList;
  LCopyData: TCopyDataStruct;
  LSugarMPHandle: THandle;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TIdeNotifier.AfterCompile');
  {$ENDIF}

  if (TSetting.GetInstance.UseIgnoreProjectNameLikeProject1
    and ProjectNameLikeProject1(StringReplace(ExtractFileName(FProjectPath),
                                              ExtractFileExt(FProjectPath), EmptyStr, [rfReplaceAll])))
    or (TSetting.GetInstance.UseIgnoreDefaultProjectPath
    and (TUtils.GetDefaultProjectPath = ExtractFilePath(FProjectPath)))
  then
    Exit;

  if Succeeded
    and Assigned(FStream)
  then
  begin
    LSugarMPHandle := TUtils.GetSugarPMHandle;

    if LSugarMPHandle > 0 then
    begin
      FStream.Size := 0;
      FStream.Position := 0;

      LList := TStringList.Create;
      try
        LList.Add(TUtils.GetNameDelphi);
        LList.Add(FProjectPath);

        LList.SaveToStream(FStream);

        LCopyData.dwData := 0;
        LCopyData.cbData := FStream.Size;
        LCopyData.lpData := FStream.Memory;

        SendMessage(LSugarMPHandle, WM_COPYDATA, Application.MainForm.Handle, LParam(@LCopyData));
      finally
        FreeAndNil(LList);
      end;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TIdeNotifier.AfterCompile');
  {$ENDIF}
end;

procedure TIdeNotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TIdeNotifier.BeforeCompile');
  {$ENDIF}

  FProjectPath := Project.FileName;

  if TSetting.GetInstance.UseProjectManager
    and (TUtils.GetSugarPMHandle > 0)
  then
    ShellExecute(0, 'open', PChar('"' + TUtils.GetHomePath + '\Sugar for Delphi\SugarPM.exe"'), nil, nil, SW_NORMAL);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TIdeNotifier.BeforeCompile');
  {$ENDIF}
end;

constructor TIdeNotifier.Create;
begin
  FStream := TMemoryStream.Create;
end;

destructor TIdeNotifier.Destroy;
begin
  FreeAndNil(FStream);
  inherited;
end;

procedure TIdeNotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
//  MsgServices.AddTitleMessage(Format('%s: %s',
//    [GetEnumName(TypeInfo(TOTAFIleNotification), Ord(NotifyCode)), FileName]));
end;

function TIdeNotifier.ProjectNameLikeProject1(const aProjectName: WideString): Boolean;
var
  LInt: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TIdeNotifier.ProjectNameLikeProject1');
  TTestRun.AddMarker('aProjectName = ' + aProjectName);
  TTestRun.AddMarker('LeftStr = ' + LeftStr(aProjectName, 7));
  TTestRun.AddMarker('Copy = ' + Copy(aProjectName, 8, Length(aProjectName) - 7));
  {$ENDIF}

  Result := (LeftStr(aProjectName, 7) = 'Project')
         and TryStrToInt(Copy(aProjectName, 8, Length(aProjectName) - 7), LInt);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TIdeNotifier.ProjectNameLikeProject1');
  {$ENDIF}
end;

end.

