unit uProjetsJson;

interface

uses
  System.IniFiles;

type
  TProject = record
    private
      FGuid: string;
      FName: string;
      FGroupID: string;
      FGroupExpanded: Boolean;
      FGroupName: string;
      FPath: string;
      FDelphi: String;
      FLastCompile: TDateTime;
    public
      property Guid: string read FGuid;
      property Name: string read FName;
      property GroupID: string read FGroupID;
      property GroupExpanded: Boolean read FGroupExpanded;
      property GroupName: string read FGroupName;
      property Path: string read FPath;
      property Delphi: String read FDelphi;
      property LastCompile: TDateTime read FLastCompile;
  end;

  TProjets = class(TMemIniFile)
  private
    const _Name = 'Name';
    const _Path = 'Path';
    const _GroupID = 'GroupID';
    const _GroupName = 'GroupName';
    const _GroupExpanded = 'GroupExpanded';
    const _Delphi = 'Delphi';
    const _LastCompile = 'LastCompile';
    const _FormatDate = 'YYYY-MM-DD';
    const _FormatTime = 'hh:nn:ss';
    const _FormatDateTime = _FormatDate + ' ' + _FormatTime;

    function  GetProject(const aGuid: string): TProject;
    function GetProjectOfIndex(Index: Integer): TProject;
  public
    function AddProject(const aPath, aDelphi: String): String;
    function Count: Integer;
    function Exists(const aPath: string): string;

    procedure UpdateProject(const aGuid: string; const aDelphi: string);
    procedure Detete(const aIndex: Integer);
    procedure AddProjectToGroup(const aProjGuid: string; aIndex: Integer);
    procedure RemoveProjectFromGroup(const aProgID: string);

    procedure GroupRemane(const aNewName: string; const aIndex: Integer);
    procedure GroupExpanded(const aExpanded: Boolean; const aIndex: Integer);
    procedure GroupDelete(const aProjID: string);

    property Project[const Index: string]: TProject read GetProject; default;

    class function LoadFromFile(const aFileName: string): TProjets;
  end;

implementation

uses
  System.Classes, System.SysUtils, System.Variants;

{ TProjetsJson }

function TProjets.AddProject(const aPath, aDelphi: String): String;
var
  LGuid: TGUID;
  LPath: string;
begin
  CreateGUID(LGuid);
  Result := GUIDToString(LGuid);

  WriteString(Result, _Name, ExtractFileName(aPath).Replace(ExtractFileExt(aPath), EmptyStr));

  if ExtractFileExt(aPath).Equals('.dproj') then
    LPath := ChangeFileExt(aPath, '.dpr')
  else
    LPath := aPath;

  WriteString(Result, _Path, LPath);
  WriteString(Result, _Delphi, aDelphi);
  WriteString(Result, _LastCompile, FormatDateTime(_FormatDateTime, Now));

  UpdateFile;
end;

procedure TProjets.AddProjectToGroup(const aProjGuid: string; aIndex: Integer);
begin
  with GetProjectOfIndex(aIndex) do
  begin
    WriteString(aProjGuid, _GroupID, GroupID);
    WriteString(aProjGuid, _GroupName, GroupName);
    WriteBool(aProjGuid, _GroupExpanded, GroupExpanded);
    UpdateFile;
  end;
end;

function TProjets.Count: Integer;
var
  LList: TStringList;
begin
  LList := TStringList.Create;
  try
    ReadSections(LList);
    Result := LList.Count;
  finally
    LList.Free;
  end;
end;

procedure TProjets.Detete(const aIndex: Integer);
begin
  EraseSection(GetProjectOfIndex(aIndex).FGuid);
  UpdateFile;
end;

function TProjets.Exists(const aPath: string): string;
var
  LList: TStringList;
  LStr, LPathIn, LPathOut: string;
begin
  Result := EmptyStr;

  if not aPath.IsEmpty then
  begin
    // Remove extension of file
    LPathIn := ExtractFilePath(aPath) + ExtractFileName(aPath).Replace(ExtractFileExt(aPath), EmptyStr);

    LList := TStringList.Create;
    try
      ReadSections(LList);

      for LStr in LList do
      begin
        LPathOut := ReadString(LStr, _Path, EmptyStr);
        LPathOut := ExtractFilePath(LPathOut) + ExtractFileName(LPathOut).Replace(ExtractFileExt(LPathOut), EmptyStr);

        if LPathIn.Equals(LPathOut) then
        begin
          Result := LStr;
          Break;
        end;
      end;
    finally
      LList.Free;
    end;
  end;
end;

function TProjets.GetProjectOfIndex(Index: Integer): TProject;
var
  LList: TStringList;
begin
  LList := TStringList.Create;
  try
    ReadSections(LList);
    Assert((Index >= 0) or (LList.Count < Index), 'Not found project');

    Result := GetProject(LList[Index]);
  finally
    LList.Free;
  end;
end;

function TProjets.GetProject(const aGuid: string): TProject;
var
  LList: TStringList;
  LStr: string;
  LFormatSetting: TFormatSettings;
begin
  Assert(not aGuid.IsEmpty, 'Not found project');

  LList := TStringList.Create;
  try
    ReadSections(LList);

    for LStr in LList do
    if LStr.Equals(aGuid) then
    begin
      LFormatSetting := TFormatSettings.Create;
      LFormatSetting.ShortDateFormat := _FormatDate;
      LFormatSetting.ShortTimeFormat := _FormatTime;
      LFormatSetting.DateSeparator := '-';
      LFormatSetting.TimeSeparator := ':';

      Result.FGuid := aGuid;
      Result.FName := ReadString(aGuid, _Name, EmptyStr);
      Result.FGroupName := ReadString(aGuid, _GroupName, EmptyStr);
      Result.FGroupID := ReadString(aGuid, _GroupID, EmptyStr);
      Result.FGroupExpanded := ReadBool(aGuid, _GroupExpanded, True);
      Result.FPath := ReadString(aGuid, _Path, EmptyStr);
      Result.FDelphi := ReadString(aGuid, _Delphi, EmptyStr);
      Result.FLastCompile := StrToDateTime(ReadString(aGuid, _LastCompile, EmptyStr), LFormatSetting);

      Break;
    end;
  finally
    LList.Free;
  end;
end;

class function TProjets.LoadFromFile(const aFileName: string): TProjets;
var
  LFile: TFileStream;
begin
  if not FileExists(aFileName) then
  begin
    LFile := TFileStream.Create(aFileName, System.Classes.fmCreate);
    LFile.Free;
  end;

  Result := TProjets.Create(aFileName);
end;

procedure TProjets.RemoveProjectFromGroup(const aProgID: string);
begin
  with GetProject(aProgID) do
  begin
    DeleteKey(Guid, _GroupID);
    DeleteKey(Guid, _GroupName);
    DeleteKey(Guid, _GroupExpanded);

    UpdateFile;
  end;
end;

procedure TProjets.GroupDelete(const aProjID: string);
var
  LStr: string;
  LList: TStringList;
begin
  with GetProject(aProjID) do
  begin
    LList := TStringList.Create;
    try
      ReadSections(LList);

      for LStr in LList do
      if GetProject(LStr).GroupID = GroupID then
      begin
        DeleteKey(GetProject(LStr).Guid, _GroupID);
        DeleteKey(GetProject(LStr).Guid, _GroupName);
        DeleteKey(GetProject(LStr).Guid, _GroupExpanded);
      end;
    finally
      LList.Free;
    end;

    UpdateFile;
  end;
end;

procedure TProjets.GroupExpanded(const aExpanded: Boolean; const aIndex: Integer);
var
  LStr: string;
  LList: TStringList;
begin
  with GetProjectOfIndex(aIndex) do
  begin
    LList := TStringList.Create;
    try
      ReadSections(LList);

      for LStr in LList do
      if GetProject(LStr).GroupID = GroupID then
        WriteBool(GetProject(LStr).Guid, _GroupExpanded, aExpanded);
    finally
      LList.Free;
    end;

    UpdateFile;
  end;
end;

procedure TProjets.GroupRemane(const aNewName: string; const aIndex: Integer);
var
  LGuid: TGUID;
  LStr: string;
  LList: TStringList;
begin
  with GetProjectOfIndex(aIndex) do
  begin
    if GroupID.IsEmpty then
    begin
      CreateGUID(LGuid);

      WriteString(FGuid, _GroupID, GUIDToString(LGuid));
      WriteString(FGuid, _GroupName, aNewName);
    end
    else
    begin
      LList := TStringList.Create;
      try
        ReadSections(LList);

        for LStr in LList do
        if GetProject(LStr).GroupID = GroupID then
          WriteString(GetProject(LStr).Guid, _GroupName, aNewName);
      finally
        LList.Free;
      end;
    end;

    UpdateFile;
  end;
end;

procedure TProjets.UpdateProject(const aGuid: string; const aDelphi: string);
var
  LProj: TProject;
begin
  if not aGuid.IsEmpty then
  begin
    LProj.FGuid := aGuid;
    LProj := GetProject(aGuid);

    if not LProj.Guid.IsEmpty then
    begin
      LProj.FDelphi := aDelphi;
      LProj.FLastCompile := Now;

      WriteString(aGuid, _Delphi, aDelphi);
      WriteString(aGuid, _LastCompile, FormatDateTime(_FormatDateTime, Now));
      UpdateFile;
    end;
  end;
end;

end.

