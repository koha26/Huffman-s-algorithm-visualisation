unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, UnitHuff, Vcl.Menus;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    StringGrid1: TStringGrid;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    fNew: TMenuItem;
    fOpen: TMenuItem;
    fSave: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button2: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure fOpenClick(Sender: TObject);
    procedure fSaveClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1; huff:Tah; mas:Tarr; code:Tcode;
  fFilePath:String;
  offset:integer;
  flag:boolean;
implementation

{$R *.dfm}
procedure CreateEdits(offset,n: integer);
var edit: tedit;
begin
  edit:= TEdit.Create(form1);
  edit.Parent := Form1;
  edit.Left:=250+(460 div n)*(offset-2);
  edit.Top := 45;
  edit.Visible := true;
  edit.Width := 460 div n;
  edit.Name := 'Edit'+inttostr(offset);
  edit.text := huff[offset-2].letter;
  huff[offset-2].edit:=edit;
end;

procedure treeChange(huff:pnode; prehuff:pnode);
var pt:pnode; i:integer;
begin
   pt:=huff;
   if pt^.left<>nil then
   begin
     pt^.left.edit.Left:=prehuff.edit.Left;
     pt^.left.edit.Top:=prehuff.edit.Top+50;
     pt^.left.edit.Width:=prehuff.edit.Width div 2;
     treeChange(pt^.left,pt^.left);
   end;
   if pt^.right<>nil then
   begin
     pt^.right.edit.Left:=prehuff.edit.Left+(prehuff.edit.Width div 2);
     pt^.right.edit.Top:=prehuff.edit.Top+50;
     pt^.right.edit.Width:=prehuff.edit.Width div 2;
     treeChange(pt^.right,pt^.right);
   end;
end;

procedure setChanges(n:integer);
var weigth,top,left,i:integer; pt:pnode;
begin
   for i:=0 to n do
   begin
     huff[i]^.edit.Left:=250+(460 div (n+1))*i;
     huff[i]^.edit.Width := 460 div (n+1);
     treeChange(huff[i],huff[i]);
   end;
end;

procedure Huffman1(var huff:Tah);
var tmp,p:pnode; size:integer; edit: tedit;
begin
  size:=length(huff)-1;
  while size<>0 do
  begin
     //FastSorting(huff,0,size);
     BubleSorting(huff,size);
     setChanges(size);
     New(p);
     //p^.left:=huff[size-1];
     //p^.right:=huff[size];
     p^.edit:= TEdit.Create(form1);
     p^.edit.Parent := Form1;
     p^.edit.Left:=huff[size-1]^.edit.Left;
     p^.edit.Top := 45;
     p^.edit.Visible := true;
     p^.edit.Width := huff[size-1]^.edit.Width;
     p^.edit.Name := 'Edit'+inttostr(offset+1);
     p^.edit.text := huff[size-1]^.edit.text+huff[size]^.edit.text;
     p^.freq:=huff[size-1]^.freq+huff[size]^.freq;
     //huff[size]^.edit.Width:=huff[size]^.edit.Width div 2;
     //huff[size-1]^.edit.Width:=huff[size-1]^.edit.Width div 2;
     p^.left:=huff[size-1];
     p^.right:=huff[size];
     //huff[size]^.edit.Top:=95;
     //huff[size-1]^.edit.Top:=95;
     dec(size);
     inc(offset);
     huff[size]:=p;
  end;
  setChanges(size);
end;

procedure TForm1.Button1Click(Sender: TObject);
var text:String; ind,i:integer; stackind,ncode:integer; pt:pnode;
begin
  text:=Edit1.text;
  UnitHuff.GenarateFreq(huff,text,ind);
  StringGrid1.RowCount:=length(huff)+1;
  for i := 0 to length(huff)-1 do
  begin
    StringGrid1.Cells[0,i+1]:=huff[i].letter;
    StringGrid1.Cells[1,i+1]:=IntToStr(huff[i].freq);
    CreateEdits(i+2,length(huff));
    offset:=i+2;
  end;
  Huffman1(huff);
  stackind:=0;   //stack index
  ncode:=0;      //codes index
  pt:=huff[0];
  Obhod(pt,mas,code,stackind,ncode);
  for i := 0 to ncode-1 do
    begin
      StringGrid1.Cells[0,i+1]:=code[i].letter;
      StringGrid1.Cells[2,i+1]:=code[i].code;
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form1.Color:= clGreen;
  fOpenClick(self);       //.chm -справка
end;

procedure TForm1.fOpenClick(Sender: TObject);
var text:String;
begin
  if OpenDialog1.Execute then
     begin
         fFilePath:=OpenDialog1.FileName;
         UnitHuff.LoadFromFile(text,fFilePath);
         Edit1.Text:=text;
     end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StringGrid1.ColCount:=3;
  StringGrid1.Cells[0,0]:='Символ';
  StringGrid1.Cells[1,0]:='Частота';
  StringGrid1.Cells[2,0]:='Код Хаффмана';
  StringGrid1.ColWidths[2]:=Canvas.TextWidth(StringGrid1.Cells[2,0])+25;
  StringGrid1.ColWidths[1]:=Canvas.TextWidth(StringGrid1.Cells[1,0])+10;
  StringGrid1.ColWidths[0]:=Canvas.TextWidth(StringGrid1.Cells[0,0])+10;
  StringGrid1.Width:=StringGrid1.ColWidths[0]+StringGrid1.ColWidths[1]+StringGrid1.ColWidths[2]+8;

end;



procedure Save;
var i:integer; f:text;
begin
  AssignFile(f,fFilePath);
  Rewrite(f);
  for i := 1 to Form1.StringGrid1.RowCount do
  begin
    writeln(f,Form1.StringGrid1.Cells[0,i],' ',Form1.StringGrid1.Cells[1,i]);
  end;
  CloseFile(f);
end;

procedure TForm1.fSaveClick(Sender: TObject);
var i:integer;
begin
  if SaveDialog1.Execute then
     begin
         fFilePath:=SaveDialog1.FileName;
         Save;
     end;
end;

end.

