unit project_files;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, Buttons,
  StdCtrls, IniPropStorage, FileUtil, LCLType;

type

  { TFilesForm }

  TFilesForm = class(TForm)
    UpdateBtn: TSpeedButton;
    FileListBox1: TFileListBox;
    ImageList1: TImageList;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    AddBtn: TSpeedButton;
    DeleteBtn: TSpeedButton;
    procedure DeleteBtnClick(Sender: TObject);
    procedure FileListBox1DrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
  private

  public

  end;

var
  FilesForm: TFilesForm;

implementation

uses unit1, dockerfile_unit;

  {$R *.lfm}

  { TFilesForm }


procedure TFilesForm.FormShow(Sender: TObject);
begin
  //Восстанавливаем для Plasma (масштабирование)
  IniPropStorage1.Restore;

  FileListBox1.Directory := GetUserDir + 'DockerManager';

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
      CopyFile(OpenDialog1.Files[i], FileListBox1.Directory + '/' +
        ExtractFileName(OpenDialog1.Files[i]), False);

    //обновить список
    UpdateBtn.Click;

    //на случай обновления Dockerfile
    if FileExists(GetUserDir + 'DockerManager/Dockerfile') then
      DFileForm.DFileMemo.Lines.LoadFromFile(GetUserDir + 'DockerManager/Dockerfile');
  end;
end;

//Refresh the list
procedure TFilesForm.UpdateBtnClick(Sender: TObject);
begin
  FileListBox1.UpdateFileList;
  if FileListBox1.Count <> 0 then FileListBox1.ItemIndex := 0;
end;

procedure TFilesForm.FormCreate(Sender: TObject);
begin
  //Файл конфигурации формы FilesForm
  IniPropStorage1.IniFileName := MainForm.IniPropStorage1.IniFileName;
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
  if FileListBox1.Count = 0 then Exit;

  if MessageDlg(SDeleteFile, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    for i := 0 to FileListBox1.Count - 1 do
      if (FileListBox1.Selected[i]) and (FileListBox1.Items[i] <> 'Dockerfile') then
        DeleteFile(FileListBox1.Directory + '/' + FileListBox1.Items[i]);

    UpdateBtn.Click;
  end;
end;

procedure TFilesForm.FileListBox1DrawItem(Control: TWinControl;
  Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  Bmp: TBitmap;
  TextY, IconY: integer;
  ImgIndex: integer;
begin
  Bmp := TBitmap.Create;
  try
    with FileListBox1, Canvas do
    begin
      // Цвет выделения
      if odSelected in State then
      begin
        Brush.Color := clHighlight;
        Font.Color := clHighlightText;
      end
      else
      begin
        Brush.Color := Color;
        if Items[Index] = 'Dockerfile' then
          Font.Color := clGray
        else
          Font.Color := clWindowText;
      end;

      FillRect(ARect);

      // Вертикальное центрирование
      TextY := ARect.Top + (ItemHeight - TextHeight(Items[Index])) div 2 + 2;
      IconY := ARect.Top + (ItemHeight - ImageList1.Height) div 2 + 2;
      // визуальная компенсация

      // Выбор иконки
      if Items[Index] = 'Dockerfile' then
        ImgIndex := 0
      else
        ImgIndex := 1;

      // Отрисовка иконки
      ImageList1.GetBitmap(ImgIndex, Bmp);
      Draw(ARect.Left + 2, IconY, Bmp);

      // Отрисовка текста
      TextOut(ARect.Left + ImageList1.Width + 6, TextY, Items[Index]);
    end;
  finally
    Bmp.Free;
  end;
end;

end.
