unit uIDENotifier;

interface

{$I Compiler.inc}

uses
  ToolsApi, Windows, SysUtils, Classes;

type
  TIdeNotifier = class(TNotifierObject, IOTANotifier, IOTAIDENotifier)
  private
    FProjectPath: WideString;
  protected
    procedure AfterCompile(Succeeded: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
  end;

implementation

uses
   uSetting
   , ShellAPI
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
  LStream: TMemoryStream;
  LList: TStringList;
  LCopyData: TCopyDataStruct;
  LSugarMPHandle: THandle;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TIdeNotifier.AfterCompile');
  {$ENDIF}

  if Succeeded and TSetting.GetInstance.UseProjectManager then
  begin
    LSugarMPHandle := FindWindow('TMainPMFrm', nil);

    if LSugarMPHandle > 0 then
    begin
      LStream := TMemoryStream.Create;
      LList := TStringList.Create;
      try
        LList.Add(TUtils.GetNameDelphi);
        LList.Add(FProjectPath);

        LList.SaveToStream(LStream);
        
        LCopyData.dwData := 0;
        LCopyData.cbData := LStream.Size;
        LCopyData.lpData := LStream.Memory;

        SendMessage(LSugarMPHandle, WM_COPYDATA, Application.MainForm.Handle, LParam(@LCopyData));
      finally
        FreeAndNil(LList);
        FreeAndNil(LStream);
      end;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TIdeNotifier.AfterCompile');
  {$ENDIF}
end;

procedure TIdeNotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
var
  LSugarMPHandle: THandle;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TIdeNotifier.BeforeCompile');
  {$ENDIF}

  FProjectPath := Project.FileName;
  LSugarMPHandle := FindWindow('TMainPMFrm', nil);
  if LSugarMPHandle = 0 then
    ShellExecute(0, 'open', PChar('"' + TUtils.GetHomePath + '\Sugar for Delphi\SugarPM.exe"'), nil, nil, SW_NORMAL);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TIdeNotifier.BeforeCompile');
  {$ENDIF}
end;

procedure TIdeNotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
//  MsgServices.AddTitleMessage(Format('%s: %s',
//    [GetEnumName(TypeInfo(TOTAFIleNotification), Ord(NotifyCode)), FileName]));
end;

end.

