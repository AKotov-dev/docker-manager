unit project_files;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Buttons,
  StdCtrls, IniPropStorage, FileUtil;

type

  { TFilesForm }

  TFilesForm = class(TForm)
    FileListBox1: TFileListBox;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    AddBtn: TSpeedButton;
    DeleteBtn: TSpeedButton;
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
  private

  public

  end;

var
  FilesForm: TFilesForm;

implementation

uses unit1;

{$R *.lfm}

{ TFilesForm }


procedure TFilesForm.FormShow(Sender: TObject);
begin
  //Восстанавливаем для Plasma (масштабирование)
  IniPropStorage1.Restore;

  FileListBox1.Directory := GetUserDir + '.config/DockerManager';
  Label1.Caption := FileListBox1.Directory;
  if FileListBox1.Count <> 0 then FileListBox1.ItemIndex := 0;
end;

//Add files
procedure TFilesForm.AddBtnClick(Sender: TObject);
var
  i: integer;
begin
  if OpenDialog1.Execute then
  begin
    for i := 0 to OpenDialog1.Files.Count - 1 do
      CopyFile(OpenDialog1.Files[i], Label1.Caption + '/' +
        ExtractFileName(OpenDialog1.Files[i]), False);

    FileListBox1.UpdateFileList;
  end;
end;

procedure TFilesForm.FormCreate(Sender: TObject);
begin
  //Файл конфигурации формы FilesForm
  FilesForm.IniPropStorage1.IniFileName := MainForm.IniPropStorage1.IniFileName;
end;

procedure TFilesForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.Save;
end;

//Delete files
procedure TFilesForm.DeleteBtnClick(Sender: TObject);
var
  i: integer;
begin
  if MessageDlg(SDeleteFile, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    for i := 0 to FileListBox1.Count - 1 do
      if FileListBox1.Selected[i] then
        DeleteFile(Label1.Caption + '/' + FileListBox1.Items[i]);

    FileListBox1.UpdateFileList;
  end;
end;

end.
