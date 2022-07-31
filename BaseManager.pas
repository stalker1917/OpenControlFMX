unit BaseManager;

interface
uses AreaManager,ControlConsts,Finance;

type THangar=record
  X,Y:Byte;
  Hangar : PAngar;
  {$IFDEF READ_ANDROID}
  Base2 : PAngar;
 {$ENDIF}
end;



type TBase=record  //Поробовать сюда добавить ангары
  Base : PAreaB;
  {$IFDEF READ_ANDROID}
  Base2 : PAreaB;
 {$ENDIF}
  X,Y : Byte;
  Miners,NMiners : TConstRes; //Nminers - количество шахт, в том числе и строящихся.
  Hangars : Array of THangar;
  Avia : Array of TBuilding;
  procedure SetHouses(SetMain:Boolean=False);
  procedure NewBase(_X,_Y,N:Byte;OnlyMainBase:Boolean=False);
end;

PBase = ^TBase;

type TStackofBases=Object  //Возможно также сформировать стек зданий для уменьшения размера сохранений
  Data : Array of TBase;
  //procedure AddBase(var B : TBase);
  procedure NewBase(X,Y,N:Byte;OnlyMainBase:Boolean=False);
  procedure DestroyBase(N:Integer);
  function  FindBase(Base:PAreaB):Integer;
  procedure Load(var F:TBFile);
  procedure Save(var F:TBFile);
  procedure RefreshMiners(N:Integer);
  procedure RefreshHangars(X,Y,N:Integer);
  procedure RefreshAvia(X,Y,N:Integer);
end;

PStackofBases = ^TStackofBases;

var
Base : Tbase;
BankofBases : array [1..NPlayers]  of  TStackofBases;

Function IsMine(const X,Y:byte; area2: PAreaB):Boolean; Overload;
Function IsMine(N:Byte):Boolean; Overload;
Function IsAvia(const X,Y:byte; area2: PAreaB):Boolean;
Function IsHangar(const X,Y:byte; area2: PAreaB):Boolean;
Function GetRegen(X,Y,i:byte):Integer;
//procedure NewBase(X,Y,N:Byte;OnlyMainBase:Boolean=False);
//Procedure SetHouses(area2:PAreaB; SetMain:Boolean=False);

implementation
function TStackofBases.FindBase;
var i:Integer;
begin
result := -1;
for i:=0 to High(Data) do
  if Data[i].Base=Base then result := i;
end;

{
procedure TStackofBases.AddBase;
begin
  SetLength(Data,Length(Data)+1);
  Data[High(Data)] := B;
  RefreshMiners(High(Data));
  //(High(Data));
end;
}

procedure TStackofBases.Save;
var i,j,k :SmallInt;
begin
  k :=Length(Data);
  BlockWrite(F,k,SizeOf(SmallInt));
  for k := 0 to High(Data) do
    begin
      BlockWrite(F,Data[k].X,1);
      BlockWrite(F,Data[k].Y,1);
      j := Length(Data[k].Hangars);
      BlockWrite(F,j,SizeOf(SmallInt));
      for j := Low(Data[k].Hangars) to High(Data[k].Hangars) do
        begin
          BlockWrite(F,Data[k].Hangars[j],SizeOf(THangar));
          BlockWrite(F,Data[k].Hangars[j].Hangar[1],SizeOf(PSamolet)*6);
          for i := 1 to HangarHigh do
            if Data[k].Hangars[j].Hangar[i]<>nil then BlockWrite(F,Data[k].Hangars[j].Hangar[i]^,SizeOf(TSamolet));//then  BlockWrite(F,area[1,1],SizeOf(TSamolet))
                                                //else  BlockWrite(F,Data[k].Hangars[j].Hangar[i]^,SizeOf(TSamolet));

        end;
      AreaBSave(F,Data[k].Base^);
      j := Length(Data[k].Avia);
      BlockWrite(F,j,SizeOf(SmallInt));
      BlockWrite(F,Data[k].Avia[0],SizeOf(TBuilding)*j);
      BlockWrite(F,Data[k].NMiners[0],SizeOf(TConstRes));
      //BlockWrite(F,SizeOf(TAreaB));
    end;
end;

procedure TStackofBases.Load;   //СДелать в соотвествии с Save.
var i,j,k,m:SmallInt;
DebugInt : Int64;
DebugInt2 : Int64;
DebugArray : Array [0..1023] of Byte;
PustSam:TSamolet;
begin
  DebugInt2:=0;
  BlockRead(F,k,SizeOf(SmallInt));
  SetLength(Data,k);
  for k := 0 to High(Data) do
    begin
      BlockRead(F,Data[k].X,1);
      BlockRead(F,Data[k].Y,1);
      BlockRead(F,j,SizeOf(SmallInt));
      SetLength(Data[k].Hangars,j);
      New(Data[k].Base);
      i := SizeOf(TSamolet);
      for j := Low(Data[k].Hangars) to High(Data[k].Hangars) do
        begin
          BlockRead(F,Data[k].Hangars[j],SizeOf(THangar));
          Data[k].Hangars[j].Hangar := @Data[k].Base[Data[k].Hangars[j].X,Data[k].Hangars[j].Y].Angar;
           {$IFDEF READ_ANDROID}
              BlockRead(F,DebugArray,4);
             for I := 0 to 5 do
               begin
                 m := SizeOf(PSamolet);
                 BlockRead(F,DebugInt,8);
                 //BlockRead(F,DebugInt2,8);
                 if (DebugInt=0) and (DebugInt2=0) then Data[k].Hangars[j].Hangar[i+1] := nil
                                                   else Data[k].Hangars[j].Hangar[i+1] := @PustSam;
               end;   //}
               //BlockRead(F,DebugInt2,8);
           {$ELSE}
             BlockRead(F,Data[k].Hangars[j].Hangar[1],SizeOf(PSamolet)*6);
            {$ENDIF}
          for i := 1 to HangarHigh do
            if Data[k].Hangars[j].Hangar[i]<>nil then  //BlockRead(F,PustSam,SizeOf(TSamolet))
              begin
                New(Data[k].Hangars[j].Hangar[i]);
                BlockRead(F,Data[k].Hangars[j].Hangar[i]^,SizeOf(TSamolet));
              end;
            //else
        end;
      //BlockRead(F,Base,SizeOf(TAreaB));
      AreaBLoad(F,Data[k].Base^);
      Area[Data[k].X,Data[k].Y].areab := Data[k].Base;
      BlockRead(F,j,SizeOf(SmallInt));
      SetLength(Data[k].Avia,j);
      BlockRead(F,Data[k].Avia[0],SizeOf(TBuilding)*j);
      if CurrSaveVersion>0 then BlockRead(F,Data[k].NMiners[0],SizeOf(TConstRes));
     // BlockRead(F,DebugArray,1024);
      RefreshMiners(k);
    end;
end;

procedure TStackofBases.RefreshMiners;
var i,j,X,Y : Integer;
area2 : PAreaB;
begin
  if (N<0) and (N>High(Data)) then exit;
  area2 := Data[N].Base;
  for I := 1 to 4 do Data[N].Miners[i] := 0;
  for I := 1 to LBaseArea  do
    for j := 1 to LBaseArea  do
      if {(area2[i,j].plm>3) and (area2[i,j].plm<8)} IsMine(i,j,area2) then Data[N].Miners[area2[i,j].plm-3]:=Data[N].Miners[area2[i,j].plm-3]+BaseMine; //Часовая добыча
  X := Data[N].X;
  Y := Data[N].Y;
   for I := 1 to 4 do if (area[X,Y].Regeneration) and (Data[N].Miners[i]>GetRegen(X,Y,i)) then Data[N].Miners[i]:= GetRegen(X,Y,i);
end;

procedure TStackofBases.RefreshHangars;
begin
  if (N<0) and (N>High(Data)) then exit;
  if Data[N].Base[X,Y].plm<>3 then exit;
  SetLength(Data[N].Hangars,Length(Data[N].Hangars)+1);
  Data[N].Hangars[High(Data[N].Hangars)].X:=X;
  Data[N].Hangars[High(Data[N].Hangars)].Y:=Y;
  Data[N].Hangars[High(Data[N].Hangars)].Hangar := @Data[N].Base[X,Y].Angar;
end;

procedure TStackofBases.DestroyBase;
begin
  Dispose(Data[N].Base);
  area[Data[N].X,Data[N].Y].plm := 0;
  area[Data[N].X,Data[N].Y].areab := nil;
  if N<High(Data)  then Data[N] := Data[High(Data)];
  //Нужно переписать все самолёты.   N_Planes[Stype,N].Base
  //Все самолёты, которые  имели N_Planes[Stype,N].Base High переписать на  N_Planes[Stype,N].Base
  SetLength(Data,Length(Data)-1);
end;

procedure TStackofBases.RefreshAvia;
begin
  if (N<0) and (N>High(Data)) then exit;
  if Data[N].Base[X,Y].plm<>2 then exit;
  SetLength(Data[N].Avia,Length(Data[N].Avia)+1);
  Data[N].Avia[High(Data[N].Avia)].X:=X;
  Data[N].Avia[High(Data[N].Avia)].Y:=Y;
end;

procedure TStackofBases.NewBase;
begin
  SetLength(Data,Length(Data)+1);
  Data[High(Data)].NewBase(X,Y,N,OnlyMainBase);
  RefreshMiners(High(Data));
  area[X,Y].Timerasv[N]:=TimeToResources+1;
end;

//------------TBase-----
procedure TBase.NewBase;
var i:Integer;
begin
    X := _X;
    Y := _Y;
    area[X,Y].clr:=Plems[N];
    area[X,Y].plm:=N;
    New(area[X,Y].areab);  //На самом деле базы есть.
    Base  := area[X,Y].areaB;
    //SetHouses(area[X,Y].areaB,OnlyMainBase);
    SetHouses(OnlyMainBase);
    if not OnlyMainBase then //Связываем анграры базы и территории.
      begin
        SetLength(Hangars,1);
        SetLength(Avia,1);
        Hangars[0].X := 10;
        Hangars[0].Y := 12;
        Hangars[0].Hangar := @area[X,Y].areaB[10,12].Angar;
        for I := Low(Hangars[0].Hangar^) to High(Hangars[0].Hangar^)  do  Hangars[0].Hangar[i] := nil;
        Avia[0].X := 14;
        Avia[0].Y := 12;
        for i := 1 to 4 do NMiners[i]:=1;
      end
    else
      begin
        SetLength(Hangars,0);  //А то из прошлой базы состояние перейдёт.
        SetLength(Avia,0);
        for i := 1 to 4 do NMiners[i] :=0;
      end;
end;


procedure TBase.SetHouses(SetMain: Boolean = False);
var l,m : Integer;
begin
  for l := 1 to 25 do
    for m := 1 to 25 do
      begin
        Base[l,m].clr := $00AAAA;
        Base[l,m].plm := 0;
        Base[l,m].HitPoints := 0;
        Base[l,m].Regime := 0;
      end;
   Base[12,12].clr := BuildCols[1];
   Base[12,12].plm := 1;
   Base[12,12].HitPoints :=H_Main;
   if not SetMain then
     begin
       Base[14,12].clr := BuildCols[2];
       Base[10,12].clr := BuildCols[3];
       Base[10,10].clr := BuildCols[4];
       Base[10,14].clr := BuildCols[5];
       Base[14,14].clr := BuildCols[6];
       Base[14,10].clr := BuildCols[7];
       Base[14,12].plm := 2;
       Base[10,12].plm := 3;
       Base[10,10].plm := 4;
       Base[10,14].plm := 5;
       Base[14,14].plm := 6;
       Base[14,10].plm := 7;
     end;
end;

//------------------Независимые----------
Function IsMine(const X,Y:byte; area2: PAreaB):Boolean;
begin
  result := (area2[X,Y].plm>3) and (area2[X,Y].plm<8);
end;

Function IsMine(N:Byte):Boolean;
begin
  result := (N>3) and (N<8);
end;

function IsHangar;
begin
  result := (area2[X,Y].plm=3);
end;

function IsAvia;
begin
  result := (area2[X,Y].plm=2);
end;

Function GetRegen(X,Y,i:byte):Integer;
begin
  result := Round(area[X,Y].Res[i]/I_Regeneration);
end;





end.
