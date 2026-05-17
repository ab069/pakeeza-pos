; Inno Setup script — compile with Inno Setup 6 to create PakeezaPOS-Setup.exe
; https://jrsoftware.org/isinfo.php

#define MyAppName "Pakeeza POS"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Pakeeza Fast Food"
#define MyAppExeName "pakeeza_pos.exe"
#define BuildDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{A8F3C2E1-9B4D-4PKE-POS-2026PAKEEZA}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Pakeeza POS
DefaultGroupName={#MyAppName}
OutputDir=..\dist
OutputBaseFilename=PakeezaPOS-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}}"; Flags: nowait postinstall skipifsilent
