unit base64;

interface
function base64_encode(const input: string): string;
function base64_decode(const input: string): string;


implementation

function base64_encode(const input: string): string;
  function Encode_Byte(b: Byte): ansichar;
  const
    Base64Code: string[64] =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  begin
    Result := Base64Code[(b and $3F)+1];
  end;
var
  i: Integer;
begin
  i := 1;
  Result := '';
  while i <=Length(input) do
  begin
    Result := Result + Encode_Byte(Byte(input[i]) shr 2);
    Result := Result + Encode_Byte((Byte(input[i]) shl 4) or (Byte(input[i+1]) shr 4));
    if i+1 <=Length(input) then
      Result := Result + Encode_Byte((Byte(input[i+1]) shl 2) or (Byte(input[i+2]) shr 6))
    else
      Result := Result + '=';
    if i+2 <=Length(input) then
      Result := Result + Encode_Byte(Byte(input[i+2]))
    else
      Result := Result + '=';
    Inc(i, 3);
  end;
end;

function base64_decode(const input: string): string;
const
  RESULT_ERROR = -2;
var
  inLineIndex: Integer;
  c: Char;
  x: SmallInt;
  c4: Word;
  StoredC4: array[0..3] of SmallInt;
  InLineLength: Integer;
begin
  Result := '';
  inLineIndex := 1;
  c4 := 0;
  InLineLength := Length(input);

  while inLineIndex <=InLineLength do
  begin
    while (inLineIndex <=InLineLength) and (c4 < 4) do
    begin
      c := input[inLineIndex];
      case c of
        '+'     : x := 62;
        '/'     : x := 63;
        '0'..'9': x := Ord(c) - (Ord('0')-52);
        '='     : x := -1;
        'A'..'Z': x := Ord(c) - Ord('A');
        'a'..'z': x := Ord(c) - (Ord('a')-26);
      else
        x := RESULT_ERROR;
      end;
      if x <> RESULT_ERROR then
      begin
        StoredC4[c4] := x;
        Inc(c4);
      end;
      Inc(inLineIndex);
    end;
    if c4 = 4 then
    begin
      c4 := 0;
      Result := Result + Char((StoredC4[0] shl 2) or (StoredC4[1] shr 4));
      if StoredC4[2] = -1 then Exit;
      Result := Result + Char((StoredC4[1] shl 4) or (StoredC4[2] shr 2));
      if StoredC4[3] = -1 then Exit;
      Result := Result + Char((StoredC4[2] shl 6) or (StoredC4[3]));
    end;
  end;
end;
end.

