program OpenControl;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  AIManager in 'AIManager.pas',
  AreaManager in 'AreaManager.pas',
  ControlConsts in 'ControlConsts.pas',
  Finance in 'Finance.pas',
  OCGraph in 'OCGraph.pas',
  TimeManager in 'TimeManager.pas',
  Debug in 'Debug.pas',
  BaseManager in 'BaseManager.pas',
  LabelGroup in 'LabelGroup.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
