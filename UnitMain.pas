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
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StringGrid2: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure fOpenClick(Sender: TObject);
    procedure fSaveClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure fNewClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
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

procedure Pause(col:integer);
var wtim:ttime;
begin
    wtim:=encodetime(0,0,col,0)+time;
    repeat
    application.processmessages;
    sleep(10);
    until time>=wtim;
end;

procedure DescriptionOfActions(c:char);
var i,j:integer;
begin
   case c of
     's': begin
          Form1.Memo1.Lines.Add('- Сортируем наш массив по частоте символов.');
          Form1.Memo1.Lines.Add(' ');
        end;
     'f': begin
          Form1.Memo1.Lines.Add('- Посчитаем частоты всех символов.');
          Form1.Memo1.Lines.Add(' ');
          end;
     'n': begin
          Form1.Memo1.Lines.Add('ПОШАГОВОЕ ОПИСАНИЕ ДЕЙСТВИЙ');
          Form1.Memo1.Lines.Add(' ');
          end;
     'm': begin
          Form1.Memo1.Lines.Add('- Создадим массив, где будем хранить узлы бинарного дерева для каждого символа.');
          Form1.Memo1.Lines.Add(' ');
          end;
     '2': begin
          Form1.Memo1.Lines.Add('- Берем последние 2 символа из массива и объединяем их в один узел. ');
          Form1.Memo1.Lines.Add('- Сложим их частоты. ');
          Form1.Memo1.Lines.Add(' ');
          end;
     't': begin
          Form1.Memo1.Lines.Add('- Cвяжем два последних элемента - получится итоговое дерево');
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

function FindLetter(letter:String):integer;
var i,j:integer;
begin
   for i := 1 to Form1.StringGrid1.RowCount-1 do
   begin
      if Form1.StringGrid1.Cells[0,i]=letter then
      begin
          result:=i;
          exit;
      end;
   end;
   result:=1;
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
var text:String;
begin
  mas[n]:=' ';
  dec(n);
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
     pause(2);
     DrawArrow(Form1.Canvas,left_x1,top_y1,left_x2,top_y2,2);
     pushMas(mas,ind,'0');
     Form1.Edit50.Text:=Form1.Edit50.Text+'0';
     Form1.Edit50.Repaint;
     //pause(2);
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
     pause(2);
     DrawArrow(Form1.Canvas,left_x1,top_y1,left_x2,top_y2,2);
     pushMas(mas,ind,'1');
     Form1.Edit50.Text:=Form1.Edit50.Text+'1';
     Form1.Edit50.Repaint;
     //pause(2);
     FindCodes(pt^.right,mas,code,ind,n);
   end;
   if length(pt^.letter)=1 then//pt^.letter<>'' then
   begin
      if length(code)=0 then
        SetLength(code,3);
      if n<length(code) then
      begin
        code[n].letter:=pt.letter;
        Form1.Edit51.Text:=code[n].letter;
        Form1.Edit51.Repaint;
        pause(1);
        for i := 0 to ind-1 do
          code[n].code:=code[n].code+mas[i];
        Form1.StringGrid1.Cells[2,FindLetter(code[n].letter)]:=code[n].code;
        Form1.StringGrid1.Repaint;
        Form1.Memo1.Lines.Add('- Cимволу "'+code[n].letter+'" соотвествует код '+code[n].code);
        inc(n);
      end
      else
        begin
          SetLength(code,length(code)*2);
          code[n].letter:=pt.letter;
          Form1.Edit51.Text:=code[n].letter;
          Form1.Edit51.Repaint;
          pause(1);
          for i := 0 to ind-1 do
            code[n].code:=code[n].code+mas[i];
          Form1.StringGrid1.Cells[2,FindLetter(code[n].letter)]:=code[n].code;
          Form1.StringGrid1.Repaint;
          Form1.Memo1.Lines.Add('- Cимволу "'+code[n].letter+'" соотвествует код '+code[n].code);
          inc(n);
        end;
   end;
   popMas(mas,ind);
   text:=Form1.Edit50.Text;
   SetLength(text,length(text)-1);
   Form1.Edit50.Text:=text;
   Form1.Edit51.Text:='';
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

procedure tableFreq(huff:Tah;size:integer);
var i,j:integer;
begin
   Form1.StringGrid2.RowCount:=size+2;
   for i := 0 to size do
   begin
      Form1.StringGrid2.Cells[0,i+1]:=huff[i].letter;
      Form1.StringGrid2.Cells[1,i+1]:=IntToStr(huff[i].freq);
   end;
end;

procedure SortingGrid(grid:TStringGrid; size:integer);
var i,j:integer; symb:String; freq:integer;
begin
   for i := size downto 1 do
        for j := 1 to i do
            if StrToInt(grid.Cells[1,j])<StrToInt(grid.Cells[1,j+1]) then
            begin
                symb:=grid.Cells[0,j];
                freq:=StrToInt(grid.Cells[1,j]);
                grid.Cells[1,j]:=grid.Cells[1,j+1];
                grid.Cells[0,j]:=grid.Cells[0,j+1];
                grid.Cells[1,j+1]:=IntToStr(freq);
                grid.Cells[0,j+1]:=symb;
            end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var text:String; ind,i,j,stackind,ncode,symbols:integer; pt:pnode; tmp:char;
begin
  text:=Edit1.text;
  UnitHuff.GenarateFreq(huff,text,ind);
  if length(huff)>20 then
  begin
    Memo1.Lines.Add('ВНИМАНИЕ: Ваш текст содержил больше 20 различных символов. Повторите попытку еще.');
    Edit1.text:='';
    exit;
  end;
  DescriptionOfActions('n');
  Form1.Memo1.Lines.Add('ПОДСКАЗКА: Для подальшего пошагового управления нажимайте кнопку "Дальше"');
  DescriptionOfActions('f');
  StringGrid1.RowCount:=length(huff)+1;
  for i := 0 to length(huff)-1 do
  begin
    StringGrid1.Cells[0,i+1]:=huff[i].letter;
    StringGrid1.Cells[1,i+1]:=IntToStr(huff[i].freq);
  end;
  size:=length(huff)-1;
  Form1.Button1.Enabled:=false;
  Form1.Button2.Enabled:=true;
  Form1.Edit1.ReadOnly:=true;
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
     SortingGrid(Form1.StringGrid1,size);
     tableFreq(huff,size);
     DescriptionOfActions('m');
     flag:=true;
     exit;
  end;
  if (size<>0) and (sorted=false) then
  begin
     BubleSorting(huff,size);
     SortingGrid(Form1.StringGrid2,size);
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
     Form1.Memo1.Lines.Add('- Берем последние 2 элемента (узла) из массива и объединяем их в один узел. ');
     Form1.Memo1.Lines.Add('  Сложим их частоты. Получилось '+IntToStr(huff[size-1].freq+huff[size].freq));
     Form1.Memo1.Lines.Add(' ');
     //p^.edit.Text:=IntToStr(huff[size-1]^.freq+huff[size]^.freq);
     //p^.edit.text := IntToStr(huff[size-1]^.freq+huff[size]^.freq);
     p^.edit.text := huff[size-1]^.edit.text+huff[size]^.edit.text;
     p^.letter:=huff[size-1]^.letter+huff[size]^.letter;
     p^.freq:=huff[size-1]^.freq+huff[size]^.freq;
     p^.left:=huff[size-1];
     p^.right:=huff[size];
     dec(size);
     inc(offset);
     huff[size]:=p;
     tableFreq(huff,size);
     //SortingGrid(Form1.StringGrid2,size);
     huff[size].edit.Text:='';
     if size=0 then
     begin
        DescriptionOfActions('t');
        Form1.Memo1.Lines.Add('- Теперь, чтобы получить код для каждого символа, надо просто пройтись по дереву, и для каждого перехода добавлять 0, если мы идём влево (красная стрелка), и 1 — если направо (синяя стрелка)');
        Form1.Memo1.Lines.Add('Загоревшаяся зеленым цветом стрелка показывает продвижение по дереву.');
        Form1.Memo1.Lines.Add('Слева синхронизировано с прохождением по дереву показано добавление 0 или 1.');
        Form1.Memo1.Lines.Add(' ');
     end;
     setChanges(size);
     sorted:=false;
  end
  else
  begin
     setChanges(size);
     Form1.Button2.Enabled:=false;
     Form1.Button3.Enabled:=false;
     stackind:=0;   //stack index
     ncode:=0;      //codes index
     pt:=huff[0];
     Form1.Canvas.Pen.Color:=clBlack;
     Form1.Canvas.Pen.Width:=2;
     Form1.Canvas.Brush.Color:=clBlack;
     DrawArrow(Form1.Canvas,143,380,159,380,2);
     FindCodes(pt,mas,code,stackind,ncode);
     sleep(500);
     Form1.Button2.Enabled:=true;
     Form1.Button3.Enabled:=true;
     Form1.Edit51.Text:='';
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
     Form1.Memo1.Lines.Add(' ');
     Form1.Memo1.Lines.Add('Поздравляю! Код Хаффмана создан. Все данные можете увидеть в таблице.');
     Form1.Button2.Default:=false;
     //Form1.Edit1.SetFocus;
     Form1.StringGrid1.SetFocus;
     Form1.Button2.Enabled:=false;
     finished:=true;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);// var huff:Tah; var size:integer);
var tmp,p:pnode; i,j:integer; edit: tedit;
begin
      //.chm -справка
  Huffman2(huff,size);
end;

procedure TForm1.Button3Click(Sender: TObject);
var tmp,i,j:integer;
begin
  if finished then
  begin
    tmp:=MessageBox(Handle,'Хотите ли вы сохранить результат в формате *.txt?','SaveDialog',MB_YESNOCANCEL+MB_ICONQUESTION);
    case tmp of
      id_yes: begin
                fSaveClick(self);
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
  Form1.Edit1.ReadOnly:=false;
  Edit50.Text:='';
  Edit51.Text:='';
  Form1.Button1.Enabled:=true;
  flag:=false;
  finished:=false;
  huff:=nil;
  code:=nil;
  for i := 1 to StringGrid1.RowCount-1 do
  begin
    Form1.StringGrid1.Cells[0,i]:='';
    Form1.StringGrid1.Cells[1,i]:='';
    Form1.StringGrid1.Cells[2,i]:='';
  end;
  StringGrid2.Cells[0,1]:='';
  StringGrid2.Cells[1,1]:='';
end;

procedure TForm1.fNewClick(Sender: TObject);
var tmp,i,j:integer;
begin
   tmp:=MessageBox(Handle,'Вы действительно хотите создать новые коды Хаффмана','New...',MB_YESNO+MB_ICONQUESTION);
    case tmp of
      id_yes: begin
                for i:=2 to offset do
                   (form1.FindComponent('Edit'+inttostr(i)) as Tedit).Destroy;
                Memo1.Lines.Clear;
                Form1.Canvas.Brush.Color := clBtnFace;
                Form1.Canvas.FillRect(Form1.Canvas.ClipRect);
                Edit1.Text:='';
                Form1.Edit1.ReadOnly:=false;
                Edit50.Text:='';
                Edit51.Text:='';
                Form1.Button1.Enabled:=true;
                flag:=false;
                finished:=false;
                huff:=nil;
                code:=nil;
                for i := 1 to StringGrid1.RowCount-1 do
                begin
                  Form1.StringGrid1.Cells[0,i]:='';
                  Form1.StringGrid1.Cells[1,i]:='';
                  Form1.StringGrid1.Cells[2,i]:='';
                end;
                StringGrid2.Cells[0,1]:='';
                StringGrid2.Cells[1,1]:='';
              end;
      id_no: exit;
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
  StringGrid2.ColCount:=2;
  StringGrid1.RowCount:=1;
  StringGrid2.RowCount:=1;
  StringGrid1.Cells[0,0]:='Символ';
  StringGrid2.Cells[0,0]:='Символ';
  StringGrid1.Cells[1,0]:='Частота';
  StringGrid2.Cells[1,0]:='Частота';
  StringGrid1.Cells[2,0]:='Код Хаффмана';
  StringGrid1.ColWidths[2]:=Canvas.TextWidth(StringGrid1.Cells[2,0])+25;
  StringGrid1.ColWidths[1]:=Canvas.TextWidth(StringGrid1.Cells[1,0])+10;
  StringGrid1.ColWidths[0]:=Canvas.TextWidth(StringGrid1.Cells[0,0])+10;
  StringGrid1.Width:=StringGrid1.ColWidths[0]+StringGrid1.ColWidths[1]+StringGrid1.ColWidths[2]+8;
  Memo1.ReadOnly:=true;
  Form1.Button2.Enabled:=false;
end;

procedure Save;
var i:integer; f:text;
begin
  AssignFile(f,fFilePath);
  Rewrite(f);
  for i := 1 to Form1.StringGrid1.RowCount do
  begin
    writeln(f,Form1.StringGrid1.Cells[0,i],' ',Form1.StringGrid1.Cells[1,i],' ',Form1.StringGrid1.Cells[2,i]);
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

procedure TForm1.N6Click(Sender: TObject);
begin
    Form1.Close;
end;

end.

