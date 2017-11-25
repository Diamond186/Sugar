unit common.update;

interface

{$I ..\Compiler.inc}

uses
  System.SysUtils, System.Classes;

function GetUpdate(const aCurrentVersion: WideString; out aNewVersion: WideString): Boolean; stdcall;
function RunUpdate(const aAllVersion: Boolean; const aCurDelphi: WideString): Boolean; stdcall;
function DownloadPM: WideString; stdcall;

exports
  GetUpdate, RunUpdate, DownloadPM;

implementation

uses
  {$IFDEF TestRun}
  TestRun ,
  {$ENDIF}
  Winapi.Windows,
  System.IOUtils,
  Winapi.WinInet,
  Data.Cloud.AmazonAPI, System.JSON, Winapi.ShellAPI;

const
  cAccountKey = '';
  cAccountName = 'AKIAJ22WJ3O3ICO6BGTQ';
  cBucketName = 'sugarupdate';
  cAppSugar = 'Sugar for Delphi';

var
  FUpdateFile: TBytes;

function DownloadPM: WideString;
var
  LError: Cardinal;
  LParam: string;
  LJson: TJSONObject;
  LArr: TJSONArray;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin DownloadPM');
  {$ENDIF}

  Result := EmptyStr;
  LError := 0;

  LJson := TJSONObject.Create;
  try
    LJson.Parse(FUpdateFile, 0);

    if LJson.TryGetValue('version', LArr) then
    begin
      LParam := LParam + '-Manager -Version=' + LArr.Items[LArr.Count - 1].Value;

      LError := ShellExecute(0, 'open', PChar(TPath.GetHomePath + '\' + cAppSugar + '\Update.exe'), PChar(LParam + ' /'), '', SW_SHOWNORMAL);
    end;

    if LError > 0 then
      Result := SysErrorMessage(LError);
  finally
    FreeAndNil(LJson);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end DownloadPM');
  {$ENDIF}
end;

function RunUpdate(const aAllVersion: Boolean; const aCurDelphi: WideString): Boolean;
{"version": ["1.0.1.2"]}
var
  LParam, LAdd: string;
  LJson: TJSONObject;
  LArr: TJSONArray;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin RunUpdate');
  {$ENDIF}

  Result := False;

  if aAllVersion then
    LParam := '-All'
  else
    LParam := '-CurDelphi=' + aCurDelphi;

  LJson := TJSONObject.Create;
  try
    LJson.Parse(FUpdateFile, 0);

    if LJson.TryGetValue('version', LArr) then
    begin
      LParam := LParam + ' -Version=' + LArr.Items[LArr.Count - 1].Value;

      if LJson.TryGetValue('additionally', LArr) then
      begin
        LAdd := LArr.ToString.Replace('[', '"').Replace(']', '"');
        LParam := LParam + ' -Add=' + LAdd;
      end;

      ShellExecute(0, 'open', PChar(TPath.GetHomePath + '\' + cAppSugar + '\Update.exe'), PChar(LParam + ' /'), '', SW_SHOWNORMAL);
      Result := True;
    end;
  finally
    FreeAndNil(LJson);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end RunUpdate');
  {$ENDIF}
end;

function GetUpdate(const aCurrentVersion: WideString; out aNewVersion: WideString): Boolean;
var
  LService: TAmazonStorageService;
  LConAmazon: TAmazonConnectionInfo;
  LStream: TStringStream;
  LJson: TJSONObject;
  LArr: TJSONArray;
  origin: cardinal;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin GetUpdate');
  {$ENDIF}

  Result := False;

  LConAmazon := TAmazonConnectionInfo.Create(nil);
  LConAmazon.AccountKey := cAccountKey;
  LConAmazon.AccountName := cAccountName;
  LConAmazon.StorageEndpoint := 's3-us-west-2.amazonaws.com';

  LService := TAmazonStorageService.Create(LConAmazon);
  try
    LStream := TStringStream.Create;
    try
      if InternetGetConnectedState(@origin, 0) then
      if LService.GetObject(cBucketName, 'Update.json', LStream) then
      begin
        LJson := TJSONObject.Create;
        try
          FUpdateFile := TEncoding.UTF8.GetBytes(LStream.DataString);
          LJson.Parse(FUpdateFile, 0);

          if LJson.TryGetValue('version', LArr) then
          begin
            aNewVersion := LArr.Items[LArr.Count - 1].Value;
            Result := aNewVersion <> aCurrentVersion;
          end;
        finally
          FreeAndNil(LJson);
        end;
      end;
    finally
      FreeAndNil(LStream);
    end;
  finally
    FreeAndNil(LService);
    FreeAndNil(LConAmazon);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end GetUpdate');
  {$ENDIF}
end;

initialization
  SetLength(FUpdateFile, 0);

finalization
  SetLength(FUpdateFile, 0);

end.
