unit Debug;   //Много аппартано зависимого кода.
//{$Define Realise}
interface
uses {Chart,}{StdCtrls,}SysUtils,Math{,ReadPack}
{$IFDEF ANDROID}
 ,Posix.SysTime,Posix.Time,System.IOUtils;
 {$ELSE}
 ,Windows,ADODB;
{$ENDIF}


 // {$IFDEF Realise}
//  ReadPackR;
 // {$ELSE}
 // ReadPack;
  //{$ENDIF}

type TLogFile = Object
 // Filelog : Text;
  Debug : Boolean;
  procedure Init(Smode:Boolean; Dlog : Boolean; S:String='Log');
  procedure ChangeLogStop(Smode : Boolean);
  procedure WriteToLog(S:String);
  procedure WriteLogStop(S:String);
  procedure WriteSafe(S:String);  //Выводить ошибки прои обращении к HID
  procedure WriteDebug(S:String);
  procedure WriteErrCount(TimesTamp:LongInt);
  procedure Stop;
  procedure PutFullData(WriteNoise:Boolean);

protected
  Opened : Boolean;
  LogStop : Boolean;
  SafeWriteDebug : Boolean;
  FullLogofSensors : Boolean;
  Filelog : Text;  //Файл лога, куда будет записывать.
End;

type TTextFile = Object(TLogFile)
 YesWriteLevels : Boolean;
 procedure Init(Smode:Boolean);
 procedure Init2;
 procedure WriteLevels(Detect:Boolean);
 protected

End;


{$IFNDEF ANDROID}
var
  ConfigVersion        : Integer = -1;
  RawMode              : Integer = 8;
{$ENDIF}

const
   Zones : array[0..2] of String = ('Right','Left','Center');

var
 // SystemT         : SystemTime;
  LogFile         : TLogFile;
  TextFile        : TTextFile;
  TrueMax         : Array[0..2,0..3] of Double;
 // PairDebug       : Array[0..NumberOfPairs+VirtualZone] of Double; //  Выводимые значения
 // PairDebugMax    : Array[0..NumberOfPairs+VirtualZone] of Double; //  Выводимые значения
  PercentOfSincro : Double = 50;
 // LiesA2  : Array[0..NumberOfPairs+VirtualZone] of longword;  //Число ложняков
  ProhCount : longword = 0;// Число проходов
  ReactCount : longword = 0;//Число срабатываний
  ReadFileName    : String;

function  GetDateString : String;
function  GetDateInt : Integer;
function  GetTimeString : String;
function  GetDebugPath: String;

implementation

procedure  TLogFile.Init;
var
{$IFDEF ANDROID}
LogFName : String;
 {$ELSE}
LogFName : AnsiString;
{$ENDIF}
TimeString : String;
i : Integer;
begin
  //Now();
  TimeString := GetDateString;
  //GetSystemTime(SystemT);
  i:=0;
  repeat
    LogFName:=S+TimeString+'_'+Inttostr(i)+'.txt';
    inc(i);
  until not FileExists(LogFName);
  AssignFIle(Filelog,LogFName);
  Rewrite(Filelog);
  Opened := True;
  LogStop := Smode; // Можно сделать из ini   или по SrvMode
  SafeWriteDebug :=True;
  Debug :=Dlog;
  FullLogofSensors :=True;
end;

{$IFDEF ANDROID}
function GetAndroidUT:tm;
var
  T: time_t;
  TV: timeval;
  UT: tm;
begin
  gettimeofday(TV, nil);
  T := TV.tv_sec;
  localtime_r(T, UT);
  Result := UT;
end;
{$ENDIF}
function GetDateString;
{$IFDEF ANDROID}
var
  UT: tm;
begin
  UT := GetAndroidUT;
  Result :=  InttoStr(UT.tm_year-100)+'_'+InttoStr(UT.tm_mon+1)+'_'+InttoStr(UT.tm_mday);
end;
 {$ELSE}
var SystemT : SystemTime;
begin
  GetSystemTime(SystemT);
  Result := InttoStr(SystemT.wYear)+'_'+InttoStr(SystemT.wmonth)+'_'+InttoStr(SystemT.wDay mod 100);
end;
{$ENDIF}

function GetDateInt;
{$IFDEF ANDROID}
var
  UT: tm;
begin
  UT := GetAndroidUT;
  Result :=  (UT.tm_year-100-21)*360+(UT.tm_mon)*30+(UT.tm_mday);
end;
 {$ELSE}
var SystemT : SystemTime;
begin
  GetSystemTime(SystemT);
  Result := (SystemT.wYear-2021)*360+(SystemT.wmonth-1)*30+(SystemT.wDay mod 100);
end;
{$ENDIF}

function GetTimeString; //Отображаем текущее время
{$IFDEF ANDROID}
var
  UT: tm;
begin
  UT := GetAndroidUT;  //Велосипед для сходного кода обоих версий
  Result :=  InttoStr(UT.tm_Hour)+':'+InttoStr(UT.tm_Min+1)+':'+InttoStr(UT.tm_Sec);
end;
 {$ELSE}
var SystemT : SystemTime;
begin
  GetSystemTime(SystemT);
  Result := IntToStr(SystemT.wHour)+':'+IntToStr(SystemT.wMinute)+':'+IntToStr(SystemT.wSecond);
end;
{$ENDIF}

procedure  TLogFile.WriteToLog;
begin
 if Opened then
   begin
     WriteLn(Filelog,S);
     Flush(Filelog);
   end;
end;



procedure  TLogFile.Stop;
begin
  if Opened then
    begin
      WriteLn(Filelog,'Конец записи в лог');
      CloseFile(Filelog);
      Opened := False;
    end;
end;

procedure  TLogFile.WriteLogStop;
begin
  if LogStop then  WriteToLog(S);
end;

procedure  TLogFile.WriteSafe;
begin
  if SafeWriteDebug then  WriteToLog(S);
end;

procedure  TLogFile.WriteDebug;
begin
  if Debug then  WriteToLog(S);
end;

procedure  TLogFile.WriteErrCount;
begin
  WriteToLog('Timestamp-'+IntToStr(Timestamp));

end;

procedure  TLogFile.PutFullData;
var i,j,k: Integer;
begin

end;

procedure TLogFile.ChangeLogStop;
begin
  LogStop := Smode;
end;


//------------TextFile
procedure  TTextFile.Init(Smode: Boolean);
begin
    {$IFDEF ANDROID}
   inherited Init(Smode,True,TPath.GetPublicPath);
   {$ELSE}
  inherited Init(Smode,True,'');
   {$ENDIF}
  WriteToLog('------Запись лога срабатываний начата--------');
  YesWriteLevels := True;
end;

procedure  TTextFile.Init2;
begin
  Opened := False;
end;

procedure  TTextFile.WriteLevels;
var j,k : Integer;
begin

end;

function GetDebugPath;
begin
{$IFDEF ANDROID}
  result := TPath.GetPublicPath;  //GetDocumentsPath -> assets/internal   //GetPublicPath -> assets
{$ELSE}
  result := '.';
{$ENDIF}
end;



end.
