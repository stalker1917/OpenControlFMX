unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,Math, FMX.Edit, FMX.Objects, FMX.Media,
  Finance,ControlConsts,TimeManager,AiManager,OCGraph,AreaManager, BaseManager,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.ImageList, FMX.ImgList,Debug,
  FMX.ListBox
{$IFDEF ANDROID}
   ,System.IOUtils;
 {$ELSE}
 ;
 {$ENDIF}
//const
 
 {   PaintRect : TRectF  =
    (
      Left: 0;
      Top: 0;
      Right: 10;
      Bottom: 10;
    );
  HighLabels = 7; }
type


  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    StyleBook1: TStyleBook;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Panel1: TPanel;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label6: TLabel;
    Image1: TImage;
    Label8: TLabel;
    Label9: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Button16: TButton;
    MediaPlayer1: TMediaPlayer;
    Memo1: TMemo;
    Panel4: TPanel;
    Circle1: TCircle;
    Circle2: TCircle;
    Circle3: TCircle;
    Circle4: TCircle;
    Label10: TLabel;
    Label11: TLabel;
    Button3: TButton;
    Button4: TButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton21: TRadioButton;
    RadioButton22: TRadioButton;
    RadioButton23: TRadioButton;
    Label7: TLabel;
    GroupBox3: TGroupBox;
    RadioButton31: TRadioButton;
    RadioButton33: TRadioButton;
    RadioButton32: TRadioButton;
    LevL: TLabel;
    LevE: TLabel;
    Label101: TLabel;
    Label111: TLabel;
    Label102: TLabel;
    Label112: TLabel;
    Label103: TLabel;
    Label113: TLabel;
    Label104: TLabel;
    Label114: TLabel;
    Label105: TLabel;
    Label115: TLabel;
    Label106: TLabel;
    Label116: TLabel;
    RadioButton34: TRadioButton;
    RadioButton35: TRadioButton;
    RadioButton36: TRadioButton;
    Button6: TButton;
    Button7: TButton;
    ComboBox1: TComboBox;
    Edit2: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    SpeedButton1: TSpeedButton;
    ImageList1: TImageList;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Memo2: TMemo;
    procedure FormCreate(Sender: TObject);
    //procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
   // procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
    //  Shift: TShiftState; X, Y: Integer);
    procedure GroupBox2Click(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OutPutCost(const Cost :TConstRes);
    procedure OutPutBuilding(const s:String;TypeB:Integer=2);
    procedure ShutDownShape;
    procedure OutPutStandart(const s:String;TypeB:Integer=2);
    procedure OutPutMine(const s:String;TypeMine:Integer);
    procedure StartBuild(const Cost:TConstRes;const BTime:TTimeRecord; BType:byte);

    procedure ShapeRadius(N:Integer);
    procedure ShapesVisible(B:Boolean);
    procedure LeditsVisible(B:Boolean);
    procedure CLS;
    procedure ShapesPosition(Mode:Byte);
    procedure SetTAHString(AHString : TAHStrings);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Edit8MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Edit6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Edit5MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
     procedure Edit3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Edit1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);

    procedure GroupBox3Click(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Button16Click(Sender: TObject);
    procedure Circle1Click(Sender: TObject);
    procedure Circle2Click(Sender: TObject);
    procedure Circle3Click(Sender: TObject);
    procedure Circle4Click(Sender: TObject);
    procedure Panel1Paint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure Button7Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OknoTo1;
    procedure OknoTo2;
  end;






const

  TimeRazvCoef : Array[1..4] of Single=(1,0.5,0.25,0.7); //Как хорошо разведывают самолёты
var
  Form1: TForm1;
  output:Text;
  textfile : File of Char;
  God : Byte = 22;
  Nas : Integer;
  Vs : Double;
  Raspr : Array[0..999] of Integer;
  Ub :Integer;
  UbObh :Integer;
  godv : Double;
  srgod : Double;
  ndel : Double;
  ndelold :Double;
  //cl :TColor;

  //---

  area2:PAreaB;

  Teki,Tekj : Byte;
  Tekbi,Tekbj : Byte;
  Samv  : Boolean = False;
  TekSam : PSamolet;
  F2Otkl : Byte = 0;
  //Ledits : Array[1..6] of TLabeledEdit;
  Ledits : Array[0..1,1..6] of TLabel;
  Circles : Array[1..4] of TCircle;
  RadioArray : Array [1..HangarHigh] of Byte;
  RadioGroups : Array [1..HangarHigh] of TRadioButton;
  RadioArrayIndex : Byte;
  Panel1Left : Integer = BaseLeft+EtalonHeight;
  PlaneEvent : Byte; // 0- отменить полёт. 1- бомбить 2 - основать базу.  3-перехват
  LastTerrain :Byte=0;


function GetSoundPath:String;

implementation
//uses OKCANCL2;

{$R *.fmx}

procedure  CLearRadioGroups;
var i:Integer;
begin
  for I := 1 to HangarHigh do  RadioGroups[i].Visible := False;//if RadioGroups[i]<>nil then RadioGroups[i].Destroy;
end;




Function TypeSamToStr(i:Byte):String;
begin
  case i of
   1:    result := 'Разведчик';
   2:    result := 'Бомбардировщик';
   3:    result := 'Основатель базы';
  end;
end;

procedure TForm1.OutPutBuilding;
begin
  GroupBox1.Visible := False;
  Label6.Text := 'Строящийся ' + s;
  GroupBox2.Visible := False;
  //Circle1.Visible := False;
  //Circle2.Visible := False;
  //Circle3.Visible := False;
  //Shape4.Visible := False;
  ShapesVisible(False);
  Image1.Bitmap := BuildingBitmaps[Typeb];
  //Edit13.Visible := True;
  //Edit13.Text := 'Осталось до конца строительства: ' +  Int64ToEnd(area2[Teki,Tekj].TimeToPusk); //IntToStr((area2[Teki,Tekj].TimeToPusk-TimeStamp) div (24*3600)) +' д.' + IntToStr(((area2[Teki,Tekj].TimeToPusk-TimeStamp) mod (24*3600)) div 3600) + ' ч.';
end;

procedure TForm1.SetTAHString;
var i:Integer;
begin
  LevL.Text := AHString[0];
  for i:=1 to 2 do Ledits[0,i].Text := AHString[i];
  GroupBox3.Text := AHString[High(AHString)];
end;

procedure TForm1.ShapesPosition(Mode: Byte);
var i:Integer;
begin
  case Mode of
    1: for I := Low(Circles) to High(Circles) do  //Открыт экран базы
      begin
        Circles[i].Position.Y := EtalonToY(580);
        Circles[i].Position.X := EtalonToX(40*i-20); //20-60...
      end
    else for I := Low(Circles) to High(Circles) do //Стандартная позиция
      begin
        {$IFDEF ANDROID}
        Circles[i].Position.Y:= EtalonToY(392 - 31*(i mod 2)+SmallRadius/2);
        {$ELSE}
        Circles[i].Position.Y:= EtalonToY(392 - 31*(i mod 2));
        {$ENDIF}
        Circles[i].Position.X := EtalonToX(12+120*(i div 3));
      end;
  end;
end;

procedure AddRadio(var A:TRadioButton;Text:String);
begin
  A.Text := Text;
  A.Visible := True;
end;

Procedure TForm1.OknoTo1;
begin
  Okno := 1;
  Button4.Enabled := True;
  Button1.Text := 'Войти в здание';
end;

Procedure TForm1.OknoTo2;
begin
  Okno:=2;
  CLS;
  Button4.Enabled := False;
  Button1.Text := 'Выйти в базу';
end;

procedure TForm1.Button1Click(Sender: TObject);
var LenC:Integer; Buf:Char;
S:String; Spr:String;
i,j:Integer;
RealName : Boolean;
begin
Button4.Visible := True;
case Okno of

0:

begin

if Samv then //Если "Отменить полёт"
  begin
    Samv := False;
    Button1.Text := 'Войти в базу';
    case PlaneEvent of
      1: Bombing(1,TekSami,Teki,Tekj);
      2: FoundBase(1,TekSami,Teki,Tekj);
    end;
    PlaneEvent := 0;
    Invalidate;
    exit;    //И что дальше ?
  end;
if area[Teki,Tekj].areab=nil then exit; //Как-то неправильно вошли в базу , надо перезайти
Okno := 1;
Panel4.Visible := False;
Label7.Visible := False;
Label8.Visible := False;
Label9.Visible := False;
Label10.Visible := False;
Label11.Visible := False;
{Edit9.Visible := False;
Edit10.Visible := False;
Edit11.Visible := False;
Edit12.Visible := False;
Edit13.Visible := False;
}
ShapesVisible(False);
Button1.Text := 'Войти в здание';
ShapeRadius(1);
ShapesPosition(1);
//Button4.Visible := False;
//Button6.Visible := False;

TekBi := Teki;
TekBj := Tekj;
//exit;
//А почему после exit???
area2 := area[Teki,Tekj].areab;
HearthBar1.Visible := True;
//progressBar1.Visible := True;
Panel1Left := 1000;
Resize;
Invalidate;
end;
1:
//if Okno=1 then
  begin

    case area2[Teki,Tekj].plm of
    2:  //Авиазавод
      begin
        OknoTo2;
        LevE.Visible := True;
        LevL.Visible := True;
        SetTAHString(AS_AviaFactory);
        GroupBox3.Visible := True;
        CLearRadioGroups;//GroupBox3.Items.Clear;
        //TRadioButton.Create(Groupbox1);
        for I := 1 to 3 do AddRadio(RadioGroups[i],TypeSamToStr(i));//GroupBox3.Items.Add(TypeSamToStr(i));
        Button16.Visible := True;
        if area2[Teki,Tekj].Regime>0 then
          begin
           // GroupBox3.ItemIndex := area2[Teki,Tekj].Regime-1;
            RadioGroups[area2[Teki,Tekj].Regime].IsChecked := True;
            for I := 1 to 3 do RadioGroups[i].Enabled :=False;
            //GroupBox3.Enabled := False;
            LevL.Text := 'Время осталось';
            LevE.Text := TimeToBuild(Int64ToTime(area2[Teki,Tekj].TimeToPusk-TimeStamp));
            Button16.Text := 'Отменить производство';
          end
        else
         begin
           for I := 1 to 3 do RadioGroups[i].Enabled :=True;
           LeditsVisible(True);
           LevL.Text := 'Время производства';
           GroupBox3.Enabled := True;
           Button16.Text := 'Начать постройку';
           GroupBox3Click(Sender);
         end;
      end;
    3:   //Ангар
     begin
      OknoTo2;
      GroupBox3.Visible := True;
      GroupBox3.Enabled := True;
      //GroupBox3.Items.Clear;
      CLearRadioGroups;
      LevL.Visible := True;
      LevE.Visible := True;
      LevE.Text := '';
      LeditsVisible(False);
      //LabeledEdit1.Visible := True;
     //LabeledEdit2.Visible := True;
      SetTAHString(AS_Hangar);
     // i:=1;
      //while (i<6) and (area2[Teki,Tekj].Angar[i]<>nil) do
        //begin
      j := 1;
      with area2[Teki,Tekj] do
      for i := Low(Angar) to HangarHigh do
          if Angar[i]<>nil then
            begin
              //RadioGroups[j] :=
              //GroupBox3.Items.Add('Самолёт'+IntTOStr(i));
              AddRadio(RadioGroups[j],'Самолёт'+IntTOStr(i));
              RadioGroups[j].Enabled := True;
              RadioArray[j]:=i;
              inc(j);
            end;


         // inc(i);
        //end;
       //-Воостановить кнопку "вылет"
      Button16.Visible := True;
      Button16.Text := 'Вылет';
      GroupBox3Click(Sender);
     end;
     {else
       begin
         OknoTo1;
         Invalidate;
       end; }
    end;
  //  exit;
  end;
2:
  begin
    OknoTo1;
    LevE.Visible := False;
    LevL.Visible := False;
    LeditsVisible(False);
    GroupBox3.Visible := False;
    Button16.Visible := False;
    Invalidate;//Button2.Click;
  end;
end;
//Button2Click(Sender);
end;

procedure TForm1.Button5Click(Sender: TObject);  //Обновить экран.
var i,j,k,m:Integer;
R  : TRect;
begin
Invalidate;
end;

procedure TForm1.OutPutCost;
var i : Byte;
begin
  BankStructure.Fill(Cost);
  for i:=0 to HighRes+1 do Ledits[1,i+1].Text:= IntToStr(BankStructure.Data[i]);
end;

procedure TForm1.Button16Click(Sender: TObject);
var St : Int64;
i,j : Byte;
begin
case area2[Teki,Tekj].plm of
2:
  begin
    if area2[Teki,Tekj].Regime=0 then
      begin
      //case GroupBox3.ItemIndex of
      // 0:  StartBuild(C_Watcher,T_Watcher,101);
      // 1:  StartBuild(C_Bomber,T_Bomber,102);
      // 2:  StartBuild(C_Constructor,T_Constructor,103);
        if RadioGroups[1].IsChecked then StartBuild(C_Watcher,T_Watcher,101);
        if RadioGroups[2].IsChecked then StartBuild(C_Bomber,T_Bomber,102);
        if RadioGroups[3].IsChecked then StartBuild(C_Constructor,T_Constructor,103);
      end
  else area2[Teki,Tekj].Regime := 0;
  Button1Click(Sender);
end;
3:  //Выпускаем самолёт на задание.
begin
 //i := RadioArray[GroupBox3.ItemIndex+1];
 i:=0;
 for j := 1 to 6 do
   if RadioGroups[j].IsChecked then  i := RadioArray[j];
 if i=0 then exit;


 if area2[Teki,Tekj].Angar[i]<>nil then
   begin
     PlaneToSky(BankofBases[1].Data[BankofBases[1].FindBase(area2)],area2[Teki,Tekj].Angar[i]);
     Okno := 1;
     Button1Click(Sender);
   end;

end;
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Memo1.Visible := not Memo1.Visible;
  if Memo1.Visible  then
  begin
     Button3.Text := 'Скрыть лог';
     Memo1.Repaint;
  end
  else
  begin
    Button3.Text:= 'Показать лог';
    invalidate;//Button2.Click;
  end;

  {if not Memo1.Visible then}
end;

procedure TForm1.Button4Click(Sender: TObject);

begin
 Okno := 0;
 {Edit9.Visible := true;
 Edit10.Visible := true;
 Edit11.Visible := true;
 Edit12.Visible := true;
 Edit13.Visible := true;}
 Label7.Visible := True;
 Label8.Visible := True;
 Label9.Visible := True;
 Label10.Visible := True;
 Label11.Visible := True;
 Button1.Text :='Войти в базу';
 //CLS;

 //Button2Click(Sender);
 Button4.Visible := True;
 //Button6.Visible := True;
 ShapeRadius(0);
 ShapesPosition(0);
 ShapesVisible(True);
 GroupBox1.Visible := False;
 GroupBox2.Visible := False;
 Teki := TekBi;
 Tekj := TekBj;
 //ProgressBar1.Visible := False;
 HearthBar1.Visible := False;
 Panel4.Visible := True;
 Panel1Left := EtalonHeight+BaseLeft;
 Button4.Visible := False;
 Label12.Visible :=False;
 Label13.Visible := False;
 Label14.Visible := False;
 Image1.Bitmap := AreaBitmaps[LastTerrain];
 Resize;
 Invalidate;
end;

procedure TForm1.Circle1Click(Sender: TObject);
begin
  if Okno=1 then ShapeRadius(1);
end;

procedure TForm1.Circle2Click(Sender: TObject);
begin
  if Okno=1 then ShapeRadius(2);
end;

procedure TForm1.Circle3Click(Sender: TObject);
begin
  if Okno=1 then ShapeRadius(3);
end;

procedure TForm1.Circle4Click(Sender: TObject);
begin
  if Okno=1 then ShapeRadius(4);
end;

procedure TForm1.CLS; //Oчистка экрана.
var
r:TRect;
begin
 //R.Top := 0;
 //R.Bottom := ClientHeight;
 //R.Left := 0;
 //R.Right := ClientWidth;
 //Form1.Canvas.FillRect(R);
  Canvas.BeginScene();
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := TAlphaColorRec.Seagreen;

  Canvas.FillPolygon([TPointF.Create(0, 0),
                      TPointF.Create(EtalontoX(1000), 0),
                      TPointF.Create(EtalontoX(1000), ClientHeight),
                      TPointF.Create(0, ClientHeight)], 1);
 Canvas.EndScene;
end;

procedure TForm1.Button6Click(Sender: TObject);
var S:String;
begin
  //Form2.ShowModal;
  //if F2Otkl = 1 then Close;
  S:=GetDebugPath+'/'+Edit2.Text+'.sav';
  SaveFile(S);
end;




procedure TForm1.Button7Click(Sender: TObject);
var S:String;
begin
  if (ComboBox1.ItemIndex>-1) and (ComboBox1.Items[ComboBox1.ItemIndex]<>'') then
    begin
      S:=GetDebugPath+'/'+ComboBox1.Items[ComboBox1.ItemIndex]+'.sav';
      LoadFile(S);
      Invalidate;
    end;
end;

procedure TForm1.Edit1MouseUp;
begin
  if Button = TMouseButton.mbRight then AddTime(3600*10,True);
  if Button = TMouseButton.mbLeft  then AddTime(3600*10,False);
  //Form1.Button2Click(Form1);
  Invalidate;
end;

procedure TForm1.Edit3MouseUp;
//var B:Boolean;
begin
 if Button = TMouseButton.mbRight then AddTime(3600,True);
 if Button = TMouseButton.mbLeft  then AddTime(3600,False);
//Form1.Button2Click(Form1);
 Invalidate;
end;



procedure TForm1.Edit5MouseUp;
//var B:Boolean;
begin
 if Button = TMouseButton.mbRight then AddTime(600,True);
 if Button = TMouseButton.mbLeft  then AddTime(600,False);
//Form1.Button2Click(Form1);
 Invalidate;
end;





procedure TForm1.Edit6MouseUp;
//var B:Boolean;
begin
 if Button = TMouseButton.mbRight then AddTime(60,True);
 if Button = TMouseButton.mbLeft  then AddTime(60,False);
//Form1.Button2Click(Form1);
 Invalidate;
end;



procedure TForm1.Edit8MouseUp;
//var B:Boolean;
begin
 if Button = TMouseButton.mbRight then AddTime(10,True);
 if Button = TMouseButton.mbLeft  then AddTime(10,False);
//Form1.Button2Click(Form1);
 Invalidate;
end;




procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var i,j,k,m:integer;
begin
  for I := 1 to 15 do
   for j := 1 to 15 do
     if area[i,j].areab<>nil then Dispose(area[i,j].areab);
end;

procedure RadioCreate(Owner:TComponent;Visible:Boolean;I:Integer);
begin
  RadioGroups[i] := TRadioButton.Create(Owner);
  RadioGroups[i].Visible := Visible;
  RadioGroups[i].Position.Y := EtalonToY(23+i*31);
end;


procedure TForm1.FormCreate(Sender: TObject);
var
i,j,k,m,l:integer;
col:Tcolor;
SearchRec: TSearchRec;
begin
  //FormResize(Sender);
  HearthBar1 := THearthBar.Create(Canvas);
  LogFile.Init(false,true,GetDebugPath+'/Log');
  Okno := 0;
  Randomize;
  Ledits[0,1] := Label101;
  Ledits[0,2] := Label102;
  Ledits[0,3] := Label103;
  Ledits[0,4] := Label104;
  Ledits[0,5] := Label105;
  Ledits[0,6] := Label106;
  Ledits[1,1] := Label111;
  Ledits[1,2] := Label112;
  Ledits[1,3] := Label113;
  Ledits[1,4] := Label114;
  Ledits[1,5] := Label115;
  Ledits[1,6] := Label116;
  RadioGroups[1] := RadioButton31;
  RadioGroups[2] := RadioButton32;
  RadioGroups[3] := RadioButton33;
  RadioGroups[4] := RadioButton34;
  RadioGroups[5] := RadioButton35;
  RadioGroups[6] := RadioButton36;
  Circles[1] := Circle1;
  Circles[2] := Circle2;
  Circles[3] := Circle3;
  Circles[4] := Circle4;
  GroupBox3.Visible := False;
  //for I := 1 to HangarHigh do RadioCreate(GroupBox3,False,i);
 //   begin
 //   end;

  for I := 1 to LArea do
   for j := 1 to LArea do
    begin
        area[i,j].clr := 0;//$00FF00;
        area[i,j].plm := 0;
        for k := 1 to 4 do area[i,j].Res[k] := Random({Round(10000/k)}C_Maximum[k]);
        area[i,j].areab := Nil;
        for k:=1 to NPlayers do area[i,j].Timerasv[k] :=0;
        area[i,j].Regeneration := True;
   end;
   GenerateTerrain;
  for I := 1 to LArea do
   for j := 1 to LArea do
     if  area[i,j].clr=255 then //ColorToAlpha($FFFF00) then
       for k := 1 to 4 do area[i,j].Res[k] := 0;

  for i:=1 to NPlayers do
   begin
    repeat
    j:=random(LArea)+1;
    k:=random(LArea)+1;
    col:= 0//PlanesCols[i];  //random($ffffff);
    until (area[j,k].plm=0) and (area[j,k].clr<>{ColorToAlpha($FFFF00)}255);
    Plems[i] := col;
    BankofBases[i].NewBase(j,k,i,False);
    if I=1 then   area2 := area[j,k].areaB;
   end;
   LogFile.WriteToLog('Terrain init completed');
    InitBitmaps;
   LogFile.WriteToLog('Bitmaps init completed');
    LoadTerrain;
   LogFile.WriteToLog('Load terrain bitmap completed');
   TimeStamp := 0;

   //Dengi := 40000;
   //Установка финансов
   for i := 1 to NPlayers do
     begin
       Banks[i].Reset;
       if i>0 then Banks[i].SetWarPercent(20+Random(10)); //Воинственность, сколько кладём в военный бюджет.
       Banks[i].AddResource(0,40000); //Каждому по 40 000 кредитов
     end;
   LogMemo := Memo1;
   //Cюда же установить процент военных расходов

   OldStamp := TimeStamp;
   //SolveStamp := TimeStamp;
   MainBmp:=TBitmap.Create;
   MainBmp.Height := 1000;
   MainBmp.Width := 1000;
   for i := 1 to NPlayers do
     begin
       BankofTrigers[i] := TAITriggers.Create(i);
       if i>1 then BankofTrigers[i].AiTurn;
     end;
   LoadAreaBitmaps;
   LogFile.WriteToLog('Load area bitmaps completed');
   Button4.OnClick(Self);
   LogFile.WriteToLog('Main map initialized');
   //---Поиск файлов
   Combobox1.Clear;
   if FindFirst(GetDebugPath+'/*.sav', faAnyFile, SearchRec) = 0 then
     begin
       Combobox1.Items.Add(Copy(SearchRec.Name,0,Length(SearchRec.Name)-4));
       while FindNext(SearchRec) = 0  do Combobox1.Items.Add(Copy(SearchRec.Name,0,Length(SearchRec.Name)-4));
     end;
  
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
{$IFNDEF ANDROID}
  if KeyChar='c' then CheatMode := not CheatMode;
{$ENDIF}
end;

procedure TForm1.ShutDownShape;
begin
  ShapesVisible(False);
  //Edit13.Visible := False;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  //Memo2.Visible := not Memo2.Visible;
end;

procedure TForm1.SpeedButton1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  Memo2.Visible := not Memo2.Visible;
end;

procedure TForm1.OutPutStandart;
begin
  GroupBox1.Visible := False;
  Label6.Text := S;
  GroupBox2.Visible := False;
  ShutDownShape;
  Image1.Bitmap := BuildingBitmaps[Typeb];
end;



procedure TForm1.Panel1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  //HearthBar1.Repaint;
end;

procedure TForm1.OutPutMine;
var i:Integer;
begin
  GroupBox1.Visible := True;
  //RadioGroup1.ItemIndex := area2[Teki,Tekj].Regime;

  RadioButton11.Text := 'Добыча равна регенерации';
  RadioButton12.Text := 'Максимальная добыча';
  if area2[Teki,Tekj].Regime=0 then RadioButton11.IsChecked := True
                               else RadioButton12.IsChecked := True;

  Label6.Text := S;
  i := BankofBases[1].FindBase(area2); //Работает только для игрока
  Label12.Visible := True;
  Label13.Visible := True;
  Label14.Visible := True;
  Label12.Text := 'Добыча: ';
  Label13.Text := 'Текущая: '+IntToStr(BankofBases[1].Data[i].Miners[TypeMine])+'/'+IntToStr(GetRegen(BankofBases[1].Data[i].X,BankofBases[1].Data[i].Y,TypeMine));
  Label14.Text := 'Будущая: '+IntToStr(BankofBases[1].Data[i].NMiners[TypeMine]*BaseMine)+'/'+IntToStr(GetRegen(BankofBases[1].Data[i].X,BankofBases[1].Data[i].Y,TypeMine));
  GroupBox2.Visible := False;
  ShutDownShape;
  Image1.Bitmap := BuildingBitmaps[1];
end;

procedure TForm1.StartBuild;
var i:Integer;
begin
  i := BankofBases[1].FindBase(area2);
  BankofTrigers[1].Build(BankofBases[1].Data[i],Cost,Btime,Btype,Teki,Tekj);
  Label1.Text := IntToStr(Banks[1].CheckRegime(0,5));
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
  var Bufi,Bufj:Byte;
  i:SmallInt;
begin
 if (XtoEtalon(X)<1031) and (YtoEtalon(Y)<1001)  then
  begin
    Bufi := Teki;
    Bufj := Tekj;
    PlaneEvent := 0; // Отменяем полёт самолёта по умолчанию.
    HearthBar1.Visible := False;

    case okno  of

    0:
    begin
      Teki:=XToSec(X);//PixelsToSec(X);
      Tekj:=YToSec(Y);//PixelsToSec(Y);
      Label7.Text := 'Квадрат '+ XYTOStr(Teki,Tekj); //chr(ord('a')+Tekj) + IntToStr(Teki);
      if Samv then with TekSam^ do
        begin
           Samv:=False;
           //Здесь прописать висение
           Button1.Text := 'Войти в базу';
           SetFlyEvent(1,XToCoord(X),YToCoord(Y),TekSami);
          // if (TekSam.Stype=3) and (area[Event.X,Event.Y].plm=0) and (area[Event.X,Event.Y].Timerasv[1]>=TimeToBase)  then     //ecли основатель и базу можно основать
            //begin
               //Может по другому реализовать
              //OKRightDlg.ShowModal;
              //if OkResult then Bombs:=1   //1 -приказ основать базу.
                         // else Bombs:=0;
           // end;

          exit;
        end;
      for I := Length(Samolets)-1 downto 0 do
      if Samolets[i]<>nil then
        begin
          //if (abs(Samolets[i].CoordX/SectorDlinna*50-X)<10) and ((abs(Samolets[i].CoordY/SectorDlinna*50-Y))<10) and (Samolets[i].plm=1) then
          if (abs(Samolets[i].CoordX-XToCoord(X))<200)  and ((abs(Samolets[i].CoordY-YToCoord(Y)))<200) and (Samolets[i].plm=1) then
            begin
              Label8.Text := TypeSamToStr(Samolets[i].Stype);
              Label9.Text := IntToStr(Samolets[i].Toplivo);
              Label10.Text := IntToStr(Samolets[i].HitPoints);
              Label11.Text := IntToStr(Samolets[i].Bombs);
              //Здесь выбрать "бомбардировка" и "основание базы"
              Samv := True;
              Button1.Text := 'Отменить полёт';
              Button1.Enabled := True;
              TekSam := Samolets[i];
              TekSami := i;
              //Не нужно. Бомбардировка идёт автоматически
              {
                if (TekSam.Stype=2) and (area[Event.X,Event.Y].plm>1) and (area[Event.X,Event.Y].Timerasv[1]>=TimeToBase) then
                begin
                  PlaneEvent := 1; //Основать базу
                  Button1.Text := 'Бомбить';
                end;
               }
              if (TekSam.Stype=3) and (area[Teki,Tekj].plm=0) and (area[Teki,Tekj].Timerasv[1]>=TimeToBase) then
                begin
                  PlaneEvent := 2; //Основать базу
                  Button1.Text := 'Основать базу';
                end;
              exit;
            end;
        end;


    //Image1.Picture := nil;

    case GetType(Teki,Tekj) of
      0:  LastTerrain := 1;//Image1.Bitmap := AreaBitmaps[1];//Полная суша//Imagelist1.GetBitmap(1,Image1.Picture.Bitmap);
      9:  LastTerrain := 2;//Image1.Bitmap := AreaBitmaps[2];//Вода //Imagelist1.GetBitmap(2,Image1.Picture.Bitmap);
      else LastTerrain := 0;//Image1.Bitmap := AreaBitmaps[0];//Берег//Imagelist1.GetBitmap(0,Image1.Picture.Bitmap);
    end;
    Image1.Bitmap := AreaBitmaps[LastTerrain];
    if area[Teki,Tekj].plm=1 then
      begin

        Label6.Text := 'Ваша база';
        Label8.Text := IntToStr(area[Teki,Tekj].Res[1]);
        Label9.Text :=  IntToStr(area[Teki,Tekj].Res[2]);
        Label11.Text :=  IntToStr(area[Teki,Tekj].Res[3]);
        Label10.Text :=  IntToStr(area[Teki,Tekj].Res[4]);
        Button1.Enabled := True;
        HearthBar1.Visible := True;
        HearthBar1.Hearth := Round(100*area[Teki,Tekj].areab[12,12].HitPoints/H_Main);
      end
    else
      begin
        if (area[Teki,Tekj].Timerasv[1]>TimeToBase) or (CheatMode) then
          if area[Teki,Tekj].plm=0 then  Label6.Text := 'Нет базы'
          else
            begin
             Label6.Text := 'Вражеская база';
             HearthBar1.Visible := True;
             HearthBar1.Hearth := Round(100*area[Teki,Tekj].areab[12,12].HitPoints/H_Main);
            end
        else Label6.Text := 'Нет информации';
        if (area[Teki,Tekj].Timerasv[1]>TimeToResources) or (CheatMode)  then
          begin
           Label8.Text := IntToStr(area[Teki,Tekj].Res[1]);
           Label9.Text :=  IntToStr(area[Teki,Tekj].Res[2]);
           Label11.Text :=  IntToStr(area[Teki,Tekj].Res[3]);
           Label10.Text :=  IntToStr(area[Teki,Tekj].Res[4]);
          end
        else
          begin
            Label8.Text := 'Неизвестно';
            Label9.Text :=  'Неизвестно';
            Label11.Text :=  'Неизвестно';
            Label10.Text :=  'Неизвестно';
            Button1.Enabled := False;
          end;
       if (CheatMode  and (area[Teki,Tekj].plm>0)) or  Samv then Button1.Enabled := True
                                                            else Button1.Enabled := False;
      end;
      if Samv then Button1.Text := 'Отменить полёт'
              else Button1.Text := 'Войти в базу';
      Invalidate;
    end;
     1:
       begin
         Teki:=(XtoEtalon(X)-1) div 40 +1;  //Преобразование экранных координат в расположение базы
         Tekj:=(YtoEtalon(Y)-1) div 40 +1;
         Label12.Visible := False;
         Label13.Visible := False;
         Label14.Visible := False;
         case area2[Teki,Tekj].plm of
           0:
             begin
               if (GroupBox2.Visible= True) and (RadioButton12.isChecked) then //RadioGroup1.ItemIndex=1) then
                 begin
                   //case GroupBox2.ItemIndex of
                     if RadioButton21.IsChecked then  StartBuild(C_AviaFactory,T_AviaFactory,2);
                     if RadioButton22.IsChecked then  StartBuild(C_Hangar,T_Hangar,3);
                     if RadioButton23.IsChecked then
                          for i := 1 to 4 do
                            if Circles[i].Height>SmallRadius then StartBuild(C_Mine,T_Mine,i+3);
                   //end;
                   Teki := Bufi;
                   Tekj := Bufj;
                   //Button2.Click;
                   //Invalidate;
                 end
               else
                 begin
                   GroupBox1.Visible := False;
                   GroupBox2.Visible := False;
                   Label6.Text := '';
                 end;
               Image1.Bitmap := AreaBitmaps[LastTerrain];
             end;
           1:
             begin
               GroupBox1.Visible := True;
               //GroupBox1.ItemIndex := 0;
               RadioButton11.IsChecked := True;
               RadioButton11.Text := 'Модернизация';
               RadioButton12.Text:= 'Строительство';
               Label6.Text := 'Штаб';
               GroupBox2.Visible := True;
              // GroupBox2.ItemIndex := area2[Teki,Tekj].Regime;
               case area2[Teki,Tekj].Regime of
                  0: RadioButton21.IsChecked := True;
                  1: RadioButton22.IsChecked := True;
                  2: RadioButton23.IsChecked := True;
               end;
               ShutDownShape;
               HearthBar1.Visible := True;
               HearthBar1.Hearth := Round(100*area2[Teki,Tekj].HitPoints/H_Main);
               Image1.Bitmap := BuildingBitmaps[0];
               //Здесь будет свой компонент
              // ProgressBar1.BarColor := clGreen;  //clBlue;
              // ProgressBar1.Position := Round(100*area2[Teki,Tekj].HitPoints/H_Main);
             //  if ProgressBar1.Position<67  then   ProgressBar1.BarColor := clYellow;
              // if ProgressBar1.Position<34  then   ProgressBar1.BarColor := clRed;
             end;
           2: OutPutStandart(S_AviaFactory,2);
           3: OutPutStandart(S_Hangar,3);
           4: OutPutMine(S_BMine,1);
           5: OutPutMine(S_GMine,2);
           6: OutPutMine(S_RMine,3);
           7: OutPutMine(S_VMine,4);
           130: OutPutBuilding(S_AviaFactory,2);
           131: OutPutBuilding(S_Hangar,3);
           132: OutPutBuilding(S_BMine,1);
           133: OutPutBuilding(S_GMine,1);
           134: OutPutBuilding(S_RMine,1);
           135: OutPutBuilding(S_VMine,1);
         end;
         Invalidate;
       end;
    end;
  end;
end;




procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var r1,r2,r3 :TRectF;
begin

R1.Left:=0;
R1.Right := 1000-1;
R1.Top := 0;
R1.Bottom := 800-1;
R2 := R1;
R2.Right:= EtalontoX(R1.Right);
R2.Bottom := EtalontoY(R1.Bottom);
case okno of
  0:
  begin
    Render;
    R1.Right := 800-1;
    R2.Left:=EtalontoX(BaseLeft);
    R2.Right := EtalontoX(BaseLeft+800);
  end;
  1: RenderBase(area2);
  2: Exit; // Выходим из окна
end;

R3.Left:=300;
R3.Right := 500;
R3.Top := 200;
R3.Bottom := 300;
Label1.Text := IntToStr(Banks[1].CheckRegime(0,5));

if (not Memo1.Visible) and  (not Memo2.Visible) then
begin
Canvas.BeginScene();
//Form1.Canvas.CopyRect(R,MainBmp.Canvas,R);
Canvas.DrawBitmap(MainBmp,r1,r2,1,False);
HearthBar1.Left := XToEtalon(Panel1.Position.X)+12;
HearthBar1.Repaint;
//Canvas.FillText(R3,'Вася пупкин лох',false,1,[TFillTextFlag.RightToLeft], TTextAlign.Center, TTextAlign.Center);
//Canvas.FillText(
Canvas.EndScene();

end;

//if Memo1.Visible then Memo1.Repaint;

end;

procedure TForm1.FormResize(Sender: TObject);
const LAlignTimer=80;
begin
   if ClientWidth>ClientHeight then
     begin
       _ClientWidth := ClientWidth;
       _ClientHeight := ClientHeight;
     end
   else
     begin
       _ClientWidth := ClientHeight;
       _ClientHeight := ClientWidth;
     end;
   Panel4.Width := EtalonToX(BaseLeft);
   Panel4.Height := EtalonToY(EtalonHeight);
   Panel1.Position.X := EtalonToX(Panel1Left);
   Panel1.Height := EtalonToY(EtalonHeight);
   Panel1.Width := EtalonToX(EtalonWidth-Panel1Left);
   Image1.Position.Y := EtalonToY(112);
   Image1.Width := EtalonToX(234);
   Image1.Height := EtalonToY(225);

   GroupBox1.Position.Y := EtalonToY(361);
   GroupBox2.Position.Y := EtalonToY(464);

   Label2.Position.Y := EtalonToY(59);
   Label1.Position.Y := EtalonToY(59);

   ShapeRadius(Okno);
   ShapesPosition(Okno);

   //   Labels[j].Width := Round(SmallFont*0.6*Length(Labels[j].Text));
   //     Labels[j].Position.X :=  {FLImages[j+1].Left}360  - Round(SmallFont*0.25*Length(Labels[j].Text));

   {$IFDEF ANDROID}
   Label3.Position.X := Panel1.Width/2 - (Label3.TextSettings.Font.Size*0.25*Length(Label3.Text));
   //Поставить в SetPosition
   Button4.Position.Y := EtalonToY(620);
   Button1.Position.Y := EtalonToY(685);
   Button1.Position.X := EtalonToX(72);
   Button4.Position.X := EtalonToX(72);
   Button1.Height := EtalonToY(44);
   Button4.Height := EtalonToY(44);
   Label6.TextSettings.Font.Size := 12;
   Label7.TextSettings.Font.Size := 12;
   SpeedButton1.Position.X := EtalonToX(10);
   SpeedButton4.Position.X := EtalonToX(10);
   SpeedButton2.Position.X := EtalonToX(10)+Panel4.Width/2;
   SpeedButton3.Position.X := EtalonToX(10)+Panel4.Width/2;
   Edit1.Position.X := EtalonToX(20)+EtalonToX(LAlignTimer);
   Edit3.Position.X := EtalonToX(32)+EtalonToX(LAlignTimer);
   Edit4.Position.X := EtalonToX(47)+EtalonToX(LAlignTimer);
   Edit5.Position.X := EtalonToX(56)+EtalonToX(LAlignTimer);
   Edit6.Position.X := EtalonToX(68)+EtalonToX(LAlignTimer);
   Edit7.Position.X := EtalonToX(83)+EtalonToX(LAlignTimer);
   Edit8.Position.X := EtalonToX(92)+EtalonToX(LAlignTimer);
   Edit9.Position.X := EtalonToX(104)+EtalonToX(LAlignTimer);
   SpeedButton1.Width := Panel4.Width/3;
   SpeedButton2.Width := Panel4.Width/3;
   SpeedButton3.Width := Panel4.Width/3;
   SpeedButton4.Width := Panel4.Width/3;
   SpeedButton1.Height := Panel4.Width/3;
   SpeedButton2.Height := Panel4.Width/3;
   SpeedButton3.Height := Panel4.Width/3;
   SpeedButton4.Height := Panel4.Width/3;
   Label8.Position.Y := EtalonToY(361);//-SmallRadius);
   Label9.Position.Y := EtalonToY(392);//-SmallRadius);
   Label10.Position.Y := EtalonToY(361);//-SmallRadius);
   Label11.Position.Y := EtalonToY(392);//-SmallRadius);
   Label8.Position.X := EtalonToX(30);
   Label9.Position.X := EtalonToX(30);
   Label10.Position.X := EtalonToX(30)+Panel1.Width/2;
   Label11.Position.X := EtalonToX(30)+Panel1.Width/2;
   RadioButton11.TextSettings.Font.Size := 10;
   RadioButton12.TextSettings.Font.Size := 10;
   RadioButton21.TextSettings.Font.Size := 10;
   RadioButton22.TextSettings.Font.Size:= 10;
   RadioButton23.TextSettings.Font.Size := 10;
   GroupBox1.TextSettings.Font.Size := 10;
   GroupBox2.TextSettings.Font.Size := 10;
   RadioButton11.Position.Y := EtalonToY(23);
   RadioButton12.Position.Y := EtalonToY(23);
   {$ENDIF}
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin
  if area2[Teki,Tekj].plm=1 then GroupBox2Click(Sender);
end;



procedure TForm1.GroupBox2Click(Sender: TObject);
begin
   if (RadioButton23.IsChecked) and (RadioButton12.IsChecked) then ShapesVisible(True)
                                                              else ShapesVisible(False);

end;

procedure TForm1.ShapesVisible;
var i:Integer;
begin
  for i:=Low(Circles) to High(Circles) do Circles[i].Visible := B;
end;

procedure TForm1.LeditsVisible;
var i,j:Integer;
begin
 for j := Low(Ledits) to High(Ledits) do
  for I := Low(Ledits[j]) to High(Ledits[j]) do
    Ledits[j,i].Visible := B;
end;

procedure TForm1.GroupBox3Click(Sender: TObject);
var i,j:Integer;
begin
  case area2[Teki,Tekj].plm of
  2:
   begin
   //case GroupBox3.ItemIndex of
    if RadioGroups[1].IsChecked then //0:
     begin
      LevE.Text := TimeToBuild(T_Watcher);
      OutPutCost(C_Watcher);
     end;
    if RadioGroups[2].IsChecked then
     begin
       LevE.Text := TimeToBuild(T_Bomber);  //'1 д. 1 ч.';
       OutPutCost(C_Bomber);
     end;
     if RadioGroups[3].IsChecked then
     begin
       LevE.Text := TimeToBuild(T_Constructor);//'1 д. 4 ч.';
       OutPutCost(C_Constructor);
     end;
   end;
    //Может тут Else?
   3:
      begin
        for j := 1 to 6 do
          if RadioGroups[j].IsChecked then  i := RadioArray[j];//GroupBox3.ItemIndex+1];
        if area2[Teki,Tekj].Angar[i]<>nil then
          begin
            LevE.Text := TypeSamToStr(area2[Teki,Tekj].Angar[i].Stype);
            Label111.Text := IntToStr(area2[Teki,Tekj].Angar[i].HitPoints);
            Label112.Text := IntToStr(area2[Teki,Tekj].Angar[i].Toplivo);
          end;
      end;
   end;
//Lev.Repaint;
end;

procedure TForm1.ShapeRadius;
var i:Integer;
begin
  for i:=1 to 4 do
    begin
       Circles[i].Height := EtalonToY(SmallRadius);
       Circles[i].Width  := EtalonToY(SmallRadius);
    end;
  if N>0 then
    begin
     Circles[N].Height := EtalonToY(BigRadius);
     Circles[N].Width  := EtalonToY(BigRadius);
    end;
end;


procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Okno=1 then ShapeRadius(1);
end;

procedure TForm1.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if Okno=1 then ShapeRadius(2);
end;

procedure TForm1.Shape3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Okno=1 then ShapeRadius(3);
end;

procedure TForm1.Shape4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Okno=1 then ShapeRadius(4);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
A:TTimeRecord;
i : word;
begin
  AddTime(1,True);//Inc(TimeStamp);
  A:= Int64ToTIme(TimeStamp);  //Обязательно прибавляем время.
  //TimeGO?
  Edit1.Text := IntToStr(A.Hours div 10);
  Edit3.Text := IntToStr(A.Hours mod 10);
  Edit5.Text := IntToStr(A.Minutes div 10);
  Edit6.Text := IntToStr(A.Minutes mod 10);
  Edit8.Text := IntToStr(A.Seconds div 10);
  Edit9.Text := IntToStr(A.Seconds mod 10);
  Label3.Text := 'День ' + IntToStr(A.Days);
  {$IFNDEF ANDROID}
  if //((MediaPlayer1.Mode in [mpPlaying, mpStopped]) and
     //(MediaPlayer1.Position = MediaPlayer1.Length)) or (MediaPlayer1.Mode>mpOpen {in [mpNotReady]}) then
     (MediaPlayer1.State <> TMediaState.Playing) then
    begin
      i:=Random(13)+1;
      MediaPlayer1.FileName := GetSoundPath+'/base'+inttostr(i)+'.mp3';//GetCurrentdir+'\Sounds\base'+inttostr(i)+'.mp3';
      //MediaPlayer1.Open;
      MediaPlayer1.Play;
    end;
  {$ENDIF}
end;

function GetSoundPath;
begin
{$IFDEF ANDROID}
  result := TPath.GetDocumentsPath+'/Sounds';  //assets/internal   //GetPublicPath -> assets
{$ELSE}
  result := './Sounds';
{$ENDIF}
end;



end.


