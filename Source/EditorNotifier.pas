unit EditorNotifier;

interface

uses
  ToolsAPI, Classes, DockForm,
  KeyboardBinding;

type
  TEditorNotifier = Class(TNotifierObject, INTAEditServicesNotifier)
    Strict Private
    Strict Protected
    Public
      Procedure WindowShow(Const EditWindow: INTAEditWindow; Show, LoadedFromDesktop: Boolean);
      Procedure WindowNotification(Const EditWindow: INTAEditWindow; Operation: TOperation);
      Procedure WindowActivated(Const EditWindow: INTAEditWindow);
      Procedure WindowCommand(Const EditWindow: INTAEditWindow; Command, Param: Integer; Var Handled: Boolean);
      Procedure EditorViewActivated(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
      Procedure EditorViewModified(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
      Procedure DockFormVisibleChanged(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
      Procedure DockFormUpdated(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
      Procedure DockFormRefresh(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
  End;

implementation

{ TEditorNotifier }

procedure TEditorNotifier.DockFormRefresh(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin

end;

procedure TEditorNotifier.DockFormUpdated(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin

end;

procedure TEditorNotifier.DockFormVisibleChanged(
  const EditWindow: INTAEditWindow; DockForm: TDockableForm);
begin

end;

procedure TEditorNotifier.EditorViewActivated(const EditWindow: INTAEditWindow;
  const EditView: IOTAEditView);
begin

end;

procedure TEditorNotifier.EditorViewModified(const EditWindow: INTAEditWindow;
  const EditView: IOTAEditView);
begin

end;

procedure TEditorNotifier.WindowActivated(const EditWindow: INTAEditWindow);
begin

end;

procedure TEditorNotifier.WindowCommand(const EditWindow: INTAEditWindow;
  Command, Param: Integer; var Handled: Boolean);
begin

end;

procedure TEditorNotifier.WindowNotification(const EditWindow: INTAEditWindow;
  Operation: TOperation);
begin

end;

procedure TEditorNotifier.WindowShow(const EditWindow: INTAEditWindow; Show,
  LoadedFromDesktop: Boolean);
begin

end;

end.
