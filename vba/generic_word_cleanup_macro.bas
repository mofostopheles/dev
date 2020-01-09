' --------------------------------------------------------------------------
' Author: Arlo Emerson arloemerson@gmail.com
' --------------------------------------------------------------------------

' --------------------------------------------------------------------------
' Globals
' --------------------------------------------------------------------------

' Every time we delete a range, add the range to this string.
' We will check it for accidentally deleted text later.
Public changeLog As String

' --------------------------------------------------------------------------
' Document cleanup examples.
' --------------------------------------------------------------------------
Public Sub Main()

    changeLog = ""
    ConvertTargetLimitsIntoTable
    RemoveEmptyTables
    CombineParaWithHeading4
    AddHeader
    RemoveEmptyParagraphs
    DeleteOrphanedVerticalTabs
    RemoveEmptyParagraphsFromTables
    ModifyStyles
    StylizeTableHeaders

    Dim statusString As String
    statusString = "Processing complete. "
    If Len(changeLog) > 0 Then
        statusString = statusString + "Oops. I deleted the following text: '" + Trim(changeLog) + "'"
    End If

    MsgBox (statusString)

End Sub

' --------------------------------------------------------------------------
' Call this with the paragraph range you are about to delete
' --------------------------------------------------------------------------
Public Sub UpdateChangeLog(arg As String)

    If IsAlphaNumeric(arg) Then
        changeLog = changeLog + arg
    End If

End Sub

' --------------------------------------------------------------------------
' Return true if string arg is alpha numeric
' --------------------------------------------------------------------------
Function IsAlphaNumeric(arg As String) As Boolean

    Dim upperCaseString As String
    'Convert the character to Uppercase so that there is no need to do a check for Lower and Uppercase separately.
    upperCaseString = UCase(arg)
    IsAlphaNumeric = (Asc(upperCaseString) > 64 And Asc(upperCaseString) < 91) Or (VBA.IsNumeric(upperCaseString))

End Function

' --------------------------------------------------------------------------
' Just a method for doing whatever.
' --------------------------------------------------------------------------
Public Sub UseForTesting()

    RemoveEmptyParagraphs
    ModifyStyles

End Sub

' --------------------------------------------------------------------------
' Converts the X0 paragraphs into a 3-col table.
' --------------------------------------------------------------------------
Public Sub ConvertTargetLimitsIntoTable()

    Dim i As Long

    For i = ActiveDocument.Paragraphs.Count To 1 Step -1
         If ActiveDocument.Paragraphs(i).Range.Style = "Normal" Then
            If ActiveDocument.Paragraphs(i).Range.Words(1).Text = "X1" Then
                If ActiveDocument.Paragraphs(i).Range.Words(2).Text = ": " Then
                    If ActiveDocument.Paragraphs(i).Previous.Range.Words(1).Text = "X2" Then
                        If ActiveDocument.Paragraphs(i).Previous.Previous.Range.Words(1).Text = "X0" Then

                            Dim totalCharLength As Integer
                            Dim rightTrimIndex As Integer
                            Dim firstWordLength As Integer
                            Dim secondWordLength As Integer
                            Dim word1 As String
                            Dim word2 As String
                            Dim word3 As String

                            word1 = ActiveDocument.Paragraphs(i).Previous.Previous.Range.Text '"X0"
                            firstWordLength = Len(ActiveDocument.Paragraphs(i).Previous.Previous.Range.Words(1).Text)
                            secondWordLength = Len(ActiveDocument.Paragraphs(i).Previous.Previous.Range.Words(2).Text)
                            totalCharLength = firstWordLength + secondWordLength
                            rightTrimIndex = Len(word1) - totalCharLength
                            word1 = RTrim(Right(word1, rightTrimIndex))    ' store the text and trim the paragraph mark and whitespace off the right

                            word2 = ActiveDocument.Paragraphs(i).Previous.Range.Text '"X2"
                            firstWordLength = Len(ActiveDocument.Paragraphs(i).Previous.Range.Words(1).Text)
                            secondWordLength = Len(ActiveDocument.Paragraphs(i).Previous.Range.Words(2).Text)
                            totalCharLength = firstWordLength + secondWordLength
                            rightTrimIndex = Len(word2) - totalCharLength
                            word2 = RTrim(Right(word2, rightTrimIndex))    ' store the text and trim the paragraph mark and whitespace off the right

                            word3 = ActiveDocument.Paragraphs(i).Range.Text '"X1"
                            firstWordLength = Len(ActiveDocument.Paragraphs(i).Range.Words(1).Text)
                            secondWordLength = Len(ActiveDocument.Paragraphs(i).Range.Words(2).Text)
                            totalCharLength = firstWordLength + secondWordLength
                            rightTrimIndex = Len(word3) - totalCharLength
                            word3 = Right(word3, rightTrimIndex)

                            ActiveDocument.Paragraphs(i).Range.Select

                            With Selection
                                .MoveEnd Unit:=wdCharacter, Count:=-1
                                '.Style = ActiveDocument.Styles("Normal")
                            End With

                            Set newTable = ActiveDocument.Tables.Add(Selection.Range, 2, 3)
                            With newTable
                                .Cell(1, 1).Range.InsertAfter "X0"
                                .Cell(1, 2).Range.InsertAfter "X2"
                                .Cell(1, 3).Range.InsertAfter "X1"
                                .Cell(2, 1).Range.InsertAfter word1
                                .Cell(2, 2).Range.InsertAfter word2
                                .Cell(2, 3).Range.InsertAfter word3
                                .Cell(2, 3).Range.Style = ActiveDocument.Styles("Normal")

                                .Cell(2, 1).Range.Select
                                With Selection.Find
                                    .Text = Chr$(13)
                                    .Replacement.Text = ""
                                End With
                                Selection.Find.Execute Replace:=wdReplaceAll

                                .Cell(2, 2).Range.Select
                                With Selection.Find
                                    .Text = Chr$(13)
                                    .Replacement.Text = ""
                                End With
                                Selection.Find.Execute Replace:=wdReplaceAll

                                .Cell(2, 3).Range.Select
                                With Selection.Find
                                    .Text = Chr$(13)
                                    .Replacement.Text = ""
                                End With
                                Selection.Find.Execute Replace:=wdReplaceAll

                                .Borders.InsideLineStyle = wdLineStyleSingle
                                .Borders.InsideColorIndex = wdGray25
                                .Borders.OutsideLineStyle = wdLineStyleSingle
                                .Borders.OutsideColorIndex = wdGray25
                                '.Columns.AutoFit
                            End With

                            newTable.AllowPageBreaks = False

                            ' Admittedly, this is scary. This is also VBA.
                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Select
                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Delete

                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Select
                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Delete

                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Select
                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Delete

                        End If
                    End If
                End If
            End If
         End If
    Next i

    DoEvents

End Sub

' --------------------------------------------------------------------------
' If empty or SOME STRING removes the 3-column tables containing X0 limits.
' --------------------------------------------------------------------------
Public Sub RemoveEmptyTables()

    Dim allTables As Tables
    Set allTables = ActiveDocument.Tables
    Dim found As Integer

    For Each Table In allTables
        found = 0
        For Each Cell In Table.Rows(2).Cells
            Cell.Select

            With Selection.Find
                .Text = "SOME STRING"
            End With
            Dim result As Boolean

            result = Selection.Find.Execute
            If result Then
                found = found + 1
            End If
        Next

        If found = 3 Then
            Table.Delete
        End If
    Next

    Set allTables = ActiveDocument.Tables
    For Each Table In allTables
        found = 0

        'filter on the correct table
        If InStr(1, Table.Rows(1).Cells(1).Range.Text, "X0") = 1 Then
            For Each Cell In Table.Rows(2).Cells
                Set cellRange = Cell.Range
                cellRange.End = cellRange.End - 1
                If Len(cellRange.Text) = 0 Then
                    found = found + 1
                End If

                If testString = Chr(7) Then
                    found = found + 1
                End If
            Next

            If found = 3 Then
                Table.Delete
            End If

        End If
    Next

End Sub


' --------------------------------------------------------------------------
' Converts the three paragraphs with specified text into one line.
' NOTE: this is a spike and not used in current processor.
' Saving for reference.
' --------------------------------------------------------------------------
Public Sub ConvertTargetLimitsIntoOneLine()

    Dim i As Long
    Dim underscore As String
    underscore = "_______"

    For i = ActiveDocument.Paragraphs.Count To 1 Step -1
        If ActiveDocument.Paragraphs(i).Range.Text = "X1: " + Chr$(13) Then
            ActiveDocument.Paragraphs(i).Range.Select
            With Selection.Find
                .Style = ActiveDocument.Styles("Normal")
                .Text = "X1:"
                .Replacement.Text = "X1: " + underscore
            End With
            Selection.Find.Execute Replace:=wdReplaceAll
        End If

        If ActiveDocument.Paragraphs(i).Range.Text = "X2: " + Chr$(13) Then
            ActiveDocument.Paragraphs(i).Range.Select
            With Selection.Find
                .Style = ActiveDocument.Styles("Normal")
                .Text = "X2:"
                .Replacement.Text = "X2: " + underscore
            End With
            Selection.Find.Execute Replace:=wdReplaceAll
        End If

        If ActiveDocument.Paragraphs(i).Range.Text = "X0: " + Chr$(13) Then
            ActiveDocument.Paragraphs(i).Range.Select
            With Selection.Find
                .Style = ActiveDocument.Styles("Normal")
                .Text = "X0:"
                .Replacement.Text = "X0: " + underscore
            End With
            Selection.Find.Execute Replace:=wdReplaceAll
        End If
    Next i

    For i = ActiveDocument.Paragraphs.Count To 1 Step -1
         If ActiveDocument.Paragraphs(i).Range.Style = "Normal" Then
            If ActiveDocument.Paragraphs(i).Range.Words(1).Text = "X1" Then
                If ActiveDocument.Paragraphs(i).Range.Words(2).Text = ": " Then
                    If ActiveDocument.Paragraphs(i).Previous.Range.Words(1).Text = "X2" Then
                        If ActiveDocument.Paragraphs(i).Previous.Previous.Range.Words(1).Text = "X0" Then

                            Dim word1 As String
                            word1 = ActiveDocument.Paragraphs(i).Previous.Previous.Range.Text '"X0"
                            word1 = RTrim(Left(word1, Len(word1) - 1)) ' store the text and trim the paragraph mark and whitespace off the right

                            Dim word2 As String
                            word2 = ActiveDocument.Paragraphs(i).Previous.Range.Text '"X2"
                            word2 = RTrim(Left(word2, Len(word2) - 1))

                            Dim word3 As String
                            word3 = ActiveDocument.Paragraphs(i).Range.Text '"X1"
                            'word3 = RTrim(Left(word3, Len(word3) - 1)) ' don't trim because we need that para mark

                            ' TODO: use a stringbuilder
                            Dim concatWords As String
                            concatWords = word1 + " " + word2 + " " + word3

                            ActiveDocument.Paragraphs(i).Range.Text = concatWords
                            ActiveDocument.Paragraphs(i).Previous.Range.Delete
                            ActiveDocument.Paragraphs(i).Previous.Previous.Range.Delete
                            ActiveDocument.Paragraphs(i - 2).Range.Select
                            ActiveDocument.Paragraphs(i - 2).Range.Style = "Normal"

                        End If
                    End If
                End If
            End If
         End If
    Next i

    Dim j As Long
    For j = ActiveDocument.Paragraphs.Count To 1 Step -1
         If ActiveDocument.Paragraphs(j).Range.Style = "Normal" Then

            ' check if these are empty entries
            Dim checkString As String
            checkString = ActiveDocument.Paragraphs(j).Range.Text
            checkString = RTrim(Left(checkString, Len(checkString) - 1))

            If checkString = "X0: SOME STRING X2: SOME STRING X1: SOME STRING" Then
                ActiveDocument.Paragraphs(j).Range.Delete
            End If
         End If
    Next j

    DoEvents

End Sub

' --------------------------------------------------------------------------
' If heading 4 ends with a non breaking space,
' meaning that it says something like "R.7.1.1.3" with no other text,
' then check the following paragraph to see if it is styled Normal.
' If so, then combine that para with the H4
' NOTE: this macro will not modify an H4 that has nested non breaking space.
' --------------------------------------------------------------------------
Public Sub CombineParaWithHeading4()

    Dim paragraph As Word.paragraph
    Dim statusMessage As String
    statusMessage = "Merging H4s with their text"

    For Each paragraph In ActiveDocument.Paragraphs

         With paragraph.Range.Find ' within the paragraph search for a non-breaking space ie. Chr$(160)
            .Style = wdStyleHeading4
            .Text = Chr$(160)
            .Forward = True
            .Wrap = wdFindStop
            .Execute

            If .found Then
                paragraph.Range.Select

                ' this appears to be an extra test of heading 4 using the bracket notation
                If (paragraph.Format.Style Like "Heading [4]") Then

                    paraText = paragraph.Range.Text
                    paraText = RTrim(Left(Txt, Len(Txt) - 1)) ' store the text and trim the paragraph mark and whitespace off the right
                    If InStr(Chr$(160), Right(Txt, 1)) = 1 Then ' check if the rightmost character is indeed a non-breaking space
                        ' check if the following paragraph is styled as normal
                        If paragraph.Range.Paragraphs(1).Next.Range.Style = "Normal" Then
                                paragraph.Range.Characters.Last.Text = "" ' swap the paragraph mark with an empty string
                                paragraph.Range.Style = wdStyleHeading4 ' restyle as h4
                                StatusBar = statusMessage
                                DoEvents
                        End If
                    End If
                End If
            End If
        End With
    Next

End Sub

' --------------------------------------------------------------------------
' Remove empty paragraph after H3/H4 and before the following normal para.
' --------------------------------------------------------------------------
Public Sub RemoveEmptyParagraphAfterH4()

    Dim paragraph As Word.paragraph

    For Each paragraph In ActiveDocument.Paragraphs
        If (paragraph.Format.Style Like "Heading [3-4]") Then
            If paragraph.Range.Paragraphs(1).Next.Range.Style = "Normal" Then
                textSample = paragraph.Range.Paragraphs(1).Next.Range.Text
                textSample = RTrim(Left(textSample, Len(textSample) - 1))
                If InStr(Chr$(13), Right(textSample, 1)) = 1 Then
                    paragraph.Range.Select
                    paragraph.Range.Paragraphs(1).Next.Range.Characters.Last.Text = ""
                    'Paragraph.Range.Style = wdStyleHeading4
                End If
            End If
        End If
    Next

End Sub

' --------------------------------------------------------------------------
' Add the header legalese.
' --------------------------------------------------------------------------
Public Sub AddHeader()

    Dim headerText As String
    headerText = "HEADER TEXT"

    Dim statusMessage As String
    statusMessage = "Header has been updated with "

    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageHeader
    Selection.HomeKey Unit:=wdLine
    Selection.EndKey Unit:=wdLine, Extend:=wdExtend
    Selection.Style = ActiveDocument.Styles("Header")
    Selection.Font.Italic = True
    Selection.TypeText Text:=headerText
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument
    Debug.Print statusMessage + headerText
    StatusBar = statusMessage + headerText
    DoEvents

End Sub

' --------------------------------------------------------------------------
' Iterate all the paragraphs and remove if empty.
' --------------------------------------------------------------------------
Public Sub RemoveEmptyParagraphs()

    Dim paragraph As Word.paragraph
    Dim counter As Integer
    Dim statusMessage As String
    statusMessage = " empty paragraphs found and removed."

    For Each paragraph In ActiveDocument.Paragraphs
        If paragraph.Range.Style = "Normal" Then
            If paragraph.Range.Text = "" + Chr$(13) Then
                counter = counter + 1
                UpdateChangeLog (paragraph.Range.Text)
                paragraph.Range.Delete
                StatusBar = "Deleting empty paragraphs"
            End If
        End If
    Next
    Debug.Print CStr(counter) + statusMessage
    StatusBar = CStr(counter) + statusMessage
    DoEvents

End Sub


' --------------------------------------------------------------------------
' Iterate all the paragraphs and remove empty line feed paragraphs.
' NOTE: THIS FUNCTION MAY BE DEPRECATED BY DeleteOrphanedVerticalTabs().
' --------------------------------------------------------------------------
Public Sub RemoveEmptyLineFeedParagraphs()

    Dim paragraph As Word.paragraph
    Dim counter As Integer
    Dim statusMessage As String
    statusMessage = " line feeds and empty paragraphs found and removed."

    For Each paragraph In ActiveDocument.Paragraphs
        If paragraph.Range.Style = "Normal" Then
            paragraph.Range.Select

            ' note: none of the constants are working for detecting Linefeed character
            ' ie. vbLf, Chr(10), vbNewLine, so we are resorting to this...
            Dim lineBreak As String
            lineBreak = ""

            If InStr(paragraph.Range.Text, lineBreak) > 0 Then
                If paragraph.Range.Text = lineBreak + vbCr Then
                    counter = counter + 1
                    UpdateChangeLog (paragraph.Range.Text)
                    paragraph.Range.Delete
                    StatusBar = "Deleting line feeds with empty paragraphs."
                End If
            End If
        End If
    Next
    Debug.Print CStr(counter) + statusMessage
    StatusBar = CStr(counter) + statusMessage

End Sub


' --------------------------------------------------------------------------
' This is an example of how to iterate paragraphs and test for empty lines.
' NOTE: this function doesn't do anything, it's an example.
' --------------------------------------------------------------------------
Public Sub IterateParagraphs()
    Dim paragraph As Word.paragraph
    Dim counter As Integer
    Dim statusMessage As String
    statusMessage = " empty paragraphs found."

    For Each paragraph In ActiveDocument.Paragraphs
        If paragraph.Range.Style = "Normal" Then
            If paragraph.Range.Text = "" + Chr$(13) Then
                counter = counter + 1
            End If
        End If
    Next
    Debug.Print CStr(counter) + statusMessage
    DoEvents
End Sub

' --------------------------------------------------------------------------
' Example of looping lines and printing ascii char of each member.
' Useful for debugging.
' --------------------------------------------------------------------------
Private Sub AsciiPrint()

    Dim rangeText As String
    Dim activeDoc As Document
    Dim linesArray() As String
    Dim lineIndex As Long
    Set activeDoc = Application.ActiveDocument

    rangeText = activeDoc.Range.Text
    linesArray = Split(rangeText, vbCr)

    Dim lineChar As Long
    Dim byteArray() As Byte

    For lineIndex = 0 To UBound(linesArray)
        byteArray = StrConv(linesArray(lineIndex), vbFromUnicode)
        For lineChar = LBound(byteArray) To UBound(byteArray)
            Debug.Print Chr$(byteArray(lineChar))
        Next lineChar
    Next lineIndex

    Set activeDoc = Nothing

End Sub

' --------------------------------------------------------------------------
' We're mainly interested in making things readable by adding space before
' the H1s, H2s and H3s. Converts H4 font to be the same as Normal.
' --------------------------------------------------------------------------
Private Sub ModifyStyles()

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
        .KeepWithNext = True
        .KeepTogether = True
    End With
    ActiveDocument.Styles("Heading 3").NoSpaceBetweenParagraphsOfSameStyle = False

    ' modify H4s
    With ActiveDocument.Styles("Heading 4").ParagraphFormat
        .WidowControl = True
        .KeepWithNext = True
        .KeepTogether = True
    End With

End Sub

' --------------------------------------------------------------------------
' There are at least three ways to see if a range or selection is inside a table
' --------------------------------------------------------------------------
Private Sub DetectIfInsideTable()

    For Each paragraph In ActiveDocument.Paragraphs
        If paragraph.Range.Information(wdWithInTable) Then
            Debug.Print "method 1"
        End If
        If paragraph.Range.Tables.Count > 0 Then
            Debug.Print "method 2"
        End If
        paragraph.Range.Select
        If Selection.Information(wdWithInTable) Then
            Debug.Print "method 3"
        End If
    Next

End Sub

' --------------------------------------------------------------------------
' Go through each table and remove empty paragraphs.
' Also check for errant space+para, somehow these are somewhat common.
' --------------------------------------------------------------------------
Private Sub RemoveEmptyParagraphsFromTables()

    Dim numberOfColumnsInCurrentTable As Integer
    Dim currentTableIndex As Integer
    Dim rangeText As String

    For Each paragraph In ActiveDocument.Paragraphs
        If paragraph.Range.Information(wdWithInTable) Then
            paragraph.Range.Select
            rangeText = paragraph.Range.Text

            ' delete orphan paragraph marks in table cell
            If Len(paragraph.Range.Text) = 1 Then   'If the length of the paragraph is 1 character
                If paragraph.Range.Text = vbCr Then
                    Debug.Print "Deleting orphaned para mark in table cell."
                    UpdateChangeLog (paragraph.Range.Text)
                    paragraph.Range.Delete
                End If
            End If

            ' delete orphan para mark with leading space
            If Len(paragraph.Range.Text) = 2 Then
                If paragraph.Range.Text = " " + vbCr Then
                    Debug.Print "Deleting orphaned space + para mark in table cell."
                    UpdateChangeLog (paragraph.Range.Text)
                    paragraph.Range.Delete
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
' Loop all paragraphs and delete vertical tabs is text length = 2.
' --------------------------------------------------------------------------
Private Sub DeleteOrphanedVerticalTabs()

    For Each paragraph In ActiveDocument.Paragraphs
        paragraph.Range.Select
        If InStr(paragraph.Range.Text, vbVerticalTab) Then
            ' vertical tabs are a line feed + para combo
            ' only delete if length of the text is 2.
            If Len(paragraph.Range.Text) = 2 Then
                Debug.Print "orphaned vertical tab"
                UpdateChangeLog (paragraph.Range.Text)
                paragraph.Range.Delete
            End If
        End If
    Next

End Sub

' --------------------------------------------------------------------------
' Loop all paragraphs and report what type of carriage return is present.
' --------------------------------------------------------------------------
Private Sub ListEachParagraphType()

    For Each paragraph In ActiveDocument.Paragraphs
        paragraph.Range.Select
        'If InStr(Paragraph.Range.Text, vbCr) Then
        '    Debug.Print "vbCr    Chr(13) Carriage return character"
        If InStr(paragraph.Range.Text, vbLf) Then
            Debug.Print "vbLf    Chr(10) Linefeed character"
        ElseIf InStr(paragraph.Range.Text, vbCrLf) Then
            Debug.Print "vbCrLf  Chr(13) + Chr(10)   Carriage return - linefeed combination"
        ElseIf InStr(paragraph.Range.Text, vbNewLine) Then
            Debug.Print "vbNewLine   Chr(13) + Chr(10)   New line character"
        ElseIf InStr(paragraph.Range.Text, vbNullChar) Then
            Debug.Print "vbNullChar  Chr(0)  Character having a value of 0."
        'ElseIf InStr(Paragraph.Range.Text, vbNullString) Then
        '    Debug.Print "vbNullString    String having value 0   Not the same as a zero-length string (""); used for calling external procedures."
        ElseIf InStr(paragraph.Range.Text, vbTab) Then
            Debug.Print "vbTab   Chr(9)  Tab character"
        ElseIf InStr(paragraph.Range.Text, vbBack) Then
            Debug.Print "vbBack  Chr(8)  Backspace character"
        ElseIf InStr(paragraph.Range.Text, vbFormFeed) Then
            Debug.Print "vbFormFeed  Chr(12) Word VBA Manual - manual page break ?"
        ElseIf InStr(paragraph.Range.Text, vbVerticalTab) Then
            ' vertical tabs are a line feed + para combo
            ' before deleting these, check if the length of the text is greater than 2.
            If Len(paragraph.Range.Text) = 2 Then
                Debug.Print "orphaned vertical tab"
                UpdateChangeLog (paragraph.Range.Text)
                paragraph.Range.Delete
            End If
            'Debug.Print "vbVerticalTab   Chr(11) Word VBA Manual - manual line break (Shift + Enter)"
        End If
    Next

End Sub

' --------------------------------------------------------------------------
' Stylize the text in the first row of a table, e.g. bold.
' --------------------------------------------------------------------------
Private Sub StylizeTableHeaders()

    Dim allTables As Tables
    Set allTables = ActiveDocument.Tables

    For Each Table In allTables
        For Each Cell In Table.Rows(1).Cells
            Cell.Select
            Selection.Font.Name = "Segoe UI Semibold"
            Selection.Font.Bold = False
        Next
    Next

End Sub


