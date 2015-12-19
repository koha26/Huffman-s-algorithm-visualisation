unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, UnitHuff, Vcl.Menus, Math,
  Vcl.ExtCtrls, Vcl.Mask;

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
    Button3: TButton;
    Timer1: TTimer;
    Edit50: TEdit;
    Edit51: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure fOpenClick(Sender: TObject);
    procedure fSaveClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1; huff:Tah; mas:Tarr; code:Tcode;
  fFilePath:String;
  offset:integer;
  flag,finished,sorted:boolean;
  size:integer;
  memoRowInd:integer;
implementation

{$R *.dfm}

procedure DescriptionOfActions(c:char);
var i,j:integer;
begin
   case c of
     's': begin
          Form1.Memo1.Lines.Add('- ��������� ��� ������ �� ������� ��������.');
          Form1.Memo1.Lines.Add(' ');
        end;
     'f': begin
          Form1.Memo1.Lines.Add('- ��������� ������� ���� ��������.');
          Form1.Memo1.Lines.Add(' ');
          end;
     'n': begin
          Form1.Memo1.Lines.Add(' ');
          Form1.Memo1.Lines.Add('��������� �������� ��������');
          Form1.Memo1.Lines.Add(' ');
          end;
     'm': begin
          Form1.Memo1.Lines.Add('- �������� ������, ��� ����� ������� ���� ��������� ������ ��� ������� �������.');
          Form1.Memo1.Lines.Add(' ');
          end;
     '2': begin
          Form1.Memo1.Lines.Add('- ����� ��������� 2 ������� �� ������� � ���������� �� � ���� ����. ');
          Form1.Memo1.Lines.Add('- ������ �� �������. ');
          Form1.Memo1.Lines.Add(' ');
          end;
     't': begin
          Form1.Memo1.Lines.Add('- C����� ��� ��������� �������� - ��������� �������� ������');
          Form1.Memo1.Lines.Add(' ');
          end;
   end;
end;

procedure DrawArrowHead(Canvas: TCanvas; X,Y: Integer; Angle,LW: Extended);
var
  A1,A2: Extended;
  Arrow: array[0..3] of TPoint;
  OldWidth: Integer;
const
  Beta=0.322;
  LineLen=4.74;
  CentLen=3;
begin
  Angle:=Pi+Angle;
  Arrow[0]:=Point(X,Y);
  A1:=Angle-Beta;
  A2:=Angle+Beta;
  Arrow[1]:=Point(X+Round(LineLen*LW*Cos(A1)),Y-Round(LineLen*LW*Sin(A1)));
  Arrow[2]:=Point(X+Round(CentLen*LW*Cos(Angle)),Y-Round(CentLen*LW*Sin(Angle)));
  Arrow[3]:=Point(X+Round(LineLen*LW*Cos(A2)),Y-Round(LineLen*LW*Sin(A2)));
  OldWidth:=Canvas.Pen.Width;
  Canvas.Pen.Width:=1;
  Canvas.Polygon(Arrow);
  Canvas.Pen.Width:=OldWidth
end;

procedure DrawArrow(Canvas: TCanvas; X1,Y1,X2,Y2: Integer; LW: Extended);
var
  Angle: Extended;
begin
  Angle:=ArcTan2(Y1-Y2,X2-X1);
  Canvas.MoveTo(X1,Y1);
  Canvas.LineTo(X2-Round(2*LW*Cos(Angle)),Y2+Round(2*LW*Sin(Angle)));
  DrawArrowHead(Canvas,X2,Y2,Angle,LW);
end;

procedure FindCodes(huff:pnode; var mas:Tarr; var code:Tcode; var ind:integer; var n:integer );
var pt:pnode; i:integer;  left_x1,top_y1,left_x2,top_y2:integer; text:string;
begin                                  //ind -> stack; n -> -//-
   pt:=huff;                           //mas -> stack; code -> tabble with codes
   if pt^.left<>nil then
   begin
     left_x1:=pt^.edit.Left+(pt^.edit.Width div 2);
     top_y1:=pt^.edit.Top+pt^.edit.Height;
     left_x2:=pt^.left^.edit.Left+(pt^.left^.edit.Width div 2);
     top_y2:=pt^.left^.edit.Top;
     Form1.Canvas.Pen.Color:=clGreen;
     Form1.Canvas.Pen.Width:=2;
     Form1.Canvas.Brush.Color:=clGreen;
     DrawArrow(Form1.Canvas,left_x1,top_y1,left_x2,top_y2,2);
     pushMas(mas,ind,'0');
     Form1.Edit50.Text:=Form1.Edit50.Text+'0';
     sleep(1000);
     FindCodes(pt^.left,mas,code,ind,n);
   end;
   if pt^.right<>nil then
   begin
     left_x1:=pt^.edit.Left+(pt^.edit.Width div 2);
     top_y1:=pt^.edit.Top+pt^.edit.Height;
     left_x2:=pt^.right^.edit.Left+(pt^.right^.edit.Width div 2);
     top_y2:=pt^.right^.edit.Top;
     Form1.Canvas.Pen.Color:=clGreen;
     Form1.Canvas.Pen.Width:=2;
     Form1.Canvas.Brush.Color:=clGreen;
     DrawArrow(Form1.Canvas,left_x1,top_y1,left_x2,top_y2,2);
     pushMas(mas,ind,'1');
     Form1.Edit50.Text:=Form1.Edit50.Text+'1';
     sleep(1000);
     FindCodes(pt^.right,mas,code,ind,n);
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
   //text:=Form1.Edit50.Text;
   //SetLength(text,length(text)-1);
   //Form1.Edit50.Text:=text;
   //delete(Form1.MaskEdit1.Text,length(Form1.MaskEdit1.Text)-1,1);
end;

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
  edit.ReadOnly:=true;
  huff[offset-2].edit:=edit;
end;

procedure treeChange(huff:pnode; prehuff:pnode);
var pt:pnode; i:integer; left_x1,top_y1,left_x2,top_y2:integer;
begin
   pt:=huff;
   if pt^.left<>nil then
   begin
     pt^.left.edit.Left:=prehuff.edit.Left;
     pt^.left.edit.Top:=prehuff.edit.Top+50;
     pt^.left.edit.Width:=prehuff.edit.Width div 2;
     left_x1:=prehuff^.edit.Left+(prehuff^.edit.Width div 2);
     top_y1:=prehuff^.edit.Top+prehuff^.edit.Height;
     left_x2:=pt^.left^.edit.Left+(pt^.left^.edit.Width div 2);
     top_y2:=pt^.left^.edit.Top;
     Form1.Canvas.Pen.Color:=clRed;
     Form1.Canvas.Pen.Width:=2;
     Form1.Canvas.Brush.Color:=clRed;
     DrawArrow(Form1.Canvas,left_x1,top_y1,left_x2,top_y2,2);
     treeChange(pt^.left,pt^.left);
   end;
   if pt^.right<>nil then
   begin
     pt^.right.edit.Left:=prehuff.edit.Left+(prehuff.edit.Width div 2);
     pt^.right.edit.Top:=prehuff.edit.Top+50;
     pt^.right.edit.Width:=prehuff.edit.Width div 2;
     left_x1:=prehuff^.edit.Left+(prehuff^.edit.Width div 2);
     top_y1:=prehuff^.edit.Top+prehuff^.edit.Height;
     left_x2:=pt^.right^.edit.Left+(pt^.right^.edit.Width div 2);
     top_y2:=pt^.right^.edit.Top;
     Form1.Canvas.Pen.Color:=clBlue;
     Form1.Canvas.Pen.Width:=2;
     Form1.Canvas.Brush.Color:=clBlue;
     DrawArrow(Form1.Canvas,left_x1,top_y1,left_x2,top_y2,2);
     treeChange(pt^.right,pt^.right);
   end;
end;

procedure setChanges(n:integer);
var weigth,top,left,i:integer; pt:pnode;
begin
   Form1.Canvas.Brush.Color := clBtnFace;
   Form1.Canvas.FillRect(Form1.Canvas.ClipRect);
   for i:=0 to n do
   begin
     huff[i]^.edit.Left:=250+(460 div (n+1))*i;
     huff[i]^.edit.Width := 460 div (n+1);
     treeChange(huff[i],huff[i]);
   end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var text:String; ind,i,j,stackind,ncode,symbols:integer; pt:pnode; tmp:char;
begin
  text:=Edit1.text;
  UnitHuff.GenarateFreq(huff,text,ind);
  if length(huff)>17 then
  begin
    Memo1.Lines.Add('��������: ��� ����� �������� ������ 17 ��������� ��������. ��������� ������� ���.');
    Edit1.text:='';
    exit;
  end;
  DescriptionOfActions('n');
  DescriptionOfActions('f');
  //UnitHuff.GenarateFreq(huff,text,ind);
  StringGrid1.RowCount:=length(huff)+1;
  for i := 0 to length(huff)-1 do
  begin
    StringGrid1.Cells[0,i+1]:=huff[i].letter;
    StringGrid1.Cells[1,i+1]:=IntToStr(huff[i].freq);
    //CreateEdits(i+2,length(huff));
    //offset:=i+2;
  end;
  size:=length(huff)-1;
  Form1.Button2.SetFocus;
end;

procedure Huffman2(var huff:Tah; var size:integer);
var tmp,p:pnode; i,j:integer; edit: tedit; stackind,ncode:integer; pt:pnode; text:String;
begin
  if (size=length(huff)-1) and (flag=false)then
  begin
     for i := 0 to length(huff)-1 do
     begin
        CreateEdits(i+2,length(huff));
        offset:=i+2;
     end;
     size:=length(huff)-1;
     DescriptionOfActions('m');
     //BubleSorting(huff,size);
     //DescriptionOfActions('s');
     //setChanges(size);
     flag:=true;
     exit;
  end;
  if (size<>0) and (sorted=false) then
  begin
     BubleSorting(huff,size);
     DescriptionOfActions('s');
     setChanges(size);
     sorted:=true;
     exit;
  end;
  if size<>0 then
  begin
     //BubleSorting(huff,size);
     //DescriptionOfActions('s');
     //setChanges(size);
     New(p);
     p^.edit:= TEdit.Create(form1);
     p^.edit.Parent := Form1;
     p^.edit.Left:=huff[size-1]^.edit.Left;
     p^.edit.Top := 45;
     p^.edit.Visible := true;
     p^.edit.ReadOnly:=true;
     p^.edit.Width := huff[size-1]^.edit.Width;
     p^.edit.Name := 'Edit'+inttostr(offset+1);
     Form1.Memo1.Lines.Add('- ����� ��������� 2 �������� (����) �� ������� � ���������� �� � ���� ����. ');
     Form1.Memo1.Lines.Add('  ������ �� �������. ���������� '+IntToStr(huff[size-1].freq+huff[size].freq));
     Form1.Memo1.Lines.Add(' ');
     p^.edit.Text:=IntToStr(huff[size-1]^.freq+huff[size]^.freq);
     //p^.edit.text := IntToStr(huff[size-1]^.freq+huff[size]^.freq);
     //p^.edit.text := huff[size-1]^.edit.text+huff[size]^.edit.text;
     p^.freq:=huff[size-1]^.freq+huff[size]^.freq;
     p^.left:=huff[size-1];
     p^.right:=huff[size];
     dec(size);
     inc(offset);
     huff[size]:=p;
     if size=0 then
     begin
        DescriptionOfActions('t');
        Form1.Memo1.Lines.Add('- ������, ����� �������� ��� ��� ������� �������, ���� ������ �������� �� ������, � ��� ������� �������� ��������� 0, ���� �� ��� ����� (������� �������), � 1 � ���� ������� (����� �������)');
        Form1.Memo1.Lines.Add(' ');
        huff[0].edit.text:='['+IntToStr(huff[0]^.freq)+']';
     end;
     setChanges(size);
     sorted:=false;
  end
  else
  begin
     setChanges(size);
     stackind:=0;   //stack index
     ncode:=0;      //codes index
     pt:=huff[0];
     FindCodes(pt,mas,code,stackind,ncode);
     for i := 0 to ncode-1 do
     begin
        for j := 0  to ncode-1 do
        begin
          if Form1.StringGrid1.Cells[0,j+1]=code[i].letter then
          begin
            Form1.StringGrid1.Cells[2,j+1]:=code[i].code;
            break;
          end;
        end;
     end;
     Form1.Button2.Default:=false;
     Form1.Edit1.SetFocus;
     Form1.Button2.Enabled:=false;
     finished:=true;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);// var huff:Tah; var size:integer);
var tmp,p:pnode; i,j:integer; edit: tedit;
begin
      //.chm -�������
  Huffman2(huff,size);
end;

procedure TForm1.Button3Click(Sender: TObject);
var tmp,i,j:integer;
begin
  if finished then
  begin
    tmp:=MessageBox(Handle,'Do you want to save this result to *.txt?','SaveDialog',MB_YESNOCANCEL+MB_ICONQUESTION);
    case tmp of
      id_yes: begin
                fOpenClick(self);
              end;
      id_cancel: exit;
    end;
  end;
  for i:=2 to offset do
    (form1.FindComponent('Edit'+inttostr(i)) as Tedit).Destroy;
  Memo1.Lines.Clear;
  Form1.Canvas.Brush.Color := clBtnFace;
  Form1.Canvas.FillRect(Form1.Canvas.ClipRect);
  Edit1.Text:='';
  flag:=false;
  finished:=false;
  for i := 1 to StringGrid1.RowCount do
  begin
    Form1.StringGrid1.Cells[0,i]:='';
    Form1.StringGrid1.Cells[1,i]:='';
    Form1.StringGrid1.Cells[2,i]:='';
  end;
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
  StringGrid1.Cells[0,0]:='������';
  StringGrid1.Cells[1,0]:='�������';
  StringGrid1.Cells[2,0]:='��� ��������';
  StringGrid1.ColWidths[2]:=Canvas.TextWidth(StringGrid1.Cells[2,0])+25;
  StringGrid1.ColWidths[1]:=Canvas.TextWidth(StringGrid1.Cells[1,0])+10;
  StringGrid1.ColWidths[0]:=Canvas.TextWidth(StringGrid1.Cells[0,0])+10;
  StringGrid1.Width:=StringGrid1.ColWidths[0]+StringGrid1.ColWidths[1]+StringGrid1.ColWidths[2]+8;
  Memo1.ReadOnly:=true;
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

