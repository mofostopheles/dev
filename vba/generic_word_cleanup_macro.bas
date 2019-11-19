Attribute VB_Name = "arlo_macros"

' --------------------------------------------------------------------------
' Author: Arlo Emerson arloemerson@gmail.com
' Last modified: 10/1/2019
' --------------------------------------------------------------------------

' --------------------------------------------------------------------------
' Globals
' --------------------------------------------------------------------------
Public change_log As String ' every time we delete a range, add the range to this string. we will check it for accidentally deleted text later

' --------------------------------------------------------------------------
' Usage: run this function to process docs that need some styling help.
'
' --------------------------------------------------------------------------
Public Sub RUN_ME()
    change_log = ""
    Combine_Para_With_Heading4_v2
    Add_Header
    Remove_Empty_Paragraphs
    Delete_Orphaned_Vertical_Tabs
    Remove_Empty_Paragraphs_From_Tables
    Modify_Styles
    Stylize_Table_Headers
    
    Dim status_string As String
    status_string = "Processing complete. "
    If Len(change_log) > 0 Then
        status_string = status_string + "Oops. I deleted the following text: '" + Trim(change_log) + "'"
    End If
    
    MsgBox (status_string)
End Sub

' --------------------------------------------------------------------------
' call this with the paragraph range you are about to delete
' --------------------------------------------------------------------------
Public Sub Update_Change_Log(p_arg As String)
    If Is_Alpha_Numeric(p_arg) Then
        change_log = change_log + p_arg
    End If
End Sub

' --------------------------------------------------------------------------
' return true if string arg is alpha numeric
' --------------------------------------------------------------------------
Function Is_Alpha_Numeric(p_arg As String) As Boolean
    Dim check_char As String
    
    'Convert the character to Uppercase.
    'So that there is no need to do a check for Lower and Uppercase seperately.
    check_char = UCase(p_arg)
    
    'Check whether input character is Alphabet or Numeric
    Is_Alpha_Numeric = (Asc(check_char) > 64 And Asc(check_char) < 91) Or (VBA.IsNumeric(check_char))
End Function


Public Sub test_run()
    Remove_Empty_Paragraphs
    Modify_Styles
End Sub



' --------------------------------------------------------------------------
' if heading 4 ends with a non breaking space,
' meaning that it says something like "R.7.1.1.3" with no other text,
' then check the following paragraph to see if it is styled Normal,
' if so, then combine that para with the H4
' note: this macro will not modify an H4 that has nested non breaking space
' --------------------------------------------------------------------------
Public Sub Combine_Para_With_Heading4_v2()
    Dim Paragraph As Word.Paragraph
    Dim status_message As String
    status_message = "Merging H4s with their text"

    ' loop each paragraph
    For Each Paragraph In ActiveDocument.Paragraphs
         
         ' within the paragraph search for a non-breaking space ie. Chr$(160)
         With Paragraph.Range.Find
            .Style = wdStyleHeading4
            .Text = Chr$(160)
            .Forward = True
            .Wrap = wdFindStop
            .Execute
        
            If .Found Then
                Paragraph.Range.Select
                
                ' this appears to be an extra test of heading 4 using the bracket notation
                If (Paragraph.Format.Style Like "Heading [4]") Then
                
                    Txt = Paragraph.Range.Text
                    Txt = RTrim(Left(Txt, Len(Txt) - 1)) ' store the text and trim the paragraph mark and whitespace off the right
                    If InStr(Chr$(160), Right(Txt, 1)) = 1 Then ' check if the rightmost character is indeed a non-breaking space
                        ' check if the following paragraph is styled as normal
                        If Paragraph.Range.Paragraphs(1).Next.Range.Style = "Normal" Then
                                Paragraph.Range.Characters.Last.Text = "" ' swap the paragraph mark with an empty string
                                Paragraph.Range.Style = wdStyleHeading4 ' restyle as h4
                                StatusBar = status_message
                                DoEvents
                        End If
                    End If
                End If
            End If
        End With
    Next
End Sub

' --------------------------------------------------------------------------
' remove empty paragraph after H3/H4 and before the following normal paragraph
' --------------------------------------------------------------------------
Public Sub Remove_Empty_Paragraph_After_H4()
    Dim Paragraph As Word.Paragraph

    For Each Paragraph In ActiveDocument.Paragraphs
        If (Paragraph.Format.Style Like "Heading [3-4]") Then
            If Paragraph.Range.Paragraphs(1).Next.Range.Style = "Normal" Then
                text_sample = Paragraph.Range.Paragraphs(1).Next.Range.Text
                text_sample = RTrim(Left(text_sample, Len(text_sample) - 1))
                If InStr(Chr$(13), Right(text_sample, 1)) = 1 Then
                    Paragraph.Range.Select
                    Paragraph.Range.Paragraphs(1).Next.Range.Characters.Last.Text = ""
                    'Paragraph.Range.Style = wdStyleHeading4
                End If
            End If
        End If
    Next
    
End Sub

' --------------------------------------------------------------------------
' add the header legalese
' --------------------------------------------------------------------------
Public Sub Add_Header()
    Dim header_text As String
    header_text = "Classified as Highly Confidential"
    
    Dim status_message As String
    status_message = "Header has been updated with "
    
    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageHeader
    Selection.HomeKey Unit:=wdLine
    Selection.EndKey Unit:=wdLine, Extend:=wdExtend
    Selection.Style = ActiveDocument.Styles("Header")
    Selection.Font.Italic = True
    Selection.TypeText Text:=header_text
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument
    Debug.Print status_message + header_text
    StatusBar = status_message + header_text
    DoEvents
End Sub

' --------------------------------------------------------------------------
' iterate all the paragraphs and remove if empty
' --------------------------------------------------------------------------
Public Sub Remove_Empty_Paragraphs()
    Dim Paragraph As Word.Paragraph
    Dim counter As Integer
    Dim status_message As String
    status_message = " empty paragraphs found and removed."
    
    For Each Paragraph In ActiveDocument.Paragraphs
        If Paragraph.Range.Style = "Normal" Then
            If Paragraph.Range.Text = "" + Chr$(13) Then
                counter = counter + 1
                Update_Change_Log (Paragraph.Range.Text)
                Paragraph.Range.Delete
                StatusBar = "Deleting empty paragraphs"
            End If
        End If
    Next
    Debug.Print CStr(counter) + status_message
    StatusBar = CStr(counter) + status_message
    DoEvents
End Sub


' --------------------------------------------------------------------------
' iterate all the paragraphs and remove empty line feed paragraphs
' --------------------------------------------------------------------------
' NOTE: THIS FUNCTION MAY BE DEPRECATED BY Delete_Orphaned_Vertical_Tabs()
Public Sub Remove_Empty_Line_Feed_Paragraphs()
    Dim Paragraph As Word.Paragraph
    Dim counter As Integer
    Dim status_message As String
    status_message = " line feeds and empty paragraphs found and removed."
    
    For Each Paragraph In ActiveDocument.Paragraphs
        If Paragraph.Range.Style = "Normal" Then
            Paragraph.Range.Select
            
            ' note: none of the constants are working for detecting Linefeed character
            ' ie. vbLf, Chr(10), vbNewLine, so we are resorting to this...
            Dim line_break As String
            line_break = ""
                        
            If InStr(Paragraph.Range.Text, line_break) > 0 Then
                If Paragraph.Range.Text = line_break + vbCr Then
                    counter = counter + 1
                    Update_Change_Log (Paragraph.Range.Text)
                    Paragraph.Range.Delete
                    StatusBar = "Deleting line feeds with empty paragraphs."
                End If
            End If
        End If
    Next
    Debug.Print CStr(counter) + status_message
    StatusBar = CStr(counter) + status_message
End Sub


' --------------------------------------------------------------------------
' this is an example of how to iterate paragraphs and test for empty lines
' NOTE: this function doesn't do anything, it's an example
' --------------------------------------------------------------------------
Public Sub Iterate_Paragraphs()
    Dim Paragraph As Word.Paragraph
    Dim counter As Integer
    Dim status_message As String
    status_message = " empty paragraphs found."
  
    For Each Paragraph In ActiveDocument.Paragraphs
        If Paragraph.Range.Style = "Normal" Then
            If Paragraph.Range.Text = "" + Chr$(13) Then
                counter = counter + 1
            End If
        End If
    Next
    Debug.Print CStr(counter) + status_message
    DoEvents
End Sub

' --------------------------------------------------------------------------
' example of looping lines and printing ascii char of each member
' useful for debugging
' --------------------------------------------------------------------------
Private Sub Ascii_Print()
    Dim sText As String, oDoc As Document, sLines() As String, lIndex As Long
    Set oDoc = Application.ActiveDocument
    
    sText = oDoc.Range.Text
    sLines = Split(sText, vbCr)
    
    Dim lChar As Long, bLine() As Byte
 
    For lIndex = 0 To UBound(sLines)
        bLine = StrConv(sLines(lIndex), vbFromUnicode)
        For lChar = LBound(bLine) To UBound(bLine)
            Debug.Print Chr$(bLine(lChar))
        Next lChar
    Next lIndex
 
    Set oDoc = Nothing
    
End Sub

' --------------------------------------------------------------------------
' modify styles
' we're mainly interested in making things readable by adding space
' before the H1s, H2s and H3s
' convert H4 font to be the same as Normal
' --------------------------------------------------------------------------
Private Sub Modify_Styles()
    With ActiveDocument.Styles("Title").Font
        .Name = "Segoe UI"
        .Size = 28
        .Bold = False
        .Italic = False
        .AllCaps = False
        .Color = -738148353
    End With
    
    ' set Normal to Segoe UI / 11 pt
    With ActiveDocument.Styles("Normal").Font
        .Name = "Segoe UI"
        .Size = 11
        .Bold = False
        .Italic = False
    End With
    
    With ActiveDocument.Styles("Heading 1").Font
        .Name = "Segoe UI Semibold"
        .Size = 16
        .Bold = False
        .Italic = False
        .AllCaps = False
        .Color = -738148353
    End With
    
    With ActiveDocument.Styles("Heading 2").Font
        .Name = "Segoe UI Semibold"
        .Size = 14
        .Bold = False
        .Italic = False
        .AllCaps = False
        .Color = -738148353
    End With
    
    With ActiveDocument.Styles("Heading 3").Font
        .Name = "Segoe UI Semibold"
        .Size = 12
        .Bold = False
        .Italic = False
        .AllCaps = False
        .Color = -738148353
    End With

    ' set H4 to be segoe UI at 11 point (just like Normal)
    With ActiveDocument.Styles("Heading 4").Font
        .Name = "Segoe UI"
        .Size = 11
        .Bold = False
        .Italic = False
        .Color = -587137025
    End With
    
    ' modify Heading 1
    With ActiveDocument.Styles("Heading 1").ParagraphFormat
        .LeftIndent = InchesToPoints(0)
        .RightIndent = InchesToPoints(0)
        .SpaceBefore = 6 ' this adds 6pt space
        .WidowControl = True
        .KeepWithNext = False ' keep with next causes some undesirable page breaks
        .KeepTogether = True
    End With
    ActiveDocument.Styles("Heading 1").NoSpaceBetweenParagraphsOfSameStyle = False

    ' modify H2s
    With ActiveDocument.Styles("Heading 2").ParagraphFormat
        .LeftIndent = InchesToPoints(0)
        .RightIndent = InchesToPoints(0)
        .SpaceBefore = 6 ' this adds 6pt space
        .SpaceBeforeAuto = False
        .SpaceAfter = 0
        .SpaceAfterAuto = False
        .WidowControl = True
        .KeepWithNext = False ' keep with next causes some undesirable page breaks
        .KeepTogether = True
    End With
    ActiveDocument.Styles("Heading 2").NoSpaceBetweenParagraphsOfSameStyle = False
    
    ' modify H3s
    With ActiveDocument.Styles("Heading 3").ParagraphFormat
        .LeftIndent = InchesToPoints(0)
        .RightIndent = InchesToPoints(0)
        .SpaceBefore = 6 ' this adds 6pt space
        .SpaceBeforeAuto = False
        .SpaceAfter = 0
        .SpaceAfterAuto = False
        .WidowControl = True
        .KeepWithNext = False ' keep with next causes some undesirable page breaks
        .KeepTogether = True
    End With
    ActiveDocument.Styles("Heading 3").NoSpaceBetweenParagraphsOfSameStyle = False
    
    ' modify H4s
    With ActiveDocument.Styles("Heading 4").ParagraphFormat
        .WidowControl = True
        .KeepWithNext = False ' keep with next causes some undesirable page breaks
        .KeepTogether = True
    End With
    


End Sub

' there are at least three ways to see if a range or selection is inside a table
Private Sub Detect_If_Inside_Table()
    For Each Paragraph In ActiveDocument.Paragraphs
        If Paragraph.Range.Information(wdWithInTable) Then
            Debug.Print "method 1"
        End If
        If Paragraph.Range.Tables.Count > 0 Then
            Debug.Print "method 2"
        End If
        Paragraph.Range.Select
        If Selection.Information(wdWithInTable) Then
            Debug.Print "method 3"
        End If
    Next
End Sub

' --------------------------------------------------------------------------
' go through each table and remove empty paragraphs
' also check for errant space+para, somehow these are somewhat common
' --------------------------------------------------------------------------
Private Sub Remove_Empty_Paragraphs_From_Tables()
    Dim numberOfColumnsInCurrentTable As Integer
    Dim currentTableIndex As Integer
    Dim sText As String
    
    For Each Paragraph In ActiveDocument.Paragraphs
        If Paragraph.Range.Information(wdWithInTable) Then
            Paragraph.Range.Select
            sText = Paragraph.Range.Text
            
            ' delete orphan paragraph marks in table cell
            If Len(Paragraph.Range.Text) = 1 Then   'If the length of the paragraph is 1 character
                If Paragraph.Range.Text = vbCr Then
                    Debug.Print "Deleting orphaned para mark in table cell."
                    Update_Change_Log (Paragraph.Range.Text)
                    Paragraph.Range.Delete
                End If
            End If
            
            ' delete orphan para mark with leading space
            If Len(Paragraph.Range.Text) = 2 Then
                If Paragraph.Range.Text = " " + vbCr Then
                    Debug.Print "Deleting orphaned space + para mark in table cell."
                    Update_Change_Log (Paragraph.Range.Text)
                    Paragraph.Range.Delete
                End If
            End If
            
'            If Len(Paragraph.Range.Text) = 2 And _
'                Left(Paragraph.Range.Text, 1) = " " And _
'                Left(Paragraph.Range.Text, 2) = "" Then  'If the paragraph is just a space
'                Debug.Print "that"
'                'oPar.Range.Delete
'            End If
'            currentTableIndex = ActiveDocument.Range(0, Selection.Tables(1).Range.End).Tables.Count
'            NumberOfColumns = ActiveDocument.Tables(currentTableIndex).Columns.Count
            'Debug.Print CStr(currentTableIndex) + " " + CStr(NumberOfColumns)
        End If
    Next
End Sub


' --------------------------------------------------------------------------
' loop all paragraphs and delete vertical tabs is text length = 2
' --------------------------------------------------------------------------
Private Sub Delete_Orphaned_Vertical_Tabs()

    For Each Paragraph In ActiveDocument.Paragraphs
        Paragraph.Range.Select
        If InStr(Paragraph.Range.Text, vbVerticalTab) Then
            ' vertical tabs are a line feed + para combo
            ' only delete if length of the text is 2.
            If Len(Paragraph.Range.Text) = 2 Then
                Debug.Print "orphaned vertical tab"
                Update_Change_Log (Paragraph.Range.Text)
                Paragraph.Range.Delete
            End If
        End If
    Next

End Sub

' --------------------------------------------------------------------------
' loop all paragraphs and report what type of carriage return is present
' --------------------------------------------------------------------------
Private Sub List_Each_Paragraph_Type()

    For Each Paragraph In ActiveDocument.Paragraphs
        Paragraph.Range.Select
        'If InStr(Paragraph.Range.Text, vbCr) Then
        '    Debug.Print "vbCr    Chr(13) Carriage return character"
        If InStr(Paragraph.Range.Text, vbLf) Then
            Debug.Print "vbLf    Chr(10) Linefeed character"
        ElseIf InStr(Paragraph.Range.Text, vbCrLf) Then
            Debug.Print "vbCrLf  Chr(13) + Chr(10)   Carriage return - linefeed combination"
        ElseIf InStr(Paragraph.Range.Text, vbNewLine) Then
            Debug.Print "vbNewLine   Chr(13) + Chr(10)   New line character"
        ElseIf InStr(Paragraph.Range.Text, vbNullChar) Then
            Debug.Print "vbNullChar  Chr(0)  Character having a value of 0."
        'ElseIf InStr(Paragraph.Range.Text, vbNullString) Then
        '    Debug.Print "vbNullString    String having value 0   Not the same as a zero-length string (""); used for calling external procedures."
        ElseIf InStr(Paragraph.Range.Text, vbTab) Then
            Debug.Print "vbTab   Chr(9)  Tab character"
        ElseIf InStr(Paragraph.Range.Text, vbBack) Then
            Debug.Print "vbBack  Chr(8)  Backspace character"
        ElseIf InStr(Paragraph.Range.Text, vbFormFeed) Then
            Debug.Print "vbFormFeed  Chr(12) Word VBA Manual - manual page break ?"
        ElseIf InStr(Paragraph.Range.Text, vbVerticalTab) Then
            ' vertical tabs are a line feed + para combo
            ' before deleting these, check if the length of the text is greater than 2.
            If Len(Paragraph.Range.Text) = 2 Then
                Debug.Print "orphaned vertical tab"
                Update_Change_Log (Paragraph.Range.Text)
                Paragraph.Range.Delete
            End If
            'Debug.Print "vbVerticalTab   Chr(11) Word VBA Manual - manual line break (Shift + Enter)"
        End If
    Next

End Sub

' --------------------------------------------------------------------------
' stylize the text in the first row of a table, e.g. bold
' --------------------------------------------------------------------------
Private Sub Stylize_Table_Headers()

    Dim all_tables As Tables
    Set all_tables = ActiveDocument.Tables
    
    For Each this_table In all_tables
        For Each this_cell In this_table.Rows(1).Cells
            this_cell.Select
            Selection.Font.Name = "Segoe UI Semibold"
            Selection.Font.Bold = False
        Next
    Next

End Sub
