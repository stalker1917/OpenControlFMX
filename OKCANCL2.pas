unit OKCANCL2;

interface

uses System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,Math, FMX.Edit, FMX.Objects, FMX.Media;

type
  TOKRightDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    //Bevel1: TBevel;
    Label1: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OKRightDlg: TOKRightDlg;
  OkResult : Boolean;

implementation

{$R *.dfm}

procedure TOKRightDlg.CancelBtnClick(Sender: TObject);
begin
  OkResult :=False;
  Close;
end;

procedure TOKRightDlg.OKBtnClick(Sender: TObject);
begin
  OkResult :=True;
  Close;
end;

end.
