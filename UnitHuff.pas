unit UnitHuff;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids;
//const inputPath='C:\Users\demo\Desktop\ХНУ им. В.Н. Каразина\Программирование\Курсовая_Хаффман\input.txt';
      //outputPath='C:\Users\demo\Desktop\ХНУ им. В.Н. Каразина\Программирование\Курсовая_Хаффман\outputcodes.txt';
type pnode=^node;
      node=record
        freq:integer;
        letter:char;
        left:pnode;
        right:pnode;
        edit:TEdit;
      end;

    nodeCode=record
      letter:char;
      code:string[40];
    end;

    Tcode=array of nodeCode;
    Tarr=array of char;
    Tah=array of pnode;
procedure LoadFromFile(var s:string;inputPath:string);
procedure SaveData(var code:Tcode; ncode:integer;outputPath:string);
function FindInMas(huff:Tah; ch:char):boolean;
procedure GenarateFreq(var huff:Tah; s:string; var ind:integer);
procedure FastSorting(var huff:Tah; l,r: integer);
procedure FastSortingCodes(var code:Tcode; l,r: integer);
procedure BubleSorting(var huff:Tah;r:integer);
procedure Huffman(var huff:Tah);
procedure pushMas(var mas:Tarr; var n:integer; x:char);
procedure popMas (var mas:Tarr; var n:integer);
procedure Obhod(huff:pnode; var mas:Tarr; var code:Tcode; var ind:integer; var n:integer );
implementation
var f,fs:text;  s:String;  huff:Tah; i,ind,n:integer; mas:Tarr;  code:Tcode;
procedure LoadFromFile(var s:string; inputPath:String);
var ch:char;
begin
  AssignFile(f,inputPath);
  Reset(f);
  while not EOF(f) do
  begin
     read(f,ch);
     s:=s+ch;
  end;
  CloseFile(f);
end;

procedure SaveData(var code:Tcode; ncode:integer;outputPath:string);
var i:integer;
begin
  assignfile(fs,outputPath);
  rewrite(fs);
  for i := 0 to ncode do
  begin
    writeln(fs, '|',code[i].letter,'|',code[i].code);
  end;
  closefile(fs);
end;

Function FindInMas(huff:Tah; ch:char):boolean;
var i:integer;
begin
   for i:=0 to high(huff) do
   begin
     if ch=huff[i]^.letter then
     begin
     result:=false;
     exit;
     end;
   end;
   result:=true;
end;

procedure GenarateFreq(var huff:Tah; s:string; var ind:integer);
var i,j:integer;
begin
    ind:=0;
    SetLength(huff,1);
    New(huff[ind]);
    huff[ind]^.letter:=s[1];
    huff[ind]^.freq:=0;
    for i := 1 to length(s) do
      if s[i]=s[1] then inc(huff[ind]^.freq);
    huff[ind]^.left:=nil;
    huff[ind]^.right:=nil;
    for j := 1 to length(s) do
      begin
        if (s[1]<>s[j]) and (FindInMas(huff,s[j])) then
          begin
              inc(ind);
              SetLength(huff,length(huff)+1);
              New(huff[ind]);
              huff[ind]^.letter:=s[j];
              huff[ind]^.freq:=0;
              for i := 1 to length(s) do
                 if s[i]=s[j] then inc(huff[ind]^.freq);
              huff[ind]^.left:=nil;
              huff[ind]^.right:=nil;
          end;
   end;
end;

procedure FastSorting(var huff:Tah; l,r: integer);
var i,j,x,y: integer; tmp:char; tml,tmr:pnode; tme:Tedit;
begin
    i:=l;
    j:=r;
    x:=huff[(r+l) div 2]^.freq;
    repeat
      while huff[i]^.freq>x do
        i:=i+1;
      while x>huff[j]^.freq do
        j:=j-1;
      if i<=j then
      begin
        if huff[i]^.freq < huff[j]^.freq then
        begin
          y:=huff[i]^.freq;
          tmp:=huff[i]^.letter;
          tml:=huff[i]^.left;
          tmr:=huff[i]^.right;
          tme:=huff[i]^.edit;
          huff[i]^.freq:=huff[j]^.freq;
          huff[i]^.letter:=huff[j]^.letter;
          huff[i]^.left:=huff[j]^.left;
          huff[i]^.right:=huff[j]^.right;
          huff[i]^.edit:=huff[j]^.edit;
          huff[j]^.freq:=y;
          huff[j]^.letter:=tmp;
          huff[j]^.left:=tml;
          huff[j]^.right:=tmr;
          huff[j]^.edit:=tme;
        end;
        i:=i+1;
        j:=j-1;
      end;
    until i>=j;
    if l<j then FastSorting(huff,l,j);
    if i<r then FastSorting(huff,i,r);
  end;

procedure FastSortingCodes(var code:Tcode; l,r: integer);
var x,tmp:char; i,j:integer; s:string;
begin
    i:=l;
    j:=r;
    x:=code[(r+l) div 2].letter;
    repeat
      while code[i].letter<x do
        i:=i+1;
      while x<code[j].letter do
        j:=j-1;
      if i<=j then
      begin
        if code[i].letter > code[j].letter then
        begin
          tmp:=code[i].letter;
          s:=code[i].code;
          code[i].letter:=code[j].letter;
          code[i].code:=code[j].code;
          code[j].letter:=tmp;
          code[j].code:=s;
        end;
        i:=i+1;
        j:=j-1;
      end;
    until i>=j;
    if l<j then FastSortingCodes(code,l,j);
    if i<r then FastSortingCodes(code,i,r);
  end;

procedure BubleSorting(var huff:Tah;r:integer);
var i,j,y:integer;  tmp:char; tml,tmr:pnode; tme:Tedit;
begin
   for i := r-1 downto 0 do
        for j := 0 to i do
            if huff[j]^.freq < huff[j+1]^.freq then
            begin
                y := huff[j]^.freq;
                tmp:=huff[j]^.letter;
                tml:=huff[j]^.left;
                tmr:=huff[j]^.right;
                tme:=huff[j]^.edit;
                huff[j]^.freq:=huff[j+1]^.freq;
                huff[j]^.letter:=huff[j+1]^.letter;
                huff[j]^.left:=huff[j+1]^.left;
                huff[j]^.right:=huff[j+1]^.right;
                huff[j]^.edit:=huff[j+1]^.edit;
                huff[j+1]^.freq:=y;
                huff[j+1]^.letter:=tmp;
                huff[j+1]^.left:=tml;
                huff[j+1]^.right:=tmr;
                huff[j+1]^.edit:=tme;
            end;
end;

procedure Huffman(var huff:Tah);
var tmp,p:pnode; size:integer;
begin
  size:=length(huff)-1;
  while size<>0 do
  begin
     //FastSorting(huff,0,size);
     BubleSorting(huff,size);
     New(p);
     p^.left:=huff[size-1];
     p^.right:=huff[size];
     p^.freq:=huff[size-1]^.freq+huff[size]^.freq;
     huff[size].edit.Width:=huff[size].edit.Width div 2;
     huff[size-1].edit.Width:=huff[size-1].edit.Width div 2;
     dec(size);
     huff[size]:=p;
  end;
end;

procedure pushMas(var mas:Tarr; var n:integer; x:char);
begin
   if length(mas)=0 then
        SetLength(mas,3);
   if n<length(mas) then
   begin
     mas[n]:=x;
     inc(n);
   end
   else
      begin
        SetLength(mas,length(mas)*2);
        mas[n]:=x;
        inc(n);
      end;
end;

procedure popMas (var mas:Tarr; var n:integer);
begin
  mas[n]:=' ';
  dec(n);
end;

procedure Obhod(huff:pnode; var mas:Tarr; var code:Tcode; var ind:integer; var n:integer );
var pt:pnode; i:integer;               //mas -> stack; code -> tabble with codes
begin                                  //ind -> stack; n -> -//-
   pt:=huff;
   if pt^.left<>nil then
   begin
     pushMas(mas,ind,'0');
     Obhod(pt^.left,mas,code,ind,n);
   end;
   if pt^.right<>nil then
   begin
     pushMas(mas,ind,'1');
     Obhod(pt^.right,mas,code,ind,n);
   end;
   if pt^.letter<>'' then
   begin
      if length(code)=0 then
        SetLength(code,3);
      if n<length(code) then
      begin
        code[n].letter:=pt.letter;
        for i := 0 to ind-1 do
          code[n].code:=code[n].code+mas[i];
        inc(n);
      end
      else
        begin
          SetLength(code,length(code)*2);
          code[n].letter:=pt.letter;
          for i := 0 to ind-1 do
            code[n].code:=code[n].code+mas[i];
          inc(n);
        end;
   end;
   popMas(mas,ind);
end;

end.
