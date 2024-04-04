// By Stalker1917  LGPL 3.0
Unit OCGraph;

interface
uses AreaManager,ControlConsts,{Graphics,VCL.Imaging.pngimage,}SysUtils,Types,FMX.Graphics, FMX.StdCtrls,System.UITypes,System.IOUtils;

const 
 TerrainsTypes = 9;
 EtalonWidth = 1280;
 EtalonHeight = 800;
 BaseLeft = 230;
 GeneratePercent = 35;//40;

type
  THearthBar = class (TObject)
  StateBMP : Array[0..2] of TBitmap;
  Owner : TCanvas;
  Visible : Boolean;
  Hearth : Byte;
  Left : Integer;
  constructor Create(_Owner:TCanvas);
  destructor Destroy;
  procedure Repaint;
  end;


var
Terrain,Ground,MainBmp : TBitmap;
Img_Ground : TBitmap;//TPNGImage;
Img_Build : Array [0..NBuildings]  of TBitmap;
Img_Bases : Array[1..NPlayers] of TBitmap;//TPNGImage;
Img_Planes : Array[1..NPlayers,1..3] of TBitmap;   //По типам самолётов
Img_Terrain : Array[0..TerrainsTypes] of TBitmap;//TPNGImage;
PlanesCols : Array [1..NPlayers] of LongWord = ($FFFF0000,$FF0000FF,$FF00FF00,$FFFFFF00,$FFFFFFFF,$FF000000,$FF808080);
//Первое FF это нет прозрачности.
AreaBitmaps : Array[0..2] of TBitmap;
BuildingBitmaps : Array[0..3] of TBitmap;  //0-штаб 1 -шахта 2- авиазавод 3-ангар.
InBuildingBitmaps : Array[0..3] of TBitmap;
_ClientWidth : Integer = 1280;
_ClientHeight : Integer =  800;
HearthBar1 : THearthBar;


procedure InitBitmaps;
procedure LoadTerrain;
procedure Render;
procedure RenderBase(area2:PAreab);
procedure GenerateTerrain;
procedure DrawToBmp(const Dst,Src:TBitmap ; X,Y:Integer);
procedure BitmapToBitmap(const Dst,Src:TBitmap);
procedure Tranparent(const B:Tbitmap; Red,Green,Blue,Tolerance:Byte);
function  SecToPixels(N:Integer):Integer;
function  SecToGround(N:Integer):Integer;
function  CoordToPixels(N:Integer):Integer;
function  PixelsToSec(N:Integer):Integer;
function  PixelsToCoord(N:Integer):Integer;
function  GetType(i,j:Byte):Byte;
function  IsWater(i,j:byte):Boolean;
function  ColorToAlpha(A:Integer):TAlphaColor;
function  BitmapToRect(const B:TBitmap):TRect;
procedure LoadAreaBitmaps;
function EtalonToX(X:Double):Double;
function EtalonToY(Y:Double):Double;
function XToEtalon(X:Single):Integer;
function YToEtalon(Y:Single):Integer;
function XToSec(X:Single):Integer;
function YToSec(Y:Single):Integer;
function XToCoord(X:Single):Integer;
function YToCoord(Y:Single):Integer;
function GetImagesPath():String;



implementation
procedure LoadAreaBitmaps;
var i:Integer;
begin
  for I := 0 to 2 do AreaBitmaps[i] := TBitmap.Create;
  AreaBitmaps[0].LoadFromFile(GetImagesPath+'/coast.jpg');
  AreaBitmaps[1].LoadFromFile(GetImagesPath+'/land.jpg');
  AreaBitmaps[2].LoadFromFile(GetImagesPath+'/ocean.jpg');
  for I := 0 to 3 do BuildingBitmaps[i] := TBitmap.Create;
  BuildingBitmaps[0].LoadFromFile(GetImagesPath+'/mainbase.jpg');
  BuildingBitmaps[1].LoadFromFile(GetImagesPath+'/mine.jpg');
  BuildingBitmaps[2].LoadFromFile(GetImagesPath+'/avia.jpg');
  BuildingBitmaps[3].LoadFromFile(GetImagesPath+'/hangar.jpg');
  for I := 0 to 3 do InBuildingBitmaps[i] := TBitmap.Create;
  InBuildingBitmaps[2].LoadFromFile(GetImagesPath+'/avia_in.png');
  InBuildingBitmaps[3].LoadFromFile(GetImagesPath+'/hangar_in.png');
end;

function GetColor(var BD: TBitmapData;Component :integer; x:Integer;y:Integer):Byte;
var A,i:LongWord;
begin
  A:= BD.GetPixel(x,y);
  for i := 1 to Component do
    A:= A div $100;
  result := A mod $100;
end;

function GetRed(var BD: TBitmapData; x:Integer;y:Integer):Byte;
begin
  result :=GetColor(BD,2,x,y);
end;

function GetGreen(var BD: TBitmapData; x:Integer;y:Integer):Byte;
begin
  result :=GetColor(BD,1,x,y);
end;

function GetBlue(var BD: TBitmapData; x:Integer;y:Integer):Byte;
begin
  result :=GetColor(BD,0,x,y);
end;

Procedure Tranparent;
var BData : TBitmapData;
i,j:Integer;
begin
   B.Map(TMapAccess.ReadWrite,BData);
// BMPAircraftBuf.Map(TMapAccess.ReadWrite,BDbuf);
 for i := 0 to B.Width-1 do
   for j := 0 to B.Height-1 do
     if (abs(GetRed(BData,i,j)-Red)<Tolerance) and (abs(GetGreen(BData,i,j)-Green)<Tolerance) and (abs(GetBlue(BData,i,j)-Blue)<Tolerance) then
        BData.SetPixel(i,j,0);      //Добавление прозрачности

   B.Unmap(BData);   //Иначе изменения не применяются!
end;


procedure InitBitmaps;
var i,j,k:Integer;
TempBmp : TBitmap;
BData : TBitmapData;
begin
  Terrain := TBitMap.Create;
  MainBmp := TBitMap.Create;
  Ground  := TBitMap.Create;
  Terrain.Width  := AreaPixels*LArea;
  Terrain.Height := AreaPixels*LArea;
  Ground.Width  := BasePixels*LBaseArea;
  Ground.Height := BasePixels*LBaseArea;
  for i := 1 to NPlayers do
   begin
     Img_Bases[i] := TBitMap.Create;//TPNGImage.Create;
     Img_Bases[i].LoadFromFile(GetImagesPath+'/base'+InttoStr(i)+'.png'); //Переправить пути
     //Img_Bases[i].CreateAlpha;
     //Img_Bases[i].RemoveTransparency;
     //Img_Bases[i].TransparentColor :=$FF00FF; //Фиолетовый
     Tranparent(Img_Bases[i],$FF,$00,$FF,$18); //Фиолетовый
     for j := 1 to 3 do
       begin
        Img_Planes[i,j] := TBitMap.Create;
        Img_Planes[i,j].Width := 10;
        Img_Planes[i,j].Height := 10;
       end;
     //BMPFon.Map(TMapAccess.ReadWrite,BDFon);
     //BMPFon.Unmap(BDFon);
     Img_Planes[i,1].Map(TMapAccess.ReadWrite,BData);  //Разведчик-квадрат
     for j := 0 to 9 do
       for k:= 0 to 9 do
         //Img_Planes[i].Canvas.Pixels[j,k] := PlanesCols[i]; //Или же через FillRect;
        BData.SetPixel(j,k,PlanesCols[i]);
     Img_Planes[i,1].Unmap(BData);
     Img_Planes[i,2].Map(TMapAccess.ReadWrite,BData);  //Бомбардировщик - ромбик
     for j := 0 to 9 do
       for k:= 0 to 9 do
         //Img_Planes[i].Canvas.Pixels[j,k] := PlanesCols[i]; //Или же через FillRect;
        if (abs(k-4.5)+abs(j-4.5))<5  then BData.SetPixel(j,k,PlanesCols[i])
                                      else BData.SetPixel(j,k,0);
     Img_Planes[i,2].Unmap(BData);
     Img_Planes[i,3].Map(TMapAccess.ReadWrite,BData);  //Основатель базы - круг
     for j := 0 to 9 do
       for k:= 0 to 9 do
         //Img_Planes[i].Canvas.Pixels[j,k] := PlanesCols[i]; //Или же через FillRect;
        if (sqr(k-4.5)+sqr(j-4.5))<25 then BData.SetPixel(j,k,PlanesCols[i])
                                      else BData.SetPixel(j,k,0);
     Img_Planes[i,3].Unmap(BData);

   end;
  for  i:=0 to TerrainsTypes do
   begin
    Img_Terrain[i] := TBitMap.Create;//TPNGImage.Create;
    Img_Terrain[i].LoadFromFile(GetImagesPath+'/img'+InttoStr(i)+'.png');
   end;
   TempBmp := TBitMap.Create;
   for i := 0 to NBuildings do
     begin
       TempBmp.LoadFromFile(GetImagesPath+'/building'+InttoStr(i)+'.png');
       case i of
         4..7: Tranparent(TempBmp,$FF,$FF,$FF,$18);
         else Tranparent(TempBmp,$FF,$00,$FF,$18);
       end;
       Img_Build[i] := TBitMap.Create;
       Img_Build[i].Width := BasePixels;
       Img_Build[i].Height := BasePixels;
       Img_Build[i].Canvas.BeginScene();
       BitmapToBitmap(Img_Build[i],TempBmp);
       Img_Build[i].Canvas.EndScene;
     end;
   {
  for i := 0 to NBuildings do
    begin
      Img_Build[i] := TBitMap.Create;
      Img_Build[i].Width := BasePixels;
      Img_Build[i].Height := BasePixels;
      Img_Build[i].Map(TMapAccess.ReadWrite,BData);
      for j := 0 to BasePixels-1 do
         for k:= 0 to BasePixels-1 do
           //Img_Build[i].Canvas.Pixels[j,k] := BuildCols[i];
            BData.SetPixel(j,k,BuildCols[i]);
      Img_Build[i].Unmap(BData);
    end;  }
  Img_Ground:= TBitMap.Create;//TPNGImage.Create;
  Img_Ground.LoadFromFile(GetImagesPath+'/base_ground.png');
end;

function  BitmapToRect;
begin
  result.Left := 0;
  result.Top := 0;
  result.Right := B.Width;//-1;
  result.Bottom := B.Height;// -1;    0..1 - рисует 1x1 пиксель.
end;

procedure  DrawToBmp;
var Rect1 :TRect;
begin
  Rect1.Left := X;
  Rect1.Top := Y;
  Rect1.Width := Src.Width;
  Rect1.Height := Src.Height;
  Dst.Canvas.DrawBitmap(Src,BitmapToRect(Src),Rect1,1,False);
end;

procedure BitmapToBitmap(const Dst,Src:TBitmap);
begin
  Dst.Canvas.DrawBitmap(Src,BitmapToRect(Src),BitmapToRect(Dst),1,False);
end;


procedure LoadTerrain;
var i,j,T_Type:Integer;
ARect:TRect;
SRCRect:Trect;
Brush : TStrokeBrush;
begin
  Terrain.Canvas.BeginScene();
  for I := 1 to Larea  do  //Устанавливаем флаги баз
    for j := 1 to Larea  do
      begin
         Arect.Left   := SecToPixels(i);//Первый писксель не отображается
         Arect.Right  := SecToPixels(i+1); //Уточнить когда +1 добавляешь, то работает
         Arect.Top    := SecToPixels(j);
         Arect.Bottom := SecToPixels(j+1);
         T_Type       := GetType(i,j);
         SRCRect := BitmapToRect(Img_Terrain[T_Type]);
         Terrain.Canvas.DrawBitmap(Img_Terrain[T_Type],SRCRect,Arect,1,False);//StretchDraw(ARect, Img_Terrain[T_Type]);
      end;
  Terrain.Canvas.EndScene;
  //Terrain.Canvas.Pen.Color := ClBlack;
  Brush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.Black);
  Brush.Thickness := 1;
  //Terrain.Canvas.Be
  for i := 0 to Larea-1 do   //Построение решётки
  with Terrain.Canvas do
    begin
      BeginScene;
      //Закомментировал для отладки
      DrawLine(PointF(1,AreaPixels*i), PointF(AreaPixels*LArea,AreaPixels*i), 1, brush);
      DrawLine(PointF(AreaPixels*i,1), PointF(AreaPixels*i,AreaPixels*LArea), 1, brush);
      EndScene;
      //Terrain.Canvas.MoveTo(1,AreaPixels*i);
      //Terrain.Canvas.LineTo(AreaPixels*LArea,AreaPixels*i);
      //Terrain.Canvas.MoveTo(AreaPixels*i,1);
      //Terrain.Canvas.LineTo(AreaPixels*i,AreaPixels*LArea);
    end;
  Ground.Canvas.BeginScene();
  for I := 1 to 4 do  //Зарисовываем территорию подложки
    for j := 1 to 4 do
      begin
         Arect.Left   := 250*(i-1);
         Arect.Right  := 250*(i);
         Arect.Top    := 250*(j-1);
         Arect.Bottom := 250*(j);
         Ground.Canvas.DrawBitmap(Img_Ground,BitmapToRect(Img_Ground),Arect,1,False);//.StretchDraw(ARect, Img_Ground);
      end;
  Ground.Canvas.EndScene();
end;

procedure Render;
var
i,j,k:Integer;
ARect: TRect;
begin

  MainBmp.Assign(Terrain);  //Подкладываем территорию
  MainBmp.Canvas.BeginScene();
  for I := 1 to Larea  do  //Устанавливаем флаги баз
    for j := 1 to Larea  do
      if (Area[i,j].Plm>0) and ((area[i,j].Timerasv[1]>TimeToBase) or CheatMode) then
        begin
          Arect.Left   := SecToPixels(i);
          Arect.Right  := SecToPixels(i+1)-1;
          Arect.Top    := SecToPixels(j);
          Arect.Bottom := SecToPixels(j+1)-1;
          MainBmp.Canvas.DrawBitmap(Img_Bases[Area[i,j].Plm],BitmapToRect(Img_Bases[Area[i,j].Plm]),Arect,1,False);
           //StretchDraw(ARect, Img_Bases[Area[i,j].Plm]);
        end;
  for I := 0 to Length(Samolets)-1 do   //Самолёты последними генерируются
    if (Samolets[i]<>nil) and ((Samolets[i].plm<2) or (CheatMode)) then
      begin
        j :=  CoordToPixels(Samolets[i].CoordX);
        k :=  CoordToPixels(Samolets[i].CoordY);
        DrawToBmp(MainBmp,Img_Planes[Samolets[i].plm,Samolets[i].Stype],j,k);
        //MainBmp.Canvas.Draw(j,k, Img_Planes[Samolets[i].plm]);
      end;
  MainBmp.Canvas.EndScene;
end;

procedure RenderBase;
var
i,j,k:Integer;
begin
  MainBmp.Assign(Ground);
  MainBmp.Canvas.BeginScene();
   for I := 1 to LBasearea  do  //Устанавливаем флаги баз
    for j := 1 to LBasearea  do
      if (Area2[i,j].plm>0) then
        if (Area2[i,j].plm<=NBuildings) then DrawToBmp(MainBmp, Img_Build[Area2[i,j].Plm],SecToGround(i),SecToGround(j))
                                        else DrawToBmp(MainBmp, Img_Build[0],SecToGround(i),SecToGround(j)); //MainBmp.Canvas.Draw(SecToGround(i),SecToGround(j), Img_Build[0]); //Стоящееся-серым

  MainBmp.Canvas.EndScene;
end;


Function EtalonToX(X:Double):Double;
begin
  Result:=Round(X*_ClientWidth/EtalonWidth);
end;

Function EtalonToY(Y:Double):Double;
begin
  Result:=Round(Y*_ClientHeight/EtalonHeight);
end;

Function XToEtalon(X:Single):Integer;
begin
  Result:=Round(X*EtalonWidth/_ClientWidth);
end;

Function YToEtalon(Y:Single):Integer;
begin
  Result:=Round(Y*EtalonHeight/_ClientHeight);
end;

function XToSec;
begin
  result := PixelsToSec(XtoEtalon(X)-BaseLeft);
end;
function YToSec;
begin
  result := PixelsToSec(YtoEtalon(Y));
end;

function  SecToPixels;
begin
  result := AreaPixels*(N-1); //+1
  if result<0 then result := 0;
end;

function  SecToGround;
begin
  result := BasePixels*(N-1);
  if result<0 then result := 0;
end;


function CoordToPixels;
begin
  result := Round(N/SectorDlinna*50)-5;
  if result<1 then result := 1;
  if result+10>AreaPixels*LArea then result := AreaPixels*LArea -10;
end;

function PixelsToSec;
begin
  result := (N-1) div AreaPixels +1;
end;

function PixelsToCoord;
begin
  result := Round(N*SectorDlinna/AreaPixels);
end;

function XToCoord;
begin
  result := PixelsToCoord(XtoEtalon(X)-BaseLeft);
end;
function YToCoord;
begin
  result := PixelsToCoord(YtoEtalon(Y));
end;


function GetType;
begin
  if (i<1) or (j<1) or (i>Larea) or (j>Larea) then Result := 0; //За пределами всё полная суша.
  if IsWater(i,j) then result := 9
  else
    begin
      result := 0;
      if (j>1) and (IsWater(i,j-1)) then result := 2;
      if (i<LArea) and (IsWater(i+1,j)) then result := 4;
      if (j<LArea) and (IsWater(i,j+1)) then result := 6;
      if (i>1) and (IsWater(i-1,j)) then result := 8;
      if result>0 then exit;//Горизонталь и вертикаль имеет больший приоритет

      if (j>1) and (i>1) and  (IsWater(i-1,j-1)) then result := 1;
      if (i<LArea) and (j>1) and (IsWater(i+1,j-1)) then result := 3;
      if (i<LArea) and (j<LArea) and (IsWater(i+1,j+1)) then result := 5;
      if (j<LArea) and (i>1) and (IsWater(i-1,j+1)) then result := 7;
    end;

end;

procedure GenerateTerrain;
var i,j:Integer;
begin
for J := 1 to LArea do
  for i := 1 to LArea do
  begin
    //area[i,j].clr :=ColorToAlpha($000000);//Заполнение нулями
    case GetType(i-1,j) of
      0:  //Суша
       // begin
          if (GetType(i,j-1)=0) and (GetType(i-1,j-1)=0) and (GetType(i+1,j-1)=0)  then
            if Random(100)<GeneratePercent then  area[i,j].clr := 255;//ColorToAlpha($FFFF00);
       // end;
      //2: if IsWater(i,j-1) then  area[i,j].clr := $FFFF00; //2- всегда сушу ставим
      3: if Random(100)<GeneratePercent then  area[i,j].clr := 255;//ColorToAlpha($FFFF00);  //можно как сушу так и воду
      //Сейчас 9 фактически запрещён
      9: if IsWater(i,j-1) then  area[i,j].clr := 255//ColorToAlpha($FFFF00)  //Вод идёт по квардатам! по диагонали ";" не ставим
         else
           //if (GetType(i,j-1)=7) and (GetType(i+1,j-1)<>3) and (GetType(i+1,j-1)<>4) then //0 невозможен
           if (GetType(i+1,j-1)=0) and (GetType(i,j-1)<>8) then
             if Random(100)<GeneratePercent then  area[i,j].clr := 255;//ColorToAlpha($FFFF00);
    end;
  end;

end;

function  IsWater;
begin
  if (i<1) or (j<1) or (i>Larea) or (j>Larea) then Result := False
  else Result :=  (area[i,j].clr=255);//ColorToAlpha($FFFF00));  //Голубое-море
end;

function  ColorToAlpha;
begin
  result := TAlphaColors.Black + A;
end;

function GetImagesPath;
begin
{$IFDEF ANDROID}
  result := TPath.GetDocumentsPath+'/Images';  //assets/internal   //GetPublicPath -> assets
{$ELSE}
  result := './Images';
{$ENDIF}
end;

//----TColorProgressBar---
constructor   THearthBar.Create;
var i,j,k:Integer;
BData : TBitmapData;
Color : TAlphaColor;
begin
  Owner := _Owner;
  Left := 1012;
  for I := Low(StateBMP) to High(StateBMP) do
    begin
      StateBMP[i] := TBitmap.Create;
      StateBMP[i].Height := 10;
      StateBMP[i].Width := 10;
      StateBMP[i].Map(TMapAccess.ReadWrite,BData);
      case i of
        0: Color := ColorToAlpha($FF0000);
        1: Color := ColorToAlpha($FFFF00);
        2: Color := ColorToAlpha($00FF00);
      end;
      for j := 0 to 9 do
         for k:= 0 to 9 do
           //Img_Build[i].Canvas.Pixels[j,k] := BuildCols[i];
            BData.SetPixel(j,k,Color);
      StateBMP[i].Unmap(BData);
    end;

end;

destructor  THearthBar.Destroy;
begin
  inherited Destroy;
end;

procedure THearthBar.Repaint;
var State :Byte;
Rect1 : TRect;
begin
  if not Visible then exit;

  if Hearth<34 then State := 0
  else
    if Hearth<67 then State := 1
    else State := 2;
  Rect1.Top := Round(ETalonToY(340));
  Rect1.Left := Round(ETalonToX(Left));//1012);
  Rect1.Width := Round(ETalonToX(2.25*Hearth));
  Rect1.Height := Round(ETalonToY(20));
  //Owner.BeginScene();
  Owner.DrawBitmap(StateBMP[State],BitmapToRect(StateBMP[State]),Rect1,1,False);
  //Owner.EndScene();

end;

//Генерация
//Только если GetType даёт 0, то можно воду.


begin
end.