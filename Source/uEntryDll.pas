unit uEntryDll;

interface

{$I Compiler.inc}

uses
  ToolsAPI
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
                    RegisterProc: TWizardRegisterProc;
                    var Terminate: TWizardTerminateProc): Boolean; stdcall;

exports
  InitWizard name WizardEntryPoint;

{$IFNDEF DLL}
//procedure Register;
{$ENDIF}

implementation

uses
  uWizardManager
//  , Vcl.Dialogs
//  , SysUtils
  ;

{$IFNDEF DLL}
procedure Register;
begin
  varWizardManager := TWizardManager.Create;
  varWizardManager.InitializeWizard(BorlandIDEServices);
end;
{$ENDIF}

// Remove Wizard Interface
procedure FinalizeWizard;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin FinalizeWizard');
  {$ENDIF}

  varWizardManager.FinalizeWizard;
  varWizardManager := nil;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end FinalizeWizard');
  {$ENDIF}
end;

function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin InitWizard');
  {$ENDIF}

  varWizardManager := TWizardManager.Create;
  Terminate := FinalizeWizard;
  Result := varWizardManager.InitializeWizard(BorlandIDEServices);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end InitWizard');
  {$ENDIF}
end;

end.
