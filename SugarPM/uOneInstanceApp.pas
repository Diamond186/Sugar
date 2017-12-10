unit uOneInstanceApp;

interface

implementation

uses
 Winapi.Windows;

var
  FMutex: THandle;

function IsRunInstance: Boolean;
begin
  FMutex := CreateMutex(nil, False, 'SugarPMMutex');

  Result := (FMutex = 0) // The mutex didn't created
             or (GetLastError = ERROR_ALREADY_EXISTS); // The mutex already exists
end;

initialization
  if IsRunInstance then
    Halt;

finalization
  CloseHandle(FMutex);

end.
