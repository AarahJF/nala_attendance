; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Nala attendance"
#define MyAppVersion "3.0"
#define MyAppExeName "nala_attendance.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{309C3EC7-D6B1-4017-8997-FE767C09B7E4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=D:\NALA\nala_attendance\installers
OutputBaseFilename=nala3.0v
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\fullscreen_window_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\webview_win_floating_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\webview_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\WebView2Loader.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\NALA\nala_attendance\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
