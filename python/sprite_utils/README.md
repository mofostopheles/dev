# SpriteUtils #

A COLLECTION OF SCRIPTS TO CREATE SPRITES
-----------------------------------------------------------------------------

### make_sprites_from_frames.py ###

>This script makes a 1 row horizontal sprite from loose, unorganized PNGs that have been exported from After Effects using the "\_\_render\_tagged\_layers\_from\_selected\_comps.jsx" script. 

In After Effects the comp would be named e.g. "home-mini-ao-loopable-coral-[frame]-300x600" where "[frame]" is dynamically replaced by however many guide layers with a hashtag-string name e.g. "#intro" (see any Home Mini project for examples). This hashtag-string convention replaces the older naming convention of simply numbering these guide layers, as titles make more sense when frames are reordered by dev.

#### USAGE ####
* Place this script and the lib folder in your render/output folder.
* Nothing to set, you just run the script. If there are PNGs present, a sprite will be constructed for each unique set of PNGs (based on the filenames).
* A temp folder "\_\_sprite\_staging\_area" will be created at this script's location to hold sorted PNGs. Organizing the PNGs into folders is something normally done by After Effects, however our hashtag-string script obliterates the inherant foldering mechanism, and the ability to make a directory is not exposed in a JSX script. 
* The temp folder "\_\_sprite\_staging\_area" will be removed at the end of this script's execution.

#### TROUBLESHOOTING ####
* If you end up with wonky looking filenames for your sprites, make sure your render folder is clean, only containing PNGs you wish to convert. Stray PNGs can cause trouble. 


### make_sprites_from_sequences.py ###

>This script makes a 1 row horizontal PNG sprite from PNGs organized into directories. Typically these would have been exported from After Effects using the built-in PNG Sequence render output module.

#### USAGE ####
* Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.
* Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.
* Directories with names like "misc" or "processed" or "boneyard", etc, will be ignored. All other directories are globbed for .png files.

### make_jpg_sprites_from_sequences.py ###

>This script makes a 1 row horizontal JPG sprite from PNGs organized into directories. Typically these would have been exported from After Effects using the built-in PNG Sequence render output module.

#### USAGE ####
* Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.
* Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.
* Directories with names like "misc" or "processed" or "boneyard", etc, will be ignored. All other directories are globbed for .png files.

### make_jpg_sprites_from_frames.py ###

>This script makes a 1 row horizontal sprite from loose, unorganized JPGs that have been exported from After Effects using the "\_\_render_tagged_layers_from_selected_comps.jsx" script. 

In After Effects the comp would be named e.g. "home-mini-ao-loopable-coral-[frame]-300x600" where "[frame]" is dynamically replaced by however many guide layers with a hashtag-string name e.g. "#intro" (see any Home Mini project for examples). This hashtag-string convention replaces the older naming convention of simply numbering these guide layers, as titles make more sense when frames are reordered by dev.

#### USAGE ####
* Place this script and the lib folder in your render/output folder.
* Nothing to set, you just run the script. If there are JPGs present, a sprite will be constructed for each unique set of JPGs (based on the filenames).
* A temp folder "\_\_sprite_staging_area" will be created at this script's location to hold sorted JPGs. Organizing the JPGs into folders is something normally done by After Effects, however our hashtag-string script obliterates the inherant foldering mechanism, and the ability to make a directory is not exposed in a JSX script. 
* The temp folder "\_\_sprite_staging_area" will be removed at the end of this script's execution.

#### TROUBLESHOOTING ####
* If you end up with wonky looking filenames for your sprites, make sure your render folder is clean, only containing JPGs you wish to convert. Stray JPGs can cause trouble. 
