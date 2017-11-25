library common;

{$I ..\Source\Compiler.inc}

uses
  {$IFDEF TestRun}
  TestRun in '..\Source\TestRun.pas',
  {$ENDIF }
  common.update in '..\Source\CommonDLL\common.update.pas',
  common.email in '..\Source\CommonDLL\common.email.pas';

{$R *.res}

begin
end.
