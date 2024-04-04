unit LabelGroup;
interface
uses System.UITypes,FMX.StdCtrls,OCGRaph;
type
TLabelGroup = class(TOBject)
  protected
  Labels : Array of TLabel;
  private
  fVisible : Boolean;
  fActive  : Integer;
  procedure SetVisible(V: Boolean);
  public
  constructor Create;
  procedure Add(var _Label : TLabel);
  procedure SetPosition(X,Y,MaxX:Single);
  procedure SetActive(I:Integer);
  procedure SetFont(I:Integer);
  //procedure SetVisible(V:Boolean);
  property Visible : Boolean read fVisible write SetVisible;
  property Active : Integer read fActive write SetActive;
end;




implementation

constructor  TLabelGroup.Create;
begin
  inherited Create;
  SetLength(Labels,0);
  fActive := -1;
end;

procedure TLabelGroup.Add(var _Label: TLabel);
begin
  Labels := Labels + [_Label];
end;

procedure TLabelGroup.SetPosition;
var i : Integer;
begin
  for i:=0 to High(Labels) do
    begin
      Labels[I].Position.X := X;
      Labels[I].Position.Y := Y+i*EtalonToY(32);
      Labels[i].Width := MaxX-X;
    end;
end;

procedure TLabelGroup.SetActive(I: Integer);
var _Label :TLabel;
begin
  fActive := I;
  for _Label in Labels do _Label.FontColor := TAlphaColorRec.White;
  if (i>=0) or (i<=High(Labels)) then Labels[i].FontColor := TAlphaColorRec.Red;
end;

procedure TLabelGroup.SetVisible(V: Boolean);
var _Label :TLabel;
begin
  fVisible := V;
  for _Label in Labels do _Label.Visible := V;
end;

procedure TLabelGroup.SetFont(I: Integer);
var _Label :TLabel;
begin
  for _Label in Labels do _Label.Font.Size := i;
end;


end.
