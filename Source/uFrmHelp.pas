unit uFrmHelp;

interface

{$I Compiler.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, ExtCtrls;

type
  THelp = (hDuplicate, hSelect, hMultiBuffer);

  TfrmHelp = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FImage: TImage;
  public
    class procedure ShowHelp(aHelp: THelp);
  end;

implementation

{$R *.dfm}

uses
  Utils
  //, Dialogs
  {$IFDEF XE2}
  , GIFImage
  {$ELSE}
  , GIFImageD5
  {$ENDIF}
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

{ TfrmHelp }

procedure TfrmHelp.FormCreate(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmHelp.FormCreate');
  {$ENDIF}

  FImage := TImage.Create(nil);
  FImage.Align := alClient;
  FImage.Parent := Self;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmHelp.FormCreate');
  {$ENDIF}
end;

procedure TfrmHelp.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmHelp.FormKeyDown');
  {$ENDIF}

  if Key = VK_ESCAPE then Close;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmHelp.FormKeyDown');
  {$ENDIF}
end;

class procedure TfrmHelp.ShowHelp(aHelp: THelp);
var
  LStream: TResourceStream;
  LGif: TGIFImage;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmHelp.ShowHelp');
  {$ENDIF}

  LStream := nil;

  with TfrmHelp.Create(nil) do
  try
    case aHelp of
      hDuplicate:   LStream := TUtils.LoadRCDATAResource(rnDuplicate);
      hSelect:      LStream := TUtils.LoadRCDATAResource(rnSelect);
      hMultiBuffer: LStream := TUtils.LoadRCDATAResource(rnMultiBuffer);
    end;

    if Assigned(LStream) then
    begin
      LGif := TGIFImage.Create;

      try
        LGif.LoadFromStream(LStream);

        Width := LGif.Width;
        Height := LGif.Height;

        FImage.Picture.Assign(LGif);
        (FImage.Picture.Graphic as TGIFImage).Animate := True;

        DoubleBuffered := True;
        ShowModal;
      finally
        LGif.Free;
        LStream.Free;
      end;
    end;
  finally
    FImage.Free;
    Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmHelp.ShowHelp');
  {$ENDIF}
end;

end.
