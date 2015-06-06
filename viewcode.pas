program ViewCode;

(***************************************************
  A simple online code viewer using PrismJS (.com)
 ***************************************************)

{$MODE OBJFPC}{$H+}

uses
  DOS, Classes, SysUtils, StrUtils, DateUtils, FileUtil;

const
  APP_TITLE = 'CODE VIEWER';
  EXE_NAME  = 'viewcode';

type
  TSourceFile = record
    filePath: string;
    fileName: string;
    fileType: string;
    fileSize: longint;
    runnable: boolean;
  end;

const
  // list of available source code files to show
  sourceFiles: array[0..6] of TSourceFile = (
    (filePath:'../Applications/'; fileName:'olahkata.pas';  fileType:'pascal';     fileSize: 0; runnable:true ),
    (filePath:'../Applications/'; fileName:'template.pas';  fileType:'pascal';     fileSize: 0; runnable:false),
    (filePath:'';                 fileName:'default.js';    fileType:'javascript'; fileSize: 0; runnable:false),
    (filePath:'';                 fileName:'default.css';   fileType:'css';        fileSize: 0; runnable:false),
    (filePath:'../';              fileName:'pas2cgi.sh';    fileType:'bash';       fileSize: 0; runnable:false),
    (filePath:'../Applications/'; fileName:'viewcode.pas';  fileType:'pascal';     fileSize: 0; runnable:true ),
    (filePath:'../Applications/'; fileName:'hello_web.pas'; fileType:'pascal';     fileSize: 0; runnable:true ));

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

var
  queryString: string;
  sourceFile: TStringList;
  selectFileName: string;
  selectFileIndex: integer;
  timeStart, timeStop: TDateTime;
  i: integer;
  s: string;

begin
  writeln('content-type: text/html;');
  writeln;

  // set html header
  timeStart := Now;
  writeln('<!doctype html>');
  writeln('<html><head>');
  writeln('  <meta charset="UTF-8" lang="id">');
  writeln('  <link rel="stylesheet" href="default.css">');
  writeln('  <link rel="stylesheet" href="prism.css">');
  writeln('  <script>var appName = "',EXE_NAME,'";</script>');
  writeln('  <script type="text/javascript" src="default.js"></script>');
  writeln('  <script type="text/javascript" src="prism.min.js"></script>');
  writeln('  <title>',APP_TITLE,'</title>');
  writeln('</head><body>');

  // set page header
  writeln('  <h3>&nbsp;');
  writeln('    <span class="bigger"><a href="',EXE_NAME,'.cgi" title="Home">⌂</a></span> │ ',APP_TITLE);
  writeln('  </h3>');
  writeln('  <div class="header"></div>');
  writeln('  <div class="content">');

  // read app params
  queryString := GetEnv('QUERY_STRING');
  selectFileName := getValue('file',queryString);

  // setup form
  writeln('<form method="get" action="',EXE_NAME,'.cgi">');
  writeln('  <label>Source files: <select id="cbFile" name="file">');

  // fill up selection
  selectFileIndex := -1;
  writeln('    <option value="" disabled selected>pick a file...</option>');
  for i := 0 to High(sourceFiles) do
  begin
    write('    <option value="',sourceFiles[i].fileName,'"');
    if sourceFiles[i].fileName = selectFileName then 
    begin 
      write(' selected ');
      selectFileIndex := i;
      selectFileName := sourceFiles[i].filePath + sourceFiles[i].fileName;
    end;
    writeln('>',sourceFiles[i].fileName,'</option>');
  end;

  writeln('  </select></label>');
  writeln('  <input type="submit" id="btnSubmit" name="submit" value=" VIEW " />');
  writeln('</form>');

  // open selected source code file
  if selectFileName <> '' then
    if FileExists(selectFileName) and (selectFileIndex >= 0) then
    begin
      writeln('<script>document.title = "',sourceFiles[selectFileIndex].fileName,' — ',APP_TITLE,'";</script>');

      sourceFile := TStringList.Create;
      try
        // open file
        sourceFiles[selectFileIndex].fileSize := FileUtil.FileSize(selectFileName);
        sourceFile.LoadFromFile(selectFileName);

        // encode special chars
        for i := 0 to sourceFile.Count-1 do
        begin
          s := sourceFile[i];
          if Pos('<',s) > 0 then s := ReplaceStr(s,'<','&lt;');
          if Pos('>',s) > 0 then s := ReplaceStr(s,'>','&gt;');
          sourceFile[i] := s;
        end;

        // print file stats
        write('<hr/><p>');
        if (sourceFiles[selectFileIndex].runnable) and (sourceFiles[selectFileIndex].fileType = 'pascal') then
          write('│ <b><a href="',ReplaceStr(sourceFiles[selectFileIndex].fileName,'.pas','.cgi'),'">',
                sourceFiles[selectFileIndex].fileName,'</a></b>')
        else
          write('│ <b>',sourceFiles[selectFileIndex].fileName,'</b>');
        writeln(' │ ',sourceFile.Count,' lines │ ',sourceFiles[selectFileIndex].fileSize,' bytes │');

        // print file content
        write('<pre class="line-numbers"><code class="language-',sourceFiles[selectFileIndex].fileType,'">');
        for i := 0 to sourceFile.Count-1 do writeln(sourceFile[i]);
        writeln('</code></pre>');
      finally
        sourceFile.Free;
      end;
    end
    else
      writeln('<br/><span class="error">ERROR</span>: Source file "',selectFileName,'" is NOT available!');

  // write page footer
  timeStop := Now;
  writeln('  </div>');
  writeln('  <div class="footer">');
  writeln('    This page is served in ',MilliSecondSpan(timeStart,timeStop):0:0,' ms by ');
  writeln('    <a href="http://freepascal.org" target=_blank>FreePascal</a>.<br/>');
  writeln('    Courtesy of ');
  writeln('    <a href="http://beeography.koding.io/">beeography.koding.io</a><br/>');
  writeln('    — <a href="viewcode.cgi?file=',EXE_NAME,'.pas">view source code</a>');
  writeln('  </div>');
  writeln('</body></html>');  
end.