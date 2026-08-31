#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef BundleRoot
  #error BundleRoot is required
#endif
#ifndef OutputDirectory
  #error OutputDirectory is required
#endif
#ifndef OutputBaseFilename
  #error OutputBaseFilename is required
#endif

[Setup]
AppId={{BEAA21D4-E8E8-4C06-8C3D-E1D2B7E2EF9E}
AppName=Pi Client
AppVersion={#AppVersion}
AppPublisher=Hu-Wentao
AppPublisherURL=https://github.com/Hu-Wentao/pi-client
AppSupportURL=https://github.com/Hu-Wentao/pi-client/issues
AppUpdatesURL=https://github.com/Hu-Wentao/pi-client/releases
DefaultDirName={localappdata}\Programs\Pi Client
DefaultGroupName=Pi Client
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDirectory}
OutputBaseFilename={#OutputBaseFilename}
SetupIconFile={#SourcePath}\..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\pi_client.exe
UninstallDisplayName=Pi Client
CreateUninstallRegKey=yes
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no

[Files]
Source: "{#BundleRoot}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Pi Client"; Filename: "{app}\pi_client.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\Pi Client"; Filename: "{app}\pi_client.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\pi_client.exe"; Description: "Launch Pi Client"; Flags: nowait postinstall skipifsilent
