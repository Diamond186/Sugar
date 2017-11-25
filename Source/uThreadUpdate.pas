unit uThreadUpdate;

interface

uses
  Classes;

type
  TCase = (caAuto, caAutoExists, caMenu, caDownloadPM);

  TThreadUpdate = class(TThread)
  private
    FCase: TCase;

    procedure DoShowMessageUpdate;
  protected
    procedure Execute; override;
  public
    class procedure RunUpdateAuto(aOnlyExists: Boolean);
    class procedure RunUpdateMenu;
    class procedure RunDownloadMP;
  end;

implementation

{$I Compiler.inc}

uses
  Windows
  , uMessageEditor
  , uSetting
  , SysUtils
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  , uCommonLibrary;



{ TThreadUpdate }

procedure TThreadUpdate.DoShowMessageUpdate;
begin
  TMesEditorForm.ShowMessageEditorUpdate('New Sugar');
end;

procedure TThreadUpdate.Execute;
var
  LError: WideString;
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TThreadUpdate.Execute');
  {$ENDIF}

  case FCase of
    caAuto: GetCommonLib.RunUpdate;

    caAutoExists:
      if uCommonLibrary.GetCommonLib.IsExistsNewVersion then
        Synchronize(DoShowMessageUpdate);

    caMenu:
      if uCommonLibrary.GetCommonLib.IsExistsNewVersion then
        GetCommonLib.RunUpdate
      else
        MessageBox(0, 'You have latest version.', 'Sugar Plugin', MB_OK + MB_ICONINFORMATION);

     caDownloadPM:
       begin
         LError := GetCommonLib.DownloadManagerProject;

         if LError <> EmptyStr then
           MessageBoxW(0, PWideChar(LError), 'Sugar Plugin', MB_OK + MB_ICONINFORMATION);
       end;
  end;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TThreadUpdate.Execute');
  {$ENDIF}
end;

class procedure TThreadUpdate.RunDownloadMP;
var
  LUpdate: TThreadUpdate;
begin
  LUpdate := TThreadUpdate.Create(True);
  LUpdate.FreeOnTerminate := True;

  LUpdate.FCase := caDownloadPM;

  {$IFDEF D2010}
  LUpdate.Start;
  {$ELSE}
  LUpdate.Resume;
  {$ENDIF}
end;

class procedure TThreadUpdate.RunUpdateAuto(aOnlyExists: Boolean);
var
  LUpdate: TThreadUpdate;
begin
  if TSetting.GetInstance.AutoUpdate then
  begin
    LUpdate := TThreadUpdate.Create(True);
    LUpdate.FreeOnTerminate := True;

    if aOnlyExists then
      LUpdate.FCase := caAutoExists
    else
      LUpdate.FCase := caAuto;

    {$IFDEF D2010}
    LUpdate.Start;
    {$ELSE}
    LUpdate.Resume;
    {$ENDIF}
  end;
end;

class procedure TThreadUpdate.RunUpdateMenu;
var
  LUpdate: TThreadUpdate;
begin
  LUpdate := TThreadUpdate.Create(True);
  LUpdate.FreeOnTerminate := True;

  LUpdate.FCase := caMenu;

  {$IFDEF D2010}
  LUpdate.Start;
  {$ELSE}
  LUpdate.Resume;
  {$ENDIF}
end;

end.
