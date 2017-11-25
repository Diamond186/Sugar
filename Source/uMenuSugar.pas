unit uMenuSugar;

interface

{$I Compiler.inc}

uses
  ToolsAPI, SysUtils, Windows,
  Menus
  ;

type
  TMenuSugar = class
    private
      FMenuItem: TMenuItem;

      function  GetSettingItem(aINTAServices: INTAServices): TMenuItem;
      procedure DoSettingClick(Sender: TObject);

      function  GetAboutItem(aINTAServices: INTAServices): TMenuItem;
      procedure DoAboutClick(Sender: TObject);

      function  GetUpdateItem(aINTAServices: INTAServices): TMenuItem;
      procedure DoUpdateClick(Sender: TObject);
    public
      destructor Destroy; override;

      procedure AddMenuItems;
  end;

implementation

{$I Compiler.inc}

uses
   SettingForm
  , AboutForm
  , Graphics
  , ActnList
  , Utils
  , uThreadUpdate
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

const
  LActionNameSetting = 'actSetting';
  LActionNameAbout = 'actAbout';
  LNameMenu = 'miSugar';
  LCaptionMenu = 'Sugar';

{ TMenuSuger }

procedure TMenuSugar.AddMenuItems;
var
  LINTAServices: INTAServices;
  i: Integer;
  LIcon: TIcon;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.AddMenuItems');
  {$ENDIF}

  if Assigned(BorlandIDEServices) then
  begin
    LINTAServices := (BorlandIDEServices as INTAServices);

    if LINTAServices.ActionList.FindComponent(LActionNameAbout) = nil then
    for i := 0 to LINTAServices.MainMenu.Items.Count - 1 do
    if LINTAServices.MainMenu.Items[i].Name = 'ToolsMenu' then
    begin
      FMenuItem := TMenuItem.Create(nil);
      FMenuItem.Name := LNameMenu;
      FMenuItem.Caption := LCaptionMenu;

      // load icon
      LIcon := TIcon.Create;
      TUtils.LoadIcon(LIcon, rnMenu);
      FMenuItem.ImageIndex := LINTAServices.ImageList.AddIcon(LIcon);

      FMenuItem.Add(GetSettingItem(LINTAServices));
      FMenuItem.Add(GetUpdateItem(LINTAServices));
      FMenuItem.Add(GetAboutItem(LINTAServices));

      LINTAServices.MainMenu.Items.Insert(i + 1, FMenuItem);

      Break;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.AddMenuItems');
  {$ENDIF}
end;

destructor TMenuSugar.Destroy;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.Destroy');
  {$ENDIF}

  FreeAndNil(FMenuItem);

  inherited;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.Destroy');
  {$ENDIF}
end;

procedure TMenuSugar.DoAboutClick(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.DoAboutClick');
  {$ENDIF}

  TAboutFrm.ShowAbout;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.DoAboutClick');
  {$ENDIF}
end;

procedure TMenuSugar.DoSettingClick(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.DoSettingClick');
  {$ENDIF}

  TSettingFrm.ShowSetting;
  
  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.DoSettingClick');
  {$ENDIF}
end;

procedure TMenuSugar.DoUpdateClick(Sender: TObject);
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.DoUpdateClick');
  {$ENDIF}

  TThreadUpdate.RunUpdateMenu;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.DoUpdateClick');
  {$ENDIF}
end;

function TMenuSugar.GetAboutItem(aINTAServices: INTAServices): TMenuItem;
var
  LAction: TAction;
  LIcon: TIcon;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.GetAboutItem');
  {$ENDIF}

  // Create action
  LAction := TAction.Create(nil);
  LAction.Caption := '&About';
  LAction.Name := LActionNameAbout;
  LAction.Category := 'Sugar';
  LAction.Hint := 'About plugin';
  LAction.OnExecute := DoAboutClick;
  LAction.ActionList := aINTAServices.ActionList;

  // load icon
  LIcon := TIcon.Create;
  TUtils.LoadIcon(LIcon, rnAbout);
  LAction.ImageIndex := aINTAServices.ImageList.AddIcon(LIcon);

  // add menu item
  Result := TMenuItem.Create(nil);
  Result.Action := LAction;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.GetAboutItem: ' + IntToStr(LIcon.Handle));
  {$ENDIF}
end;

function TMenuSugar.GetSettingItem(aINTAServices: INTAServices): TMenuItem;
var
  LAction: TAction;
  LIcon: TIcon;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.GetSettingItem');
  {$ENDIF}

  // Create action
  LAction := TAction.Create(nil);
  LAction.Caption := '&Setting';
  LAction.Name := LActionNameSetting;
  LAction.Category := 'Sugar';
  LAction.Hint := 'Sugar plugin setting';
  LAction.OnExecute := DoSettingClick;
  LAction.ActionList := aINTAServices.ActionList;

  // load icon
  LIcon := TIcon.Create;
  TUtils.LoadIcon(LIcon, rnSetting);
  LAction.ImageIndex := aINTAServices.ImageList.AddIcon(LIcon);

  // add menu item
  Result := TMenuItem.Create(nil);
  Result.Action := LAction;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.GetSettingItem: ' + IntToStr(LIcon.Handle));
  {$ENDIF}
end;

function TMenuSugar.GetUpdateItem(aINTAServices: INTAServices): TMenuItem;
var
  LAction: TAction;
  LIcon: TIcon;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TMenuSugar.GetUpdateItem');
  {$ENDIF}

  // Create action
  LAction := TAction.Create(nil);
  LAction.Caption := '&Update';
  LAction.Name := LActionNameAbout;
  LAction.Category := 'Sugar';
  LAction.Hint := 'Update plugin';
  LAction.OnExecute := DoUpdateClick;
  LAction.ActionList := aINTAServices.ActionList;

  // load icon
  LIcon := TIcon.Create;
  TUtils.LoadIcon(LIcon, rnUpdate);
  LAction.ImageIndex := aINTAServices.ImageList.AddIcon(LIcon);

  // add menu item
  Result := TMenuItem.Create(nil);
  Result.Action := LAction;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TMenuSugar.GetUpdateItem: ' + IntToStr(LIcon.Handle));
  {$ENDIF}
end;

end.
