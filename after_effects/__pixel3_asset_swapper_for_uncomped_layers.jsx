/**********************************************************

ARLO EMERSON DESIGN LLC 

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.1"
__date__ = "10/15/2018"


DESCRIPTION
 
Combine all the little swapper tools into one UI.

https://www.adobe.com/content/dam/acom/en/devnet/Images/JavaScript-Tools-Guide-CC.pdf
http://jongware.mit.edu/scriptuihtml/Sui/pc_Panel.html
**********************************************************/


// Added functionality to Array object as Adobe does implement modern javascript
if(!Array.prototype.indexOf) 
{
    Array.prototype.indexOf = function(obj) 
    {
        for(var i=0; i<this.length; i++) 
        {
            if(obj===this[i])
            {
                return i;
            }
        }
        return -1;
    };
}

var LABEL_HELP = "1. Enter the layer source name.\n2. Enter the name of a comp to swap with layer.\n3. Select one or more comps.\n4. Click Swap.\n\nYou can undo if you need to.";
var LABEL_LAYER_SOURCE_NAME = "The layer source name you want to replace:";
var LABEL_COMP_REPLACEMENT_NAME = "The comp name that will replace the above layer:";
var LABEL_SWAP_BUTTON = "Swap layer with comp";
var LABEL_SWAP_UI_BUTTON = "Swap UI";
var LABEL_SWAP_PHOTO_BUTTON = "Swap Photo";
var MARGIN_LEFT = 50;
var SEARCH_STRING_UI = "_ui_";
var SEARCH_STRING_PHOTO = "__photo__";
var FILENAME_LOGO = "essence_white.png";
var DIRNAME_RESOURCES = "essence_production_tools";

var win = new Window('palette', 'ESSENCE PRODUCTION TOOLS - Pixel 3 Launch', [300,100,800,800]);
var w = buildUI();

start();

function start()
{
    if (app.project != null) 
    {
        if (app.project.items.length < 1)
        {
            alert("Please select at least one comp.");
        } 
        else 
        {      
            w.show();                                
        }
    }    
}

function buildUI()
{
    if (win != null)
    {
        win.spacing = 0;
        win.margins = 10;
                
        //------------------------- PHOTO SWAPPING SECTION -------------------------

        var strPhotoSwapping = 
        "panel { orientation:'row', text:'__photo__ swapper', spacing:5, margins:10, \
            leftCol: Group { orientation:'column', alignment:['fill','top'], \
                topRow: Group { alignment:['fill','top'], \
                    lblLayerToSwap: StaticText { text:'" + LABEL_LAYER_SOURCE_NAME + "', alignment:['left','center'] }, \
                    ddlLayerToSwap: DropDownList { text:'', characters:30, alignment:['fill','center']  },  \
                }, \
                botRow: Group { alignment:['left','top'], \
                    lblCompToSwap: StaticText { text:'" + LABEL_COMP_REPLACEMENT_NAME + "', alignment:['left','center'] }, \
                    ddlCompToSwap: DropDownList { text:'', characters:30, alignment:['fill','center'] }, \
                }, \
            } \
            rightCol: Group { alignment:['fill','fill'], swapButton: Button { text:'" + LABEL_SWAP_PHOTO_BUTTON + "' , alignment:['fill','fill'], preferredSize:[100, *]}, \
            } \
        }";
        
        win.objPhotoSwapping = win.add(strPhotoSwapping);
        populateLayerList(win.objPhotoSwapping.leftCol.topRow.ddlLayerToSwap);
        populateCompList(win.objPhotoSwapping.leftCol.botRow.ddlCompToSwap, SEARCH_STRING_PHOTO);
        win.objPhotoSwapping.rightCol.swapButton.onClick = function() { swapItems( win.objPhotoSwapping ) };

        //------------------------- UI SWAPPING SECTION -------------------------

        var strUISwapping = 
        "panel { orientation:'row', text:'__ui__ swapper', spacing:5, margins:10, alignment:['fill','top'], \
            leftCol: Group { orientation:'column', alignment:['fill','top'], \
                topRow: Group { alignment:['fill','top'], \
                    lblLayerToSwap: StaticText { text:'" + LABEL_LAYER_SOURCE_NAME + "', alignment:['left','center'] }, \
                    ddlLayerToSwap: DropDownList { text:'', characters:30, alignment:['fill','center']  },  \
                }, \
                botRow: Group { alignment:['fill','top'], \
                    lblCompToSwap: StaticText { text:'" + LABEL_COMP_REPLACEMENT_NAME + "', alignment:['left','center'] }, \
                    ddlCompToSwap: DropDownList { text:'', characters:30, alignment:['fill','center'] }, \
                }, \
            } \
            rightCol: Group { alignment:['fill','fill'], swapButton: Button { text:'" + LABEL_SWAP_UI_BUTTON + "' , alignment:['fill','fill'], preferredSize:[100, *]}, \
            } \
        }";

        win.objGroup2 = win.add(strUISwapping);
        populateLayerList(win.objGroup2.leftCol.topRow.ddlLayerToSwap);
        populateCompList(win.objGroup2.leftCol.botRow.ddlCompToSwap, SEARCH_STRING_UI);
        win.objGroup2.rightCol.swapButton.onClick = function() { swapItems( win.objGroup2 ) };

        //------------------------- GLOBAL BUTTONS SECTION -------------------------

        var strGlobalButtons = 
        "group { \
            orientation:'column', alignment:['fill','fill'], alignChildren:['left','top'], spacing:5, margins:10, \
            cmds: Group { \
                alignment:['fill','top'], \
                cancelButton: Button { text:'Cancel', alignment:['right','center'] }, \
                refreshLayersButton: Button { text:'Refresh', alignment:['right','center'] }, \
                helpButton: Button { text:'?', alignment:['right','center'], preferredSize:[25,25] }, \
            }, \
        }";

        win.objGlobalButtons = win.add(strGlobalButtons);

        win.objGlobalButtons.cmds.cancelButton.onClick = function() {win.close(0)};
        win.objGlobalButtons.cmds.helpButton.onClick = function() { alert(LABEL_HELP) };        
        win.objGlobalButtons.cmds.refreshLayersButton.onClick = function() { populateLayerList(win.objPhotoSwapping.leftCol.topRow.ddlLayerToSwap);populateLayerList(win.objGroup2.leftCol.topRow.ddlLayerToSwap); };

        //------------------------- FOOTER SECTION -------------------------
        
        var strFooter = 
        "panel { \
            orientation:'column', text:'', alignment:['fill','fill'], alignChildren:['left','top'], spacing:5, margins:10, \
            topRow: Group { \
                alignment:['fill','top'], \
                lblLayerToSwap: StaticText { text:'asdf', alignment:['left','center'] }, \
            }, \
        }";
        
        win.objFooter = win.add(strFooter);
        
        //$.writeln(win.objFooter);
        win.objFooter.onDraw = function()
        {
            var fillBrush = this.graphics.newBrush( this.graphics.BrushType.SOLID_COLOR, [1, 1, 1, 1] );
            //this.graphics.rectPath(0, 0, this.size[0], this.size[1]);
            //this.graphics.fillPath(fillBrush);  
            
            //$.writeln(Folder.current);
            var newPath = "D:/_projects/AfterEffectsUtils/" + FILENAME_LOGO;                                   
            var imageFile = File(newPath);            
            
            if (imageFile.exists)
            {
                var newImage = ScriptUI.newImage(imageFile);
                //$.writeln(win.size.width);
                this.graphics.drawImage(newImage, (win.size.width - newImage.size[0] - 25), 5, newImage.size[0], newImage.size[1]);  
            } 
            else
            {
                var imageBinString = (new String("\u0089PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\u0096\x00\x00\x00\x1C\b\x06\x00\x00\x00\u0083*F\\\x00\x00\x0B!IDATx\u009C\u00ED\u009B{\u00B4\u00D5E\x15\u00C7\u00BF\x17\u00BD\\\x05I$\u00BD\u00A2\u00A0$\u00C8C%\u0084\u00B0|\u00A6\u00A6ba\u00A9\x19i\u00A9\u0099\u0088H\u00E6#\rMmY\u0082\u00CF\u00D2|`\u00BA\u00D2|\u0083\u00E6\u0083\u0082\u008Cc*\u0084\x1C|`(\u008A\u008A\u0082\"  j\u00A8\b\u0088\x18\x17\x14>\u00FD\u00B1\x7F\u00BFu\u00E67g~\u00E7\u00F7;\u00E7\u0082\u00BAZ|\u00D7\u009Au\u00EFof\u00EF=\u00AF=3{\u00EF\u0099S\x07h=a[I\u00BBJ\u00DAFR\x0BI\u00AB$=&ie\u008D\u00F2\u00BAJ\u00FA\u0091\u00A4\u00FE\u0091\u00CC\x19\u0092FJzHRV\u00A3\u008F\u0097\u00F4=I\u00BD%\u00FDW\u00D2\x18I\u00B7HZ\u0092\u00A3\u00DE\u00EE\u0092\u00BAIj\x15}\x7F,iR$g#\u00F2\x02hn\u00EA\x03\u008C\x00\u00E6Q\u008E\t\u00C0&5\u00C8<\x05X\x1A\u0090\x07px\x05\u00BE\u00F6\u00C0\u00DFS\u00F8~\u0091Qg\x7F\u00E0\x01\u00E0\u00A3\x00\u00EF\u00EF\u00D6\u00C38}\x16i\u00CB/@\x1B\x044K\u00B1\u00EA\u0081\u00CB\u0081\x0F\u009D\tX\x074\x01\u00AB\u009C\u00BC\x03\u00AA\u0094{1\u0095qb\n_G`f\u0080~!0\f\u00E8\u0090\u00C2\u00D7\x15x8\u00C0\u00B7\u00DA\u00F9\x7F\x1A\u00D0P\u00A1\u00CD_\x07\u00CE\x04\x06\x03\u00BBV\u00D9\u00DF\u00E6\u00A6zl!>\x06\u00BC\x06\x14\u0081\u00EF\u00AF\x07\u00B9\u009B\x00;\x02\u009D\u0081\u00BAj\u00F9k\u00AD\u00B4\x130\u00C9\x19\u00F8\x05\u00D8\u00AA\u00DE\x1B\u00D8\x1E\u00F8\u00A7S\u00F6\u00F3*\u00E4\u009EL\x18\u00B3\u0080G\u0081!\u00D1@\u0086x\x1F\u00F1x\u0096\x03\u00BF\u00A5\u00F2*\u00EE\x07\u00BC\u00ED\u00F1M\x04\x06\x00=\u00B1\u0089\x02\u0098\x0B4\x06\u00F8\u00B7\x02\u00FE\u00EA\u00F1\u00AF\x04\u00EE\u008E\u00CA6\u00B4Ru\x07\u009E\b\u008C\u00D7\x1A\u00E0\u00DB5\u00CA\u00EC\x0B\\\x06L\u00C16\u008D\x15\u00C0\x18\u00A0m5rj\u00A9x\x17`\u0091\u00D3\u0089\u00FB\u00BCA\u00EF@r\u00B2N\u00CD)\u00B7#\u00E5\u00C7\u00D0D\u00EC\u00E8k\u0099\u00C1;\u00D0\u00E3[\x10\rP%\u009E\u00E3\u00A3\tp1\u00DC\u00A3)D\u00F9\u00B3\u0081m\u00BC\u00B2\u00CD\u0081\x19Qy\x01x\u00DD\u0093\u00F5\u00E3\u009C\u00FD\u00AE5}\x0BXB:.\u00AER^7\u00E0\u009E\n\u00F2n\u00A9F^\u00B5\u009D\u00E9\x01\u00BC\u00E3Tv\u00BBW\u00DE\x1B\u009B\u00D4\x18\u00EB\u0080\u00DDr\u00CA\u00BE\u00C2\u00EB\u00C8\u00BF\u0080Ms\u00F0m\u008Am\u00FF.\x0E\u00CC\u00E09,0p\x17x4;PZ O\x05\u00DA2<*\u00FBc\u00F4=\u00C2\u0091\u00D5\u0084\u00D9\u009E\u00A1\u00BA\u00F7\u00C1v\u0084\u00BF`\n9\x16\u00B8\r[\u00B0y\u00E7a/\u0092\u00E6\u0086\u008B%\u00C0]\u00D8\u00C9\u0091W\u00DE\x10\u00E0?\u009E\u009C\u0097\u0080?c;V<\x06\x1BD\u00B1Z\x02\u00CF9\x15\u008Fv\u00CA\u00DA\x03C)7\u00B8O\u00CF)\u00BBK\u0080\u00F7\u00D0\u009C\u00BC\u009DH\u00AE\u00DC\u00B1\x19\u00F4;\u0093\u00B4\x0B\x01\u00EE\r\u00D0\u008Ds\u00CA\u00EF\u00F0\u00CA\x1A\u00A3\u00FCg\u009D\u00BC\t\x0E\u00FD\u00F3\u00D8\u008E\u00E6\u00F2\u00EC\x1F\u00D1\u00A4)\u00C4d\u00D2\u008Fy7\u00B5\u00A6\u00DC\u0096|\x17\u00DBm\x06\x00\u00DB\u00E6\u0090\u00E1\u00A6K\x02m\x19\tl\u0081\x1D\u00E7+\u00A3\u00BCB5r\u00E3\x7F\u00FAb\u00B6\u00D0w\u0080^\u00C0W\x02\x03s\u00ABS\u00F1\nlE\u00EE\x0F\\Kr\u0097\x02XK~\u00A5\x12I{-F\u00DA\u008A\u00F7S_\u008F\u00EF\u00E8*\u00EBZD\u00D2~hC\u00E9\b\x04\u00F84\x1A\x13WF\u00BC\u00BB\u00C6\u00BB\u00CC6\u00C0|\u0087\u00E7R\u0087v3l\x07\u00C9\u0083N9\u00FA{\u0099\u00C7s'\u00B6X\u00AAQ\u00A6JJu\u00B6S>\u00C4\u00C9?\u00A5\x1A\u00D9\x02\u00CE\u00A0\u00B4\u00DD\x01|\u0080yR/`\u0093\u00F0\x00\u00F0\u0090W\u00F9J`Nph\u00E0\x19\u00AA\u00F3\x04\u00E3I\u009A\u0083Mb\u008C\u00BC\u00C6g/\u0087g1\u0095'\u00E7\u0097\u0081\u00F6\u009E\u00E7\u00C9z\u00DE+?+ g!\u00E6)\u00C6\u00DF\u00FB:\u00F4k1'F\u00C0\u00EE\u00D8\u00AE\u0096\x07s\u0080/e\u00F4\u00B53\u00C9\x1D\u00EF\u009A\f\u00FAJ\u00E9\u00D8@\x1B\u0086:\u00E5m)\u0099\x02S\u00C8\u00B7\u009B&\x14\u00CB\u009D\u00CC\u00E6`9p\x15\u00D0\u00AA\u008A\x06\x1C\x15\u00F1>\x02\u00EC\u0089MJ\f\u00DF\u00E6IK}\x1C\u009E\u0097I7\u00F47'\u00E9t\x10}\u00B7\u00C0B\t\u00E7\u0092\\`\u00ABI\x0E\u00B4\u00AFD\u00C79y\u0083\x1C\u00BE\u00A7\u00A3\u00BC\u0083\u00B0#\u00CA\u00C72,\u00E6\u00E7\u00DB4\u00E3r\u00F4ux\u00A0\u009EZRgJG\\\u008C\x1B<\u009A{\u009D\u00B2\u00BC\u00A7GB\u00B1\u008E\u00A5\u00E4\u00DD\u00D4\u0082&\u00CCc\u00F8Z\u0095\u0095w\x01\u00DE\u00C7<\u00B3.\u0098B\u00B8\u0083\u00FDpN9_\u00A5\x14sz\x03\u00D8:\u0085\u00EE\u00EC@\u00DB/\u00C2\u008ER\u00FFx\u009C\n\x1C\u0092\"\u00E7\u00F7\x11\u008D\x1B\u00D7\u00BA=\u00CA\u00FB\x04S\u00B8\u00BD\u0081\u008F\x1DyoFc4\x18spZc\u00F13\u00D7{\u00CE\u00F2\u00E2\u00B6$\u00E9y\u00F6\u00CF9>\u00A1\u00E4\u0087H^!i\u00FA\\\u00E4\u0094\r\u00AC\u00A5\u008E\u00F8\u009FvQ\u00A7\x1F\u00A0|%\u00A5a\x0E\x16\u00BB\u00DA\u00A3\u0086\u008Aw\u00A2d\u0093\u009C\u00E4\u00E4\u00DF\u00E2\u00C8\u00FF\u0090|\u009EM#\u00A5cy\r\u00F0\u00CD\x00\u00CD\x16\u00C0t\u00AF\u00FD\u00EB(?\u00A6\u00DE\u00C1\"\u00F4\u009B\u00A5\u00D4\u00D5\x12\u008Bi\u00B9\u00C6|=%\x1Bs\r\u00F08\u00A5\u009D\u00F7\x13LavJ\u0091\u00F7\u00A2S\u00F7\u0080\u008C~\x0Ewh\u0097a\u00C1\u00CBZ\u0094j\u00BF\u00A8].\x0Ep\u00CA\u00CFq\u00F2\u00CF\u00AF\u00B1\u008E\u00A0W\u00D8>\u00AA\u00FC'\u0098\u00E2,\u00F7\x1A1\n\u00F8\x06\u00F0\u00E5\x1A+mM\u00C9\u008E\x19\u00E5\u0095\u00F5 y4\u00E79\x0E[\u0093T\u00903\x034=\u00A9\u008C\u00F9\u00D1 fyT\u00FBD\u00F4n\be\u00BF\x14\u0099\u0093\u00C8^t\u00AE=W\u0089v\x07\u0092;\u00E0Lj\x1F\x7F\u00F7\u0088\x03\u00F3\x00\u00E327\u00E4\u0093u\x05V\u00B5b\u00B9\u00A9;f\u00CC\u00BB8\u00A2\x19\x156b+\x1A\u00CC9\b\x19\u00ABE\u00A7\u00AEi9d\u00D6aQ\u00F9\x18\x05\u00CA\u00EF'\u008F\u00A7\x1Ck\u00B0\x00\u00EC\x10lG\u00CB\u00D3\u00FE\u00C9\x11\u008F\u009Bw]@\u00F6\u0083\u0094{\u00D5\u00A1\x14\u00EF\u00A2\u008B1\u00E5I\u00A3\u00BB\u00D3\u0093?\u009DlC?m\u00FC\x17;r\u009A0\u008F\u00B6\x1D\x16\u00A6\x013O\u009A3\u00C7\u00B9\x14\u00EB\u00AC\u00C0\u00A0\r\u00AC\u00B1\u00B2^\u0094\u00AEH\u00E6\u0093\u00EE\u00BD\x1D\u00E3\u00D4\u00B5\u0086|\x1E\u00A6\x1B1n\u00A24Im\u00B0{\u00C2\u00D0\u00F1^U\\&\u0092\tf\u0093\u00BA\u00F9O\x07\u00E4\u00E6\u00BDx\u009F\x12\u00F1L%\u00DD\u00E9\u00F9n\u00A0\u00EDo`'K\u00B5sp\u00A8'\u00E7>\u00EC\u009Esa\u00F4]\u00C4\f\u00FBf)\x15\u00A0M3\x1E?\u00EC\x12\u00C8\u00EBY\u00C3#\u008A~\u0092FIj/i\u0099\u00A4\x1FJZ\u0098B\u00FB\u0084\u00A4\u00A5\u0092\u00DAI\u00AA\u0097t\u0084\u00A4\u00C73\u00E4\u00CFv\u00FEo\u0090t\u00A4\u00A4FIC$\u00B5\u008C\u0092\u008F\x0Fr\u00B6=\u00C6\u00E5\u0092\u00E6K\u00BA\u00DF\u00C9\u00DBY\u00F6\u00CC&\u00C6+\u0092\u008E\u0091\u00B46\u00A7\u00CC\u00A5\u00D1\u00DF\u00CD$m\x12(o%\u00E9z\u00E7{\u008D\u00AC/\u00ED\x14\u00EES\x16zx\u00DF}$=\x1B\u00FD?L\u00D2\u0095\u0092V\u00A7\u00F0\u00D6K:Q\u00D2\u00EE\u0092\u00A6K*JZ\u0090ZS\u0086\u00E6\u00F9\u00DE\x03\u0098\u00A1\u009Af\u00DC\u00FA\u00A9\x15\x16,\u008C\u008D\u00D9\x0F\u00B1\u00EB\u0088\x10m\x1BJ/\x10\u00C68\u00F5\u00CD\"\u00FB\u00A8\u00EAK\u00F25\u00C2Z\u00EC\u00B6\u00FF\",\x1E\u00F3\u009B@?B\u00D1\u00F6\u00B4\u00D4-\u00E29\u00D9\u00CB?\u00CD\u00ABs\u00DF*d\u008A\u00D2\u00C5\u00F9*\u00C2;\u00B8\u00BB\x13\u008F\x00nr\u00BECNJV\n]\u00F2\u00CF\u00C4l\u00C7J|\u008D$o\x16\u00C0\x1E\x1A\u00A4\u00F2d5\u00E4\u00D2@C\u00C0\u00CE\u00FC,\u00DE\u0081$\u008D\u00EAY\u0084\u00E3!\u00BD0;e6\x16\u00DF\x11\u00E5\u008App\u0085z\u00B6\u00C7\u00EE\u00EB\\\u00A3\x7F\u0089G\u00E3\u00C6\u0099b<\u0098\u00A3\x0Fqz\u00C2i[\u009C\u00EAH\u00BE\u00FD\u00AAF^\u009Cnv\u00F8\x7F\u00ED\u0095]\u00E8\u0094\u00CD\u00C3\x16\u00E9O\u009D\u00BC\x7F\u00D4P\u009F?\u009F\x7F#\u00FB>vO\u00E0U\u008F\u00EF)\u009C\x1B\x0EM\u009F+=8Q*\x14\u00B7R\u00A1\u00D8]\u0085b\u00A6b\u009D@:\u00C6a\u0097\u00BDm\u00B1\u0098N[\u00CC\u00FB\u00FA\x15\u00E5n|\u0091\u00F2\u00D0A\x03\u00A6P\u00CB\x1C\u00BAAQ\u00D9\u0095\x1E\u00FF\u00D9\u0094\u00B7mG\u00E0\u00C6\u00A8\u0093\u00B7\u0091\u00BCV\u00FA\x14\u00F8\u0081C\u00BB3\u00C9\x1D\r,\u00B4\u0090'\u0098\u00FB\u00B3\u0088\u00DE_\u00D5\u00DB\u0091\u00BC\u00DF<(\u0087,?\rs\u00F8\u00D7\x02GR\u00B2\x0Bc\u00AC\u00C6\u00EC a\u009E\u00A0\x1Bt\u00CD\u00FBrd_\u00ECR\u00DF\u00C7e\x19|C(\x7Fq2\n\u00CF1\u00D1\u00F8\u00A7\u00A5Bq\u00A8\n\u00C5\x05*\x14\u00DFW\u00A1xuV\u0083\u00DA\x12~<\u00E7\u00E2u\u00CC[z\u008Dd\u00E4\x1C\u00CC\u00F8\u00BE\u00DCo\bf\b?\u00E6\u00D0\u00CD#\x19`\u00BD\u00DE\u0093s\u0089\u00C7\x7F*\u00B6\u008An\u00A34\u00E8c<\u009E\u00AB<\u009E\u0091\u0081\u00B6g\u00B9\u00D4\u00F1]\u00D9\x1F\x02e\u00FD\x1D9\u00B5F\u00C1\x07{\u00ED\u00F9\b{U\x10\u00A3\t\u00BB\u009Dpy\u00FC\u00DD\u00F7\\\u00CC\u00AB\u00F3eo\u008D=\u00F8s\u00CD\u0099\u00B7\"\u00991\x16\x126kz`\u00B1:\x17\u00ABH\t\u00FFh\u00DC\u00A4\u00BDU(\u00AEV\u00A1H\u0094\u00DE\u00CD\u00D3\u00F9\u00DD\u00C9\x1F4u1\u0081\u00B0\x1D\u00B0=\u00C9{\u00C6I\u0094{8\u00B7\u0092D\u00ACXu\u00C0\u00FD\u0098W\u00D4\u00CF\u00E3\u00F1\u00DD\u00FE?y\u00E5\x1D(\x7F>\u00BD\u009Cp\x04\u00BB\x11\u00BB\u00E2\x00\u00DB\u0099[\x04h\u00DCc\u00CC\u009F\u00FC\u00BC\u00A9+\u00E9X\u0096\u00D2\u00B6:\u00EC9\u008B\u008B\u0097\u00B0\u00DD{(v\u0084\u00DE\u008D\u0099\x1E.\u0086a\u00BB\u00AC\u00FF \u00F2\u008E(_X|\u00EE\x02\u00CA\u00DFy=C\x05;L\u0085\u00E2TG\u00A9P\u00A18\"\u00EF\x00t\x01\u00C6S\u00FE0\u00CE\u00C7\n\u00CC\u00D68\u008C\u00F4\u00B3\u00DB5@\u00C7S~\u00B7WO\u00F2y\x0E\u0094\u00E2*\u00CF`G_(\u0086\u00E3\u0087F\u00FC\u00A7.\u00C2\u008C\u00F0\x17<\u00BA\u00B5\u0098!\x7F\x06\x16uvcbW\u00A4\u00F4\u00A1\x01\u008B\u00F7\u0080)X-J\u0095\u00B6 \u00C0\f\u00E3\u009E\x19|\u00D7P\x1EA\u00F7\u00B1\x1A\u00BBM\u00E9\u00ED\u00F0\u00F5\x0B\u00D0-\u00C2\u00AEu\u00FC\u0098\u00E5\u00FB\u00D8\u00B8Vt\u009ET(\u00BE\x1C)\u00D4\u00A7*\x14G\u00ABPl\u00A8\u0083\u00AA~\u00A5s\u0088\u00A4\u00A3d.\u00F6\x16\u0092\u00EAd\u00BF\u00C6yS\u00F6+\u009A\u0087%\u00CD\u00AA\u00C0\u00DFI\u00D2\u008B\u0092\u00DAJ\u009A#i\x7FI\u008B=\u009A=$Ms\u00BE\x17K\u00DAA\u00D2u\u0092\x06K\u00EA\u00A8p\u00A8\u00E0^I\u00C7:\u00DFWH\u00BA0@\u00B7\u00B5\u00A4\u00AB%\x1D\x1C\u00C9\u00F2\u00B1N\u00D2\u00CB\u0092.\u0090\u00F4hJ?\x06J\u00BAS\x16z\x18\u00A8t\x17=\x0F\u00DA\u00C8\u00FA\u00D6I\u00D6\u00AF\u00B1\u0092F\u00E7\u00E4\u00ED'\u00E9TI\u009D%u\u0090\u00CD\u00C9\u00BB\u0092\x16\u00C9\u00E6\u00E3\x1EIS\x03|\u00A7H\u00BAX\u00D2v)rgHzD\u00D2\u00CD\u00AA\x14R\u0088P\u00F7\u00D0\u00E4\x1E2\u00DD\u0098\u00ABh\u00CC\u00AAU\u00AC\u00E6\u00A2\u00AF\u00A4\u00E7\u00A2\u00FFG\u00C9\u00E2\">FK:\u00DA\u00F9>M\u00D2\x0B\u0092\u00FE-\u00E9ZI\u00E7x\u00F4\u00BBI:_\u00D2\tN\u00DElI\x07\u00AA\\i]t\u008Ehv\u0093\u00C5\u0091\u00D6I\u009A'i\u00A2,\x1EU\t\u00FD%m.S\u0082/\x02\x1A$u\u0091\u00C5\u00BD\x16\u00C9\u0094+\x0B]e\x0Bq\x17\u00D9\u00CF\u00EB\u00DE\u0093\u00F4\u0096\u00A4)\u0092&\u00C86\u008C\u009A\u00F1Y+\u00D6V\u0092\u009E\u0097\u00B4\u0093\u00AC#'I\x1A/\x0B(\u00B6\u0090)\u00D1\r\x0E\u00FD\\Y@v\u00B2\u00A4\u00BD$\u00BD-\u00DB\x15W\u00CAVg\x17\u00D9o\x07\u00DB9<O\u00CA~W\u00B8h\u00C3u\u00E3\u00FF\x0E\u00F5\u0092>Y\u009F\x02?k\u00C5\u0092\u00A4\u00F3d\x11\u00DE\x18\x13$\u00CD\u0094\x1D\u00AF\u00879\u00F9\x1FK:\\\x16\u00E1\u00BDQ\u00D2\u00E9\x19rgH\u00BAU\u00D2M\u00CA\x1F\u00F9\u00DE\u0088\r\u0084\u00CFC\u00B1$;\x06O\u00A8P\u00FE\u009C\u00A43U\u00B2\x0FZ\u00C9l\u0089\x012\u00BB\u00A8\u0085\u00EC\u0097\u00C9\u00AF\u00CA\x14\u00EAI\u00D9\u00AE\u00B6^W\u00DDF\u00D4\u008E\u00CFK\u00B1\u00EA$\r\u0092t\u009C\u00EC\u00FE\u00AAAR\u0093\u00EC\u00E8\x1B+\u00E9.I+\x02|\u00ADd\u00C7\u00A9dJ\u00F4\u00DE\u0086n\u00E8F\u00D4\u0086\u00FF\x01\u00CDl\u008D\u00BE\u00A2,=\u00B2\x00\x00\x00\x00IEND\u00AEB`\u0082"));

                //$.writeln(Folder.userData.absoluteURI + "/" + DIRNAME_RESOURCES);
                var myDataFolder = new Folder( Folder.userData.absoluteURI + "/" + DIRNAME_RESOURCES );  
                myDataFolder.create();

                var myFile = new File( myDataFolder.absoluteURI + "/" + FILENAME_LOGO );  
                myFile.encoding = "BINARY";  
                myFile.open( "w" );  
                myFile.write( imageBinString );
                myFile.close();
                
                var imageFile = File(myDataFolder.absoluteURI + "/" + FILENAME_LOGO  );
                var newImage = ScriptUI.newImage(imageFile);
                this.graphics.drawImage(newImage, (win.size.width - newImage.size[0] - 25), 5, newImage.size[0], newImage.size[1]); 
            }
        };

        win.layout.layout(true);                      
    }
    return win;
}

function populateCompList(pList, pSearchString)
{
    if (app.project != null) 
    {        
        var allComps = app.project.items;                                          
        var selectedComps = 0;
        collectionSelectedComps = new Array();

        for (var i = allComps.length; i >= 1; i--) 
        {
            item = allComps[i];
            
            //if ( (item instanceof CompItem) && (item.name.toLowerCase().indexOf(pSearchString) > -1)  )
            //{
                pList.add('item', item.name);   
            //}
        }  
    }
}

//loop the layers of the first selected comp and use that as our list of layers to choose from
function populateLayerList(pList)
{
    pList.removeAll();

    if (app.project != null) 
    {        
        var allComps = app.project.items;                                          
        var selectedComps = 0;
        collectionSelectedComps = new Array();

        for (var i = allComps.length; i >= 1; i--) 
        {
            item = allComps[i];
            if ((item instanceof CompItem) && item.selected) 
            {
                selectedComps++;
                collectionSelectedComps[collectionSelectedComps.length] = item;
            }
        }

        if (selectedComps >= 1)
        {
            var firstComp = collectionSelectedComps[0]; // we're only using one comp, hope it has the layers you want to use                    

            for (var j=1; j<=firstComp.layers.length; j++)
            {
                //if (firstComp.layers[j].source != null) //layer must have a source
                //{
                    pList.add('item', firstComp.layers[j].name);                        
                //}
            }
        }        
    }
}

function swapItems(pWinGroup)
{
    app.beginUndoGroup("swapitems");

    if (null == pWinGroup.leftCol.botRow.ddlCompToSwap.selection ||
        null == pWinGroup.leftCol.topRow.ddlLayerToSwap.selection
        )
    {
        return;
    }

    var strReplacementComp = pWinGroup.leftCol.botRow.ddlCompToSwap.selection.text;
    var layerNameToReplace = pWinGroup.leftCol.topRow.ddlLayerToSwap.selection.text;

    statusReport = "";
    counter = 0;

    if (app.project != null) 
    {
        if (app.project.items.length < 1) 
        {
            alert("Please select at least one comp.");
        } 
        else 
        {
            var allComps = app.project.items;                                          
            var selectedComps = 0;
            collectionSelectedComps = new Array();

            for (var i = allComps.length; i >= 1; i--) 
            {
                item = allComps[i];
                if ((item instanceof CompItem) && item.selected) 
                {
                    selectedComps++;
                    collectionSelectedComps[collectionSelectedComps.length] = item;
                }
            }

            if (selectedComps >= 1)
            {
                for (var k=0; k<collectionSelectedComps.length; k++)
                {
                    
                    var replacementComp = getComp(strReplacementComp);
                    var strError = "";

                    if (layerNameToReplace == "")
                    {
                        strError = "Please enter a valid layer name.";
                    }

                    if (strReplacementComp == "")
                    {
                       strError = "Please enter a comp name.";
                    }
                    else if (replacementComp == null)
                    {
                        strError = "Can't find comp " + strReplacementComp;
                    }
                    
                    if (strError != "")
                    {
                        alert(strError);
                        return;
                    }

                    var selectedComp = collectionSelectedComps[k];                        
                    var ableToReplace = false;

                    //try to find the layer by looping the comp's layer collection
                    for (var j=1; j<=selectedComp.layers.length; j++)
                    {
                        if (selectedComp.layers[j].source != null) //layer must have a source
                        {
                            if (selectedComp.layers[j].source.name.indexOf( layerNameToReplace ) != -1 )
                            {
                                selectedComp.layers[j].replaceSource(replacementComp,false);
                                selectedComp.layers[j].name = replacementComp.name;
                                ableToReplace = true;
                                counter++;
                                selectedComp.label = 9;
                            }      
                        }
                    }

                    if (ableToReplace == false)
                    {
                        alert("couldn't find a layer in " + selectedComp.name + " with name '" + layerNameToReplace + "'");
                        selectedComp.label = 1;
                    }
                    else
                    {
                        statusReport += "\n\n" + selectedComp.name + " - replaced '" + layerNameToReplace + "'' with '" + strReplacementComp + "'"; 
                    }                    
                }
            } 
            else 
            {
                alert("Please select at least one comp.");
            }
        }        
    } 

    alert("made " + counter + " replacements. \n" + statusReport);
    app.endUndoGroup();
}

function getComp(pName)
{
    for (var i = 1; i <= app.project.numItems; i++)
    {
        if (app.project.item(i).name == pName)
        {
            return app.project.item(i);
        }
    }
    return null;
}