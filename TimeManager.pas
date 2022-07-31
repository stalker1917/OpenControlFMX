// By Stalker1917  LGPL 3.0
Unit TimeManager;

interface
uses ControlConsts,SysUtils,Debug;

type
TTimeRecord = record
  Days,Hours,Minutes,Seconds : Word;
end;

const 
T_High : Int64 = Int64(3600*24)*100000;
//�������
T_Watcher       : TTimeRecord = 
(
 Days    : 0;
 Hours   : 11;
 Minutes : 0;
 Seconds : 0; 
);
T_Bomber        : TTimeRecord = 
(
 Days    : 1;
 Hours   : 1;
 Minutes : 0;
 Seconds : 0; 
);
T_Constructor   : TTimeRecord = 
(
 Days    : 1;
 Hours   : 4;
 Minutes : 0;
 Seconds : 0; 
);
//������
T_AviaFactory   : TTimeRecord = 
(
 Days    : 5;
 Hours   : 0;
 Minutes : 0;
 Seconds : 0; 
);
T_Hangar        : TTimeRecord = 
(
 Days    : 4;
 Hours   : 0;
 Minutes : 0;
 Seconds : 0; 
);
T_Mine          : TTimeRecord = 
(
 Days    : 2;
 Hours   : 0;
 Minutes : 0;
 Seconds : 0; 
);

//
type
TEvent = record  // ����� Object c ������ ����������� �������
EventTime : Int64;
EventType : Byte; 
{0-������ ������� 
1-��������� ������ 
2-��������� ������� 
3-����� �������.  
4-������ ������������ ���������� �������� ��� ���������
5-��������. 
}
X,Y : Byte;  //� ����� �������� �������
X1,Y1 : Byte; // � ����� ����������� �������      //��� ������� - ����� �������=X1*256+Y1;
end;

TEvents = Array of TEvent;

TStackOfEvent=object
  private
  FData : TEvents;
  public
  procedure AddEvent(Event:TEvent);
  function GetEvent:TEvent;
  function GetPlaneNumber:Word;
  //procedure SetPlaneNumber(N:Word);
  procedure DeleteEvent;
  procedure Destroy;
  procedure Load(var F:TBFile);
  procedure Save(var F:TBFile);
  procedure Reset(i:Integer);
  function GetData(Index: Integer): TEvent;
  function GetLength:word;
  function _High : Integer;
  property Data[Index:Integer]  : TEvent  read GetData;
  function FindEvent(X,Y,X1,Y1:Byte) :TEvent;
  function TimeToEvent(X,Y,X1,Y1:Byte): Int64;
end;

PStackOfEvent=^TStackofEvent;



function Int64ToTime(i:Int64):TTimeRecord;
Function Time60ToStr(i:Word):String;
function Int64ToString(i:Int64):String;
function TimeToInt64(const A_Time:TTimeRecord):Int64;
function TimeToStr(const A_Time:TTimeRecord):String;
function TimeToBuild(const A_Time:TTimeRecord):String;
function Int64ToEnd(i:Int64):String;
function GetMinEvents:Byte;
function Int64ToRtime(Time1,Time2:Int64):Integer;
procedure SetPlaneNumber(var Event:TEvent; N:Word);
function TestEvent(var E:TEvent):Boolean;
procedure DebugEvent(var E:TEvent);


var 
  TimeStamp : Int64;
  OldStamp : Int64;
  //SolveStamp : Int64;
  BankOfEvents : Array [1..NPlayers] of TStackOfEvent;
  Event : TEvent;
 
  

implementation

//--------TStackOfEvent
function TStackOfEvent._High;
begin
  result := High(FData);
end;

function TStackOfEvent.GetData;
begin
  result := FData[Index];
end;

procedure TStackOfEvent.AddEvent;
begin
  SetLength(FData,Length(FData)+1);
  if (High(FData)>0) and (FData[High(FData)-1].EventTime<Event.EventTime) then
    begin
      FData[High(FData)]  := FData[High(FData)-1];
      FData[High(FData)-1] := Event;
    end
  else  FData[High(FData)] := Event;
end;

function TStackOfEvent.GetEvent;
begin
  if Length(FData)>0 then result := FData[High(FData)]
  else result.EventType := 0; //������ �������.
end;

procedure TStackOfEvent.DeleteEvent;
var
min : Int64;
i,mini : Integer;
begin
  if (High(FData)>1) then
    begin
      min := T_High; // �����- 100 000 ����
      mini := -1;
      for i:=0 to High(FData)-1 do
        if FData[i].EventTime<min then
          begin
            mini := i;
            min := FData[i].EventTime;
          end;  
     FData[High(FData)] := Data[mini];
     FData[mini] := FData[High(FData)-1];
     FData[High(FData)-1] := Data[High(FData)]; //����� ��������� �����
    end; 
  SetLength(FData,Length(FData)-1);
end; 


function TStackOfEvent.GetPlaneNumber;
begin
  if (High(FData)>=0)  then result :=  Fdata[High(FData)].X1*256+Fdata[High(FData)].Y1 ;
end;

procedure TStackOfEvent.Destroy;
begin
  SetLength(FData,0);
  //FData[0].EventType := 0;
end;

Procedure TStackOfEvent.Load;
var i:SmallInt;
begin
  BlockRead(F,i,2);
  SetLength(FData,i);
  for I := Low(FData) to High(FData) do BlockRead(F,FData[i],SizeOf(TEvent));
end;

Procedure TStackOfEvent.Save;
var i:SmallInt;
begin
  i := Length(FData);
  BlockWrite(F,i,2);
  for I := Low(FData) to High(FData) do BlockWrite(F,FData[i],SizeOf(TEvent));
end;

function TStackOfEvent.GetLength: Word;
begin
  result := Length(FData);
end;

Procedure TStackOfEvent.Reset(i: Integer);

begin
  FData[i].EventType := 0;
end;

function TStackOfEvent.FindEvent;
var
i:Integer;
begin
  result.EventType := 255;// ��������� �������
  for I := 0 to High(FData) do
    if (FData[i].X=X) and (FData[i].Y=Y)  then
      if (FData[i].X1=X1) and (FData[i].Y1=Y1)  then
        begin
          result := FData[i];
          exit;
        end;
end;

function TStackOfEvent.TimeToEvent;
var PrEvent : TEvent;
begin
  PrEvent := FindEvent(X,Y,X1,Y1);
  if PrEvent.EventType=255 then result := 0
                           else result := PrEvent.EventTime-Timestamp;
end;


//----------����������� ������� ------
procedure SetPlaneNumber; //������ ������
begin
  // if (High(FData)>0)  then
    // begin
       Event.X1 :=  N div 256;
       Event.Y1 :=  N mod 256;
    // end;
end;
function Int64ToTime;
begin
  if i<0 then i := 0;
  result.Days := i div (3600*24);
  i := i mod (3600*24);
  result.Hours := i div 3600;
  i := i mod 3600;
  result.Minutes := i div 60;
  result.Seconds := i mod 60;
end;

function TimeToInt64;
begin
  result := A_Time.Days*3600*24+A_Time.Hours*3600+A_Time.Minutes*60+A_Time.Seconds;
end;

Function Time60ToStr;
begin
  if i<10 then result:='0'+IntToStr(i)
          else result:=IntToStr(i);
end;

Function TimeToStr;
begin
  result := '';
  result := '���� '+IntToStr(A_time.Days)+' ';
  result := result+Time60ToStr(A_time.Hours)+':';
  result := result+Time60ToStr(A_time.Minutes)+':';
  result := result+Time60ToStr(A_time.Seconds)+' :';
end;

function TimeToBuild;
var
i:Integer;
begin
 i := 0;
 result := '';
 if A_time.Days>0 then result := result+IntToStr(A_time.Days)+' �. '
                else inc(i);
 if A_time.Hours>0 then result := result+IntToStr(A_time.Hours)+' �. '
                else inc(i); 
 if (i>0) and (A_time.Minutes>0) then result := result+IntToStr(A_time.Minutes)+' �. ';
 if (i>1) and (A_time.Seconds>0) then result := result+IntToStr(A_time.Seconds)+' �. ';
end;

function Int64ToString;
begin
  result :=  TimeToStr(Int64ToTime(i));
end;

function Int64ToEnd;
begin
  result := TimeToBuild(Int64ToTime(i-Timestamp));
end;

function GetMinEvents;
var i,mini:Integer;
min : Int64;
begin
  Min := T_High;
  Mini := 0;
  for i := 1 to NPlayers do
  //������� ������� ���� �������.
   if {(BankofEvents[i].GetEvent.EventType>0)   and }(BankofEvents[i].GetEvent.EventTime<Min) then
     begin
       Mini := i;
       Min := BankofEvents[i].GetEvent.EventTime;
     end; 
 result := Mini;
end;

function Int64ToRtime;
var
T1,T2: TTimeRecord;
begin
  T1 := Int64ToTime(Time1);
  T2 := Int64ToTime(Time2);
  result := (T1.Days-T2.Days)*24+(T1.Hours-T2.Hours); //�������� ����� ���� � ������ 
  if result<0 then Result := 0;
end;

function TestEvent;
begin
  result := True;
  result := result and (E.X>0) and (E.X<=LArea);
  result := result and (E.Y>0) and (E.Y<=LArea);
  if (E.EventType>0) and (E.EventType<3) then  //����� ���������� ����
    begin
     result := result and (E.X1>0) and (E.X1<=LBaseArea);
     result := result and (E.Y1>0) and (E.Y1<=LBaseArea);
    end;
end;

procedure DebugEvent;
begin
  LogFile.WriteToLog('C������ ��������� ����:');
  LogFile.WriteToLog('����� �������: '+IntToStr(E.EventTime));
  LogFile.WriteToLog('��� �������: '+IntToStr(E.EventType));
  LogFile.WriteToLog('���������� ���� X: '+IntToStr(E.X));
  LogFile.WriteToLog('���������� ���� Y: '+IntToStr(E.Y));
  LogFile.WriteToLog('���������� ������ X: '+IntToStr(E.X1));
  LogFile.WriteToLog('���������� ������ Y: '+IntToStr(E.Y1));
  Event.EventType := 0;
end;

begin
end.