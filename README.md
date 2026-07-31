# Dolphin Image2PDF

A small, maintained KDE Plasma 6 service menu for creating PDF files from images directly in Dolphin.

Select one or more images in Dolphin, open the context menu, and choose either:

- **Convert Images to Separate PDFs**
- **Combine Images into One PDF**

The German translations are **Bilder in getrennte PDFs konvertieren** and **Bilder in einer PDF zusammenfassen**.

## Why this project exists

Creating a multi-page PDF from selected images should be a simple desktop operation. Existing third-party service-menu entries may contain outdated Plasma 5 metadata or invalid, complex shell code embedded directly in `Exec=` entries. Dolphin rejects such entries on current Plasma 6 systems.

This project keeps the desktop entry deliberately small and moves all conversion logic into a separately testable helper script.

## Requirements

- KDE Plasma 6 with Dolphin
- Bash
- `kdialog`
- [`img2pdf`](https://github.com/josch/img2pdf)

On openSUSE Tumbleweed, install the converter with:

```bash
sudo zypper install img2pdf
```

For other distributions, install `img2pdf` from the distribution package manager or follow the upstream installation instructions.

## Installation

```bash
git clone https://github.com/fhroland/dolphin-image2pdf.git
cd dolphin-image2pdf
./install.sh
```

Close and reopen Dolphin if the actions do not appear immediately.

The installer copies only two files into the current user account:

- `~/.local/bin/dolphin-image2pdf`
- `~/.local/share/kio/servicemenus/org.fhroland.dolphin-image2pdf.desktop`

The paths follow `XDG_BIN_HOME` and `XDG_DATA_HOME` when those variables are set.

If the old `image2pdf.desktop` service menu is still installed, the installer prints a warning. Disable or uninstall that entry through **Dolphin Settings → Configure Dolphin → Context Menu** to avoid duplicate actions.

## Usage

### Create one PDF per image

Select one or more images and choose **Convert Images to Separate PDFs**. Each PDF is written next to its source image with the same base name. Existing PDF files are never overwritten; they are skipped and reported.

### Combine images into one PDF

Select the images and choose **Combine Images into One PDF**. A standard KDE save dialog asks for the destination. If the destination already exists, Image2PDF asks before replacing it.

The page order is the file order supplied by Dolphin. Each image becomes one PDF page. `img2pdf` embeds compatible image formats without unnecessary re-encoding, so JPEG and many PNG conversions are fast and lossless.

Only local files are supported. The service menu is intentionally hidden for remote protocols such as `smb://`.

## Uninstallation

Run from the cloned repository:

```bash
./uninstall.sh
```

The uninstaller removes only the two files installed by this project. It does not modify unrelated Dolphin service menus.

## Development and tests

Run the test suite with:

```bash
./tests/verify.sh
```

The tests use isolated temporary directories and fake `img2pdf`/`kdialog` commands. They verify installation, desktop-entry generation, filenames containing spaces, separate conversion, combined conversion, page order, and uninstallation without touching the user's Dolphin configuration.

GitHub Actions additionally runs [ShellCheck](https://www.shellcheck.net/) for all shell scripts.

## Security and data handling

- Selected filenames are passed as individual arguments, not concatenated into shell commands.
- Filenames containing spaces and common shell metacharacters are handled safely.
- PDFs are first written to temporary files in the destination directory and moved into place only after successful conversion.
- Existing files are not silently overwritten.
- Conversion is entirely local. No images are uploaded.

## Contributing

Bug reports and pull requests are welcome. Please include the Plasma, KDE Frameworks, Dolphin, and `img2pdf` versions when reporting a problem.

## License

Copyright © 2026 fhroland

Licensed under the GNU General Public License, version 3 or later. See [LICENSE](LICENSE).
