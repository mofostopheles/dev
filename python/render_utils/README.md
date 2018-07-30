# RenderUtils #

A COLLECTION OF SCRIPTS FOR RENDERED VIDEO
-----------------------------------------------------------------------------

### transcoder.py ###
#### USAGE ####
* Place script in same location as video files.
* Run this against uncompressed AVIs or Apple ProRes files.
* Creates transcoded versions of videos to YouTube/CBS/VAST specs. 
  This typically includes:
	* 1920x1080 30 mbps
	* 1920x1080	2000 kbps
	* 1280x720 1000 kbps
	* 1280x720 800 kbps
	* 1280x720 700 kbps
	* 1280x720 500 kbps
	* audio only

### make_gifs.py ###
#### USAGE ####
* Place script in same location as video files.
* Makes animated GIFs from AVI or MOV files.
* Uses the video's own filename, swaps extension with ".gif".
* Uses the source width/2.
	
### encode_apple_prores.py ###
#### USAGE ####
* Place script in same location as video files.
* Run this against uncompressed AVIs or MOVs.
* Creates Apple ProRes encoded MOV files.

### make_endframe_stills.py ###
#### USAGE ####
* Place script in same location as video files.
* Uses the video's own filename, swaps extension with ".png" or ".jpg"
