{
  lib,
  fetchFromGitHub,
  python313Packages,
}:
python313Packages.buildPythonApplication (finalAttrs: {
  pname = "tuxbox";
  version = "3.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AndyCappDev";
    repo = "tuxbox";
    rev = "5c4d27718f96ce511235a2e3e60b904d80722adb";
    hash = "sha256-FryeqFbp7X5gJ0LCEDjFPgT8kmZ+E7pk5wp4/xPrr7Q=";
  };

  build-system = [ python313Packages.setuptools ];

  dependencies = with python313Packages; [
    bleak
    evdev
    pyserial
    pyside6
  ];

  patches = [
    # TuxBox uses a pgrep command to check if there is a running driver process.
    # However, the search argument does not work for NixOS - `python.*-m.*tuxbox`.
    # We patch the command to use `tuxbox-wrapped` since that is the name the process will spawn as when using this package.
    ./change-pgrep-command.patch
  ];

  meta = {
    changelog = "https://github.com/AndyCappDev/tuxbox/releases/tag/${finalAttrs.version}";
    description = "Linux driver for all TourBox models - Native feel with USB, Bluetooth, haptics and graphical configuration GUI.";
    homepage = "https://github.com/AndyCappDev/tuxbox";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CompileTime ];
  };
})
