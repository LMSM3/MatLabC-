#define MyAppName "MatLabC++"
#define MyAppVersion "0.3.1"
#define MyAppExeName "matlabcpp.exe"
#define MyAppPublisher "MatLabC++ Project"
#define MyAppURL "https://github.com/yourusername/matlabcpp"
#define MyAppGUID "{{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}}"

[Setup]
; Application metadata
AppId={#MyAppGUID}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright=Copyright (C) 2026 MatLabC++ Project

; Installation directories
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

; Icon and visual settings
SetupIconFile=..\assets\icon.ico
WizardImageFile=compiler:WizardClassic.bmp
WizardSmallImageFile=compiler:WizardClassicSmall.bmp
WizardStyle=modern

; Output configuration
OutputDir=output
OutputBaseFilename=MatLabCpp_Setup_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes

; System requirements
MinVersion=0,6.1
ArchitecturesInstallIn64BitMode=x64

; Licensing
LicenseFile=..\LICENSE
InfoBeforeFile=
InfoAfterFile=

; Other settings
RestartIfNeededByRun=no
UninstallDisplayIcon={app}\icon.ico
AllowNoIcons=yes
AlwaysShowDirOnReadyPage=yes
AlwaysShowGroupOnReadyPage=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "addtopath"; Description: "Add MatLabC++ to PATH (recommended)"; GroupDescription: "Command line integration:"; Flags: unchecked
Name: "alias_mlc"; Description: "Install short command alias: mlc"; GroupDescription: "Command line integration:"; Flags: unchecked
Name: "desktopicon"; Description: "Create desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; Main executable (from Release build)
Source: "..\build\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Icon assets
Source: "..\assets\icon.ico"; DestDir: "{app}"; Flags: ignoreversion

; Command wrappers (Windows)
Source: "..\scripts\mlcpp.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\mlc.cmd"; DestDir: "{app}"; Flags: ignoreversion; Tasks: alias_mlc
Source: "..\scripts\mlcpp.ps1"; DestDir: "{app}"; Flags: ignoreversion

; Command wrappers (Linux/macOS) - included in installer for reference
Source: "..\scripts\mlcpp"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\mlc"; DestDir: "{app}"; Flags: ignoreversion; Tasks: alias_mlc

; Documentation
Source: "..\README.md"; DestDir: "{app}\docs"; DestName: "README.md"; Flags: ignoreversion
Source: "..\powershell\README.md"; DestDir: "{app}\docs"; DestName: "PowerShell_Guide.md"; Flags: ignoreversion
Source: "..\COMMAND_LINE_INTEGRATION_SUMMARY.md"; DestDir: "{app}\docs"; Flags: ignoreversion

; Examples
Source: "..\examples\*"; DestDir: "{app}\examples"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]
Name: "{app}\docs"
Name: "{app}\examples"

[Icons]
; Start menu shortcuts
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"; Comment: "MatLabC++ - High-Performance Numerical Computing"
Name: "{group}\Command Prompt (here)"; Filename: "cmd.exe"; Parameters: "/k cd /d ""{app}"""; WorkingDir: "{app}"; IconFilename: "{app}\icon.ico"
Name: "{group}\Documentation"; Filename: "notepad.exe"; Parameters: """{app}\docs\README.md"""; WorkingDir: "{app}\docs"; IconFilename: "{app}\icon.ico"

; Desktop shortcut (optional)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon.ico"; Comment: "MatLabC++ - High-Performance Numerical Computing"; Tasks: desktopicon

; Uninstaller
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"; IconFilename: "{app}\icon.ico"

[Registry]
; Add to PATH (System-wide)
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
  ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; \
  Tasks: addtopath; Check: NeedsAddPath; Flags: preservestringtype

; File association for .mlx files (optional)
Root: HKCR; Subkey: ".mlx"; ValueType: string; ValueData: "MatLabCppFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "MatLabCppFile"; ValueType: string; ValueData: "MatLabC++ MATLAB Live Script"; Flags: uninsdeletekey
Root: HKCR; Subkey: "MatLabCppFile\shell\open\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletevalue

[Run]
; Show readme after installation
Filename: "notepad.exe"; Parameters: """{app}\docs\README.md"""; Description: "View README"; Flags: postinstall skipifsilent
Filename: "explorer.exe"; Parameters: "/select,""{app}\{#MyAppExeName}"""; Description: "Open installation folder"; Flags: postinstall skipifsilent nowait

[Messages]
; Custom messages
SetupAppTitle=Install {#MyAppName} v{#MyAppVersion}
SetupWindowTitle={#MyAppName} {#MyAppVersion} Setup
BeveledLabel={#MyAppName} v{#MyAppVersion} - High-Performance Numerical Computing

[Code]
function NeedsAddPath(): Boolean;
var
  Paths: string;
  AppPath: string;
begin
  AppPath := ExpandConstant('{app}');
  
  if not RegQueryStringValue(HKLM,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', Paths) then
  begin
    Result := True;
    Exit;
  end;
  
  { Check if app path is already in PATH (case-insensitive) }
  Result := Pos(';' + Uppercase(AppPath) + ';',
                ';' + Uppercase(Paths) + ';') = 0;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if WizardIsTaskSelected('addtopath') then
    begin
      MsgBox('MatLabC++ has been added to PATH.' + #13#13 +
             'Open a new Command Prompt or PowerShell to use the mlcpp command.' + #13#13 +
             'Usage: mlcpp [options] file1.c file2.m ...', 
             'Command-Line Integration', mbInformation, MB_OK);
    end;
    
    if WizardIsTaskSelected('alias_mlc') then
    begin
      MsgBox('Short alias ''mlc'' has been installed.' + #13#13 +
             'You can now use: mlc [options] file1.c file2.m ...', 
             'Short Alias Installed', mbInformation, MB_OK);
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  Paths: string;
  NewPaths: string;
  AppPath: string;
  PathArray: TArrayOfString;
  i: Integer;
  Found: Boolean;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    AppPath := ExpandConstant('{app}');
    
    { Remove from PATH if present }
    if RegQueryStringValue(HKLM,
      'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
      'Path', Paths) then
    begin
      { Split, filter, rejoin to remove app path }
      Found := False;
      
      if Pos(AppPath, Paths) > 0 then
      begin
        { Simple removal for common case: ";{app}" }
        NewPaths := StringChange(Paths, ';' + AppPath, '');
        if NewPaths = Paths then
        begin
          { Try without leading semicolon }
          NewPaths := StringChange(Paths, AppPath + ';', '');
        end;
        if NewPaths = Paths then
        begin
          { Try exact match }
          NewPaths := StringChange(Paths, AppPath, '');
        end;
        
        if NewPaths <> Paths then
        begin
          RegWriteStringValue(HKLM,
            'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
            'Path', NewPaths);
          MsgBox('MatLabC++ has been removed from PATH.', 'Uninstall Complete', mbInformation, MB_OK);
        end;
      end;
    end;
  end;
end;
