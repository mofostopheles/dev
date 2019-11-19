namespace VideoRenamerTool
{
    partial class UserControl1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(UserControl1));
            this.folderBrowserDialog1 = new System.Windows.Forms.FolderBrowserDialog();
            this.buttonChooseDir = new System.Windows.Forms.Button();
            this.labelSelectedDir = new System.Windows.Forms.Label();
            this.labelCurrentDir = new System.Windows.Forms.Label();
            this.labelFileExt = new System.Windows.Forms.Label();
            this.labelScene = new System.Windows.Forms.Label();
            this.textBoxDate = new System.Windows.Forms.TextBox();
            this.labelUnderscore3 = new System.Windows.Forms.Label();
            this.labelDate = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.numericUpDown1 = new System.Windows.Forms.NumericUpDown();
            this.labelCamera = new System.Windows.Forms.Label();
            this.textBoxCamera = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.buttonRenameFiles = new System.Windows.Forms.Button();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.checkBoxConfirmEach = new System.Windows.Forms.CheckBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.cbxAVI = new System.Windows.Forms.CheckBox();
            this.cbxBRAW = new System.Windows.Forms.CheckBox();
            this.cbxMXF = new System.Windows.Forms.CheckBox();
            this.cbxMOV = new System.Windows.Forms.CheckBox();
            this.cbxMP4 = new System.Windows.Forms.CheckBox();
            this.folderBrowserDialog2 = new System.Windows.Forms.FolderBrowserDialog();
            this.checkBoxWriteMetadata = new System.Windows.Forms.CheckBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.checkBoxShowCMD = new System.Windows.Forms.CheckBox();
            this.labelStatusMessage = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).BeginInit();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // folderBrowserDialog1
            // 
            this.folderBrowserDialog1.RootFolder = System.Environment.SpecialFolder.MyComputer;
            // 
            // buttonChooseDir
            // 
            this.buttonChooseDir.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(30)))), ((int)(((byte)(30)))));
            resources.ApplyResources(this.buttonChooseDir, "buttonChooseDir");
            this.buttonChooseDir.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.buttonChooseDir.Name = "buttonChooseDir";
            this.buttonChooseDir.UseVisualStyleBackColor = false;
            this.buttonChooseDir.Click += new System.EventHandler(this.ButtonChooseDir_Click);
            // 
            // labelSelectedDir
            // 
            resources.ApplyResources(this.labelSelectedDir, "labelSelectedDir");
            this.labelSelectedDir.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.labelSelectedDir.Name = "labelSelectedDir";
            // 
            // labelCurrentDir
            // 
            resources.ApplyResources(this.labelCurrentDir, "labelCurrentDir");
            this.labelCurrentDir.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.labelCurrentDir.Name = "labelCurrentDir";
            // 
            // labelFileExt
            // 
            resources.ApplyResources(this.labelFileExt, "labelFileExt");
            this.labelFileExt.Name = "labelFileExt";
            // 
            // labelScene
            // 
            resources.ApplyResources(this.labelScene, "labelScene");
            this.labelScene.Name = "labelScene";
            this.toolTip1.SetToolTip(this.labelScene, resources.GetString("labelScene.ToolTip"));
            // 
            // textBoxDate
            // 
            this.textBoxDate.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(30)))), ((int)(((byte)(30)))));
            this.textBoxDate.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.textBoxDate.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            resources.ApplyResources(this.textBoxDate, "textBoxDate");
            this.textBoxDate.Name = "textBoxDate";
            this.toolTip1.SetToolTip(this.textBoxDate, resources.GetString("textBoxDate.ToolTip"));
            // 
            // labelUnderscore3
            // 
            resources.ApplyResources(this.labelUnderscore3, "labelUnderscore3");
            this.labelUnderscore3.Name = "labelUnderscore3";
            // 
            // labelDate
            // 
            resources.ApplyResources(this.labelDate, "labelDate");
            this.labelDate.Name = "labelDate";
            this.toolTip1.SetToolTip(this.labelDate, resources.GetString("labelDate.ToolTip"));
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.numericUpDown1);
            this.groupBox1.Controls.Add(this.labelCamera);
            this.groupBox1.Controls.Add(this.labelDate);
            this.groupBox1.Controls.Add(this.textBoxCamera);
            this.groupBox1.Controls.Add(this.textBoxDate);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.labelScene);
            this.groupBox1.Controls.Add(this.labelUnderscore3);
            this.groupBox1.Controls.Add(this.labelFileExt);
            resources.ApplyResources(this.groupBox1, "groupBox1");
            this.groupBox1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.TabStop = false;
            // 
            // numericUpDown1
            // 
            this.numericUpDown1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(30)))), ((int)(((byte)(30)))));
            this.numericUpDown1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.numericUpDown1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            resources.ApplyResources(this.numericUpDown1, "numericUpDown1");
            this.numericUpDown1.Name = "numericUpDown1";
            this.toolTip1.SetToolTip(this.numericUpDown1, resources.GetString("numericUpDown1.ToolTip"));
            // 
            // labelCamera
            // 
            resources.ApplyResources(this.labelCamera, "labelCamera");
            this.labelCamera.Name = "labelCamera";
            this.toolTip1.SetToolTip(this.labelCamera, resources.GetString("labelCamera.ToolTip"));
            // 
            // textBoxCamera
            // 
            this.textBoxCamera.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(30)))), ((int)(((byte)(30)))));
            this.textBoxCamera.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.textBoxCamera.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            resources.ApplyResources(this.textBoxCamera, "textBoxCamera");
            this.textBoxCamera.Name = "textBoxCamera";
            this.toolTip1.SetToolTip(this.textBoxCamera, resources.GetString("textBoxCamera.ToolTip"));
            // 
            // label1
            // 
            resources.ApplyResources(this.label1, "label1");
            this.label1.Name = "label1";
            // 
            // buttonRenameFiles
            // 
            this.buttonRenameFiles.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(30)))), ((int)(((byte)(30)))));
            resources.ApplyResources(this.buttonRenameFiles, "buttonRenameFiles");
            this.buttonRenameFiles.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.buttonRenameFiles.Name = "buttonRenameFiles";
            this.buttonRenameFiles.UseVisualStyleBackColor = false;
            this.buttonRenameFiles.Click += new System.EventHandler(this.ButtonRenameVideos_Click);
            // 
            // checkBoxConfirmEach
            // 
            resources.ApplyResources(this.checkBoxConfirmEach, "checkBoxConfirmEach");
            this.checkBoxConfirmEach.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.checkBoxConfirmEach.Name = "checkBoxConfirmEach";
            this.toolTip1.SetToolTip(this.checkBoxConfirmEach, resources.GetString("checkBoxConfirmEach.ToolTip"));
            this.checkBoxConfirmEach.UseVisualStyleBackColor = true;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.cbxAVI);
            this.groupBox2.Controls.Add(this.cbxBRAW);
            this.groupBox2.Controls.Add(this.cbxMXF);
            this.groupBox2.Controls.Add(this.cbxMOV);
            this.groupBox2.Controls.Add(this.cbxMP4);
            resources.ApplyResources(this.groupBox2, "groupBox2");
            this.groupBox2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.TabStop = false;
            // 
            // cbxAVI
            // 
            resources.ApplyResources(this.cbxAVI, "cbxAVI");
            this.cbxAVI.Name = "cbxAVI";
            this.cbxAVI.UseVisualStyleBackColor = true;
            // 
            // cbxBRAW
            // 
            resources.ApplyResources(this.cbxBRAW, "cbxBRAW");
            this.cbxBRAW.Name = "cbxBRAW";
            this.cbxBRAW.UseVisualStyleBackColor = true;
            // 
            // cbxMXF
            // 
            resources.ApplyResources(this.cbxMXF, "cbxMXF");
            this.cbxMXF.Name = "cbxMXF";
            this.cbxMXF.UseVisualStyleBackColor = true;
            // 
            // cbxMOV
            // 
            resources.ApplyResources(this.cbxMOV, "cbxMOV");
            this.cbxMOV.Name = "cbxMOV";
            this.cbxMOV.UseVisualStyleBackColor = true;
            // 
            // cbxMP4
            // 
            resources.ApplyResources(this.cbxMP4, "cbxMP4");
            this.cbxMP4.Name = "cbxMP4";
            this.cbxMP4.UseVisualStyleBackColor = true;
            // 
            // checkBoxWriteMetadata
            // 
            resources.ApplyResources(this.checkBoxWriteMetadata, "checkBoxWriteMetadata");
            this.checkBoxWriteMetadata.ForeColor = System.Drawing.Color.Gainsboro;
            this.checkBoxWriteMetadata.Name = "checkBoxWriteMetadata";
            this.toolTip1.SetToolTip(this.checkBoxWriteMetadata, resources.GetString("checkBoxWriteMetadata.ToolTip"));
            this.checkBoxWriteMetadata.UseVisualStyleBackColor = true;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.checkBoxShowCMD);
            this.groupBox3.Controls.Add(this.checkBoxWriteMetadata);
            resources.ApplyResources(this.groupBox3, "groupBox3");
            this.groupBox3.ForeColor = System.Drawing.Color.Gainsboro;
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.TabStop = false;
            // 
            // checkBoxShowCMD
            // 
            resources.ApplyResources(this.checkBoxShowCMD, "checkBoxShowCMD");
            this.checkBoxShowCMD.ForeColor = System.Drawing.Color.Gainsboro;
            this.checkBoxShowCMD.Name = "checkBoxShowCMD";
            this.toolTip1.SetToolTip(this.checkBoxShowCMD, resources.GetString("checkBoxShowCMD.ToolTip"));
            this.checkBoxShowCMD.UseVisualStyleBackColor = true;
            // 
            // labelStatusMessage
            // 
            resources.ApplyResources(this.labelStatusMessage, "labelStatusMessage");
            this.labelStatusMessage.Name = "labelStatusMessage";
            // 
            // UserControl1
            // 
            resources.ApplyResources(this, "$this");
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(30)))), ((int)(((byte)(30)))), ((int)(((byte)(30)))));
            this.Controls.Add(this.labelStatusMessage);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.buttonRenameFiles);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.labelCurrentDir);
            this.Controls.Add(this.checkBoxConfirmEach);
            this.Controls.Add(this.labelSelectedDir);
            this.Controls.Add(this.buttonChooseDir);
            this.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.Name = "UserControl1";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog1;
        private System.Windows.Forms.Button buttonChooseDir;
        private System.Windows.Forms.Label labelSelectedDir;
        private System.Windows.Forms.Label labelCurrentDir;
        private System.Windows.Forms.Label labelFileExt;
        private System.Windows.Forms.Label labelScene;
        private System.Windows.Forms.TextBox textBoxDate;
        private System.Windows.Forms.Label labelUnderscore3;
        private System.Windows.Forms.Label labelDate;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button buttonRenameFiles;
        private System.Windows.Forms.NumericUpDown numericUpDown1;
        private System.Windows.Forms.ToolTip toolTip1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.CheckBox cbxAVI;
        private System.Windows.Forms.CheckBox cbxBRAW;
        private System.Windows.Forms.CheckBox cbxMXF;
        private System.Windows.Forms.CheckBox cbxMOV;
        private System.Windows.Forms.CheckBox cbxMP4;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserDialog2;
        private System.Windows.Forms.Label labelCamera;
        private System.Windows.Forms.TextBox textBoxCamera;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox checkBoxConfirmEach;
        private System.Windows.Forms.CheckBox checkBoxWriteMetadata;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.CheckBox checkBoxShowCMD;
        private System.Windows.Forms.Label labelStatusMessage;
    }
}
