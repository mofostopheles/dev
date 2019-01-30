# VideoCompositingTools

> A video compositing script that wraps several ffmpeg calls.

## Usage
Run the script **video_compositor.py** from the command line. Script will load **video_variations.xlsx** and will create title card PNGs automatically. Custom fonts are supports by specifying the font file (you must place the font files in the fonts folder in this project). Title builder code supports UTF8.

> *Note*: Several things are still hard-coded as this script evolves, error handling is scant at best. The script was written with 6-second bumpers in mind, specifically the Estelle project, so that's 3 title cards, a 3D product base video, a camera-mapped screen video, a background, and end-card logo. Additional layers can easily be added in the code and spreadsheet.

----

## TODO
* add color options for all titles/text
* un-hardcode the legal text positioning
* add argparse and --help
* add a "enable" column to row (instead of deleting rows)

## Troubleshooting
* If you see edge artifacting in the renders, make sure all assets are unmatted, not pre-multiplied from After Effects.
* If titles are loading text correctly, make sure you have copied the correct fonts into the fonts folder.
