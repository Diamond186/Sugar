unit PasWideLex;

interface

{$I ..\Compiler.inc}

uses
  SysUtils, Classes, Controls, mPasLexTypes;

type
{$IFDEF D2009}
  CnIndexChar = Char;
  CnWideString = string;
{$ELSE}
  CnIndexChar = AnsiChar;
  CnWideString = WideString;
{$ENDIF}

  TPasWideBookmark = class(TObject)
  private
    FRunBookmark: LongInt;
    FLineNumberBookmark: Integer;
    FColumnNumberBookmark: Integer;
    FColumnBookmark: Integer;
    FCommentBookmark: TCommentState;
    FLastNoSpacePosBookmark: Integer;
    FStringLenBookmark: Integer;
    FRoundCountBookmark: Integer;
    FLastNoSpaceBookmark: TTokenKind;
    FToIdentBookmark: PWideChar;
    FIsClassBookmark: Boolean;
    FTokenIDBookmark: TTokenKind;
    FTokenPosBookmark: Integer;
    FIsInterfaceBookmark: Boolean;
    FSquareCountBookmark: Integer;
    FAngleCountBookmark: Integer;
    FLastIdentPosBookmark: Integer;
    FLineStartOffsetBookmark: Integer;
  public
    property RunBookmark: LongInt read FRunBookmark write FRunBookmark;
    property LineNumberBookmark: Integer read FLineNumberBookmark write FLineNumberBookmark;
    property ColumnNumberBookmark: Integer read FColumnNumberBookmark write FColumnNumberBookmark;
    property ColumnBookmark: Integer read FColumnBookmark write FColumnBookmark;
    property CommentBookmark: TCommentState read FCommentBookmark write FCommentBookmark;
    property RoundCountBookmark: Integer read FRoundCountBookmark write FRoundCountBookmark;
    property SquareCountBookmark: Integer read FSquareCountBookmark write FSquareCountBookmark;
    property AngleCountBookmark: Integer read FAngleCountBookmark write FAngleCountBookmark;
    property TokenIDBookmark: TTokenKind read FTokenIDBookmark write FTokenIDBookmark;
    property LastIdentPosBookmark: Integer read FLastIdentPosBookmark write FLastIdentPosBookmark;
    property LastNoSpaceBookmark: TTokenKind read FLastNoSpaceBookmark write FLastNoSpaceBookmark;
    property LastNoSpacePosBookmark: Integer read FLastNoSpacePosBookmark write FLastNoSpacePosBookmark;
    property LineStartOffsetBookmark: Integer read FLineStartOffsetBookmark write FLineStartOffsetBookmark;
    property IsInterfaceBookmark: Boolean read FIsInterfaceBookmark write FIsInterfaceBookmark;
    property IsClassBookmark: Boolean read FIsClassBookmark write FIsClassBookmark;
    property StringLenBookmark: Integer read FStringLenBookmark write FStringLenBookmark;
    property TokenPosBookmark: Integer read FTokenPosBookmark write FTokenPosBookmark;
    property ToIdentBookmark: PWideChar read FToIdentBookmark write FToIdentBookmark;
  end;

  TPasWideLex = class(TObject)
  private
    FSupportUnicodeIdent: Boolean;
    FRun: LongInt;       
    FColumn: Integer;    
    FLineNumber: Integer;
    FColumnNumber: Integer;
    FComment: TCommentState;
    FRoundCount: Integer;
    FSquareCount: Integer;
    FAngleCount: Integer;
    FTokenID: TTokenKind;
    FLastIdentPos: Integer;
    FLastNoSpace: TTokenKind;
    FLastNoSpacePos: Integer;
    FLineStartOffset: Integer;
    FIsInterface: Boolean;
    FIsClass: Boolean;
    FStringLen: Integer; 
    FTokenPos: Integer;
    FToIdent: PWideChar;

    FOrigin: PWideChar;
    FProcTable: array[#0..#255] of procedure of object;
    FIdentFuncTable: array[0..191] of function: TTokenKind of object;

    function KeyHash(ToHash: PWideChar): Integer;
    function KeyComp(const aKey: CnWideString): Boolean;
    function Func15: TTokenKind;
    function Func19: TTokenKind;
    function Func20: TTokenKind;
    function Func21: TTokenKind;
    function Func23: TTokenKind;
    function Func25: TTokenKind;
    function Func27: TTokenKind;
    function Func28: TTokenKind;
    function Func29: TTokenKind;
    function Func32: TTokenKind;
    function Func33: TTokenKind;
    function Func35: TTokenKind;
    function Func37: TTokenKind;
    function Func38: TTokenKind;
    function Func39: TTokenKind;
    function Func40: TTokenKind;
    function Func41: TTokenKind;
    function Func44: TTokenKind;
    function Func45: TTokenKind;
    function Func46: TTokenKind;
    function Func47: TTokenKind;
    function Func49: TTokenKind;
    function Func52: TTokenKind;
    function Func54: TTokenKind;
    function Func55: TTokenKind;
    function Func56: TTokenKind;
    function Func57: TTokenKind;
    function Func59: TTokenKind;
    function Func60: TTokenKind;
    function Func61: TTokenKind;
    function Func63: TTokenKind;
    function Func64: TTokenKind;
    function Func65: TTokenKind;
    function Func66: TTokenKind;
    function Func69: TTokenKind;
    function Func71: TTokenKind;
    function Func73: TTokenKind;
    function Func75: TTokenKind;
    function Func76: TTokenKind;
    function Func79: TTokenKind;
    function Func81: TTokenKind;
    function Func84: TTokenKind;
    function Func85: TTokenKind;
    function Func87: TTokenKind;
    function Func88: TTokenKind;
    function Func91: TTokenKind;
    function Func92: TTokenKind;
    function Func94: TTokenKind;
    function Func95: TTokenKind;
    function Func96: TTokenKind;
    function Func97: TTokenKind;
    function Func98: TTokenKind;
    function Func99: TTokenKind;
    function Func100: TTokenKind;
    function Func101: TTokenKind;
    function Func102: TTokenKind;
    function Func103: TTokenKind;
    function Func105: TTokenKind;
    function Func106: TTokenKind;
    function Func117: TTokenKind;
    function Func126: TTokenKind;
    function Func129: TTokenKind;
    function Func132: TTokenKind;
    function Func133: TTokenKind;
    function Func136: TTokenKind;
    function Func141: TTokenKind;
    function Func143: TTokenKind;
    function Func166: TTokenKind;
    function Func168: TTokenKind;
    function Func191: TTokenKind;
    function AltFunc: TTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PWideChar): TTokenKind;
    procedure SetOrigin(NewValue: PWideChar);
    procedure SetRunPos(Value: Integer);
    procedure MakeMethodTables;
    procedure AddressOpProc;
    procedure AsciiCharProc;
    procedure AnsiProc;
    procedure BorProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure CRProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PlusProc;
    procedure PointerSymbolProc;
    procedure PointProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringProc;
    procedure BadStringProc; 
    procedure SymbolProc;
    procedure AmpersandProc;
    procedure UnknownProc;
    function GetToken: CnWideString;
    function InSymbols(aChar: WideChar): Boolean;
    function GetTokenAddr: PWideChar;
    function GetTokenLength: Integer;
    function GetWideColumnNumber: Integer;
  protected
    procedure StepRun(Count: Integer = 1; CalcColumn: Boolean = False);
  public
    constructor Create(SupportUnicodeIdent: Boolean = False);
    destructor Destroy; override;
    function CharAhead(Count: Integer): WideChar;
    function IsFirstGreater: Boolean;
    procedure Next;
    procedure NextID(ID: TTokenKind);
    procedure NextNoJunk;
    procedure NextClass;

    procedure SaveToBookMark(out Bookmark: TPasWideBookmark);
    procedure LoadFromBookMark(var Bookmark: TPasWideBookmark);

    property IsClass: Boolean read FIsClass;
    property IsInterface: Boolean read FIsInterface;
    property LastIdentPos: Integer read FLastIdentPos;
    property LastNoSpace: TTokenKind read FLastNoSpace;
    property LastNoSpacePos: Integer read FLastNoSpacePos;

    property LineNumber: Integer read FLineNumber write FLineNumber;
    property ColumnNumber: Integer read FColumnNumber write FColumnNumber;    
    property WideColumnNumber: Integer read GetWideColumnNumber;
    property LineStartOffset: Integer read FLineStartOffset write FLineStartOffset;
    property Origin: PWideChar read FOrigin write SetOrigin;
    property RunPos: Integer read FRun write SetRunPos;
    property TokenPos: Integer read FTokenPos;
    property TokenID: TTokenKind read FTokenID;
    property Token: CnWideString read GetToken;
    property TokenAddr: PWideChar read GetTokenAddr;
    property TokenLength: Integer read GetTokenLength;
  end;

implementation

type
  TAnsiCharSet = set of AnsiChar;

var
  Identifiers: array[#0..#255] of ByteBool;

  mHashTable: array[#0..#255] of Integer;

function _WideCharInSet(C: WideChar; CharSet: TAnsiCharSet): Boolean; {$IFDEF D2005} inline; {$ENDIF}
begin
  if Ord(C) <= $FF then
    Result := AnsiChar(C) in CharSet
  else
    Result := False;
end;

function _IndexChar(C: WideChar): CnIndexChar; {$IFDEF D2005} inline; {$ENDIF}
begin
{$IFDEF D2009}
  Result := C;
{$ELSE}
  Result := CnIndexChar(C);
{$ENDIF}
end;

procedure MakeIdentTable;
var
  I, J: AnsiChar;
begin
  for I := #0 to#255 do
  begin
    case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z':
        Identifiers[I] := True;
    else
      Identifiers[I] := False;
    end;
    case I of
      'a'..'z', 'A'..'Z', '_':
        begin
          J := AnsiChar(UpperCase(string(I))[1]);
          mHashTable[I] := Ord(J) - 64;
        end;
    else
      mHashTable[AnsiChar(I)] := 0;
    end;
  end;
end;

function GetHashTableValue(C: WideChar): Integer;  {$IFDEF D2005} inline; {$ENDIF}
begin
  if Ord(C) > Ord(High(mHashTable)) then
    Result := 0
  else
    Result := mHashTable[_IndexChar(C)];
end;

procedure TPasWideLex.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 191 do
    case I of
      15:
        FIdentFuncTable[I] := Func15;
      19:
        FIdentFuncTable[I] := Func19;
      20:
        FIdentFuncTable[I] := Func20;
      21:
        FIdentFuncTable[I] := Func21;
      23:
        FIdentFuncTable[I] := Func23;
      25:
        FIdentFuncTable[I] := Func25;
      27:
        FIdentFuncTable[I] := Func27;
      28:
        FIdentFuncTable[I] := Func28;
      29:
        FIdentFuncTable[I] := Func29;
      32:
        FIdentFuncTable[I] := Func32;
      33:
        FIdentFuncTable[I] := Func33;
      35:
        FIdentFuncTable[I] := Func35;
      37:
        FIdentFuncTable[I] := Func37;
      38:
        FIdentFuncTable[I] := Func38;
      39:
        FIdentFuncTable[I] := Func39;
      40:
        FIdentFuncTable[I] := Func40;
      41:
        FIdentFuncTable[I] := Func41;
      44:
        FIdentFuncTable[I] := Func44;
      45:
        FIdentFuncTable[I] := Func45;
      46:
        FIdentFuncTable[I] := Func46;
      47:
        FIdentFuncTable[I] := Func47;
      49:
        FIdentFuncTable[I] := Func49;
      52:
        FIdentFuncTable[I] := Func52;
      54:
        FIdentFuncTable[I] := Func54;
      55:
        FIdentFuncTable[I] := Func55;
      56:
        FIdentFuncTable[I] := Func56;
      57:
        FIdentFuncTable[I] := Func57;
      59:
        FIdentFuncTable[I] := Func59;
      60:
        FIdentFuncTable[I] := Func60;
      61:
        FIdentFuncTable[I] := Func61;
      63:
        FIdentFuncTable[I] := Func63;
      64:
        FIdentFuncTable[I] := Func64;
      65:
        FIdentFuncTable[I] := Func65;
      66:
        FIdentFuncTable[I] := Func66;
      69:
        FIdentFuncTable[I] := Func69;
      71:
        FIdentFuncTable[I] := Func71;
      73:
        FIdentFuncTable[I] := Func73;
      75:
        FIdentFuncTable[I] := Func75;
      76:
        FIdentFuncTable[I] := Func76;
      79:
        FIdentFuncTable[I] := Func79;
      81:
        FIdentFuncTable[I] := Func81;
      84:
        FIdentFuncTable[I] := Func84;
      85:
        FIdentFuncTable[I] := Func85;
      87:
        FIdentFuncTable[I] := Func87;
      88:
        FIdentFuncTable[I] := Func88;
      91:
        FIdentFuncTable[I] := Func91;
      92:
        FIdentFuncTable[I] := Func92;
      94:
        FIdentFuncTable[I] := Func94;
      95:
        FIdentFuncTable[I] := Func95;
      96:
        FIdentFuncTable[I] := Func96;
      97:
        FIdentFuncTable[I] := Func97;
      98:
        FIdentFuncTable[I] := Func98;
      99:
        FIdentFuncTable[I] := Func99;
      100:
        FIdentFuncTable[I] := Func100;
      101:
        FIdentFuncTable[I] := Func101;
      102:
        FIdentFuncTable[I] := Func102;
      103:
        FIdentFuncTable[I] := Func103;
      105:
        FIdentFuncTable[I] := Func105;
      106:
        FIdentFuncTable[I] := Func106;
      117:
        FIdentFuncTable[I] := Func117;
      126:
        FIdentFuncTable[I] := Func126;
      129:
        FIdentFuncTable[I] := Func129;
      132:
        FIdentFuncTable[I] := Func132;
      133:
        FIdentFuncTable[I] := Func133;
      136:
        FIdentFuncTable[I] := Func136;
      141:
        FIdentFuncTable[I] := Func141;
      143:
        FIdentFuncTable[I] := Func143;
      166:
        FIdentFuncTable[I] := Func166;
      168:
        FIdentFuncTable[I] := Func168;
      191:
        FIdentFuncTable[I] := Func191;
    else
      FIdentFuncTable[I] := AltFunc;
    end;
end;

function TPasWideLex.KeyHash(ToHash: PWideChar): Integer;
begin
  Result := 0;
  while (_WideCharInSet(ToHash^, ['a'..'z', 'A'..'Z'])) or
    (FSupportUnicodeIdent and (Ord(ToHash^) > 127)) do
  begin
    Inc(Result, GetHashTableValue(ToHash^));
    Inc(ToHash);
  end;
  if _WideCharInSet(ToHash^, ['_', '0'..'9']) then
    Inc(ToHash);
  FStringLen := ToHash - FToIdent;
end;  { KeyHash }

function TPasWideLex.KeyComp(const aKey: CnWideString): Boolean;
var
  I: Integer;
  P: PWideChar;
begin
  P := FToIdent;
  if Length(aKey) = FStringLen then
  begin
    Result := True;
    for I := 1 to FStringLen do
    begin
      if GetHashTableValue(P^) <> GetHashTableValue(aKey[I]) then
      begin
        Result := False;
        Break;
      end;
      Inc(P);
    end;
  end
  else
    Result := False;
end;  { KeyComp }

function TPasWideLex.Func15: TTokenKind;
begin
  if KeyComp('If') then
    Result := tkIf
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func19: TTokenKind;
begin
  if KeyComp('Do') then
    Result := tkDo
  else if KeyComp('And') then
    Result := tkAnd
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func20: TTokenKind;
begin
  if KeyComp('As') then
    Result := tkAs
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func21: TTokenKind;
begin
  if KeyComp('Of') then
    Result := tkOf
  else if KeyComp('At') then
    Result := tkAt
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func23: TTokenKind;
begin
  if KeyComp('End') then
    Result := tkEnd
  else if KeyComp('In') then
    Result := tkIn
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func25: TTokenKind;
begin
  if KeyComp('Far') then
    Result := tkFar
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func27: TTokenKind;
begin
  if KeyComp('Cdecl') then
    Result := tkCdecl
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func28: TTokenKind;
begin
  if KeyComp('Read') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkRead
  end
  else if KeyComp('Case') then
    Result := tkCase
  else if KeyComp('Is') then
    Result := tkIs
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func29: TTokenKind;
begin
  if KeyComp('On') then
    Result := tkOn
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func32: TTokenKind;
begin
  if KeyComp('File') then
    Result := tkFile
  else if KeyComp('Label') then
    Result := tkLabel
  else if KeyComp('Mod') then
    Result := tkMod
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func33: TTokenKind;
begin
  if KeyComp('Or') then
    Result := tkOr
  else if KeyComp('Name') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkName
  end
  else if KeyComp('Asm') then
    Result := tkAsm
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func35: TTokenKind;
begin
  if KeyComp('To') then
    Result := tkTo
  else if KeyComp('Nil') then
    Result := tkNil
  else if KeyComp('Div') then
    Result := tkDiv
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func37: TTokenKind;
begin
  if KeyComp('Begin') then
    Result := tkBegin
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func38: TTokenKind;
begin
  if KeyComp('Near') then
    Result := tkNear
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func39: TTokenKind;
begin
  if KeyComp('For') then
    Result := tkFor
  else if KeyComp('Shl') then
    Result := tkShl
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func40: TTokenKind;
begin
  if KeyComp('Packed') then
    Result := tkPacked
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func41: TTokenKind;
begin
  if KeyComp('Else') then
    Result := tkElse
  else if KeyComp('Var') then
    Result := tkVar
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func44: TTokenKind;
begin
  if KeyComp('Set') then
    Result := tkSet
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func45: TTokenKind;
begin
  if KeyComp('Shr') then
    Result := tkShr
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func46: TTokenKind;
begin
  if KeyComp('Sealed') then
    Result := tkSealed
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func47: TTokenKind;
begin
  if KeyComp('Then') then
    Result := tkThen
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func49: TTokenKind;
begin
  if KeyComp('Not') then
    Result := tkNot
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func52: TTokenKind;
begin
  if KeyComp('Raise') then
    Result := tkRaise
  else if KeyComp('Pascal') then
    Result := tkPascal
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func54: TTokenKind;
begin
  if KeyComp('Class') then
  begin
    Result := tkClass;
    if FLastNoSpace = tkEqual then
    begin
      FIsClass := True;
      if Identifiers[_IndexChar(CharAhead(FStringLen))] then
        FIsClass := False;
    end
    else
      FIsClass := False;
  end
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func55: TTokenKind;
begin
  if KeyComp('Object') then
    Result := tkObject
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func56: TTokenKind;
begin
  if KeyComp('Index') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkIndex
  end
  else if KeyComp('Out') then
    Result := tkOut
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func57: TTokenKind;
begin
  if KeyComp('While') then
    Result := tkWhile
  else if KeyComp('Goto') then
    Result := tkGoto
  else if KeyComp('Xor') then
    Result := tkXor
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func59: TTokenKind;
begin
  if KeyComp('Safecall') then
    Result := tkSafecall
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func60: TTokenKind;
begin
  if KeyComp('With') then
    Result := tkWith
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func61: TTokenKind;
begin
  if KeyComp('Dispid') then
    Result := tkDispid
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func63: TTokenKind;
begin
  if KeyComp('Public') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkPublic
  end
  else if KeyComp('Record') then
    Result := tkRecord
  else if KeyComp('Try') then
    Result := tkTry
  else if KeyComp('Array') then
    Result := tkArray
  else if KeyComp('Inline') then
    Result := tkInline
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func64: TTokenKind;
begin
  if KeyComp('Uses') then
    Result := tkUses
  else if KeyComp('Unit') then
    Result := tkUnit
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func65: TTokenKind;
begin
  if KeyComp('Repeat') then
    Result := tkRepeat
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func66: TTokenKind;
begin
  if KeyComp('Type') then
    Result := tkType
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func69: TTokenKind;
begin
  if KeyComp('Dynamic') then
    Result := tkDynamic
  else if KeyComp('Default') then
    Result := tkDefault
  else if KeyComp('Message') then
    Result := tkMessage
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func71: TTokenKind;
begin
  if KeyComp('Stdcall') then
    Result := tkStdcall
  else if KeyComp('Const') then
    Result := tkConst
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func73: TTokenKind;
begin
  if KeyComp('Except') then
    Result := tkExcept
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func75: TTokenKind;
begin
  if KeyComp('Write') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkWrite
  end
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func76: TTokenKind;
begin
  if KeyComp('Until') then
    Result := tkUntil
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func79: TTokenKind;
begin
  if KeyComp('Finally') then
    Result := tkFinally
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func81: TTokenKind;
begin
  if KeyComp('Interface') then
  begin
    Result := tkInterface;
    if FLastNoSpace = tkEqual then
      FIsInterface := True
    else
      FIsInterface := False;
  end
  else if KeyComp('Stored') then
    Result := tkStored
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func84: TTokenKind;
begin
  if KeyComp('Abstract') then
    Result := tkAbstract
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func85: TTokenKind;
begin
  if KeyComp('Library') then
    Result := tkLibrary
  else if KeyComp('Forward') then
    Result := tkForward
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func87: TTokenKind;
begin
  if KeyComp('String') then
    Result := tkString
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func88: TTokenKind;
begin
  if KeyComp('Program') then
    Result := tkProgram
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func91: TTokenKind;
begin
  if KeyComp('Private') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkPrivate
  end
  else if KeyComp('Downto') then
    Result := tkDownto
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func92: TTokenKind;
begin
  if KeyComp('overload') then
    Result := tkOverload
  else if KeyComp('Inherited') then
    Result := tkInherited
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func94: TTokenKind;
begin
  if KeyComp('Resident') then
    Result := tkResident
  else if KeyComp('Readonly') then
    Result := tkReadonly
  else if KeyComp('Assembler') then
    Result := tkAssembler
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func95: TTokenKind;
begin
  if KeyComp('Absolute') then
    Result := tkAbsolute
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func96: TTokenKind;
begin
  if KeyComp('Published') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkPublished
  end
  else if KeyComp('Override') then
    Result := tkOverride
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func97: TTokenKind;
begin
  if KeyComp('Threadvar') then
    Result := tkThreadvar
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func98: TTokenKind;
begin
  if KeyComp('Export') then
    Result := tkExport
  else if KeyComp('Nodefault') then
    Result := tkNodefault
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func99: TTokenKind;
begin
  if KeyComp('External') then
    Result := tkExternal
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func100: TTokenKind;
begin
  if KeyComp('Automated') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkAutomated
  end
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func101: TTokenKind;
begin
  if KeyComp('Register') then
    Result := tkRegister
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func102: TTokenKind;
begin
  if KeyComp('Function') then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func103: TTokenKind;
begin
  if KeyComp('Virtual') then
    Result := tkVirtual
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func105: TTokenKind;
begin
  if KeyComp('Procedure') then
    Result := tkProcedure
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func106: TTokenKind;
begin
  if KeyComp('Protected') then
  begin
    if inSymbols(CharAhead(FStringLen)) then
      Result := tkIdentifier
    else
      Result := tkProtected
  end
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func117: TTokenKind;
begin
  if KeyComp('Exports') then
    Result := tkExports
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func126: TTokenKind;
begin
  if KeyComp('Implements') then
    Result := tkImplements
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func129: TTokenKind;
begin
  if KeyComp('Dispinterface') then
    Result := tkDispinterface
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func132: TTokenKind;
begin
  if KeyComp('Reintroduce') then
    Result := tkReintroduce
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func133: TTokenKind;
begin
  if KeyComp('Property') then
    Result := tkProperty
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func136: TTokenKind;
begin
  if KeyComp('Finalization') then
    Result := tkFinalization
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func141: TTokenKind;
begin
  if KeyComp('Writeonly') then
    Result := tkWriteonly
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func143: TTokenKind;
begin
  if KeyComp('Destructor') then
    Result := tkDestructor
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func166: TTokenKind;
begin
  if KeyComp('Constructor') then
    Result := tkConstructor
  else if KeyComp('Implementation') then
    Result := tkImplementation
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func168: TTokenKind;
begin
  if KeyComp('Initialization') then
    Result := tkInitialization
  else
    Result := tkIdentifier;
end;

function TPasWideLex.Func191: TTokenKind;
begin
  if KeyComp('Resourcestring') then
    Result := tkResourcestring
  else if KeyComp('Stringresource') then
    Result := tkStringresource
  else
    Result := tkIdentifier;
end;

function TPasWideLex.AltFunc: TTokenKind;
begin
  Result := tkIdentifier
end;

function TPasWideLex.IdentKind(MayBe: PWideChar): TTokenKind;
var
  HashKey: Integer;
begin
  FToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 192 then
    Result := FIdentFuncTable[HashKey]
  else
    Result := tkIdentifier;
end;

procedure TPasWideLex.MakeMethodTables;
var
  I: AnsiChar;
begin
  for I := #0 to#255 do
    case I of
      #0:
        FProcTable[I] := NullProc;
      #10:
        FProcTable[I] := LFProc;
      #13:
        FProcTable[I] := CRProc;
      #1..#9, #11, #12, #14..#32:
        FProcTable[I] := SpaceProc;
      '#':
        FProcTable[I] := AsciiCharProc;
      '$':
        FProcTable[I] := IntegerProc;
      #39:
        FProcTable[I] := StringProc;
      '0'..'9':
        FProcTable[I] := NumberProc;
      'A'..'Z', 'a'..'z', '_':
        FProcTable[I] := IdentProc;
      '{':
        FProcTable[I] := BraceOpenProc;
      '}':
        FProcTable[I] := BraceCloseProc;
      '!', '"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(':
              FProcTable[I] := RoundOpenProc;
            ')':
              FProcTable[I] := RoundCloseProc;
            '*':
              FProcTable[I] := StarProc;
            '+':
              FProcTable[I] := PlusProc;
            ',':
              FProcTable[I] := CommaProc;
            '-':
              FProcTable[I] := MinusProc;
            '.':
              FProcTable[I] := PointProc;
            '/':
              FProcTable[I] := SlashProc;
            ':':
              FProcTable[I] := ColonProc;
            ';':
              FProcTable[I] := SemiColonProc;
            '<':
              FProcTable[I] := LowerProc;
            '=':
              FProcTable[I] := EqualProc;
            '>':
              FProcTable[I] := GreaterProc;
            '@':
              FProcTable[I] := AddressOpProc;
            '[':
              FProcTable[I] := SquareOpenProc;
            ']':
              FProcTable[I] := SquareCloseProc;
            '^':
              FProcTable[I] := PointerSymbolProc;
            '"':
              FProcTable[I] := BadStringProc;
            '&':
              FProcTable[I] := AmpersandProc;
          else
            FProcTable[I] := SymbolProc;
          end;
        end;
    else
      FProcTable[I] := UnknownProc;
    end;
end;

constructor TPasWideLex.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FSupportUnicodeIdent := SupportUnicodeIdent;
  InitIdent;
  MakeMethodTables;
end;  { Create }

destructor TPasWideLex.Destroy;
begin
  inherited Destroy;
end;  { Destroy }

procedure TPasWideLex.SetOrigin(NewValue: PWideChar);
begin
  FOrigin := NewValue;
  FComment := csNo;
  FLineNumber := 1;
  FColumn := 1;

  FLineStartOffset := 0;
  FRun := 0;
  Next;
end;  { SetOrigin }

procedure TPasWideLex.SetRunPos(Value: Integer);
begin
  FRun := Value;
  Next;
end;

procedure TPasWideLex.AddressOpProc;
begin
  case FOrigin[FRun + 1] of
    '@':
      begin
        FTokenID := tkDoubleAddressOp;
        StepRun(2);
      end;
  else
    begin
      FTokenID := tkAddressOp;
      StepRun;
    end;
  end;
end;

procedure TPasWideLex.AsciiCharProc;
begin
  FTokenID := tkAsciiChar;
  StepRun;
  while _WideCharInSet(FOrigin[FRun], ['0'..'9']) do
    StepRun;
end;

procedure TPasWideLex.BraceCloseProc;
begin
  StepRun;
  FTokenID := tkError;
end;

procedure TPasWideLex.BorProc;
begin
  FTokenID := tkBorComment;
  case FOrigin[FRun] of
    #0:
      begin
        NullProc;
        Exit;
      end;

    #10:
      begin
        LFProc;
        Exit;
      end;

    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while FOrigin[FRun] <> #0 do
    case FOrigin[FRun] of
      '}':
        begin
          FComment := csNo;
          StepRun;
          Break;
        end;
      #10:
        Break;

      #13:
        Break;
    else
      StepRun;
    end;
end;

procedure TPasWideLex.BraceOpenProc;
begin
  case FOrigin[FRun + 1] of
    '$':
      FTokenID := tkCompDirect;
  else
    begin
      FTokenID := tkBorComment;
      FComment := csBor;
    end;
  end;
  StepRun(1, True); 
  while FOrigin[FRun] <> #0 do
    case FOrigin[FRun] of
      '}':
        begin
          FComment := csNo;
          StepRun;
          Break;
        end;
      #10:
        Break;

      #13:
        Break;
    else
      StepRun(1, True);
    end;
end;

procedure TPasWideLex.ColonProc;
begin
  case FOrigin[FRun + 1] of
    '=':
      begin
        StepRun(2);
        FTokenID := tkAssign;
      end;
  else
    begin
      StepRun;
      FTokenID := tkColon;
    end;
  end;
end;

procedure TPasWideLex.CommaProc;
begin
  StepRun;
  FTokenID := tkComma;
end;

procedure TPasWideLex.CRProc;
begin
  case FComment of
    csBor:
      FTokenID := tkCRLFCo;
    csAnsi:
      FTokenID := tkCRLFCo;
  else
    FTokenID := tkCRLF;
  end;

  case FOrigin[FRun + 1] of
    #10:
      StepRun(2);
  else
    StepRun;
  end;
  Inc(FLineNumber);
  FColumn := 1;
  FLineStartOffset := FRun;
end;

procedure TPasWideLex.EqualProc;
begin
  StepRun;
  FTokenID := tkEqual;
end;

procedure TPasWideLex.GreaterProc;
begin
  case FOrigin[FRun + 1] of
    '=':
      begin
        StepRun(2);
        FTokenID := tkGreaterEqual;
      end;
  else
    begin
      StepRun;

      if FAngleCount > 0 then
      begin
        FTokenID := tkAngleClose;
        Dec(FAngleCount);
      end
      else
        FTokenID := tkGreater;
    end;
  end;
end;

function TPasWideLex.InSymbols(aChar: WideChar): Boolean;
begin
  if _WideCharInSet(aChar, ['#', '$', '&', #39, '(', ')', '*', '+', ',', '?', '.', '/', ':', ';', '<', '=', '>', '@', '[', ']', '^']) then
    Result := True
  else
    Result := False;
end;

function TPasWideLex.CharAhead(Count: Integer): WideChar;
var
  P: PWideChar;
begin
  P := FOrigin + FRun + Count;
  while _WideCharInSet(P^, [#1..#9, #11, #12, #14..#32]) do
    Inc(P);
  Result := P^;
end;

procedure TPasWideLex.IdentProc;
begin
  FTokenID := IdentKind((FOrigin + FRun));
  StepRun(FStringLen, True);
  while Identifiers[_IndexChar(FOrigin[FRun])] or
    (FSupportUnicodeIdent and (Ord(_IndexChar(FOrigin[FRun])) > 127)) do
    StepRun(1, FSupportUnicodeIdent); 
end;

procedure TPasWideLex.IntegerProc;
begin
  StepRun;
  FTokenID := tkInteger;
  while _WideCharInSet(FOrigin[FRun], ['0'..'9', 'A'..'F', 'a'..'f']) do
    StepRun;
end;

function TPasWideLex.IsFirstGreater: Boolean;
begin
  Next;
  Result := False;

  repeat
    case FTokenID of
      tkNull, tkRoundClose, tkSquareClose, tkSemiColon, tkThen, tkOf, tkDo:
        begin
          Result := False;
          Break;
        end;

      tkGreater:
        begin
          Result := True;
          Break;
        end
    else
      Next;
    end;
  until Result;
end;

procedure TPasWideLex.LFProc;
begin
  case FComment of
    csBor:
      FTokenID := tkCRLFCo;
    csAnsi:
      FTokenID := tkCRLFCo;
  else
    FTokenID := tkCRLF;
  end;

  case FOrigin[FRun + 1] of
    #13:
      StepRun(2);
  else
    StepRun;
  end;
  Inc(FLineNumber);
  FColumn := 1;
  FLineStartOffset := FRun;
end;

procedure TPasWideLex.LoadFromBookMark(var Bookmark: TPasWideBookmark);
begin
  if Bookmark <> nil then
    with Bookmark do
    begin
      FRun := RunBookmark;
      FLineNumber := LineNumberBookmark;
      FColumnNumber := ColumnNumberBookmark;
      FColumn := ColumnBookmark;
      FComment := CommentBookmark;
      FLastNoSpacePos := LastNoSpacePosBookmark;
      FStringLen := StringLenBookmark;
      FRoundCount := RoundCountBookmark;
      FLastNoSpace := LastNoSpaceBookmark;
      FToIdent := ToIdentBookmark;
      FIsClass := IsClassBookmark;
      FTokenID := TokenIDBookmark;
      FTokenPos := TokenPosBookmark;
      FIsInterface := IsInterfaceBookmark;
      FSquareCount := SquareCountBookmark;
      FAngleCount := AngleCountBookmark;
      FLastIdentPos := LastIdentPosBookmark;
      FLineStartOffset := LineStartOffsetBookmark;

      FreeAndNil(Bookmark);
    end;
end;

procedure TPasWideLex.LowerProc;
var
  LBookmark: TPasWideBookmark;
  LIsFirstGreater: Boolean;
begin
  case FOrigin[FRun + 1] of
    '=':
      begin
        StepRun(2);
        FTokenID := tkLowerEqual;
      end;
    '>':
      begin
        StepRun(2);
        FTokenID := tkNotEqual;
      end
  else
    begin
      StepRun;

      SaveToBookMark(LBookmark);
      try
        LIsFirstGreater := IsFirstGreater;
      finally
        LoadFromBookMark(LBookmark);
      end;

      if LIsFirstGreater then
      begin
        FTokenID := tkAngleOpen;
        FAngleCount := FAngleCount + 1;
      end
      else
        FTokenID := tkLower;

    end;
  end;
end;

procedure TPasWideLex.MinusProc;
begin
  StepRun;
  FTokenID := tkMinus;
end;

procedure TPasWideLex.NullProc;
begin
  FTokenID := tkNull;
end;

procedure TPasWideLex.NumberProc;
begin
  StepRun;
  FTokenID := tkNumber;
  while _WideCharInSet(FOrigin[FRun], ['0'..'9', '.', 'e', 'E']) do
  begin
    case FOrigin[FRun] of
      '.':
        if FOrigin[FRun + 1] = '.' then
          Break
        else
          FTokenID := tkFloat
    end;
    StepRun;
  end;
end;

procedure TPasWideLex.PlusProc;
begin
  StepRun;
  FTokenID := tkPlus;
end;

procedure TPasWideLex.PointerSymbolProc;
begin
  StepRun;
  FTokenID := tkPointerSymbol;
end;

procedure TPasWideLex.PointProc;
begin
  case FOrigin[FRun + 1] of
    '.':
      begin
        StepRun(2);
        FTokenID := tkDotDot;
      end;
    ')':
      begin
        StepRun(2);
        FTokenID := tkSquareClose;
        Dec(FSquareCount);
      end;
  else
    begin
      StepRun;
      FTokenID := tkPoint;
    end;
  end;
end;

procedure TPasWideLex.RoundCloseProc;
begin
  StepRun;
  FTokenID := tkRoundClose;
  Dec(FRoundCount);
  FAngleCount := 0;
end;

procedure TPasWideLex.AnsiProc;
begin
  FTokenID := tkAnsiComment;
  case FOrigin[FRun] of
    #0:
      begin
        NullProc;
        Exit;
      end;

    #10:
      begin
        LFProc;
        Exit;
      end;

    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while FOrigin[FRun] <> #0 do
    case FOrigin[FRun] of
      '*':
        if FOrigin[FRun + 1] = ')' then
        begin
          FComment := csNo;
          StepRun(2);
          Break;
        end
        else
          StepRun;
      #10:
        Break;

      #13:
        Break;
    else
      StepRun;
    end;
end;

procedure TPasWideLex.RoundOpenProc;
begin
  StepRun;
  case FOrigin[FRun] of
    '*':
      begin
        FTokenID := tkAnsiComment;
        if FOrigin[FRun + 1] = '$' then
          FTokenID := tkCompDirect
        else
          FComment := csAnsi;
        StepRun(1, True);
        while FOrigin[FRun] <> #0 do
          case FOrigin[FRun] of
            '*':
              if FOrigin[FRun + 1] = ')' then
              begin
                FComment := csNo;
                StepRun(2);
                Break;
              end
              else
                StepRun(1, True);
            #10:
              Break;
            #13:
              Break;
          else
            StepRun(1, True);
          end;
      end;
    '.':
      begin
        StepRun;
        FTokenID := tkSquareOpen;
        Inc(FSquareCount);
      end;
  else
    begin
      FTokenID := tkRoundOpen;
      Inc(FRoundCount);
    end;
  end;
end;

procedure TPasWideLex.SaveToBookMark(out Bookmark: TPasWideBookmark);
begin
  Bookmark := TPasWideBookmark.Create;
  with Bookmark do
  begin
    RunBookmark := FRun;
    LineNumberBookmark := FLineNumber;
    ColumnNumberBookmark := FColumnNumber;
    ColumnBookmark := FColumn;
    CommentBookmark := FComment;
    LastNoSpacePosBookmark := FLastNoSpacePos;
    StringLenBookmark := FStringLen;
    RoundCountBookmark := FRoundCount;
    LastNoSpaceBookmark := FLastNoSpace;
    ToIdentBookmark := FToIdent;
    IsClassBookmark := FIsClass;
    TokenIDBookmark := FTokenID;
    TokenPosBookmark := FTokenPos;
    IsInterfaceBookmark := FIsInterface;
    SquareCountBookmark := FSquareCount;
    AngleCountBookmark := FAngleCount;
    LastIdentPosBookmark := FLastIdentPos;
    LineStartOffsetBookmark := FLineStartOffset;
  end;
end;

procedure TPasWideLex.SemiColonProc;
begin
  StepRun;
  FTokenID := tkSemiColon;
end;

procedure TPasWideLex.SlashProc;
begin
  case FOrigin[FRun + 1] of
    '/':
      begin
        StepRun(2);
        FTokenID := tkSlashesComment;
        while FOrigin[FRun] <> #0 do
        begin
          case FOrigin[FRun] of
            #10, #13:
              Break;
          end;
          StepRun;
        end;
      end;
  else
    begin
      StepRun;
      FTokenID := tkSlash;
    end;
  end;
end;

procedure TPasWideLex.SpaceProc;
begin
  StepRun;
  FTokenID := tkSpace;
  while _WideCharInSet(FOrigin[FRun], [#1..#9, #11, #12, #14..#32]) do
    StepRun;
end;

procedure TPasWideLex.SquareCloseProc;
begin
  StepRun;
  FTokenID := tkSquareClose;
  Dec(FSquareCount);
  FAngleCount := 0;
end;

procedure TPasWideLex.SquareOpenProc;
begin
  StepRun;
  FTokenID := tkSquareOpen;
  Inc(FSquareCount);
end;

procedure TPasWideLex.StarProc;
begin
  StepRun;
  FTokenID := tkStar;
end;

procedure TPasWideLex.StepRun(Count: Integer; CalcColumn: Boolean);
var
  I: Integer;
begin
  if not CalcColumn then
    Inc(FColumn, Count)
  else
  begin
    for I := 0 to Count - 1 do
    begin
      if Ord(FOrigin[FRun + I]) > $900 then
        Inc(FColumn, SizeOf(WideChar))
      else 
        Inc(FColumn, SizeOf(AnsiChar));
    end;
  end;
  Inc(FRun, Count);
end;

procedure TPasWideLex.StringProc;
begin
  FTokenID := tkString;
  if (FOrigin[FRun + 1] = #39) and (FOrigin[FRun + 2] = #39) then
    StepRun(2);
  repeat
    case FOrigin[FRun] of
      #0, #10, #13:
        Break;
    end;
    StepRun(1, True); 
  until FOrigin[FRun] = #39;
  if FOrigin[FRun] <> #0 then
    StepRun;
end;

procedure TPasWideLex.BadStringProc;
begin
  FTokenID := tkBadString;
  repeat
    case FOrigin[FRun] of
      #0, #10, #13:
        Break;
    end;
    StepRun(1, True); 
  until FOrigin[FRun] = '"';
  if FOrigin[FRun] <> #0 then
    StepRun;
end;

procedure TPasWideLex.SymbolProc;
begin
  StepRun;
  FTokenID := tkSymbol;
end;

procedure TPasWideLex.AmpersandProc;
begin
  StepRun;
  FTokenID := tkAmpersand;
end;

procedure TPasWideLex.UnknownProc;
begin
  StepRun;
  FTokenID := tkUnknown;
end;

procedure TPasWideLex.Next;
var
  W: WideChar;
  C: CnIndexChar;
begin
  case FTokenID of
    tkIdentifier:
      begin
        FLastIdentPos := FTokenPos;
        FLastNoSpace := FTokenID;
        FLastNoSpacePos := FTokenPos;
      end;
    tkSpace:
      ;
  else
    begin
      FLastNoSpace := FTokenID;
      FLastNoSpacePos := FTokenPos;
    end;
  end;
  FTokenPos := FRun;
  FColumnNumber := FColumn;

  case FComment of
    csNo:
    begin
      W := FOrigin[FRun];
      C := _IndexChar(W);
      if FSupportUnicodeIdent then
      begin
        if Ord(W) > 127 then
          IdentProc
        else
          FProcTable[C];
      end
      else
      begin
{$IFDEF D2009}
        if Ord(W) > 255 then
          UnknownProc
        else
{$ENDIF}
          FProcTable[C];
      end;
    end;
  else
    case FComment of
      csBor:
        BorProc;
      csAnsi:
        AnsiProc;
    end;
  end;
end;

function TPasWideLex.GetToken: CnWideString;
var
  Len: LongInt;
  OutStr: CnWideString;
begin
  Len := FRun - FTokenPos;                         
  SetString(OutStr, (FOrigin + FTokenPos), Len);   
  Result := OutStr;
end;

procedure TPasWideLex.NextID(ID: TTokenKind);
begin
  repeat
    case FTokenID of
      tkNull:
        Break;
    else
      Next;
    end;
  until FTokenID = ID;
end;

procedure TPasWideLex.NextNoJunk;
begin
  repeat
    Next;
  until not (FTokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF,
    tkCRLFCo, tkSpace]);
end;

procedure TPasWideLex.NextClass;
begin
  if FTokenID <> tkNull then
    next;
  repeat
    case FTokenID of
      tkNull:
        Break;
    else
      Next;
    end;
  until(FTokenID = tkClass) and (IsClass);
end;

function TPasWideLex.GetTokenAddr: PWideChar;
begin
  Result := FOrigin + FTokenPos;
end;

function TPasWideLex.GetTokenLength: Integer;
begin
  Result := FRun - FTokenPos;
end;

function TPasWideLex.GetWideColumnNumber: Integer;
begin
  Result := FTokenPos - FLineStartOffset + 1;
end;

initialization
  MakeIdentTable;

end.

