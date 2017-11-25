unit dmImages;

interface

{$I Compiler.inc}

uses
  SysUtils, Classes
  (*{$IFDEF XE8}
  , System.ImageList
  {$ENDIF}
  , ImgList*)
  , Controls;

type
  TImagesDM = class(TDataModule)
    Images: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
