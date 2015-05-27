unit Template;

(*****************************************************************************
  A simple Pascal unit to simplify HTML page creation; with execution timer.
 *****************************************************************************)

{$MODE OBJFPC}{$H+}

interface

const
  APP_TITLE : string = 'DEFAULT';
  EXE_NAME  : string = 'default';
  CSS_NAME  : string = 'default';
  JS_NAME   : string = 'default';

procedure WriteAppHeader(const aCSSFile: string = ''; const aJSFile: string = '');
procedure WriteAppTitle(const aLevel: integer = 3; const aHome: string = 'Home');
procedure WriteAppFooter(const viewCode: boolean = true; const gitRepo: string = '');

function getValue(const aKey, fromString: string; const defValue: string = ''): string;
function boolToChecked(const aBoolean: boolean): string;
function boolToSelected(const aBoolean: boolean): string;
function strToTrue(const aValue: string): boolean;
function strToFalse(const aValue: string): boolean;

implementation

uses
  SysUtils, StrUtils, DateUtils;

var
  timeStart, timeStop: TDateTime;

(* private methods *)

function strTrimLower(const aString: string): string;
begin
  Result := Trim(LowerCase(aString));
end;

(* public methods *)

procedure WriteAppHeader(const aCSSFile: string = ''; const aJSFile: string = '');
begin
  writeln('content-type: text/html;');
  writeln;

  timeStart := Now;
  writeln('<!doctype html>');
  writeln('<html><head>');
  writeln('  <meta charset="UTF-8" lang="id">');
  writeln('  <link rel="stylesheet" type="text/css" href="',CSS_NAME,'.css">');
  if aCSSFile <> '' then writeln('  <link rel="stylesheet" type="text/css" href="',aCSSFile,'.css">');
  writeln('  <script>var appName = "',EXE_NAME,'";</script>');
  writeln('  <script type="text/javascript" src="',JS_NAME,'.js"></script>');
  if aJSFile  <> '' then writeln('  <script type="text/javascript" src="',aJSFile,'.js"></script>');
  writeln('  <title>',APP_TITLE,'</title>');
  writeln('</head><body>');
end;

procedure WriteAppTitle(const aLevel: integer = 3; const aHome: string = 'Home');
begin
  writeln('  <h',aLevel,'>&nbsp;');
  writeln('    <span class="bigger"><a href="',EXE_NAME,'.cgi" title="',aHome,'">⌂</a></span> │ ',APP_TITLE);
  writeln('  </h',aLevel,'>');
  writeln('  <div class="header"></div>');
  writeln('  <div class="content">');
  writeln('<!--- ### generated content start here ### --->');
end;

procedure WriteAppFooter(const viewCode: boolean = true; const gitRepo: string = '');
begin
  timeStop := Now;
  writeln('<!--- ### generated content end here ### --->');
  writeln('  </div>');
  writeln('  <div class="footer">');
  writeln('    This page is served in ',MilliSecondSpan(timeStart,timeStop):0:0,' ms by ');
  writeln('    <a href="http://freepascal.org" target=_blank>FreePascal</a>.<br/>');
  writeln('    Courtesy of ');
  writeln('    <a href="http://beeography.koding.io/">beeography.koding.io</a><br/>');
  if viewCode and (gitRepo <> '') then 
    writeln('    — <a href="',gitRepo,'" target=_blank>view source code</a>')
  else if viewCode then
    writeln('    — <a href="viewcode.cgi?file=',EXE_NAME,'.pas">view source code</a>');
  writeln('  </div>');
  writeln('</body></html>');
end;

function getValue(const aKey, fromString: string; const defValue: string = ''): string;
var
  pStart, pStop: integer;
  s: string;
begin
  Result := '';
  s := Trim(fromString);
  pStart := Pos(LowerCase(aKey)+'=', s);
  if pStart > 0 then
  begin
    pStop := PosEx('&', s, pStart);
    pStart := pStart + Length(aKey) + 1;
    if pStop = 0 then pStop := 1024;
    Result := Copy(s, pStart, pStop-pStart);
    if (Result = '') and (defValue <> '') then Result := defValue;
  end;
end;

function boolToChecked(const aBoolean: boolean): string;
begin
  if aBoolean then Result := 'checked' else Result := '';
end;

function boolToSelected(const aBoolean: boolean): string;
begin
  if aBoolean then Result := 'selected' else Result := '';
end;

function strToTrue(const aValue: string): boolean;
var
  s: string;
begin
  s := strTrimLower(aValue);
  Result := (s = '1') or (s = 'true') or (s = 'y') or (s = 'yes');
end;

function strToFalse(const aValue: string): boolean;
var
  s: string;
begin
  s := strTrimLower(aValue);
  Result := (s = '0') or (s = 'false') or (s = 'n') or (s = 'no');
end;

(* unit initialization *)

begin  
end.