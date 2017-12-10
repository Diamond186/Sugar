program SugarPM;

uses
  uOneInstanceApp,
  {$IFDEF madExcept}
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  {$ENDIF madExcept}
  Winapi.Windows,
  System.SysUtils,
  Vcl.Forms,
  MainServierFrm in 'MainServierFrm.pas' {MainPMFrm},
  uProjetsJson in 'uProjetsJson.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '';
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TMainPMFrm, MainPMFrm);
  Application.Run;
end.
