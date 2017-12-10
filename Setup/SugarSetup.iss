; Скрипт создан через Мастер Inno Setup Script.
; ИСПОЛЬЗУЙТЕ ДОКУМЕНТАЦИЮ ДЛЯ ПОДРОБНОСТЕЙ ИСПОЛЬЗОВАНИЯ INNO SETUP!

#define MyAppName "Sugar for Delphi"
#define MyAppVersion "1.0.2.0"
#define MyAppURL "https://www.linkedin.com/in/igor-movchan-947193a5/"

[Setup]
; Примечание: Значение AppId идентифицирует это приложение.
; Не используйте одно и тоже значение в разных установках.
; (Для генерации значения GUID, нажмите Инструменты | Генерация GUID.)
AppId={{B1546358-CA62-4942-B435-D30CFC64EE00}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher=Igor Movchan
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=Setup
OutputBaseFilename=Sugar {#MyAppVersion}
SetupIconFile=..\Image\sugar.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "default"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "compD6"; Description: "Borland Delphi 6"; Types: custom;
Name: "compD7"; Description: "Borland Delphi 7"; Types: custom;
Name: "compD2005"; Description: "Borland Delphi 2005"; Types: custom;
Name: "compD2006"; Description: "Borland Delphi 2006"; Types: custom;
Name: "compD2007"; Description: "CodeGear Delphi 2007"; Types: custom;
Name: "compD2009"; Description: "CodeGear Delphi 2009"; Types: custom;
Name: "compD2010"; Description: "CodeGear Delphi 2010"; Types: custom;
Name: "compXE"; Description: "RAD Studio XE"; Types: custom;
Name: "compXE2"; Description: "RAD Studio XE2"; Types: custom;
Name: "compXE3"; Description: "RAD Studio XE3"; Types: custom;
Name: "compXE4"; Description: "RAD Studio XE4"; Types: custom;
Name: "compXE5"; Description: "RAD Studio XE5"; Types: custom;
Name: "compXE6"; Description: "RAD Studio XE6"; Types: custom;
Name: "compXE7"; Description: "RAD Studio XE7"; Types: custom;
Name: "compXE8"; Description: "RAD Studio XE8"; Types: custom;
Name: "compSeattle"; Description: "RAD Studio 10 Seattle"; Types: custom;
Name: "compBerlin"; Description: "RAD Studio 10.1 Berlin"; Types: custom;
Name: "compTokyo"; Description: "RAD Studio 10.2 Tokyo"; Types: custom;

[Files]
Source: "App\ssleay32.dll"; DestDir: "{app}";
Source: "App\libeay32.dll"; DestDir: "{app}";
Source: "App\SugarRes.dll"; DestDir: "{app}"; flags: ignoreversion
Source: "App\Common.dll"; DestDir: "{app}"; flags: ignoreversion
Source: "App\SugarPM.exe"; DestDir: "{userappdata}\{#MyAppName}"; flags: ignoreversion
Source: "Updater\Update\Update.exe"; DestDir: "{userappdata}\{#MyAppName}"; flags: ignoreversion
Source: "App\SugarD6.dll"; DestDir: "{app}"; Components: compD6; flags: ignoreversion
Source: "App\SugarD7.dll"; DestDir: "{app}"; Components: compD7; flags: ignoreversion
Source: "App\SugarD2005.dll"; DestDir: "{app}"; Components: compD2005; flags: ignoreversion
Source: "App\SugarD2006.dll"; DestDir: "{app}"; Components: compD2006; flags: ignoreversion
Source: "App\SugarD2007.dll"; DestDir: "{app}"; Components: compD2007; flags: ignoreversion
Source: "App\SugarD2009.dll"; DestDir: "{app}"; Components: compD2009; flags: ignoreversion
Source: "App\SugarD2010.dll"; DestDir: "{app}"; Components: compD2010; flags: ignoreversion
Source: "App\SugarXE.dll"; DestDir: "{app}"; Components: compXE; AfterInstall: DoAfterInstall('XE'); flags: ignoreversion
Source: "App\SugarXE2.dll"; DestDir: "{app}"; Components: compXE2; AfterInstall: DoAfterInstall('XE2'); flags: ignoreversion
Source: "App\SugarXE3.dll"; DestDir: "{app}"; Components: compXE3; AfterInstall: DoAfterInstall('XE3'); flags: ignoreversion
Source: "App\SugarXE4.dll"; DestDir: "{app}"; Components: compXE4; AfterInstall: DoAfterInstall('XE4'); flags: ignoreversion
Source: "App\SugarXE5.dll"; DestDir: "{app}"; Components: compXE5; AfterInstall: DoAfterInstall('XE5'); flags: ignoreversion
Source: "App\SugarXE6.dll"; DestDir: "{app}"; Components: compXE6; AfterInstall: DoAfterInstall('XE6'); flags: ignoreversion
Source: "App\SugarXE7.dll"; DestDir: "{app}"; Components: compXE7; AfterInstall: DoAfterInstall('XE7'); flags: ignoreversion
Source: "App\SugarXE8.dll"; DestDir: "{app}"; Components: compXE8; AfterInstall: DoAfterInstall('XE8'); flags: ignoreversion
Source: "App\SugarSeattle.dll"; DestDir: "{app}"; Components: compSeattle; AfterInstall: DoAfterInstall('Seattle'); flags: ignoreversion
Source: "App\SugarBerlin.dll"; DestDir: "{app}"; Components: compBerlin; AfterInstall: DoAfterInstall('Berlin'); flags: ignoreversion
Source: "App\SugarTokyo.dll"; DestDir: "{app}"; Components: compTokyo; AfterInstall: DoAfterInstall('Tokyo'); flags: ignoreversion

; Примечание: Не используйте "Flags: ignoreversion" для системных файлов

[Registry]
Root: HKCU; Subkey: "SOFTWARE\Borland\Delphi\6.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD6.dll; Components: compD6; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Borland\Delphi\7.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD7.dll; Components: compD7; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Borland\BDS\3.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD2005.dll; Components: compD2005; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Borland\BDS\4.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD2006.dll; Components: compD2006; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Borland\BDS\5.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD2007.dll; Components: compD2007; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\CodeGear\BDS\6.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD2009.dll; Components: compD2009; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\CodeGear\BDS\7.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarD2010.dll; Components: compD2010; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\8.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE.dll; Components: compXE; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\9.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE2.dll; Components: compXE2; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\10.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE3.dll; Components: compXE3; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\11.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE4.dll; Components: compXE4; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\12.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE5.dll; Components: compXE5; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\14.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE6.dll; Components: compXE6; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\15.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE7.dll; Components: compXE7; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\16.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarXE8.dll; Components: compXE8; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\17.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarSeattle.dll; Components: compSeattle; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\18.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarBerlin.dll; Components: compBerlin; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\19.0\Experts"; ValueType: string; ValueName: "SugarIDE"; ValueData: {app}\SugarTokyo.dll; Components: compTokyo; Flags: uninsdeletevalue

[Code]
{ RedesignWizardFormBegin }
var
  OldEvent_ComponentsListClickCheck: TNotifyEvent;

procedure ComponentsListClickCheck(Sender: TObject); forward;

procedure RedesignWizardForm;
begin
  { Creates custom wizard page }
  with WizardForm.ComponentsList do
  begin
    OldEvent_ComponentsListClickCheck := OnClickCheck;
    OnClickCheck := @ComponentsListClickCheck;
  end;

  with WizardForm.PageDescriptionLabel do
  begin
    Left := ScaleX(37);
    Width := ScaleX(350);
  end;

  with WizardForm.PageNameLabel do
  begin
    Width := ScaleX(350);
  end;

{ ReservationBegin }

{ ReservationEnd }
end;
{ RedesignWizardFormEnd } 

procedure ComponentsListClickCheck(Sender: TObject);
var
  i: Integer;
  LEnabled: Boolean;
begin
  OldEvent_ComponentsListClickCheck(Sender);

  LEnabled := False;
  for i := 0 to Wizardform.ComponentsList.ItemCount - 1 do
  if Wizardform.ComponentsList.Checked[i] then
  begin
    LEnabled := True;
    break;
  end;

  Wizardform.NextButton.Enabled := LEnabled;
end;

function existsDelphi(const aVersion: string): boolean;
var
  LFile, LKey: string;
begin
  if aVersion = 'D6' then LKey := 'SOFTWARE%s\Borland\Delphi\6.0' else
  if aVersion = 'D7' then LKey := 'SOFTWARE%s\Borland\Delphi\7.0' else
  if aVersion = 'D2005' then LKey := 'SOFTWARE%s\Borland\BDS\3.0' else
  if aVersion = 'D2006' then LKey := 'SOFTWARE%s\Borland\BDS\4.0' else
  if aVersion = 'D2007' then LKey := 'SOFTWARE%s\Borland\BDS\5.0' else
  if aVersion = 'D2009' then LKey := 'SOFTWARE%s\CodeGear\BDS\6.0' else
  if aVersion = 'D2010' then LKey := 'SOFTWARE%s\CodeGear\BDS\7.0' else
  if aVersion = 'XE' then LKey := 'SOFTWARE%s\Embarcadero\BDS\8.0' else
  if aVersion = 'XE2' then LKey := 'SOFTWARE%s\Embarcadero\BDS\9.0' else
  if aVersion = 'XE3' then LKey := 'SOFTWARE%s\Embarcadero\BDS\10.0' else
  if aVersion = 'XE4' then LKey := 'SOFTWARE%s\Embarcadero\BDS\11.0' else
  if aVersion = 'XE5' then LKey := 'SOFTWARE%s\Embarcadero\BDS\12.0' else
  if aVersion = 'XE6' then LKey := 'SOFTWARE%s\Embarcadero\BDS\14.0' else
  if aVersion = 'XE7' then LKey := 'SOFTWARE%s\Embarcadero\BDS\15.0' else
  if aVersion = 'XE8' then LKey := 'SOFTWARE%s\Embarcadero\BDS\16.0' else
  if aVersion = 'Seattle' then LKey := 'SOFTWARE%s\Embarcadero\BDS\17.0' else
  if aVersion = 'Berlin' then LKey := 'SOFTWARE%s\Embarcadero\BDS\18.0' else
  if aVersion = 'Tokyo' then LKey := 'SOFTWARE%s\Embarcadero\BDS\19.0';

  if IsWin64 then
    LKey := Format(LKey, ['\WOW6432Node'])
  else
    LKey := Format(LKey, ['']);

  Result := RegQueryStringValue(HKEY_LOCAL_MACHINE, LKey, 'App', LFile);

  if Result then
    Result := FileExists(LFile);
end;

procedure DoAfterInstall(const aVersion: string);
var
  LKey: string;
begin
  if aVersion = 'XE' then LKey := 'SOFTWARE\Embarcadero\BDS\8.0\Experts' else
  if aVersion = 'XE2' then LKey := 'SOFTWARE\Embarcadero\BDS\9.0\Experts' else
  if aVersion = 'XE3' then LKey := 'SOFTWARE\Embarcadero\BDS\10.0\Experts' else
  if aVersion = 'XE4' then LKey := 'SOFTWARE\Embarcadero\BDS\11.0\Experts' else
  if aVersion = 'XE5' then LKey := 'SOFTWARE\Embarcadero\BDS\12.0\Experts' else
  if aVersion = 'XE6' then LKey := 'SOFTWARE\Embarcadero\BDS\14.0\Experts' else
  if aVersion = 'XE7' then LKey := 'SOFTWARE\Embarcadero\BDS\15.0\Experts' else
  if aVersion = 'XE8' then LKey := 'SOFTWARE\Embarcadero\BDS\16.0\Experts' else
  if aVersion = 'Seattle' then LKey := 'SOFTWARE\Embarcadero\BDS\17.0\Experts' else
  if aVersion = 'Berlin' then LKey := 'SOFTWARE\Embarcadero\BDS\18.0\Experts' else
  if aVersion = 'Tokyo' then LKey := 'SOFTWARE\Embarcadero\BDS\19.0\Experts';

  RegDeleteValue(HKEY_CURRENT_USER, LKey, 'SugerDLL');
  DeleteFile(ExpandConstant('{app}') + '\SugerDLL.dll');
end;

procedure CurPageChanged(CurPageID: Integer);
var
  i: Integer;
begin
  if CurPageID = wpSelectComponents then
  with Wizardform.ComponentsList do
  begin
    Checked[0] := existsDelphi('D6');
    ItemEnabled[0] := Checked[0];

    Checked[1] := existsDelphi('D7');
    ItemEnabled[1] := Checked[1];

    Checked[2] := existsDelphi('D2005');
    ItemEnabled[2] := Checked[2];

    Checked[3] := existsDelphi('D2006');
    ItemEnabled[3] := Checked[3];

    Checked[4] := existsDelphi('D2007');
    ItemEnabled[4] := Checked[4];

    Checked[5] := existsDelphi('D2009');
    ItemEnabled[5] := Checked[5];

    Checked[6] := existsDelphi('D2010');
    ItemEnabled[6] := Checked[6];

    Checked[7] := existsDelphi('XE');
    ItemEnabled[7] := Checked[7];

    Checked[8] := existsDelphi('XE2');
    ItemEnabled[8] := Checked[8];

    Checked[9] := existsDelphi('XE3');
    ItemEnabled[9] := Checked[9];

    Checked[10] := existsDelphi('XE4');
    ItemEnabled[10] := Checked[10];

    Checked[11] := existsDelphi('XE5');
    ItemEnabled[11] := Checked[11];

    Checked[12] := existsDelphi('XE6');
    ItemEnabled[12] := Checked[12];

    Checked[13] := existsDelphi('XE7');
    ItemEnabled[13] := Checked[13];

    Checked[14] := existsDelphi('XE8');
    ItemEnabled[14] := Checked[14];

    Checked[15] := existsDelphi('Seattle');
    ItemEnabled[15] := Checked[15];

    Checked[16] := existsDelphi('Berlin');
    ItemEnabled[16] := Checked[16];

    Checked[17] := existsDelphi('Tokyo');
    ItemEnabled[17] := Checked[17];

    Wizardform.NextButton.Enabled := False;
    for i := 0 to Wizardform.ComponentsList.ItemCount - 1 do
    if Checked[i] then
    begin
      Wizardform.NextButton.Enabled := True;
      break;
    end;
  end;
end;

procedure InitializeWizard();
begin
  RedesignWizardForm;
end;
