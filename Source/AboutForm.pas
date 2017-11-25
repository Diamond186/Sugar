unit AboutForm;

interface

{$I Compiler.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, StdCtrls, Buttons, ExtCtrls;

type
  TAboutFrm = class(TForm)
    bEmail: TBitBtn;
    Image: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lCurVersion: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure bEmailClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FAboutMainStream: TResourceStream;
  public
    class procedure ShowAbout;
  end;

implementation

{$R *.dfm}

Uses
  ShellAPI
  , uEmail
  , Utils
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;


procedure TAboutFrm.bEmailClick(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TAboutFrm.bEmailClick');
  {$ENDIF}

  TfrmEmail.ShowSendEmail;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TAboutFrm.bEmailClick');
  {$ENDIF}
end;

procedure TAboutFrm.FormCreate(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TAboutFrm.FormCreate');
  {$ENDIF}

  Label5.Font.Color := clBlue;
  lCurVersion.Caption := 'Current version ' + TUtils.GetCurrentVersion;

  FAboutMainStream := TUtils.LoadRCDATAResource(rnAboutMain);

  if Assigned(FAboutMainStream) then
    Image.Picture.Bitmap.LoadFromStream(FAboutMainStream);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TAboutFrm.FormCreate Bitmap: ' + IntToStr(Image.Picture.Bitmap.Handle));
  {$ENDIF}
end;

procedure TAboutFrm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAboutMainStream);
end;

procedure TAboutFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TAboutFrm.Label5Click(Sender: TObject);
const
  clinkedin = 'https://www.linkedin.com/in/igor-movchan-947193a5/';
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TAboutFrm.Label5Click');
  {$ENDIF}

  ShellExecute(handle, 'open', clinkedin, nil, nil, SW_SHOWNORMAL);
  Label5.Font.Color := clRed;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TAboutFrm.Label5Click');
  {$ENDIF}
end;

class procedure TAboutFrm.ShowAbout;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TAboutFrm.ShowAbout');
  {$ENDIF}

  with TAboutFrm.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TAboutFrm.ShowAbout');
  {$ENDIF}
end;

end.
