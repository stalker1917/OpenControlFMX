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
  Number : Integer; //����� � ��������, ���� �������. ���� ���-�� ������� � ������. 
  Base   : Integer; //����� ����, ���� � ����
  X,Y    : Integer; //��������� ������ �� ����.
  Event  : Boolean; //�� ������� ��� ���. 
  //OnBuild : Boolean; //��� ���������! 
end;

TPlaneArray = Array of TPlaneControl;

type TAiTriggers = class(TObject)
  Player     : Byte;
  Bank       : PBank;
  Events     : PStackOfEvent;
  Bases      : PStackofBases;
  Areas      : TStackofArea;
  //T�������
  N_Planes : Array[1..C_MaxPlane] of TPlaneArray;
  Procedure AiTurn;
  Procedure PlaneToSky(Stype:Byte;Pos:Integer);
  procedure Economics;
  procedure ToWar; 
  function Build(var Base :TBase; const Cost:TConstRes;const BTime:TTimeRecord; BType:byte;X1,Y1:Integer; Target:Byte=0):Boolean;  // ������ ���-������//100-c�����
  function BuildNewPlane(SType:Integer):Boolean;
  //procedure CheckHangar(N:Byte); //����� ������� �� ���������+����� ������� ���������� � ������� � ������  N-����� ����  //��
  procedure CreatePlaneEvent(Extype:Byte;N:Integer);
  procedure InitAreas(Stype:Byte;N:Integer);
  function FindPlane(var N:Integer):Integer;
  procedure DeletePlane(Stype,N:Integer);// ������� ������ �� ��� ������ � ��������.
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

//������ ��������� ��������������� , �������� ������ ��� 1
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


//------------�����������-----------


Procedure ResPlanes(OldTime:Int64);
var RTime : Int64;
i:Integer;
begin
 Rtime := Int64ToRtime(Timestamp,OldTime);
 if Rtime>0  then  for i := 1 to NPlayers do BankofTrigers[i].UpdateRes(Rtime); //UpdateRes(i,Rtime); //���������� ��������
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
        if (TarX<>CoordX) or (TarY<>CoordY) then    //��� �� X ��� �� Y ���������� ����������.
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
        //���� ���������������� ����������� � ���� 100% , �� ��� ���� ���������.      
end;

Procedure EndSolveEvent(N:Integer);
begin
  BankofEvents[N].DeleteEvent;
  OldStamp := TimeStamp;
end;

Procedure SolveEvent;   //����� ������
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
if NBase>=0 then Base := @BankofBases[N].Data[Nbase] //���� ���� �������
            else Base := nil;
//begin

//SolvePlanes(Timestamp-OldStamp); //��������� ��������� ����� ��������
//if Base<>nil then //������� ���
case Event.EventType of
  1:  //��������� ������
    begin
      //Base.Base := ;
      if Base=nil then
        begin
          // ��������� �������� �� ������������ ����
          EndSolveEvent(N);
          exit; //������ ������� ������
        end;
      i := Base.Base[Event.X1,Event.Y1].plm;
      if i>=128 then i := i - 128; //+�������� ����
      if N=1 then PutLog(Int64ToString(TimeStamp)+' ��������� ������ � �������� '+XYTOStr(Event.X,Event.Y));
      if i>0 then Base.Base[Event.X1,Event.Y1].clr := BuildCols[i];
      Base.Base[Event.X1,Event.Y1].plm := i;
      Base.Base[Event.X1,Event.Y1].Regime := 0;
      if IsMine(i) then  BankofBases[N].RefreshMiners(Nbase);
      if IsHangar(Event.X1,Event.Y1,Base.Base)then
        begin
          BankofBases[N].RefreshHangars(Event.X1,Event.Y1,Nbase);   //���� �����, ��������� � ������ �������.
          for j := Low(Base.Base[Event.X1,Event.Y1].Angar) to High(Base.Base[Event.X1,Event.Y1].Angar) do
            Base.Base[Event.X1,Event.Y1].Angar[j] := nil;
        end;
      if IsAvia(Event.X1,Event.Y1,Base.Base) then BankofBases[N].RefreshAvia(Event.X1,Event.Y1,Nbase); //���� ���������, ��������� � ������ �����������.
    end;
  2:  //��������� �������
    begin
        if Base=nil then
          begin
            EndSolveEvent(N);
            exit; //������ ������� ������
          end;
       k:=100;  //���� ��� � ��������� ������ � ������ ��� �����.
       for  j:=0 to High(Base.Hangars) do
       begin
         Angar :=  Base.Hangars[j].Hangar;//  ����� ������ ������ ��������
       i := 1; //������� � ������ ���������� � 1-�� ��������
       repeat
         if Angar[i]=nil then
           begin
             EStype := Base.Base[Event.X1,Event.Y1].Regime;
             if (EStype<1) or  (EStype>C_MaxPlane)  then //��� ����� ����� �������� ��� Regime=0 , �� ���� � ��� ����������.
               //LogFile.WriteToLog('�������� ������ ��������� ����'+IntToStr(EStype)+'� ����������� '+IntToStr(Event.X1)+':'+IntToStr(Event.Y1))
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
       until (i>6); // ��������� �� ����� �������!
       if i<0 then  break;
       end;
       
      Base.Base[Event.X1,Event.Y1].Regime := 0;
      if N=1 then
         if k<100 then PutLog(Int64ToString(TimeStamp)+' �������� ������ � �������� '+XYTOStr(Event.X,Event.Y))
                  else PutLog(Int64ToString(TimeStamp)+' ��� ����� � ������ '+XYTOStr(Event.X,Event.Y));
      If (BankofTrigers[N]<>nil) and (k<100) then
        begin
          SetLength(BankofTrigers[N].N_Planes[Angar[k].Stype],Length(BankofTrigers[N].N_Planes[Angar[k].Stype])+1);
          with  BankofTrigers[N].N_Planes[Angar[k].Stype][High(BankofTrigers[N].N_Planes[Angar[k].Stype])]  do
            begin
              Event := False;
              Base := Nbase;
              X := {AiManager.}BankofBases[N].Data[Nbase].Hangars[j].X; //����� ������ base �������, �.�. with
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
              if j>=0 then BankofTrigers[N].N_Planes[Stype,k].Event := False; //C��������� �������
              if (Stype=2) then   // ���������� ����. ������������� �������, �������� ���-������ � ���� � ���������.
                Bombing(N,i,Event.X,Event.Y);
              {if (area[Event.X,Event.Y].plm>0) and (area[Event.X,Event.Y].plm<>N) then
                begin
                  area[Event.X,Event.Y].areab[12,12].HitPoints := area[Event.X,Event.Y].areab[12,12].HitPoints - H_Bomb;
                  DeletePlane(N,i);
                  if area[Event.X,Event.Y].areab[12,12].HitPoints<=0 then BankofTrigers[area[Event.X,Event.Y].plm].DestroyBase(area[Event.X,Event.Y].areab);
                end;  }
              if (Stype=3) and (bombs=1) then    //��� ���������� ���� � ������ �������� ���� , � �� ������ ������ � �������.
                FoundBase(N,i,Event.X,Event.Y);
              {if area[Event.X,Event.Y].plm=0 then
                begin
                  NewBase(Event.X,Event.Y,plm,True);
                  if N=1 then PutLog(Int64ToString(TimeStamp)+' ������� �������� ���� � �������� '+XYTOStr(Event.X,Event.Y));
                  DeletePlane(N,i);

                 //�������� - ���� �������� �������.
                end
              else
                begin
                  bombs := 0; //������ ������ �� "������ � �����"
                  if N=1 then PutLog(Int64ToString(TimeStamp)+' ������ ��������� ���� � �������� '+XYTOStr(Event.X,Event.Y));
                //��������: ������ ��������� ����.
                end; }
              end;
      end; 
    5: 
      begin
        i := BankofEvents[N].GetPlaneNumber; //���� ����� ������ ���������� ������� � �����. ��� ����� �.�. ��������� ����� � ���������� ��������
        j := BankofTrigers[N].FindPlane(i);
        //if j<0 then  break;
        if j>=0 then BankofTrigers[N].N_Planes[j,i].Event := False; //�������� �������
        if N=1 then PutLog(Int64ToString(TimeStamp)+' ������� ��������� �������� � �������� '+XYTOStr(Event.X,Event.Y));
      end;  
  end;

EndSolveEvent(N);
end;

procedure DeletePlane;
var
Stype,Num:Integer;
begin
  if Samolets[N] = nil then exit;//������� ��� �������� ������
  if Samolets[N].plm<>Player then exit; //������� ����� ������
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

Procedure PutLog(S:String); //��������� ������ � ��� �������� ������
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
       LogFile.WriteToLog('������� ��������� �������������� ������');
       exit;
     end;
  if  (Samolet.Stype<1) or (Samolet.Stype>C_MaxPlane) then
    begin
      LogFile.WriteToLog('������� ��������� ������ ��������� ����'+IntToStr(Samolet.Stype));
      Samolet:= nil;
      exit;
    end;
  //SetLength(Samolets,Length(Samolets)+1);
  M := AddPlane;
  Samolets[M] := Samolet;  //����������� ������=a���������� ������
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
    //������� �������
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
   // BankofEvents[Player].SetPlaneNumber(N); //������ ������
    if (not Hang) and (Stype=3) and (area[Event.X,Event.Y].plm=0) and (area[Event.X,Event.Y].Timerasv[Player]>TimeToBase)  then     //ec�� ���������� � ���� ����� ��������
      if plm>1 then Bombs := 1;    //���������� ����, ���� ����� >1
  end;  
end;

Procedure Bombing;  //�������������
begin
// ���������� ����. ������������� �������, �������� ���-������ � ���� � ���������.
  if (area[X,Y].plm>0) and (area[X,Y].plm<>Player) then
    begin
      area[X,Y].areab[12,12].HitPoints := area[X,Y].areab[12,12].HitPoints - H_Bomb;
      DeletePlane(Player,N);
      if area[X,Y].areab[12,12].HitPoints<=0 then
        BankofTrigers[area[X,Y].plm].DestroyBase(area[X,Y].areab);
    end;
end;

Procedure FoundBase; //�������� ����
begin
  if area[X,Y].plm=0 then
    begin
      //NewBase(X,Y,Samolets[N].plm,True);
      BankofBases[Samolets[N].plm].NewBase(X,Y,Samolets[N].plm,True);
      if N=1 then PutLog(Int64ToString(TimeStamp)+' ������� �������� ���� � �������� '+XYTOStr(X,Y));
      DeletePlane(Player,N);
      //�������� - ���� �������� �������.
    end
  else
    begin
      Samolets[N].bombs := 0; //������ ������ �� "������ � �����"
      if N=1 then PutLog(Int64ToString(TimeStamp)+' ������ ��������� ���� � �������� '+XYTOStr(X,Y));
      //��������: ������ ��������� ����.
      //end;
    end;
end;

//----------������������ ��������� -------
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
  //��������

  for i:=0 to High(N_Planes[1]) do
    if (N_Planes[1][i].Event=False) then
      if i=0 then CreatePlaneEvent(0,0) //���� ��� ������� , ��������� �� �������
             else CreatePlaneEvent(1,i);
  if Length(N_Planes[1])<(2+Length(Bases.Data)) then b:=BuildNewPlane(1)  //���������� ����������� = 2 + ���������� ���.
                                                else b := True;
  if not b then exit; // ��� ����� �� ��������� ����� ����������� ��� ������� � ���. 
  //�� ������ ���� ����� ���������. ��� ����������? � �� ���������? ������ �������! � ���� �� ���� �����.
  for i := 0 to High(Bases.Data) do
   if (Length(Bases.Data[i].Avia)<1) and (Bases.Data[i].Base[14,12].plm=0) then
     begin
       b := Build(Bases.Data[i],C_AviaFactory,T_AviaFactory,2,14,12); //������ ���������
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
  //��� ������ ���� ��������� - ���� �� ����� � ������. 
  N_Hang := 0;
  N_Pl := 0;
  result := true;
  //� ������������������ ���� �� ������ ���� ���� ������������.
  {
  //������ ���� ���� ������ ��������, ��� ������������.
  for i := 0 to Events._High do
    begin
      if  Events.Data[i].EventType=2 then  //���� �� ������� ������������� �������
      begin
        inc(N_Pl);
        j := Bases.Findbase(area[Events.Data[i].X,Events.Data[i].Y].AreaB);
        if j>=0 then
          with Bases.Data[j]  do
            if Base[Events.Data[i].X1,Events.Data[i].Y1].Regime=SType then exit; //��� ������ �������.
      end;
    end;
   }
  for i := 1 to 3 do N_Pl := N_Pl + Length(N_Planes[i]);
  for i := 0 to High(Bases.Data) do N_Hang := N_Hang + 6*Length(Bases.Data[i].Hangars);
  if true then    //if N_Hang > N_Pl then ���� ��� �� �����. �������, ����� ���� ���� ����� ��� �� ����.
    begin
       NoFactory  := true;    //��������� ��������? ������ ������������ � true;
       for i := 0 to High(Bases.Data) do
        begin
         N_Hang := Length(Bases.Data[i].Hangars); //����� ���������� �������
         if N_Hang=0 then
           begin
             if (Bases.Data[i].Base[1,9].plm<>131)  then     //�� �������� �����
               Build(Bases.Data[i],C_Hangar,T_Hangar,3,1,9,GetRegime(Stype));
             continue;
           end;
         //
         N_Avia := High(Bases.Data[i].Avia);  //����� ��������� ����������� -1
         if  (N_Avia>0) and (Stype=3) then N_Avia :=0; //����������� ������� ������ �� ������ 1!
         if  (N_Avia>0) and (Stype=2) then Low_Avia := 1
                                      else Low_Avia := 0; //������� ������� ������ �� ������ >1
         for j := Low_Avia to N_Avia   do
           if Bases.Data[i].Base[Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y].Regime=0  then
             begin
               NoFactory := False;  //���� ��������� ��� �������������
                 case Stype of
                  1: result := Build(Bases.Data[i],C_Watcher,T_Watcher,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,0);
                  2: result := Build(Bases.Data[i],C_Bomber ,T_Bomber ,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,1);
                  3: result := Build(Bases.Data[i],C_Constructor,T_Constructor,Stype+100,Bases.Data[i].Avia[j].X,Bases.Data[i].Avia[j].Y,2);
             end;
        end;
       if (Nofactory) and (Stype=2) then  //��� ������, � ����� ��������������
       //�� �� ��� ������� ������ ������ ����������
       begin
         for j := 0 to High(Bases.Data) do
          begin
           N_Avia := Length(Bases.Data[i].Avia)+1;  //���� ���� � ������, �������� �� ������� ������.
           if N_Avia<LBaseArea then
           //if N then
             if {(Length(Bases.Data[j].Avia)<2)} {and} (Bases.Data[j].Base[N_Avia,8].plm=0) then
               begin
                 result := Build(Bases.Data[j],C_AviaFactory,T_AviaFactory,2,N_Avia,8,1); //������ ��������� �� �������� �������
                 exit;
               end;
          end;
       end;
    end;
   end;
   {
  else
    begin
      //����� ��� - ������ �����. 
      N_Hang := 1000; 
      k:=0;
      for i := 0 to Events._High do
       begin
         if  Events.Data[i].EventType=1 then
          begin
            j:=Bases.Findbase(area[Events.Data[i].X,Events.Data[i].Y].AreaB);
            if (j<0) then continue;//���� �� ����������, ������ ��� ������ �� �� ����
            if (Bases.Data[j].Base[Events.Data[i].X1,Events.Data[i].Y1].plm=103) then exit; //��� ������ �������
          end;
       end;
      //���� ����� �� ��������� �����, �� �������� �������.
      for i := 0 to High(Bases.Data) do
        if Length(Bases.Data[i].Hangars)<N_Hang then  //������ ��� ��� ������ ����� �������
          begin
            N_Hang := Length(Bases.Data[i].Hangars);
            k:=i;
          end;
      result := Build(Bases.Data[k],C_Hangar,T_Hangar,3,N_Hang+1,9,GetRegime(Stype)); //������ ������ � ���  - ����� � ������� �� ���� �������. ��������, ���� ������ ���.
    end;
  }
end;

Procedure TAiTriggers.Economics;
var i,j:Integer;
b:Boolean;
begin
  //-------�����
  //��� ������ ���� ��������� - ����� �� ��������� ���� ������ �����������.
  b := True;
  for j:=4 downto 1 do  //������� ������ ���������� �����, � ����� ��� � ���������
    for i:=0 to High(Bases.Data) do
      repeat
        if (Bases.Data[i].NMiners[j]*BaseMine<GetRegen(Bases.Data[i].X,Bases.Data[i].Y,j)) and   //���� ������, �� ������ ��� �����
        (Bases.Data[i].NMiners[j]+1<=LBaseArea) then //������ ��������� ������ 25 ����.
           b := Build(Bases.Data[i],C_Mine,T_Mine,3+j,Bases.Data[i].NMiners[j]+1,15+j,2) //������ ���������
        else break;

          //if not b then break;
        //end;
      until (not b) or (not VioletPriority);  //���� ������� ������� ����, ������� ������ ���������� �����, ����� ���������.

  //-------���������� ����
  for i:=0 to High(N_Planes[3]) do
    if N_Planes[3][i].Event=False then CreatePlaneEvent(3,i); //���� ��� ������� , ��������� �� �������

  if not b then  exit;    //�� ����� ��������� - �� �����.
  b:=BuildNewPlane(3);  //���������� ����������� = 2 + ���������� ���.
  //
  //������ ���������� ���� �� ���������� 1
     //���� �� ���� ��� ����� -������ �����. 

end;

Procedure TAiTriggers.ToWar;
var i:Integer;
b:Boolean;
begin
  //-------���������������
  //���� ���������������� ���� ��� �������
    for i:=0 to High(N_Planes[2]) do
    if N_Planes[2][i].Event=False then CreatePlaneEvent(2,i); //���� ��� ������� , ��������� �� �������
        //������ �������������� �� ���������� 1
     //���� �� ���� ��� ����� -������ �����.
     //���� ��������� 1 �����, ������ ��������� 2
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
  if Stype=0 then Stype := 1; //�������� ����������� ��� � �������.

  if Length(Areas.Data)=0 then  InitAreas(Stype,N);
  case Extype of
    0 : 
      begin
        Areas.NextNewWatch; //������ ������
        Target := High(Areas.Data);
        if Areas.GetX>=250 then  //���� �� ���������, �� �� ������ ����� ��������� ��
          begin
            Extype := 1;
            Target := Areas.NextWatch;
          end;
      end;  
    1 : Target := Areas.NextWatch;
    2 : Target := Areas.NextTarget;
    3 : Target := Areas.NextBase;
  end;  
  //if Stype<2  //���� Target ��������� � ����� ������ ������� �������(� ��������)
  if (Stype<2) and (N_Planes[Stype,N].Number>=0) and (PlaneX(Stype,N)=AreaX(Target)) and (PlaneY(Stype,N)=AreaY(Target)) then
    begin
      if Extype=0 then TarTime := TimeToBase
                  else TarTime := TimeToResources;
      TarTime := TarTime-area[AreaX(Target),AreaY(Target)].Timerasv[Player];
      if TarTime<0 then TarTime := 1;             
      SetFlyEvent(Player,0,0,N_Planes[Stype,N].Number,True,TarTime);   //������ ������� �������.
      N_Planes[Stype,N].Event := True;
      exit;
    end;
  //���������� else � ��� �����.
  if Target>=0 then  //���� Targer � ������ �� �������, �� ���������
    begin
      if N_Planes[Stype,N].Number<0 then 
        begin
          Base := Bases.Data[N_Planes[Stype,N].Base];
          //����� ������� ������� �� ����                       f
          AiManager.PlaneToSky(Base,Base.Base[N_Planes[Stype,N].X,N_Planes[Stype,N].Y].Angar[-N_Planes[Stype,N].Number]);
          //������ ���������� �������������� ������. ����� ���� �� ������������ ���� �������������.
        end;
      if N_Planes[Stype,N].Number>=0 then
        begin
          SetFlyEvent(Player,SecToCoord(AreaX(Target)),SecToCoord(AreaY(Target)),N_Planes[Stype,N].Number);   //������ ������� ����� � ����
          N_Planes[Stype,N].Event := True;
        end
      else
        begin
          LogFile.WriteToLog('�� ��������� ����� �������');
          DeletePlane(Stype,N);
        end;
    end;
  //���� Targer = -1 � ������ ����, ���������� �� ����(� �������)
end;

Procedure TAiTriggers.PlaneToSky;
var i:Integer;
begin
  for i:=0 to High(N_Planes[Stype]) do
    begin
      if N_Planes[Stype][i].Number>=0 then continue;
      if Bases.Data[N_Planes[Stype][i].Base].Base[N_Planes[Stype][i].X,N_Planes[Stype][i].Y].Angar[-N_Planes[Stype][i].Number]=nil then //���� ������ ������ ��� �������.
        begin
          N_Planes[Stype][i].Number := Pos;//High(Samolets); //�� High,� ���, ������� ���������
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
      //break;    //����� break �� ���� ������.
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
          Base.Base[X1,Y1].plm := Btype+128; //+128- ������ ��������
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
  for i:=0 to Events.GetLength-1 do  //������� ��� ������� , ��������� � ��������� �����
    if (Events.Data[i].EventType<3) and (Bases.Data[N].X=Events.Data[i].X) and (Bases.Data[N].Y=Events.Data[i].Y)  then
      Events.Reset(i); //���������� ������� �� ������.
  Bases.DestroyBase(N);
  if Length(Bases.Data)=0 then  Surrender
  else  //������ ���� ��� ��� ��������
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
      for j:=0 to High(Bases.Data) do  Res:=Res+Bases.Data[j].Miners[i]; //���� ����� �����
      Bank.AddResource(i,Res*Time);
    end;
end;


begin
end.