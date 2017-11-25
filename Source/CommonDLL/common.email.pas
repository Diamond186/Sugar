unit common.email;

interface

{$I ..\Source\Compiler.inc}

function SendEmail(const aMessage: WideString; const aFiles: array of String; out aError: WideString): Boolean; stdcall;

exports
  SendEmail;

implementation

uses
  System.SysUtils
  , IdSMTP
  , IdSSLOpenSSL
  , IdMessage
  , IdExplicitTLSClientServerBase
  , IdGlobal
  , IdAttachmentFile
  , IdMessageParts
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

function SendEmail(const aMessage: WideString; const aFiles: array of String; out aError: WideString): Boolean; stdcall;
var
  LIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
  LIdMessage: TIdMessage;
  LIdSMTP: TIdSMTP;
  LFileName: string;
  LOldCurDir: string;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin SendEmail');
  {$ENDIF}

  aError := EmptyStr;
  Result := True;

  LIdSMTP := TIdSMTP.Create(nil);
  LIdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(LIdSMTP);

//  with FIdSSLIOHandlerSocketOpenSSL do
//  begin
//    OnStatusInfo := DoStatusInfo;
//    SSLOptions.Method := sslvSSLv3;
//    SSLOptions.Mode := sslmUnassigned;
//    SSLOptions.VerifyMode :=  [];
//    SSLOptions.VerifyDepth := 0;
//  end;

  with LIdSMTP do
  begin
    IOHandler := LIdSSLIOHandlerSocketOpenSSL;
    Host := 'smtp.gmail.com';
    Password := 'pgcxmowyglygxmjf';
    UseTLS := utUseImplicitTLS;
    Port := 465;
    Username := 'diamondmovchan@gmail.com';
  end;

  LIdMessage := TIdMessage.Create(LIdSMTP);
  with LIdMessage do
  begin
    AttachmentEncoding := 'UUE';
    CharSet := 'UTF-8';
    Encoding := meDefault;

    with FromList.Add do
    begin
      Address := 'DelphiPluginSugar';
      Text := 'DelphiPluginSugar';
    end;

    From.Address := 'DelphiPluginSugar';
    From.Text := 'DelphiPluginSugar';
    with Recipients.Add do
    begin
      Address := 'diamondmovchan@gmail.com';
      Text := 'diamondmovchan@gmail.com';
      Domain := 'gmail.com';
      User := 'diamondmovchan';
    end;

    Subject := 'DelphiPluginSuger';
    ConvertPreamble := True;

    Body.Text := aMessage;
  end;

  for LFileName in aFiles do
  with TIdAttachmentFile.Create(LIdMessage.MessageParts, LFileName) do
  begin
    ContentType := 'application/octet-stream';
    FileName    := ExtractFileName(LFileName);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('begin SendEmail Send');
  {$ENDIF}

  try
    LOldCurDir := GetCurrentDir;
    SetCurrentDir(ExtractFileDir(GetModuleName(HInstance)));

    LIdSMTP.Connect;
    try
      if LIdSMTP.Authenticate then
      begin
        LIdSMTP.Send(LIdMessage);
      end;
    finally
      LIdSMTP.Disconnect;
      SetCurrentDir(LOldCurDir);
    end;
  except
    on E: exception do
    begin
      aError := E.Message;
      Result := False;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end SendEmail');
  {$ENDIF}
end;

end.
