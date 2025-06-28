unit WidePasParser;

interface

{$I ..\Compiler.inc}

uses
  Windows, SysUtils, Classes, PasWideLex, mwBCBTokenList,
  Contnrs, FastList, CnContainers, mPasLexTypes;

type
{$IFDEF D2009}
  CnWideString = string;
{$ELSE}
  CnWideString = WideString;
{$ENDIF}

  TWidePasToken = class(TPersistent)
  private
    FEditAnsiCol: Integer;
    FTag: Integer;
    function GetToken: PWideChar;
  protected
    FCppTokenKind: TCTokenKind;
    FCompDirectiveType: TCompDirectiveType;
    FCharIndex: Integer;
    FAnsiIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FTokenLength: Integer;
    FColumnNumber: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: array[0..CN_TOKEN_MAX_SIZE] of WideChar;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FMethodStartAfterParentBegin: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
    FIsMethodInterface: Boolean;
  public
    procedure Clear;

    property UseAsC: Boolean read FUseAsC;
    property IsMethodInterface: Boolean read FIsMethodInterface;
    property LineNumber: Integer read FLineNumber; // Start 0
    property ColumnNumber: Integer read FColumnNumber; // Start 0
    property TokenLength: Integer read FTokenLength;
    property CharIndex: Integer read FCharIndex;   // Start 0
    property AnsiIndex: Integer read FAnsiIndex;   // Start 0

    property EditCol: Integer read FEditCol write FEditCol;
    property EditLine: Integer read FEditLine write FEditLine;
    property EditAnsiCol: Integer read FEditAnsiCol write FEditAnsiCol;

    property ItemIndex: Integer read FItemIndex;
    property ItemLayer: Integer read FItemLayer;
    property MethodLayer: Integer read FMethodLayer;
    property Token: PWideChar read GetToken;
    property TokenID: TTokenKind read FTokenID;
    property CppTokenKind: TCTokenKind read FCppTokenKind;
    property TokenPos: Integer read FTokenPos;
    property IsBlockStart: Boolean read FIsBlockStart;
    property IsBlockClose: Boolean read FIsBlockClose;
    property IsMethodStart: Boolean read FIsMethodStart;
    property IsMethodClose: Boolean read FIsMethodClose;
    property MethodStartAfterParentBegin: Boolean read FMethodStartAfterParentBegin;
    property CompDirectivtType: TCompDirectiveType read FCompDirectiveType write FCompDirectiveType;
    property Tag: Integer read FTag write FTag;
  end;


  { TCnPasStructureParser }

  TWidePasStructParser = class(TObject)
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TWidePasToken;
    FBlockStartToken: TWidePasToken;
    FChildMethodCloseToken: TWidePasToken;
    FChildMethodStartToken: TWidePasToken;
    FCurrentChildMethod: CnWideString;
    FCurrentMethod: CnWideString;
    FKeyOnly: Boolean;
    FList: TCnList;
    FMethodCloseToken: TWidePasToken;
    FMethodStartToken: TWidePasToken;
    FSource: CnWideString;
    FInnerBlockCloseToken: TWidePasToken;
    FInnerBlockStartToken: TWidePasToken;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    FMethodStack: TCnObjectStack;
    FBlockStack: TCnObjectStack;
    FMidBlockStack: TCnObjectStack;
    FProcStack: TCnObjectStack;
    FIfStack: TCnObjectStack;
    function GetCount: Integer;
    function GetToken(Index: Integer): TWidePasToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PWideChar; AIsDpr, AKeyOnly: Boolean);
    function FindCurrentDeclaration(LineNumber, WideCharIndex: Integer): CnWideString;
    procedure FindCurrentBlock(LineNumber, WideCharIndex: Integer);
    function IndexOfToken(Token: TWidePasToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TWidePasToken read GetToken;
    property MethodStartToken: TWidePasToken read FMethodStartToken;
    property MethodCloseToken: TWidePasToken read FMethodCloseToken;
    property ChildMethodStartToken: TWidePasToken read FChildMethodStartToken;
    property ChildMethodCloseToken: TWidePasToken read FChildMethodCloseToken;
    property BlockStartToken: TWidePasToken read FBlockStartToken;
    property BlockCloseToken: TWidePasToken read FBlockCloseToken;
    property InnerBlockStartToken: TWidePasToken read FInnerBlockStartToken;
    property InnerBlockCloseToken: TWidePasToken read FInnerBlockCloseToken;
    property CurrentMethod: CnWideString read FCurrentMethod;
    property CurrentChildMethod: CnWideString read FCurrentChildMethod;
    property Source: CnWideString read FSource;
    property KeyOnly: Boolean read FKeyOnly;
    
    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    property TabWidth: Integer read FTabWidth write FTabWidth;
  end;

procedure ParseUnitUsesW(const Source: CnWideString; UsesList: TStrings;
  SupportUnicodeIdent: Boolean = False);

implementation

type
  TCnProcObj = class
  private
    FToken: TWidePasToken;
    FBeginToken: TWidePasToken;
    FNestCount: Integer;
    function GetIsNested: Boolean;
    function GetBeginMatched: Boolean;
    function GetLayer: Integer;
  public
    property Token: TWidePasToken read FToken write FToken;
    property Layer: Integer read GetLayer;
    property BeginMatched: Boolean read GetBeginMatched;
    property BeginToken: TWidePasToken read FBeginToken write FBeginToken;
    property IsNested: Boolean read GetIsNested;
    property NestCount: Integer read FNestCount write FNestCount;
  end;

  TCnIfStatement = class
  private
    FLevel: Integer;
    FIfStart: TWidePasToken;
    FIfBegin: TWidePasToken;
    FIfEnded: Boolean;             
    FElseToken: TWidePasToken;
    FElseBegin: TWidePasToken;
    FElseEnded: Boolean;           
    FElseList: TObjectList;        
    FIfList: TObjectList;          
    FElseIfBeginList: TObjectList; 
    FElseIfEnded: TList;           
    FIfAllEnded: Boolean;          
    function GetElseIfCount: Integer;
    function GetElseIfElse(Index: Integer): TWidePasToken;
    function GetElseIfIf(Index: Integer): TWidePasToken;
    function GetLastElseIfElse: TWidePasToken;
    function GetLastElseIfIf: TWidePasToken;
    procedure SetIfStart(const Value: TWidePasToken);
    function GetLastElseIfBegin: TWidePasToken;
    procedure SetFIfBegin(const Value: TWidePasToken);
    procedure SetElseBegin(const Value: TWidePasToken);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function HasElse: Boolean;

    procedure ChangeElseToElseIf(AIf: TWidePasToken);
    procedure AddBegin(ABegin: TWidePasToken);
    
    procedure EndLastElseIfBlock;
    procedure EndElseBlock;
    procedure EndIfBlock;
    procedure EndIfAll;
    
    property Level: Integer read FLevel write FLevel;
    property IfStart: TWidePasToken read FIfStart write SetIfStart;
    property IfBegin: TWidePasToken read FIfBegin write SetFIfBegin;
    property ElseToken: TWidePasToken read FElseToken write FElseToken;
    property ElseBegin: TWidePasToken read FElseBegin write SetElseBegin;
    property ElseIfCount: Integer read GetElseIfCount;
    property ElseIfElse[Index: Integer]: TWidePasToken read GetElseIfElse;
    property ElseIfIf[Index: Integer]: TWidePasToken read GetElseIfIf;
    property LastElseIfElse: TWidePasToken read GetLastElseIfElse;
    property LastElseIfIf: TWidePasToken read GetLastElseIfIf;
    property LastElseIfBegin: TWidePasToken read GetLastElseIfBegin;
    property IfAllEnded: Boolean read FIfAllEnded;
  end;

var
  TokenPool: TCnList;

function WideTrim(const S: CnWideString): CnWideString;
{$IFNDEF D2009}
var
  I, L: Integer;
{$ENDIF}
begin
{$IFDEF D2009}
  Result := Trim(S);
{$ELSE}
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
{$ENDIF}
end;

function CreatePasToken: TWidePasToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TWidePasToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TWidePasToken.Create;
end;

procedure FreePasToken(Token: TWidePasToken);
begin
  if Token <> nil then
  begin
    Token.Clear;
    TokenPool.Add(Token);
  end;
end;

procedure ClearTokenPool;
var
  I: Integer;
begin
  for I := 0 to TokenPool.Count - 1 do
    TObject(TokenPool[I]).Free;
end;

procedure LexNextNoJunkWithoutCompDirect(Lex: TPasWideLex);
begin
  repeat
    Lex.Next;
  until not (Lex.TokenID in [{tkSlashesComment, tkAnsiComment, tkBorComment,} tkCRLF,
    tkCRLFCo, tkSpace{, tkCompDirect}]);
end;


{ TCnPasStructureParser }

constructor TWidePasStructParser.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FList := TCnList.Create;
  FTabWidth := 2;
  FSupportUnicodeIdent := SupportUnicodeIdent;

  FMethodStack := TCnObjectStack.Create;
  FBlockStack := TCnObjectStack.Create;
  FMidBlockStack := TCnObjectStack.Create;
  FProcStack := TCnObjectStack.Create;
  FIfStack := TCnObjectStack.Create;
end;

destructor TWidePasStructParser.Destroy;
begin
  Clear;
  FMethodStack.Free;
  FBlockStack.Free;
  FMidBlockStack.Free;
  FProcStack.Free;
  FIfStack.Free;
  FList.Free;
  inherited;
end;

procedure TWidePasStructParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreePasToken(TWidePasToken(FList[I]));
  FList.Clear;

  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
  FSource := '';
end;

function TWidePasStructParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TWidePasStructParser.GetToken(Index: Integer): TWidePasToken;
begin
  Result := TWidePasToken(FList[Index]);
end;

procedure TWidePasStructParser.ParseSource(ASource: PWideChar; AIsDpr, AKeyOnly:
  Boolean);
var
  Lex: TPasWideLex;
  Token, CurrMethod, CurrBlock, CurrMidBlock, CurrIfStart: TWidePasToken;
  Bookmark: TPasWideBookmark;
  IsClassOpen, IsClassMethod, IsClassDef, IsImpl, IsHelper, IsElseIf, ExpectElse: Boolean;
  IsRecordHelper, IsSealed, IsAbstract, IsRecord, IsObjectRecord, IsForFunc: Boolean;
  SameBlockMethod, CanEndBlock, CanEndMethod: Boolean;
  LPrevTokenIsMethodInterface: Boolean;
  LRoundOpen: Boolean;
  DeclareWithEndLevel: Integer;
  PrevTokenID: TTokenKind;
  PrevTokenStr: CnWideString;
  AProcObj, PrevProcObj: TCnProcObj;
  AIfObj: TCnIfStatement;

  procedure CalcCharIndexes(out ACharIndex: Integer; out AnAnsiIndex: Integer);
  var
    I, AnsiLen, WideLen: Integer;
  begin
    if FUseTabKey and (FTabWidth >= 2) then
    begin
      I := Lex.LineStartOffset;
      AnsiLen := 0;
      WideLen := 0;
      while I < Lex.TokenPos do
      begin
        if (ASource[I] = #09) then
        begin
          AnsiLen := ((AnsiLen div FTabWidth) + 1) * FTabWidth;
          WideLen := ((WideLen div FTabWidth) + 1) * FTabWidth;
        end
        else
        begin
          Inc(WideLen);
          if Ord(ASource[I]) > $900 then
            Inc(AnsiLen, SizeOf(WideChar))
          else
            Inc(AnsiLen, SizeOf(AnsiChar));
        end;
        Inc(I);
      end;
      ACharIndex := WideLen;
      AnAnsiIndex := AnsiLen;
    end
    else
    begin
      ACharIndex := Lex.TokenPos - Lex.LineStartOffset;
      AnAnsiIndex := Lex.ColumnNumber - 1;
    end;
  end;

  procedure NewToken;
  var
    Len: Integer;
  begin
    Token := CreatePasToken;
    Token.FTokenPos := Lex.TokenPos;
    Token.FIsMethodInterface := LPrevTokenIsMethodInterface;

    Len := Lex.TokenLength;
    if Len > CN_TOKEN_MAX_SIZE then
      Len := CN_TOKEN_MAX_SIZE;
    // FillChar(Token.FToken[0], SizeOf(Token.FToken), 0);
    CopyMemory(@Token.FToken[0], Lex.TokenAddr, Len * SizeOf(WideChar));
    Token.FToken[Len] := #0;

    Token.FLineNumber := Lex.LineNumber - 1;
    Token.FColumnNumber := Lex.ColumnNumber;
    Token.FTokenLength := Lex.TokenLength;
    CalcCharIndexes(Token.FCharIndex, Token.FAnsiIndex);

    Token.FTokenID := Lex.TokenID;
    Token.FItemIndex := FList.Count;
    if CurrBlock <> nil then
      Token.FItemLayer := CurrBlock.FItemLayer;

    if CurrMethod <> nil then
    begin
      Token.FMethodLayer := CurrMethod.FMethodLayer;
      if CurrBlock = nil then
        Token.FItemLayer := CurrMethod.FMethodLayer;
    end;
    FList.Add(Token);
  end;

  procedure DiscardToken(Forced: Boolean = False);
  begin
    if (AKeyOnly or Forced) and (FList.Count > 0) then
    begin
      FreePasToken(FList[FList.Count - 1]);
      FList.Delete(FList.Count - 1);
    end;
  end;

  procedure ClearStackAndFreeObject(AStack: TCnObjectStack);
  begin
    if AStack = nil then
      Exit;

    while AStack.Count > 0 do
      AStack.Pop.Free;
  end;

begin
  Clear;
  Lex := nil;
  PrevTokenID := tkProgram;

  try
    FSource := ASource;
    FKeyOnly := AKeyOnly;

    FMethodStack.Clear;
    FBlockStack.Clear;
    FMidBlockStack.Clear;
    FProcStack.Clear;
    FIfStack.Clear;

    Lex := TPasWideLex.Create(FSupportUnicodeIdent);
    Lex.Origin := PWideChar(ASource);

    DeclareWithEndLevel := 0;
    Token := nil;
    CurrMethod := nil;
    CurrBlock := nil;
    CurrMidBlock := nil;
    IsImpl := AIsDpr;
    IsHelper := False;
    IsRecordHelper := False;
    ExpectElse := False;

    while Lex.TokenID <> tkNull do
    begin
      if ExpectElse and (Lex.TokenID <> tkElse) and not FIfStack.IsEmpty then
        FIfStack.Pop.Free;
      ExpectElse := False;

      if {IsImpl and } (Lex.TokenID in [tkCompDirect, tkSlashesComment, tkAnsiComment, tkBorComment]) or // Allow CompDirect
        ((PrevTokenID <> tkAmpersand) and (Lex.TokenID in
        [tkProcedure, tkFunction, tkConstructor, tkDestructor,
        tkInitialization, tkFinalization,
        tkBegin, tkAsm,
        tkCase, tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
        tkRecord, tkObject, tkOf, tkEqual,
        tkClass, tkInterface, tkDispinterface,
        tkExcept, tkFinally, tkElse,
        tkEnd, tkUntil, tkThen, tkDo,
        tkAngleOpen, tkAngleClose]))
      then
      begin
        NewToken;

        case Lex.TokenID of
          tkAngleOpen, tkAngleClose:
            begin
              Token.FIsMethodInterface := False;
            end;

          tkProcedure, tkFunction, tkConstructor, tkDestructor:
            begin
              if (Lex.TokenID in [tkProcedure, tkFunction, tkConstructor]) and
                 not (PrevTokenID in [tkEqual, tkColon])
              then
                Token.FIsMethodInterface := True;

              if IsImpl and ((not (Lex.TokenID in [tkProcedure, tkFunction]))
                or (not (PrevTokenID in [tkEqual, tkColon, tkTo{, tkAssign, tkRoundOpen, tkComma}])))
                and (DeclareWithEndLevel <= 0) then
              begin
                // DeclareWithEndLevel <= 0  class/record
//                while BlockStack.Count > 0 do
//                  BlockStack.Pop;
//                CurrBlock := nil;
                if CurrBlock = nil then
                  Token.FItemLayer := 1
                else
                  Token.FItemLayer := CurrBlock.ItemLayer;
                Token.FIsMethodStart := True;

                if CurrMethod <> nil then
                begin
                  Token.FMethodLayer := CurrMethod.FMethodLayer + 1;
                  FMethodStack.Push(CurrMethod);
                end
                else
                  Token.FMethodLayer := 1;
                CurrMethod := Token;

                if FProcStack.IsEmpty then
                  PrevProcObj := nil
                else
                  PrevProcObj := TCnProcObj(FProcStack.Peek);

                AProcObj := TCnProcObj.Create;
                AProcObj.Token := Token;
                FProcStack.Push(AProcObj);

                if PrevProcObj <> nil then
                begin
                  if PrevProcObj.BeginMatched then
                    Token.FMethodStartAfterParentBegin := True
                  else
                    AProcObj.NestCount := PrevProcObj.NestCount + 1;
                end;
              end;
            end;
          tkInitialization, tkFinalization:
            begin
              while FBlockStack.Count > 0 do
                FBlockStack.Pop;
              CurrBlock := nil;
              while FMethodStack.Count > 0 do
                FMethodStack.Pop;
              CurrMethod := nil;
            end;
          tkBegin, tkAsm:
            begin
              Token.FIsBlockStart := True;
              if (CurrMethod <> nil) and ((CurrBlock = nil) or
                (CurrBlock.ItemIndex < CurrMethod.ItemIndex))
              then
                Token.FIsMethodStart := True;

              if (CurrBlock <> nil) and ((CurrMethod = nil) or (CurrMethod.ItemIndex < CurrBlock.ItemIndex)) then
                Token.FItemLayer := CurrBlock.FItemLayer + 1
              else if CurrMethod <> nil then
                Token.FItemLayer := CurrMethod.FItemLayer + 1
              else
                Token.FItemLayer := 0;

              FBlockStack.Push(CurrBlock);
              CurrBlock := Token;

              if FProcStack.Count > 0 then
              begin
                AProcObj := TCnProcObj(FProcStack.Peek);
                if (AProcObj.Token <> nil) and Token.FIsMethodStart then
                begin
                  Token.FMethodStartAfterParentBegin := AProcObj.Token.FMethodStartAfterParentBegin;
                end;

                if not AProcObj.BeginMatched then
                begin
                  if AProcObj.IsNested then
                    Inc(Token.FItemLayer, AProcObj.NestCount);

                  AProcObj.BeginToken := Token;
                end;
              end;

              if (Lex.TokenID = tkBegin) and (PrevTokenID in [tkThen, tkElse]) and not FIfStack.IsEmpty then
              begin
                AIfObj := TCnIfStatement(FIfStack.Peek);
                if AIfObj.Level = Token.ItemLayer then
                  AIfObj.AddBegin(Token);
              end;
            end;
          tkCase:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkRecord) then
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 0;
                CurrBlock := Token;
              end
              else
                DiscardToken(True);
            end;
          tkTry, tkRepeat, tkIf, tkFor, tkWith, tkOn, tkWhile,
          tkRecord, tkObject:
            begin
              IsRecord := Lex.TokenID = tkRecord;
              IsObjectRecord := Lex.TokenID = tkObject;
              IsForFunc := (PrevTokenID in [tkPoint]) or
                ((PrevTokenID = tkSymbol) and (PrevTokenStr = '&'));
              if IsRecord then
              begin
                IsRecordHelper := False;
                Lex.SaveToBookMark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                    IsRecordHelper := True;
                end;

                Lex.LoadFromBookMark(Bookmark);
              end;

              if ((Lex.TokenID <> tkObject) or (PrevTokenID <> tkOf))
                and not (PrevTokenID in [tkAt, tkDoubleAddressOp])
                and not IsForFunc
                and not ((Lex.TokenID = tkFor) and (IsHelper or IsRecordHelper)) then
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                  if (CurrBlock.TokenID = tkTry) and (Token.TokenID = tkTry)
                    and (CurrMidBlock <> nil) then
                  begin
                    FMidBlockStack.Push(CurrMidBlock);
                    CurrMidBlock := nil;
                  end;
                end
                else
                  Token.FItemLayer := 0;

                CurrBlock := Token;

                if IsRecord or IsObjectRecord then
                begin
                  // IsInDeclareWithEnd := True;
                  Inc(DeclareWithEndLevel);
                end;
              end;

              if Lex.TokenID = tkFor then
              begin
                if IsHelper then
                  IsHelper := False;
                if IsRecordHelper then
                  IsRecordHelper := False;
              end;

              if Lex.TokenID = tkIf then
              begin
                IsElseIf := False;
                if PrevTokenID = tkElse then
                begin
                  if not FIfStack.IsEmpty then
                  begin
                    AIfObj := TCnIfStatement(FIfStack.Peek);
                    if AIfObj.Level = Token.ItemLayer then
                    begin
                      AIfObj.ChangeElseToElseIf(Token);
                      IsElseIf := True;
                    end;
                  end;
                end;

                if not IsElseIf then
                begin
                  AIfObj := TCnIfStatement.Create;
                  AIfObj.IfStart := Token;
                  FIfStack.Push(AIfObj);
                end;
              end;
            end;
          tkClass, tkInterface, tkDispInterface:
            begin
              IsHelper := False;
              IsSealed := False;
              IsAbstract := False;
              IsClassMethod := False;
              IsClassDef := ((Lex.TokenID = tkClass) and Lex.IsClass)
                or ((Lex.TokenID = tkInterface) and Lex.IsInterface) or
                (Lex.TokenID = tkDispInterface);

              if not IsClassDef and (Lex.TokenID = tkClass) and not Lex.IsClass then
              begin
                Lex.SaveToBookMark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID in [tkSymbol, tkIdentifier, tkSealed, tkAbstract, tkProcedure, tkFunction] then
                begin
                  if LowerCase(Lex.Token) = 'helper' then
                  begin
                    IsClassDef := True;
                    IsHelper := True;
                  end
                  else if Lex.TokenID = tkSealed then
                  begin
                    IsClassDef := True;
                    IsSealed := True;
                  end
                  else if Lex.TokenID = tkAbstract then
                  begin
                    IsClassDef := True;
                    IsAbstract := True;
                  end
                  else if Lex.TokenID in [tkProcedure, tkFunction] then
                    IsClassMethod := True;
                end;

                Lex.LoadFromBookMark(Bookmark);
              end;

              IsClassOpen := False;
              if IsClassDef then
              begin
                IsClassOpen := True;
                Lex.SaveToBookMark(Bookmark);

                LexNextNoJunkWithoutCompDirect(Lex);
                if Lex.TokenID = tkSemiColon then
                  IsClassOpen := False
                else if IsHelper or IsSealed or IsAbstract then
                  LexNextNoJunkWithoutCompDirect(Lex);

                if Lex.TokenID = tkRoundOpen then
                begin
                  while not (Lex.TokenID in [tkNull, tkRoundClose]) do
                    LexNextNoJunkWithoutCompDirect(Lex);
                  if Lex.TokenID = tkRoundClose then
                    LexNextNoJunkWithoutCompDirect(Lex);
                end;

                if Lex.TokenID = tkSemiColon then
                  IsClassOpen := False
                else if Lex.TokenID = tkFor then
                  IsClassOpen := True;

                Lex.LoadFromBookMark(Bookmark);
              end;

              if IsClassOpen then
              begin
                Token.FIsBlockStart := True;
                if CurrBlock <> nil then
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer + 1;
                  FBlockStack.Push(CurrBlock);
                end
                else
                  Token.FItemLayer := 0;

                CurrBlock := Token;
                // IsInDeclareWithEnd := True;
                Inc(DeclareWithEndLevel);
              end
              else
              if IsClassMethod then
              begin
                Token.FIsMethodInterface := True;
                Token.FIsMethodStart := True;
                CurrBlock := Token;
                if CurrBlock = nil then
                  Token.FItemLayer := 0;
              end
              else
                DiscardToken(Token.TokenID in [tkClass, tkInterface, tkDispinterface]);
            end;
          tkExcept, tkFinally:
            begin
              if (CurrBlock = nil) or (CurrBlock.TokenID <> tkTry) then
                DiscardToken
              else if CurrMidBlock = nil then
              begin
                CurrMidBlock := Token;
              end
              else
                DiscardToken;
            end;
          tkElse:
            begin
              CurrIfStart := nil;
              if not FIfStack.IsEmpty then
              begin
                AIfObj := TCnIfStatement(FIfStack.Peek);
                if AIfObj.IfStart <> nil then
                  CurrIfStart := AIfObj.IfStart;
              end;

              if (CurrBlock = nil) or (PrevTokenID in [tkAt, tkDoubleAddressOp]) then
                DiscardToken
              else if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) and
                (CurrMidBlock.TokenID = tkExcept) and
                ((CurrIfStart = nil) or (CurrIfStart.ItemIndex <= CurrBlock.ItemIndex)) then
                Token.FItemLayer := CurrBlock.FItemLayer
              else if (CurrBlock.TokenID = tkCase) and
                ((CurrIfStart = nil) or (CurrIfStart.ItemIndex <= CurrBlock.ItemIndex))then
                Token.FItemLayer := CurrBlock.FItemLayer
              else if not FIfStack.IsEmpty then
              begin
                AIfObj := TCnIfStatement(FIfStack.Peek);
                Token.FItemLayer := AIfObj.Level;
                if not AIfObj.HasElse then
                  AIfObj.ElseToken := Token;
              end;
            end;
          tkEnd, tkUntil, tkThen, tkDo:
            begin
              if (CurrBlock <> nil) and not (PrevTokenID in [tkPoint, tkAt, tkDoubleAddressOp]) then
              begin
                if ((Lex.TokenID = tkUntil) and (CurrBlock.TokenID <> tkRepeat))
                  or ((Lex.TokenID = tkThen) and (CurrBlock.TokenID <> tkIf))
                  or ((Lex.TokenID = tkDo) and not (CurrBlock.TokenID in
                  [tkOn, tkWhile, tkWith, tkFor])) then
                begin
                  DiscardToken;
                end
                else
                begin
                  Token.FItemLayer := CurrBlock.FItemLayer;
                  Token.FIsBlockClose := True;
                  if (CurrBlock.TokenID = tkTry) and (CurrMidBlock <> nil) then
                  begin
                    if FMidBlockStack.Count > 0 then
                      CurrMidBlock := TWidePasToken(FMidBlockStack.Pop)
                    else
                      CurrMidBlock := nil;
                  end;

                  CanEndBlock := False;
                  CanEndMethod := False;
                  if (CurrBlock = nil) and (CurrMethod = nil) then
                  begin
                    CanEndBlock := False;
                    CanEndMethod := False;
                  end
                  else if (CurrBlock = nil) and (CurrMethod <> nil) then
                  begin
                    CanEndBlock := False;
                    CanEndMethod := True;
                  end
                  else if (CurrBlock <> nil) and (CurrMethod = nil) then
                  begin
                    CanEndBlock := True;
                    CanEndMethod := False;
                  end
                  else if (CurrBlock <> nil) and (CurrMethod <> nil) then
                  begin
                    SameBlockMethod := False;
                    if not FProcStack.IsEmpty then
                    begin
                      AProcObj := TCnProcObj(FProcStack.Peek);
                      if (AProcObj.Token = CurrMethod) and (AProcObj.BeginToken = CurrBlock) then
                        SameBlockMethod := True;
                    end;

                    if SameBlockMethod then
                    begin
                      CanEndMethod := True;
                      CanEndBlock := True;
                    end
                    else
                    begin
                      CanEndBlock := CurrBlock.ItemIndex >= CurrMethod.ItemIndex;
                      CanEndMethod := CurrMethod.ItemIndex >= CurrBlock.ItemIndex;
                    end;
                  end;

                  if CanEndBlock or (Lex.TokenID <> tkEnd) then
                  begin
                  if FBlockStack.Count > 0 then
                  begin
                    CurrBlock := TWidePasToken(FBlockStack.Pop);
                  end
                  else
                  begin
                    CurrBlock := nil;
                    end;
                  end;

                  if CanEndMethod and (Lex.TokenID = tkEnd) then
                  begin
                    if (CurrMethod <> nil) and (DeclareWithEndLevel <= 0) then
                    begin
                      Token.FIsMethodClose := True;
                      Token.FMethodStartAfterParentBegin := CurrMethod.MethodStartAfterParentBegin;
                      if FMethodStack.Count > 0 then
                        CurrMethod := TWidePasToken(FMethodStack.Pop)
                      else
                        CurrMethod := nil;
                    end;
                  end;
                end;
              end
              else
                DiscardToken(Token.TokenID = tkEnd);

              if (DeclareWithEndLevel > 0) and (Lex.TokenID = tkEnd) then
                Dec(DeclareWithEndLevel);

              if Lex.TokenID = tkEnd then
              begin
                if FProcStack.Count > 0 then
                begin
                  AProcObj := TCnProcObj(FProcStack.Peek);
                  if AProcObj.BeginMatched and (AProcObj.Layer = Token.ItemLayer) then
                    FProcStack.Pop.Free;
                end;

                if not FIfStack.IsEmpty then
                begin
                  AIfObj := TCnIfStatement(FIfStack.Peek);
                  if (AIfObj.LastElseIfBegin <> nil) and
                    (AIfObj.LastElseIfBegin.ItemLayer = Token.ItemLayer) then
                  begin
                    AIfObj.EndLastElseIfBlock;
                    ExpectElse := True;
                  end
                  else if (AIfObj.ElseBegin <> nil) and (AIfObj.ElseBegin.ItemLayer = Token.ItemLayer) then
                  begin
                    AIfObj.EndElseBlock;
                    AIfObj.EndIfAll;
                  end
                  else if (AIfObj.IfBegin <> nil) and (AIfObj.IfBegin.ItemLayer = Token.ItemLayer) then
                  begin
                    AIfObj.EndIfBlock;
                    ExpectElse := True;
                  end
                  else if (AIfObj.LastElseIfBegin = nil) and (AIfObj.LastElseIfIf <> nil) and
                    (AIfObj.LastElseIfIf.ItemLayer > Token.ItemLayer) then
                  begin
                    AIfObj.EndLastElseIfBlock;
                    AIfObj.EndIfAll;
                  end
                  else if (AIfObj.ElseBegin = nil) and (AIfObj.ElseToken <> nil) and
                    (AIfObj.ElseToken.ItemLayer > Token.ItemLayer) then
                  begin
                    AIfObj.EndElseBlock;
                    AIfObj.EndIfAll;
                  end
                  else if (AIfObj.IfBegin = nil) and (AIfObj.IfStart.ItemLayer > Token.ItemLayer) then
                  begin
                    AIfObj.EndIfBlock;
                    AIfObj.EndIfAll;
                  end;

                  if AIfObj.FIfAllEnded then
                    FIfStack.Pop.Free;
                end;
              end;
            end;
        end;
      end
      else
      begin
        if not IsImpl and (Lex.TokenID = tkImplementation) then
          IsImpl := True;

        if (Lex.TokenID = tkSemicolon) and not FIfStack.IsEmpty then
        begin
          AIfObj := TCnIfStatement(FIfStack.Peek);

	    	  if CurrBlock <> nil then
          begin
            if AIfObj.HasElse and (AIfObj.ElseBegin = nil) and
              (CurrBlock.ItemIndex <= AIfObj.ElseToken.ItemIndex) then
            begin
              AIfObj.EndElseBlock;
              AIfObj.EndIfAll;
            end
            else if (AIfObj.ElseIfCount > 0) and (AIfObj.LastElseIfBegin = nil)
              and (AIfObj.LastElseIfIf <> nil) and
              (CurrBlock.ItemIndex <= AIfObj.LastElseIfIf.ItemIndex) then
            begin
              AIfObj.EndLastElseIfBlock;       
              AIfObj.EndIfAll;
            end
            else if (AIfObj.IfBegin = nil) and
              (CurrBlock.ItemIndex <= AIfObj.IfStart.ItemIndex) then  
            begin
              AIfObj.EndIfBlock;
              AIfObj.EndIfAll;
            end;

            if AIfObj.IfAllEnded then
              FIfStack.Pop.Free;
          end;
        end;

        if (CurrMethod <> nil) and 
          (Lex.TokenID in [tkForward, tkExternal]) and (PrevTokenID = tkSemicolon) then
        begin
          CurrMethod.FIsMethodStart := False;
          if AKeyOnly and (CurrMethod.FItemIndex = FList.Count - 1) then
          begin
            FreePasToken(FList[FList.Count - 1]);
            FList.Delete(FList.Count - 1);
          end;
          if FMethodStack.Count > 0 then
            CurrMethod := TWidePasToken(FMethodStack.Pop)
          else
            CurrMethod := nil;

          if FProcStack.Count > 0 then
          begin
            AProcObj := TCnProcObj(FProcStack.Pop);
            AProcObj.Free;
          end;
        end;

        if not AKeyOnly and ((PrevTokenID <> tkAmpersand) or (Lex.TokenID = tkIdentifier)) then
          NewToken;
      end;

      LPrevTokenIsMethodInterface := Token.FIsMethodInterface;

      if LPrevTokenIsMethodInterface then
        if Token.TokenID = tkRoundOpen then LRoundOpen := True else
        if Token.TokenID = tkRoundClose then LRoundOpen := False;


      PrevTokenID := Lex.TokenID;
      PrevTokenStr := Lex.Token;

      if LPrevTokenIsMethodInterface and
         (Token.TokenID = tkSemiColon) and
         not LRoundOpen
      then
        LPrevTokenIsMethodInterface := False;

      LexNextNoJunkWithoutCompDirect(Lex);
//      Lex.NextNoJunk;
    end;
  finally
    Lex.Free;
    FMethodStack.Clear;
    FBlockStack.Clear;
    FMidBlockStack.Clear;
    ClearStackAndFreeObject(FProcStack);
    ClearStackAndFreeObject(FIfStack);
  end;
end;

procedure TWidePasStructParser.FindCurrentBlock(LineNumber, WideCharIndex:
  Integer);
var
  Token: TWidePasToken;
  CurrIndex: Integer;

  procedure _BackwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    StartInner: Boolean;
  begin
    Level := 0;
    StartInner := True;
    NestedProcs := 1;
    for I := CurrIndex - 1 downto 0 do
    begin
      Token := Tokens[I];
      if Token.IsBlockStart then
      begin
        if StartInner and (Level = 0) then
        begin
          FInnerBlockStartToken := Token;
          StartInner := False;
        end;

        if Level = 0 then
          FBlockStartToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockClose then
      begin
        Inc(Level);
      end;

      if Token.IsMethodStart then
      begin
        if Token.TokenID in [tkProcedure, tkFunction, tkConstructor, tkDestructor] then
        begin
          Dec(NestedProcs);
          if (NestedProcs = 0) and (FChildMethodStartToken = nil) then
            FChildMethodStartToken := Token;
          if Token.MethodLayer = 1 then
          begin
            FMethodStartToken := Token;
            Exit;
          end;
        end
        else if Token.TokenID in [tkBegin, tkAsm] then
        begin
          
        end;
      end
      else if Token.IsMethodClose then
        Inc(NestedProcs);

      if Token.TokenID in [tkImplementation] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _ForwardFindDeclarePos;
  var
    Level: Integer;
    I, NestedProcs: Integer;
    EndInner: Boolean;
  begin
    Level := 0;
    EndInner := True;
    NestedProcs := 1;
    for I := CurrIndex to Count - 1 do
    begin
      Token := Tokens[I];
      if Token.IsBlockClose then
      begin
        if EndInner and (Level = 0) then
        begin
          FInnerBlockCloseToken := Token;
          EndInner := False;
        end;

        if Level = 0 then
          FBlockCloseToken := Token
        else
          Dec(Level);
      end
      else if Token.IsBlockStart then
      begin
        Inc(Level);
      end;

      if Token.IsMethodClose then
      begin
        Dec(NestedProcs);
        if Token.MethodLayer = 1 then 
        begin
          FMethodCloseToken := Token;
          Exit;
        end
        else if (NestedProcs = 0) and (FChildMethodCloseToken = nil) then
          FChildMethodCloseToken := Token;
      end
      else if Token.IsMethodStart and (Token.TokenID in [tkProcedure, tkFunction,
        tkConstructor, tkDestructor]) then
      begin
        Inc(NestedProcs);
      end;

      if Token.TokenID in [tkInitialization, tkFinalization] then
      begin
        Exit;
      end;
    end;
  end;

  procedure _FindInnerBlockPos;
  var
    I, Level: Integer;
  begin
    if (FInnerBlockStartToken <> nil) and (FInnerBlockCloseToken <> nil) then
    begin
      if FInnerBlockStartToken.ItemLayer = FInnerBlockCloseToken.ItemLayer then
        Exit;
      
      if FInnerBlockStartToken.ItemLayer > FInnerBlockCloseToken.ItemLayer then
        Level := FInnerBlockCloseToken.ItemLayer
      else
        Level := FInnerBlockStartToken.ItemLayer;

      for I := CurrIndex - 1 downto 0 do
      begin
        Token := Tokens[I];
        if Token.IsBlockStart and (Token.ItemLayer = Level) then
          FInnerBlockStartToken := Token;
      end;
      for i := CurrIndex to Count - 1 do
      begin
        Token := Tokens[i];
        if Token.IsBlockClose and (Token.ItemLayer = Level) then
          FInnerBlockCloseToken := Token;
      end;
    end;
  end;

  function _GetMethodName(StartToken, CloseToken: TWidePasToken): CnWideString;
  var
    I: Integer;
  begin
    Result := '';
    if Assigned(StartToken) and Assigned(CloseToken) then
      for I := StartToken.ItemIndex + 1 to CloseToken.ItemIndex do
      begin
        Token := Tokens[I];
        if (Token.Token^ = '(') or (Token.Token^ = ':') or (Token.Token^ = ';') then
          Break;
        Result := Result + WideTrim(Token.Token);
      end;
  end;

begin
  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildMethodStartToken := nil;
  FChildMethodCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FInnerBlockCloseToken := nil;
  FInnerBlockStartToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';

  CurrIndex := 0;
  while CurrIndex < Count do
  begin
    if (Tokens[CurrIndex].LineNumber > LineNumber - 1) then
      Break;

    if Tokens[CurrIndex].LineNumber = LineNumber - 1 then
    begin
      if (Tokens[CurrIndex].TokenID in [tkBegin, tkAsm, tkTry, tkRepeat, tkIf,
        tkFor, tkWith, tkOn, tkWhile, tkCase, tkRecord, tkObject, tkClass,
        tkInterface, tkDispInterface]) and
        (Tokens[CurrIndex].CharIndex > WideCharIndex ) then 
        Break
      else if (Tokens[CurrIndex].TokenID in [tkEnd, tkUntil, tkThen, tkDo]) and
        (Tokens[CurrIndex].CharIndex + Length(Tokens[CurrIndex].Token) > WideCharIndex ) then
        Break;  
    end;

    Inc(CurrIndex);
  end;

  if (CurrIndex > 0) and (CurrIndex < Count) then
  begin
    _BackwardFindDeclarePos;
    _ForwardFindDeclarePos;

    _FindInnerBlockPos;
    if not FKeyOnly then
    begin
      FCurrentMethod := _GetMethodName(FMethodStartToken, FMethodCloseToken);
      FCurrentChildMethod := _GetMethodName(FChildMethodStartToken, FChildMethodCloseToken);
    end;
  end;
end;

function TWidePasStructParser.IndexOfToken(Token: TWidePasToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

function TWidePasStructParser.FindCurrentDeclaration(LineNumber,
  WideCharIndex: Integer): CnWideString;
var
  Idx: Integer;
begin
  Result := '';
  FindCurrentBlock(LineNumber, WideCharIndex);

  if InnerBlockStartToken <> nil then
  begin
    if InnerBlockStartToken.TokenID in [tkClass, tkInterface, tkRecord,
      tkDispInterface, tkObject] then
    begin
      Idx := IndexOfToken(InnerBlockStartToken);
      if Idx > 3 then
      begin
        if (InnerBlockStartToken.TokenID = tkRecord)
          and (Tokens[Idx - 1].TokenID = tkPacked) then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkEqual then
          Dec(Idx);
        if Tokens[Idx - 1].TokenID = tkIdentifier then
          Result := Tokens[Idx - 1].Token;
      end;
    end;
  end;
end;

procedure ParseUnitUsesW(const Source: CnWideString; UsesList: TStrings;
  SupportUnicodeIdent: Boolean);
var
  Lex: TPasWideLex;
  Flag: Integer;
  S: CnWideString;
begin
  UsesList.Clear;
  Lex := TPasWideLex.Create(SupportUnicodeIdent);

  Flag := 0;
  S := '';
  try
    Lex.Origin := PWideChar(Source);
    while Lex.TokenID <> tkNull do
    begin
      if Lex.TokenID = tkUses then
      begin
        while not (Lex.TokenID in [tkNull, tkSemiColon]) do
        begin
          Lex.Next;
          if Lex.TokenID = tkIdentifier then
          begin
            S := S + CnWideString(Lex.Token);
          end
          else if Lex.TokenID = tkPoint then
          begin
            S := S + '.';
          end
          else if Trim(S) <> '' then
          begin
            UsesList.AddObject(S, TObject(Flag));
            S := '';
          end;
        end;
      end
      else if Lex.TokenID = tkImplementation then
      begin
        Flag := 1;
      end;
      Lex.Next;
    end;
  finally
    Lex.Free;
  end;
end;

{ TWidePasToken }

procedure TWidePasToken.Clear;
begin
  FCppTokenKind := TCTokenKind(0);
  FCharIndex := 0;
  FAnsiIndex := 0;
  FEditCol := 0;
  FEditLine := 0;
  FItemIndex := 0;
  FItemLayer := 0;
  FLineNumber := 0;
  FMethodLayer := 0;
  FToken[0]:= #0;
  FTokenID := TTokenKind(0);
  FTokenPos := 0;
  FIsMethodStart := False;
  FIsMethodClose := False;
  FIsBlockStart := False;
  FIsBlockClose := False;
  FIsMethodInterface := False;
end;

function TWidePasToken.GetToken: PWideChar;
begin
  Result := @FToken[0];
end;

{ TCnIfStatement }

procedure TCnIfStatement.AddBegin(ABegin: TWidePasToken);
begin
  if ABegin = nil then
    Exit;

  if HasElse then                         
    FElseBegin := ABegin
  else if FElseIfBeginList.Count > 0 then 
    FElseIfBeginList[FElseIfBeginList.Count - 1] := ABegin
  else
    FIfBegin := ABegin;                   
end;

procedure TCnIfStatement.ChangeElseToElseIf(AIf: TWidePasToken);
begin
  if (FElseToken = nil) or (AIf = nil) then
    Exit;

  FElseList.Add(FElseToken);
  FIfList.Add(AIf);
  FElseIfBeginList.Add(nil);
  FElseIfEnded.Add(nil);
  FElseToken := nil;
end;

constructor TCnIfStatement.Create;
begin
  inherited;
  FLevel := -1;
  FElseList := TObjectList.Create(False);
  FIfList := TObjectList.Create(False);
  FElseIfBeginList := TObjectList.Create(False);
  FElseIfEnded := TList.Create;
end;

destructor TCnIfStatement.Destroy;
begin
  FElseIfEnded.Free;
  FElseIfBeginList.Free;
  FIfList.Free;
  FElseList.Free;
  inherited;
end;

procedure TCnIfStatement.EndElseBlock;
begin
  if FElseToken <> nil then
    FElseEnded := True;
end;

procedure TCnIfStatement.EndIfAll;
begin
  if FIfStart <> nil then
    FIfAllEnded := True;
end;

procedure TCnIfStatement.EndIfBlock;
begin
  if FIfStart <> nil then
    FIfEnded := True;
end;

procedure TCnIfStatement.EndLastElseIfBlock;
begin
  if ElseIfCount > 0 then
    FElseIfEnded[FElseIfEnded.Count - 1] := Pointer(Ord(True));
end;

function TCnIfStatement.GetElseIfCount: Integer;
begin
  Result := FElseList.Count;
end;

function TCnIfStatement.GetElseIfElse(Index: Integer): TWidePasToken;
begin
  Result := TWidePasToken(FElseList[Index]);
end;

function TCnIfStatement.GetElseIfIf(Index: Integer): TWidePasToken;
begin
  Result := TWidePasToken(FIfList[Index]);
end;

function TCnIfStatement.GetLastElseIfBegin: TWidePasToken;
begin
  Result := nil;
  if FElseIfBeginList.Count > 0 then
    Result := TWidePasToken(FElseIfBeginList[FElseIfBeginList.Count - 1]);
end;

function TCnIfStatement.GetLastElseIfElse: TWidePasToken;
begin
  Result := nil;
  if FElseList.Count > 0 then
    Result := TWidePasToken(FElseList[FElseList.Count - 1]);
end;

function TCnIfStatement.GetLastElseIfIf: TWidePasToken;
begin
  Result := nil;
  if FIfList.Count > 0 then
    Result := TWidePasToken(FIfList[FIfList.Count - 1]);
end;

function TCnIfStatement.HasElse: Boolean;
begin
  Result := FElseToken <> nil;
end;

procedure TCnIfStatement.SetElseBegin(const Value: TWidePasToken);
begin
  FElseBegin := Value;
end;

procedure TCnIfStatement.SetFIfBegin(const Value: TWidePasToken);
begin
  FIfBegin := Value;
end;

procedure TCnIfStatement.SetIfStart(const Value: TWidePasToken);
begin
  FIfStart := Value;
  if Value <> nil then
    FLevel := Value.ItemLayer
  else
    FLevel := -1;
end;

{ TCnProcObj }

function TCnProcObj.GetIsNested: Boolean;
begin
  Result := FNestCount > 0;
end;

function TCnProcObj.GetBeginMatched: Boolean;
begin
  Result := FBeginToken <> nil;
end;

function TCnProcObj.GetLayer: Integer;
begin
  if FBeginToken <> nil then
    Result := FBeginToken.ItemLayer
  else
    Result := -1;
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
