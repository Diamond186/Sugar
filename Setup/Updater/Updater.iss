; Скрипт создан через Мастер Inno Setup Script.
; ИСПОЛЬЗУЙТЕ ДОКУМЕНТАЦИЮ ДЛЯ ПОДРОБНОСТЕЙ ИСПОЛЬЗОВАНИЯ INNO SETUP!

#define MyAppName "Sugar for Delphi"
#define MyAppVersion "1.0.0.0"
#define MyAppURL "https://www.linkedin.com/in/igor-movchan-947193a5/"

[Setup]
AppId={{ED08A734-9C34-44B5-AA25-8C5ED45F1CC0}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={pf}\{#MyAppName}
DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=Update
OutputBaseFilename=Update
SetupIconFile=..\..\GroupProjects\Image\sugar.ico
Compression=lzma
SolidCompression=yes
ExtraDiskSpaceRequired = 1048576
DisableWelcomePage=yes
PrivilegesRequired=admin

#include <idp.iss>

[Languages]
Name: "default"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "UNZIP.EXE"; DestDir:{tmp}; Flags: deleteafterinstall

// Перевірка файлів на можлість заміни або показується процес який їх тримає
[InstallDelete]
Type: files; Name: "{app}\SugarD6.dll"
Type: files; Name: "{app}\SugarD7.dll"
Type: files; Name: "{app}\SugarD2005.dll"
Type: files; Name: "{app}\SugarD2006.dll"
Type: files; Name: "{app}\SugarD2007.dll"
Type: files; Name: "{app}\SugarD2009.dll"
Type: files; Name: "{app}\SugarD2010.dll"
Type: files; Name: "{app}\SugarXE.dll"
Type: files; Name: "{app}\SugarXE2.dll"
Type: files; Name: "{app}\SugarXE3.dll"
Type: files; Name: "{app}\SugarXE4.dll"
Type: files; Name: "{app}\SugarXE5.dll"
Type: files; Name: "{app}\SugarXE6.dll"
Type: files; Name: "{app}\SugarXE7.dll"
Type: files; Name: "{app}\SugarXE8.dll"
Type: files; Name: "{app}\SugarSeattle.dll"
Type: files; Name: "{app}\SugarBerlin.dll"
Type: files; Name: "{app}\SugarTokyo.dll"
Type: files; Name: "{app}\SugarRes.dll"
Type: files; Name: "{app}\common.dll"
;Type: files; Name: "{app}\SugarPM.exe"

[Code]
{ RedesignWizardFormBegin } // Не удалять эту строку!
// Не изменять эту секцию. Она создана автоматически.

// Не изменять эту секцию. Она создана автоматически.
{ RedesignWizardFormEnd } // Не удалять эту строку!

var
  FAllVersion: boolean;
  FCurrentDelphi, FVersion: string;
  FAddList: TStringList;
  FManager: boolean;

function InitializeSetup(): Boolean;
var
   i, LIndex: Integer;
   LValue: string;
begin
  // Якщо немає вхідних параметрів, то закривається апдейтер
  Result := (ParamCount > 1);

  if Result then
  begin
    // Парсинг вхідних параметрів
    FAddList := TStringList.Create;

    //MsgBox(GetCmdTail, mbError, MB_OK);
    FAllVersion := False;
    FManager := False;

    for i := 0 to ParamCount - 1 do
    begin
      //MsgBox(ParamStr(i), mbError, MB_OK);

      if ParamStr(i) = '-All' then
      begin
        FAllVersion := True;
        //MsgBox('-LAllVersion', mbError, MB_OK);
      end
      else
      if pos('-CurDelphi', ParamStr(i)) > 0 then
      begin
        FCurrentDelphi := ParamStr(i);
        Delete(FCurrentDelphi, 1, 11);
        //MsgBox(FCurrentDelphi, mbError, MB_OK);
      end else
      if pos('-Version', ParamStr(i)) > 0 then
      begin
        FVersion := ParamStr(i);
        Delete(FVersion, 1, 9);
        //MsgBox(FVersion, mbError, MB_OK);
      end else
      if pos('-Add', ParamStr(i)) > 0 then
      begin
        LValue := ParamStr(i);
        Delete(LValue, 1, 5);

        while LValue <> '' do
        begin
          LIndex := pos(',', LValue);

          if LIndex > 0 then
          begin
            FAddList.Add(Copy(LValue, 1, LIndex - 1));
            Delete(LValue, 1, LIndex);
          end
          else
          begin
            FAddList.Add(LValue);
            LValue := ''; // break;
          end;
        end;

        //MsgBox(FAddList.Text, mbError, MB_OK);
      end
      else
      if ParamStr(i) = '-Manager' then
      begin
        FManager := True;
      end;
    end;
  end;
end;

// Додаються до списку завантаження файли або зберігаються в тимчасовій папці
procedure AddToDownloadList(const aDelphi, aKeyValue, aFileName: string);
begin
  if RegValueExists(HKCU, aKeyValue, 'SugarIDE') then
    if FAllVersion or (FCurrentDelphi = aDelphi) then
      idpAddFile('https://sugarupdate.s3.amazonaws.com/' + FVersion + '/' + aFileName + '.zip', ExpandConstant('{tmp}\' + aFileName + '.zip'))
    else
      FileCopy(ExpandConstant('{pf}\Sugar for Delphi\' + aFileName + '.dll'), ExpandConstant('{tmp}\' + aFileName + '.dll'), False);
end;

procedure InitializeWizard();
var
  i: Integer;
begin
  AddToDownloadList('D6', 'SOFTWARE\Borland\Delphi\6.0\Experts', 'SugarD6');
  AddToDownloadList('D7', 'SOFTWARE\Borland\Delphi\7.0\Experts', 'SugarD7');
  AddToDownloadList('D2005', 'SOFTWARE\Borland\BDS\3.0\Experts', 'SugarD2005');
  AddToDownloadList('D2006', 'SOFTWARE\Borland\BDS\4.0\Experts', 'SugarD2006');
  AddToDownloadList('D2007', 'SOFTWARE\Borland\BDS\5.0\Experts', 'SugarD2007');
  AddToDownloadList('D2009', 'SOFTWARE\CodeGear\BDS\6.0\Experts', 'SugarD2009');
  AddToDownloadList('D2010', 'SOFTWARE\CodeGear\BDS\7.0\Experts', 'SugarD2010');
  AddToDownloadList('XE', 'SOFTWARE\Embarcadero\BDS\8.0\Experts', 'SugarXE');
  AddToDownloadList('XE2', 'SOFTWARE\Embarcadero\BDS\9.0\Experts', 'SugarXE2');
  AddToDownloadList('XE3', 'SOFTWARE\Embarcadero\BDS\10.0\Experts', 'SugarXE3');
  AddToDownloadList('XE4', 'SOFTWARE\Embarcadero\BDS\11.0\Experts', 'SugarXE4');
  AddToDownloadList('XE5', 'SOFTWARE\Embarcadero\BDS\12.0\Experts', 'SugarXE5');
  AddToDownloadList('XE6', 'SOFTWARE\Embarcadero\BDS\14.0\Experts', 'SugarXE6');
  AddToDownloadList('XE7', 'SOFTWARE\Embarcadero\BDS\15.0\Experts', 'SugarXE7');
  AddToDownloadList('XE8', 'SOFTWARE\Embarcadero\BDS\16.0\Experts', 'SugarXE8');
  AddToDownloadList('Seattle', 'SOFTWARE\Embarcadero\BDS\17.0\Experts', 'SugarSeattle');
  AddToDownloadList('Berlin', 'SOFTWARE\Embarcadero\BDS\18.0\Experts', 'SugarBerlin');
  AddToDownloadList('Tokyo', 'SOFTWARE\Embarcadero\BDS\19.0\Experts', 'SugarTokyo');

  // Додаткові файли
  for i := 0 to FAddList.Count - 1 do
    idpAddFile('https://sugarupdate.s3.amazonaws.com/' + FVersion + '/' + FAddList[i] + '.zip', ExpandConstant('{tmp}\' + FAddList[i] + '.zip'));

  // Зберігаємо файли
  FileCopy(ExpandConstant('{pf}\Sugar for Delphi\SugarRes.dll'), ExpandConstant('{tmp}\SugarRes.dll'), False);
  FileCopy(ExpandConstant('{pf}\Sugar for Delphi\common.dll'), ExpandConstant('{tmp}\common.dll'), False);

  if not FManager
     and FileExists(ExpandConstant('{pf}\Sugar for Delphi\SugarPM.exe'))
  then
    FileCopy(ExpandConstant('{pf}\Sugar for Delphi\SugarPM.exe'), ExpandConstant('{tmp}\SugarPM.exe'), False);

  if FManager then
    idpAddFile('https://sugarupdate.s3.amazonaws.com/' + FVersion + '/SugarPM.zip', ExpandConstant('{tmp}\SugarPM.zip'));

  idpDownloadAfter(wpReady);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpReady then begin
    WizardForm.NextButton.Caption := 'Update';
    WizardForm.PageNameLabel.Caption := 'Ready to Update';
    WizardForm.PageDescriptionLabel.Caption := 'Is now ready to begin updating {#MyAppName}.';
    WizardForm.ReadyLabel.Caption := 'Click Update to continue with the updating.';
  end;
end;

// Роззіповується файл
procedure unzip(const SourceFile: string);
var
  ResultCode: Integer;
  LParam, LPath: string;
begin
  if SourceFile = 'SugarPM.zip' then
  begin
    LParam := '-o "' + SourceFile + '" -d "' + ExpandConstant('{userappdata}\{#MyAppName}"');
    LPath := ExpandConstant('"{userappdata}\{#MyAppName}\SugarPM.exe"');
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', 'SugarManagerProject', LPath);
  end
  else
    LParam := '-o "' + SourceFile + '" -d "' + ExpandConstant('{app}"');
  
  // Launch unzip and wait for it to terminate
  if not Exec(ExpandConstant('{tmp}\UNZIP.EXE'), LParam, '', SW_HIDE, ewWaitUntilIdle, ResultCode) then
  begin
    MsgBox('Error.' + #10#13 + SysErrorMessage(ResultCode), mbError, MB_OK);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  FindRec: TFindRec;
begin
  if CurStep = ssPostInstall then
  begin
    // Відновлюємо та роззіповуємо файли
    if FindFirst(ExpandConstant('{tmp}') + '\*.*', FindRec) then
    try
      repeat
        if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
          if ExtractFileExt(FindRec.Name) = '.zip' then
            // Copy downloaded files to application directory
            unzip(FindRec.Name)
          else
          if (FindRec.Name <> 'idp.dll') and (ExtractFileExt(FindRec.Name) = '.dll') then
            FileCopy(ExpandConstant('{tmp}\' + FindRec.Name), ExpandConstant('{app}\' + FindRec.Name), True);
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;

    FAddList.Free;
  end;
end;

[ISFormDesigner]
WizardForm=FF0A005457495A415244464F524D003010A203000054504630F10B5457697A617264466F726D0A57697A617264466F726D0C436C69656E744865696768740368010B436C69656E74576964746803F1010C4578706C696369744C65667402000B4578706C69636974546F7002000D4578706C6963697457696474680301020E4578706C69636974486569676874038F010D506978656C73506572496E636802600A54657874486569676874020D00F10C544E65774E6F7465626F6F6B0D4F757465724E6F7465626F6F6B00F110544E65774E6F7465626F6F6B506167650B57656C636F6D65506167650D4578706C69636974576964746803F1010E4578706C6963697448656967687403390100F10E544E6577537461746963546578740D57656C636F6D654C6162656C320743617074696F6E06C9546869732077696C6C20757064617465207B234D794170704E616D657D2076657273696F6E207B234D7941707056657273696F6E7D206F6E20796F757220636F6D70757465722E0D0A0D0A4974206973207265636F6D6D656E646564207468617420796F7520636C6F736520616C6C206F74686572206170706C69636174696F6E73206265666F726520636F6E74696E75696E672E0D0A0D0A436C69636B204E65787420746F20636F6E74696E75652C206F722043616E63656C20746F20657869742053657475702E000000F110544E65774E6F7465626F6F6B5061676509496E6E6572506167650D4578706C69636974576964746803F1010E4578706C6963697448656967687403390100F10C544E65774E6F7465626F6F6B0D496E6E65724E6F7465626F6F6B00F110544E65774E6F7465626F6F6B50616765095265616479506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650D507265706172696E67506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650E496E7374616C6C696E67506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED000000F110544E65774E6F7465626F6F6B506167650D496E666F4166746572506167650D4578706C69636974576964746803A1010E4578706C6963697448656967687403ED0000000000F110544E65774E6F7465626F6F6B506167650C46696E6973686564506167650D4578706C69636974576964746803F1010E4578706C6963697448656967687403390100000000

