unit uEmail;

interface

{$I ..\Source\Compiler.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms
  , Dialogs
  , StdCtrls,
  ExtCtrls, PictureContainer;

type
  {$IFNDEF XE7}
  TArrayString = array of string;
  {$ENDIF}

  TfrmEmail = class(TForm)
    mBody: TMemo;
    bSend: TButton;
    bAttach: TButton;
    ScrollBox: TScrollBox;
    FlowPanel: TPanel;
    procedure bSendClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mBodyChange(Sender: TObject);
    procedure bAttachClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPictureContainer: TPictureContainer;
    FFileList: TStringList;

    procedure DoAnchorClick(Sender: TObject; Anchor: string);
    function FileListToArray: {$IFDEF XE7}TArray<String>{$ELSE}TArrayString{$ENDIF};
    //procedure DoStatusInfo(const Msg: string);
  public
    class procedure ShowSendEmail;
  end;

implementation

{$R *.dfm}

uses
   HTMLabel
  {$IFDEF XE7}
  , System.Threading
  {$ENDIF}
  , Utils
  , uCommonLibrary
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

const
  cHTMLPicture = ' <A href="%s"><IMG width="16" height="16" src="Close"></A>';

{ TfrmEmail }

procedure TfrmEmail.bAttachClick(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.bAttachClick');
  {$ENDIF}

  with TOpenDialog.Create(nil) do
  try
    if Execute and FileExists(FileName) then
    begin
      FlowPanel.AutoSize := False;
      FlowPanel.Width := 460;

      with THTMLabel.Create(self) do
      begin
        Align := alTop;
        Parent := FlowPanel;
        AutoSizing := True;
        AutoSizeType := asBoth;
        Width := 330;
        PictureContainer := Self.FPictureContainer;
        HTMLText.Text := FileName + Format(cHTMLPicture, [FileName]);
        OnAnchorClick := DoAnchorClick;
      end;

      FlowPanel.AutoSize := True;
    end;
  finally
    Free;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.bAttachClick');
  {$ENDIF}
end;

procedure TfrmEmail.bSendClick(Sender: TObject);
var
{$IFDEF XE7}
  LTask: ITask;
{$ENDIF}
  LError: WideString;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.bSendClick');
  {$ENDIF}

  bSend.Enabled := False;
  mBody.ReadOnly := True;

  {$IFDEF XE7}
  LTask := TTask.Run(procedure
                     begin
  {$ENDIF}
                       GetCommonLib.SendEmail(mBody.Lines.Text, FileListToArray, LError);
  {$IFDEF XE7}
                     end);

  TTask.Run(procedure
            begin
              TTask.WaitForAny(LTask);

              TThread.Queue(TThread.CurrentThread,
                            procedure
                            begin
  {$ENDIF}
                              if LError <> EmptyStr then
                              begin
                                MessageBoxExW(0, PWideChar(LError), 'Error', MB_OK + MB_ICONHAND, LANG_ENGLISH);

                                mBody.ReadOnly := False;
                                bSend.Enabled := True;
                                Show;
                              end
                              else
                              begin
                                MessageBoxEx(0, 'Message was sent.', 'Email', MB_OK + MB_ICONINFORMATION, LANG_ENGLISH);
                                Close;
                              end;
  {$IFDEF XE7}
                            end);
            end);
  {$ENDIF}

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.bSendClick');
  {$ENDIF}
end;

procedure TfrmEmail.DoAnchorClick(Sender: TObject; Anchor: string);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.DoAnchorClick');
  TTestRun.AddMarker('Anchor: ' + Anchor);
  {$ENDIF}

  (Sender as THTMLabel).Hide;
  for i := 0 to FFileList.Count - 1 do
  if FFileList[i] = Anchor then
  begin
    FFileList.Delete(i);
    Break;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.DoAnchorClick');
  {$ENDIF}
end;

//procedure TfrmEmail.DoStatusInfo(const Msg: string);
//begin
//  ShowMessage(Msg);
//end;

function TfrmEmail.FileListToArray: {$IFDEF XE7}TArray<String>{$ELSE}TArrayString{$ENDIF};
{$IFNDEF XE7}
var
  i: Integer;
{$ENDIF}
begin
  {$IFDEF XE7}
  Result := FFileList.ToStringArray;
  {$ELSE}
  SetLength(Result, FFileList.Count);

  for i := 0 to FFileList.Count - 1 do
    Result[i] := FFileList[i];
  {$ENDIF}
end;

procedure TfrmEmail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.FormClose');
  {$ENDIF}

  if not bSend.Enabled then
    Action := caHide;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.FormClose');
  {$ENDIF}
end;

procedure TfrmEmail.FormCreate(Sender: TObject);
begin
  FFileList := TStringList.Create;
end;

procedure TfrmEmail.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFileList);
end;

procedure TfrmEmail.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.FormKeyDown');
  {$ENDIF}

  if Key = VK_ESCAPE then
  begin
    if Showing and bSend.Enabled then
      Close
    else
      Hide;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.FormKeyDown');
  {$ENDIF}
end;

procedure TfrmEmail.mBodyChange(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.mBodyChange');
  {$ENDIF}

  bSend.Enabled := mBody.Text <> EmptyStr;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.mBodyChange');
  {$ENDIF}
end;

class procedure TfrmEmail.ShowSendEmail;
var
  LBM: TBitmap;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TfrmEmail.ShowSendEmail');
  {$ENDIF}

  with TfrmEmail.Create(Application) do
  begin
    LBM := TBitmap.Create;
    try
      TUtils.LoadBitmap(LBM, rnClose);

      FPictureContainer := TPictureContainer.Create(Application);
      with FPictureContainer.Items.Add do
      begin
        Name := 'Close';
        Picture.Assign(LBM);
      end;
    finally
      LBM.Free;
    end;

    Show;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TfrmEmail.ShowSendEmail');
  {$ENDIF}
end;

end.