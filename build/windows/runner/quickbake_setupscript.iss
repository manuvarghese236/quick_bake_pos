; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Quick Bake"
#define MyAppVersion "1.0.1"
#define MyAppExeName "windowspos.exe"
#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{9C7A3EA7-FBC9-40A7-A28E-7914B0FAAF18}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputBaseFilename=setup_quickbake_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
[Code]
function InitializeSetup: Boolean;
begin
  // add the dependencies you need
  Dependency_AddVC2013;
  // ...

  Result := True;
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\flutter\quickbake\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "D:\flutter\quickbake\build\windows\runner\Release\charset_converter_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\flutter_pos_printer_platform_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\network_info_plus_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\pdfium.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\printing_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\syncfusion_pdfviewer_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\flutter\quickbake\build\windows\runner\Release\windowspos.exe"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

