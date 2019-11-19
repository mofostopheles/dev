using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.IO;
using Microsoft.WindowsAPICodePack.Dialogs;

/*
 * A very simple file renaming tool, intended to rename video files upon ingest.
 * @author Arlo Emerson <arloemerson@gmail.com>
 */
namespace VideoRenamerTool
{

    public partial class UserControl1: UserControl
    {
        string selectedPath = "";
        string sDate = "";
        int filesTouched = 0;
        int foldersTouched = 0;

        public UserControl1()
        {
            InitializeComponent();
        }

        private void ButtonChooseDir_Click(object sender, EventArgs e)
        {
            CommonOpenFileDialog dialog = new CommonOpenFileDialog();
            dialog.IsFolderPicker = true;

            if (dialog.ShowDialog() == CommonFileDialogResult.Ok)
            {
                selectedPath = dialog.FileName;
                labelSelectedDir.Text = selectedPath;
                string[] folders = selectedPath.Split('\\');

                // determine the date....loop ancestors until we get something that looks like a date
                for (var i = 0; i < folders.Length; i++)
                {
                    string folderSplit = folders[i].Split('_')[0];
                    if (folderSplit != null)
                    {
                        if (int.TryParse(folderSplit, out int n))
                        {
                            sDate = folderSplit;
                            textBoxDate.Text = sDate;
                            buttonRenameFiles.Enabled = true;
                        }
                    }
                }

                labelStatusMessage.Text = ""; //reset the status text to nothing
                filesTouched = 0;
                foldersTouched = 0;
            }
        }

        private void ButtonCloseApp_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void ButtonRenameVideos_Click(object sender, EventArgs e)
        {            
            string fileExtension = "";
            int sceneIndex = 0;
            bool renameEverythingThisDir = false;
            bool renameEverything = false;

            //get the child folders
            List<string> folderEntries = new List<string>();
            foreach (var folder in Directory.GetDirectories(selectedPath))
            {
                folderEntries.Add(folder);
            }

            //if for some reason the user is INSIDE a sub folder with no child folders, then folderEntries length will be 0, 
            //therefore, let's assume the user really wants to modify names just inside here, so let's populate folderEntries with current folder
            if (folderEntries.Count == 0)
            {
                folderEntries.Add(selectedPath);
            }

            if (folderEntries != null && folderEntries.Count > 0)
            {
                for (var i = 0; i < folderEntries.Count; i++)
                {
                    string subFolderPath = folderEntries[i];
                    string[] fileEntries = Directory.GetFiles(subFolderPath);
                    renameEverythingThisDir = false;

                    // reset sceneIndex to inital value from number box
                    sceneIndex = Decimal.ToInt32(numericUpDown1.Value);

                    if (fileEntries != null && fileEntries.Length > 0)
                    {
                        for (var f=0;f<fileEntries.Length;f++)
                        {
                            string oldFileName = Path.GetFileName(fileEntries[f]);

                            if (!fileExtension.Contains("DS_Store") ) // ignore any mac directory files
                            {
                                //first, get the file extension
                                fileExtension = Path.GetExtension(fileEntries[f]);

                                if (IsFileExtensionOnRestrictedToList(fileExtension))
                                {
                                    string scene = "";
                                    scene = sceneIndex.ToString("0000");

                                    string subFolder = subFolderPath.Substring(subFolderPath.LastIndexOf("\\")+1);

                                    textBoxCamera.Text = subFolder;

                                    string newFileName = textBoxDate.Text + "_" + textBoxCamera.Text + "_" + scene + fileExtension;
                                    string folderSlash = "\\";

                                    if (checkBoxConfirmEach.Checked && !renameEverythingThisDir)
                                    {
                                        DialogResult dialogResult = ShowDialog(newFileName);
                                        if (dialogResult == DialogResult.Yes)
                                        {
                                            renameEverythingThisDir = true;
                                        }
                                        else if (dialogResult == DialogResult.No)
                                        {
                                            renameEverythingThisDir = false;
                                            break;
                                        }
                                    }
                                    else if (!checkBoxConfirmEach.Checked && !renameEverything)
                                    {
                                        DialogResult dialogResult = ShowDialog(newFileName);
                                        if (dialogResult == DialogResult.Yes)
                                        {
                                            renameEverything = true;
                                        }
                                        else if (dialogResult == DialogResult.No)
                                        {
                                            renameEverything = false;
                                            break;
                                        }
                                    }

                                    if (renameEverythingThisDir || renameEverything)
                                    {
                                        System.IO.File.Move(subFolderPath + folderSlash + oldFileName, subFolderPath + folderSlash + newFileName);
                                        string tmpPath = subFolderPath + folderSlash + newFileName;
                                        filesTouched += 1;

                                        if (checkBoxWriteMetadata.Checked)
                                        {
                                            string strCmdText;
                                            string strCmdMode = "/C"; // 'C' runs the command and closes the window, 'K' will leave the terminal open

                                            if (checkBoxShowCMD.Checked)
                                            {
                                                strCmdMode = "/K";
                                            }
                                            strCmdText = strCmdMode + " \"C:\\Program Files\\exiftool-11.73\\exiftool.exe\" -v -overwrite_original -Subject+=" + subFolder + " " + tmpPath;
                                            System.Diagnostics.Process.Start("CMD.exe", strCmdText);
                                        }
                                    }
                                    sceneIndex += 1;
                                }
                            }
                        }
                    } 
                }
            }
            labelStatusMessage.Text = "Renamed " + filesTouched.ToString() + getPluralEnding(filesTouched);
        }

        private string getPluralEnding(int pArg)
        {
            if (pArg > 1)
            {
                return " files.";
            }
            else
            {
                return " file.";
            }
        }

        private DialogResult ShowDialog(string pNewFileName)
        {
            return MessageBox.Show("You are about to rename all files \nin this folder to the following format: " + pNewFileName, "Confirm batch file rename", MessageBoxButtons.YesNo);
        }

        private bool IsFileExtensionOnRestrictedToList(string pFileExtension)
        {
            //first, if NONE of the boxes are checked, just return true...we can change ANY file type
            if (!cbxAVI.Checked && !cbxMP4.Checked && !cbxMOV.Checked && !cbxMXF.Checked && !cbxBRAW.Checked)
            {
                return true;
            }
            else
            {
                if (cbxAVI.Checked && pFileExtension.ToLower().Equals(".avi"))
                {
                    return true;
                }
                if (cbxMP4.Checked && pFileExtension.ToLower().Equals(".mp4"))
                {
                    return true;
                }
                if (cbxMOV.Checked && pFileExtension.ToLower().Equals(".mov"))
                {
                    return true;
                }
                if (cbxBRAW.Checked && pFileExtension.ToLower().Equals(".braw"))
                {
                    return true;
                }
                if (cbxMXF.Checked && pFileExtension.ToLower().Equals(".mxf"))
                {
                    return true;
                }
            }

            return false;
        }

        private void LabelTitle_DoubleClick(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }
}
