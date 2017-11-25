unit frmContextMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, Generics.Collections,
  ExtCtrls;

type
  TfrmMenu = class(TForm)
    lbMenu: TListBox;
    pCaption: TPanel;
    Bevel1: TBevel;

    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbMenuKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
  private
    type
      TResultSelectedItem = reference to procedure(aItem: TArray<Integer>);

    var
      FDoSelectedItem: TResultSelectedItem;

      procedure lbMenuSelect;
      class function GetIndexMaxLength(aItems: TStrings): Integer;
      class procedure OutputMessage(const strText: String);
  public
    class procedure showMenu(const aCaption: string;
                             aFoo: TPoint;
                             aItems: TStrings;
                             aSelectedItem: TResultSelectedItem);
  end;

implementation

{$R *.dfm}

uses
  ToolsAPI;

ResourceString
  strIDENotifierMessages = 'Debug Suger Messages';

class procedure TfrmMenu.OutputMessage(const strText: String);
var
  Group: IOTAMessageGroup;
Begin
  With (BorlandIDEServices As IOTAMessageServices) Do
  Begin
    Group := GetGroup(strIDENotifierMessages);

    If Group = Nil Then
      Group := AddMessageGroup(strIDENotifierMessages);

    AddTitleMessage(strText, Group);
  End;
end;

{ TfrmMenu }

procedure TfrmMenu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmMenu.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TfrmMenu.FormShow(Sender: TObject);
begin
  if lbMenu.CanFocus and (lbMenu.Items.Count > 0) then
    lbMenu.Selected[0] := True;
end;

class function TfrmMenu.GetIndexMaxLength(aItems: TStrings): Integer;
var
  LIndex, LMax: Integer;
begin
  Result := -1;
  LMax := 0;

  for LIndex := 0 to aItems.Count - 1 do
  if Length(aItems[LIndex]) > LMax then
  begin
    Result := LIndex;
    LMax := Length(aItems[LIndex]);
  end;
end;

procedure TfrmMenu.lbMenuSelect;
var
  i: Integer;
  LList: TList<Integer>;
begin
  LList := TList<Integer>.Create;
  try
    for i := 0 to lbMenu.Items.Count - 1 do
    if lbMenu.Selected[i] then
    begin
      LList.Add(i);
    end;

    if Assigned(FDoSelectedItem) then FDoSelectedItem(LList.ToArray);
  finally
    LList.Free;
  end;
end;

procedure TfrmMenu.lbMenuKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    lbMenuSelect;
    Close;
  end else
  if Key = VK_ESCAPE then
  begin
    Close;
  end;
end;

class procedure TfrmMenu.showMenu(const aCaption: string;
                                  aFoo: TPoint;
                                  aItems: TStrings;
                                  aSelectedItem: TResultSelectedItem);
var
  LIndexMaxLength: Integer;
begin
  with TfrmMenu.Create(nil) do
  begin
    pCaption.Caption := aCaption;

    Left := aFoo.X + 50;
    Top := aFoo.Y + 180;

    lbMenu.Items.Assign(aItems);
    FDoSelectedItem := aSelectedItem;

    Height := aItems.Count * lbMenu.ItemHeight + aItems.Count + pCaption.Height;

    LIndexMaxLength := TfrmMenu.GetIndexMaxLength(aItems);
    Width := Canvas.TextWidth(aItems[LIndexMaxLength]) + Length(aItems[LIndexMaxLength]);
      OutputMessage(IntToStr(LIndexMaxLength));
    Show;
  end;
end;

end.
