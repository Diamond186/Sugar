unit SelectBlockCodeU;

interface

{$I Compiler.inc}

uses
  SysUtils, Classes
  , ToolsAPI
  , CnContainers
  , WidePasParser
  , mPasLexTypes
  ;

type
  TParser = TWidePasStructParser;
  TToken = TWidePasToken;

  TPairBlock = class
    BPos: TToken;
    EPos: TToken;
  end;

  TArrayString = array of string;
  TArrayTokenID = array of mPasLexTypes.TTokenKind;

  TSelectBlockCode = class
    private
      FModuleName: string;

      FParser: TParser;
      FBeginToken,
      FEndToken: TToken;

      FAddToStack: Boolean;
      FStackSelectedCode: TCnObjectStack;

      procedure SelectBlock(const aEditBuffer: IOTAEditBuffer);
      procedure AddSelectedBlockToStack;

      function IsQuotation(aEditBlock: IOTAEditBlock): Boolean; overload;
      procedure SelectQuotationText(const aEditBuffer: IOTAEditBuffer);

      // перевірка виділений увесь коду виристання обєкту
      // result = true - виділений не увесь
      function IsFullPropObject: Boolean;
      // виділення всього коду виристання обєкту
      procedure SelectFullPropObject(const aEditBuffer: IOTAEditBuffer);

      // виділений текст знаходиться в дужках
      function IsQuotationParenthesis(const aEditBuffer: IOTAEditBuffer): Boolean;
      // Якщо зліва дужка відкривається, а справа закривається, то виділяємо дужки
      function IsFullPropInParenthesis(const aEditBuffer: IOTAEditBuffer): Boolean;
      // виділення всего тексту в дужках
      procedure SelectQuotationParenthesis(const aEditBuffer: IOTAEditBuffer);

      // видідення коду до парного End блоку begin/case/try/finnaly/except
      procedure SelectBlockToEnd(const aEditBuffer: IOTAEditBuffer);
      // виділення коду до парного begin/case/try/finnaly/except починаючи з end
      procedure SelectBlockFromEnd(const aEditBuffer: IOTAEditBuffer);
//      class function IsEndLineLeft(const aEditBuffer: IOTAEditBuffer): Boolean;

      // Виділення блоку коментарів
      procedure SelectComment(const aEditBuffer: IOTAEditBuffer);
      // Чи виділений увесь блок коментарів
      function IsAllSelectedComment(aBegin, aEnd: TToken): Boolean;

      // знаходить пару для дужки, яка закривається
      // aToken: токен дужки
      function  GetPairOpened(aToken: TToken): TToken;
      // знаходить пару для дужки, яка відкривається
      // aToken: токен дужки
      function  GetPairClosed(aToken: TToken): TToken;

      // чи виділений параметер в дужках
      function IsSelectedParameter: Boolean;
      // виділення параметру в дужках
      procedure SelectParameterInParenthesis(const aEditBuffer: IOTAEditBuffer);

      // Чи виділений увесь рядок коду
      function IsSelectAllLine: Boolean;

      // виділення всего рядка коду
      procedure SelectAllLine(const aEditBuffer: IOTAEditBuffer);

      // виділення умови циклу for
      procedure SelectingConditionFor(aBeginToken: TToken; const aEditBuffer: IOTAEditBuffer);
      // виділення умови циклу for/While/with/On
      procedure SelectingConditionDo(aEndToken: TToken; const aEditBuffer: IOTAEditBuffer);
      // виділення умови циклу If
      procedure SelectingConditionIf(aBeginToken: TToken; const aEditBuffer: IOTAEditBuffer);
      // виділення умови циклу If
      procedure SelectingConditionThen(aEndToken: TToken; const aEditBuffer: IOTAEditBuffer);
      // виділення умови циклу Case
      procedure SelectingConditionCase(aBeginToken: TToken; const aEditBuffer: IOTAEditBuffer);
      // виділення умови циклу While
      procedure SelectingConditionWhile(aBeginToken: TToken; const aEditBuffer: IOTAEditBuffer);

      // виділення умови циклу Until
      procedure SelectingConditionUntil(aBeginToken: TToken; const aEditBuffer: IOTAEditBuffer);

      // виділення блоку циклу For
      procedure SelectingBlockFor(const aEditBuffer: IOTAEditBuffer);

      // виділення блоку циклу If
      procedure SelectingBlockIf(const aEditBuffer: IOTAEditBuffer);

      // виділення блоку циклу Else
      procedure SelectingBlockElse(const aEditBuffer: IOTAEditBuffer);

      // виділення блоку циклу Case
      procedure SelectingBlockCase(const aEditBuffer: IOTAEditBuffer);
      // виділення умови циклу Case
      procedure SelectingConditionOf(aEndToken: TToken; const aEditBuffer: IOTAEditBuffer);

      // виділення блоку циклу While
      procedure SelectingBlockWhile(const aEditBuffer: IOTAEditBuffer);

      // виділення блоку циклу Repeat
      procedure SelectingBlockRepeat(const aEditBuffer: IOTAEditBuffer);

      // виділення блоку try finally/except end коли finally/except end уже виділений
      procedure SelectingBlockTry(const aEditBuffer: IOTAEditBuffer);

      procedure ClearStack;
      procedure ParseModule(const aEditBuffer: IOTAEditBuffer);
    public
      constructor Create;
      destructor Destroy; override;

      procedure SelectBlockCode(const aEditBuffer: IOTAEditBuffer);
      procedure DeSelectBlockCode(const aEditBuffer: IOTAEditBuffer);
  end;

implementation

uses
  Utils
//  , Dialogs
  //, TypInfo
  {$IFDEF TestRun}
  , TestRun
  {$ENDIF}
  ;

const
  cPrevBeginLine = [tkSemiColon, tkBegin, tkTry, tkExcept, tkFinally, tkElse, tkDo,
                    tkAsm, tkVar, tkPublic, tkPrivate, tkProtected, tkRepeat, tkThen,
                    tkPublished, tkBorComment, tkAnsiComment, tkSlashesComment];

  cNextEndLine = [tkEnd, tkElse, tkExcept, tkFinally, tkUntil, tkBorComment, tkAnsiComment, tkSlashesComment];

{ TSelectBlockCode }

procedure TSelectBlockCode.AddSelectedBlockToStack;
var
  LPair: TPairBlock;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.AddSelectedBlockToStack');
  {$ENDIF}

  if FAddToStack then
  begin
    LPair := TPairBlock.Create;
    LPair.BPos := FBeginToken;
    LPair.EPos := FEndToken;

    FStackSelectedCode.Push(LPair);
    FAddToStack := False;
  end;
//  ShowMessage('Stack: ' + FStackSelectedCode.Count.ToString);
  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.AddSelectedBlockToStack');
  {$ENDIF}
end;

procedure TSelectBlockCode.ClearStack;
var
  LPair: TPairBlock;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.ClearStack');
  {$ENDIF}

  while not FStackSelectedCode.IsEmpty do
  begin
    LPair := FStackSelectedCode.Pop as TPairBlock;
    FreeAndNil(LPair);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.ClearStack');
  {$ENDIF}
end;

constructor TSelectBlockCode.Create;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.Create');
  {$ENDIF}

  FModuleName := EmptyStr;

  FParser := TParser.Create;
  FParser.UseTabKey := True;
  FParser.TabWidth := 2;
  FBeginToken := nil;
  FEndToken := nil;

  FStackSelectedCode := TCnObjectStack.Create;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.Create');
  {$ENDIF}
end;

procedure TSelectBlockCode.ParseModule(const aEditBuffer: IOTAEditBuffer);
var
  LReader: IOTAEditReader;
  LText: WideString;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.ParseModule');
  {$ENDIF}

  FBeginToken := nil;
  FEndToken := nil;
  FParser.Clear;

  LReader := aEditBuffer.CreateReader;
  try
    LText := TUtils.GetTextFromReader(LReader);
    FParser.ParseSource(PWideChar(LText), False, False);
  finally
    LReader := nil;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.ParseModule');
  {$ENDIF}
end;

procedure TSelectBlockCode.DeSelectBlockCode(const aEditBuffer: IOTAEditBuffer);
var
  LPair: TPairBlock;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.DeSelectBlockCode');
  {$ENDIF}

  if aEditBuffer.EditBlock.Size = 0 then
    ClearStack;

  if FStackSelectedCode.Count > 0 then
  begin
    if FStackSelectedCode.Count > 1 then
      LPair := FStackSelectedCode.Pop as TPairBlock
    else
      LPair := FStackSelectedCode.Peek as TPairBlock;

    FBeginToken := LPair.BPos;
    FEndToken := LPair.EPos;

    SelectBlock(aEditBuffer);
//    ShowMessage('Stack: ' + FStackSelectedCode.Count.ToString);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.DeSelectBlockCode');
  {$ENDIF}
end;

destructor TSelectBlockCode.Destroy;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.Destroy');
  {$ENDIF}

  FreeAndNil(FParser);
  ClearStack;
  FStackSelectedCode.Free;

  inherited;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.Destroy');
  {$ENDIF}
end;

// знаходить пару для дужки, яка відкривається
function TSelectBlockCode.GetPairClosed(aToken: TToken): TToken;
var
  LCount, i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.GetPairClosed');
  {$ENDIF}

  LCount := 0;
  Result := aToken;

  for i := aToken.ItemIndex + 1 to FParser.Count - 1 do
  begin
    case aToken.TokenID of
      tkRoundOpen:
        if FParser.Tokens[i].TokenID = tkRoundOpen then Inc(LCount) else
        if FParser.Tokens[i].TokenID = tkRoundClose then Dec(LCount);

      tkSquareOpen:
        if FParser.Tokens[i].TokenID = tkSquareOpen then Inc(LCount) else
        if FParser.Tokens[i].TokenID = tkSquareClose then Dec(LCount);

      tkAngleOpen:
        if FParser.Tokens[i].TokenID = tkAngleOpen then Inc(LCount) else
        if FParser.Tokens[i].TokenID = tkAngleClose then Dec(LCount) else
        if not (FParser.Tokens[i].TokenID in [tkAngleClose, tkIdentifier]) then
        begin
          Result := nil;
          break;
        end;
    end;

    if LCount < 0 then
    begin
      Result := FParser.Tokens[i];
      Break;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.GetPairClosed');
  {$ENDIF}
//  ShowMessage('GetPairOpened: ' + GetEnumName(TypeInfo(TTokenKind), Ord(Result.TokenID)));
end;

// знаходить пару для дужки, яка закривається
// aToken: токен дужки
function TSelectBlockCode.GetPairOpened(aToken: TToken): TToken;
var
  LCount, i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.GetPairOpened');
  {$ENDIF}

  LCount := 0;
  Result := aToken;

  for i := aToken.ItemIndex - 1 downto 0 do
  begin
    case aToken.TokenID of
      tkRoundClose:
        if FParser.Tokens[i].TokenID = tkRoundClose then Inc(LCount) else
        if FParser.Tokens[i].TokenID = tkRoundOpen then Dec(LCount);

      tkAngleClose:
        if FParser.Tokens[i].TokenID = tkAngleClose then Inc(LCount) else
        if FParser.Tokens[i].TokenID = tkAngleOpen then Dec(LCount) else
        if not (FParser.Tokens[i].TokenID in [tkAngleOpen, tkIdentifier]) then
        begin
          Result := nil;
          Break;
        end;

      tkSquareClose:
        if FParser.Tokens[i].TokenID = tkSquareClose then Inc(LCount) else
        if FParser.Tokens[i].TokenID = tkSquareOpen then Dec(LCount);
    end;

    if LCount < 0 then
    begin
      Result := FParser.Tokens[i];
      Break;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.GetPairOpened');
  {$ENDIF}
//  ShowMessage('GetPairOpened: ' + GetEnumName(TypeInfo(TTokenKind), Ord(Result.TokenID)));
end;

// Чи виділений увесь блок коментарів
function TSelectBlockCode.IsAllSelectedComment(aBegin, aEnd: TToken): Boolean;
var
  LBefore, LAfter: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.GetTextFromReader');
  {$ENDIF}

  LBefore := Assigned(aBegin) and
             (aBegin.ItemIndex > 0) and
             (aBegin.TokenID <> FParser.Tokens[aBegin.ItemIndex - 1].TokenID);

  LAfter := Assigned(aEnd) and
            (aEnd.ItemIndex < FParser.Count - 1) and
            (aEnd.TokenID <> FParser.Tokens[aEnd.ItemIndex + 1].TokenID);

  Result := LBefore and LAfter;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.GetTextFromReader');
  {$ENDIF}
end;

// Якщо зліва дужка відкривається, а справа закривається, то виділяємо дужки
function TSelectBlockCode.IsFullPropInParenthesis(const aEditBuffer: IOTAEditBuffer): Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.IsFullPropInParenthesis');
  {$ENDIF}

  Result :=
    (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkRoundOpen) and
    (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkRoundClose)
    or
    (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkSquareOpen) and
    (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkSquareClose)
    or
    (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkAngleOpen) and
    (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkAngleClose);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.IsFullPropInParenthesis');
  {$ENDIF}
//  ShowMessage('IsFullPropInParenthesis: ' + BoolToStr(Result, True));
end;

// перевірка виділений увесь коду виристання обєкту
// result = true - виділений не увесь
function TSelectBlockCode.IsFullPropObject: Boolean;
const
  TLeftSetToken = [tkPoint, tkIdentifier, tkRoundClose, tkAngleClose, tkSquareClose];
  TRightSetToken = [tkPoint, {tkIdentifier,} tkRoundOpen, tkAngleOpen, tkSquareOpen];
var
  LToken: TToken;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.IsFullPropObject');
  {$ENDIF}

  if not Assigned(FEndToken) then
    FEndToken := FBeginToken;
//         dda<test>.hh;
  Result := FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID in TLeftSetToken;

  if Result and (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkAngleClose) then
  begin
    // якщо попередній котен > то це може бути порівняння або типізований обєкт
    LToken := GetPairOpened(FParser.Tokens[FBeginToken.ItemIndex - 1]);
    // якщо пари не знайдено, то це порівняння
    Result := Assigned(LToken);
  end;

  if not Result then
  begin
    Result := (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID in TRightSetToken)
              and (FEndToken.ItemIndex + 1 < FParser.Count - 1);
//              ShowMessage('Result 2: ' + BoolToStr(Result, True) + #10#13 +
//                          'Token: ' + FParser.Tokens[FEndToken.ItemIndex + 1].Token);
    if Result and (FParser.Tokens[FBeginToken.ItemIndex + 1].TokenID = tkAngleOpen) then
    begin
      LToken := GetPairClosed(FParser.Tokens[FBeginToken.ItemIndex + 1]);
      Result := Assigned(LToken);
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.IsFullPropObject');
  {$ENDIF}
//  ShowMessage('IsFullPropObject: ' + BoolToStr(Result, True));
end;

function TSelectBlockCode.IsQuotation(aEditBlock: IOTAEditBlock): Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.IsQuotation');
  {$ENDIF}

  Result := Assigned(FBeginToken) and Assigned(aEditBlock) and
            (FBeginToken.TokenID = tkString) and
            (aEditBlock.StartingColumn > FBeginToken.ColumnNumber) and
            (aEditBlock.EndingColumn < FBeginToken.ColumnNumber + FBeginToken.TokenLength);

//  ShowMessage('TokenID: ' + GetEnumName(TypeInfo(TTokenKind), Ord(FBeginToken.TokenID)) + #10#13 +
//              'StartingColumn: ' + aEditBlock.StartingColumn.ToString + ' ColumnNumber: ' + FBeginToken.ColumnNumber.ToString + #10#13 +
//              'EndingColumn: ' + aEditBlock.EndingColumn.ToString + ' EndToken: ' + (FBeginToken.ColumnNumber + FBeginToken.TokenLength).ToString);
  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.IsQuotation');
  {$ENDIF}
end;

// виділений текст знаходиться в дужках
function TSelectBlockCode.IsQuotationParenthesis(const aEditBuffer: IOTAEditBuffer): Boolean;
var
  i, LCountRound, LCountAngle, LCountSquare: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.IsQuotationParenthesis');
  {$ENDIF}

  Result := False;
  LCountRound := 0;
  LCountAngle := 0;
  LCountSquare := 0;

  for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
  begin
    case FParser.Tokens[i].TokenID of
      tkRoundOpen: Inc(LCountRound);
      tkAngleOpen: Inc(LCountAngle);
      tkSquareOpen: Inc(LCountSquare);
      tkRoundClose: Dec(LCountRound);
      tkAngleClose: Dec(LCountAngle);
      tkSquareClose: Dec(LCountSquare);
    end;

    Result := (LCountRound < 0) or (LCountAngle < 0) or (LCountSquare < 0);

//    ShowMessage('IsQuotationParenthesis: ' + BoolToStr(Result, True) + #10#13 +
//                'TokenID: ' + GetEnumName(TypeInfo(TTokenKind), Ord(FParser.Tokens[i].TokenID)));

    if Result or ((FParser.Tokens[i].TokenID in [tkEnd, tkElse, tkFinally, tkExcept]) or
       (not FParser.Tokens[i].IsMethodInterface and (FParser.Tokens[i].TokenID = tkSemiColon)))
    then
      Break;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.IsQuotationParenthesis');
  {$ENDIF}
//  ShowMessage('IsQuotationParenthesis: ' + BoolToStr(Result, True));
end;

// Чи виділений увесь рядок коду
function TSelectBlockCode.IsSelectAllLine: Boolean;
var
  LBegin, LEnd: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.IsSelectAllLine');
  {$ENDIF}

            // Початок рядка
  LBegin := (
              (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID in cPrevBeginLine)
              or
              (FBeginToken.ItemLayer <> FParser.Tokens[FBeginToken.ItemIndex - 1].ItemLayer)
              or
              ((FBeginToken.ItemLayer = FParser.Tokens[FBeginToken.ItemIndex - 1].ItemLayer)
              and (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkSemiColon))
            );
//            and

            // Кінець рядка
  LEnd := (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID in cNextEndLine)
           or (FEndToken.TokenID in [tkSemiColon, tkDo, tkThen, tkOf])
           or (FEndToken.ItemLayer <> FParser.Tokens[FEndToken.ItemIndex + 1].ItemLayer);

  Result := LBegin and LEnd;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.IsSelectAllLine');
  {$ENDIF}
//  ShowMessage('LBegin: ' + BoolToStr(LBegin, True) + #10#13 +
//              'LEnd: ' + BoolToStr(LEnd, True));
//  ShowMessage('IsSelectAllLine: ' + BoolToStr(Result, True));
end;

function TSelectBlockCode.IsSelectedParameter: Boolean;
const
  cSet = [tkAnd, tkOr, tkXor, tkMod, tkDiv, tkLower, tkLowerEqual, tkGreater, tkGreaterEqual, tkEqual];
var
  LBegin, LEnd: TTokenKind;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.IsSelectedParameter');
  {$ENDIF}

  LBegin := FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID;
  LEnd := FParser.Tokens[FEndToken.ItemIndex + 1].TokenID;

  if FBeginToken.IsMethodInterface then
    Result := (LBegin in [tkRoundOpen, tkSquareOpen, tkSemiColon]) and
              (LEnd in [tkRoundClose, tkSquareClose, tkSemiColon])
  else
    Result := (LBegin in [tkRoundOpen, tkSquareOpen, tkComma] + cSet) and
              (LEnd in [tkRoundClose, tkSquareClose, tkComma] + cSet);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.IsSelectedParameter');
  {$ENDIF}
//  ShowMessage('IsSelectedParameter. LBegin: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LBegin)) + #10#13 +
//              'LEnd : ' + GetEnumName(TypeInfo(TTokenKind), Ord(LEnd)));
end;

// виділення всего рядка коду
procedure TSelectBlockCode.SelectAllLine(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectAllLine');
  {$ENDIF}

//  ShowMessage('SelectAllLine');
  if FBeginToken.IsMethodInterface and FEndToken.IsMethodInterface then
  begin
    // пошук початку рядка
    for i := FBeginToken.ItemIndex - 1 downto 0 do
    if not FParser.Tokens[i].IsMethodInterface then
    begin
      FBeginToken := FParser.Tokens[i + 1];
      Break;
    end;

    // пошук останнього токену рядка
    for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    if not FParser.Tokens[i].IsMethodInterface then
    begin
      FEndToken := FParser.Tokens[i - 1];
      Break;
    end;
  end
  else
  begin
    // пошук початку рядка
    for i := FBeginToken.ItemIndex - 1 downto 0 do
    if (FParser.Tokens[i].ItemLayer <> FBeginToken.ItemLayer) or
       (FParser.Tokens[i].TokenID in cPrevBeginLine)
    then
    begin
      FBeginToken := FParser.Tokens[i + 1];
      Break;
    end;

    // пошук останнього токену рядка
    for i := FEndToken.ItemIndex to FParser.Count - 1 do
    if (FParser.Tokens[i].ItemLayer <> FBeginToken.ItemLayer) or
       (FParser.Tokens[i].TokenID in cNextEndLine) or
       (FParser.Tokens[i].TokenID in [tkSemiColon, tkThen, tkDo, tkOf])
    then
    begin
      FEndToken := FParser.Tokens[i];

      if not (FEndToken.TokenID in [tkSemiColon, tkThen, tkDo, tkOf]) then
        FEndToken := FParser.Tokens[i - 1];

      Break;
    end;
  end;

  SelectBlock(aEditBuffer);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectAllLine');
  {$ENDIF}
end;

procedure TSelectBlockCode.SelectBlock(const aEditBuffer: IOTAEditBuffer);
var
  LBegin, LEnd: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectBlock');
  {$ENDIF}

  LBegin := (FBeginToken.LineNumber + 1 = aEditBuffer.EditBlock.StartingRow) and
            (FBeginToken.ColumnNumber = aEditBuffer.EditBlock.StartingColumn);

  if not Assigned(FEndToken) then
    FEndToken := FBeginToken;

  LEnd := (FEndToken.LineNumber + 1 = aEditBuffer.EditBlock.EndingRow) and
          (FEndToken.ColumnNumber + FEndToken.TokenLength = aEditBuffer.EditBlock.EndingColumn);

//  ShowMessage('LBegin: ' + BoolToStr(LBegin, True) + #10#13 +
//              'LEnd: ' + BoolToStr(LEnd, True));

  if not LBegin or
     not LEnd
  then
  begin
    aEditBuffer.EditPosition.Move(FBeginToken.LineNumber + 1, FBeginToken.ColumnNumber);
    aEditBuffer.EditBlock.BeginBlock;

    aEditBuffer.EditPosition.Move(FEndToken.LineNumber + 1, FEndToken.ColumnNumber + FEndToken.TokenLength);
    aEditBuffer.EditBlock.EndBlock;

    aEditBuffer.EditBlock.Save;

    FAddToStack := True;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectBlock');
  {$ENDIF}
end;

procedure TSelectBlockCode.SelectBlockCode(const aEditBuffer: IOTAEditBuffer);
var
  EditPosition: IOTAEditPosition;
  EditBlock: IOTAEditBlock;
  BlockSize: Integer;
  IsAutoIndent: Boolean;
  i, LIndex: Integer;
  LToken: TToken;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectBlockCode');
  {$ENDIF}

  if FModuleName <> aEditBuffer.Module.FileName then
  begin
    ClearStack;
    ParseModule(aEditBuffer);
  end;

  FModuleName := aEditBuffer.Module.FileName;

  EditPosition := aEditBuffer.EditPosition;
  EditBlock := aEditBuffer.EditBlock;
  //Save the current edit block and edit position
  EditBlock.Save;
  EditPosition.Save;

  // Length of the selected block (0 means no block)
  BlockSize := EditBlock.Size;
  // Store AutoIndent property
  IsAutoIndent := aEditBuffer.BufferOptions.AutoIndent;
  // Turn off AutoIndent, if necessary
  if IsAutoIndent then
    aEditBuffer.BufferOptions.AutoIndent := False;

  try
    // If no block is selected, or the selected block is a single line,
    // then duplicate just the current line
    if BlockSize = 0 then
    begin
      ParseModule(aEditBuffer);
      ClearStack;

      EditPosition.MoveCursor(mmSkipLeft or mmSkipWord);
      EditBlock.BeginBlock;
      EditPosition.MoveCursor(mmSkipRight or mmSkipWord);
      EditBlock.EndBlock;
      EditBlock.Save;

      for i := 0 to FParser.Count - 1 do
      begin
        LToken := FParser.Tokens[i];

        if (LToken.LineNumber + 1 = EditBlock.EndingRow) then
        begin
          if   (LToken.ColumnNumber <= EditBlock.StartingColumn) and
             ((LToken.TokenLength + LToken.ColumnNumber) > EditBlock.StartingColumn)
          then
          begin
            FBeginToken := LToken;

//              ShowMessage(FBeginToken.Token);
            Break;
          end;
        end;
      end;
    end
    else
    begin
      if not Assigned(FBeginToken) then Exit;

      // Додаємо поточний виділений блок до стеку
      AddSelectedBlockToStack;

//              aEditBuffer.TopView.ConvertPos(True, LSPos, LPos);
//                ShowMessage('LSPos.Col: ' + LSPos.Col.ToString + ' LSPos.Line:' + LSPos.Line.ToString + #10#13 +
//                            'LPos.CharIndex: ' + LPos.CharIndex.ToString + ' LPos.Line:' + LPos.Line.ToString);

//      ShowMessage(FStackSelectedCode.Count.ToString);

      // TSelectBlockCode.IsQuotation[EditPosition.Read(0)]
      if (FBeginToken.TokenID in [tkAnsiComment, tkBorComment, tkCompDirect, tkSlashesComment])
        and not IsAllSelectedComment(FBeginToken, FEndToken)
      then
      begin
        if (FBeginToken.TokenID in [tkAnsiComment, tkBorComment])
        then
          SelectComment(aEditBuffer)
        else
        if FBeginToken.TokenID in [tkCompDirect, tkSlashesComment] then
        begin
//          ShowMessage('Start: ' + (FBeginToken.ColumnNumber = aEditBuffer.EditBlock.StartingColumn).ToString + #10#13 +
//                     'End: ' + (FBeginToken.ColumnNumber + FBeginToken.TokenLength = aEditBuffer.EditBlock.EndingColumn).ToString);

          if (FBeginToken.ColumnNumber = aEditBuffer.EditBlock.StartingColumn)
            and (FBeginToken.ColumnNumber + FBeginToken.TokenLength = aEditBuffer.EditBlock.EndingColumn)
          then
            SelectComment(aEditBuffer)
          else
            SelectBlock(aEditBuffer);
        end;
      end
      else
      // виділяе блок коду між begin/case/try/finally/except та end включно
      if not Assigned(FEndToken) and
         ((FBeginToken.TokenID = tkBegin) or
//         (FBeginToken.TokenID = tkCase) or
         (FBeginToken.TokenID = tkTry) or
         (FBeginToken.TokenID = tkFinally) or
         (FBeginToken.TokenID = tkExcept) or
         (FBeginToken.TokenID = tkAsm))
      then
        SelectBlockToEnd(aEditBuffer)
      else
      if FBeginToken.TokenID = tkEnd then
        // виділення коду до парного begin/case/try/finnaly/except починаючи з end
        SelectBlockFromEnd(aEditBuffer)
      else
      if (FBeginToken.TokenID in [tkExcept, tkFinally])
        and ((FEndToken.TokenID = tkEnd)
        or (FParser.Tokens[FEndToken.ItemIndex - 1].TokenID = tkEnd))
      then
        SelectingBlockTry(aEditBuffer)
      else
      if (FBeginToken.TokenID = tkThen)
        and ((FEndToken = nil) or (FEndToken.TokenID = tkThen))
      then
        SelectingConditionThen(FBeginToken, aEditBuffer)
      else
      if (FBeginToken.TokenID = tkOf)
        and ((FEndToken = nil) or (FEndToken.TokenID = tkOf))
      then
        SelectingConditionOf(FBeginToken, aEditBuffer)
      else
      if (FBeginToken.TokenID = tkDo)
        and ((FEndToken = nil) or (FEndToken.TokenID = tkDo))
      then
        SelectingConditionDo(FBeginToken, aEditBuffer)
      else
//      if FBeginToken.IsMethodInterface
//        and not IsQuotation(aEditBuffer.EditBlock)
//        and (FBeginToken.TokenID <> tkIdentifier)
//      then
//        SelectingMethodInterface(aEditBuffer)
//      else
      // check a text in quotation marks
      if IsQuotation(aEditBuffer.EditBlock) then SelectQuotationText(aEditBuffer) else
      // check a selected text is all object
      if IsFullPropObject then SelectFullPropObject(aEditBuffer) else
      // check a selected text is all parenthesis
      if IsQuotationParenthesis(aEditBuffer)
         and not IsFullPropInParenthesis(aEditBuffer) then
      begin
//        ShowMessage('1');
        // check a text in parenthesis
        if IsQuotationParenthesis(aEditBuffer) then
          // перевіряється чи увесь виділений поточний параметер в дужках інтерфейсу методу
          if not IsSelectedParameter
          then
          begin
//            ShowMessage('1');
            // виділення параметру в дужках
            SelectParameterInParenthesis(aEditBuffer);
          end
          else
          begin
//            Select all text in Parenthesis
            SelectQuotationParenthesis(aEditBuffer);
          end;
      end
      else
      if IsFullPropInParenthesis(aEditBuffer)
      then
      begin
//        ShowMessage('SelectParenthesis');
        FBeginToken := FParser.Tokens[FBeginToken.ItemIndex - 1];
        FEndToken := FParser.Tokens[FEndToken.ItemIndex + 1];
        SelectBlock(aEditBuffer);
      end
      else
      if not IsSelectAllLine
        or (((FBeginToken.TokenID in [tkFor, tkWith, tkOn, tkWhile]) and (FEndToken.TokenID = tkDo)) or
            ((FBeginToken.TokenID = tkIf) and (FEndToken.TokenID = tkThen)) or
            ((FBeginToken.TokenID = tkCase) and (FEndToken.TokenID = tkOf)) or
            ((FBeginToken.TokenID = tkUntil) and (FEndToken.TokenID in [tkSemiColon, tkIdentifier])) or
            ((FBeginToken.TokenID = tkIf) and (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkElse)))
      then
      begin
        for i := FBeginToken.ItemIndex downto 0 do
        if FParser.Tokens[i].TokenID in [tkSemiColon, tkBegin, tkOf, tkDo, tkThen, tkElse] then
        begin
          SelectAllLine(aEditBuffer);
          Break;
        end
        else
        case FParser.Tokens[i].TokenID of
          tkFor, tkWith, tkOn:
            begin
              if (FEndToken.TokenID = tkDo)
                and (FBeginToken.TokenID in [tkFor, tkWith, tkOn])
              then
                SelectingBlockFor(aEditBuffer)
              else
                SelectingConditionFor(FParser.Tokens[i], aEditBuffer);

              Break;
            end;

          tkIf:
            begin
              if (FBeginToken.TokenID = tkIf)
                and (FEndToken.TokenID = tkThen)
              then
                SelectingBlockIf(aEditBuffer)
              else
              if (FBeginToken.TokenID = tkIf)
                and (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkElse)
              then
                SelectingBlockElse(aEditBuffer)
              else
                SelectingConditionIf(FParser.Tokens[i], aEditBuffer);

              Break;
            end;

          tkCase:
            begin
              if (FBeginToken.TokenID = tkCase)
                and (FEndToken.TokenID = tkOf)
              then
                SelectingBlockCase(aEditBuffer)
              else
                SelectingConditionCase(FParser.Tokens[i], aEditBuffer);

              Break;
            end;

          tkWhile:
            begin
              if (FBeginToken.TokenID = tkWhile)
                and (FEndToken.TokenID = tkDo)
              then
                SelectingBlockWhile(aEditBuffer)
              else
                SelectingConditionWhile(FParser.Tokens[i], aEditBuffer);

              Break;
            end;

          tkUntil:
            begin
              if (FBeginToken.TokenID = tkUntil)
                and (FEndToken.TokenID in [tkIdentifier, tkSemiColon])
              then
                SelectingBlockRepeat(aEditBuffer)
              else
                SelectingConditionUntil(FParser.Tokens[i], aEditBuffer);

              Break;
            end;
        end;
      end
      else
      begin
//        ShowMessage('FindCurrentBlock ColumnNumber: ' + FBeginToken.ColumnNumber.ToString + #10#13 +
//                    'LineNumber: ' + FBeginToken.LineNumber.ToString);
        FParser.FindCurrentBlock(FBeginToken.LineNumber + 1, FBeginToken.ColumnNumber + 1);

        if Assigned(FParser.InnerBlockStartToken) then
        begin
          if FParser.Tokens[FParser.InnerBlockCloseToken.ItemIndex + 1].TokenID = tkSemiColon
          then
            LIndex := FParser.InnerBlockCloseToken.ItemIndex + 1
          else
            LIndex := FParser.InnerBlockCloseToken.ItemIndex;

          if (FParser.InnerBlockStartToken.ItemIndex <> FBeginToken.ItemIndex) or
             (LIndex <> FEndToken.ItemIndex)
          then
          begin
            if FBeginToken.ItemIndex > FParser.InnerBlockStartToken.ItemIndex then
              FBeginToken := FParser.InnerBlockStartToken;

            if FEndToken.ItemIndex < FParser.InnerBlockCloseToken.ItemIndex then
              FEndToken := FParser.InnerBlockCloseToken;

            if FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkSemiColon then
              FEndToken := FParser.Tokens[FEndToken.ItemIndex + 1];

            SelectBlock(aEditBuffer);
            Exit;
          end;
        end;

        if Assigned(FParser.MethodStartToken) then
        begin
          if FParser.Tokens[FParser.MethodCloseToken.ItemIndex + 1].TokenID = tkSemiColon
          then
            LIndex := FParser.MethodCloseToken.ItemIndex + 1
          else
            LIndex := FParser.MethodCloseToken.ItemIndex;

          if (FParser.MethodStartToken.ItemIndex <> FBeginToken.ItemIndex) or
             (LIndex <> FEndToken.ItemIndex)
          then
          begin
            FBeginToken := FParser.MethodStartToken;
            FEndToken := FParser.Tokens[LIndex];

            if (FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkClass) and
               FParser.Tokens[FBeginToken.ItemIndex - 1].IsMethodInterface
            then
              FBeginToken := FParser.Tokens[FBeginToken.ItemIndex - 1];

            SelectBlock(aEditBuffer);
          end;
        end;
      end;

//      ShowMessage('IsSpecialCharacter sd : ' +
//                  BoolToStr(EditPosition.IsSpecialCharacter, True));
  //      CP := EditBuffer.EditViews[0].CursorPos;
  //      CP.Col := EditBlock.StartingColumn;

  //      EditBlock.BeginBlock;
  //      if EditPosition.IsWordCharacter then
  //        EditPosition.MoveCursor(mmSkipLeft or mmSkipWord);
  //    if EditPosition.IsWhiteSpace then
  //      EditPosition.MoveCursor(mmSkipRight or mmSkipWhite);
  //
  //      OutputMessage(EditPosition.IsWordCharacter.ToString);
  //      OutputMessage(EditPosition.IsWhiteSpace.ToString);
  //      OutputMessage(EditPosition.IsWordCharacter.ToString);
  //      EditPosition.MoveCursor(mmSkipRight or mmSkipWord {or mmSkipNonWhite or mmSkipSpecial});
  //    EditBlock.EndBlock;
  //    EditBlock.Save;
    end;
  finally
    //EditPosition.Restore;
    // Restore AutoIndent, if necessary
    if IsAutoIndent then
      aEditBuffer.BufferOptions.AutoIndent := True;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectBlockCode');
  {$ENDIF}
end;

// виділення коду до парного begin/case/try/finnaly/except починаючи з end
procedure TSelectBlockCode.SelectBlockFromEnd(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectBlockFromEnd');
  {$ENDIF}

//  ShowMessage('SelectLeftTextToBlank');
  for i := FBeginToken.ItemIndex downto 0 do
  begin
    if (FParser.Tokens[i].TokenID in [tkAsm, tkBegin, tkCase, tkExcept, tkFinally])
      and (FBeginToken.ItemLayer = FParser.Tokens[i].ItemLayer)
    then
    begin
      FEndToken := FBeginToken;
      FBeginToken := FParser.Tokens[i];

      if FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkSemiColon then
        FEndToken := FParser.Tokens[FEndToken.ItemIndex + 1];
      
      SelectBlock(aEditBuffer);
      Break;
    end
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectBlockFromEnd');
  {$ENDIF}
end;

procedure TSelectBlockCode.SelectBlockToEnd(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectBlockToEnd');
  {$ENDIF}

//  ShowMessage('SelectLeftTextToBlank');
  for i := FBeginToken.ItemIndex to FParser.Count - 1 do
  begin
    if (FParser.Tokens[i].TokenID = tkEnd)
      and (FParser.Tokens[i].ItemLayer = FBeginToken.ItemLayer)
    then
    begin
      if FParser.Tokens[i + 1].TokenID = tkSemiColon then
        FEndToken := FParser.Tokens[i + 1]
      else
        FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectBlockToEnd');
  {$ENDIF}
end;

// Виділення блоку коментарів
procedure TSelectBlockCode.SelectComment(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectComment');
  {$ENDIF}

  // Begin block
  for i := FBeginToken.ItemIndex - 1 downto 0 do
  if FBeginToken.TokenID = FParser.Tokens[i].TokenID then
    FBeginToken := FParser.Tokens[i]
  else
  begin
    FBeginToken := FParser.Tokens[i + 1];
    Break;
  end;

  // End block
  for i := FBeginToken.ItemIndex + 1 to FParser.Count - 1 do
  if FBeginToken.TokenID = FParser.Tokens[i].TokenID then
    FEndToken := FParser.Tokens[i]
  else
  begin
    FEndToken := FParser.Tokens[i - 1];
    Break;
  end;

  SelectBlock(aEditBuffer);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectComment');
  {$ENDIF}
end;

// виділення всього коду виристання обєкту
procedure TSelectBlockCode.SelectFullPropObject(const aEditBuffer: IOTAEditBuffer);
const
  cSetClose = [tkRoundClose, tkAngleClose, tkSquareClose];
  cSetOpen = [tkRoundOpen, tkAngleOpen, tkSquareOpen];
var
  i, LFromIndex: Integer;
  LToken: TToken;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectFullPropObject');
  {$ENDIF}

//  ShowMessage('SelectFullPropObject');
//  LToken := nil;

  try
    // Begin block
    if //(FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID in cSetClose) or
       ((FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkPoint) and
       (FParser.Tokens[FBeginToken.ItemIndex - 2].TokenID in cSetClose))
    then
    begin
//      if FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID in cSetClose then
//        LToken := GetPairOpened(FParser.Tokens[FBeginToken.ItemIndex - 1])
//      else
        LToken := GetPairOpened(FParser.Tokens[FBeginToken.ItemIndex - 2]);

      if FParser.Tokens[FBeginToken.ItemIndex - 1].TokenID = tkIdentifier then
        FBeginToken := FParser.Tokens[FBeginToken.ItemIndex - 1];
//      ShowMessage('1');

      if Assigned(LToken) then
        FBeginToken := LToken;
    end;

    LFromIndex := FBeginToken.ItemIndex - 1;
    while FParser.Tokens[LFromIndex].TokenID in [tkIdentifier, tkPoint, tkRoundClose, tkAngleClose, tkSquareClose] do
    begin
      if FParser.Tokens[LFromIndex].TokenID = tkPoint then
      begin
        Dec(LFromIndex);
      end
      else
      if FParser.Tokens[LFromIndex].TokenID in cSetClose then
      begin
        LToken := GetPairOpened(FParser.Tokens[LFromIndex]);

        if Assigned(LToken) then
        begin
          FBeginToken := LToken;
          LFromIndex := FBeginToken.ItemIndex - 1;
        end
        else
        begin
          FBeginToken := FParser.Tokens[LFromIndex + 1];
          Break;
        end;
//          ShowMessage('2');
      end
      else
      if FParser.Tokens[LFromIndex].TokenID = tkIdentifier then
      begin
        FBeginToken := FParser.Tokens[LFromIndex];
        Dec(LFromIndex);
  //        ShowMessage('3');
      end
      else
        Break;
    end;

    // таким чином виділення йде спочатку лівої частини
//    if LBefore <> FBeginToken then
//      Exit;
//    ShowMessage('FEndToken: ' + FEndToken.Token);
    // End block
    if FParser.Tokens[FEndToken.ItemIndex + 1].TokenID in cSetOpen then
    begin
      LToken := GetPairClosed(FParser.Tokens[FEndToken.ItemIndex + 1]);

      if Assigned(LToken) then
        FEndToken := LToken;
//      ShowMessage('4');
    end
    else
    begin
//      ShowMessage((FEndToken.ItemIndex + 2).ToString + #10#13 +
//                  FParser.Count.ToString + #10#13 +
//                  FParser.Tokens[FParser.Count - 1].Token
//                  );

      if (FEndToken.ItemIndex + 2 >= FParser.Count - 1) and
         (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkPoint) and
         (FParser.Tokens[FEndToken.ItemIndex + 2].TokenID in cSetOpen)
      then
      begin
        LToken := GetPairClosed(FParser.Tokens[FEndToken.ItemIndex + 2]);

        if Assigned(LToken) then
          FEndToken := LToken;
  //      ShowMessage('5');
      end;
    end;

    for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    begin
//      ShowMessage(FParser.Tokens[i].Token);

      if FParser.Tokens[i].TokenID = tkPoint then Continue else
      if FParser.Tokens[i].TokenID in cSetOpen then
      begin
        // перед крапкою
        FEndToken := FParser.Tokens[i - 1];
//        ShowMessage('6');
        Break;
      end
      else
      if FParser.Tokens[i].TokenID in cSetOpen then
      begin
        FEndToken := FParser.Tokens[i - 1];
//        ShowMessage('7');
      end
      else
      if FParser.Tokens[i].TokenID = tkIdentifier then
      begin
        FEndToken := FParser.Tokens[i];
//        ShowMessage('8');
      end
      else
        Break;
    end;
  finally
    SelectBlock(aEditBuffer);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectFullPropObject');
  {$ENDIF}
end;

// виділення блоку циклу Case
procedure TSelectBlockCode.SelectingBlockCase(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockCase');
  {$ENDIF}

  if Assigned(FEndToken) and (FEndToken.TokenID = tkOf)
     and Assigned(FBeginToken) and (FBeginToken.TokenID = tkCase)
  then
  for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    if (FEndToken.ItemLayer - 1 = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID = tkSemiColon)
    then
    begin
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockCase');
  {$ENDIF}
end;

// виділення блоку циклу Else
procedure TSelectBlockCode.SelectingBlockElse(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
  LElse: TToken;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockElse');
  {$ENDIF}

//  ShowMessage('SelectingBlockElse');
  if Assigned(FEndToken) and (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkElse)
     and Assigned(FBeginToken) and (FBeginToken.TokenID = tkIf)
  then
  begin
    LElse := FParser.Tokens[FEndToken.ItemIndex + 1];

    for i := LElse.ItemIndex + 1 to FParser.Count - 1 do
    if ((LElse.ItemLayer - 1 = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID = tkSemiColon))
       or
       ((LElse.ItemLayer = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID in [tkEnd, tkElse]))
    then
    begin
      FEndToken := FParser.Tokens[i];

      if FEndToken.TokenID = tkElse then
        FEndToken := FParser.Tokens[i - 1]
      else
      if (FEndToken.TokenID = tkEnd)
        and (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkSemiColon)
      then
        FEndToken := FParser.Tokens[FEndToken.ItemIndex + 1];

      SelectBlock(aEditBuffer);
      Break;
    end;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockElse');
  {$ENDIF}
end;

// виділення умови циклу for
procedure TSelectBlockCode.SelectingBlockFor(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockFor');
  {$ENDIF}

  if Assigned(FEndToken) and (FEndToken.TokenID = tkDo)
     and Assigned(FBeginToken) and (FBeginToken.TokenID = tkFor)
  then
  for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    if (FEndToken.ItemLayer - 1 = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID = tkSemiColon)
    then
    begin
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockFor');
  {$ENDIF}
end;

// виділення блоку циклу If
procedure TSelectBlockCode.SelectingBlockIf(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockIf');
  {$ENDIF}

//  ShowMessage('SelectingBlockIf');
  if Assigned(FEndToken) and (FEndToken.TokenID = tkThen)
     and Assigned(FBeginToken) and (FBeginToken.TokenID = tkIf)
  then
  for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    if ((FEndToken.ItemLayer - 1 = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID = tkSemiColon))
       or
       ((FEndToken.ItemLayer = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID in [tkEnd, tkElse]))
    then
    begin
      FEndToken := FParser.Tokens[i];

      if FEndToken.TokenID = tkElse then
        FEndToken := FParser.Tokens[i - 1]
      else
      if (FEndToken.TokenID = tkEnd)
        and (FParser.Tokens[FEndToken.ItemIndex + 1].TokenID = tkSemiColon)
      then
        FEndToken := FParser.Tokens[FEndToken.ItemIndex + 1];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockIf');
  {$ENDIF}
end;

// виділення блоку циклу Repeat
procedure TSelectBlockCode.SelectingBlockRepeat(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockRepeat');
  {$ENDIF}

//  ShowMessage('SelectingBlockRepeat');
  if Assigned(FEndToken) and (FEndToken.TokenID in [tkSemiColon, tkIdentifier])
     and Assigned(FBeginToken) and (FBeginToken.TokenID = tkUntil)
  then
  for i := FBeginToken.ItemIndex - 1 downto 0 do
    if (FBeginToken.ItemLayer = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID = tkRepeat)
    then
    begin
      FBeginToken := FParser.Tokens[i];
      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockRepeat');
  {$ENDIF}
end;

procedure TSelectBlockCode.SelectingBlockTry(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockTry');
  {$ENDIF}

  if (FBeginToken.TokenID in [tkExcept, tkFinally])
    and ((FEndToken.TokenID = tkEnd)
    or (FParser.Tokens[FEndToken.ItemIndex - 1].TokenID = tkEnd))
  then
  for i := FBeginToken.ItemIndex - 1 downto 0 do
    if (FParser.Tokens[i].TokenID = tkTry)
      and (FParser.Tokens[i].ItemLayer = FBeginToken.ItemLayer)
    then
    begin
      FBeginToken := FParser.Tokens[i];
      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockTry');
  {$ENDIF}
end;

// виділення блоку циклу While
procedure TSelectBlockCode.SelectingBlockWhile(const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingBlockWhile');
  {$ENDIF}

  if Assigned(FEndToken) and (FEndToken.TokenID = tkDo)
     and Assigned(FBeginToken) and (FBeginToken.TokenID = tkWhile)
  then
  for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    if (FEndToken.ItemLayer - 1 = FParser.Tokens[i].ItemLayer)
       and (FParser.Tokens[i].TokenID = tkSemiColon)
    then
    begin
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingBlockWhile');
  {$ENDIF}
end;

// виділення умови циклу Case
procedure TSelectBlockCode.SelectingConditionCase(aBeginToken: TToken;
                                                  const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionCase');
  {$ENDIF}

//  ShowMessage('SelectingСonditionCase');
  if Assigned(aBeginToken) and (aBeginToken.TokenID = tkCase) then
  for i := aBeginToken.ItemIndex + 1 to FParser.Count - 1 do
    if FParser.Tokens[i].TokenID = tkOf then
    begin
      FBeginToken := aBeginToken;
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionCase');
  {$ENDIF}
end;

// виділення умови циклу for/While/with/On
procedure TSelectBlockCode.SelectingConditionDo(aEndToken: TToken;
                                                const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionDo');
  {$ENDIF}

//  ShowMessage('SelectingСonditionFor');
  if Assigned(aEndToken) and (aEndToken.TokenID = tkDo) then
  for i := aEndToken.ItemIndex - 1 downto 0 do
    if FParser.Tokens[i].TokenID in [tkFor, tkWith, tkOn, tkWhile] then
    begin
      FBeginToken := FParser.Tokens[i];
      FEndToken := aEndToken;

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionDo');
  {$ENDIF}
end;

procedure TSelectBlockCode.SelectingConditionFor(aBeginToken: TToken; const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionFor');
  {$ENDIF}

//  ShowMessage('SelectingСonditionFor');
  if Assigned(aBeginToken) and (aBeginToken.TokenID = tkFor) then
  for i := aBeginToken.ItemIndex + 1 to FParser.Count - 1 do
    if FParser.Tokens[i].TokenID = tkDo then
    begin
      FBeginToken := aBeginToken;
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionFor');
  {$ENDIF}
end;

// виділення умови циклу If
procedure TSelectBlockCode.SelectingConditionIf(aBeginToken: TToken;
                                                const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionIf');
  {$ENDIF}

//  ShowMessage('SelectingСonditionIf');
  if Assigned(aBeginToken) and (aBeginToken.TokenID = tkIf) then
  for i := aBeginToken.ItemIndex + 1 to FParser.Count - 1 do
    if FParser.Tokens[i].TokenID = tkThen then
    begin
      FBeginToken := aBeginToken;
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionIf');
  {$ENDIF}
end;

// виділення блоку циклу Case
procedure TSelectBlockCode.SelectingConditionOf(aEndToken: TToken; const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionOf');
  {$ENDIF}

  //  ShowMessage('SelectingСonditionCase');
  if Assigned(aEndToken) and (aEndToken.TokenID = tkOf) then
  for i := aEndToken.ItemIndex - 1 downto 0 do
    if FParser.Tokens[i].TokenID = tkCase then
    begin
      FBeginToken := FParser.Tokens[i];
      FEndToken := aEndToken;

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionOf');
  {$ENDIF}
end;

// виділення умови циклу If
procedure TSelectBlockCode.SelectingConditionThen(aEndToken: TToken;
                                                  const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionThen');
  {$ENDIF}

//  ShowMessage('SelectingСonditionIf');
  if Assigned(aEndToken) and (aEndToken.TokenID = tkThen) then
  for i := aEndToken.ItemIndex - 1 downto 0 do
    if FParser.Tokens[i].TokenID = tkIf then
    begin
      FBeginToken := FParser.Tokens[i];
      FEndToken := aEndToken;

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionThen');
  {$ENDIF}
end;

// виділення умови циклу Until
procedure TSelectBlockCode.SelectingConditionUntil(aBeginToken: TToken;
                                                    const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionUntil');
  {$ENDIF}

//  ShowMessage('SelectingСonditionUntil');
  if Assigned(aBeginToken) and (aBeginToken.TokenID = tkUntil) then
  for i := aBeginToken.ItemIndex + 1 to FParser.Count - 1 do
    if FParser.Tokens[i].TokenID in [tkSemiColon, tkEnd, tkElse] then
    begin
      FBeginToken := aBeginToken;

      if FParser.Tokens[i].TokenID in [tkEnd, tkElse] then
        FEndToken := FParser.Tokens[i - 1]
      else
        FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionUntil');
  {$ENDIF}
end;

// виділення умови циклу While
procedure TSelectBlockCode.SelectingConditionWhile(aBeginToken: TToken;
                                                   const aEditBuffer: IOTAEditBuffer);
var
  i: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectingConditionWhile');
  {$ENDIF}

//  ShowMessage('SelectingСonditionWhile');
  if Assigned(aBeginToken) and (aBeginToken.TokenID = tkWhile) then
  for i := aBeginToken.ItemIndex + 1 to FParser.Count - 1 do
    if FParser.Tokens[i].TokenID = tkDo then
    begin
      FBeginToken := aBeginToken;
      FEndToken := FParser.Tokens[i];

      SelectBlock(aEditBuffer);
      Break;
    end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectingConditionWhile');
  {$ENDIF}
end;

// виділення параметру в дужках
procedure TSelectBlockCode.SelectParameterInParenthesis(const aEditBuffer: IOTAEditBuffer);
const
  cLeftOpen = [tkSemiColon, tkRoundOpen];
  cRightOpen = [tkSemiColon, tkRoundClose];
var
  i: Integer;
  LRoundCount, LSquareCount: Integer;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectParameterInParenthesis');
  {$ENDIF}

//  ShowMessage('SelectParameterInParenthesis');
  try
    LRoundCount := 0;
    LSquareCount := 0;

    // пошук дужки, яка відкривається або символу ;
    for i := FBeginToken.ItemIndex - 1 downto 0 do
    begin
      if ((FParser.Tokens[i].IsMethodInterface and (FParser.Tokens[i].TokenID in [tkSemiColon, tkRoundOpen])) or
         (not FParser.Tokens[i].IsMethodInterface and (FParser.Tokens[i].TokenID in [tkComma, tkRoundOpen, tkSquareOpen])))
         and (LRoundCount = 0)
         and (LSquareCount = 0)
      then
      begin
        FBeginToken := FParser.Tokens[i + 1];
        Break;
      end;

      if FParser.Tokens[i].TokenID = tkRoundOpen then LRoundCount := LRoundCount + 1 else
      if FParser.Tokens[i].TokenID = tkRoundClose then LRoundCount := LRoundCount - 1 else
      if FParser.Tokens[i].TokenID = tkSquareOpen then LSquareCount := LSquareCount + 1 else
      if FParser.Tokens[i].TokenID = tkSquareClose then LSquareCount := LSquareCount - 1;
//       ShowMessage('Token: ' + FParser.Tokens[i].Token);
    end;

    LRoundCount := 0;
    LSquareCount := 0;
    // пошук дужки, яка закриваються або символу ;
    for i := FEndToken.ItemIndex + 1 to FParser.Count - 1 do
    begin
      if ((FParser.Tokens[i].IsMethodInterface and (FParser.Tokens[i].TokenID in [tkSemiColon, tkRoundClose])) or
         (not FParser.Tokens[i].IsMethodInterface and (FParser.Tokens[i].TokenID in [tkComma, tkRoundClose, tkSquareClose])))
         and (LRoundCount = 0)
         and (LSquareCount = 0)
      then
      begin
        FEndToken := FParser.Tokens[i - 1];
        Break;
      end;

      if FParser.Tokens[i].TokenID = tkRoundOpen then LRoundCount := LRoundCount + 1 else
      if FParser.Tokens[i].TokenID = tkRoundClose then LRoundCount := LRoundCount - 1 else
      if FParser.Tokens[i].TokenID = tkSquareOpen then LSquareCount := LSquareCount + 1 else
      if FParser.Tokens[i].TokenID = tkSquareClose then LSquareCount := LSquareCount - 1;
//        ShowMessage('Token: ' + FParser.Tokens[i].Token);
    end;
  finally
    SelectBlock(aEditBuffer);
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectParameterInParenthesis');
  {$ENDIF}
end;

// виділення всего тексту в дужках
procedure TSelectBlockCode.SelectQuotationParenthesis(const aEditBuffer: IOTAEditBuffer);
const
  cLeftOpen = [tkRoundOpen, tkAngleOpen, tkSquareOpen];
  cRightClose = [tkRoundClose, tkAngleClose, tkSquareClose];
var
  LBegin, LEnd: TTokenKind;
  LIndex, Index: Integer;
  LToken: TToken;
  LRes: Boolean;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectQuotationParenthesis');
  {$ENDIF}

  LIndex := 0;
//   ShowMessage('SelectQuotationParenthesis');
  // знаходимо першу дужку
  repeat
    Inc(LIndex);

    LBegin := FParser.Tokens[FBeginToken.ItemIndex - LIndex].TokenID;
    LEnd := FParser.Tokens[FEndToken.ItemIndex + LIndex].TokenID;

//    LToken := nil;
    if LBegin in cLeftOpen then
    begin
      // знаходимо пару знайденій першій дужці
      FBeginToken := FParser.Tokens[FBeginToken.ItemIndex - LIndex + 1];
      LToken := GetPairClosed(FParser.Tokens[FBeginToken.ItemIndex - 1]);

      if Assigned(LToken) then
      begin
        Index := LToken.ItemIndex;
        FEndToken := FParser.Tokens[Index - 1];
        LEnd := FParser.Tokens[Index].TokenID;
      end;
    end
    else
    if LEnd in cRightClose then
    begin
      FEndToken := FParser.Tokens[FEndToken.ItemIndex + LIndex - 1];
      LToken := GetPairOpened(FParser.Tokens[FEndToken.ItemIndex + 1]);

      if Assigned(LToken) then
      begin
        Index := LToken.ItemIndex;
        FBeginToken := FParser.Tokens[Index + 1];
        LBegin := FParser.Tokens[Index].TokenID;
      end;
    end;

//    ShowMessage('FBeginToken: ' + FBeginToken.Token + #10#13 +
//                'FEndToken: ' + FEndToken.Token);

    // перевірка знайденої пари
    LRes := (LBegin = tkRoundOpen) and (LEnd = tkRoundClose) or
            (LBegin = tkAngleOpen) and (LEnd = tkAngleClose) or
            (LBegin = tkSquareOpen) and (LEnd = tkSquareClose);

  until LRes or (FEndToken.ItemIndex + LIndex = FParser.Count - 1);

//     ShowMessage('Begin: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LBegin)) + #10#13 +
//                 'End: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LEnd)));


//       ShowMessage('Begin: ' + FBeginToken.Token + #10#13 + 'End: ' + FEndToken.Token);
  SelectBlock(aEditBuffer);

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectQuotationParenthesis');
  {$ENDIF}
//  ShowMessage('Line: ' + LBeginPos.Line.ToString + ' Col: ' + LBeginPos.Col.ToString);
end;

procedure TSelectBlockCode.SelectQuotationText(const aEditBuffer: IOTAEditBuffer);
var
  LBegin, LEnd: Integer;
  LEditBlock: IOTAEditBlock;
  LEditPosition: IOTAEditPosition;
begin
  {$IFDEF TestRun}
  TTestRun.AddMarker('begin TSelectBlockCode.SelectQuotationText');
  {$ENDIF}

//  ShowMessage('SelectQuotationText');
//  'test test test';
  if Assigned(FBeginToken) then
  begin
    LEditBlock := aEditBuffer.EditBlock;
    LEditPosition := aEditBuffer.EditPosition;

    if FBeginToken.ColumnNumber + 1 < LEditBlock.StartingColumn then
    begin
      LBegin := FBeginToken.ColumnNumber + 1;
      LEnd := LBegin + FBeginToken.TokenLength - 2;
    end
    else
    begin
      LBegin := FBeginToken.ColumnNumber;
      LEnd := LBegin + FBeginToken.TokenLength;
    end;

    // BeginBlock
    LEditPosition.Move(LEditPosition.Row, LBegin);
    LEditBlock.BeginBlock;

    // EndBlock
    LEditPosition.Move(LEditPosition.Row, LEnd);
    LEditBlock.EndBlock;
    LEditBlock.Save;
  end;

  {$IFDEF TestRun}
  TTestRun.AddMarker('end TSelectBlockCode.SelectQuotationText');
  {$ENDIF}
end;

end.

