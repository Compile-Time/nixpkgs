{
  lib,
  fetchFromGitHub,
  python313Packages,
  nix-update-script,
  versionCheckHook,
}:
python313Packages.buildPythonApplication (finalAttrs: {
  pname = "tuxbox";
  version = "3.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AndyCappDev";
    repo = "tuxbox";
    rev = "67e38741d1951267902cdb0583e7708a19571aa0";
    hash = "sha256-/faAuCUkQfCYArCijU1B+7ux5/p/MHdf1G9yRSVQtFc=";
  };

  build-system = [ python313Packages.setuptools ];

  dependencies = with python313Packages; [
    bleak
    evdev
    pyserial
    pyside6
  ];

  passthru.updateScript = nix-update-script { };

  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    changelog = "https://github.com/AndyCappDev/tuxbox/releases/tag/${finalAttrs.version}";
    description = "Linux driver for all TourBox models - Native feel with USB, Bluetooth, haptics and graphical configuration GUI";
    homepage = "https://github.com/AndyCappDev/tuxbox";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CompileTime ];
    mainProgram = "tuxbox";
  };
})
