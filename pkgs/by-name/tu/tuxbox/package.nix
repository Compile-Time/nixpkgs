{
  lib,
  fetchFromGitHub,
  python313Packages,
}:
python313Packages.buildPythonApplication (finalAttrs: {
  pname = "tuxbox";
  version = "3.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AndyCappDev";
    repo = "tuxbox";
    rev = "606a1604cf4e03c331ad034d8f60b263fc395fd7";
    hash = "sha256-hBk4KhLNMgk8bFCZPQMtQlJ1/RB9qcL4kiF+eb3n4LU=";
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
    # Therefore, a patch is applied to use `tuxbox-wrapped` for the search since that is the name the process will spawn as when using this package.
    ./change-pgrep-command.patch
  ];

  meta = {
    changelog = "https://github.com/AndyCappDev/tuxbox/releases/tag/${finalAttrs.version}";
    description = "Linux driver for all TourBox models - Native feel with USB, Bluetooth, haptics and graphical configuration GUI";
    homepage = "https://github.com/AndyCappDev/tuxbox";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CompileTime ];
    mainProgram = "tuxbox";
  };
})
