
#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7735.h> // Hardware-specific library
#include <SPI.h>
#include <SD.h>

#if defined(__SAM3X8E__)
#undef __FlashStringHelper::F(string_literal)
#define F(string_literal) string_literal
#endif

#define sclk 13
#define mosi 11

#define SD_CS    4  // Chip select line for SD card
#define TFT_CS  10  // Chip select line for TFT display
#define TFT_DC   9  // Data/command line for TFT
#define TFT_RST  8  // Reset line for TFT (or connect to +5V)


Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

int _counter = 0;
int _currentReading = 0;
int _lastReading = 0;
int _lastCycle = 20;
double _defaultCircleSize = 15.0;
double _thisSize = 10.0;
double _lastSize = 10.0;

double _ripple1 = 10.0;
double _ripple2 = 10.0;
double _ripple3 = 10.0;

int _graphWidthCounter = 1;
int _graphDefaultX = 8;
int _graphXLocation = _graphDefaultX;


void setup(void)
{
  Serial.begin(9600);

  tft.initR(INITR_BLACKTAB);   // initialize a ST7735S chip, black tab


  tft.fillScreen(ST7735_BLACK);
  printExplanation();
}

int processCurrentReading()
{
   return sin( _currentReading );
}

void loop()
{  
    //every N seconds, 
    //draw a column of circles representing the current light reading
    
    _currentReading = analogRead(A4);
    Serial.println(_currentReading);
    _thisSize = _currentReading * 2;
    int tmpSpacer = 6;
    int tmpCircleSize = 2;
    int tmpStartAtY = 150;
    
    for(int r=0;r< 100 ;r++)
    {
      tft.drawCircle(_graphXLocation, tmpStartAtY - r*tmpSpacer, tmpCircleSize, ST7735_BLACK);
      //not filling creates a history of previous highs
    }
    
    for(int y=0;y< round(3*_thisSize)+1;y++)
    {      
      tft.drawCircle(_graphXLocation, tmpStartAtY - y*tmpSpacer, tmpCircleSize , ST7735_YELLOW);
      tft.fillCircle(_graphXLocation, tmpStartAtY - y*tmpSpacer, tmpCircleSize , ST7735_YELLOW);

    }
    
    _graphWidthCounter += 1;
    _graphXLocation += 10;
    
    if (_graphWidthCounter == 13)
    {
      //reset everything
      _graphWidthCounter = 1;
      //tft.fillScreen(ST7735_BLACK);
      _graphXLocation = _graphDefaultX;
    }

    _counter += 1;
    
    if (_counter == 5000)
    {
    //printExplanation();
      _counter = 0;
    }
    delay(5);
}

void testdrawtext(char *text, uint16_t color) {
  tft.setCursor(0, 0);
  tft.setTextColor(color);
  tft.setTextWrap(true);
  tft.print(text);
}

void printExplanation()
{
  tft.fillScreen(ST7735_BLACK);
  tft.setTextColor(0xFFFFFF);
  tft.setCursor(0, 0);
  tft.print("Microsoft");
  tft.setCursor(0, 10);
  tft.print("Education Workshop");
  tft.setCursor(0, 20);
  tft.print(" ");
  tft.setCursor(0, 30);
  tft.print(" ");
  tft.setCursor(0, 40);
  tft.print("  ");
  tft.setCursor(0, 50);
  tft.print("  ");

  tft.setCursor(0, 70);
  tft.print(" ");
  tft.setCursor(0, 80);
  tft.print(" ");
  tft.setCursor(0, 90);
  tft.print(" ");
  tft.setCursor(0, 100);
  tft.print(" ");
  tft.setCursor(0, 110);
  tft.print(" ");
  tft.setCursor(0, 120);
  tft.print(" ");

  delay(10000);
  tft.fillScreen(ST7735_BLACK);

}

//String _colorArray = {ST7735_RED, ST7735_YELLOW, ST7735_BLUE, ST7735_GREEN, ST7735_WHITE, ST7735_MAGENTA};

void drawCirc(int pRadius)
{
  //

  //uint16_t color
  tft.drawCircle(tft.width() / 2, tft.height() / 2, pRadius, ST7735_BLUE);
}

// This function opens a Windows Bitmap (BMP) file and
// displays it at the given coordinates.  It's sped up
// by reading many pixels worth of data at a time
// (rather than pixel by pixel).  Increasing the buffer
// size takes more of the Arduino's precious RAM but
// makes loading a little faster.  20 pixels seems a
// good balance.

#define BUFFPIXEL 20

void bmpDraw(char *filename, uint8_t x, uint8_t y) {

  File     bmpFile;
  int      bmpWidth, bmpHeight;   // W+H in pixels
  uint8_t  bmpDepth;              // Bit depth (currently must be 24)
  uint32_t bmpImageoffset;        // Start of image data in file
  uint32_t rowSize;               // Not always = bmpWidth; may have padding
  uint8_t  sdbuffer[3 * BUFFPIXEL]; // pixel buffer (R+G+B per pixel)
  uint8_t  buffidx = sizeof(sdbuffer); // Current position in sdbuffer
  boolean  goodBmp = false;       // Set to true on valid header parse
  boolean  flip    = true;        // BMP is stored bottom-to-top
  int      w, h, row, col;
  uint8_t  r, g, b;
  uint32_t pos = 0, startTime = millis();

  if ((x >= tft.width()) || (y >= tft.height())) return;

  Serial.println();
  Serial.print("Loading image '");
  Serial.print(filename);
  Serial.println('\'');

  // Open requested file on SD card
  if ((bmpFile = SD.open(filename)) == NULL) {
    Serial.print("File not found");
    return;
  }

  // Parse BMP header
  if (read16(bmpFile) == 0x4D42) { // BMP signature
    Serial.print("File size: "); Serial.println(read32(bmpFile));
    (void)read32(bmpFile); // Read & ignore creator bytes
    bmpImageoffset = read32(bmpFile); // Start of image data
    Serial.print("Image Offset: "); Serial.println(bmpImageoffset, DEC);
    // Read DIB header
    Serial.print("Header size: "); Serial.println(read32(bmpFile));
    bmpWidth  = read32(bmpFile);
    bmpHeight = read32(bmpFile);
    if (read16(bmpFile) == 1) { // # planes -- must be '1'
      bmpDepth = read16(bmpFile); // bits per pixel
      Serial.print("Bit Depth: "); Serial.println(bmpDepth);
      if ((bmpDepth == 24) && (read32(bmpFile) == 0)) { // 0 = uncompressed

        goodBmp = true; // Supported BMP format -- proceed!
        Serial.print("Image size: ");
        Serial.print(bmpWidth);
        Serial.print('x');
        Serial.println(bmpHeight);

        // BMP rows are padded (if needed) to 4-byte boundary
        rowSize = (bmpWidth * 3 + 3) & ~3;

        // If bmpHeight is negative, image is in top-down order.
        // This is not canon but has been observed in the wild.
        if (bmpHeight < 0) {
          bmpHeight = -bmpHeight;
          flip      = false;
        }

        // Crop area to be loaded
        w = bmpWidth;
        h = bmpHeight;
        if ((x + w - 1) >= tft.width())  w = tft.width()  - x;
        if ((y + h - 1) >= tft.height()) h = tft.height() - y;

        // Set TFT address window to clipped image bounds
        tft.setAddrWindow(x, y, x + w - 1, y + h - 1);

        for (row = 0; row < h; row++) { // For each scanline...

          // Seek to start of scan line.  It might seem labor-
          // intensive to be doing this on every line, but this
          // method covers a lot of gritty details like cropping
          // and scanline padding.  Also, the seek only takes
          // place if the file position actually needs to change
          // (avoids a lot of cluster math in SD library).
          if (flip) // Bitmap is stored bottom-to-top order (normal BMP)
            pos = bmpImageoffset + (bmpHeight - 1 - row) * rowSize;
          else     // Bitmap is stored top-to-bottom
            pos = bmpImageoffset + row * rowSize;
          if (bmpFile.position() != pos) { // Need seek?
            bmpFile.seek(pos);
            buffidx = sizeof(sdbuffer); // Force buffer reload
          }

          for (col = 0; col < w; col++) { // For each pixel...
            // Time to read more pixel data?
            if (buffidx >= sizeof(sdbuffer)) { // Indeed
              bmpFile.read(sdbuffer, sizeof(sdbuffer));
              buffidx = 0; // Set index to beginning
            }

            // Convert pixel from BMP to TFT format, push to display
            b = sdbuffer[buffidx++];
            g = sdbuffer[buffidx++];
            r = sdbuffer[buffidx++];
            tft.pushColor(tft.Color565(r, g, b));
          } // end pixel
        } // end scanline
        Serial.print("Loaded in ");
        Serial.print(millis() - startTime);
        Serial.println(" ms");
      } // end goodBmp
    }
  }

  bmpFile.close();
  if (!goodBmp) Serial.println("BMP format not recognized.");
}

// These read 16- and 32-bit types from the SD card file.
// BMP data is stored little-endian, Arduino is little-endian too.
// May need to reverse subscript order if porting elsewhere.

uint16_t read16(File f) {
  uint16_t result;
  ((uint8_t *)&result)[0] = f.read(); // LSB
  ((uint8_t *)&result)[1] = f.read(); // MSB
  return result;
}

uint32_t read32(File f) {
  uint32_t result;
  ((uint8_t *)&result)[0] = f.read(); // LSB
  ((uint8_t *)&result)[1] = f.read();
  ((uint8_t *)&result)[2] = f.read();
  ((uint8_t *)&result)[3] = f.read(); // MSB
  return result;
}
