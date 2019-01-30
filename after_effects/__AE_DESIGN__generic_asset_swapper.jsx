/**********************************************************

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"
__date__ = "11/13/2018"

DESCRIPTION

    a script that replaces comps with an existing library comp
        --> select a bunch of comps
        --> set the master comp to copy from (select from dropdown menu)
        --> select the layer to copy over

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

var LABEL_HELP = "1. Select one or more comps.\n2. Enter a filter (i.e. __video) and click Search.\n3. Select the source comp.\n4. Select the layer to swap with the source. \n5. Click Swap.\n\nYou can undo if you need to.";
var LABEL_COMP_MASTER_SOURCE_NAME = "Library comp";
var LABEL_TARGET_LAYER = "Select a layer to swap with the source:";
var LABEL_TRANSFER_PROPS_BUTTON = "Swap";
var MARGIN_LEFT = 50;
var FILENAME_LOGO = "ARLO-EMERSON-DESIGN-LLC.png";
var DIRNAME_RESOURCES = "arlo_emerson_production_tools";

var win = new Window('palette', 'ARLO EMERSON DESIGN PRODUCTION TOOLS', [300,100,800,800]);
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
                
        //------------------------- MASTER COMP SECTION -------------------------

        var strMasterComp = 
        "panel { orientation:'row', text:'Master comp', spacing:5, margins:10, alignment:['fill','top'], \
            leftCol: Group { orientation:'column', alignment:['fill','top'], \
                filterRow: Group { alignment:['fill','top'], \
                    lblMasterComp: StaticText { text:'filter', alignment:['left','center'] }, \
                    txtMasterCompFilter: EditText { text:'', characters:30, alignment:['fill','center'] }, \
                    searchButton: Button { text:'Search', alignment:['right','center'] }, \
                }, \
                topRow: Group { alignment:['fill','top'], \
                    lblMasterComp: StaticText { text:'" + LABEL_COMP_MASTER_SOURCE_NAME + "', alignment:['left','center'] }, \
                    ddlMasterComp: DropDownList { text:'', characters:30, alignment:['fill','center']  },  \
                }, \
            } \
        }";
        
        win.objForm1 = win.add(strMasterComp);
        win.objForm1.leftCol.filterRow.searchButton.onClick = function() { populateSearchResults( win.objForm1.leftCol.topRow.ddlMasterComp, win.objForm1.leftCol.filterRow.txtMasterCompFilter.text ) };


        //------------------------- TARGET LAYER SECTION -------------------------

        var strTargetLayer = 
        "panel { orientation:'row', text:'Target layer', spacing:5, margins:10, alignment:['fill','top'], \
            leftCol: Group { orientation:'column', alignment:['fill','top'], \
                topRow: Group { alignment:['fill','top'], \
                    lblTargetLayer: StaticText { text:'" + LABEL_TARGET_LAYER + "', alignment:['left','center'] }, \
                    ddlTargetLayer: DropDownList { text:'', characters:30, alignment:['fill','center']  },  \
                }, \
            } \
            rightCol: Group { alignment:['fill','fill'], btnDoAction: Button { text:'" + LABEL_TRANSFER_PROPS_BUTTON + "' , alignment:['fill','fill'], preferredSize:[100, *]}, \
            } \
        }";
        
        win.objForm2 = win.add(strTargetLayer);
        populateTargetLayerList(win.objForm2.leftCol.topRow.ddlTargetLayer);
        win.objForm2.rightCol.btnDoAction.onClick = function() { swapItems(win.objForm1, win.objForm2) };

        //------------------------- GLOBAL BUTTONS SECTION -------------------------

        var strGlobalButtons = 
        "group { \
            orientation:'column', alignment:['fill','fill'], alignChildren:['left','top'], spacing:5, margins:10, \
            cmds: Group { \
                alignment:['fill','top'], \
                refreshLayersButton: Button { text:'Refresh', alignment:['right','center'] }, \
                cancelButton: Button { text:'Cancel', alignment:['right','center'] }, \
                helpButton: Button { text:'?', alignment:['right','center'], preferredSize:[25,25] }, \
            }, \
        }";

        win.objGlobalButtons = win.add(strGlobalButtons);
        win.objGlobalButtons.cmds.refreshLayersButton.onClick = function() { populateTargetLayerList( win.objForm2.leftCol.topRow.ddlTargetLayer ) };
        win.objGlobalButtons.cmds.cancelButton.onClick = function() {win.close(0)};
        win.objGlobalButtons.cmds.helpButton.onClick = function() { alert(LABEL_HELP) };        

        //------------------------- FOOTER SECTION -------------------------
        
        var strFooter = 
        "panel { \
            orientation:'column', text:'', alignment:['fill','fill'], alignChildren:['left','top'], spacing:5, margins:10, \
            topRow: Group { \
                alignment:['fill','top'], \
                lblMasterComp: StaticText { text:'asdf', alignment:['left','center'] }, \
            }, \
        }";
        
        win.objFooter = win.add(strFooter);
        
        //$.writeln(win.objFooter);
        win.objFooter.onDraw = function()
        {
            var fillBrush = this.graphics.newBrush( this.graphics.BrushType.SOLID_COLOR, [1, 1, 1, 1] );
            //this.graphics.rectPath(0, 0, this.size[0], this.size[1]);
            //this.graphics.fillPath(fillBrush);  
            
            
            var resourceFolder = Folder.userData.absoluteURI + "/" + DIRNAME_RESOURCES;
            //$.writeln(resourceFolder);     
            var newPath = resourceFolder + '/' + FILENAME_LOGO;                                   
            var imageFile = File(newPath);            
            
            if (imageFile.exists)
            {
                var newImage = ScriptUI.newImage(imageFile);
                //$.writeln(win.size.width);
                this.graphics.drawImage(newImage, (win.size.width - newImage.size[0] - 25), 5, newImage.size[0], newImage.size[1]);  
            } 
            else
            {
                var imageBinString = (new String("\u0089PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x01\x10\x00\x00\x00\x11\b\x06\x00\x00\x00\x15!\u00F3\x04\x00\x00\b\u00EAIDATx\u009C\u00CD\\\u00ED\u0091\u00F28\f~\u00CEs\r\u00A4\u0085\\\tyK`K`K\b%@\tPB(\x01J\u0080\x126%@\t\u00D0\u0081\u00F6~X\"\u008A\u00E3\u00CF\u0084\u00DD;\u00CDdvHl\u00D9\u00D6\u00B7-y\u00FFB\x04\u0088he\u008C\u00B9&\u00DA\u00B4\x00*\u00CF\u00A7'\u0080\u00DE\x18\u00D3\u00BB8\x014\u00C6\u0098C\f\u00AFg\u009C5\u0080\u0086\x1F\u0081+\u0080\u00AB;\u00C6\u00CC\u00F9j\u00E8e\u00DD94\u00F0\u008CQ\x03\u00801\u00E6>g\\\"\u00DA\x06\u00BE\u00DF\u00B9\u00CD\u00DD\u00FD\u00C0t]\x03\u00A8ai\x7F5\u00C6\x1C3\u00E6)t\u0095\u00B9\u00DD\x01\u00F4\x00\u00CE\u00C6\u0098g\u00A0\u00DF\u00DA\x18sN\u00ACE\u00CF+\u00CA\u00EF\u00C4z\u00EF1\u00FE\n\u00FE\u00C44\u009EB\x0B\u00E6\u00C3\nv\u00BDw\u00D8u\u00BE\u00F8\u00ABhr\x0E\u00D0\u00B9\u00C2@gW\x16\u00EF!\u00BA0\u00DE*WV\u0099&}H\u00F62\u00E9\u00BAD\u00D7jX:\t\u00F4\x18\u00E8\u00E5\u0095\x0B\x17IED\x0FQ\u0086H\u00BB\x0B\x11}G\u009E\x0B\x13]\u00DAo\u0089\u00E8\u00BBd1Dts\u00F0]\u0088\u00E8\u00CBy\u0097\x12\u00A2\u00DC\u00F9~k\u0081&\u00A2\x13\x0B]6\x10Q\u00E7*E\u00C9\u00B8\x19\u00ED\u00F6\x0E\u00EE-\u00BF\u00BF\u00F18\x0F\x1F\u00EDU\u00FB\u008A\u00E7\u00F8\u00ED\u00F4\u00D3}\x1F!\u00C5\u00E6vY4\u00C9\u00E1w\u00C6zcs\u00D9f\u00F4\u00BF8<\u00F8r\u00F8\u00B1W\u00F8V\u00FCn\x15\x18\u00EB\u00A1\u00F1zd\u00F1\u00E6\u00A3\r\u00E3\u00FD\u00F2\u00F1#B\u0093\u0090a\u00CD\u00A5\u00EB\u00BBtM\u00D3*\u00C8\x0B\u00EF\u00E0D\u00D4%\u00DA]\u0084A\u00CE\u00FB\u008A\u0088Z\x1E\u00F0k\u00CE\u00A2\u0088h\u009F`J\u00A5\u0098\u00FA\u00C8\x11\u00EA\u00D0|\u00DF\u00D8\u00BE\u00F21\u00BF\x04OHx\u0088\u00A8V|\u00D9\u00F3\u00BB\u00C6\u00C7'e .\u00CE\u00FBF\tIG\x1E\x07\u00C1\u00C2.B31B\u00EA\u00DBD\u00C9<\u00B8r\r\u0088K\u00AF\u008A\u00E7\u00B1U\n:Q\u00C0\\yRtk\u00D5\u00BBJ\u00E1\x16\u00E3=1 \u00DCN\u00D3c\u00ED\u00C1/\u00BC\u00F1\x1Ao\u0085w\u0091\f\u0094\u00AC\u00FB\u009D\u00BA\u00C6m\u00D646\u00C2ac\u00A8\u0084\u00EC\x11k\u0098R\f6\"\u00DFB\u00F4\x19\f\u00EF\u00A2\x13\u00C5\u008By\"\b\u00D1Hd\u0086A\x10\u00CB\u009BT\x16g\u00DE\u00AE\u00E2.6 \u00EA\u00BB\x18\u0087J\u008D\u00E7\u008B4\u00B6\u009A\x1E\u00DC\u00FE\u00C6<\u00CDV~\":y\u00D6\"\u00B2\u0091\u00A2\u00F7,\x03\x12\u0099\u00CB\u0097\u00EF}\u00C6Z.n_~_\u00B1\u00F2T\u00FC\u00DBg@N9sT\u00F8:\u00B7\u00BD\u00C2\u009Bt\u00CA\u00DC\u00FE\u00D7\f\be\x06\x0B\u009E\u00F6\u00FE\u00F9)\u00A5o3\x16\u0092T\f\u008D#s\u00E1\u00B5Op\x13}D9n\u0089vs\rH\u00B2\x0F\r\u00DB\u00BE\u009F6 /!W\u00CC\u008Cn5\u00B9\u009F\bv\u00D6v\u008F\u00FB\u00F8<\u00B7\u0084\u00ED\u00F2\u00C4\x1C\u00CC[\f\b\u00B7\u009B\u00C8c\u00A1\x01\u0089\u00CA\x06\u00B7\x1B\x19\u0090\x1C\x1D\b\u00E1\t\u00E0\u00ED\\z\x06\u00FA\u00FF\u008A\x01\u00A1!\u0082\u00CD\u00D65\u00EE\u00B7\x02\x00\x13\u00F8\u00BE\u00C5p\bw\x05Pt\x06\u00E0\f\u0094\u00B5\u00E7\u00F3\u008C\u00FF\x04\u00B0\u00C9\u00ED\u00C0\x07;\x1B\x00u\u008A9\u00B9\u00A0\u0084\u00E0\b`\u00E5\n\u0085\x07\u00E4\u00A0\u00F4\u0088\u00F1\x01\u00D4\u00BBA\u00D3T\x0E\u00EDR\x1E\u00BC\u0086\u009D\u00DF\u00AE\u00E4\u00D0\u0099\x0F\u00E0\u00AE\x1E\u00FCO\x00\u009F\u00B0\u0087m\u00D9\x06y\t(y,Rf\u00863\u00E6\u00C9\u00C6\x16\u00F6p\u00B4\u00E8 2r\u00F0~\x06p\x00\u00D0\u0091g+\u00F4\x1F@\u008BB]\x03\u0086\u00F5M\f\b\x13\u00B8\u0086U\x02\u00F0\u00DFz\u00C1b\u0085a%\u0099\f9\x05O\u009F\u00F6*\u00E0E\u00DD\u00F1>\u00E5\x15E=2\u00DE\u0098G\u00A8\u00F8\u00BB\u00B4\u009Dk<s\u00A0\u0085\u00CD,\\9S\u00B0\x03\u00D0r\u00A8\x1D\x1AS\u00F8\u0097\u0095=q@\u0094o\x14\u00B9\u00F0\u00D8\x1F\x00\u009A\u00DC\u00F0\u00F7\rp\x06Pe\x18\u00F3\x11(\u00E339\u00E0\x0E\x01\u00AF\u00B7\u0086U\u00F8\u00B7\u00811f\x07\u00BB\u008E\u00AE$\x1A\u00FC!h1C\u00D7\x04\u00FE\u00F6\u00BC[C\u00A5\u00A3\u008C1g\"\u00BA\u00CB@\x01<>\u0086J\x1Ah\r\u00E0X\u0090\u00BE\u0092\u0094b\u00B6\u0097t\u00E0\u008Ct\u00C4\u00D4$\u00B6\x13g\x168I\u00C7\u00F6D$^#\u0094\u00D6\u0095\u00E8\u00E3 \u00FD`\u00D3|\u00BAm\u00EE\u00B8\u0080UX\u0097\u00A6\r\u0086\u00B4\u00EB\u00CBc\x18c\x0ED\u00F4\x04\u00D0\u00F1\x18\x1B\u00CF\x1C\x1BX\u00BENR\u0093\x19pf\u00DC+8|a\u00DAl`iS\u00EC\u00A9g\u0080\u00ACkD\u00DB\x04]{c\u00CC\u00CE\x18\u00F3\u00C1\u0086n\u00CF\u00B4\u00DD$\u00E8!\u00F4/J\u00E3g\u00C2\x066r;\x11\u00D1\u009F\u00B9\n\u00BC\x04\u0094\u00F1\u009A\u00BD\u00BEQ\x04\u00C2D]ajq%\u0084\x0F\u00ED\u00B3\x1BXb\u00E8\u00A7\u00E3\u00F7;cLIx\u00A4\u00EB\x11\u00E6\u00C0\x13\u00E9z\u008B\u0092\u00B9<\u0081\u0097\x07\u00F3F!:\u00FA`\u0081|\u00AA\u00FEs\u00A1\u00C5\u0094\u00A6\u0092n\u00FCtk<\u00F8\u00F7\x1F\u00FEy\u00F1xY\u00A9{(\u0086\u0094p\u00F3\u00D8;X\u00C5|\u00CB\u00F612\u00D6\\\u00B9\u0090\u00FE\x1BX\u00E5m\x00|\u00E5D\u00D6K\u00C7\f\u00E0|\u00C2Fo\x15,\u00BF~*Z\u008D\u0081\u008C9\u00DBx\u00B9\x11\u0088\u00EC\u00F7\u00DC\x02\u00A4#\u00AC\u00F0\u00B6\u00B0\u0082\u00E2B\u00CF\u00EF\u00F7\u00B0\u00DEw\u0083@\u00C1\u00D3\u00FF\x04zc\u00CCGF\u00BB\x06c\u008F{\x04{/\u00C7\u00C3K\u00F4!Q[OD\u00C0\x10\u0089\u0094\u008E+c]a\r\u00B1lS\u00FA\u00982\u00F3\u00B8\x7F\u00B8\u00CF\u009E\u0088\u00EAB\u00E3=\x1B8\n\u00AAy\u00DCI\x01\u00E1/\u008C\u009FKW\x18c\u008ED\u00D4\u00C3\u00D2\u00E9\u00C4\x11[\u00B4\u00E8.\x05\u0091\u00C3\u00CAkhn\u00C6\u0098'\x11}`p\x0E\u00BF\u00C2\u00ABw\u00C2+\x02\u00E1pf\x05\x1B:\u008F\nq\x00<\u00B8Y\x1B\u00B0\u0094OV(!\u00C0z\u0081\u00F1\x10\u00C1\u009B\u00BB7t\u0095~\t\u00D4\x18{\u00ED#\u00AC\u00B5v\u00BDV\x0B+(\u00DA\u00A8\u00DC15 % \u00DB\u00C8\x1D\u00B8\x027'\u00CC5\u00C6<\u008D1\u009F<\u00D7VE\"=f\u00D2T\u0085\u00BA)\u009E\u00EE\u00B8\u00CD\u008FyT\x15\x05/\n\u00F9\u00D9\u00C0}\u00C0\u00D2\u00A5\x0B\u009C\u00A9\u00C8YV\u00CE\u00F9\u00DF\u00CE\u00F3\u00E8h46\x0F9\u00C3\u009As8\u00BC\x04\u0096\u00EA\u00DAh\x0B#\u00A7\u00B1>B\u00EC`\u00B75R\u00C6\u00EBGf\u0089\u00B1\x01\u00B0\u009EK\fV\u0092\x1E3\x0EBi(3~\u00D7\u009Eud@xn\x07Xf\u00D7<\u00A6\x1C:\u00BB\u00DB\u00BE\u00A5\x06D\u00C6<2\u00EE}@\u00C8C\u00FD6\x18g,z\u00CC8|d\x10\u009EG\u00E9\u00AA\u00C2\u00F2'~\u00CE\u0088\u00C8\u00FC\x17;\tg\u00BE\u00BE\u00AD\u0097\u00AC7I3c\u00CC\u00C1}\u0090y\u0096\u00F7\u009B[@g\\\u00D1\u00B5e\u00D9 \x1A\u00EA.R\u00A9\u00C0I.\u009D<\u00F5\r4T\u00B5\u0085\u00CA\u0081S\u00B9\u00E9Q\u00F1Y\u00C1:d\u00DC\u00A0\u00E2\u00FA\u00E6\x1Bh'\u00F9\u00F1\u00D6y/\u00B5\x1E\x1D\u00FF\u00BE\u00F9\u00F0q\u00BE\u00FF\u00A1~/\u00AA\x03![o\x11-\u00EA\u00F3\u00E0Y\u00D3\u00B8\u00A6\u00E1F\u009Eb\u00AA\x04\u008EZ\u00AF\u0097\u00DF\u00A5\u008A\x07\x1B\u00E9\u0093\u00C9\u00EF\u00EC:\x0Brj}r\u00F0g\u00E0\u00DC\x0B\x0E\u009A\u00D6\u0081t\x14\u0090\u00E5\x04N\u0091aq4\u00C1\x12y\u00D5\u00A7c\u00BA5)\u009Ad\u00D2\u00F5\u00C7tM@\"\x10\u00A9\u00BBH\u00ED\x03%\u009D\x17%&\u00A7\u00A9z\u00D8\u00FDe\u00B1\x17f\u008B,\u00A1e\u00EE\x1D\u0097\x16v\x1D\u00877\u009D\u00BDx\x0Fs\u009D(d\u008Bp\u009A\u00EF\u008E\u00F7\x1D\u00E6\x02\u00B6\u00E6\x02P5\x17,h\u00D9\u00F7\u0080\u00C0\u00DB!\u00CA\u00AF8\u00AC\x00H\u0081QvvEE\u00A2\u00C2\u0093\u00B7\x00\u00CF\u00BB8\u00ADJC\t\u00F6\x1C~\u00EC`u\u00E3T \u008B\r\u00EC\u0099\u00C6\u00B1D\x169j\u00BC\u00E3\u0097\u00EAjx\u00CC9\u00BA\u00D6\u00B0Ck\u00B2\u00A3\x0F\u00D5\u00F9F\u00AAj-\u00E4\u008D\u0094\u00A7\u009E[z,\u009E\u00EF\u0091\u00B2\u008ED\u00FE2\u00E7@\u00DB\u00DC\b$V\"\x1E\u00AC8Um\u00C4\u00FB7%\u00E3r\u00DB\u00D0]\x18\u00F1br\x0FFht\x0B\u00CC\u00D3\x171J\u0094\x16\u00AB\x19\u00D1B2\u00F1N3h\u00B8(\x02\u00E1uJ9\u00B9{\u00E7'\u00C7\u00CB\n/&\u00D5\u00964\u008D(}\u00A5\u00EC\x12Q%\u00EF[q\x7Fi\u00EB\u00BB\x0B\x13u\u00BE4TT\u00FFf)\u00BB^_J\u00D7\u00D6J\u00F6\u00DB\u00BFQ^`$\u0099\u0088:f]\u00F9\u0084\u00F9\x13v/\u00DC\u00B9\u00D9\u0080\bq\u009E\u00C6\u0098\u00A31\u00E6ND\u00FF`\u00C8\u0095\u00F7<G\u00D9SV\u00B0\u0087?\u00BA\u00FA\u00D3\u0097!\u00F2A\u009D0\u0098\u00AF}\u00AB\u00EF\u00E0\u0092\u00D7v\u0080\u00F52!o\u00E8K\u00E5&\u00C7\u008D\u00FD\u00EB\x00\u00BE\u00EA/{\u00E5;g\x13v\u00B0\u00D9\u0084\x1B\u00CF\u00A9\u0087\u00F5\u00D2-,}>\x1D\x1C;\u00B2u=\x1Dlj^h*\u00BC\u0094\u00C3\u00F4\x15\u00AF\u00E1\u00A3\u00F4\u00DF\x19\u00A8\u00B1$3\u0093\u00B3\u00AF_\u0091\u00CD\\i\u00A81\u00BEV~\fe\u0095\x12t\u0095\u00E8\u00BAe'#)\u00F9\x06C\u0084\x14\u008Cj8\u00BB\u00F5\x01\x1B\u008DI!\u009A\u00D0M\u00F8\u00AC\u00E9\u00D6\u00C3\u00D6\u0098\x14\x1F\u00F4j\u00BD\u00C9i\x1F\u00D3\u00A3\u009C6\u00ACk\u00B2>\u00C9J\u00DDai\u00A4\u00CFot\r\u00D2 \x17\u00E4\u00ECo3&,\u00B7M\u00C5\x0B\u00A6\u00F6\u00C3\u00A3\u00BB\x14\u00DA+\x05\x1E_4\u00D3\u00D2\u00F8\u00CA\u00B4~N)\u00AB\u00EE\u00E0\u00CA\u00BAVO\u0081\u00CBW\x0E\x1DJ\u00EE\x00\u0095^\u00E7\u008Fy\u009F\x13\u00A9\u008Bl\u00EC\u00DDn\x0E\u00AE[\u008C.d\u00BD\u00BA\u00EC\u00B9\u00DDy\u00DC\u0098\x06\u00DE\b%\u00C5s_\u00FB\u00C4\u00F7\x18M\u00BEx\u009E\u00DE\u00B5d\u00C8\u00D3K\u00A6hz\x1D\u00FF\u009B\u00D7R+|\u00B1\u00EB\u00FCry1$\u008B\u00B7\x10\u00DFbx#\u00ED\u0093\x11Hl\u00CD?\u00A0k\x13\u00B9\u00F8\x17\u00C2\x7F\n=\u00E8\u00E1\u00C4\u0093\x00\x00\x00\x00IEND\u00AEB`\u0082"));

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

//loop the layers of the first selected comp and use that as our list of layers to choose from
function populateSearchResults(pList, pSearchCriteria)
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
            if ((item instanceof CompItem) && item.name.indexOf(pSearchCriteria) != -1) 
            {
                collectionSelectedComps[collectionSelectedComps.length] = item;
                pList.add('item', item.name); 
            }
        }     
    }
}

//build a list of layers from the first comp in a group of selected comps
//this assumes the user knows exactly what they are doing
function populateTargetLayerList(pList)
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
            var firstComp = collectionSelectedComps[0]; // we're only using one comp, you better hope the layers in this are similar to other selected comps                    

            for (var j=1; j<=firstComp.layers.length; j++)
            {
                if (firstComp.layers[j].source != null) //layer must have a source
                {
                    pList.add('item', firstComp.layers[j].source.name);                        
                }  
            }
        }        
    }
}
function swapItems(pWinForm1, pWinForm2)
{
    app.beginUndoGroup("swapitems");

    if (null == pWinForm1.leftCol.topRow.ddlMasterComp.selection ||
    null == pWinForm2.leftCol.topRow.ddlTargetLayer.selection)
    {
        return;
    }

    var strReplacementComp = pWinForm1.leftCol.topRow.ddlMasterComp.selection.text;
    var layerNameToReplace = pWinForm2.leftCol.topRow.ddlTargetLayer.selection.text;

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
                    item.label = 1
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
        if ((app.project.item(i) instanceof CompItem) && (app.project.item(i).name == pName))
        {
            return app.project.item(i);
        }
    }
    return null;
}