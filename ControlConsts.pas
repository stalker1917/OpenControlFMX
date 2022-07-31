// By Stalker1917  LGPL 3.0
{$DEFINE HARD_LEVEL}

unit ControlConsts;
interface
const 
C_MaxPlane  = 3;
type 
TPlanesConst  = Array [1..C_MaxPlane] of Byte;
TAHStrings  = Array [0..3] of String;
TBFile  = File of Byte;
const
NPlayers = 7; //Число игроков
NBuildings = 7;
BuildCols : Array [0..NBuildings] of LongWord = ($808080,$FFFFFF,$00FF00,$00FFFF,$0000FF,$008000,$FF0000,$6000AA); //На самом деле почему-то отвечают за цвет зданий
LBaseArea = 25;
LArea = 16;
AreaPixels = 50; //Надо 1000/LArea а по факту почему-то 750/LBaseArea  800/LArea
BasePixels = 40; //1000/LBaseArea
BaseMine = 6;
HangarHigh = 6;
I_Regeneration = 25;
SectorDlinna = 1000;
SmallRadius = 18;
BigRadius = 36;
TimeToBase = 3600;
TimeToResources = 3600*36;

S_AviaFactory   = 'Авиационный завод';
S_Hangar        = 'Ангар';
S_BMine         = 'Синяя шахта';
S_GMine         = 'Зелёная шахта';
S_RMine         = 'Красная шахта';
S_VMine         = 'Фиолетовая шахта';



AS_AviaFactory  : TAHStrings = ('Время производства','Стоимость работы','Синих ресурсов','Что строим');
AS_Hangar  : TAHStrings = ('Тип самолёта','Прочность самолёта','Запас топлива','Список самолётов');

H_Main          = 20000;
H_Bomb          = 1000;


Velocites : TPlanesConst = (5,4,3); // Скорость разных типов самолётов. 
C_Regimes : TPlanesConst = (0,1,2); // Скорость разных типов самолётов.

SaveVersion : Word = 1; //

{$IfDef HARD_LEVEL}
 VioletPriority = True;
{$ELSE}
 VioletPriority = False;
{$EndIf}

var
CurrSaveVersion : Word = 3;//SaveVersion;
Plems : Array[1..NPlayers] of byte;//TAlphaColor;   //TEnemy
Okno : Byte; //Какой из режимов окна.

implementation
begin
end.
