// By Stalker1917  LGPL 3.0
Unit AiManager;

interface
uses TimeManager,Finance,ControlConsts,{StdCtrls,Graphics,}SysUtils,AreaManager,BaseManager,
FMX.Graphics,FMX.StdCtrls,System.UITypes,FMX.Memo,Debug;



var
  LogMemo : TMemo;
  TekSami : Integer;


type

TPlaneControl=record
  Number : Integer; //Номер в самолётах, если выпущен. Если нет-то позиция в ангаре. 
  Base   : Integer; //Номер базы, если в базе
  X,Y    : Integer; //Положение ангара на базе.
  Event  : Boolean; //На задании или нет. 
  //OnBuild : Boolean; //Ещё строиться! 
end;

TPlaneArray = Array of TPlaneControl;

type TAiTriggers = class(TObject)
  Player     : Byte;
  Bank       : PBank;
  Events     : PStackOfEvent;
  Bases      : PStackofBases;
  Areas      : TStackofArea;
  //Tриггеры
  N_Planes : Array[1..C_MaxPlane] of TPlaneArray;
  Procedure AiTurn;
  Procedure PlaneToSky(Stype:Byte;Pos:Integer);
  procedure Economics;
  procedure ToWar; 
  function Build(var Base :TBase; const Cost:TConstRes;const BTime:TTimeRecord; BType:byte;X1,Y1:Integer; Target:Byte=0):Boolean;  // Строим что-нибудь//100-cамолёт
  function BuildNewPlane(SType:Integer):Boolean;
  //procedure CheckHangar(N:Byte); //Число событий по постройке+число смолётов сравниваем с местами в ангаре  N-номер базы  //Мо
  procedure CreatePlaneEvent(Extype:Byte;N:Integer);
  procedure InitAreas(Stype:Byte;N:Integer);
  function FindPlane(var N:Integer):Integer;
  procedure DeletePlane(Stype,N:Integer);// Удалить самолёт по его номеру в массвиве.
  Function  AreaX(N:Integer) :Byte;
  Function  AreaY(N:Integer) :Byte;
  Function  PlaneX(Stype,N:Integer) :Byte;
  Function  PlaneY(Stype,N:Integer) :Byte;
  procedure DestroyBase(DBase : PAreaB);
  procedure Surrender;
  procedure UpdateRes(Time:Integer);
  procedure Load(var F:TBFile);
  procedure Save(var F:TBFile);
  Constructor Create(N:Byte);

  Destructor Destroy;
 
end;

var
BankofTrigers: array [1..NPlayers]  of  TAiTriggers;



Procedure AddTime(AddTime:Int64;Force:Boolean);
Procedure SolveEvent(N:Integer) ;
Procedure PutLog(S:String);

//Сейчас процедура неуниверсальная , работает только для 1
function XYTOStr(const X,Y:byte):String;




Function  CoordToSec(A:Integer):Integer;
Function  SecToCoord(A:Integer):Integer;
Function  GetLn(const A:TSamolet):Double;
procedure SolvePlanes(ATime:Int64);
procedure PlaneToSky(const Base:TBase; var Samolet:PSamolet);
Function  GetRegime(Stype : Byte):Byte;
Procedure DeletePlane(Player,N:Integer);
Function AddPlane:Integer;
Procedure SetFlyEvent(Player,TX,Ty,N:Integer;Hang:Boolean=False;AddTime:Integer=0);
Procedure Bombing(Player,N,X,Y:Integer);
Procedure FoundBase(Player,N,X,Y:Integer);


implementation


//------------Независимые-----------


Procedure ResPlanes(OldTime:Int64);
var RTime : Int64;
i:Integer;
begin
 Rtime := Int64ToRtime(Timestamp,OldTime);
 if Rtime>0  then  for i := 1 to NPlayers do BankofTrigers[i].UpdateRes(Rtime); //UpdateRes(i,Rtime); //Добавление ресурсов
 SolvePlanes(Timestamp-OldTime);
end;

Procedure AddTime;
var
MinEvents:Byte;
TimeEvent,ManagerStamp,Planestamp:Int64;
begin
  ManagerStamp := TimeStamp;
  repeat 
    MinEvents := GetMinEvents;
    TimeEvent := BankofEvents[MinEvents].GetEvent.EventTime;
    Planestamp := Timestamp;
    if (MinEvents=0) or (TimeEvent>ManagerStamp+AddTime) then
      begin
        TimeStamp:=ManagerStamp+AddTime;
        ResPlanes(Planestamp);
      end
    else 
      begin
        if TimeEvent>Timestamp then TimeStamp:= TimeEvent;
        ResPlanes(Planestamp);//SolvePlanes(Timestamp-Planestamp);
        SolveEvent(MinEvents);
        //if MinEvents>1 then AiTurn(MinEvents);
        if (MinEvents=1)  then
          if (not Force) then exit
          else 
        else if (BankofTrigers[MinEvents]<>nil) then BankofTrigers[MinEvents].AiTurn;   
      end;

  until TimeStamp>=ManagerStamp+AddTime;
end;



Procedure SolvePlanes;
var i,j:Integer;
CoordXD,CoordYD:DOuble;
VecX,VecY:Double;
Ln : Double;
//X1,Y1:Integer;
begin
//ATime
  if ATime<=0 then exit;
  for i := 0 to Length(Samolets)-1 do 
    if Samolets[i]<> nil then  
      With Samolets[i]^ do
        if (TarX<>CoordX) or (TarY<>CoordY) then    //Или по X или по Y одинаковые координаты.
          begin
            Ln := GetLn(Samolets[i]^);//sqrt(sqr(TarX-CoordX)+sqr(TarY-CoordY));
            if Ln<0.1 then continue;
            CoordXD:= CoordX;
            CoordYD:= CoordY;
            VecX :=(TarX-CoordX)/Ln;
            VecY :=(TarY-CoordY)/Ln;
            for j:=0 to Atime do
              begin
                if (abs(VecX)<0.01) or ((TarX-CoordX)/VecX>0) then CoordXD := CoordXD + VecX*Velocites[Stype];
                if (abs(VecY)<0.01) or ((TarY-CoordY)/VecY>0) then CoordYD := CoordYD + VecY*Velocites[Stype];
                CoordX :=  Round(CoordXD);
                CoordY :=  Round(CoordYD);
                inc(area[CoordToSec(CoordX),CoordToSec(CoordY)].Timerasv[plm]);
              end;

          end
        else area[CoordToSec(CoordX),CoordToSec(CoordY)].Timerasv[plm] := area[CoordToSec(CoordX),CoordToSec(CoordY)].Timerasv[plm] + ATime;
        //Пока разведовательная способность у всех 100% , но это надо исправить.      
end;

Procedure EndSolveEvent(N:Integer);
begin
  BankofEvents[N].DeleteEvent;
  OldStamp := TimeStamp;
end;

Procedure SolveEvent;   //Номер игрока
var
Event : TEvent;
Angar : PAngar;
i,j,k,Nbase: Integer;
RTime : Int64;
Base : PBase;
EStype : Byte;
//X,Y   : Byte;
begin
Event := BankofEvents[N].GetEvent;
if not TestEvent(Event) then DebugEvent(Event);
Nbase := BankofBases[N].FindBase(area[Event.X,Event.Y].areab);
if NBase>=0 then Base := @BankofBases[N].Data[Nbase] //Если база найдена
            else Base := nil;
//begin

//SolvePlanes(Timestamp-OldStamp); //Изменение координат полёта самолётов
//if Base<>nil then //Удаляем для
case Event.EventType of
  1:  //Постройка завода
    begin
      //Base.Base := ;
      if Base=nil then
        begin
          // Возникает например на уничтоженной базе
          EndSolveEvent(N);
          exit; //Искать причину ошибки
        end;
      i := Base.Base[Event.X1,Event.Y1].plm;
      if i>=128 then i := i - 128; //+Добавить цвет
      if N=1 then PutLog(Int64ToString(TimeStamp)+' Построено здание в квадрате '+XYTOStr(Event.X,Event.Y));
      if i>0 then Base.Base[Event.X1,Event.Y1].clr := BuildCols[i];
      Base.Base[Event.X1,Event.Y1].plm := i;
      Base.Base[Event.X1,Event.Y1].Regime := 0;
      if IsMine(i) then  BankofBases[N].RefreshMiners(Nbase);
      if IsHangar(Event.X1,Event.Y1,Base.Base)then
        begin
          BankofBases[N].RefreshHangars(Event.X1,Event.Y1,Nbase);   //Если ангар, добавляем в список ангаров.
          for j := Low(Base.Base[Event.X1,Event.Y1].Angar) to High(Base.Base[Event.X1,Event.Y1].Angar) do
            Base.Base[Event.X1,Event.Y1].Angar[j] := nil;
        end;
      if IsAvia(Event.X1,Event.Y1,Base.Base) then BankofBases[N].RefreshAvia(Event.X1,Event.Y1,Nbase); //Если аВиазавод, добавляем в список авиазаводов.
    end;
  2:  //Постройка самолёта
    begin
        if Base=nil then
          begin
            EndSolveEvent(N);
            exit; //Искать причину ошибки
          end;
       k:=100;  //Если так и останется значит в ангаре нет места.
       for  j:=0 to High(Base.Hangars) do
       begin
         Angar :=  Base.Hangars[j].Hangar;//  Нужно именно ссылку передать
       i := 1; //Позиция в ангаре начинается с 1-го элемента
       repeat
         if Angar[i]=nil then
           begin
             EStype := Base.Base[Event.X1,Event.Y1].Regime;
             if (EStype<1) or  (EStype>C_MaxPlane)  then //Это будет часто выпадать при Regime=0 , не надо в лог записывать.
               //LogFile.WriteToLog('Построен самолёт неверного типа'+IntToStr(EStype)+'в координатах '+IntToStr(Event.X1)+':'+IntToStr(Event.Y1))
             else
               begin
             New(Angar[i]);
             Angar[i].Stype := EStype;

             Angar[i].HitPoints := 10;
             Angar[i].InBase := True;
             Angar[i].Toplivo := 300;
             Angar[i].plm := area[Event.X,Event.Y].plm;
             k := i;
               end;
             I :=-1;
             break;
           end;
        inc(i)
       until (i>6); // Исправить на много ангаров!
       if i<0 then  break;
       end;
       
      Base.Base[Event.X1,Event.Y1].Regime := 0;
      if N=1 then
         if k<100 then PutLog(Int64ToString(TimeStamp)+' Построен самолёт в квадрате '+XYTOStr(Event.X,Event.Y))
                  else PutLog(Int64ToString(TimeStamp)+' Нет места в ангаре '+XYTOStr(Event.X,Event.Y));
      If (BankofTrigers[N]<>nil) and (k<100) then
        begin
          SetLength(BankofTrigers[N].N_Planes[Angar[k].Stype],Length(BankofTrigers[N].N_Planes[Angar[k].Stype])+1);
          with  BankofTrigers[N].N_Planes[Angar[k].Stype][High(BankofTrigers[N].N_Planes[Angar[k].Stype])]  do
            begin
              Event := False;
              Base := Nbase;
              X := {AiManager.}BankofBases[N].Data[Nbase].Hangars[j].X; //Здесь нельзя base ставить, т.к. with
              Y := {AiManager.}BankofBases[N].Data[Nbase].Hangars[j].Y;
              Number := -k;
            end;
        end; 
    end;
    3:
      begin
        i := BankofEvents[N].GetPlaneNumber;
        if Samolets[i]<> nil then
          With Samolets[i]^ do
            begin
              CoordX := TarX;
              CoordY := TarY; 
              k:=i;
              //BankofTrigers[N].FindPlane(j)<0 then break;
              j := BankofTrigers[N].FindPlane(k);
              if j>=0 then BankofTrigers[N].N_Planes[Stype,k].Event := False; //Cбрасываем событие
              if (Stype=2) then   // Упрощённая игра. Бомбардирощик долетел, уменьшил хит-поинты у базы и выпилился.
                Bombing(N,i,Event.X,Event.Y);
              {if (area[Event.X,Event.Y].plm>0) and (area[Event.X,Event.Y].plm<>N) then
                begin
                  area[Event.X,Event.Y].areab[12,12].HitPoints := area[Event.X,Event.Y].areab[12,12].HitPoints - H_Bomb;
                  DeletePlane(N,i);
                  if area[Event.X,Event.Y].areab[12,12].HitPoints<=0 then BankofTrigers[area[Event.X,Event.Y].plm].DestroyBase(area[Event.X,Event.Y].areab);
                end;  }
              if (Stype=3) and (bombs=1) then    //Тип основатель базы и приказ основать базу , а не просто лететь в квадрат.
                FoundBase(N,i,Event.X,Event.Y);
              {if area[Event.X,Event.Y].plm=0 then
                begin
                  NewBase(Event.X,Event.Y,plm,True);
                  if N=1 then PutLog(Int64ToString(TimeStamp)+' Успешно основана база в квадрате '+XYTOStr(Event.X,Event.Y));
                  DeletePlane(N,i);

                 //Записать - база основана успешно.
                end
              else
                begin
                  bombs := 0; //Приказ изменён на "лететь в точку"
                  if N=1 then PutLog(Int64ToString(TimeStamp)+' Ошибка основания базы в квадрате '+XYTOStr(Event.X,Event.Y));
                //Записать: Ошибка основания базы.
                end; }
              end;
      end; 
    5: 
      begin
        i := BankofEvents[N].GetPlaneNumber; //Берём номер самого последнего самолёта в банке. Это можно т.к. последний номер с наименьшим временем
        j := BankofTrigers[N].FindPlane(i);
        //if j<0 then  break;
        if j>=0 then BankofTrigers[N].N_Planes[j,i].Event := False; //Сбросили событие
        if N=1 then PutLog(Int64ToString(TimeStamp)+' Успешно проведена разведка в квадрате '+XYTOStr(Event.X,Event.Y));
      end;  
  end;

EndSolveEvent(N);
end;

procedure DeletePlane;
var
Stype,Num:Integer;
begin
  if Samolets[N] = nil then exit;//Удалаем уже удалённый самолёт
  if Samolets[N].plm<>Player then exit; //Удаляем чужой самолёт
  Samolets[N] := nil;
  Num := N;
  Stype := BankofTrigers[Player].FindPlane(Num);
  if (Stype>0) and (Stype<=C_MaxPlane) then BankofTrigers[Player].DeletePlane(Stype,Num);
end;

Function AddPlane;
var i,H:Integer;
begin
  H := High(Samolets);
  for i:=0 to  H do
    if Samolets[i]=nil then
      begin
        result := i;
        exit;
      end; 
  SetLength(Samolets,H+2);
  result := H+1;    
end;

function XYTOStr;
begin
  result := chr(ord('a')+X-1) + IntToStr(Y);
end;

Procedure PutLog(S:String); //Добавляем строку в лог действий игрока
begin
  LogMemo.Lines.Add(S);
end;




function CoordToSec;
begin
  result := Trunc(A/SectorDlinna)+1;
  if result>Larea then
    result := Larea;
end;

function SecToCoord;
begin
  result := Round(SectorDlinna*(A-0.5));
end;

function GetLn;
begin
  with a do result := sqrt(sqr(TarX-CoordX)+sqr(TarY-CoordY));
end;

procedure PlaneToSky;
var
N,M:Integer;
begin
 if  (Samolet=nil)  then
     begin
       LogFile.WriteToLog('Попытка выпустить несуществующий самолёт');
       exit;
     end;
  if  (Samolet.Stype<1) or (Samolet.Stype>C_MaxPlane) then
    begin
      LogFile.WriteToLog('Попытка выпустить самолёт неверного типа'+IntToStr(Samolet.Stype));
      Samolet:= nil;
      exit;
    end;
  //SetLength(Samolets,Length(Samolets)+1);
  M := AddPlane;
  Samolets[M] := Samolet;  //Выпускаемый самолёт=aнгаровский самолёт
  with Samolets[M]^ do
    begin
      CoordX := SecToCoord(Base.X);
      CoordY := SecToCoord(Base.Y);
      TarX := CoordX;
      TarY := CoordY;
    end;
  Samolet:= nil;
  N:=area[Base.X,Base.Y].plm;
  //if N>1 then
  BankofTrigers[N].PlaneToSky(Samolets[M].Stype,M)
end;

function GetRegime;
begin
  if Stype<C_MaxPlane then Result := C_Regimes[Stype]
                      else Result := 0;
end;

procedure SetFlyEvent;
begin
with Samolets[N]^ do
  begin
    if Hang then
      begin
        TarX := CoordX;
        TarY := CoordY; 
      end
    else
      begin
        TarX := Tx;
        TarY := Ty;      
      end;
    //Bombs := 0
    //Создать событие
    Event.X := CoordToSec(TarX);
    Event.Y := CoordToSec(TarY);
    if Hang then 
      begin
        Event.EventType := 5;
        Event.EventTime :=Timestamp+ AddTime;
      end
    else 
      begin
        Event.EventType := 3;
        Event.EventTime :=Timestamp+ Round(GetLn(Samolets[N]^)/Velocites[Stype]);
      end;
    SetPlaneNumber(Event,N);
    BankofEvents[Player].AddEvent(Event);
   // BankofEvents[Player].SetPlaneNumber(N); //Портит данные
    if (not Hang) and (Stype=3) and (area[Event.X,Event.Y].plm=0) and (area[Event.X,Event.Y].Timerasv[Player]>TimeToBase)  then     //ecли основатель и базу можно основать
      if plm>1 then Bombs := 1;    //Основываем базу, если игрок >1
  end;  
end;

Procedure Bombing;  //Бомбардировка
begin
// Упрощённая игра. Бомбардирощик долетел, уменьшил хит-поинты у базы и выпилился.
  if (area[X,Y].plm>0) and (area[X,Y].plm<>Player) then
    begin
      area[X,Y].areab[12,12].HitPoints := area[X,Y].areab[12,12].HitPoints - H_Bomb;
      DeletePlane(Player,N);
      if area[X,Y].areab[12,12].HitPoints<=0 then
        BankofTrigers[area[X,Y].plm].DestroyBase(area[X,Y].areab);
    end;
end;

Procedure FoundBase; //Основать базу
begin
  if area[X,Y].plm=0 then
    begin
      //NewBase(X,Y,Samolets[N].plm,True);
      BankofBases[Samolets[N].plm].NewBase(X,Y,Samolets[N].plm,True);
      if N=1 then PutLog(Int64ToString(TimeStamp)+' Успешно основана база в квадрате '+XYTOStr(X,Y));
      DeletePlane(Player,N);
      //Записать - база основана успешно.
    end
  else
    begin
      Samolets[N].bombs := 0; //Приказ изменён на "лететь в точку"
      if N=1 then PutLog(Int64ToString(TimeStamp)+' Ошибка основания базы в квадрате '+XYTOStr(X,Y));
      //Записать: Ошибка основания базы.
      //end;
    end;
end;

//----------Икусственный интеллект -------
Constructor TAiTriggers.Create;
var i:Integer;
begin
  inherited Create;
  Player     := N;
  Bank       := @Banks[N];
  Events     := @BankofEvents[N]; 
  Bases      := @BankofBases[N];  
  Areas.RightMode := True;
  Areas.Angle     := 0;
  Areas.Over      := False;
  Areas.Player    := Player;
  for i := 1 to 3 do SetLength(N_Planes[i],0);
  ///
end;

function TAiTriggers.AreaX;
begin
  result := Areas.Data[N].X;
end;
function TAiTriggers.AreaY;
begin
  result := Areas.Data[N].Y;
end;

function TAiTriggers.PlaneX;
begin
  if N_Planes[Stype,N].Number<0 then
    result := Bases.Data[N_Planes[Stype,N].Base].X
  else
    result := CoordToSec(Samolets[N_Planes[Stype,N].Number].CoordX);
end;
function TAiTriggers.PlaneY;
begin
  if N_Planes[Stype,N].Number<0 then
    result := Bases.Data[N_Planes[Stype,N].Base].Y
  else
    result := CoordToSec(Samolets[N_Planes[Stype,N].Number].CoordY);
end;

Destructor TAiTriggers.Destroy;
begin
  inherited Destroy;
end; 
Procedure TAiTriggers.AiTurn;
var i:Integer;
b:Boolean;
begin
  //Разведка

  for i:=0 to High(N_Planes[1]) do
    if (N_Planes[1][i].Event=False) then
      if i=0 then CreatePlaneEvent(0,0) //Если нет задания , оправляем на задание
             else CreatePlaneEvent(1,i);
  if Length(N_Planes[1])<(2+Length(Bases.Data)) then b:=BuildNewPlane(1)  //Количество разведчиков = 2 + количество баз.
                                                else b := True;
  if not b then exit; // Нет денег на постройку новых разведчиков или ангаров к ним. 
  //На каждой базе нужен авиазавод. Нет таковского? И не строиться? Срочно строить! И хотя бы один ангар.
  for i := 0 to High(Bases.Data) do
   if (Length(Bases.Data[i].Avia)<1) and (Bases.Data[i].Base[14,12].plm=0) then
     begin
       b := Build(Bases.Data[i],C_AviaFactory,T_AviaFactory,2,14,12); //Строим авиазавол
       if not b then exit;
     end;
  Economics;
  ToWar;
end;

Function TAiTriggers.BuildNewPlane;
var i,j,k:Integer;
N_Hang,N_pl:Integer;
N_Avia : Integer;
Low_Avia : Integer;
NoFactory  : Boolean;
begin
  //Для каждой базы проверить - есть ли место в ангаре. 
  N_Hang := 0;
  N_Pl := 0;
  result := true;
  //В закомментированном виде мы строим пока есть производство.
  {
  //Сейчас если один самолёт строится, уже вываливаемся.
  for i := 0 to Events._High do
    begin
      if  Events.Data[i].EventType=2 then  //Если на задании строительство самолёта
      begin
        inc(N_Pl);
        j := Bases.Findbase(area[Events.Data[i].X,Events.Data[i].Y].AreaB);
        if j>=0 then
          with Bases.Data[j]  do
            if Base[Events.Data[i].X1,Events.Data[i].Y1].Regime=SType then exit; //Уже начали строить.
      end;
    end;
   }
  for i := 1 to 3 do N_Pl := N_Pl + Length(N_Planes[i]);
  for i := 0 to High(Bases.Data) do N_Hang := N_Hang + 6*Length(Bases.Data[i].Hangars);
  if true then    //if N_Hang > N_Pl then пока это не нужно. Главное, чтобы хоть один ангар был на базе.
    begin
       NoFactory  := true;    //Авиазавод загружен? Значит вываливаемся с true;
       for i := 0 to High(Bases.Data) do
        begin
         N_Hang := Length(Bases.Data[i].Hangars); //Число допступных ангаров
         if N_Hang=0 then
           begin
             if (Bases.Data[i].Base[1,9].plm<>131)  then     //Не строится ангар
               Build(Bases.Data[i],C_Hangar,T_Hangar,3,1,9,GetRegime(Stype));
             continue;
           end;
         //
         N_Avia := High(Bases.Data[i].Avia);  //Число доступных авиазаводов -1
         if  (N_Avia>0) and (Stype=3) then N_Avia :=0; //Гражданские самолёты только на заводе 1!
         if  (N_Avia>0) and (Stype=2) then Low_Avia := 1
                                      else Low_Avia := 0; //Военные самолёты только на заводе >1
         for j := Low_Avia to N_Avia   do
           if Bases.Data[i].Base[Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y].Regime=0  then
             begin
               NoFactory := False;  //Есть авиазавод для строительства
                 case Stype of
                  1: result := Build(Bases.Data[i],C_Watcher,T_Watcher,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,0);
                  2: result := Build(Bases.Data[i],C_Bomber ,T_Bomber ,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,1);
                  3: result := Build(Bases.Data[i],C_Constructor,T_Constructor,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,2);
             end;
        end;
       if (Nofactory) and (Stype=2) then  //Нет завода, а нужен бомбардировщик
       //То на все военные дельги шлёпаем авиазаводы
       begin
         for j := 0 to High(Bases.Data) do
          begin
           N_Avia := Length(Bases.Data[i].Avia)+1;  //Если есть в центре, начинаем со второго завода.
           if N_Avia<LBaseArea then
           //if N then
             if {(Length(Bases.Data[j].Avia)<2)} {and} (Bases.Data[j].Base[N_Avia,8].plm=0) then
               begin
                 result := Build(Bases.Data[j],C_AviaFactory,T_AviaFactory,2,N_Avia,8,1); //Строим авиазавод из военного бюджета
                 exit;
               end;
          end;
       end;
    end;
   end;
   {
  else
    begin
      //Нигде нет - строим ангар. 
      N_Hang := 1000; 
      k:=0;
      for i := 0 to Events._High do
       begin
         if  Events.Data[i].EventType=1 then
          begin
            j:=Bases.Findbase(area[Events.Data[i].X,Events.Data[i].Y].AreaB);
            if (j<0) then continue;//Если не находиться, значит это вообще не та база
            if (Bases.Data[j].Base[Events.Data[i].X1,Events.Data[i].Y1].plm=103) then exit; //Уже начали строить
          end;
       end;
      //Если нигде не строиться ангар, то начинаем строить.
      for i := 0 to High(Bases.Data) do
        if Length(Bases.Data[i].Hangars)<N_Hang then  //Строим там где меньше всего ангаров
          begin
            N_Hang := Length(Bases.Data[i].Hangars);
            k:=i;
          end;
      result := Build(Bases.Data[k],C_Hangar,T_Hangar,3,N_Hang+1,9,GetRegime(Stype)); //Строим ангары в ряд  - режим в отличие от типа самолёта. Работает, если меньше трёх.
    end;
  }
end;

Procedure TAiTriggers.Economics;
var i,j:Integer;
b:Boolean;
begin
  //-------Шахты
  //Для каждой базы проверяем - равна ли выработка шахт уровню регенерации.
  b := True;
  for j:=4 downto 1 do  //Сначала строим фиолетовые шахты, а потом уже и остальное
    for i:=0 to High(Bases.Data) do
      repeat
        if (Bases.Data[i].NMiners[j]*BaseMine<GetRegen(Bases.Data[i].X,Bases.Data[i].Y,j)) and   //Если меньше, то строим ещё шахту
        (Bases.Data[i].NMiners[j]+1<=LBaseArea) then //Нельзя поставить больше 25 шахт.
           b := Build(Bases.Data[i],C_Mine,T_Mine,3+j,Bases.Data[i].NMiners[j]+1,15+j,2) //Мирная постройка
        else break;

          //if not b then break;
        //end;
      until (not b) or (not VioletPriority);  //Если трудный уровень игры, сначала строим фиолетовые шахты, потом остальные.

  //-------Основатели базы
  for i:=0 to High(N_Planes[3]) do
    if N_Planes[3][i].Event=False then CreatePlaneEvent(3,i); //Если нет задания , оправляем на задание

  if not b then  exit;    //Не можем построить - на выход.
  b:=BuildNewPlane(3);  //Количество разведчиков = 2 + количество баз.
  //
  //Строим основатель базы на авиазаводе 1
     //Если на базе нет места -строим ангар. 

end;

Procedure TAiTriggers.ToWar;
var i:Integer;
b:Boolean;
begin
  //-------Бомбардировщики
  //Всем бомбардировщикам базы даём задание
    for i:=0 to High(N_Planes[2]) do
    if N_Planes[2][i].Event=False then CreatePlaneEvent(2,i); //Если нет задания , оправляем на задание
        //Строим бомбардировщик на авиазаводе 1
     //Если на базе нет места -строим ангар.
     //Если авиазавод 1 занят, строим авиазавод 2
     // 
    b:=BuildNewPlane(2);
end;

Procedure TAiTriggers.InitAreas;
//var X,Y:Byte;
begin
    Areas.AddData(PlaneX(Stype,N),PlaneY(Stype,N));
end;

Procedure TAiTriggers.CreatePlaneEvent;  //Stype,N
var
Target : Integer;
TarTIme : Integer;
Stype : Integer;
begin
  Stype := Extype;
  if Stype=0 then Stype := 1; //Приводим расширенный тип к массиву.

  if Length(Areas.Data)=0 then  InitAreas(Stype,N);
  case Extype of
    0 : 
      begin
        Areas.NextNewWatch; //Первый самолёт
        Target := High(Areas.Data);
        if Areas.GetX>=250 then  //Если всё разведали, то по второй схеме разведуем всё
          begin
            Extype := 1;
            Target := Areas.NextWatch;
          end;
      end;  
    1 : Target := Areas.NextWatch;
    2 : Target := Areas.NextTarget;
    3 : Target := Areas.NextBase;
  end;  
  //if Stype<2  //Если Target совпадает с целью создаём событие висения(и вылетаем)
  if (Stype<2) and (N_Planes[Stype,N].Number>=0) and (PlaneX(Stype,N)=AreaX(Target)) and (PlaneY(Stype,N)=AreaY(Target)) then
    begin
      if Extype=0 then TarTime := TimeToBase
                  else TarTime := TimeToResources;
      TarTime := TarTime-area[AreaX(Target),AreaY(Target)].Timerasv[Player];
      if TarTime<0 then TarTime := 1;             
      SetFlyEvent(Player,0,0,N_Planes[Stype,N].Number,True,TarTime);   //Создаём висячее событие.
      N_Planes[Stype,N].Event := True;
      exit;
    end;
  //Фактически else к той ветке.
  if Target>=0 then  //Если Targer и самолёт не запущен, то запускаем
    begin
      if N_Planes[Stype,N].Number<0 then 
        begin
          Base := Bases.Data[N_Planes[Stype,N].Base];
          //Здесь считаем позицию на базе                       f
          AiManager.PlaneToSky(Base,Base.Base[N_Planes[Stype,N].X,N_Planes[Stype,N].Y].Angar[-N_Planes[Stype,N].Number]);
          //Иногда получается несуществующий самолёт. Может быть из уничтоженной базы приписывается.
        end;
      if N_Planes[Stype,N].Number>=0 then
        begin
          SetFlyEvent(Player,SecToCoord(AreaX(Target)),SecToCoord(AreaY(Target)),N_Planes[Stype,N].Number);   //Создаём событие полёта к цели
          N_Planes[Stype,N].Event := True;
        end
      else
        begin
          LogFile.WriteToLog('Не обработан вылет самолёта');
          DeletePlane(Stype,N);
        end;
    end;
  //Если Targer = -1 и самолёт есть, отправляем на базу(в будущем)
end;

Procedure TAiTriggers.PlaneToSky;
var i:Integer;
begin
  for i:=0 to High(N_Planes[Stype]) do
    begin
      if N_Planes[Stype][i].Number>=0 then continue;
      if Bases.Data[N_Planes[Stype][i].Base].Base[N_Planes[Stype][i].X,N_Planes[Stype][i].Y].Angar[-N_Planes[Stype][i].Number]=nil then //Если самолёт только что взлетел.
        begin
          N_Planes[Stype][i].Number := Pos;//High(Samolets); //Не High,а тот, который получился
          break;
        end;         
    end;    
end;

Function TAiTriggers.FindPlane;
var i,j:Integer;
begin
  result := -1;
  for i:=1 to C_MaxPlane do
    for j:=0 to High(N_Planes[i]) do
      if N_Planes[i,j].Number = N then
      begin
        result := i;
        N := j;
        exit;
      end;
      //break;    //Нужен break из двух циклов.
end;

Procedure TAiTriggers.DeletePlane;
begin
  if N<High(N_Planes[Stype]) then N_Planes[Stype,N] := N_Planes[Stype,High(N_Planes[Stype])];
  SetLength(N_Planes[Stype],Length(N_Planes[Stype])-1);
end;


function TAiTriggers.Build;
begin
  result := false;
  if Base.Base=nil then exit;
  BankStructure.Fill(Cost);
  if Banks[Player].SpendResource(Target,BankStructure)=0 then
    begin
      If btype<100 then
        begin
          Base.Base[X1,Y1].plm := Btype+128; //+128- Значит строится
          Base.Base[X1,Y1].clr := $808080;
          if IsMine(Btype)  then inc(Base.NMiners[btype-3])
        end
      else Base.Base[X1,Y1].Regime := btype - 100;
      Event.EventType := 1+(btype div 100);
      Event.EventTime := TimeStamp + TimeToInt64(Btime);
      Event.X  := Base.X;
      Event.Y  := Base.Y;
      Event.X1 := X1;
      Event.Y1 := Y1;
      Events.AddEvent(Event);
      Base.Base[X1,Y1].TimeToPusk := Event.EventTime;//3600*24*5;
      result :=True;
    end;
end;

Procedure TAiTriggers.DestroyBase;
var i,j,N:Integer;
begin
  N := Bases.FindBase(DBase);
  for i:=0 to Events.GetLength-1 do  //Стираем все события , свящанные с удаляемой базой
    if (Events.Data[i].EventType<3) and (Bases.Data[N].X=Events.Data[i].X) and (Bases.Data[N].Y=Events.Data[i].Y)  then
      Events.Reset(i); //Сбрасываем событие на пустое.
  Bases.DestroyBase(N);
  if Length(Bases.Data)=0 then  Surrender
  else  //Меняем базу для все самолётов
  for i:=1 to C_MaxPlane do
   for j:=0 to High(N_Planes[i]) do
     if N_Planes[i,j].Base>High(Bases.Data) then
       N_Planes[i,j].Base := N;
end;


Procedure TAiTriggers.Surrender;
var i:Integer;
begin
  Events.Destroy;
  for i := 0 to High(Samolets) do AiManager.DeletePlane(Player,i);
  for i := 1 to 3 do  SetLength(N_Planes[i],0);
    //if Samolets^[i]. the
end;

procedure TAiTriggers.Save;
var i,j,k :SmallInt;
begin
   Bank.Save(F);
   Events.Save(F);
   Bases.Save(F);
   Areas.Save(F);
   for i := 1 to C_MaxPlane do
     begin
       k := Length(N_planes[i]);
       BlockWrite(F,k,SizeOf(SmallInt));
       BlockWrite(F,N_planes[i,0],Sizeof(TPlaneControl)*k);
     end;
end;

procedure TAiTriggers.Load;
var i,j,k :SmallInt;
begin
  Bank.Load(F);
  Events.Load(F);
  Bases.Load(F);
  Areas.Load(F);
    for i := 1 to C_MaxPlane do
     begin
       BlockRead(F,k,SizeOf(SmallInt));
       SetLength(N_planes[i],k);
       BlockRead(F,N_planes[i,0],Sizeof(TPlaneControl)*k);
     end;
end;

Procedure TAiTriggers.UpdateRes;
var
i,j:Integer;
Res : Integer;
begin
  for i:=1 to 4 do
    begin
      Res:=0;
      for j:=0 to High(Bases.Data) do  Res:=Res+Bases.Data[j].Miners[i]; //Пока здесь хрень
      Bank.AddResource(i,Res*Time);
    end;
end;


begin
end.