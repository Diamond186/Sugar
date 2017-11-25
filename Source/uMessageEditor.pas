unit uMessageEditor;

interface

{$I Compiler.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, ExtCtrls, StdCtrls;

type
  TMesEditorForm = class(TForm)
    ImageClose: TImage;
    gbMessage: TGroupBox;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageCloseClick(Sender: TObject);
  private
    FEditControl: TWinControl;

    procedure LoadCloseImage;
    procedure GetPosition(out aLeft, aTop: Integer);
    procedure DoClickUpdate(Sender:TObject; Anchor: string);
  public
    class procedure ShowMessageEditorUpdate(const aCaption: string);
  end;

implementation

{$R *.dfm}

uses
  Utils
  , htmlabel
  , uThreadUpdate
  {$IFDEF TestRun}
  , TestRun
  , Dialogs
  {$ENDIF}
  ;

{ TMesEditorForm }

procedure TMesEditorForm.DoClickUpdate(Sender:TObject; Anchor: string);
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TMesEditorForm.DoClickUpdate');
  {$ENDIF}

  TThreadUpdate.RunUpdateAuto(False);
  Close;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TMesEditorForm.DoClickUpdate');
  {$ENDIF}
end;

procedure TMesEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TMesEditorForm.ShowMessageEditorUpdate');
  {$ENDIF}

  Action := caFree;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TMesEditorForm.FormClose');
  {$ENDIF}
end;

procedure TMesEditorForm.GetPosition(out aLeft, aTop: Integer);
var
  LPoint: TPoint;
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TMesEditorForm.GetPosition');
  {$ENDIF}

  LPoint.X := FEditControl.ClientWidth - Width - 5;
  LPoint.Y := FEditControl.ClientHeight - Height - 25;

//  {$IFDEF TestRun}
//    TTestRun.AddMarker('LPoint.X: ' + LPoint.X.ToString + #10#13 +
//                       'LPoint.Y: ' + LPoint.Y.ToString);
//  {$ENDIF}

  LPoint := FEditControl.ClientToParent(LPoint, FEditControl.Parent.Parent);

//  {$IFDEF TestRun}
//    TTestRun.AddMarker('LPoint.X: ' + LPoint.X.ToString + #10#13 +
//                       'LPoint.Y: ' + LPoint.Y.ToString);
//  {$ENDIF}

  aTop := LPoint.Y;
  aLeft := LPoint.X;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TMesEditorForm.GetPosition');
  {$ENDIF}
end;

procedure TMesEditorForm.ImageCloseClick(Sender: TObject);
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TMesEditorForm.ImageCloseClick');
  {$ENDIF}

  Close;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TMesEditorForm.ImageCloseClick');
  {$ENDIF}
end;

procedure TMesEditorForm.LoadCloseImage;
var
  LBM: TBitmap;
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TMesEditorForm.LoadCloseImage');
  {$ENDIF}

  LBM := TBitmap.Create;
  try
    TUtils.LoadBitmap(LBM, rnClose);
    ImageClose.Picture.Assign(LBM);
  finally
    FreeAndNil(LBM);
  end;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TMesEditorForm.LoadCloseImage');
  {$ENDIF}
end;

class procedure TMesEditorForm.ShowMessageEditorUpdate(const aCaption: string);
var
  LLeft, LTop: Integer;
  LLabel: THTMLabel;
  LRGN: HRGN;
  LDefault: Boolean;
begin
  {$IFDEF TestRun}
    TTestRun.AddMarker('begin TMesEditorForm.ShowMessageEditorUpdate');
  {$ENDIF}

  with TMesEditorForm.Create(Application) do
  begin
    gbMessage.Caption := aCaption;
    LDefault := False;

    FEditControl := TUtils.OtaGetCurrentEditControl;

    if not Assigned(FEditControl) then
    begin
      LDefault := True;
      FEditControl := TUtils.OtaGetDefaultEditWindow;
    end;

    if Assigned(FEditControl) then
    begin
      LoadCloseImage;
      GetPosition(LLeft, LTop);

      Parent := FEditControl.Parent.Parent;

      LRGN := CreateRoundRectRgn(0,// x-координата левого верхнего угла региона
      0,            // y-координата левого верхнего угла региона
      ClientWidth,  // x-координата нижнего правого угла региона
      ClientHeight, // y-координата нижнего правого угла региона
      10,           // высота эллипса закругленного угла
      10);          // ширина эллипса загругленного угла

      SetWindowRgn(Handle, LRGN, True);

      LLabel := THTMLabel.Create(gbMessage);
      LLabel.Parent := gbMessage;
      LLabel.Left := 24;
      LLabel.Top := 20;

      LLabel.HTMLText.Add('The Sugar plugin has a new version.');
      LLabel.HTMLText.Add('Are you want <a href="%"><b>update</b></a> now ?');
      LLabel.HTMLText.Add('Will need to be restart IDE.');
      LLabel.AutoSizing := True;
      LLabel.Width := 224;
      LLabel.OnAnchorClick := DoClickUpdate;

      Show;
      Visible := False;

      Top := LTop;

      if LDefault then
        Left := LLeft - 40
      else
        Left := LLeft;

      Visible := True;
    end
    else
      Free;
  end;

  {$IFDEF TestRun}
    TTestRun.AddMarker('end TMesEditorForm.ShowMessageEditorUpdate');
  {$ENDIF}
end;

end.
