from Tkinter import *

'''
    really simple data entry tool for getting names+emails into a txt file,
    usually because the original data is handwritten. see readme.txt for more or less the same info.
    i originally made this so my lady can get emails from paper into a single file with no dupes.
    
    arloemerson@gmail.com
'''

class SmartList(Frame):

    def makeTK(self):
        '''
        self.ADD = Button(self)
        self.ADD["text"] = "add it!"
        self.ADD["fg"]   = "red"
        self.ADD["command"] =  self.processForm(1)
        self.ADD.grid(row=5, column=2)
        '''
        
        self.TMP_TITLE_LABEL = Label(self)
        self.TMP_TITLE_LABEL["text"] = "entries are added to 'email_contacts_master.txt'"        
        self.TMP_TITLE_LABEL.grid(row=1, column=2)

        
        self.TMP_NAME_LABEL = Label(self)
        self.TMP_NAME_LABEL["text"] = "name: "        
        self.TMP_NAME_LABEL.grid(row=3, column=1)

        
        self.TMP_NAME = Entry(self, textvariable=self.strVarName)
        self.TMP_NAME["width"] = 50
        self.TMP_NAME.grid(row=3, column=2)
        self.TMP_NAME.focus_set()

        self.TMP_EMAIL_LABEL = Label(self)
        self.TMP_EMAIL_LABEL["text"] = "email: "        
        self.TMP_EMAIL_LABEL.pack({"side": "left"})
        self.TMP_EMAIL_LABEL.grid(row=4, column=1)
        
        self.TMP_EMAIL = Entry(self, textvariable=self.strVarEmail)
        self.TMP_EMAIL["width"] = 50
        self.TMP_EMAIL.grid(row=4, column=2)

        self.STATUS_LABEL = Label(self)
        self.STATUS_LABEL["text"] = "nothing entered yet"        
        self.STATUS_LABEL.grid(row=5, column=2)    
        
    def processForm(self, foo):
        #print(self.STATUS_LABEL["text"])
        self.strName = self.strVarName.get()
        self.strEmail = self.strVarEmail.get()
        
        
        #wipe out the text boxes, reset focus
        self.TMP_NAME.delete(0, END)
        self.TMP_EMAIL.delete(0, END)        
        self.TMP_NAME.focus_set()

        self.addItemToDict()
        self.updateDatabase()

        #if we made it this far then no errors
        self.STATUS_LABEL["text"] = self.strEmail + ", " + self.strName +  " was added"
        
    def updateDatabase(self):
        f = open(self.fileName, 'w')
        for k, v in self.master_dict.items():
            f.write(str(k) + "," + str(v) + "\n")
        
        f.close()
        
    def addItemToDict(self):
        self.master_dict[self.strEmail] = self.strName

    def hydrateDict(self):
        
        with open(self.fileName, 'r+') as fileObj:
            for line in fileObj:
                self.master_dict[line.split(",")[0]] = line.split(",")[1].split("\n")[0]

            
                    
            fileObj.close()

    def makeBackup(self):
        #let's make a physical backup copy before we do ANYTHING
        f1 = open(self.fileName, 'r')
        
        fcopy = open(self.fileName+".backup.txt", 'w')
        #print(f1.read())
        fcopy.write(f1.read())
        fcopy.close()
        f1.close()
        
    def __init__(self, master=None):
        #print('init')

        self.fileName = 'email_contacts_master.csv'

        self.makeBackup()
        
        self.master_dict = {}
        self.hydrateDict()        
        
        #we need these props to copy the TK data bound objects to
        self.strName = ''
        self.strEmail = ''
        
        #we need these two datatypes for TK data binding
        self.strVarName = StringVar()
        self.strVarEmail = StringVar()        
        
        Frame.__init__(self, master)
        root.geometry('{}x{}'.format(400, 100))
        root.wm_title("bunrab's personal email entry tool")
        self.pack()
        self.makeTK()
        
##################

root = Tk()
app = SmartList(master=root)
root.bind('<Return>', app.processForm)
app.mainloop()
root.destroy()



