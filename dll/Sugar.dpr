library Sugar;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory  manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.}

{$R *.res}

{$I ..\Source\Compiler.inc}

uses
  Utils in '..\Source\Utils.pas',
  uEntryDll in '..\Source\uEntryDll.pas',
  uWizardManager in '..\Source\uWizardManager.pas',
  KeyboardBinding in '..\Source\KeyboardBinding.pas',
  uMenuSugar in '..\Source\uMenuSugar.pas',
  SelectBlockCodeU in '..\Source\SelectBlockCodeU.pas',
  uEmail in '..\Source\uEmail.pas',
  uSetting in '..\Source\uSetting.pas',
  uMultiClipboard in '..\Source\uMultiClipboard.pas',
  frmMultiClipboard in '..\Source\frmMultiClipboard.pas',
  uFrmHelp in '..\Source\uFrmHelp.pas',
  {$IFDEF TestRun}
  TestRun in '..\Source\TestRun.pas',
  {$ENDIF }
  dmImages in '..\Source\dmImages.pas',
  AboutForm in '..\Source\AboutForm.pas' {AboutFrm},
  SettingForm in '..\Source\SettingForm.pas' {SettingFrm},
  uMessageEditor in '..\Source\uMessageEditor.pas' {MesEditorForm},
  uCommonLibrary in '..\Source\uCommonLibrary.pas',
  uThreadUpdate in '..\Source\uThreadUpdate.pas',
  uIDENotifier in '..\Source\uIDENotifier.pas';

begin

end.
