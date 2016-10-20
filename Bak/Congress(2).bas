/' +---------------------------------------------------+
   |                    Congress Game                  |
   |               Written by Nick Lauber              |
   | This game is written as a simulation of Congress. |
   |     Code licensced under the GNU GPL License      |
   +---------------------------------------------------+
   |                    Main Game Code                 |
   +---------------------------------------------------+'/

' Include Header & FB_GUI Files
#Include Once "Congress.bi"
#Include Once "FB_GUI.BI"
#Include Once "FB_GUI_LIB.Bas"
#Include Once "issuetext.bas"

' Intitialize Variables & Subs
Declare Sub MainGameLoop()
Declare Sub NewGameScreen()
Dim Shared As Integer DateMonth,DateYear,Party,House,ElecYear
Dim Shared As String SDateMonth,SDateYear,RName,SParty,SHouse,State,About(0 To 2)
Dim Shared As Byte Quit
Dim Shared As Byte Chk_Flg
Dim Shared As Integer key

'											Title Screen Stuff
'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

' Initialize Title Screen
'---------------------------------------------------------------------------------
Screen 18
Screen_Width  = 640 ' Initialize Screen Mode
Screen_Height = 480
SetVideo("Congress Game v" & __Congress_Version__)
SetFonts
PopUp_Fade = TRUE ' Fade in Popup Windows
Cls

' Load Buttons and Other Controls
BLoad "title.bmp"
Window
Num_Ctrl_Total = 0
Mssg_Box("Welcome to The Houses of Congress!","Welcome!")

' Creation of Controls and Actions from them
'---------------------------------------------------------------------------------
' Create Command Buttons
Dim As Integer NumButtons
Dim As Integer b_x1 = 274, b_y1 = 350
Dim As Integer First_Button = Num_Ctrl_Total
NumButtons = 4
For i As Integer = Num_Ctrl_Total To Num_Ctrl_Total + (NumButtons-1)\2-1      'auto-index for two columns of
	With B[First_Button]
		.Ctrl_type = Ctrl_Button
		.state = Ctrl_Status_Enabled
		.x1 = b_x1
		.y1 = b_y1 + 30
		.x2 = .x1 + 95
		.y2 = .y1 + 20
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.LabelFont = ButtonFont
		.Label_FontSize=ButtonFont_size
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
	With B[First_Button + 1]
		.Ctrl_type = Ctrl_Button
		.state = Ctrl_Status_Enabled
		.x1 = b_x1
		.y1 = b_y1 + 60
		.x2 = .x1 + 95
		.y2 = .y1 + 20
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.LabelFont = ButtonFont
		.Label_FontSize=ButtonFont_size
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
Next i

' Define Button Labels and Colors
B[First_Button + 0].label = "Start New Game"
B[First_Button + 0].color = RGB(200,200,200)
B[First_Button + 1].label = "Quit"
B[First_Button + 1].color = RGB(200,200,200)
Font.FontIndex = MyFont.Button_Indx
For i As Integer = First_Button To First_Button + NumButtons-1
	If Len(B[i].label) > 0 Then   'skip blanks or getTextWidth crashes
		B[i].Label_Len = Font.StringWidth(B[i].Label)
	End If
Next i

' ListBox Pop-up Window
Enable_Controls()							' Pop-up Windows with listbox controls

' Reset to "nothing active/GotFocus
Active_Ctrl.Indx = -1   'reset to null Ctrl
Active_Ctrl.Ctrl_Type = Ctrl_Null
Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
ClearEvents

' Start of Main Loop
'---------------------------------------------------------------------------------
' Poll for keyboard / mouse events, and launch routines
Do
	Select Case PollEvent()        'poll for mouse and keyboard events
		Case Poll_Null
		Case Poll_CmdButton_Press
		Case Poll_CmdButton_Release
			Serve_CmdButton
		Case Poll_TxtBox_Press
			Serve_TxtBox
		Case Poll_TxtBox_Release
		Case Poll_CheckBox_Press
			Serve_CheckBox
		Case Poll_CheckBox_Release
		Case Poll_Key_Press
			Serve_KeyPress Active_Ctrl.key
		Case Poll_Window_Close
			If QUERY("Do you really want to exit?") Then End
		Case Else
			Mssg_Box("Poll Event not programed ", "ERROR")
	End Select
Loop

'											New Game Screen Stuff
'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Sub NewGameScreen()
	' New Game Screen Initialization Code
	'------------------------------------------------------------------------------
	Cls
	BLoad "back.bmp"
	Window
	Num_Ctrl_Total = 0
	Num_PopUP_Total = 0

	' Create Button, CheckBoxes, & TextBoxes
	'------------------------------------------------------------------------------
	Dim As Integer NumButtons
	Dim As Integer First_Button = Num_Ctrl_Total
	NumButtons = 1
	With B[First_Button]                                   'Cmd_Buttons
		.Ctrl_type = Ctrl_Button
		.State = Ctrl_Status_Enabled
		.x1 = 272
		.y1 = 450
		.x2 = 367
		.y2 = 470
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.LabelFont = ButtonFont
		.Label_FontSize = ButtonFont_size
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
	B[First_Button + 0].label = "Start"
	B[First_Button + 0].color = RGB(200,200,200)
	Font.FontIndex = MyFont.Button_Indx
	For i As Integer = First_Button To First_Button + NumButtons-1
		If Len(B[i].label) > 0 Then   'skip blanks or getTextWidth crashes
			B[i].Label_Len = Font.StringWidth(B[i].Label)
		End If
	Next i

	Enable_Controls()							' Draw controls

	With B[Num_Ctrl_total]
		.Ctrl_Type = Ctrl_TxtBox
		.state = Ctrl_Status_Enabled
		.x1 = 10
		.y1 = 10
		.x2 = 262
		.y2 = 30
		.x_offset = 0
		.y_offset = 0
		.label = "Name: "
		'.Label_len = -1     'suppress label printing
		.Label_FontSize = Font.TextHeight
		.V_Scroll_Enable = FALSE
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
	With B[Num_Ctrl_total]
		.Ctrl_Type = Ctrl_TxtBox
		.state = Ctrl_Status_Enabled
		.x1 = 10
		.y1 = 35
		.x2 = 262
		.y2 = 55
		.x_offset = 0
		.y_offset = 0
		.label = "State: "
		'.Label_len = -1     'suppress label printing
		.Label_FontSize = Font.TextHeight
		.V_Scroll_Enable = FALSE
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1

	Font.FontIndex = MyFont.TxtBox_Indx
	With B[Num_Ctrl_Total]
		.Ctrl_type = Ctrl_CheckBox
		.state = Ctrl_Status_Enabled
		.x1 = 400
		.y1 = 10
		.x2 = 622
		.y2 = 30
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.Color = RGB(200,200,200)
		.CheckState = True     'default, checked
		.Label = "Check for Democratic Party"
		.TxtStr = "R"          'right justified
		.LabelFont = ButtonFont
		'.Label_Len = gfx.font.getTextWidth(.LabelFont, .label)
		.Label_Len = Font.StringWidth(.Label)
		.Label_FontSize = Font.TextHeight
		.V_Scroll_Enable = FALSE                'no vertical Scroll Bars
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1

	Font.FontIndex = MyFont.TxtBox_Indx
	With B[Num_Ctrl_Total]
		.Ctrl_type = Ctrl_CheckBox
		.state = Ctrl_Status_Enabled
		.x1 = 400
		.y1 = 35
		.x2 = 622
		.y2 = 55
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.Color = RGB(200,200,200)
		.CheckState = True     'default, checked
		.Label = "Check for House of Representatives"
		.TxtStr = "R"          'right justified
		.LabelFont = ButtonFont
		'.Label_Len = gfx.font.getTextWidth(.LabelFont, .label)
		.Label_Len = Font.StringWidth(.Label)
		.Label_FontSize = Font.TextHeight
		.V_Scroll_Enable = FALSE                'no vertical Scroll Bars
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1

	Enable_Controls()							' Draw controls

	' Reset to "nothing active/GotFocus
	Active_Ctrl.Indx = -1   'reset to null Ctrl
	Active_Ctrl.Ctrl_Type = Ctrl_Null
	Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
	Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
	ClearEvents

	' Start of Main Loop
	'---------------------------------------------------------------------------------
	' Poll for keyboard / mouse events, and launch routines
	Do
		Select Case PollEvent()        'poll for mouse and keyboard events
			Case Poll_Null
			Case Poll_CmdButton_Press
			Case Poll_CmdButton_Release
				Serve_CmdButton
			Case Poll_TxtBox_Press
				Serve_TxtBox
			Case Poll_TxtBox_Release
			Case Poll_CheckBox_Press
				Serve_CheckBox
			Case Poll_CheckBox_Release
			Case Poll_Key_Press
				Serve_KeyPress Active_Ctrl.key
			Case Poll_Window_Close
				If QUERY("Do you really want to exit?") Then End
			Case Else
				Mssg_Box("Poll Event not programed ", "ERROR")
		End Select
	Loop
End Sub
'											Game Screen Stuff
'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Sub MainGameLoop()
	' Game Screen Initialization Code
	'------------------------------------------------------------------------------
	Num_Ctrl_Total = 0
	Num_PopUP_Total = 0
	reelection = 0
	#Include Once "randomize.bas"
	' Convert Integers into Strings and Make all names the same length
	If Party = 0 Then Sparty = "Democratic Party"
	If Party = 1 Then SParty = "Republican Party"
	If House = 0 Then SHouse = "House of Representatives"
	If House = 1 Then SHouse = "Senate"
	SDateMonth = WStr(DateMonth)
	SDateYear = WStr(DateYear)
	SScore = WStr(Score)

	' Print satus text to top and bottom margins
	Locate 1,1
	Print "Name: " + RName
	Locate 2,1
	Print "Party: " + SParty
	Locate 2,26
	Print "House: " + SHouse
	Locate 3,1
	Print "Home State: " + State
	Locate 31,2
	Print "Score: "+ SScore
	Locate 31,65
	Print "Date: " + SDateMonth + "-" + SDateYear

	' Creation of Controls and Actions from them
	'------------------------------------------------------------------------------
	' Create Command Buttons
	Dim As Integer NumButtons
	Dim As Integer b_x1 = 15, b_y1 = 450
	Dim As Integer First_Button = Num_Ctrl_Total
	NumButtons = 5
	With B[First_Button]                                   'Cmd_Buttons
		.Ctrl_type = Ctrl_Button
		.State = Ctrl_Status_Enabled
		.x1 = b_x1
		.y1 = b_y1
		.x2 = .x1 + 95
		.y2 = .y1 + 20
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.LabelFont = ButtonFont
		.Label_FontSize = ButtonFont_size
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
	With B[First_Button + 1]
		.Ctrl_type = Ctrl_Button
		.state = Ctrl_Status_Enabled
		.x1 = b_x1 + 400
		.y1 = b_y1
		.x2 = .x1 + 95
		.y2 = .y1 + 20
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.LabelFont = ButtonFont
		.Label_FontSize=ButtonFont_size
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
	With B[First_Button + 2]
		.Ctrl_type = Ctrl_Button
		.state = Ctrl_Status_Enabled
		.x1 = b_x1 + 515
		.y1 = b_y1
		.x2 = .x1 + 95
		.y2 = .y1 + 20
		.x_offset = 0       'no offsets for controls on Main Form
		.y_offset = 0
		.LabelFont = ButtonFont
		.Label_FontSize=ButtonFont_size
	End With
	Num_Ctrl_Total = Num_Ctrl_Total + 1
	' Define Button Labels and Colors
	B[First_Button + 0].label = "Next Issue"
	B[First_Button + 0].color = RGB(200,200,200)
	B[First_Button + 1].label = "About"
	B[First_Button + 1].color = RGB(200,200,200)
	B[First_Button + 2].label = "Quit"
	B[First_Button + 2].color = RGB(200,200,200)
	Font.FontIndex = MyFont.Button_Indx
	For i As Integer = First_Button To First_Button + NumButtons-1
		If Len(B[i].label) > 0 Then   'skip blanks or getTextWidth crashes
			B[i].Label_Len = Font.StringWidth(B[i].Label)
		End If
	Next i
	Enable_Controls()							' Pop-up Windows with listbox controls

	' Reset to "nothing active/GotFocus
	Active_Ctrl.Indx = -1   'reset to null Ctrl
	Active_Ctrl.Ctrl_Type = Ctrl_Null
	Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
	Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
	ClearEvents

	' Start of Main Loop
	'---------------------------------------------------------------------------------
	' Poll for keyboard / mouse events, and launch routines
	Do
		Select Case PollEvent()        'poll for mouse and keyboard events
			Case Poll_Null
			Case Poll_CmdButton_Press
			Case Poll_CmdButton_Release
				Serve_CmdButton
			Case Poll_TxtBox_Press
				Serve_TxtBox
			Case Poll_TxtBox_Release
			Case Poll_CheckBox_Press
				Serve_CheckBox
			Case Poll_CheckBox_Release
			Case Poll_Key_Press
				Serve_KeyPress Active_Ctrl.key
			Case Poll_Window_Close
			Case Else
		End Select
	Loop
End Sub

' Start of Server Subs
'---------------------------------------------------------------------------------
' CheckBox Server
Sub Serve_CheckBox()
	Select Case B[Active_Ctrl.Indx].label
		Case "Check for Democratic Party"
			If B[Active_Ctrl.Indx].CheckState = TRUE Then
				Party = 0
			Else
				Party = 1
			End If
		Case "Check for House of Representatives"
			If B[Active_Ctrl.Indx].CheckState = TRUE Then
				House = 0
			Else
				House = 1
			End If
		Case Else
	End Select
End Sub
' Command Button Server
Sub Serve_CmdButton()
	Select Case B[Active_Ctrl.Indx].label
		'Cmd_Buttons on Main Form
		Case "Start New Game"
			NewGameScreen()
		Case "Quit"
			If QUERY("Do you really want to exit?") Then End
		Case "About"
			About(0) = "Congress Game was compiled with " + __FB_SIGNATURE__ + ", built on "
			About(1) =  __FB_BUILD_DATE__ + ", and uses FB_GUI version " + FB_GUI_Version_ + ", built on " + FB_GUI_Date_ + "."
			About(2) = "The Houses of Congress was built on " + __BUILD_Date__  + "."
			Mssg_Box(About(),"Congress Game")
		Case "Start"
			total_issues = 0
			ElecYear = 0
			Score=0
			DateMonth=1
			DateYear=2011
			Cls
			BLoad "back.bmp"
			Window
			MainGameLoop()
		Case "Next Issue"
			If QUERY(issue_chosen) Then
				Vote(issuen) = 1
			Else
				Vote(issuen) = 0
			End If
			If Vote(issuen) = 1 Then Mssg_Box("You voted for the issue.","Vote Results")
			If Vote(issuen) = 0 Then Mssg_Box("You voted against the issue.","Vote Results")
			If Vote(issuen) <= People_Vote Then reelection = 1
			DateMonth = DateMonth + 6
			If DateMonth = 13 Then DateMonth = DateMonth + 1
			If DateMonth = 14 Then DateYear = DateYear + 1 : DateMonth = 1 : ElecYear = ElecYear + 1
			If House = 0 And ElecYear = 2 And DateMonth = 1 And reelection = 1 Then
				Mssg_Box("You have been reelected!","Reelection!")
				Score = Score + 10
				ElecYear = 1
			End If
			If House = 1 And ElecYear = 6 And DateMonth = 1 And reelection = 1 Then
				Mssg_Box("You have been reelected!","Reelection!")
				Score = Score + 30
				ElecYear = 1
			End If
			If House = 0 And ElecYear = 2 And DateMonth = 1 And reelection = 0 Then
				Mssg_Box("You have not be reelected!","Try Again!")
				NewGameScreen()
			End If
			If House = 1 And ElecYear = 6 And DateMonth = 1 And reelection = 0 Then
				Mssg_Box("You have not be reelected!","Try Again!")
				NewGameScreen()
			End If
			If DateYear = 2022  And House = 0 Then
				Mssg_Box("You have won the game with a score of " + SScore + "!","Congratulations!")
				NewGameScreen()
			End If
			#Include Once "randomize.bas"
			MainGameLoop()
		Case Else
	End Select
	Active_Ctrl.Indx = -1   ' reset to null Ctrl
	Active_Ctrl.Ctrl_Type = Ctrl_Null
	ClearEvents
End Sub

' Typebox Server
Sub Serve_TxtBox()
	With B[Active_Ctrl.Indx]
		Select Case .label
			Case "Name: "
				RName = .TxtStr
			Case "State: "
				State = .TxtStr
			Case Else
		End Select
		ClearEvents
	End With
Do Until InKey = "": Loop   'clear Keybd buffer
End Sub

' Key Press Server
Sub Serve_KeyPress (ByVal Key As Integer)
Do Until InKey = "": Loop   ' clear keyboard buffer
Select Case key
	Case FB.SC_Q
		If QUERY("Do you really want to exit?") Then End
	Case FB.SC_ESCAPE
		If QUERY("Do you really want to exit?") Then End
	Case FB.SC_A
		About(0) = "Congress Game was compiled with " + __FB_SIGNATURE__ + ", built on "
		About(1) =  __FB_BUILD_DATE__ + ", and uses FB_GUI version " + FB_GUI_Version_ + ", built on " + FB_GUI_Date_ + "."
		About(2) = "The Houses of Congress was built on " + __BUILD_Date__  + "."
		Mssg_Box(About(),"Congress Game")
	Case Else
End Select
ClearEvents
End Sub
