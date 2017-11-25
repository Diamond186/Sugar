unit uMultiClipboard;

interface

uses
  Windows
  , ToolsAPI
  , SysUtils
  , Classes
  , Contnrs;

type
  TClipboardItem = class
    private
      Lock: Boolean;
    public
      Text: string;
  end;

  TMultiClipboard = class(TList)
    private
      function  GetItem(Index: Integer): string;
      function  GetLock(Index: Integer): Boolean;
      procedure SetLock(Index: Integer; const Value: Boolean);
      function  GetFirstFreeIndex: Integer;
      function  GetFirstLockIndex(aStart: Integer = 0): Integer;
    public
      procedure Clear; override;
      procedure Add(const aText: string);
      procedure Delete(Index: Integer);
      function  IndexOf(const aText: string): Integer;
      procedure Sort;

      property Text[Index: Integer]: string read GetItem; default;
      property Lock[Index: Integer]: Boolean read GetLock write SetLock;
  end;

implementation

uses
  uSetting
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
//  , Vcl.Dialogs
  ;

var
  FClipboardViewer: THandle = 0;

{ TMultiClipboard }

procedure TMultiClipboard.Add(const aText: string);
var
  LItem: TClipboardItem;
  LIndex: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.Add');
  {$ENDIF}

  if (aText <> EmptyStr)
      and (IndexOf(aText) = -1)
  then
  begin
    // Видалення останнього не блокованого елементу
    if Count + 1 > TSetting.GetInstance.ClipboardStorageSlots then
    begin
      LIndex := Count - 1;

      while LIndex > -1 do
      begin
        if not Lock[LIndex] then
        begin
          Delete(LIndex);
          Break;
        end
        else
          Dec(LIndex);
      end;
    end;

    LItem := TClipboardItem.Create;
    LItem.Text := aText;
    LItem.Lock := False;

    LIndex := GetFirstFreeIndex;
    if LIndex > -1 then
      inherited Insert(GetFirstFreeIndex, LItem)
    else
      inherited Add(LItem);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.Add');
  {$ENDIF}
end;

procedure TMultiClipboard.Clear;
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.Clear');
  {$ENDIF}

  for i := 0 to Count - 1 do
    TClipboardItem(inherited Items[i]).Free;

  inherited Clear;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.Clear');
  {$ENDIF}
end;

procedure TMultiClipboard.Delete(Index: Integer);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.Delete');
  {$ENDIF}

  if (Count > index) and (index >= 0) then
  begin
    inherited Delete(index);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.Delete');
  {$ENDIF}
end;

function TMultiClipboard.GetFirstFreeIndex: Integer;
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.GetFirstFreeIndex');
  {$ENDIF}

  Result := -1;

  if Count > 0 then
  begin
    for i := 0 to Count - 1 do
    if not Lock[i] then
    begin
      Result := i;
      Break;
    end;
  end
  else
    Result := 0;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.GetFirstFreeIndex');
  {$ENDIF}
end;

function TMultiClipboard.GetFirstLockIndex(aStart: Integer = 0): Integer;
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.GetFirstLockIndex');
  {$ENDIF}

  Result := -1;

  if Count > 0 then
  begin
    for i := aStart to Count - 1 do
    if Lock[i] then
    begin
      Result := i;
      Break;
    end;
  end
  else
    Result := 0;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.GetFirstLockIndex');
  {$ENDIF}
end;

function TMultiClipboard.GetItem(Index: Integer): string;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.GetItem');
  {$ENDIF}

  if (Count > index) and (index >= 0) then
    Result := TClipboardItem(inherited Items[index]).Text;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.GetItem');
  {$ENDIF}
end;

function TMultiClipboard.GetLock(Index: Integer): Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.GetLock');
  {$ENDIF}

  Result := False;

  if (Count > index) and (index >= 0) then
    Result := TClipboardItem(inherited Items[index]).Lock;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.GetLock');
  {$ENDIF}
end;

function TMultiClipboard.IndexOf(const aText: string): Integer;
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.IndexOf');
  {$ENDIF}

  Result := -1;

  for i := 0 to Count - 1 do
  if Text[i] = aText then
  begin
    Result := i;
    Break;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.IndexOf');
  {$ENDIF}
end;

procedure TMultiClipboard.SetLock(Index: Integer; const Value: Boolean);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.SetLock');
  {$ENDIF}

  if (Count > index) and (index >= 0) then
  begin
    TClipboardItem(inherited Items[index]).Lock := Value;
    //Insert(GetFirstFreeIndex, Extract(inherited Items[index]));
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.SetLock');
  {$ENDIF}
end;

procedure TMultiClipboard.Sort;
var
  i, f : Integer;

begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMultiClipboard.Sort');
  {$ENDIF}

  for i := 0 to Count - 2 do
  if not GetLock(i) then
  begin
    f := GetFirstLockIndex(i + 1);

    if f = -1 then
      Break
    else
      Exchange(i, f);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMultiClipboard.Sort');
  {$ENDIF}
end;

end.
