program OlahKata;

(*****************************************************************************
  OlahKata v1.0 - Online Scrabble or TextTwist solver for Indonesian/English.
  Malang, 10 May 2015 
  by @beezing
 *****************************************************************************)

{$MODE OBJFPC}{$H+}

uses
  DOS, Classes, SysUtils, FileUtil, Template;

const
  LETTERS  = 26;
  a_INDEX  = 97;
  ALPHABET = ['a'..'z','-'];
  ID_FILE  = 'kata.txt';
  EN_FILE  = 'word.txt';
  URL_KBBI = 'http://kbbi.web.id/';

type
  // array is started from 1 to match pascal's string index
  TLetters = array[1..LETTERS] of integer;
  // word dictionary stat
  TDictionary = record
    lang: string;
    fileName: string;
    fileSize: longint;
    wordCount: longint;
    longestWord: integer;
  end;

var
  queryString, inputLetters: string;
  dictWords, foundWords: TStringList;
  isExact, isDebug: boolean;
  dictFile: TDictionary;
  userLetters: TLetters;

(* main methods *)

function openDictionary(var aDictionary: TDictionary): boolean;
begin
  with aDictionary do
  begin
    if lang = 'en' then fileName := EN_FILE else fileName := ID_FILE;

    if FileExists(fileName) then
      try
        dictWords.LoadFromFile(fileName);
        fileSize := FileUtil.FileSize(fileName);
        wordCount := dictWords.Count;
        Result := true;
      except
        dictWords.Free;
        Result := false;
      end
    else
      Result := false;
  end;
end;

function countLetters(const aLetters: string): TLetters;
var
  i: integer;
  s: string;
begin
  s := LowerCase(aLetters);
  for i := 1 to LETTERS do Result[i] := 0; // reset count

  for i := 1 to Length(s) do 
    if s[i] in ALPHABET then
      // index is plused 1 because the array is started from 1
      Result[ord(s[i]) - a_INDEX+1] := Result[ord(s[i]) - a_INDEX+1] + 1;
end;

function containLetters(const subLetters, fullLetters: TLetters; const aExact: boolean = false): boolean;
var
  i: integer;
begin
  Result := true;
  for i := 1 to LETTERS do
    if aExact then
      Result := Result and (subLetters[i] = fullLetters[i])
    else
      Result := Result and (subLetters[i] <= fullLetters[i]);
end;

procedure printLetters(const aLetters: TLetters; const isComplete: boolean = true);
var
  i: integer;
begin
  for i := 1 to LETTERS do
    if (not isComplete) and (aLetters[i] > 0) then 
      write(UpperCase(chr(a_INDEX + i-1)),' ')
    else if isComplete then
      write(chr(a_INDEX + i-1),'=',aLetters[i],'; ');
end;

procedure printLetters(const aInput: string);
var
  i: integer;
  s: string;
begin
  s := LowerCase(aInput);
  for i := 1 to Length(aInput) do
    if s[i] in ALPHABET then write(s[i]);
end;

function sortWordsByLength(aList: TStringList; Index1, Index2: integer): integer;
var
  l1, l2: integer;
begin
  l1 := Length(aList[Index1]);
  l2 := Length(aList[Index2]);
  if (l1 < l2) then Result := -1
    else if (l1 > l2) then Result := 1
      else Result := 0;
end;

procedure sortWordsGroupByLength(var aWords: TStringList);
var
  s: string;
  i,l: integer;
  sortedGroup: TStringList;
begin
  if (aWords.Count = 0) or (aWords.Text = '') then Exit;

  sortedGroup := TStringList.Create;
  sortedGroup.Sorted := true;

  i := 0;
  s := '';
  while i < aWords.Count do
  begin
    l := Length(aWords[i]);
    sortedGroup.Clear;

    while Length(aWords[i]) = l do
    begin
      sortedGroup.Add(aWords[i]);
      i := i + 1;

      if i > aWords.Count-1 then Break;
    end;

    s := s + sortedGroup.Text;
  end;

  aWords.Text := s;
  sortedGroup.Free;
end;

procedure searchWords(const aLetters: TLetters; const aDictWords: TStringList; var aFoundWords: TStringList);
var
  i: integer;
  dw: TLetters;
begin
  aFoundWords.Clear;
  dictFile.longestWord := 0;

  for i := 0 to aDictWords.Count-1 do
  begin
    if Length(aDictWords[i]) > dictFile.longestWord then 
      dictFile.longestWord := Length(aDictWords[i]);

    dw := countLetters(aDictWords[i]);
    if containLetters(dw, aLetters, isExact) then 
      aFoundWords.Add(LowerCase(aDictWords[i]));
  end;
end;

procedure printWordsGroupByLength(const aWords: TStringList);
var
  s: string;
  c,i,l: integer;
begin
  if (aWords.Count > 0) or (aWords.Text <> '') then
  begin
    writeln('<p><ul>');

    i := 0;
    while i < aWords.Count do
    begin
      l := Length(aWords[i]);
      writeln('<li><b>',l,' huruf:</b><p class="tighter">');

      c := 0;
      s := '';
      while Length(aWords[i]) = l do 
      begin
        s := s + '<a href="'+URL_KBBI+aWords[i]+'">'+aWords[i]+'</a>, ';
        c := c + 1;
        i := i + 1;
        if i > aWords.Count-1 then Break;
      end;

      if c > 0 then 
      begin
        s := Copy(s,1,Length(s)-2);
        write(s,'<span class="smaller"> — (',c,' kata)</span>');
      end;

      if isDebug then 
      begin
        writeln('<br/>');
        printLetters(aWords[i-1]);
        write(' : ');
        printLetters(countLetters(aWords[i-1]));
        writeln;
      end;

      writeln('</li>');
    end;

    writeln('</ul>');
    writeln('<p>Ditemukan <b>',aWords.Count,'</b> kata.');
  end
  else
    writeln('<p>Tidak ada kata ditemukan.')
end;

procedure buildForm;
begin
  writeln('<form method="get" action="',EXE_NAME,'.cgi">');
  writeln('  <label>Ketikkan:');
  writeln('  <input type="text" id="edLetters" name="letters" value="" />');
  writeln('  </label>');
  writeln('  <input type="submit" id="btnSubmit" name="submit" value=" OLAH " />');
  writeln('  <span class="bigger"> │ </span>');
  writeln('  <label>');
  writeln('  <input type="checkbox" id="cbExact" name="exact" value="1" ',boolToChecked(isExact),'/>');
  writeln('  tepat jumlah huruf</label>');
  writeln('</form>');
end;

(* main program *)

begin
  APP_TITLE := 'OLAH KATA';
  EXE_NAME  := 'olahkata';

  // read app parameters
  queryString := GetEnv('QUERY_STRING');
  inputLetters := getValue('letters',queryString);
  isExact := strToTrue(getValue('exact',queryString));
  isDebug := strToTrue(getValue('debug',queryString));
  dictFile.lang := getValue('lang',queryString);

  // setup app variables
  dictWords := TStringList.Create;
  foundWords := TStringList.Create;

  WriteAppHeader;
  WriteAppTitle;

  // stop app if dictionary file is missing
  if not openDictionary(dictFile) then 
  begin
    writeln('<span class="error">ERROR</span>: Dictionary file is NOT found!');
    WriteAppFooter;
    Exit;
  end;

  buildForm;

  if inputLetters <> '' then
  begin
    // input letters
    write('<p><hr><p>Daftar huruf: ');
    write('<span class="letters">');
    printLetters(inputLetters);
    write('</span><span class="smaller">');
    write(' — (',Length(inputLetters),' huruf)');
    writeln('</span>');

    userLetters := countLetters(inputLetters);
    if isDebug then 
    begin
      write('<br/>');
      printLetters(inputLetters);
      write(' : ');
      printLetters(userLetters);
      writeln;
    end;

    // search for words in dictionary by input letters
    searchWords(userLetters, dictWords, foundWords);
    foundWords.CustomSort(@sortWordsByLength);
    sortWordsGroupByLength(foundWords);

    // print found words
    writeln('<script>document.title = "',Trim(inputLetters),' — ',APP_TITLE,'";</script>');
    writeln('<p>Daftar kata yg bisa disusun:');
    printWordsGroupByLength(foundWords);

    // dictionary stats
    write('<p><hr>Lihat daftar kata di <a href="',dictFile.fileName,'">sini</a>.');
    write('<span class="smaller">&nbsp;');
    write(' — (ada ',dictFile.wordCount,' kata; ');
    write('terpanjang ',dictFile.longestWord,' huruf; ');
    write('berkas ',dictFile.fileSize div 1000,' kb)');
    writeln('</span>')
  end
  else
    if queryString <> '' then 
      writeln('<br/><span class="error">ERROR</span>: Tidak ada huruf dimasukkan!');

  // clean up and close app
  foundWords.Free;
  dictWords.Free;
  WriteAppFooter;
end.