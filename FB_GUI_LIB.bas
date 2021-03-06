'------------------------------------------------------------------------
'|                                                                       |
'| FB_GUI_LIB.BAS                                                        |
'|                                                                       |
'| Series of routines written for GUI interface                          |
'|                                                                       |
'| Author:  Steve Cannon                                                 |
'| Version: 1.0.0                                                        |
'| Date:    April 2008                                                   |
'| Revised: September 2008                                               |
' -----------------------------------------------------------------------|

'
'  Axis delta
'
' Determines optimal increment for axis tics with preferred delta (1, 2, 5)
'
FUNCTION AxisDelta (byval x as single) as single
DIM as single scale, y
IF x = 0 then return 1              'default for illegal entry
scale = int(log(x/1.5)/log(10))      'Log10 of x/1.5
Select case x/(10^scale)
    case 1.5 to 3
        y = .2
    case 3 to 7.5
        y = .5
    case 7.5 to 15
        y = 1
    case else
        Box_print "need to debug " & x/(10^scale) & "x = " & x & " scale = " & scale
end select
    return y*10^scale
END FUNCTION
'
'Draw_Control Function
'
' Operates on the control designated by Active_Ctrl.Indx
'
'
FUNCTION Control.Draw_Control (byval CtrlPtr as any ptr) as integer
dim as uinteger white, Color_lt, Color_drk, black, FGnd_Color, Color_Inactive, Menu_Inactive
dim as integer delta, mask, x_label, y_label, r, g, b
dim as integer xl,xr,yu,yd      'temporary coordinates for object to be drawn
dim as integer i, LineCnt, Max_Line, First_Line, slen
dim as string TxtBoxLabel
Dim as integer Temp_ctrl_indx
Dim as byte H_Slider = TRUE     'default, slider is horizontal

Temp_Ctrl_Indx = Active_Ctrl.Indx   'temporary copy.  some procs (e.g. create_scroll) need to know B[index]
Active_Ctrl.Indx = Index

If Active_Ctrl.Indx < 0 then
    Mssg_Box ("Must set Active_Ctrl.Indx for control " & label, ".Draw_Control Error")
    Return 0
end if

white = rgb (255, 255, 255)
black = rgb (0,0,0)
r = Color Shr 16 AND 255
g = Color Shr 8 AND 255
b = color AND 255
FGnd_color = Color
Color_drk = rgb (r*.3,g*.3,b*.3)
Color_lt = rgb (r*.6,g*.6,b*.6)
Color_inactive = rgb (r*.85,g*.85,b*.85)
mask = &b1100110011001100
Delta = 1       'thickness for 3D effect in pixels

' Make sure x1, y1 is top left and x2, y2 is bottom right

Select Case Ctrl_Type
    Case Ctrl_ListBox
        if x2 < x1 then swap x1,x2
        IF y2 = 0 then y2 = y1 + ListBox_Hgt    'in case y2 not assigned, default
        if y2 < y1 then swap y1,y2
    Case Ctrl_Slider
        IF ABS(x2-x1) > abs(y2-y1)then
            H_Slider = True     'horizonatal
            if x2 < x1 then swap x1,x2
            if y2 <> y1 + SliderHeight then y2 = y1 + SliderHeight  'force slider height
            slen = x2-x1
        Else
            H_Slider = False    'vertical
            if y2 < y1 then swap y1,y2
            IF x2 <> x1 + SliderHeight then x2 = x1 + SliderHeight  'force slider height
            slen = y2-y1
        END if
    Case Else   'default
        if x2 < x1 then swap x1,x2
        if y2 < y1 then swap y1,y2
end select

' Offset variable are for controls on PopUp Form, which may be dragged/moved
xl = x1 + x_offset
xr = x2 + x_offset
yu = y1 + y_offset
yd = y2 + y_offset

' Center label for Buttons and Dropdown Menu
x_label = ((xl+xr)- Label_len)\2
y_label = (yu+yd-label_FontSize/1.6667)\2       'Windows standard of 1.667 points/pixel

If (State = Ctrl_Status_Hidden) then return -1

SELECT CASE Ctrl_Type

CASE Ctrl_Button
    font.fontindex = MyFont.Button_Indx
    font.forecolor = Color_ButtonTxt
    x_label = ((xl+xr-delta)- font.stringwidth(label))\2
    y_label = (yu+yd-delta -font.textheight)\2
    SELECT CASE State
    CASE Ctrl_Status_Disabled
        line CtrlPtr, (xl,yu)-(xr,yd),Color_drk,bf
        line CtrlPtr, (xl,yu)-(xr-delta,yd-delta),white,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-delta,yd-delta),Color_lt,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-2*delta,yd-2*delta),Color_Inactive,bf
        'draw string CtrlPtr, (x_label, y_label), label , , labelfont, alpha
        font.backcolor = Color_Inactive
        Font.DrawString ctrlptr, label, x_label, y_label
    CASE Ctrl_Status_Enabled
        line CtrlPtr, (xl,yu)-(xr,yd),Color_drk,bf
        line CtrlPtr, (xl,yu)-(xr-delta,yd-delta),white,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-delta,yd-delta),Color_lt,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-2*delta,yd-2*delta),FGnd_color,bf
        'draw string CtrlPtr, (x_label, y_label), label , , labelfont, alpha
        Font.backcolor = FGnd_Color
        Font.DrawString ctrlptr, label, x_label, y_label
        
    CASE Ctrl_Status_GotFocus
        line CtrlPtr, (xl,yu)-(xr,yd),black,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-delta,yd-delta),Color_drk,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-2*delta,yd-2*delta),white,bf
        line CtrlPtr, (xl+2*delta, yu+2*delta)-(xr-2*delta,yd-2*delta),Color_lt,bf
        line CtrlPtr, (xl+2*delta, yu+2*delta)-(xr-3*delta,yd-3*delta),FGnd_color,bf
        
        'draw string CtrlPtr, (x_label, y_label), label, , labelfont, alpha    
        font.backcolor = FGnd_Color
        Font.DrawString ctrlptr, label, x_label, y_label
        line CtrlPtr, (xl+3*delta, yu+3*delta)-(xr-4*delta,yd-4*delta),black,b, mask
    CASE Ctrl_Status_Clicked
        line CtrlPtr, (xl,yu)-(xr,yd),black,bf
        line CtrlPtr, (xl+delta, yu+delta)-(xr-delta,yd-delta),Color_lt,bf
        line CtrlPtr, (xl+2*delta, yu+2*delta)-(xr-2*delta,yd-2*delta),FGnd_color,bf
        line CtrlPtr, (xl+3*delta, yu+3*delta)-(xr-4*delta,yd-4*delta),black,b, mask
        'draw string CtrlPtr, (x_label+1, y_label+1), label, , labelfont, alpha
        font.backcolor = FGnd_Color
        Font.DrawString ctrlptr, label, x_label, y_label
    END SELECT
CASE Ctrl_Label 'Note: modified to remove "Disabled" color changes
    font.fontindex = MyFont.Label_Indx
    font.forecolor = Color_LabelTxt
    x_label = ((xl+xr-delta)- font.stringwidth(label))\2
    y_label = (yu+yd-delta -font.textheight)\2
    'IF State = Ctrl_Status_Disabled then
    '    line CtrlPtr, (xl,yu)-(xr,yd),Color_Inactive,bf
    'Else
        line CtrlPtr, (xl,yu)-(xr,yd),Color,bf
    'END IF
    view screen (xl, yu)-(xr, yd)   'Clip label to boundaries
    If TxtStr = "R" then xl = xr - TxtBox.Boarder - Label_Len
    IF TxtStr = "L" then Xl = Xl + TxtBox.Boarder
    IF TxtStr = "C" then Xl = (Xr+Xl)/2 - Label_Len/2
    'SELECT CASE State
        'CASE Ctrl_Status_Disabled
            'draw string CtrlPtr, (xl, yu + ((yd-yu)-LabelFont_Size/1.67)\2), label,,LabelFont,alpha  
        'CASE Ctrl_Status_Enabled, Ctrl_Status_GotFocus, Ctrl_Status_Clicked
            'draw string CtrlPtr, (xl, yu + ((yd-yu)-LabelFont_Size/1.67)\2), label,,LabelFont,alpha 
            Font.DrawString ctrlptr, label, x_label, y_label
    'END Select
    view        'reset viewport
CASE Ctrl_Menu
    font.fontindex = MyFont.Menu_Indx
    font.forecolor = Color_MenuTxt
    x_label = ((xl+xr-delta)- font.stringwidth(label))\2
    y_label = (yu+yd-delta -font.textheight)\2
    SELECT CASE State
    CASE Ctrl_Status_Disabled
        line (xl,yu)-(xr,yd),Color_MenuInactive,bf
        'draw string (x_label, y_label+1), label, , LabelFont, alpha
        font.backcolor = Color_MenuInactive
        font.forecolor = Color_MenuTxtInactive
        Font.DrawString ctrlptr, label, x_label, y_label
    CASE Ctrl_Status_Enabled
        line (xl,yu)-(xr,yd),Color_MenuBar,bf
        'draw string CtrlPtr, (x_label, y_label+1), label, , LabelFont, alpha
        font.backcolor = Color_MenuBar
        font.forecolor = Color_MenuTxt
        Font.DrawString ctrlptr, label, x_label, y_label
    CASE Ctrl_Status_GotFocus
        line (xl,yu)-(xr,yd),Color_MenuActiveBckgnd,bf
        'draw string (x_label, y_label+1), label, , LabelFontSel, alpha
        font.backcolor = Color_MenuActiveBckgnd
        font.forecolor = Color_Menu_Focus_Txt
        Font.DrawString ctrlptr, label, x_label, y_label
    CASE Ctrl_Status_Clicked
        line (xl,yu)-(xr,yd),Color_MenuActiveBckgnd,bf
        'draw string (x_label, y_label+1), label, , LabelFontSel, alpha
        font.backcolor = Color_MenuActiveBckgnd
        font.forecolor = Color_Menu_Focus_Txt
        Font.DrawString ctrlptr, label, x_label, y_label
        ' Create FB_Image buf and get region where drop-down will occur
        dim as integer iw, ih
        ImageInfo Menu_Image, iw, ih                'Size of pre-defined drop down menu
        ImageDestroy(Image_MenuSave)                'wipe out old
        Image_MenuSave = ImageCreate (iw+1, ih+1)   'new custom image size
        get (x1,23) - (x1 + iw, 23 + ih), Image_MenuSave    'Grab image for later restore
        put (xl, 23), Menu_Image, pset                      'Put drop down menu
    END SELECT
CASE Ctrl_ListBox
    font.fontindex = MyFont.Menu_Indx
    font.forecolor = Color_MenuTxt
    x_label = ((xl+xr-delta)- font.stringwidth(label))\2
    y_label = (yu+yd-delta -font.textheight)\2
    'Force ListBox height size, if not already set
    if yd <> yu + ListBox_Hgt then yd = yu + ListBox_Hgt
    SELECT CASE State
    Case Ctrl_Status_Disabled
        if slider_pos < 0 or slider_pos > ubound(sub_menu_label) then slider_pos = 0    
        Box_3D(xl,yu,xr-xl,ListBox_hgt, Color_MenuInactive,CtrlPtr)
        font.backcolor = Color_Transparent
        font.forecolor = Color_MenuTxtInactive
        IF slider_pos < 0 then
            Font.DrawString 0, Sub_Menu_Label(Active_Ctrl.Menu_Select), xl+4, yu+2
        else
            Font.DrawString ctrlptr, Sub_Menu_Label(Slider_Pos), xl+4, yu+2
        END IF   
    CASE Ctrl_Status_Enabled
        if slider_pos < 0 or slider_pos > ubound(sub_menu_label) then slider_pos = 0    
        Box_3D(xl,yu,xr-xl,ListBox_hgt, rgb(255,255,255),CtrlPtr)
        'draw string CtrlPtr,(xl+4, yu+6), Sub_Menu_Label(slider_pos), , MenuFont, alpha
        font.backcolor = rgb(255,255,255)
        font.forecolor = Color_MenuTxt
        'Font.DrawString ctrlptr, label, x_label, y_label
        IF slider_pos < 0 then
            Font.DrawString 0, Sub_Menu_Label(Active_Ctrl.Menu_Select), xl+4, yu+2
        else
            Font.DrawString ctrlptr, Sub_Menu_Label(Slider_Pos), xl+4, yu+2
        END IF
        ListBox_Button (xr-18, yu+2, FALSE)   'show button, not pressed
    CASE Ctrl_Status_Clicked
        ListBox_Button (xr-18, yu+2, TRUE)   'show button, pressed
    end select
CASE Ctrl_TxtBox
    font.fontindex = MyFont.TxtBox_Indx
    font.forecolor = Color_TxtBoxTxt
    x_label = ((xl+xr-delta)- font.stringwidth(label))\2
    y_label = (yu+yd-delta -font.textheight)\2
    IF Label_Len <> - 1 then
        TxtBoxLabel = Label
    else
        TxtBoxLabel = " "       'use Label_Len parameter to suppress showing Label
    end if
    IF V_Scroll_Enable = False then
        'May need to clip TxtStr to horizontal boarders of TxtBox
        'Print to image buffer to enable clipping at edges of TxtBox
        Dim Txt_image as FB.IMAGE ptr
        Select case state
            Case Ctrl_status_disabled
                Return 0
            Case ctrl_Status_Enabled
                FGnd_Color = Color_Box_Enabled
            Case ctrl_Status_GotFocus
                FGnd_Color = Color_Box_Focus
            Case Ctrl_Status_Clicked
                Fgnd_Color = Color_Box_Clicked
        end select
        Box_3d xl, yu, (xr-xl), (yd-yu), FGnd_Color, CtrlPtr
        Txt_Image = imagecreate ((xr-xl)-8,(yd-yu)-8,FGnd_Color)
        Font.backcolor = Color_Transparent
        Font.ForeColor = Color_TxtBoxTxt
        Font.Drawstring Txt_image, TxtBoxLabel & TxtStr, TxtBox.offset, (yd-yu-Font.TextHeight)/2-4
        Put (xl+4, yu+4), Txt_image, pset
        ' Show Label for TextBox ?
        IF Sub_Menu_State(0) <> 0 then
            Fgnd_Color = point (xl-5, yu+5, CtrlPtr)
            IF Sub_Menu_State(0) = -1 then   'right-justified, before TxtBox
                'r = gfx.font.getTextWidth(LabelFont, Label)
                Line CtrlPtr, (xl-Font.StringWidth(Label)-5, yu)-(xl-1,yd),Fgnd_Color, BF     'erase first
                'draw string CtrlPtr, (xl-r-5, yu+((yd-yu)-LabelFont_Size/1.67)\2), Label, ,LabelFont, alpha
                Font.Backcolor = Color_Transparent 'FGnd_Color
                Font.DrawString ctrlptr, label, xl-Font.StringWidth(Label)-5, yu+ ((yd-yu)-Font.TextHeight)\2
            ELSE
                Line CtrlPtr, (xl-SUB_Menu_State(0), yu)-(xl-1,yd),Fgnd_Color, BF     'erase first
                'draw string CtrlPtr, (xl-SUB_Menu_State(0), yu+((yd-yu)-LabelFont_Size/1.67)\2), Label, ,LabelFont, alpha
                Font.Backcolor = Color_Transparent
                Font.DrawString ctrlptr, label, xl-Sub_Menu_State(0), yu+ ((yd-yu)-Font.TextHeight)\2
            END IF
        END IF
        IF Sub_Menu_State(1) <> 0 then
            IF Sub_Menu_State(1) = -1 then   'left-justified, after TxtBox
                'draw string CtrlPtr, (xr + 5, yu+((yd-yu)-LabelFont_Size/1.67)\2), Label, ,LabelFont, alpha
                Font.Backcolor = Color_Transparent
                Font.DrawString ctrlptr, TxtBoxlabel & txtstr, xr + 5, yu+ ((yd-yu)-Font.TextHeight)\2
            ELSE                             'right-justified, after TxtBox
                'r = gfx.font.getTextWidth(LabelFont, Label)
                'draw string CtrlPtr, (xr + Sub_Menu_State(1)-r, yu+((yd-yu)-LabelFont_Size/1.67)\2), Label, ,LabelFont, alpha
                Font.Backcolor = Color_Transparent
                Font.DrawString ctrlptr, label, xr + Sub_Menu_State(1) - Font.StringWidth(label), yu+ ((yd-yu)-Font.TextHeight)\2
            END IF
        end if
        ImageDestroy (Txt_Image)
    else
        'view screen (xl, yu)-(xr, yd)
        Max_Line = INT((yd-yu-2*TxtBox.boarder) / (TxtBox.Line_Spacing*Font.TextHeight) )
        'Recompute the top & bottom boarder for the text in the textbox, as Delta,
        'so the block of text is centered vertically
        'Delta = ((yd-yu) - Max_Line * (TxtBox.Line_Spacing*TxtBoxFont_Size/1.67))\2+1
        Delta = ((yd-yu) - Max_Line * (TxtBox.Line_Spacing*Font.TextHeight))\2+1
        LineCnt = Parse_Text (TxtBoxlabel & TxtStr, (x2-x1)-2*TxtBox.boarder-Scroll_Width)
        IF (LineCnt > Max_Line) then
            if (V_Scroll_Active = False) then       'If Scroll not active yet, then activate
                Create_Scroll (x2,y2,y2-y1, "v")    'Caution: use x1, y1 etc coordinates, not
                                                    'xl, xr, yu, yd which already include offsets
                V_Scroll_Active = True
            End if
            First_Line = (LineCnt - Max_Line)*V_Scroll_pos
        Else
            First_Line = 0
        End IF
        If (V_Scroll_Active = True) and (LineCnt < Max_line+1) then
            V_Scroll_Active = False     'turn off Scroll bar, if no longer needed.
        end if
        IF V_Scroll_Active = True then 
            Set_Scroll_Len ((Max_Line/LineCnt)*(yd-yu-2))
        END IF
        SELECT CASE State
        CASE Ctrl_Status_Disabled
        CASE Ctrl_Status_Enabled
            line CtrlPtr, (xl,yu)-(xr,yd),Color_Box_Enabled,bf
            line CtrlPtr, (xl,yu)-(xr,yd),rgb(0,0,0),b
            For i = 0 to Max_Line-1
                'draw string CtrlPtr, (xl+TxtBox.Boarder, yu+Delta+(i)*TxtBox.Line_Spacing*TxtBoxFont_Size/1.67), Txt_Substr(First_Line+ i),,LabelFont,alpha          
                Font.Backcolor = Color_Box_Enabled
                Font.DrawString ctrlptr, Txt_Substr(First_Line+ i), xl+TxtBox.Boarder, yu+Delta+(i)*TxtBox.Line_Spacing*Font.TextHeight
            Next i
        CASE Ctrl_Status_GotFocus  'hovering, not clicked yet
            line CtrlPtr, (xl,yu)-(xr,yd),Color_Box_Focus,bf
            line CtrlPtr, (xl,yu)-(xr,yd),rgb(0,0,0),b
            For i = 0 to Max_Line-1
                'draw string CtrlPtr, (xl+TxtBox.Boarder, yu+Delta+(i)*TxtBox.Line_Spacing*TxtBoxFont_Size/1.67), Txt_Substr(First_Line+ i),,LabelFont,alpha          
                Font.Backcolor = Color_Box_Focus
                Font.DrawString ctrlptr, Txt_Substr(First_Line+ i), xl+TxtBox.Boarder, yu+Delta+(i)*TxtBox.Line_Spacing*Font.TextHeight
            Next i
        CASE Ctrl_Status_Clicked
            line CtrlPtr, (xl,yu)-(xr,yd),Color_Box_Clicked,bf
            line CtrlPtr, (xl,yu)-(xr,yd),rgb(0,0,0),b
            For i = 0 to Max_Line-1
                'draw string CtrlPtr, (xl+TxtBox.Boarder, yu+Delta+(i)*TxtBox.Line_Spacing*TxtBoxFont_Size/1.67), Txt_Substr(First_Line+ i),,LabelFont,alpha          
                Font.Backcolor = Color_Box_Clicked
                Font.DrawString ctrlptr, Txt_Substr(First_Line+ i), xl+TxtBox.Boarder, yu+Delta+(i)*TxtBox.Line_Spacing*Font.TextHeight
            Next i
         END Select
         View
    End if
CASE Ctrl_Scroll
    IF State <> Ctrl_Status_Disabled AND State <> Ctrl_Status_Hidden then
        line CtrlPtr, (xl, Yu+1)-(xr-1, Yd-1),rgb(245,245,245), bf  'Reset bckgnd
        line CtrlPtr, (xl, Yu+1)-(xr-1, Yd-1),rgb(230,230,230), b   'BckGnd trim
        line CtrlPtr, (xl-2, Yu+1)-(Xl-2, Yd-1),rgb(230,230,230)    'BckGnd trim
        Delta = ((yd-yu-2)-V_Scroll_Len)*V_Scroll_Pos
    END IF
    Select Case State
    Case Ctrl_Status_Enabled
        line CtrlPtr, (xl, Yu+1+Delta) - (xr-1, Yu+Delta+V_Scroll_Len), rgb(200,216,250), bf  
    Case Ctrl_Status_GotFocus
        line CtrlPtr, (xl, Yu+1+Delta) - (xr-1, Yu+Delta+V_Scroll_Len), rgb(212,230,250), bf 
    Case Ctrl_Status_Clicked
        line CtrlPtr, (xl, Yu+1+Delta) - (xr-1, Yu+Delta+V_Scroll_Len), rgb(160,188,250), bf
    Case Else
    End Select 
CASE Ctrl_CheckBox
    Font.FontIndex = MyFont.Label_Indx
    Font.Forecolor = Color_LabelTxt
    DIM as integer Box = Font.TextHeight
    IF State = Ctrl_Status_Disabled then
        Line CtrlPtr, (xl,yu)-(xr,yd),Color_Inactive, bf
    else
        Line CtrlPtr, (xl,yu)-(xr,yd),FGnd_Color, bf
    END IF
    IF State = Ctrl_Status_GotFocus then line CtrlPtr, (xl+1, yu+1)-(xr-1,yd-1),black,b, mask
    If TxtStr = "L" then
        Xl = Xl+5: xr = xr+5                    'Left-Justified
    else
        Xl = Xr-5-Box: xr = xr-5     'Right-Justified
    end if
    'Draw Box. Default dimensions determined by TextHeight. Delta is for vertical centering
    Delta = ((yd-yu)-Box)\2
    Box_3D (xl, yu+Delta, Box, Box, Color_FG)
    IF CheckState = True then
        line CtrlPtr, (xl+2,yu+Delta+2)-(xl+Box-2, Yu+Delta+Box-2), Black
        line CtrlPtr, (xl+2,yu+Delta+Box-2)-(xl+Box-2, Yu+Delta+2), Black
    else
        Box_3D (xl, yu+Delta, Box, Box, Color_FG)   'redraw box to cancel cross mark
    end if
    If TxtStr = "L" then
        Xl = Xl + Box + 5
    else
        xl = xl - 5 - Label_Len
    end if
    IF Label_Len > 0 then
    Select Case State
        CASE Ctrl_Status_Disabled
            'draw string CtrlPtr, (xl, yu+Delta+Label_FontSize*(1-1/1.67)\2), Label,,LabelFont,alpha   
            Font.BackColor = Color_Inactive
            Font.Drawstring CtrlPtr, Label, xl, yu + Delta
        Case Ctrl_Status_Enabled
            'draw string CtrlPtr, (xl, yu+Delta+Label_FontSize*(1-1/1.67)\2), Label,,LabelFont,alpha 
            Font.BackColor = FGnd_Color
            Font.Drawstring CtrlPtr, Label, xl, yu + Delta
        Case Ctrl_Status_Clicked
            'draw string CtrlPtr, (xl, yu+Delta+Label_FontSize*(1-1/1.67)\2), Label,,LabelFont,alpha 
            Font.BackColor = FGnd_Color
            Font.Drawstring CtrlPtr, Label, xl, yu + Delta
        CASE Ctrl_Status_GotFocus
            'draw string CtrlPtr, (xl, yu+Delta+Label_FontSize*(1-1/1.67)\2), Label,,LabelFont,alpha 
            Font.BackColor = FGnd_Color
            Font.Drawstring CtrlPtr, Label, xl, yu + Delta
    END SELECT
    END IF
CASE Ctrl_TxtFileBoX
    Box_3D (xl, yu, xr-xl, yd-yu, Color_FG)
    dim as integer hFile
    dim as string dumb
    Font.FontIndex = MyFont.TxtBox_Indx
    Font.ForeColor = Color_TxtBoxTxt
    Font.BackColor = Color_FG
    Max_Line = Fix((yd-yu)\Font.TextHeight)-1
    hFile = FreeFile
    If FileExists(TxtStr) then
        open TxtStr for input as hFIle 
    else
        open TxtStr for append as hFIle
    end if
    ' Count number of lines in text file
    LineCnt = 0
    do
        Line INPUT #hFIle, dumb
        LineCnt = LineCnt + 1
    loop until EOF(hFIle)
    IF LineCnt = 0 then
        Close #hFile
        Return 0
    end if
    IF (LineCnt > Max_Line) then
        if (V_Scroll_Active = False) and (V_Scroll_Enable = True) then       'If Scroll not active yet, then activate
            Create_Scroll (x2,y2,y2-y1, "v")    'Caution: use x1, y1 etc coordinates, not
                                                'xl, xr, yu, yd which already include offsets
            V_Scroll_Active = True 
            Set_Scroll_Len ((Max_Line/LineCnt)*(yd-yu-2))
            If Active_Ctrl.Active_PopUp = -1 then
                V_Scroll_Pos = 1                'default, start at end of file if not re-opening PopUp
            end if
            draw_scroll                         'Show Scroll
        End if
        First_Line = (LineCnt - Max_Line)*V_Scroll_pos
        If First_Line = 0 then First_Line = 1      
    Else
            First_Line = TxtBox.Offset
    End IF
    If (V_Scroll_Active = True) and (LineCnt < Max_line+1) then
        V_Scroll_Active = False     'turn off Scroll bar, if no longer needed.
    end if
    IF V_Scroll_Active = True then 
        Set_Scroll_Len ((Max_Line/LineCnt)*(yd-yu-2))
    END IF
    seek #hFile, 1      'reset pointer to read from beginning of file
    if First_Line > 1 then
        for i = 1 to First_Line-1
            Line INPUT #hFIle, dumb  'fake read to position file pointer
        next i
    else
        First_Line = 1
    END IF
    i=0
    do 
        Line input #hFIle, dumb
        dumb = mid(dumb,1,fix((xr-xl-Scroll_Width)/8))   'truncate string, if too long to fit on line
        draw string (xl + 4, yu + 4 + i*Default_Font_Height), dumb, rgb (0,0,0)
        'Font.DrawString (CtrlPtr, dumb, xl+4, yu + 4 + i * Font.TextHeight)
        i = i+1
    loop until EOF(hFile) or i = max_line+1
    Close #hFIle

CASE Ctrl_Slider
    dim as single cscale = 1
    Select Case State
        CASE Ctrl_Status_Disabled
            cscale = 0.6  
        Case Ctrl_Status_Enabled
            cscale = 1.0  
        Case Ctrl_Status_Clicked
            IF Slider_Click = 3 then cscale = 0.85
        CASE Ctrl_Status_GotFocus
            cscale = 1.05
        Case Else
            cscale = 1
    End Select


    IF V_Scroll_Len = 0 then V_Scroll_Len = SliderWidth  'default
    ' Draw track   
    IF H_Slider then
        line CtrlPtr, (xl,yu) - step (slen, SliderHeight), rgb(172,168,153), BF
        line CtrlPtr, (xl,yu+1) - step (slen, SliderHeight-2), rgb (236,233,216), BF
        line CtrlPtr, (xl,yu+2) - step (slen, SliderHeight-4), rgb(255,255,255),bf
    Else
        line CtrlPtr, (xl,yu) - step (SliderHeight, slen), rgb(172,168,153), BF
        line CtrlPtr, (xl+1,yu) - step (SliderHeight-2, slen), rgb (236,233,216), BF
        line CtrlPtr, (xl+2,yu) - step (SliderHeight-4, slen), rgb(255,255,255),bf
    END IF
    
    'draw slider
    IF H_Slider then
        line CtrlPtr, (xl   + SliderHeight + Slider_Pos, yu)-   step (V_Scroll_Len,   SliderHeight), rgb(113,111,100), BF
        line CtrlPtr, (xl   + SliderHeight + Slider_Pos, yu)-   step (V_Scroll_Len-1, SliderHeight-1), rgb(241,239,226), BF
        line CtrlPtr, (xl+1 + SliderHeight + Slider_Pos, yu+1)- step (V_Scroll_Len-2, SliderHeight-2), rgb(172,168,153), BF
        line CtrlPtr, (xl+1 + SliderHeight + Slider_Pos, yu+1)- step (V_Scroll_Len-3, SliderHeight-3), rgb(255,255,255), BF
        line CtrlPtr, (xl+2 + SliderHeight + Slider_Pos, yu+2)- step (V_Scroll_Len-4, SliderHeight-4), rgb(236*cscale,233*cscale,216*cscale), BF
    Else
        line CtrlPtr, (xl   , yd - (Slider_Pos + SliderHeight))  - step (SliderHeight,   -V_Scroll_Len), rgb(113,111,100), BF
        line CtrlPtr, (xl   , yd - (Slider_Pos + SliderHeight)-1)  - step (SliderHeight-1, -V_Scroll_Len+1), rgb(241,239,226), BF
        line CtrlPtr, (xl+1 , yd - (Slider_Pos + SliderHeight)-1)- step (SliderHeight-2, -V_Scroll_Len+2), rgb(172,168,153), BF
        line CtrlPtr, (xl+1 , yd - (Slider_Pos + SliderHeight)-2)- step (SliderHeight-3, -V_Scroll_Len+3), rgb(255,255,255), BF
        line CtrlPtr, (xl+2 , yd - (Slider_Pos + SliderHeight)-2)- step (SliderHeight-4, -V_Scroll_Len+4), rgb(236*cscale,233*cscale,216*cscale), BF
    END IF
    
    'Left/Bottom End Cmmd Button
    IF Slider_Click = 1 then    'button pressed
        IF H_Slider then
            line CtrlPtr, (xl,yu) - step (SliderHeight, SliderHeight), rgb(172,168,153), BF
            line CtrlPtr, (xl+1,yu+1) - step (SliderHeight-2, SliderHeight-2), rgb(236,233,216), BF
            'arrow
            line CtrlPtr, (xl+10,yu+6)- step (0, 7), rgb(0,0,0)    
            line CtrlPtr, (xl+9,yu+7)- step (0, 5), rgb(0,0,0)
            line CtrlPtr, (xl+8,yu+8)- step (0, 3), rgb(0,0,0)
            line CtrlPtr, (xl+7,yu+9)-step (0, 1), rgb(0,0,0)
        ELSE
            line CtrlPtr, (xl,yd-SliderHeight) - step (SliderHeight, SliderHeight), rgb(172,168,153), BF
            line CtrlPtr, (xl+1,yd-SliderHeight+1) - step (SliderHeight-2, SliderHeight-2), rgb(236,233,216), BF    

            line CtrlPtr, (xl+6,yd-SliderHeight+7)- step (7,0), rgb(0,0,0)
            line CtrlPtr, (xl+7,yd-SliderHeight+ 8)- step (5,0), rgb(0,0,0)
            line CtrlPtr, (xl+8,yd-SliderHeight+9)- step (3, 0), rgb(0,0,0)
            line CtrlPtr, (xl+9,yd-SliderHeight+10)-step (1,0), rgb(0,0,0)
        END IF
        
    ELSE                'button not pressed
        IF H_SLider then
            line CtrlPtr, (xl,yu) - step (SliderHeight, SliderHeight), rgb(113,111,100), BF
            line CtrlPtr, (xl, yu)- step (SliderHeight-1, SliderHeight-1), rgb(241,239,226), BF
            line CtrlPtr, (xl+1, yu+1)- step (SliderHeight-2, SliderHeight-2), rgb(172,168,153), BF
            line CtrlPtr, (xl+1, yu+1)- step (SliderHeight-3, SliderHeight-3), rgb(255,255,255), BF
            line CtrlPtr, (xl+2, yu+2)- step (SliderHeight-4, SliderHeight-4), rgb(236,233,216), BF
            'arrow
            line CtrlPtr, (xl+10,yu+6)- step (0, 7), rgb(0,0,0)
            line CtrlPtr, (xl+9,yu+7)- step (0, 5), rgb(0,0,0)
            line CtrlPtr, (xl+8,yu+8)- step (0, 3), rgb(0,0,0)
            line CtrlPtr, (xl+7,yu+9)-step (0, 1), rgb(0,0,0)
        ELSE
            line CtrlPtr, (xl,yd-SliderHeight) - step (SliderHeight, SliderHeight), rgb(113,111,100), BF
            line CtrlPtr, (xl, yd-SliderHeight)- step (SliderHeight-1, SliderHeight-1), rgb(241,239,226), BF
            line CtrlPtr, (xl+1, yd-SliderHeight+1)- step (SliderHeight-2, SliderHeight-2), rgb(172,168,153), BF
            line CtrlPtr, (xl+1, yd-SliderHeight+1)- step (SliderHeight-3, SliderHeight-3), rgb(255,255,255), BF
            line CtrlPtr, (xl+2, yd-SliderHeight+2)- step (SliderHeight-4, SliderHeight-4), rgb(236,233,216), BF
            
            line CtrlPtr, (xl+ 8,yd-SliderHeight+10)- step (1,0), rgb(0,0,0)
            line CtrlPtr, (xl+ 7,yd-SliderHeight+ 9)- step (3,0), rgb(0,0,0)
            line CtrlPtr, (xl+ 6,yd-SliderHeight+8) - step (5,0), rgb(0,0,0)
            line CtrlPtr, (xl+ 5,yd-SliderHeight+7) - step (7,0), rgb(0,0,0)
            
        END IF
    
        
    END IF

    'Right/Top End Cmmd Button
    IF Slider_Click = 2 then    'Button pressed
        IF H_Slider then
            line CtrlPtr, (xl+Slen-SliderHeight,yu) - step (SliderHeight, SliderHeight), rgb(172,168,153), BF
            line CtrlPtr, (xl+Slen-SliderHeight+1,yu+1) - step (SliderHeight-2, SliderHeight-2), rgb(236,233,216), BF    

            line CtrlPtr, (xl+slen - 9,yu+6)- step (0, 7), rgb(0,0,0)
            line CtrlPtr, (xl+Slen - 8,yu+ 7)- step (0, 5), rgb(0,0,0)
            line CtrlPtr, (xl+Slen - 7,yu+8)- step (0, 3), rgb(0,0,0)
            line CtrlPtr, (xl+Slen - 6,yu+9)-step (0, 1), rgb(0,0,0)
        ELSE
            line CtrlPtr, (xl,yu) - step (SliderHeight, SliderHeight), rgb(172,168,153), BF
            line CtrlPtr, (xl+1,yu+1) - step (SliderHeight-2, SliderHeight-2), rgb(236,233,216), BF    

            line CtrlPtr, (xl+6,yu+11)- step (7,0), rgb(0,0,0)
            line CtrlPtr, (xl+7,yu+ 10)- step (5,0), rgb(0,0,0)
            line CtrlPtr, (xl+8,yu+9)- step (3, 0), rgb(0,0,0)
            line CtrlPtr, (xl+9,yu+8)-step (1,0), rgb(0,0,0)
        END IF
    else                'Button not pressed
        IF H_Slider then
            line CtrlPtr, (xl+Slen-SliderHeight,yu) - step (SliderHeight, SliderHeight), rgb(113,111,100), BF
            line CtrlPtr, (xl+Slen-SliderHeight, yu)- step (SliderHeight-1, SliderHeight-1), rgb(241,239,226), BF
            line CtrlPtr, (xl+Slen-SliderHeight+1, yu+1)- step (SliderHeight-2, SliderHeight-2), rgb(172,168,153), BF
            line CtrlPtr, (xl+Slen-SliderHeight+1, yu+1)- step (SliderHeight-3, SliderHeight-3), rgb(255,255,255), BF
            line CtrlPtr, (xl+Slen-SliderHeight+2, yu+2)- step (SliderHeight-4, SliderHeight-4), rgb(236,233,216), BF

            line CtrlPtr, (xl+slen - 10,yu+5)- step (0, 7), rgb(0,0,0)
            line CtrlPtr, (xl+Slen - 9,yu+ 6)- step (0, 5), rgb(0,0,0)
            line CtrlPtr, (xl+Slen - 8,yu+7)- step (0, 3), rgb(0,0,0)
            line CtrlPtr, (xl+Slen - 7,yu+8)-step (0, 1), rgb(0,0,0)
        ELSE
            line CtrlPtr, (xl,yu) - step (SliderHeight, SliderHeight), rgb(113,111,100), BF
            line CtrlPtr, (xl, yu)- step (SliderHeight-1, SliderHeight-1), rgb(241,239,226), BF
            line CtrlPtr, (xl+1, yu+1)- step (SliderHeight-2, SliderHeight-2), rgb(172,168,153), BF
            line CtrlPtr, (xl+1, yu+1)- step (SliderHeight-3, SliderHeight-3), rgb(255,255,255), BF
            line CtrlPtr, (xl+2, yu+2)- step (SliderHeight-4, SliderHeight-4), rgb(236,233,216), BF
            
            line CtrlPtr, (xl+ 5,yu+9)- step (7,0), rgb(0,0,0)
            line CtrlPtr, (xl+ 6,yu+ 8)- step (5,0), rgb(0,0,0)
            line CtrlPtr, (xl+ 7,yu+7)- step (3,0), rgb(0,0,0)
            line CtrlPtr, (xl+ 8,yu+6)-step (1,0), rgb(0,0,0)
        END IF
    end if

CASE Ctrl_Null
    
CASE Ctrl_Key

CASE ELSE
    Active_Ctrl.Indx = Temp_Ctrl_Indx
    Return 0    'error code, nothing to draw
END SELECT
Active_Ctrl.Indx = Temp_Ctrl_Indx
Return -1
END Function

'Function to clip any single precision number to SIGDIG signficant digits.
'Example:  123     sigdig 2  is 120
'          0.02345 sigdig 1 is 0.02
FUNCTION CLIP(BYVAL X AS SINGLE, BYVAL SIGDIG AS INTEGER)AS SINGLE
DIM scale as single
if sigdig < 1 then clip = x: exit function
if x = 0 then
        clip = 0
        exit function
else
    scale = int(log(abs(x))/log(10))-(sigdig-1)
    CLIP = Cint(x/10^scale)*10^scale
end if
END function
'
' Converts to the string representation of a floating point number (single)
' to the nth dedimal place.  n = 0 -> whole number, n = -1 -> tenths, n = 1 -> tens etc
'
#include Once "vbcompat.bi"
Function Decimal_Place(byval x as single, byval n as integer) as string
    dim as string sx
    If n < 0 then
        sx = Format(x, "#." & String(-n, "0"))
    END if
    if n = 0 then
        sx = format(x,"#")
    end if
    if n > 0 then
        x = cint(x/10^n)*10^n
        sx = format(x,"#")
    end if
    return sx
end function

'
'  Function to draw rotated text.  In current version only 0, 90, 180, 270, 360 works.
'  Other angles cause truncation. Must use physical coordinates and have Viewport
'  include the entire screen
'  No test for clipping in current version
'
FUNCTION DrawStringRotate (byval xphys as integer, byval yphys as integer, _
    byval Text as string, byval Myfont as any ptr, byval FontSize as integer, _
    byval angle as integer)as byte
dim as FB.IMAGE ptr TextImage
dim as FB.IMAGE ptr NewTextImage 
dim as integer TxtLen, TxtHgt, Delta, Screen_width
'
'
Mssg_Box ("DrawStringRotate disabled.  Use Font.DrawString", "Warning")
return 0

'
' All distances / locations computed on physical screen coordinates.
'
'using ext
'ScreenInfo Screen_width 
''Compute coordinates for location to place rotated text
'TxtLen = gfx.font.getTextWidth(MyFont,Text)
'TxtHgt = .65*FontSize
'if xphys < TxtHgt then
'    Box_print "Won't work Bozo... too close to left edge"
'    'sleep
'    return 0
'    end
'end if
'if yphys < TxtLen then
'    Box_print "Worn't work Bozo... too close to the top"
'    'sleep
'    return 0
'    end
'end if
''
''Creat image buffer large enough to rotate along long axis of rectangular box
'If TxtLen > TxtHgt then
'    Delta = TxtLen
'Else
'    Delta = TxtHgt
'end if
'TextImage = IMageCreate(Delta+1,Delta+1, RGB(255,0,255))
'NewTextImage = IMageCreate(Delta+1,Delta+1, RGB(255,0,255))
''Get Original upper left, for later restore
'screenlock
'Get (0,0)-(Delta,Delta),TextImage
''Get target area and past to top left
'if xphys < Screen_Width\2 then       'If left half of screen, grab region to the right of target
'    Get (xphys-TxtHgt,yphys)-(xphys-TxtHgt+Delta,yphys-Delta),NewTextImage
'    'Rotate and paste at top left
'    gfx.Rotate(0,NewTextImage,0,0,-angle)
'    draw string  (0,0), Text,,MyFont, alpha
'    Get (0,0)-(Delta,Delta),NewTextImage                    'Capture image again
'    put (0,0),TextImage,pset                                'repair upper left
'    gfx.Rotate(0,NewTextImage,xphys-TxtHgt,yphys-TxtLen,angle)         'Rotate and paste
'else                   'For right half of screen, grab region to the left of target
'    Get (xphys-Delta,yphys)-(xphys,yphys-Delta),NewTextImage                
'    gfx.Rotate(0,NewTextImage,0,0,-angle)                      'Rotate and paste at top left
'    draw string  (0,Delta-TxtHgt), Text,,MyFont, alpha
'    Get (0,0)-(Delta,Delta),NewTextImage                      'Capture image again
'    put (0,0),TextImage,pset  'repair upper left
'    gfx.Rotate(0,NewTextImage,xphys-Delta,yphys-Delta,angle)           'Rotate and paste
'end if
'screenunlock
''
'ImageDestroy (TextImage)
'ImageDestroy (NewTextImage)
'return -1
end function


' Routine to test if file exists before open / append
' Returns   1 = yes exits
'           0 = no, does not exist
'
Function FileExist(byval fname as string) as byte
    IF len(dir(fname)) then
        return TRUE
    ELSE
        return FALSE
    end if
end function

' Routine to use Win Open / Save File Dialog Box to get filename.
'   sztitle  = Title for dialog box
'   szInitailidir    = default directory (current directory if null)
'   _szfilter = string to specify to filte for file listing (default *.* if null)
'
'             Format:   "any mssg here" + chr(0) + "filter" + chr(0).
'                       e.g. "Dat Files, (*.DAT)" + chr(0) + "*.dat" + chr(0)
' 
'   szName = default filename for dropdown menu
'
#Include Once "crt.bi"
#Include Once "windows.bi"
#Include Once "win/commdlg.bi"
'#Define FileOpenDialog(a,b,c,d) FileOpenSaveDialog(0,(a),(b),(c),(d))
'#Define FileSaveDialog(a,b,c,d) FileOpenSaveDialog(1,(a),(b),(c),(d))

Function FileOpenSaveDialog(iMode As Integer, Byval szTitle As Zstring Ptr , Byval szInitialDir As Zstring Ptr, Byval _szFilter As Zstring Ptr, Byval szName As Zstring Ptr) As String
        Dim ofn As OPENFILENAME
        Dim buff As Zstring*260
        Dim sz_Filter As Zstring Ptr
        Dim iIndex As Uinteger
        'Added hwnd to set ofn.hwndOwner to current FreeBasic program.
        'This causes FileOpenDialog box to open "on top"
        Dim As HWND hwnd          
        ScreenControl 2,cast(Integer,hwnd)   'Get Handle for the program window
        ofn.lStructSize=SizeOf(OPENFILENAME)
        ofn.hwndOwner=hwnd
        ofn.hInstance=GetModuleHandle(NULL)
        ofn.lpstrInitialDir= szInitialDir
        buff=String(260,0)
        If szName Then
            StrCpy(buff,szName)
        Endif
        ofn.lpstrFile=@buff
        ofn.nMaxFile=260
        sz_Filter = malloc(StrLen(_szFilter)+2)
        StrCpy(sz_Filter,_szFilter)
        sz_Filter[StrLen(sz_Filter)+1] = 0
        For iIndex = 0 To StrLen(sz_Filter) - 1
           If sz_Filter[iIndex] = Asc("|") Then sz_Filter[iIndex] = 0
        Next iIndex
        ofn.lpstrFilter = sz_Filter
        ofn.lpstrTitle = szTitle
        If iMode = 0 Then
            If GetOpenFileName(@ofn) Then Function =  buff
        Else
            If GetSaveFileName(@ofn) Then Function =  buff
        Endif
        free(sz_Filter)
End Function
'
'

Function FileSelectFolder (Byref title As String = "Choose A Folder", _
    Byval nCSIDL As Integer, iFlags As ULong = BIF_EDITBOX, _
    Byref sz_InitialDir As String) As String
  Dim bi As BROWSEINFO
  Dim pidl As LPITEMIDLIST
  Dim ret As HRESULT
  Dim physpath As Zstring * MAX_PATH
  Dim dispname As Zstring * MAX_PATH
  Dim fp As FOLDER_PROPS
  'bi.hwndOwner = HWND_DESKTOP
  'modified by SC to cause window to appear on top of program
  Dim As HWND hwnd 
  ScreenControl 2,cast(Integer,hwnd)   'Get Handle for the program window
  bi.hwndOwner = hwnd
  'end mod by SC
  If nCSIDL Then
    ret = SHGetSpecialFolderLocation(HWND_DESKTOP, nCSIDL, @bi.pidlRoot)
    'ret = SHGetFolderLocation(HWND_DESKTOP, nCSIDL, NULL, NULL, @bi.pidlRoot)
  Else
   'ret = SHGetSpecialFolderLocation(HWND_DESKTOP, CSIDL_DESKTOP, @bi.pidlRoot)
   ret = SHGetFolderLocation(HWND_DESKTOP, CSIDL_DESKTOP , NULL, NULL, @bi.pidlRoot)
  Endif
  fp.lpszTitle = Strptr(Title)
  fp.lpszInitialFolder = Strptr(sz_InitialDir)
  fp.ulFlags = iFlags
 
  bi.pszDisplayName = @dispname
  bi.lpszTitle = Strptr(title)
  bi.ulFlags = iFlags
  bi.lpfn = @FileSelectFolder_callback
  bi.lParam = Cast(LPARAM,Varptr(fp))
  bi.iImage = 0

  pidl = SHBrowseForFolder(@bi)
 
  If pidl <> 0 Then
    If SHGetPathFromIDList(pidl, physpath) = 0 Then
      Function = ""
    Else
      Function = physpath
    End If
    CoTaskMemFree pidl
   Else
    Function = ""
  End If
 
  CoTaskMemFree bi.pidlRoot
End Function

Function FileSelectFolder_callback (Byval hwndbrowse As HWND, Byval uMsg As UINT, _
  Byval lp As LPARAM, Byval lpData As LPARAM) As Integer
    If uMsg = BFFM_INITIALIZED Then
            Dim fp As FOLDER_PROPS Ptr
            fp = Cast(FOLDER_PROPS Ptr, lpData)
                        If fp Then
                            If (*fp).lpszInitialFolder Then
                                If (*fp).lpszInitialFolder[0] <> 0   Then
                                    ' set initial directory
                                            SendMessage(hwndbrowse, BFFM_SETSELECTION, TRUE, Cast(LPARAM,fp->lpszInitialFolder))
                                    Endif
                            Endif
                            If fp->lpszTitle Then
                                If (fp->lpszTitle[0] <>0) Then
                                    '        // set window caption
                                            SetWindowText(hwndbrowse, fp->lpszTitle)
                                    Endif
                            Endif
            Endif
   
        Endif
    Return 0
End Function
'
' Returns Ctrl_Indx for control win B[].label = Lbl
' If none found, returns -1
'
FUNCTION Get_Ctrl_Indx (byval Lbl as string) as integer
'Find first occurrance of B[indx].Label = Lbl, starting from last to first
    For i as integer = Num_Ctrl_Total-1 to 0 step -1
        If B[i].label = lbl then Return i
    next i
    Return -1   'not found
end function

'
' General function to return Filename from Windows Open File Dialog Box
FUNCTION GetFileName (byval Prompt as string, byval FileExt as string) as string
    DIM FullFileName as zstring*260, FileTypeFilter as zstring*100
    '
    'Define FileType filter for drop-down in OpenFile dialog box
    '
    FileTypeFilter = FileExt & " file ... (*." & FileExt & ")|*." & FileExt & "|"
    FileTypeFilter = FileTypeFilter + "All Files ... (*.*)|*.*||"
    '
    'Call OpenFile dialog 
    '
    FullFileName = FileOpenDialog(Prompt,Path,FileTypeFilter,"")
    if FullFileName = "" then 
        Return ""       'Null, no file selected
    end if
    '
    ' Strip out just the FileName, not the Path
    '
    DIM CharPos as integer = len(FullFileName)
    DO 
        CharPos = CharPos-1
    LOOP until "\" = mid(FullFileName, CharPos,1)   'Look for "\" as separator for path\filname
    Path = mid(FullFileName,1, CharPos)             'Same Path name
    Return mid(FullFileName,CharPos+1)          '
END FUNCTION
'
' Routine to Get_Input from textbox.
' Minimalist version, postion fixed, only single line prompt.
FUNCTION Get_Input (byval Prompt as string) as string
Dim as integer qwidth, qheight
Dim as uinteger Color_temp
Dim image_temp as FB.IMAGE ptr 
'using ext
Font.FontIndex = MyFont.TxtBox_Indx
'qwidth = gfx.font.getTextWidth(TxtBoxFont, Prompt) + 50
'qheight = TxtBoxFont_Size + 20
qwidth = Font.StringWidth(prompt) + 50
qheight = Font.TextHeight + 20


'Buffer to store screen image
Image_Temp = ImageCreate (qwidth+1, qheight+1)

Color_Temp = Color_Box_Focus
Color_Box_Focus = rGB(255,255,225)  'RGB (150,220,220)

With B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_TxtBox
    .state = Ctrl_Status_GotFocus
    .x1 = dxsmin + ((dxsmax-dxsmin) - qwidth)\2
    .x2 = .x1 + qwidth
    .y1 = (Screen_Height-qHeight)\2
    .y2 = .y1 + qheight
    Get (.x1,.y1)-(.x2,.y2),Image_Temp  'save screen image
    .x_offset = 0
    .y_offset = 0
    .Label = Prompt & " "
    '.Label_Len = gfx.font.getTextWidth(TxtBoxFont, Prompt)
    .Label_Len = Font.StringWidth(prompt)
    .txtstr = ""
    .LabelFont = TxtBoxFont
    .LabelFontSel = MenuFontSel
    .Label_FontSize = TxtBoxFont_size
    .V_Scroll_Enable = False            'no vertical Scroll Bars
end with
Active_Ctrl.Indx = Num_Ctrl_Total       'give focus to temporary TxtBox
B[Num_Ctrl_Total].Draw_Control 0        'draw it

'Get textbox input
TextBox_Process

' Kill temporary control & image buffer 
With B[Num_Ctrl_Total]
    Put (.x1,.y1),Image_Temp, pset  ' Restore screen
    .Ctrl_Type = Ctrl_Null
    .State = Ctrl_Status_hidden
END With
ImageDestroy (Image_Temp)
Active_Ctrl.Indx = -1                   'no control has focus
Color_Box_Focus = Color_Temp
return B[Num_Ctrl_Total].txtStr
END Function
'
'
' Routine to get input from a txtbox, with a verbose prompt.
' Prompt(0) = title  as string
' Prompt(1) .... prompt(10) separate lines of prompt, as string
' TxtLabel is the prompt for the TxtBox
' TxtDef is the default input
'
FUNCTION Get_Input_PopUp (Prompt () as string, byval Txt_Label as string, byval txtdef as string) as string
dim as integer x,y, bwidth, bheight, NumLine, title_Len, Ctrl_PopUp_Txt 
'using ext

Font.FontIndex = MyFont.TxtBox_Indx
Font.ForeColor = Color_TxtBoxTxt
Font.BackColor = Color_PopUP
'Find longest line of prompt
bwidth = 0
NumLine = 0
For i as integer = 0 to ubound(prompt)
    If len(prompt(i)) > 0 then 
        IF i <> 0 then NumLine = NumLine + 1
        'x = gfx.font.getTextWidth(ButtonFont, Prompt(i))
        x = Font.StringWidth(Prompt(i))
        if x > bwidth then bwidth = x
    END IF
Next i

bwidth = bwidth + 20
bheight = Font.TextHeight*NumLine + 90
with PopUp[Num_PopUp_Total]
        .x1 = dxsmin + (dxsmax-dxsmin-bwidth)\2
        .x2 = .x1 + bwidth    
        .y1 = dysmin + (dysmax-dysmin-bheight)\2
        .y2 = .y1 + bheight
        .x_offset = 0
        .y_offset = 0
        .color = Color_PopUP
        .Title = prompt(0)
        .Num_Ctrl = 1
        .ctrl_indx(0) = Num_Ctrl_Total
        .Exit_Button_Mssg = "Done"
end with

Active_Ctrl.Active_PopUp = Num_PopUp_Total  'Designate this PopUp as the active one
Num_PopUp_Total = Num_PopUp_Total + 1

with B[Num_Ctrl_total]
    .Ctrl_Type = Ctrl_TxtBox
    .state = Ctrl_Status_hidden
    'Control location in RELATIVE coordinates (wrt upper left corner of PoPUp Frame)
    .x1 = 20
    .x2 = .x1 + bwidth -40
    .y1 = bheight - (30 + Font.TextHeight * 1.8)    '30 pixels at bottom for exti button
    .y2 = .y1 + Font.TextHeight * 1.8
    .x_offset = 0  
    .y_offset = 0  
    .label = Txt_Label
    .LabelFont = TxtBoxFont
    .LabelFontSel = MenuFontSel
    .Label_FontSize = TxtBoxFont_size
    'IF len(.Label) > 0 then .label_len = GFX.FONT.GetTextWidth(.LabelFont, .Label)
    IF len(.Label) > 0 then .label_len = Font.StringWidth(.Label)
    .V_Scroll_Enable = False
    .TxtStr = txtdef        'initialize response to default
    .Sub_Menu_State(0) = 0  'don't print label as prompt on left outside txtbox
    .Sub_Menu_State(1) = 0  'don't print label as prompt on right outside txtbox
end with
Ctrl_PopUp_Txt = Num_Ctrl_Total
Num_Ctrl_Total = Num_Ctrl_Total + 1
Num_PopUP_Temp_Ctrl = Num_PopUP_Temp_Ctrl + 1

Draw_Pop_Up (Active_Ctrl.Active_PopUp)



IF NumLine > 0 then
    ' Add verbose prompt to popup
    With PopUp[Active_Ctrl.Active_PopUp]
        Get (.x1+.x_offset,.y1+.y_offset)-(.x2+.x_offset,.y2+.y_offset), Image_PopUp
    end with

    Font.BackColor = Color_PopUP
    For i as integer = 1 to NumLine
        'draw string Image_PopUp, (5, 25 + (i-1)* ButtonFont_Size), prompt(i),,ButtonFont, alpha
        Font.DrawString Image_PopUp, prompt(i), 5, 25 + (i-1)*Font.TextHeight
    Next i
    put (PopUp[Active_Ctrl.Active_PopUp].x1, PopUp[Active_Ctrl.Active_PopUp].y1), image_popup, pset
END IF



Active_Ctrl.Indx = Ctrl_PopUp_Txt        'give focus to temporary TxtBox
B[Active_Ctrl.Indx].State = Ctrl_Status_Clicked 
B[Active_Ctrl.Indx].Draw_Control 0       'draw it
TextBox_Process


' Bail out from ENTER key?
If B[Ctrl_PopUp_Txt].CheckState = True then     'Short-cut exit if ENTER key hit
    Close_PopUp
    Num_PopUp_Total = Num_PopUp_Total - 1
    return B[Num_Ctrl_Total].txtStr
END IF

' De-activate any reference to Active_Ctrl
    'Active_Ctrl.Indx = -1   'reset to null Ctrl
    Active_Ctrl.Ctrl_Type = Ctrl_Null
    Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
    Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
    clearevents 

    
' Local polling for events
do
    Select Case PollEvent ()
        Case Poll_Null              'no actions
        case Poll_TxtBox_Press      'nothing to do here
            'Serve_TxtBox
            TextBox_Process
            
            'print "Just after TextBox_Process. Checkstate: " & B[Ctrl_PopUP_Txt].Checkstate
            'Sleep
            'do until inkey = "": loop
            
            IF B[Ctrl_PopUp_Txt].Checkstate then      'if true, then ENTER key was hit
                    Close_PopUp
                    Num_PopUp_Total = Num_PopUp_Total - 1
                    return B[Num_Ctrl_Total].txtStr
            end if
        case Poll_CmdButton_Release 
            IF  Active_Ctrl.Indx > -1 then
                Select case B[Active_Ctrl.Indx].label    
                case PopUp[Active_Ctrl.Active_PoPup].Exit_Button_mssg    'close Cmd_Button for pop-ups
                    Close_PopUp
                    Num_PopUp_Total = Num_PopUp_Total - 1
                    return B[Num_Ctrl_Total].txtStr
                case else
                END Select
            END IF 
        case Poll_Key_Press
            IF Active_Ctrl.Key = FB.SC_Enter then
                Close_PopUp
                Num_PopUp_Total = Num_PopUp_Total - 1
                return B[Num_Ctrl_Total].txtStr
            END IF
        Case else
    End Select
    Sleep SleepTime         'Timeout so CPU can attend to other tasks
loop
END Function


'
' Parse a string into substrings, each of which is shorter (in pixels) than Tlen
' This proc is used to split a long text string for word-wrap in a TextBox
Function Parse_Text (byval Text as string, Tlen as integer) as integer
    dim as integer LineCnt, StrLoc, SpcLoc 
    Dim as string NextWord, TestString
    'Using Ext
    font.fontindex =  MyFont.TxtBox_Indx 
    'First, reset temporary text strings.
    for i as integer = 0 to sizeof(Txt_SubStr)-1
            Txt_SubStr(i) = ""
    next i
    
    LineCnt = 0
    StrLoc=1
    do
        SpcLoc = Instr(StrLoc,Text, " ")
        NextWord = mid (Text,StrLoc,SpcLoc-StrLoc)
        TestString = Txt_SubStr(LineCnt) + NextWord
        'if gfx.font.gettextwidth(MyFont, TestString) > TLen then
        if Font.StringWidth(TestString) > TLen then
            LineCnt = LineCnt+1
            Txt_Substr(LineCnt) = NextWord + " "
        else
            Txt_SubStr(LineCnt) = Txt_SubStr(LineCnt)  + NextWord + " "
        end iF
        StrLoc=SpcLoc+1
    loop until StrLoc > Len(Text) or SpcLoc = 0 or LineCnt = sizeof(Txt_SubStr)
    return LineCnt + 1      'number of lines to represent entire text string
END Function


'
' Uses the FBGfx ScreenEvent function to poll for mouse action or keyboard action.
' The mouse movement / press / release is then compared to the locations of user-defined 
' controls on the screen.
'
' Returns:  Event_type to indicate action, as defined in the table below:
'                    Poll_Null                   =0  
'                    Poll_CmdButton_Press        =1  
'                    Poll_CmdButton_Release      =2  
'                    Poll_TxtBox_Press           =3  
'                    Poll_TxtBox_Release         =4  
'                    Poll_MenuSelect_Press       =5  
'                    Poll_MenuSelect_Release     =6  
'                    Poll_MenuDropDown_Press     =7  
'                    Poll_MenuDropDown_Release   =8  
'                    Poll_Key_Press              =9   
'                    Poll_Window_Close           =10
'
'   The Control for which the Event_Type occurred and the state of the Control are
'   passed in Active_Ctrl user-defined-type.
'       Active_Ctrl.Ctrl_Type as integer        'which class of control
'       Active_Ctrl.Indx as integer             'unique numbered indx to identify each ctrl
'       Active_Ctrl.Key as integer              'Scancode for Kybd input
'       Active_Ctrl.Active_Menu as integer      'which Dropdown Menu, if any, is active
'       Active_Ctrl.Menu_Select as integer      'which Submenu item within dropdown menu
'       Active_Ctrl.Active_PopUp as integer     'data for PopUp Form (under development)     
'       Active_Ctrl.Active_TxtBox as integer    'data for TxtBox
'
'  Additional parameters for each Contrl are stored in User-Defined-Type "Control".  B is 
'  a ptr to UDT Control, and memory is allocated to store 50 controls.  Syntax B[index].CtrlVar
'  to read or set parameter values for Control # index.
'
Function PollEvent () as integer
dim as integer MenuWidth, scroll_indx, xm, ym, wm, bm
static as single Scroll_Pos_init
static PopUp_Select as byte
static Scroll_Select as byte
Static Slider_Select as byte
static x_last as integer
static y_last as integer
dim as integer xleft, xtop, c_indx
Dim Delta as single
DIM Event_Type as integer
Using fb
Dim e As EVENT                  'FBGfx ScreenEvent
If (ScreenEvent(@e)) Then   'wait for new event
    SELECT CASE e.type
    CASE EVENT_MOUSE_MOVE
        
        With mouse_now           'Update current mouse position
            IF e.x <= screen_width  then .x = e.x   'avoid mouse off-screen error
            IF e.y <= Screen_height then .y = e.y   'avoid mouse off-screen error
            '.b = 0
        end with
        
        IF PopUP_Select = TRUE then     'active dragging
            IF mouse_now.x <> x_last or mouse_now.y <> y_last then
                screenlock
                RestVid
                ''wipe
                ''view screen (dxsmin, dysmin)-(dxsmax, dysmax)
                with PopUp[Active_Ctrl.Active_PopUP]
                    'check for collision, prevent PopUp from moving off screen
                    xleft = .x1 +.x_offset + (Mouse_now.x - mouse_prev.x)
                    if xleft  < 1 then
                        xleft = 1
                        Mouse_Now.x = Xleft + Mouse_prev.x - (.x1 + .x_offset)
                    ELSEIF xleft + (.x2-.x1+1) > screen_width then
                        xleft = screen_width - (.x2-.x1+1)
                        Mouse_Now.x = Xleft + Mouse_prev.x - (.x1 + .x_offset)
                    END if
                    'now check vertical
                    xtop = .y1 + .y_offset+ (Mouse_now.y - mouse_prev.y)
                    IF xtop < dysmin then
                        xtop = dysmin
                        Mouse_Now.y = xtop + Mouse_Prev.y - (.y1 + .y_offset)
                    ELSEIF xtop + (.y2 - .y1 + 1) > screen_height then
                        xtop = screen_height - (.y2 - .y1 + 1)
                        Mouse_Now.y = xtop + Mouse_Prev.y - (.y1 + .y_offset)
                    end if
                    'put (.x1 +.x_offset + (Mouse_now.x - mouse_prev.x), .y1 + .y_offset+ (Mouse_now.y - mouse_prev.y)),image_PopUp, pset 
                    put (xleft, xtop),image_PopUp, pset 
                end with    
                screenunlock
                x_last = mouse_now.x
                y_last = mouse_now.y
            end if
        Elseif Scroll_Select = True then
            IF mouse_now.x <> x_last or mouse_now.y <> y_last then
                'NOTE!!! this works because the Parent Ctrl for the scrollbar is defined FIRST
                'i.e it has lower Indx and so WhichCtrl finds the Child before the parent ScrollBar (search is reverse order LIFO)
                With B[Active_Ctrl.indx]
                    'Update Scroll bar position
                    Delta = (Mouse_now.y - mouse_prev.y)/(.y2-.y1-2-.V_Scroll_Len)
                    .V_Scroll_Pos = Scroll_Pos_Init + Delta
                    'Make sure Scroll Bar stays in bounds
                    If .V_Scroll_Pos < 0 then .V_Scroll_Pos = 0
                    IF .V_Scroll_Pos > 1 then .V_Scroll_Pos = 1
                    x_last = mouse_now.x
                    y_last = mouse_now.y
                    B[.Scroll_Hnd].V_Scroll_Pos = .V_Scroll_Pos 'save copy in parent Ctrl info
                    screenlock
                    B[.Scroll_Hnd].Draw_Control 0               'update parent control
                    .draw_Control 0                             'Update Scroll Bar, must do after parent update  
                    screenunlock
                END WITH
            END IF
        Else
           Mouse_Move_Process ()       'Generalized Mouse Routines
        END IF
        
    CASE EVENT_MOUSE_BUTTON_PRESS
        Active_Ctrl.Indx = WhichCtrl ()
        IF Active_Ctrl.Indx > -1 then
            Active_Ctrl.Ctrl_type = B[Active_Ctrl.Indx].Ctrl_type
        else
            Active_Ctrl.Ctrl_type = Ctrl_Null
            With mouse_now          'Update mouse button status
                '.x = e.x           'CAREFUL! .x is not value during mouse click
                '.y = e.y           'Don't update position
                .b = e.button
            end with
        end if
        SELECT CASE Active_Ctrl.Ctrl_type
            CASE Ctrl_Mouse_R_PopUp
                IF e.button = 2 then
                    Event_Type = Poll_Mouse_R_Press
                    Mouse_PopUp_Process()
                end if
                
                'print "Sleeping...now back in PollEvent"
                'sleep
                
            CASE Ctrl_Button
                B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked   'update state to indicate clicked
                B[Active_Ctrl.Indx].Draw_Control 0
                Event_Type = Poll_CmdButton_Press
            CASE Ctrl_Menu
                B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked 
                Active_Ctrl.Active_Menu = Active_Ctrl.Indx
                Menu_Process()                                  'Process Menu activity
                Event_Type = Poll_MenuSelect_Press
            CASE Ctrl_ListBox
                B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked   'update state to indicate clicked
                B[Active_Ctrl.Indx].Draw_Control 0
                Event_Type = Poll_ListBox_Press
                ListBox_Process()
            CASE Ctrl_TxtBox
                B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked   'update state to indicate clicked
                B[Active_Ctrl.Indx].Draw_Control 0
                Event_Type = Poll_TxtBox_Press
                Textbox_Process()                    
            CASE Ctrl_Null          'clicked off control, but might be dropdown selection
                Event_Type = Poll_Null
            CASE Ctrl_PopUP     'drag PopUp Form
                IF PopUp_Select = FALSE then
                    PopUP_Select = TRUE
                    Mouse_Prev.x = Mouse_Now.x      'store Mouse position at start of drag
                    Mouse_Prev.y = Mouse_Now.y
                    x_last = mouse_now.x
                    y_last = mouse_now.y
          ''          view screen (dxsmin, dysmin)-(dxsmax, dysmax)           'constrain limits of screen
                    With PopUp[Active_Ctrl.Active_PopUp]
                        Get (.x1+.x_offset,.y1+.y_offset)-(.x2+.x_offset,.y2+.y_offset), Image_PopUp
                    end with  
                End if
            CASE Ctrl_Scroll
                With B[Active_Ctrl.Indx]
                    'Delta is the position for the top edge of scroll_bar, relative to .y1
                    Delta = (.y2-.y1-2-.V_Scroll_Len)*.V_Scroll_pos
                    'Where is mouse click, relative to scroll_bar?
                    If Mouse_Now.y < (.y1+.y_offset+Delta) then    'Mouse above scroll_bar
                        wm = 0  'reset flg, no loop through yet
                        Do 
                            'Jump scroll upward, with increment = V_Scroll_Len
                            .V_Scroll_Pos = .V_Scroll_Pos - .V_Scroll_Len / (.y2-.y1-.V_Scroll_Len)
                            'Make sure the jump doesn't pass over location of mouse click
                            If .V_Scroll_Pos < (Mouse_Now.y-.y1-.y_offset)/(.y2-.y1-.V_Scroll_Len) then
                                .V_Scroll_Pos = (Mouse_Now.y-.y1-.y_offset)/(.y2-.y1-.V_Scroll_Len)
                            end if
                            'Make sure Scroll Bar stays in bounds
                            If .V_Scroll_Pos < 0 then .V_Scroll_Pos = 0
                            IF .V_Scroll_Pos > 1 then .V_Scroll_Pos = 1
                            x_last = mouse_now.x
                            y_last = mouse_now.y
                            B[.Scroll_Hnd].V_Scroll_Pos = .V_Scroll_Pos 'save copy in parent Ctrl info
                            screenlock
                            B[.Scroll_Hnd].Draw_Control 0               'update parent control
                            .draw_Control 0                             'Update Scroll Bar, must do after parent update  
                            screenunlock
                            IF wm = 0 then
                                sleep (500) 'wait a bit
                                wm = 1
                            else
                                sleep (100) 'shorter on repeat
                            end if
                            getmouse (xm, ym, ,bm)  'low-level, get mouse status
                        loop while bm = 1           'continue scroll/jump while mouse button pressed
                    ElseIf Mouse_Now.y > (.y1 + .y_offset + Delta + .V_Scroll_Len) then   'Mouse below Scroll_Bar
                        wm = 0  'reset flg, no loop through yet
                        Do 
                            'Jump scroll downward, with increment = V_Scroll_Len
                            .V_Scroll_Pos = .V_Scroll_Pos + .V_Scroll_Len / (.y2-.y1-.V_Scroll_Len)
                            'Make sure the jump doesn't pass over location of mouse click
                            If .V_Scroll_Pos > (Mouse_Now.y-.y1-.y_offset)/(.y2-.y1-.V_Scroll_Len) then
                                .V_Scroll_Pos = (Mouse_Now.y-.y1-.y_offset)/(.y2-.y1-.V_Scroll_Len)
                            end if
                            'Make sure Scroll Bar stays in bounds
                            If .V_Scroll_Pos < 0 then .V_Scroll_Pos = 0
                            IF .V_Scroll_Pos > 1 then .V_Scroll_Pos = 1
                            x_last = mouse_now.x
                            y_last = mouse_now.y
                            B[.Scroll_Hnd].V_Scroll_Pos = .V_Scroll_Pos 'save copy in parent Ctrl info
                            screenlock
                            B[.Scroll_Hnd].Draw_Control 0               'update parent control
                            .draw_Control 0                             'Update Scroll Bar, must do after parent update  
                            screenunlock
                            IF wm = 0 then
                                sleep (500) 'wait a bit
                                wm = 1
                            else
                                sleep (100) 'shorter on repeat
                            end if
                            getmouse (xm, ym, ,bm)  'low-level, get mouse status
                        loop while bm = 1           'continue scroll/jump while mouse button pressed                
                    Else        'mouse on Scroll_bar
                        If Scroll_Select = False then 
                            Scroll_Select = True
                            Mouse_Prev.x = Mouse_Now.x      'store Mouse position at start of drag
                            Mouse_Prev.y = Mouse_Now.y
                            x_last = mouse_now.x
                            y_last = mouse_now.y
                            Scroll_Pos_Init = .V_scroll_pos
                            .State = Ctrl_Status_Clicked
                            screenlock
                            .draw_Control 0
                            screenunlock
                        END IF
                    end if
                END WIth
            CASE Ctrl_CheckBox 
                B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked   'update state to indicate clicked
                If B[Active_Ctrl.Indx].CheckState = True then
                    B[Active_Ctrl.Indx].CheckState = False
                else
                    B[Active_Ctrl.Indx].CheckState = True
                end if
                B[Active_Ctrl.Indx].Draw_Control 0
                Event_Type = Poll_CheckBox_Press
            Case Ctrl_Slider
                B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked   'update state to indicate clicked
                B[Active_Ctrl.Indx].Draw_Control 0
                Slider_Process
                Event_Type = Poll_Slider_Press
            Case else
            END Select
                           
    CASE EVENT_MOUSE_BUTTON_RELEASE
        With mouse_now      'Update mouse button status
         '   .x = e.x       'DON'T UPDATE POSITON!!!
         '   .y = e.y
            .b = 0
        end with
        IF Active_Ctrl.Indx > -1 then
            IF Active_Ctrl.Menu_Select > 0 then   'Button release, after clicking on dropdown menu
                Active_Ctrl.Active_Menu = -1      'de-activate Menu Select stuff
                Active_Ctrl.Menu_Select = -1
                Active_Ctrl.Indx = -1   'reset to null Ctrl
                Active_Ctrl.Ctrl_Type = Ctrl_Null
            end if
        
            IF B[Active_Ctrl.indx].Ctrl_Type = Ctrl_Button Then
                B[Active_Ctrl.Indx].state = Ctrl_Status_Enabled     'Reset to available Cmd_Button
                B[Active_Ctrl.Indx].Draw_Control 0
                Event_Type = Poll_CmdButton_Release
            END IF
            If B[Active_Ctrl.indx].Ctrl_Type = Ctrl_Scroll then
                Scroll_Select = False
                if Active_Ctrl.indx = WhichCtrl then
                    'Still on top of scrollbar
                    B[Active_Ctrl.Indx].State = Ctrl_Status_GotFocus
                else
                    'Released buttom while off scrollbar
                    B[Active_Ctrl.Indx].State = Ctrl_Status_Enabled
                end if
                B[Active_Ctrl.Indx].Draw_Control 0
            end if
            If B[Active_Ctrl.Indx].Ctrl_Type = Ctrl_Slider then
                B[Active_Ctrl.Indx].Slider_Click = 0
                B[Active_Ctrl.Indx].Draw_Control 0
                Event_Type = Poll_Slider_Release
            end if
            If PopUp_Select = True Then
                PopUP_Select = False
                'Reset Offset for PopUp
                With PopUp[Active_Ctrl.Active_PopUp]
                    .x_offset = .x_offset + (mouse_now.x - mouse_prev.x)
                    .y_offset = .y_offset + (mouse_now.y - mouse_prev.y)
                end with
                'Reset Offset for Controls on PopUp
                With PopUp[Active_Ctrl.Active_PopUp]
                    IF .Num_Ctrl > 0 then 
                        for i as integer = 0 to .Num_Ctrl-1
                            B[.Ctrl_Indx(i)].x_offset = B[.Ctrl_Indx(i)].x_offset + (mouse_now.x - mouse_prev.x)
                            B[.Ctrl_Indx(i)].y_offset = B[.Ctrl_Indx(i)].y_offset + (mouse_now.y - mouse_prev.y)
                        next i
                    END IF
                END with
                'Don't forget new temporary controls on PopUp
                For i as integer = 1 to Num_PopUp_Ctrl
                    B[Num_Ctrl_Total-i].x_offset = B[Num_Ctrl_Total-i].x_offset + (mouse_now.x - mouse_prev.x)
                    B[Num_Ctrl_Total-i].y_offset = B[Num_Ctrl_Total-i].y_offset + (mouse_now.y - mouse_prev.y)
                Next i
                View                                    'reset to entire screen
            end if
        END IF
    Case EVENT_KEY_PRESS
        Event_Type = Poll_Key_Press
        Active_Ctrl.key = e.scancode
        
    CASE EVENT_WINDOW_CLOSE             'attempt to close window
        Event_Type = Poll_Window_Close
        
    CASE else
            'ignore all other events
    END SELECT
END IF

view

return Event_Type
End Function

'
' Routine to ask a PoPup question, and return T/F answer
FUNCTION QUERY (byval Prompt as string) as byte
dim as integer x,y, qwidth, qheight, button_width, Ctrl_Yes, Ctrl_No, Ctrl_Default 
'using ext
'qwidth = gfx.font.getTextWidth(TxtBoxFont, Prompt) + 16
'qheight = TxtBoxFont_Size + 60

Font.fontindex = MyFont.TxtBox_Indx
qwidth = Font.StringWidth(prompt) + 16
qheight = Font.TextHeight + 60


With PopUp[Num_PopUp_Total]
    .x1 = (dxsmax + dxsmin - qwidth)\2    '(Screen_Width - qwidth)\2
    .x2 = .x1 + qwidth
    .y1 = (dysmax+dysmin-qheight)\2       '(Screen_Height-qHeight)\2
    .y2 = .y1 + qheight
    .x_offset = 0
    .y_offset = 0
    .color = rgb (255,255,255)
    .Title = "Query"
    .Num_Ctrl = 2
    .ctrl_indx(0) = Num_Ctrl_Total
    .Ctrl_Indx(1) = Num_Ctrl_Total+1
    .Exit_Button_Mssg = ""
end with
Active_Ctrl.Active_PopUp = Num_PopUp_Total  'Designate this PopUp as the active one
Num_PopUp_Total = Num_PopUp_Total + 1

'Button_Width = GFX.Font.GetTextWidth (ButtonFont, "Yes") + 30
Button_Width = Font.StringWidth("Yes") + 30


with B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_Button
    .state = Ctrl_Status_hidden
    .color = rgb (220, 220, 255)
    .label ="Yes"
    .labelFont = ButtonFont
    .LabelFontSel = ButtonFont
    .Label_FontSize = Font.TextHeight
    '.Label_Len = gfx.font.getTextWidth(ButtonFont, .label)
    .Label_Len = Font.StringWidth(.label)
    .x1 = qwidth\2 - Button_Width - 10 :        .y1 = qheight-(.Label_FontSize + 10)
    .x2 = .x1 + Button_Width:                   .Y2 =.y1 + .Label_FontSize+5
    .x_offset = 0
    .y_offset = 0 
    .CheckState = False     'reset variable to detect button press
End with
Ctrl_Yes = Num_Ctrl_Total
Num_Ctrl_Total = Num_Ctrl_Total + 1
Num_PopUP_Temp_Ctrl = Num_PopUP_Temp_Ctrl + 1

with B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_Button
    .state = Ctrl_Status_hidden
    .color = rgb (220, 220, 255)
    .label ="No"
    .labelFont = ButtonFont
    .LabelFontSel = ButtonFont
    .Label_FontSize = Font.TextHeight
    '.label_len = gfx.font.getTextWidth(ButtonFont, .label)
    .Label_Len = Font.StringWidth(.label)
    .x1 = qwidth\2 + 10:            .y1 = qheight-(.Label_FontSize + 10)
    .x2 = .x1 + Button_Width:       .Y2 =.y1 + .Label_FontSize + 5
    .x_offset = 0
    .y_offset = 0 
    .CheckState = False     'reset variable to detect button press
end with
Ctrl_No = Num_Ctrl_Total
Num_Ctrl_Total = Num_Ctrl_Total + 1
Num_PopUP_Temp_Ctrl = Num_PopUP_Temp_Ctrl + 1

' Draw PopUp
Draw_Pop_UP (Active_Ctrl.Active_PopUp)
' Set "Yes" as the default answer
Ctrl_Default = Ctrl_Yes
Active_Ctrl.Indx = PopUp[Active_Ctrl.Active_PopUp].Ctrl_Indx(0)        'temporarily reset Active_Ctrl for Draw routines
With B[Ctrl_Default]
    .state = Ctrl_Status_GotFocus
    .draw_Control 0
End With
' Add query mssg
'draw string (PopUp[Active_Ctrl.Active_PopUp].x1 + 8, PopUp[Active_Ctrl.Active_PopUp].y1 + qheight\2),Prompt, , TxtBoxFont, alpha
Font.ForeColor = Color_TxtBoxTxt
Font.BackColor = RGB(255,255,255)
Font.DrawString 0, Prompt, PopUp[Active_Ctrl.Active_PopUp].x1 + 8, PopUp[Active_Ctrl.Active_PopUp].y1 + qheight\2 - Font.TextHeight


' De-activate any reference to Active_Ctrl
    Active_Ctrl.Indx = -1   'reset to null Ctrl
    Active_Ctrl.Ctrl_Type = Ctrl_Null
    Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
    Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
    clearevents  
' Query PopUp will be destroyed after poll event, so decrease count now     
Num_PopUp_Total = Num_PopUp_Total-1
' Local polling for events
do
    Select Case PollEvent ()
        case Poll_CmdButton_Release 
            Select case B[Active_Ctrl.Indx].label    
                case "Yes"
                    Close_PopUP
                    Return True
                case "No"
                    Close_PopUP
                    Return False
                case else
                    locate 15,1
                    print "Response not recognized.  Routine Query in FB_Lib.BAS"
                    print "Hit any key to continue"
                    sleep
                    do until inkey = "" : Loop
                    close_PopUP
                    return false
            end select 
        Case Poll_Key_Press
            If Active_Ctrl.key = FB.SC_TAB then
                'Clear prior definition
                with B[Ctrl_Default]
                    .state = Ctrl_Status_Enabled
                    .draw_Control 0
                END With
                'toggle
                If Ctrl_Default = Ctrl_Yes then
                    Ctrl_Default = Ctrl_No
                Else
                    Ctrl_Default = Ctrl_Yes
                END IF
                with B[Ctrl_Default]
                    .state = Ctrl_Status_GotFocus
                    .draw_Control 0
                END With
            ElseIF Active_Ctrl.key = FB.SC_Enter then
                If Ctrl_Default = Ctrl_Yes then
                    Close_PopUp
                    Return True
                else
                    Close_PopUP
                    Return False
                END IF
            END IF
        Case Else
    end select
    Sleep SleepTime     'free up some time for CPU
loop
END Function

'
' Symmetric Arithematic Rounding.
'
' Round(0.5) = 1,  Round(-0.5) = -1
'
FUNCTION RoundSym (byval x as single) as single
    return FIX(x+.5*SGN(x))
END FUNCTION
'
' Screen capture to BMP file.  Returns 0 if no BMP file saved
'
function ScrnBMP () as byte
dim buff as Zstring*260
Buff = FileSaveDialog ("Save to BMP file...  ","","BMP file... (*.BMP)|*.BMP||","untitled.bmp")
if buff = "" then Return False
'
' Make sure filename has "BMP" extension
if ucase(mid(buff,len(buff)-3))<> ".BMP" then buff = buff + ".BMP"
bsave buff, 0
Return True
end function
'
' Draw a box with pseudo 3D effect
' Background is set to Color_Main, a constant set in FB_GUI.BI
' Usable background size is reduced by 4 pixels (Vert and Horiz)
'
SUB Box_3D (byval x as integer, byval y as integer, _
    byval w as integer, byval h as integer, byval Color_Main as uinteger, byval CtrlPtr as any ptr)
DIM as UINTEGER Shade1, Shade2, Shade3 
shade1 = rgb(241, 239, 226)
shade2 = rgb(172,168,153)
shade3 = rgb(113,111,100)
    'Draw background
    line CtrlPtr,(x,y)-step(w,h), Color_Main, BF
    'Shading for pseudo 3D
    line CtrlPtr,(x,y)-step(w-1,  0), shade2
    line CtrlPtr,(x,y)-step(0  ,H-1), shade2
    line CtrlPtr,(x+1,y+h-1)-step(w-2,  0), shade1
    line CtrlPtr,(x+w-1,y+1)-step(0  ,h-2), shade1
    line CtrlPtr,(x+1,y+1)-step(w-3,  0), shade3
    line CtrlPtr,(x+1,y+1)-step(0,  h-3), shade3    
END SUB

'
' Print text to the default TxtFileBox
SUB Box_Print (byval MyString as string)
DIM as integer hFile, C_indx 
    hFile = FREEFILE
    IF B[Default_TxTFileBox].TxtStr = "" then 
        locate 10,10
        print "Box_Print mssg: " & mystring   
        exit sub  'abort if not defined
    end if
    Open B[Default_TxTFileBox].TxtStr for append as hFile
    Print #hFIle, MyString
    close #hfile
    'print "In Box_Print.  Default_TxtFileBox: ", Default_TxtFileBox
    C_indx = Active_Ctrl.Indx   'temporary storage
    Active_Ctrl.Indx = Default_TxtFileBox
    With B[Active_Ctrl.Indx] 
        IF .State <> Ctrl_Status_Disabled AND .State <> Ctrl_Status_Hidden then
            .V_Scroll_Pos = 1    'reset to show last line in hFIle
            .Draw_Control 0
            if .V_Scroll_Active = True then Draw_Scroll
        END IF
    END With
    Active_Ctrl.Indx = C_Indx
END SUB  
'
' Reset all Ctrl, kybd buffer  & Mouse events
'
SUB Clear_All()
Active_Ctrl.Indx = -1           'reset to null Ctrl
Active_Ctrl.Ctrl_Type = Ctrl_Null
Active_Ctrl.Active_Menu = -1    'reset index, no dropdown menu active
Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
Mouse_Now.B = 0                 'Reset Mouse Click
Do until inkey = "": loop       'clear keybd buffer
clearevents                     'Clear Events
end sub
'
' Subroutine to clear queue of ScreenEvents
'
SUB ClearEvents ()
    Using FB 
    dim e as EVENT
    do until ScreenEvent(@e) = 0 : loop
end SUB
'
' Routine to close a PopUp Form, and reset the Controls on the Main Form to Enabled status
SUB Close_PopUp ()
    RestVid
    'wipe    'restore graphics area
    'If PopUp had any Controls, reset status to Hidden
    IF PopUp[Active_Ctrl.Active_PopUp].Num_Ctrl > 0 then
        for i as integer = 0 to PopUp[Active_Ctrl.Active_PopUp].Num_Ctrl-1
            B[PopUp[Active_Ctrl.Active_PopUp].Ctrl_Indx(i)].state = Ctrl_Status_Hidden
            B[PopUp[Active_Ctrl.Active_PoPup].Ctrl_indx(i)].V_Scroll_Active = False
        next i
    END IF
    'Remove temporary controls
    Num_Ctrl_Total = Num_Ctrl_Total - Num_PopUp_Ctrl - Num_PopUp_Temp_Ctrl
    Num_PopUp_Temp_Ctrl = 0                         'reset
    Num_PopUp_Ctrl = 0
    'Reset PopUp status
    IF PopUp[Active_Ctrl.Active_PopUp].Temp_Flg = TRUE then 
        Kill_PopUp (Active_Ctrl.Active_PopUp)
    end if
    Active_Ctrl.Active_PopUp = -1                   'no active PopUps
    'Reset Controls on main form
    Enable_Controls                                 'Enable Controls on Main Form
    Active_Ctrl.Indx = -1   'reset to null Ctrl
    Active_Ctrl.Ctrl_Type = Ctrl_Null
    Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
    Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
    clearevents  
END SUB
'
'Clear the graphics window
SUB ClrScrn ()
   ' Line (dxsmin, dysmin)-(dxsmax, dysmax), Color_Scrn, BF  'Overwrite graphics Viewport with bckgnd color
    Box_3D (dxsmin, dysmin, dxsmax-dxsmin, dysmax-dysmin, Color_Scrn)
END SUB
'
' Create Menu bar across top of graphics window
' NumMenu = number of Menu selections
' FirstMenuCtrl = identifier index used to define the first Menu selection
SUB Create_Menu (byval NumMenu as integer, byref First_Menu_Ctrl as integer)
dim as integer xold = 5                             ' spacer, in pixels between menu titles
'
' Draw Menu Bar
'
    line (dxsmin,dysmin) - (Screen_Width, Dysmin + Menu_Bar_Height),Color_MenuBar, bf
    line (dxsmin,dysmin+Menu_Bar_Height) - (Screen_Width, Dysmin+Menu_Bar_Height), rgb(255,255,255)
    line (dxsmin,dysmin+Menu_Bar_Height+1) - (Screen_Width, Dysmin+Menu_Bar_Height+1), rgb(172,168,153)
    line (dxsmin,dysmin+Menu_Bar_Height+2) - (Screen_Width, Dysmin+Menu_Bar_Height+2), rgb(255,255,255)
    dysmin = Menu_Bar_Height+4
    ImageDestroy (Image_Buffer)
    image_buffer = ImageCreate ((dxsmax-dxsmin+1), (dysmax-dysmin+1))   
' Define Menu Labels across the menu bar
Font.FontIndex = MyFont.Menu_Indx
First_Menu_Ctrl = Num_Ctrl_Total    
For i as integer = 0 to NumMenu-1
    with B[Num_Ctrl_Total]
        .Ctrl_type = Ctrl_Menu
        .label = Menu_Title(i)
        .state = Ctrl_Status_Enabled
        .x1 = xold 
        .y1 = 0
        '.Label_Len = gfx.font.getTextWidth(MenuFontSel, .label)
        .Label_Len = Font.StringWidth (.Label)
        .x2 = .x1 + .Label_len + 12            
        .y2 = Menu_Bar_Height
        .x_offset = 0       'no offsets for controls on Main Form
        .y_offset = 0
        .LabelFont = MenuFont
        .LabelFontSel = MenuFontSel
        .Label_FontSize = MenuFontSel_size
        xold = .x2
    end with
    Num_Ctrl_Total = Num_Ctrl_Total +1
next i
END SUB


' Create new Scroll Bar as a control
' xr - right end.  yd - lower edge, Scroll_Length full length 
' S_type is V = verticalor H = horizonal
SUB Create_Scroll (byval xr as integer, byval yd as integer, _
    byval S_Length as integer, byval S_Type as string)
'Assign Scroll_Ctrl.Indx to "parent"
B[Active_Ctrl.Indx].Scroll_hnd = Num_Ctrl_Total


dprint (18,"In create scroll. Active_Ctrl.Indx = " & Active_Ctrl.Indx)
dprint (19,"B[0].Scroll_hnd = " & B[Active_Ctrl.Indx].Scroll_hnd)
dprint (20,"Going into Def Scroll, Num_Ctrl_Total = " & Num_Ctrl_Total)

If (Active_Ctrl.Active_PopUp = -1) then
    'No PopUp, increse Num_Ctrl_Total and no offset
    With B[Num_Ctrl_Total]
        .Ctrl_Type = Ctrl_Scroll
        .Scroll_hnd = Active_Ctrl.Indx  'index of the control assocaited with new scrollbar
        .x2 = xr     'PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset  'default, start where PopUp originates
        .y2 = yd     'PopUp[PopUp_Indx].y1 + PopUp[PopUp_Indx].y_offset
        if ucase(S_Type) = "V" then
            .x1 = .x2 - Scroll_width     'PopUp[PopUp_Indx].x2 - PopUp[PopUp_Indx].x1      'PopUp[PopUp_Indx].x2 + PopUp[PopUp_Indx].x_offset
            .y1 = .y2 - S_Length    'PopUp[PopUp_Indx].y1 + PopUp[PopUp_Indx].y_offset + 19 'height of MenuBar on PoPup
        else
            .x1 = .x2 - S_Length
            .y1 = .y2 - Scroll_Width
        END IF
        .x_offset = 0
        .y_offset = 0
        .state = Ctrl_Status_Enabled
        .V_Scroll_Pos = 1               'default, at the bottom
        .V_Scroll_Active = True
        .Label = "Scroll_" & Num_Ctrl_Total
       ' .draw_Control 0                'not ready to draw yet.  Gotta set V_Scroll_Len 
    END With
    dprint (21, "Created Scroll.  Ctrl.Indx = " & Num_Ctrl_Total)
    Num_Ctrl_Total = Num_Ctrl_Total +1
Else
    'Scroll bar is being added to a control on an active PopUp 
    Dim as integer C_indx
    C_indx = PopUp[Active_Ctrl.Active_PopUp].Num_Ctrl                   'How many controls on PopUP?
    PopUp[Active_Ctrl.Active_PopUp].Ctrl_Indx(C_indx) = Num_Ctrl_Total  'Set relative index for new PopUp_Ctrl
    With B[Num_Ctrl_Total]     
        .Ctrl_Type = Ctrl_Scroll
        .Scroll_hnd = Active_Ctrl.Indx
        .x2 = xr       
        .y2 = yd     
        if ucase(S_Type) = "V" then
            .x1 = .x2 - Scroll_width        
            .y1 = .y2 - S_Length   
        else
            .x1 = .x2 - S_Length
            .y1 = .y2 - Scroll_Width
        END IF
        .state = Ctrl_Status_Enabled
        .V_Scroll_Pos = 1                   'default, at the bottom
        .Label = "Scroll_" & Num_Ctrl_Total
        '.draw_Control 0        'not ready to draw yet.  Gotta set V_Scroll_Len
        .x_offset = PopUp[Active_Ctrl.Active_PopUp].x1 + PopUp[Active_Ctrl.Active_PopUp].x_offset               'initialize.  These will store mouse drag movements 
        .y_offset = PopUp[Active_Ctrl.Active_PopUp].y1 + PopUp[Active_Ctrl.Active_PopUp].y_offset
    End With
    Num_Ctrl_Total = Num_Ctrl_Total + 1       'bump count
    Num_PopUp_Ctrl = Num_PopUp_Ctrl + 1
end if
END SUB
'
' Generates a PopUP form with TextBoxes for Data Entry.
' Size of PopUp and TextBox automatically adjusts relative to size of label.  If
' default values are specified in FormContent() and Box_Width = 0, then the
' width of TextBox is automatically adjusted to contain the content.  Otherwise
' Box_width <> 0 specifies the width in pixels. Overload is used for +/- FormTitle
'
' Tab key can be used to move between txtbox fields
'
SUB Data_Form (FormLabel() as string, FormContent() as string, _
    byval Box_Width as integer)  
    
    Data_Form_proc (FormLabel(), FormContent(), Box_Width, "")     'call with space string for title
END SUB

SUB Data_Form (FormLabel() as string, FormContent() as string, _
    byval Box_Width as integer, byval FormTitle as string)
    
    Data_Form_proc (FormLabel(), FormContent(), Box_Width, FormTitle)
    
END SUB


SUB Data_Form_proc (FormLabel() as string, FormContent() as string, _
    byval Box_Width as integer, byval FormTitle as string)

DIM as integer FormNum, FormPopUP, MaxLen, LabelLen, BoxWidth = 200, Button_Width, _
    Form_Width, Form_Height, ContentLen, MaxContLen

'Determine number of Label entries, and maximum string length
MaxLen = 0
MaxContLen = 0
Font.FontIndex = MyFont.TxtBox_Indx
For i as integer = 0 to ubound(Formlabel)
    if FormLabel(i) <> "" then 
        FormNum = i + 1
        'LabelLen = gfx.font.getTextWidth(TxtBoxFont, FormLabel(i))
        LabelLen = Font.StringWidth(FormLabel(i))
        IF  LabelLen > MaxLen then MaxLen = LabelLen
        IF len(FormContent(i)) > 0 then
            ContentLen = Font.StringWidth(FormContent(i))
            'ContentLen = gfx.font.getTextWidth(TxtBoxFont, FormContent(i))
        Else
            ContentLen = 50 'default
        end if
        IF ContentLen > MaxContLen then MaxContLen = ContentLen
    end if
next
IF Box_Width = 0 then Box_Width = MaxContLen + 20
Form_Width  = maxlen + Box_Width + 50
Form_Height = FormNum*(TxtBoxFont_size+10) + 70

' Define PopUp
FormPopUP = Num_PopUP_Total
with PopUp[FormPopUP]
        .x1 = 100
        .x2 = .x1 + Form_Width
        .y1 = 100
        .y2 = .y1 + Form_Height
        .x_offset = 0     'default offsets, before any mouse dragging
        .y_offset = 0
        .color = rgb (230,230,230)
        .Title = FormTitle
        .Num_Ctrl = FormNum + 2
        For i as integer = 0 to .Num_Ctrl -1
            .ctrl_indx(i) = Num_Ctrl_Total + i
        next i
        .Exit_Button_Mssg = ""
end with    
Num_PopUp_Total = Num_PopUp_Total + 1

For i as integer = 0 to FormNum -1
WITH B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_TxtBox
    .x1 = MaxLen + 20
    .x2 = .x1 + Box_Width
    .y1 = 30 + i * (TxtBoxFont_Size+10)
    .y2 = .y1 + 25
    .x_offset = 0       'no offsets for controls on Main Form
    .y_offset = 0
    .Label = FormLabel(i)
    .TxtStr = FormContent(i)
    .LabelFont = TxtBoxFont
    .Label_FontSize = Font.TextHeight   'TxtBoxFont_size
    .Label_Len = -1
    .V_Scroll_Enable = FALSE
    .State = Ctrl_Status_hidden
    .Sub_Menu_State(0) = MaxLen+5
    .color = Color_MenuBar
END WITH
Num_Ctrl_Total = Num_Ctrl_Total + 1
Num_PopUp_Temp_Ctrl = Num_PopUp_Temp_Ctrl + 1
next i

' Std Buttons for Form
Font.FontIndex = MyFont.Button_Indx 
'Button_Width = GFX.Font.GetTextWidth (ButtonFont, "Clear") + 20
Button_Width = Font.StringWidth ("Clear") + 20
with B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_Button
    .state = Ctrl_Status_hidden
    .color = rgb (220, 220, 255)
    .label ="Clear"
    .labelFont = ButtonFont
    .LabelFontSel = ButtonFont
    .Label_FontSize = Font.TextHeight    'ButtonFont_size
    '.Label_Len = gfx.font.getTextWidth(ButtonFont, .label)
    .Label_Len = Font.StringWidth(.label)
    .x1 = Form_Width\2 - Button_Width - 10   :.y1 = Form_Height -(.Label_FontSize + 10)
    .x2 = .x1 + Button_Width                 :.Y2 =.y1 + .Label_FontSize + 3
    .x_offset = 0
    .y_offset = 0 
    .CheckState = False     'reset variable to detect button press
End with
Num_Ctrl_Total = Num_Ctrl_Total + 1
Num_PopUP_Temp_Ctrl = Num_PopUP_Temp_Ctrl + 1

with B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_Button
    .state = Ctrl_Status_hidden
    .color = rgb (220, 220, 255)
    .label ="Close"
    .labelFont = ButtonFont
    .LabelFontSel = ButtonFont
    .Label_FontSize = Font.TextHeight  'ButtonFont_size
    '.label_len = gfx.font.getTextWidth(ButtonFont, .label)
    .Label_Len = Font.StringWidth(.Label)
    .x1 = Form_Width\2 + 10  :.y1 = Form_Height-(.Label_FontSize + 10)
    .x2 = .x1 + Button_Width                :.Y2 =.y1 + .Label_FontSize + 3
    .x_offset = 0
    .y_offset = 0 
    .CheckState = False     'reset variable to detect button press
end with
Num_Ctrl_Total = Num_Ctrl_Total + 1
Num_PopUP_Temp_Ctrl = Num_PopUP_Temp_Ctrl + 1

' Render Form
Active_Ctrl.Active_PopUp = FormPopUP
Draw_Pop_UP (Active_Ctrl.Active_PopUp)
Clear_All


' Loop to serve PopUP
DO
    Select Case PollEvent ()
        Case Poll_Null              'no actions
        case Poll_CmdButton_Release 
            IF  Active_Ctrl.Indx > -1 then
                Select case B[Active_Ctrl.Indx].label    
                    case "Close"    'close Cmd_Button for pop-ups
                        With PopUP[Active_Ctrl.Active_PopUP]
                            For i as integer = 0 to FormNum -1
                                FormContent(i) = B[.Ctrl_Indx(i)].TxtStr
                            next i
                        END With    
                        Close_PopUp
                        Num_PopUp_Total = Num_PopUP_Total - 1
                        exit sub 
                    Case "Clear"
                        With PopUP[Active_Ctrl.Active_PopUP]
                            For i as integer = 0 to FormNum -1
                                B[.ctrl_indx(i)].TxtStr = ""
                                B[.Ctrl_Indx(i)].Draw_Control 0
                            next i
                        END With
                END Select
            END IF 
        case Poll_Key_Press
            Select Case Active_Ctrl.Key
                Case FB.SC_Enter
                    With PopUP[Active_Ctrl.Active_PopUP]
                        For i as integer = 0 to FormNum -1
                            FormContent(i) = B[.Ctrl_Indx(i)].TxtStr
                        next i
                    END With 
                    Close_PopUp
                    Num_PopUp_Total = Num_PopUP_Total - 1
                    exit sub
                Case FB.SC_Tab
                    'Was TxtBox terminated by Tab key? (i.e. .Sub_Menu_State(2) = -1
                    DO until B[Active_Ctrl.indx].Sub_Menu_State(2) <> -1 'then  
                        'Is this the last TxtBox on the PopUP Form?
                        IF Active_Ctrl.Indx = PopUP[Active_Ctrl.Active_PopUP].Ctrl_Indx(FormNum-1) then
                            'Yup, reset to first TxtBox on PopUP
                            Active_Ctrl.Indx = PopUP[Active_Ctrl.Active_PopUP].Ctrl_Indx(0)
                        ELSE
                            'Nope, increment
                            Active_Ctrl.indx = Active_Ctrl.Indx + 1
                        END IF
                        B[Active_Ctrl.indx].State = Ctrl_Status_Clicked
                        B[Active_Ctrl.indx].Draw_Control 0
                        'Event_Type = Poll_TxtBox_Press
                        TextBox_Process
                    loop
            END SELECT
        Case Poll_TxtBox_Press
            'Was TxtBox terminated by Tab key? (i.e. .Sub_Menu_State(2) = -1
            DO until B[Active_Ctrl.indx].Sub_Menu_State(2) <> -1 'then  
                'Is this the last TxtBox on the PopUP Form?
                IF Active_Ctrl.Indx = PopUP[Active_Ctrl.Active_PopUP].Ctrl_Indx(FormNum-1) then
                    'Yup, reset to first TxtBox on PopUP
                    Active_Ctrl.Indx = PopUP[Active_Ctrl.Active_PopUP].Ctrl_Indx(0)
                ELSE
                    'Nope, increment
                    Active_Ctrl.indx = Active_Ctrl.Indx + 1
                END IF
                B[Active_Ctrl.indx].State = Ctrl_Status_Clicked
                B[Active_Ctrl.indx].Draw_Control 0
                'Event_Type = Poll_TxtBox_Press
                TextBox_Process
            loop
        Case else
    End Select
    Sleep SleepTime
loop
end sub



'
' Routine to disable all controls (Cmd_Buttons, Menu, TxtBox) except the one titled "label"
' Lable = string containing the label of the control whose state will remain unchanged.
' TotalObjects = number of Buttons + MenuItems
'
' Controls with .state = Ctrl_Status_hidden will NOT be disabled, so these hidden
' controls (usually reserved for PopUp Forms) will not be "enabled" by the inverse
' routine used to re-enable all the controls on the desktop
'
SUB Disable (byval label as string)
For i as integer = 0 to Num_Ctrl_Total-1- Num_PopUP_Temp_Ctrl
    IF B[i].State <> Ctrl_Status_Disabled then
        Temp_Font(i) = B[i].LabelFont              'copy for restore, if not already disabled
    END IF
    if  B[i].label <> label then
        IF B[i].state <> Ctrl_Status_Hidden then 
            B[i].state = Ctrl_Status_Disabled
            IF B[i].Ctrl_Type <> Ctrl_Label AND B[i].Ctrl_Type <> Ctrl_TxtBox then B[i].Labelfont = MenuFontSel
            Active_Ctrl.Indx = i
            B[i].Draw_Control 0
        end if
    end if
next i
END SUB
'
' Launches a new Form, referenced as PopUp[PoPUp_Indx].  By default, a new cmd_button is
' also created to control close/exit from the Form.  Up to 10 controls can be
' added to the Form.  Controls must be previously defined as a Control data type,
' B[Active_Ctrl.Indx].  Coordinates for controls are in absolute screen coordinates,
' not relative to PopUp.
Sub Draw_Pop_UP (byval PopUP_Indx as integer)
dim as integer Temp_Indx, Title_Len
'using ext
'Disable all Controls on Main Form
Disable ""
' This version allows PopUp to over-write any part of screen
SaveVid 
' Alternative version that restricts PopUp to graphics area 
''Protect     'save screen graphics area, for restore
''view screen (dxsmin, dysmin)-(dxsmax, dysmax)   'restrict PopUp to graphics port
Num_PopUp_Ctrl = 0  'reset, no new temporary controls

with PopUp[PopUp_Indx]
    Image_PopUp = imagecreate (.x2-.x1+1, .y2-.y1+1)    'Image buffer for PopUp form
    ' Background
    line Image_PoPUp, (0, 0) - (.x2-.x1, .y2-.y1), .color, bf
    
    ' Border
    For a As Integer = 0 To 9
        Line Image_PopUp, (0, a) - (.x2-.x1, a), Rgb(0, 65+a*5, 240)
        line Image_PopUP, (0, 19-a) - (.x2-.x1, 19-a), Rgb(0, 110, 255)
    Next a
    line Image_PopUp, (0, 0) - (.x2-.X1, .y2-.Y1), Rgb(0,25,207), b
    line Image_PopUp, (1, .1) - (.x2-.X1-1, .y2-.Y1-1), Rgb(22,106,235), b
    
    locate 10,1
    IF Len(.Title) > 0 then
        Font.FontIndex = MyFont.PopUp_Indx
        Font.ForeColor = rgb(255,255,255)
        Font.BackColor = rgba(255,0,255,0)  'mask
        'Title_Len = gfx.font.GetTextWidth(PopUpFont, .Title)
        Title_Len = Font.StringWidth(.Title)
        'draw string Image_PopUp, (((.x2-.x1)-Title_Len)\2, 5), .Title, , PopUpFont, alpha
        Font.DrawString Image_PopUp, .Title, ((.x2-.x1)-Title_Len)\2, 2
    end if
END WIth    

' Create exit button to close PopUp, if requested
IF PopUp[PopUp_Indx].Exit_Button_Mssg <> "" then
    'Create Exit Button for PopUp
    'Draw boarder at bottom
    with PopUp[PopUp_Indx]
        line Image_PopUp, (2, .y2-.y1-25)-(.x2-.x1-2, .y2-.y1-2),Color_Button_Area, bf
    END WIth
    Font.FontIndex = MyFont.Button_Indx
    WITH B[Num_Ctrl_Total]
        .Ctrl_Type = Ctrl_Button
        .Color = Color_Button_Area
        .label = PopUp[PopUp_Indx].Exit_Button_Mssg
        .LabelFont = ButtonFont
        .Label_FontSize = Font.TextHeight
        '.Label_Len = gfx.font.getTextWidth(.LabelFont, .label)
        .Label_Len = Font.StringWidth(.label)
        .state = Ctrl_Status_Enabled
        .x1 = (PopUp[PopUp_Indx].x2-PopUp[PopUp_Indx].x1-.Label_Len - 20)\2  'need to adjust label_len
        .y1 = PopUp[PopUp_Indx].y2-PopUp[PopUp_Indx].y1-23
        .x2 =  .x1 + .Label_len+20
        .y2 =  .y1+ Font.TextHeight + 6
        .x_offset = 0
        .y_offset = 0
        'Draw on Image_Buffer with offets initially set to 0
        .Draw_Control Image_PoPUp
        'Set offsets to account for PopUP initial positions (.x1, .y1) and any mouse dragging
        .x_offset = PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset
        .y_offset = PopUp[PopUp_Indx].y1 + PopUp[PopUp_Indx].y_offset
    END WITH
    Num_Ctrl_Total = Num_Ctrl_Total + 1       'bump count
    Num_PopUp_Ctrl = Num_PopUp_Ctrl + 1
END IF
' Define MenuBar on PopUp as pseudo-control, for dragging PopUp with mouse
With B[Num_Ctrl_Total]
    .Ctrl_Type = Ctrl_PopUp
    .x1 = 0     'PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset  'default, start where PopUp originates
    .x2 = PopUp[PopUp_Indx].x2 - PopUp[PopUp_Indx].x1      'PopUp[PopUp_Indx].x2 + PopUp[PopUp_Indx].x_offset
    .y1 = 0     'PopUp[PopUp_Indx].y1 + PopUp[PopUp_Indx].y_offset
    .y2 = 19      'PopUp[PopUp_Indx].y1 + PopUp[PopUp_Indx].y_offset + 19 'height of MenuBar on PoPup
    .x_offset = PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset               'initialize.  These will store mouse drag movements 
    .y_offset = PopUp[PopUp_Indx].y1 + PopUp[PopUp_Indx].y_offset
    .state = Ctrl_Status_Enabled
END WIth
Num_Ctrl_Total = Num_Ctrl_Total + 1       'bump count
Num_PopUp_Ctrl = Num_PopUp_Ctrl + 1

IF PopUp_Fade then
    dim as integer Alpha_Level = 0  'Transparency fade-in for pop-up
    DO
        put (PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset, PopUp[PopUp_Indx].y1+PopUp[PopUp_Indx].y_offset),Image_PoPup, Alpha, Alpha_Level  'pset
        Alpha_Level = Alpha_Level + 1
        sleep 15
    Loop until Alpha_Level = 22     'After 22-times, cumulative PUT has alpha of 253
END IF
put (PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset, PopUp[PopUp_Indx].y1+PopUp[PopUp_Indx].y_offset),Image_PoPup, pset
'Activate previously defined Controls for PopUP
Temp_Indx = Active_Ctrl.Indx    'temporary store
With PopUp[PopUp_Indx]      
    IF .Num_Ctrl > 0 then 
        for i as integer = 0 to .Num_Ctrl-1
            IF B[.Ctrl_Indx(i)].state <> ctrl_Status_Disabled then
                B[.Ctrl_Indx(i)].state = Ctrl_Status_Enabled
            END if
            'Now define offset for PopUp initial position and mouse movement
            B[.Ctrl_Indx(i)].x_offset = .x1 + .x_offset
            B[.Ctrl_Indx(i)].y_offset = .y1 + .y_offset
            Active_Ctrl.Indx = .Ctrl_Indx(i)        'temporarily reset Active_Ctrl for Draw routines
            B[.Ctrl_Indx(i)].draw_Control 0
        next i
    END IF
Active_Ctrl.Indx = Temp_Indx
END with

'put (PopUp[PopUp_Indx].x1 + PopUp[PopUp_Indx].x_offset, PopUp[PopUp_Indx].y1+PopUp[PopUp_Indx].y_offset),Image_PoPup, pset

view
end sub

'
'
SUB Draw_Scroll
    Dim as integer indx
    indx = B[Active_Ctrl.indx].Scroll_hnd                   'get Ctrl.indx for Scroll Bar
    with B[indx]
        .V_Scroll_Pos = B[Active_Ctrl.indx].V_Scroll_Pos    'transfer info from parent ctrl to scroll ctrl
        .draw_Control 0
    end with
END SUB

' Wrapper for xFont routines that will parse Text string containing font control characters
'
SUB DrawString_Custom (byval target as any ptr, byval x as integer, byval y as integer, _
    byval Text as string, _
    byval FontName as string, _
    byval Fore_Color as uinteger, _
    byval Back_Color as uinteger, _
    byval Rotation as integer)

DrawString_Xfont (target, x, y,Text, FontName, Fore_Color, Back_Color, Rotation)

end sub

SUB DrawString_Custom (byval x as integer, byval y as integer, _
    byval Text as string, _
    byval FontName as string, _
    byval Fore_Color as uinteger, _
    byval Back_Color as uinteger, _
    byval Rotation as integer)
    
DrawString_Xfont (0, x, y,Text, FontName, Fore_Color, Back_Color, Rotation)
    
END SUB

SUB DrawString_Xfont (byval target as any ptr, byval x as integer, byval y as integer, _
    byval Text as string, _
    byval FontName as string, _
    byval Fore_Color as uinteger, _
    byval Back_Color as uinteger, _
    byval Rotation as integer)

DIM as string TempStr, NxtChr, FontName_Modified
Dim as byte ModFlg = FALSE, SlashFlg = FALSE
DIM as integer dpos = 0   'position-offset for substrings

Font.unloadfont(1)                  'unload any pre-existing font
IF font.loadfont (Font_Path & FontName,1) then
    IF Font.LoadFont(CurDir & "\" & FontName,1) then
        
        locate 10,1
        print "Font_Path: " & Font_Path
        print "CurDir:    " & CurDir 
        
        Mssg_Box "LoadFont Error. " & FontName & " not found", "Error"
    END IF
end if

font.fontindex = 1
font.forecolor = Fore_Color
font.backcolor = Back_Color

IF InStr(Text, "\") = 0 then
    font.drawstring(target,Text, x, y,,,Rotation)     'no special font changes
ELSE
    TempStr = ""
    For i as integer = 0 to Len(Text)-1
            NxtChr = mid(text, i+1,1)
            IF NxtChr = "(" AND SlashFlg = TRUE then 
                ModFlg = True       'beginning of substring for special font
                SlashFlg = FALSE
            ELSEIF NxtChr = ")" AND ModFlg = TRUE then
                ModFLg = False      'end of substring for special font
                IF Rotation then
                    font.drawstring(target,TempStr, x, y-dpos,,,Rotation)
                Else
                    font.drawstring(target,TempStr, x+dpos, y,,,Rotation)  'Print substring
                end if
                dpos += Font.StringWidth(TempStr)
                Font.FontIndex = 1                          'return to original font
                TempStr = ""                                'Reset substring
            ElseIF NxtChr <> "\" then
                IF SlashFlg = FALSE then
                    TempStr += NxtChr           'append next char
                ELSE
                    Select case UCASE(NxtChr)   'serve control char
                    Case "G"                    'Greek = Symbol Font
                        FontName_Modified = "Symb" & Font.TextSize & ".xf"
                    Case "B"                    'Bold
                        FontName_Modified = mid(FontName,1 ,Len(FontName)-3) + "B.xf"
                    Case "I"                    'Italic
                        FontName_Modified = mid(FontName,1, Len(FontName)-3) + "I.xf"
                    'Case "U"                    'Underline
                    '    FontName_Modified = mid(FontName,1, Len(FontName)-3) + "U.xf"
                    Case Else                   'undefined / illegal
                        'Print TempStr thus far and abort
                        IF Rotation then
                            font.drawstring(target,TempStr, x, y-dpos,,,Rotation)
                        Else
                            font.drawstring(target,TempStr, x+dpos, y,,,Rotation)  'Print substring
                        end if
                        Mssg_Box "Text string truncated. Delimiter ""\"" error", "Error"
                        exit sub
                    END SELECT
                    'Print TempStr thus far with main font
                    IF Rotation then
                            font.drawstring(target,TempStr, x, y-dpos,,,Rotation)
                        Else
                            font.drawstring(target,TempStr, x+dpos, y,,,Rotation)  'Print substring
                    end if
                    dpos += Font.StringWidth(TempStr)
                    TempStr = ""        'reset TempStr
                    'SlashFlg = FALSE    'reset flag
                    'load new special font
                    Font.UnloadFont(2)
                    IF font.loadfont (Font_Path & FontName_Modified,2) then
                        IF font.loadfont (Curdir & "\" & FontName_Modified,2) then
                            Mssg_Box "LoadFont Error. " & FontName_modified & " not found", "Error"
                        END IF
                    END if
                    Font.FontIndex = 2          
                END IF
            else
                IF SlashFlg = FALSE then
                    SlashFlg = TRUE
                ELSE
                    TempStr += NxtChr   'more than one "\".  So add "\" as a valid Char
                    SlashFlg = FALSE    'reset flag.  Slashes must be used in pairs to add "\" to string
                end if
            end if
    next i
    'If any remaining text, and not in middle of special font substring, then show
    If LEN(TempStr) > 0 and ModFlg = FALSE then 
        IF Rotation then
            font.drawstring(target,TempStr, x, y-dpos,,,Rotation)
        Else
            font.drawstring(target,TempStr, x+dpos, y,,,Rotation)  'Print substring
        end if
    end if
    'Reset FontIndex 2, which is the loaded font for Command Button
    Font.UnloadFont(2)
    IF Font.loadfont (Curdir & "\" & MyFont.Button, MyFont.Button_Indx)    then 
        IF Font.loadfont (Font_Path & MyFont.Button, MyFont.Button_Indx) then
            print "Unable to find font: " & MyFont.Button
        END IF
    end if
END IF

end sub




'
' Enable all controls (Cmmd_Buttons, Drop_Down Menus, TxtBoxes), that are not Hidden. 
'
SUB Enable_Controls ()
Dim as integer Temp_indx
Temp_indx = Active_Ctrl.indx    'temp store
For i as integer = 0 to Num_Ctrl_Total-1
    IF Temp_Font(i) <> 0 then B[i].LabelFont = Temp_Font(i)
    IF B[i].State <> Ctrl_Status_Hidden then     
        B[i].State = Ctrl_Status_Enabled
        Active_Ctrl.indx = i    'assign, in case Draw_Control launches create_scroll
        B[i].Draw_Control 0
    END IF
Active_Ctrl.Indx = Temp_indx    'reset
Next i
END SUB


'
' Alternative to XOR for changing white bckgnd to blue and black text to white,
' or vice versa.  Seems to work on gray scale too... but not for all colors
'
SUB Hi_Light (byval x as integer, byval y as integer, byval wid as integer, _
    byval hgt as integer, byval dirn as byte) 
Dim as uinteger c, newval
IF dirn then    'to blue bckgnd, white foreground
    for iy as integer = y to y + hgt 
        For ix as integer = x To  x + wid
            c = Point(ix,iy)
            newval = ((c And 255) Shl 24) Or ((c And &h00ffff00) Xor &hffff00) Or 255
            Pset (ix,iy),newval
         Next
    next
Else          'back to black text on white bckgnd.
    For iy as integer = y To y + hgt
        For ix as integer = x To x + wid
            c = Point(ix,iy)
            newval = ((c And &h00ffff00) Xor &hffff00) Or (c Shr 24)
            Pset (ix,iy),newval
        Next
    Next
end if
    
END SUB


'
' PopUp Hint.  The text Prompt is scanned for CRLF to indicate new line
' Hint remains visible until mouse_move, key_press, or 5 secs
'
' Went a bit overboard with the shading for the boarder... could have been much easier
'
SUB Hint (byval Prompt as string, byval x as integer, byval y as integer)
DIM as uinteger p_color
DIM as integer r, g, b, delta
DIM as integer hheight, hwidth, NumLine, Str_Len, ChrLoc
DIM as single scale(4), corner_matrix(4,4)
DIM as String TxtStr(20)
' Process Prompt to determine optimal width and height
'Find longest line of text
'Using EXT
Font.FontIndex = MyFont.TxtBox_Indx
For i as integer = 0 to 20: TxtStr(i) = "": next i
hwidth = 0
NumLine = 0
ChrLoc = 1
do
    Select case mid(Prompt,ChrLoc,1)
    Case CHR(10)    'LF
        if len(TxtStr(NumLine)) > 0 then
            'Str_Len = gfx.font.getTextWidth(TxtBoxFont, TxtStr(NumLine))
            Str_Len = Font.StringWidth (TxtStr(NumLine))
            if Str_Len > hwidth then hwidth = Str_Len
            NumLine=NumLine+1
        END IF
    Case CHR(13)    'CR
    Case Else
        TxtStr(NumLine) = TxtStr(NumLine) & mid(Prompt,ChrLoc,1)
    END SELECT
    ChrLoc = ChrLoc + 1
loop until ChrLoc > LEN(prompt) or NumLine = 20
'Complete analysis of final line
if len(TxtStr(NumLine)) > 0 then
    'Str_Len = gfx.font.getTextWidth(TxtBoxFont, TxtStr(NumLine))
    Str_Len = Font.StringWidth (TxtStr(NumLine))
    if Str_Len > hwidth then hwidth = Str_Len
    NumLine = NumLine + 1
END IF


hwidth = hwidth + 16
'hheight = TxtBoxFont_Size*NumLine + 10
hheight = Font.TextHeight*NumLine + 10

' Create sprite
Image_Temp = imagecreate (hwidth + 5, hheight + 5)    'Image buffer for PopUp Hint
Image_Restore = imagecreate (hwidth + 5, hheight + 5) 'Image buffer for restore
View
Window
Get (x,y)-(x+hwidth+4, y+hheight+4), Image_Restore   'Store a copy for refresh
Get (x,y)-(x+hwidth+4, y+hheight+4), Image_Temp       'Get another copy to manipulate as sprite

' Define filter for scaling RGB in shells
Scale(1) = .95
Scale(2) = .83
Scale(3) = .67
Scale(4) = .56
corner_matrix(1,1) = .61:   corner_matrix(1,2)= 0.71:   corner_matrix(1,3) = 0.85:  corner_matrix(1,4) = 0.95   
corner_matrix(2,1) = .71:   corner_matrix(2,2)= 0.78:   corner_matrix(2,3) = 0.89:  corner_matrix(2,4) = 0.96   
corner_matrix(3,1) = .85:   corner_matrix(3,2)= 0.89:   corner_matrix(3,3) = 0.95:  corner_matrix(3,4) = 0.98   
corner_matrix(4,1) = .95:   corner_matrix(4,2)= 0.96:   corner_matrix(4,3) = 0.98:  corner_matrix(4,4) = 0.99   
' Scale RGB channels to create shaddow as 4 shells, starting from bottom right
For j as integer = 1 to 4 
    For i as integer = 9 to hwidth                      'row
        'Get 32-bit RGB color
        p_color = point(i,hheight+5-j,Image_Temp)
        'Filter RBG channels
        R = ((p_color Shr 16) And &h000000FF)*scale(j)
        G = ((p_color Shr 8) And &h000000FF)*scale(j)
        B = (p_color And &h000000FF)*scale(j)
        pset Image_Temp,(i,hheight+5-j),RGB (R, G, B)
    Next i
    For i as integer = 9 to hheight                     'column
        'Get 32-bit RGB color
        p_color = point(hwidth+5-j,i,Image_Temp)
        'Filter RBG channels
        R = ((p_color Shr 16) And &h000000FF)*scale(j)
        G = ((p_color Shr 8) And &h000000FF)*scale(j)
        B = (p_color And &h000000FF)*scale(j)
        pset Image_Temp,(hwidth+5-j,i),RGB (R, G, B)
    Next i
Next j
' Blends at the corners
' Bottom right
For i as integer = 1 to 4
    for j as integer = 1 to 4
        'Get 32-bit RGB color
        p_color = point(i+hwidth,hheight+j,Image_Temp)
        'Filter RBG channels
        R = ((p_color Shr 16) And &h000000FF)*corner_matrix(i,j)
        G = ((p_color Shr 8)  And &h000000FF)*corner_matrix(i,j)
        B = (p_color          And &h000000FF)*corner_matrix(i,j)
        pset Image_Temp,(i+hwidth,hheight+j),RGB (R, G, B)    
    next j
next i
' Top right
For i as integer = 1 to 4
    for j as integer = 1 to 4
        'Get 32-bit RGB color
        p_color = point(i+hwidth,4+j,Image_Temp)
        'Filter RBG channels
        R = ((p_color Shr 16) And &h000000FF)*corner_matrix(i,5-j)
        G = ((p_color Shr 8)  And &h000000FF)*corner_matrix(i,5-j)
        B = (p_color          And &h000000FF)*corner_matrix(i,5-j)
        pset Image_Temp,(i+hwidth,4+j),RGB (R, G, B)    
    next j
next i
'Bottom left
For i as integer = 1 to 4
    for j as integer = 1 to 4
        'Get 32-bit RGB color
        p_color = point(i+4,hheight+j,Image_Temp)
        'Filter RBG channels
        R = ((p_color Shr 16) And &h000000FF)*corner_matrix(5-i,j)
        G = ((p_color Shr 8)  And &h000000FF)*corner_matrix(5-i,j)
        B = (p_color          And &h000000FF)*corner_matrix(5-i,j)
        pset Image_Temp,(i+4,hheight+j),RGB (R, G, B)    
    next j
next i

' Fill the center
    line Image_Temp,(0,0)-(hwidth, hheight),rgb(255,255,225),BF
    line Image_Temp,(0,0)-(hwidth, hheight),rgb(0,0,0),B

' Print text
    For i as integer = 0 to NumLine-1
        'draw string Image_Temp, (5 , 5+ i*TxtBoxFont_Size), TxtStr(i),,TxtBoxFont,alpha
        Font.Drawstring Image_Temp, TxtStr(i), x, 5 + i * Font.TextHeight 
    next i  
    
' Show hint
    put (x,y), Image_Temp, pset

' Wait for mouse, keybd action, or 5 sec, then kill hint
dim as integer mx,my
dim as double TimeNow
Mouse_Update
do: loop until inkey = ""   'clear keybd buffer
TimeNow = Timer
do
    getmouse mx,my,b
loop until abs(mx-mouse_now.x) > 20 or abs(my-mouse_now.y) > 20 or inkey <> "" or Timer-TimeNow >5
sleep 500   'minimum 0.5 sec display
put (x,y), Image_Restore, pset
ImageDestroy (Image_Restore)

END SUB
'
'  Remove a control from the list of defined gadgets
'
SUB Kill_Ctrl (byref lbl as string)
DIM as integer i, indx
    'Find Ctrl, according to unique label (starting from last to first)
    indx = -1
    For i = Num_Ctrl_Total-1 to 0 step -1
        If B[i].label = lbl then indx = i
    next i
    If indx < 0 then
        Mssg_box "Control not found. " & lbl, "Error in: Kill_Ctrl"
        exit sub
    end if
    'Shift/Over_write
    If Indx < Num_Ctrl_Total-1 then
        For i = indx to Num_Ctrl_Total -2
            B[i] = B[i+1]
            'Check for reference "by" or "to" slider
            If B[i].Scroll_Hnd <> 0 then 
                B[B[i].Scroll_Hnd].Scroll_Hnd = i 'reset reference to Handle
            end if
        next
    Elseif Indx = Num_Ctrl_Total -1 then
        'If it was the last Ctrl, then just kill, no shift
        B[Indx].Ctrl_Type = Ctrl_Null
        B[Indx].State = Ctrl_Status_Hidden
    END IF
    'Reduce count for number of Ctrls
    Num_Ctrl_Total = Num_Ctrl_Total - 1
end sub
'
' Kill PopUp
'
SUB Kill_PopUp (byref indx as integer)
    If (Indx < 0) or (Indx > Max_PopUp) then
        Mssg_box "Illegal index for PopUp: " & indx, "Error in: Kill_PopUp"
        exit sub
    end if
    'Shift / Over-write
    If Indx < Num_PopUp_Total-1 then
        For i as integer = indx to Num_PopUp_Total -2
            PopUp[i] = PopUp[i+1]
        next
        PopUp[Num_PopUP_Total-1].Temp_Flg = FALSE   'force default
    Else
        PopUp[indx].Num_Ctrl = 0
        PopUp[indx].Title = ""
        PopUp[indx].Temp_Flg = FALSE
    end if
    Num_PopUP_Total = Num_PopUp_Total - 1
end sub

' Draw button for listbox
' State 0 -> not pressed,  State 1 -> mouse press
'
SUB ListBox_Button (byval x as integer, byval y as integer, byval state as byte)
IF State = False then
'Unpressed arrow
    'outline
    line (x,y) - step (16,16), rgb(236,233,216), BF
    line (x,y) - step (16, 0), rgb(241, 239, 226)
    line (x,y) - step (0, 15), rgb(241, 239, 226)
    line (x,y+16) - step (16, 0), rgb(113, 111, 100)
    Line (x+16, y+16)- step (0, -16), rgb(113, 111, 100)
    line (x+1, y+1) - step (0, 14), rgb(255,255,255)
    line (x+1, y+1) - step (14, 0), rgb(255,255,255)
    line (x+1, y+15) - step (14, 0), rgb(172, 168, 153)
    line (x+15,y+15) - step (0, -14), rgb(172, 168, 152)
    'arrow
    line (x+5, y+7) - step (6,0), rgb(0,0,0)
    line (x+6, y+8) - step (4,0), rgb(0,0,0)
    Line (x+7, y+9) - step (2,0), rgb(0,0,0)
    pset (x+8,y+10), rgb(0,0,0)
Else
'Pressed arrow
    'outline
    line (x, y) - step (16,16), rgb(172,160,153), B
    line (x+1,y+1) - step(14,14), rgb(236,233,216), BF
    'arrow
    line (x+6, y+8) - step (6,0), rgb(0,0,0)
    line (x+7, y+9) - step (4,0), rgb(0,0,0)
    Line (x+8, y+10) - step (2,0), rgb(0,0,0)
    pset (x+9,y+11), rgb(0,0,0)
END IF
end sub

'
' Routine to process an active ListBox menu
' Stores a copy of menu_select in .slider_pos, so that upon repeat call the prior choice is available 
' as default
'
SUB ListBox_Process ()
Dim as integer MenuSelect_New, xl, xr, yu, yd

Font.FontIndex = MyFont.Menu_Indx
Font.BackColor = rgb(255,255,255)
Font.ForeColor = rgb(0,0,0)

With B[Active_Ctrl.Indx]

Active_Ctrl.Menu_Select = .slider_pos   'reset default to prior value 
Active_Ctrl.Active_Menu = Active_Ctrl.Indx
.CheckState = FALSE                     'reset flag that drop_down item has been selected

' Offset variable are for controls on PopUp Form, which may be dragged/moved
xl = .x1 + .x_offset
xr = .x2 + .x_offset
yu = .y1 + .y_offset
yd = .y2 + .y_offset


'Create drop_down Menu sprite.  All coordinates are local for this part, offest irrelevant   
    .Menu_Image = ImageCreate (.x2-.x1+1, ListBox_Hgt * .Sub_Menu_Num + 5)
    Paint .Menu_Image, (10,10), RGB(255,255,255)                             'background
    Line  .Menu_Image, (0,0) - (.x2-.x1, ListBox_Hgt * .Sub_Menu_Num+4), RGB(0,0,0), B    'boarder
    For i as integer = 0 to .Sub_Menu_Num-1
        'draw string .Menu_Image, (4, i*ListBox_Hgt + 6), .Sub_Menu_Label(i), , MenuFont, alpha 
        Font.DrawString .Menu_Image, .Sub_Menu_Label(i), 4, i*ListBox_Hgt+6
    next 

' Save screen for restore and show menu
    ImageDestroy Image_MenuSave
    Image_MenuSave = ImageCreate (.x2-.x1+1, ListBox_Hgt * (.Sub_Menu_Num+1) + 10)
    get (xl,yu+ListBox_Hgt+1) - step(.x2-.x1, ListBox_Hgt* .Sub_Menu_Num+9), Image_MenuSave
    put (xl,yu+ListBox_Hgt+1), .Menu_Image, pset

' Generate Mask for XOR with mouse_over menu
    ImageDestroy Image_MenuMask
    Image_MenuMask = ImageCreate (.x2-.x1-3, ListBox_Hgt)
    Paint image_MenuMask, (10,10), rgb(20,20,0)

' Show default selection from prior choice, using mask
    put (xl+2, yu+ListBox_Hgt+1+ Active_Ctrl.Menu_Select*ListBox_Hgt),Image_MenuMask , xor

' Wait for mouse release
    Do
        Mouse_Update
    loop until Mouse_Now.b = 0
    
' Reset ListBox button
    ListBox_Button (xr-(ListBox_Hgt-2), yu+2, FALSE)   'show button, not pressed

' Poll for mouse events  ?add keyboard later
DO
    Mouse_Update
    if (mouse_now.x > xl and mouse_now.x < xr) and (mouse_now.y > yu and _
        mouse_now.y < yd + ListBox_Hgt*.Sub_Menu_Num) then 
        IF mouse_Now.b  then
            Put (xl,yu+ListBox_Hgt+1), Image_MenuSave, pset
            line (xl+2, yu+2) - step(xr-xl-21, ListBox_Hgt-4), RGB(255,255,255), BF
            'draw string (xl+4, yu+6), .Sub_Menu_Label(Active_Ctrl.Menu_Select), , MenuFont, alpha
            Font.DrawString 0, .Sub_Menu_Label(Active_Ctrl.Menu_Select), xl+4, yu+2
            .slider_pos = Active_Ctrl.Menu_Select   'store to use as default with repeat call 
            .CheckState = TRUE
            Exit Do
        end if
        if Mouse_prev.x <> Mouse_now.x or mouse_prev.y <> mouse_now.y then
            MenuSelect_New = int((mouse_now.y - yu)/ListBox_Hgt - 1)
            If MenuSelect_New <> Active_Ctrl.Menu_Select and MenuSelect_New > -1 then
                put (xl+2, yu+ListBox_Hgt+1+ Active_Ctrl.Menu_Select*ListBox_Hgt),Image_MenuMask , xor  'erase former
                Active_Ctrl.Menu_Select = MenuSelect_New      're-assign
                put (xl+2, yu+ListBox_Hgt+1+ Active_Ctrl.Menu_Select*ListBox_Hgt),Image_MenuMask , xor  'show new
            end if
        end if
    ELSE
        IF Mouse_now.b then     'click off menu, cancel
            Active_Ctrl.Menu_Select = .slider_pos           'rest to default
            Put (xl,yu+ListBox_Hgt+1), Image_MenuSave, pset
            line (xl+2, yu+2)-step(xr-xl-21, ListBox_Hgt-4), RGB(255,255,255), BF
            'draw string (xl+4, yu+6), .Sub_Menu_Label(.Slider_pos), , MenuFont, alpha
            Font.DrawString 0, .Sub_Menu_Label(.Slider_pos), xl+4, yu+2
            Exit Do
        end if
    end if
    Sleep SleepTime 'give some time back to CPU
loop
Active_Ctrl.Active_Menu = -1    'menu no longer active
end with

' Wait for mouse release
    Do
        Mouse_Update
    loop until Mouse_Now.b = 0
    ClearEvents     'clear polling
    Active_Ctrl.indx = -1   'reset, but leave Active_Ctrl.Active_Menu and Active_Ctrl.Menu_Select for server
end sub
'
'
' Event_Handler while dropdown menu is active.
'
SUB Menu_Process()
DIM as integer MenuWidth, MenuHeight, TempSelect 
DIM as byte redoflg = FALSE

Start:
With B[Active_Ctrl.Active_Menu]

' Check if SubMenu Items exist
    If B[Active_Ctrl.Active_Menu].Sub_Menu_Num = 0 then    'degenerate case, no submenu items
        Active_Ctrl.Active_Menu = Active_Ctrl.Indx
        Active_Ctrl.Menu_select = 0     'default, set Menu_Select to pseudo first item
       'Redraw MenuBar to show item as Enabled, not GotFocus
        B[Active_Ctrl.Active_Menu].state = Ctrl_Status_Enabled
        B[Active_Ctrl.Active_Menu].Draw_Control 0
        'jump to Serve_PullDownMenu as though submenu already selected
         
        Exit SUB
    END IF
    If B[Active_Ctrl.Active_Menu].Sub_Menu_Num > Max_Menu then    'Test for error, too many submenu items
        Mssg_Box "Error! Too many items in submenu", "Menu_Process Error"
        Exit SUB
    end if

' New dropdown menu, with submenus
    'Generate sprite for dropdown menu
    UpDate_Menu Active_Ctrl.Active_Menu             'generate new drop_down menu
    
    'Show dropdown menu (also saves screen image for restore)
    B[Active_Ctrl.Active_Menu].Draw_Control 0          
    
    'Create mask to XOR highlight bar over dropdown submenu items
    ImageInfo .Menu_Image, MenuWidth, MenuHeight
    Image_MenuMask = imageCreate (MenuWidth-12,MenuRowHeight)
    line image_MenuMask, (0,0)-(MenuWidth-12,MenuRowHeight), rgb(20,20,0), bf
    
    'Reset Selection
    Active_Ctrl.Menu_Select = -1               

' Serve events while dropdown menu is showing
' Wait for mouse release
    Do
        Mouse_Update
    loop until Mouse_Now.b = 0
    
' Poll for mouse events  ?add keyboard later
DO
    Mouse_Update    'check mouse
    'Test if mouse is over dropdown Menu
    if (mouse_now.x > .x1 + .x_offset and mouse_now.x < .x1 + .x_offset + MenuWidth-12) _
        and (mouse_now.y > Menu_Bar_Height + 4) and (mouse_now.y < Menu_Bar_Height+ 4 + MenuHeight-15) then
 
        'Convert to MenuSelect coordinates
        'Highlight bar is shifted downward by 0.35*MenuRowHeight
        TempSelect = int((mouse_now.y-(Menu_Bar_Height+4)-.35*MenuRowHeight)/MenuRowHeight)
        If TempSelect < 0 then TempSelect = 0
        
        'If moved on to a new submenu, then shift highlight bar
        If TempSelect <> Active_Ctrl.Menu_Select then
            Screenlock  'suppress screen flicker
            'Check for prior highlighted MenuSelect. If yes, then erase select highlight
            If Active_Ctrl.Menu_Select <> -1 then   
                put (.x1+4+.x_offset, (Active_Ctrl.Menu_Select+.35)*MenuRowHeight + Menu_Bar_Height+4), image_MenuMask, xor  
            End IF
            'Define new active Menu_Select
            Active_Ctrl.Menu_select = TempSelect
            put (.x1+4+.x_offset, (Active_Ctrl.Menu_Select+.35)*MenuRowHeight + Menu_Bar_Height+4), image_MenuMask, xor
            screenunlock
        End if  
        
        'If mouse clicked and SubMenu state is Enabled, then make selection
        IF mouse_Now.b  And (.Sub_Menu_State(TempSelect) AND Enabled) = Enabled then
            Active_Ctrl.Menu_Select = TempSelect
            'Erase drop_down
            put (B[Active_Ctrl.Active_Menu].x1, Menu_Bar_Height+4),Image_MenuSave, pset     
            'Refresh MenuBar
            B[Active_Ctrl.Active_Menu].state = Ctrl_Status_Enabled      'Deactivate any active menu
            B[Active_Ctrl.Active_Menu].Draw_Control 0                   'draw
            TempSelect = Active_Ctrl.Menu_select        'Kludge, save a copy
            
            'wait until mouse button released (otherwise Ctrl under drop_down may be clicked)
            Do
                Mouse_Update
            Loop Until Mouse_Now.b = 0
            
            Exit Do
        end if
        
    else        'nope, not over dropdowm menu
        'If mouse click off menu, then exit, no selection
        IF Mouse_now.b then
            TempSelect = WhichCtrl
            IF TempSelect <> -1 then
                'Did user click on another menu bar item?
                If B[TempSelect].Ctrl_Type = Ctrl_Menu then
                    'Erase drop_down
                    put (B[Active_Ctrl.Active_Menu].x1, Menu_Bar_Height+4),Image_MenuSave, pset     
                    'Refresh MenuBar
                    B[Active_Ctrl.Active_Menu].state = Ctrl_Status_Enabled      'Deactivate any active menu
                    B[Active_Ctrl.Active_Menu].Draw_Control 0                   'draw 
                    'Shift Active_Ctrl to new Menu Item
                    Active_Ctrl.Indx = TempSelect
                    B[Active_Ctrl.Indx].state = Ctrl_Status_Clicked 
                    Active_Ctrl.Active_Menu = Active_Ctrl.Indx
                    Active_Ctrl.Ctrl_type = B[Active_Ctrl.Indx].Ctrl_type
                    'Menu_Process()  'start over
                    Goto Start:
                end if
            END IF
            Active_Ctrl.Menu_Select = -1    'nothing selected
            'Erase drop_down
            put (B[Active_Ctrl.Active_Menu].x1, Menu_Bar_Height+4),Image_MenuSave, pset     
            'Refresh MenuBar
            B[Active_Ctrl.Active_Menu].state = Ctrl_Status_Enabled      'Deactivate any active menu
            B[Active_Ctrl.Active_Menu].Draw_Control 0                   'draw
            Exit Do
        end if
        
        ' moved off dropdwon menu, erase last highlight
        If (Active_Ctrl.Menu_select <> -1) Then
            put (.x1+4+.x_offset, (Active_Ctrl.Menu_Select+.35)*MenuRowHeight + Menu_Bar_Height+4), image_MenuMask, xor       'erase
            Active_Ctrl.Menu_select = -1            'no menu item selected
        end if
    end if
    Sleep SleepTime 'give some time back to CPU
loop    
end with

' This is a Klduge to compensate for recursive call to Menu_process that wipe out Active_Ctrl.Menu_select
' This weirdness happens only if Menu_Bar click occurs while drop_down is active.
'IF Active_Ctrl.Menu_Select <> TempSelect then Active_Ctrl.Menu_Select = TempSelect
'print "At Exit from Menu_Process, Menu selection: " & Active_Ctrl.Menu_select
'print "Temp Select: " & TempSelect

end sub

'
' Routine to update menu drop-down menu and submenu highlight
' for entry with a toggle
'SUB Menu_Toggle()
'    B[Active_Ctrl.Active_Menu].state = Ctrl_Status_Clicked 
'    Menu_Process() 'go back to menu
'    Serve_PulldownMenu
'end sub

' Handler for Mouse_R_Press_PopUp
'
SUB Mouse_PopUp_Process
Dim as integer xl, xr, yu, MenuSelect_New, x_width = 0 
Font.FontIndex = MyFont.Menu_Indx
Font.ForeColor = Color_MenuTxt
Font.BackCOlor = RGB(255,255,255)
With B[Active_Ctrl.Indx]
    
    ' Auto-select width.
    For i as integer = 0 to .Sub_Menu_Num -1
        'xr = gfx.font.gettextwidth(MenuFont, .Sub_Menu_Label(i))
        xr = Font.StringWidth(.Sub_Menu_Label(i))
        IF xr > x_width then x_width = xr
    next
    xl = Mouse_now.x
    yu = Mouse_now.y
    xr = xl + x_width + 8
    
    ' Test for crashing off right side of view port
    IF xr > dxsmax then
        xr = xl
        xl = xr - x_width - 8
    end if
    If yu + ListBox_Hgt * .Sub_Menu_Num > dysmax then
        yu = yu - ListBox_Hgt * .Sub_Menu_Num
    end if

    'Create Pop_up Menu sprite.  All coordinates are local (sprite) for this part  
    .Menu_Image = ImageCreate (xr-xl+1, ListBox_Hgt * .Sub_Menu_Num )
    Paint .Menu_Image, (10,10), RGB(255,255,255)                             'background
    Line  .Menu_Image, (0,0) - (xr-xl, ListBox_Hgt * .Sub_Menu_Num -1), RGB(0,0,0), B    'boarder
    For i as integer = 0 to .Sub_Menu_Num-1
        'draw string .Menu_Image, (4, i*ListBox_Hgt + 6), .Sub_Menu_Label(i), , MenuFont, alpha 
        IF .Sub_Menu_State(i) AND Enabled = Enabled then
            Font.DrawString .Menu_Image, .Sub_Menu_Label(i), 4, i*ListBox_Hgt + 4
        Else
            Font.ForeColor = RGB(190,190,190)
            Font.DrawString .Menu_Image, .Sub_Menu_Label(i), 4, i*ListBox_Hgt + 4
            Font.ForeColor = Color_MenuTxt
        END IF
    next 

    ' Save screen for restore and show menu
    ImageDestroy Image_MenuSave
    Image_MenuSave = ImageCreate (xr-xl+1, ListBox_Hgt * (.Sub_Menu_Num) + 1)
    get (xl,yu+1) - step(xr-xl, ListBox_Hgt * .Sub_Menu_Num), Image_MenuSave
    put (xl,yu+1), .Menu_Image, pset

    ' Generate Mask for XOR with mouse_over menu
    ImageDestroy Image_MenuMask
    Image_MenuMask = ImageCreate (xr-xl-3, ListBox_Hgt)
    Paint image_MenuMask, (10,10), rgb(20,20,0)

    ' Wait for mouse release
    Do
        Mouse_Update
    loop until Mouse_Now.b = 0
    
' Poll for mouse events
    'Reset Status
    MenuSelect_New = -1                 'reset
    Active_Ctrl.Menu_Select = -1
    DO
        Mouse_Update
        if (mouse_now.x > xl and mouse_now.x < xr) and (mouse_now.y > yu and _
            mouse_now.y < yu + ListBox_Hgt*.Sub_Menu_Num) then 
            IF mouse_Now.b  then
                Put (xl,yu+1), Image_MenuSave, pset
                Exit Do
            end if
            if Mouse_prev.x <> Mouse_now.x or mouse_prev.y <> mouse_now.y then
                MenuSelect_New = int((mouse_now.y - yu)/ListBox_Hgt)
                If MenuSelect_New <> Active_Ctrl.Menu_Select then
                    IF Active_Ctrl.Menu_Select = -1 then
                        put (xl+2, yu+1+ MenuSelect_New*ListBox_Hgt),Image_MenuMask , xor  'new highlight
                        Active_Ctrl.Menu_Select = MenuSelect_New      're-assign        
                    ELSE
                        put (xl+2, yu+1 + Active_Ctrl.Menu_Select*ListBox_Hgt),Image_MenuMask , xor  'erase
                        Active_Ctrl.Menu_Select = MenuSelect_New      're-assign
                        put (xl+2, yu+1 + Active_Ctrl.Menu_Select*ListBox_Hgt),Image_MenuMask , xor  'highlight new
                    END IF
                end if
            end if
        ELSE
            IF MenuSelect_New <> -1 then
                put (xl+2, yu+1 + Active_Ctrl.Menu_Select*ListBox_Hgt),Image_MenuMask , xor  'erase former
                MenuSelect_New = -1
                Active_Ctrl.Menu_Select = -1
            END if
            IF Mouse_now.b then     'click off menu, cancel
                Active_Ctrl.Menu_Select = -1           'no choice
                Put (xl,yu+1), Image_MenuSave, pset
                Exit Do
            end if
        end if
        Sleep SleepTime 'give some time back to CPU
    loop
end with   

' Wait for mouse release
Do
    Mouse_Update
loop until Mouse_Now.b = 0

end sub

'
' Get current mouse status, and save prior status
SUB Mouse_Update()
    mouse_prev.x = mouse_now.x       'keep track of prior status
    mouse_prev.y = mouse_now.y
    mouse_prev.w = mouse_now.w
    mouse_prev.b = mouse_now.b
    With mouse_now
      If Getmouse(.x, .y, .w, .b) Then mouse_now = mouse_prev 'Get new, but revert to prior if failure
    End With
END SUB
'
' Subroutine to compare mouse movements to positions of user-defined Cmmd_Buttons on the
' screen.  The Cmmd_Button state ( B[].state ) and appearance of the button on the screen 
' (Draw_Control) are updated according to mouse action.  ActiveButton indicates which
' Cmmd_Button "has focus" from the mouse or = -1 if the mouse is not on any Cmmd_Button.
' The capability of using PullDown Menus was added later, using the same "CmmdButton" structure.
'
SUB Mouse_Move_Process ()
Dim as byte H_Slider = TRUE     'default, slider is horizontal
'Did mouse move off a Control?
IF (Active_Ctrl.Indx > -1) and (Active_Ctrl.Indx < Max_Ctrl) then
    With B[Active_Ctrl.Indx]
    if .Ctrl_Type <> Ctrl_Null then           
        if (mouse_now.x < .x1 + .x_Offset) or (mouse_now.x > .x2 + .x_Offset) _
        or (mouse_now.y < .Y1 + .y_Offset) or (mouse_now.y > .Y2 + .y_Offset) then
            screenlock
            if .state <> Ctrl_Status_Disabled then 'Test if button is disabled
                IF  .Ctrl_Type = Ctrl_Button then   
                    .state = Ctrl_Status_Enabled 'De-activate state of Button
                    .Draw_Control 0               'Re-draw button / menu item
                END IF
                IF  .Ctrl_type = Ctrl_TxtBox then
                    .state = Ctrl_Status_Enabled 'Enabled, but not focus/click
                    .Draw_Control 0               'Re-draw control           
                end if
                IF (.Ctrl_Type = Ctrl_Menu) and (Active_Ctrl.Active_Menu < 0) then             'Moving off Menu item, but not clicked
                    .state = Ctrl_Status_Enabled
                    .Draw_Control 0               'Re-draw button / menu item
                end if
                IF .Ctrl_Type = Ctrl_PoPUp then
                    .state = Ctrl_Status_Enabled
                END IF
                if .Ctrl_Type = Ctrl_Scroll then
                    .state = Ctrl_Status_Enabled
                    .Draw_Control 0 
                End if
                If .Ctrl_Type = Ctrl_CheckBox then
                    .state = Ctrl_Status_Enabled
                    .Draw_Control 0
                End if
                'Check to see if control has a "child" scroll bar
                if (.Ctrl_Type <> Ctrl_Scroll) and (.V_Scroll_Active = True) then
                    B[.Scroll_Hnd].State = Ctrl_Status_Enabled
                    Draw_Scroll
                end if
                IF .Ctrl_Type = Ctrl_Slider then
                    .state = Ctrl_Status_Enabled
                    .Draw_Control 0
                end if
                Active_Ctrl.Indx = -1       'reSet active ctrl indx to null
                Active_Ctrl.Ctrl_Type = Ctrl_Null
            end if
            screenunlock
        end if
    End if
    END WIth
END IF


' Did mouse move on to a new control ?

''If  B[Active_Ctrl.Indx].Ctrl_Type = Ctrl_Null then 
''    Active_Ctrl.Indx = WhichCtrl ()
''    if B[Active_Ctrl.Indx].Ctrl_Type <> Ctrl_Null then      'Must have moved on to a control
        'If Ctrl is a scroll bar, make sure mouse is over bar

'New code to avoid B[-1]

IF (Active_Ctrl.Indx <> WhichCtrl()) and (WhichCtrl() <> -1) then
    Active_Ctrl.Indx = WhichCtrl()
    With B[Active_Ctrl.Indx]
            if .Ctrl_Type = Ctrl_Scroll  then
                If (Mouse_Now.y < .y1 + .y_offset+ (.y2-.y1-.V_Scroll_Len)*.V_Scroll_Pos) _
                    OR (mouse_Now.y > .y1 + .y_offset+ (.y2-.y1-.V_Scroll_Len)*.V_Scroll_Pos + .V_Scroll_Len) then
                    .state = Ctrl_Status_Enabled
                ELSE
                    .State = Ctrl_Status_GotFocus
                end if
                screenlock
                .draw_control 0
                screenunlock
                exit sub
            end if 
            IF .Ctrl_Type = Ctrl_Slider then
                IF abs(.x2 - .x1) < abs(.y2-.y1) then H_Slider = FALSE    ' Vert or Horiz Slider?
                IF H_Slider then 'horizontal
                    IF (Mouse_Now.x > .x1 +.x_offset + SliderHeight + .Slider_Pos) and _
                   (Mouse_Now.x < .x1 +.x_offset + SliderHeight + .Slider_Pos + .V_Scroll_Len) then
                        .State = Ctrl_Status_GotFocus
                    ELSE
                        .State = Ctrl_Status_Enabled
                    END IF
                ELSE
                    IF (Mouse_Now.y < .y2 +.y_offset - SliderHeight-.Slider_Pos) and _
                   (Mouse_Now.y > .y2 +.y_offset - SliderHeight -.Slider_Pos - .V_Scroll_Len) then
                        .State = Ctrl_Status_GotFocus
                    ELSE
                        .State = Ctrl_Status_Enabled
                    END IF
                END IF
                screenlock
                .draw_control 0
                screenunlock
                exit sub
            end if
            If mouse_now.b = 1 then     'Mouse button pressed while moving onto button/menu
                IF .Ctrl_Type = Ctrl_Menu then
                    .State = Ctrl_Status_GotFocus      'Started w/o Menu_Select, so just
                                                        'set focus, not clicked
                Else
                    .State = Ctrl_Status_Clicked       'got focus and clicked on button
                END if
            else
                .State = Ctrl_Status_GotFocus          'got focus, no click
            END IF
            screenlock
            .Draw_Control 0
            'Check to see if control has a "child" scroll bar
            if (.Ctrl_Type <> Ctrl_Scroll) and (.V_Scroll_Active = True) then
                B[.Scroll_Hnd].State = Ctrl_Status_Enabled
                Draw_Scroll
            end if
            Screenunlock
        END With
END IF        
        

' Special Case.  Stayed on a Slider control.  Did you move on/off the slider?
IF Active_Ctrl.Indx > -1 then
    IF (B[Active_Ctrl.Indx].Ctrl_Type = Ctrl_Slider) and  (WhichCtrl() = Active_Ctrl.Indx) then
        With B[Active_Ctrl.Indx]
        .State = Ctrl_Status_GotFocus            'Default
        IF ABS(.x2-.x1) > ABS(.y2-.y1) then     'Horizontal
            IF (Mouse_Now.x < .x1 + .x_offset + SliderHeight + .Slider_Pos) _
            OR (Mouse_Now.x > .x1 + .x_offset + SliderHeight + .Slider_Pos + .V_Scroll_Len) _
            Then .State = Ctrl_Status_Enabled
        ELSE                                    'Vertical
            IF (Mouse_Now.Y > .y2 + .Y_Offset - SliderHeight - .Slider_Pos) _
            OR (Mouse_Now.Y < .y2 + .y_Offset - SliderHeight - .Slider_pos - .V_Scroll_Len) _
            Then .State = Ctrl_Status_Enabled
        end if
        screenlock
        .Draw_Control 0 
        screenunlock
        END With
    end if
END IF

''    End if
''end if   

' Handy debug stuff here for mouse control
'locate 3,1
'print using "Active_Ctrl.Indx: ###,         Active_Ctrl.type: ###,        Active_Ctrl.State: ##";Active_Ctrl.indx, B[Active_Ctrl.indx].Ctrl_Type, B[Active_Ctrl.indx].state 
'print using "Active_Ctrl.Active_Menu: ###"; Active_Ctrl.Active_Menu
'print using "Mouse_x, mouse_y: ####, ####   Mouse_B: ###   x_offset, y_offset: ####, #### ";mouse_now.x, mouse_now.y, mouse_now.b, B[Active_Ctrl.Indx].x_offset, B[Active_Ctrl.Indx].y_offset

'print using "B[23].state ##, B[23].V_Scroll_Active #, B[23].V_Scroll_Pos #.##,  B[23].Scroll_hnd ##";B[23].state,B[23].V_Scroll_Active,B[23].V_Scroll_Pos,B[23].Scroll_hnd
END SUB


'
' Displays a multi-line text message in a PopUP Form, and waits for OK to proceed
' PopUP width / height are automatically adjusted to fit the text.  PopUP is
' displayed at the center of the screen
'
SUB Mssg_Box (Prompt() as string, byval Title as string)
dim as integer x, mwidth, mheight, NumLine 
'using ext
'Find longest line of text
Font.FontIndex = MyFont.TxtBox_Indx
mwidth = 0
NumLine = 0
For i as integer = 0 to ubound(prompt)
    If len(prompt(i)) > 0 then 
        NumLine = NumLine + 1
        'x = gfx.font.getTextWidth(TxtBoxFont, Prompt(i))
        x = Font.StringWidth(Prompt(i))
        if x > mwidth then mwidth = x
    END IF
Next i
mwidth = mwidth + 16
'mheight = TxtBoxFont_Size*NumLine + 55
mheight = Font.TextHeight*NumLine + 55

With PopUp[Num_PopUp_Total]
    .x1 = (Screen_Width - mwidth)\2
    .x2 = .x1 + mwidth
    .y1 = (Screen_Height-mHeight)\2
    .y2 = .y1 + mheight
    .x_offset = 0
    .y_offset = 0
    .color = rgb(255,255,255)
    .Title = Title
    .Num_Ctrl = 0
    .ctrl_indx(0) = Num_Ctrl_Total
    .Exit_Button_Mssg = "OK"
end with
Active_Ctrl.Active_PopUp = Num_PopUp_Total  'Designate this PopUp as the active one
Num_PopUp_Total = Num_PopUp_Total + 1


' Draw PopUp
Draw_Pop_UP (Active_Ctrl.Active_PopUp)

' Add query mssg
Font.FontIndex = MyFont.TxtBox_Indx     'Reset, in case changed by some proc or sub
Font.ForeColor = Color_TxtBoxTxt
Font.BackColor = Color_Transparent
For i as integer = 0 to NumLine
    'draw string (PopUp[Active_Ctrl.Active_PopUp].x1 + 10, PopUp[Active_Ctrl.Active_PopUp].y1 + 25 + i * TxtBoxFont_Size),Prompt(i), , TxtBoxFont, alpha
    Font.DrawString 0, Prompt(i), PopUp[Active_Ctrl.Active_PopUp].x1 + 10, PopUp[Active_Ctrl.Active_PopUp].y1 + 25 + i * Font.TextHeight
Next i
' De-activate any reference to Active_Ctrl
    Active_Ctrl.Indx = -1   'reset to null Ctrl
    Active_Ctrl.Ctrl_Type = Ctrl_Null
    Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
    Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
    clearevents  

' Local Event Polling for Button Release or ENTER key
do
    Select Case PollEvent ()
    case Poll_CmdButton_Release 
        Select case B[Active_Ctrl.Indx].label    
                case PopUp[Active_Ctrl.Active_PopUp].Exit_Button_Mssg
                    Close_PopUP
                    Num_PopUp_Total = Num_PopUp_Total - 1
                    ClearEvents
                    Exit Sub
                Case else
            end select 
    Case Poll_Key_Press
            If Active_Ctrl.key = FB.SC_Enter then
                Close_PopUp
                Num_PopUp_Total = Num_PopUp_Total - 1
                ClearEvents
                Exit Sub
            Else
                Do until inkey = "": loop   'clear keybd buffer
            END IF
    Case Else
    End Select
    Sleep SleepTime         'Timeout so CPU can attend other tasks
loop

END SUB

' Displays a single-line text message in a PopUP Form, and waits for OK to proceed
' PopUP width is automatically adjusted to fit the text.  PopUP is
' displayed at the center of the screen
'
SUB Mssg_Box (byval Prompt as string, byval Title as string)
dim as integer mwidth, mheight
'using ext
'Find longest line of text
Font.FontIndex = MyFont.TxtBox_Indx

'mwidth = gfx.font.getTextWidth(TxtBoxFont, Prompt) + 16
'mheight = TxtBoxFont_Size + 55
mwidth = Font.StringWidth(Prompt) + 16
mheight = Font.TextHeight + 55


With PopUp[Num_PopUp_Total]
    .x1 = (Screen_Width - mwidth)\2
    .x2 = .x1 + mwidth
    .y1 = (Screen_Height-mHeight)\2
    .y2 = .y1 + mheight
    .x_offset = 0
    .y_offset = 0
    .color = rgb(255,255,255)
    .Title = Title
    .Num_Ctrl = 0
    .ctrl_indx(0) = Num_Ctrl_Total
    .Exit_Button_Mssg = "OK"
end with
Active_Ctrl.Active_PopUp = Num_PopUp_Total  'Designate this PopUp as the active one
Num_PopUp_Total = Num_PopUp_Total + 1

' Draw PopUp
Draw_Pop_UP (Active_Ctrl.Active_PopUp)

' Add query mssg
    Font.FontIndex = MyFont.TxtBox_Indx
    Font.ForeColor = Color_TxtBoxTxt
    Font.BackCOlor = Color_Transparent
    'draw string (PopUp[Active_Ctrl.Active_PopUp].x1 + 10, PopUp[Active_Ctrl.Active_PopUp].y1 + 25),Prompt, , TxtBoxFont, alpha
    Font.DrawString 0, prompt, PopUp[Active_Ctrl.Active_PopUp].x1 + 10, PopUp[Active_Ctrl.Active_PopUp].y1 + 25
' De-activate any reference to Active_Ctrl
    Active_Ctrl.Indx = -1   'reset to null Ctrl
    Active_Ctrl.Ctrl_Type = Ctrl_Null
    Active_Ctrl.Active_Menu = -1     'reset index, no dropdown menu active
    Active_Ctrl.Menu_Select = -1    'reset index, no menu item selected
    clearevents  

' Local Event Polling for Button Release or ENTER key
do
    Select Case PollEvent ()
    case Poll_CmdButton_Release 
        Select case B[Active_Ctrl.Indx].label    
                case PopUp[Active_Ctrl.Active_PopUp].Exit_Button_Mssg
                    Close_PopUP
                    Num_PopUp_Total = Num_PopUp_Total - 1
                    ClearEvents
                    Exit Sub
                Case else
            end select 
    Case Poll_Key_Press
            If Active_Ctrl.key = FB.SC_Enter then
                Close_PopUp
                Num_PopUp_Total = Num_PopUp_Total - 1
                ClearEvents
                Exit Sub
            Else
                Do until inkey = "": loop   'clear keybd buffer
            END IF
    Case Else
    End Select
    Sleep SleepTime
loop

END SUB


'       Plots a pixel in the graphics port.
'       Range of graphics port assumed (0,0) - (1,1)
'       PSTYLE: 0     -> points
'              -1     -> circle, filled
'               1     -> circle, open
'               2     -> line
'
sub plot (byval x as single, byval y as single, byval xmin as single, _
    byval xmax as single, byval ymin as single, byval ymax as single, _
    byval ptcol as uinteger, byval pstyle as integer)

STATIC xold as single, yold as single, xpt as single, ypt as single

window (-.1,-.1)-(1.1, 1.1)
        xpt = (x - xmin) / (xmax - xmin)        'scale 0-1
        ypt = (y - ymin) / (ymax - ymin)        'scale 0-1
        IF xpt < 0 OR ypt < 0 THEN GOTO SavePt
        IF xpt > 1 OR ypt > 1 THEN GOTO SavePt
        SELECT CASE pstyle
                CASE -1         'filled circle
                        CIRCLE (xpt, ypt), .005, ptcol, , , ,F
                CASE 0          'plot points
                        PSET (xpt, ypt), ptcol
                CASE 1          'open circle
                        CIRCLE (xpt, ypt), .005, ptcol
                CASE ELSE       'line
                        IF xpt > 0 THEN
                                LINE (xold, yold)-(xpt, ypt), ptcol
                        ELSE
                                PSET (xpt, ypt), ptcol   'first point in data set
                        END IF
        END SELECT
SavePt:
        xold = xpt: yold = ypt  'always redefine (may use pstyle 0 to reset)
window
END SUB
' OVERLOAD VERSION OF PLOT TO ADDED RADIUS AS ANOTHER PARAMETER
'       Plots a pixel in the graphics port.
'       Range of graphics port assumed (0,0) - (1,1)
'       PSTYLE: 0     -> points
'              -1     -> circle, filled
'               1     -> circle, open
'               2     -> line
'       Radius        -> radius of circle (fraction of full-length y-axis) when used, 
'                        otherwise ignored. Values is scaled by horizontal
'                        size of plot in pixels (ysmax-ysmin)
'
sub plot (byval x as single, byval y as single, byval xmin as single, _
    byval xmax as single, byval ymin as single, byval ymax as single, _
    byval ptcol as uinteger, byval pstyle as integer, byval radius as single)

STATIC xold as single, yold as single, xpt as single, ypt as single

window (-.1,-.1)-(1.1, 1.1)
        xpt = (x - xmin) / (xmax - xmin)        'scale 0-1
        ypt = (y - ymin) / (ymax - ymin)        'scale 0-1
        IF xpt < 0 OR ypt < 0 THEN GOTO SavePt
        IF xpt > 1 OR ypt > 1 THEN GOTO SavePt
        SELECT CASE pstyle
                CASE -1         'filled circle
                        CIRCLE (xpt, ypt), radius, ptcol, , , ,F
                CASE 0          'plot points
                        PSET (xpt, ypt), ptcol
                CASE 1          'open circle
                        CIRCLE (xpt, ypt), radius, ptcol
                CASE ELSE       'line
                        IF xpt > 0 THEN
                                LINE (xold, yold)-(xpt, ypt), ptcol
                        ELSE
                                PSET (xpt, ypt), ptcol   'first point in data set
                        END IF
        END SELECT
SavePt:
        xold = xpt: yold = ypt  'always redefine (may use pstyle 0 to reset)
window
END SUB
'
' Save the Viewport graphics area to image_buffer
' The Wipe () subroutine will restore the Viewport with the contents of image_buffer
'
SUB Protect ()
    View                                                     'Must reset to entire screen
    window screen                                            'Reset, default coordicate system
    Get (dxsmin,dysmin) - (dxsmax,dysmax), image_buffer      'Save Viewport to image_buffer
END SUB

SUB RestVid ()
pcopy 1,0
END SUB

'
'Save active video page
SUB SaveVid ()
pcopy 0,1
END SUB

'
'
SUB Set_Scroll_Len(byval Bar_len as integer)
Dim as integer temp_indx        
    temp_indx = B[Active_Ctrl.indx].Scroll_Hnd      'get index for control that is a scrollbar for current active control
    IF Bar_Len > 10 then
        B[temp_indx].V_Scroll_Len = Bar_Len
    ELSE
        B[temp_indx].V_Scroll_Len = 10              'minimum size of 10 pts 
    end if
END SUB

'
' Adjust width of righthand panel with three pane window
'
SUB SetPanel (byval Pwidth as integer)
    dxsmax = Screen_Width - Pwidth
    'Refresh entire screen
    line (0,0)-(Screen_Width-1, Screen_Height-1), Color_MenuBar, BF
    'Draw Panel areas
    Line (dxsmax+1,dysmin+Menu_Bar_Height+3)-(Screen_Width-2,Screen_Height) ,Color_Button_Area, BF
    Line (dxsmax+1,dysmin+Menu_Bar_Height+3)-(Screen_Width-2,Screen_Height), Color_FG, B
    'When MenuBar is added to top of screen, Dysmin -> Dysmin + Menu_Bar_Height + 4
    Box_3D (dxsmin, dysmin+Menu_Bar_Height+3, dxsmax-dxsmin, dysmax-dysmin-Menu_Bar_Height-4, Color_Scrn)
    Menu_col = LoWord(width) * (dxsmax/Screen_Width) +2                     'Column at left edge of Menu  
    'Reset size of Image_Buffer for screen save witn Protect/Wipe
    ImageDestroy (Image_Buffer)
    image_buffer = ImageCreate ((dxsmax-dxsmin+1), (dysmax-dysmin+1))   
end sub


'
' Initialize the screen.  Overload option to allow new parameter to specify # of panels
'
'sub SetVideo (byval Title as string)
'    using fb
'    screenres Screen_Width, Screen_Height,8 * BytePP,2          ', GFX_ALWAYS_ON_TOP  '8 bit resolution, 2 screen pages, fullscreen window
'    screenset 0,0                                               'default screen page is 0 for graphics
'    Width Screen_Width\8, Screen_Height\Default_Font_Height     'set default font size for print
'    WindowTItle Title
'    Image_Blank_Check = ImageCreate (8,8, RGB(255,255,255))
'    image_buffer = ImageCreate ((dxsmax-dxsmin+1), (dysmax-dysmin+1))       'buffer to save graphics area on screen
'    'Image_MenuSave = ImageCreate (400, 400)                                 'buffer to save chunk of screen for dropdown menu
'    CLS 0                                                                   'clear entire screen
'    line (0,0)-(Screen_Width-1, Screen_Height-1), Color_MenuBar, BF
'    color Color_FG, 0
'    SetMouse 0,0,1,0    'set mouse visible
'    dxsmax = screen_width
'    dysmax = Screen_Height
'    View                'Reset graphics viewport to entire screen (allow mouse action on Cmmd_buttons)
'END SUB

sub SetVideo (byval Title as string, byval panels as integer, byval Pwidth as integer = 0)
    using fb
    screenres Screen_Width, Screen_Height,8 * BytePP,2  ', GFX_ALWAYS_ON_TOP  '8 bit resolution, 2 screen pages, fullscreen window
    screenset 0,0                                                   'default screen page is 0 for graphics
    Width Screen_Width\8, Screen_Height\Default_Font_Height         'set default font size for print
    WindowTItle Title
    CLS 0                                                                   'clear entire screen
    line (0,0)-(Screen_Width-1, Screen_Height-1), Color_MenuBar, BF         'background for entire screen
    Select Case Panels
        Case 2
            dxsmax = screen_width-2
            Box_3D (dxsmin, dysmin+Menu_Bar_Height+3, dxsmax-dxsmin, dysmax-dysmin-Menu_bar_height-4, Color_Scrn)
        Case 3
            IF Pwidth = 0 then
                dxsmax = Screen_Width *4\5  'default, 20% of Screen_Width
            else
                dxsmax = Screen_Width - Pwidth
            end if
            Line (dxsmax+1,dysmin+Menu_Bar_Height+3)-(Screen_Width-2,Screen_Height) ,Color_Button_Area, BF
            Line (dxsmax+1,dysmin+Menu_Bar_Height+3)-(Screen_Width-2,Screen_Height), Color_FG, B
            'When MenuBar is added to top of screen, Dysmin -> Dysmin + Menu_Bar_Height + 4
            Box_3D (dxsmin, dysmin+Menu_Bar_Height+3, dxsmax-dxsmin, dysmax-dysmin-Menu_Bar_Height-4, Color_Scrn)
            Menu_col = LoWord(width) * (dxsmax/Screen_Width) +2                     'Column at left edge of Menu    
        Case else
            dxsmax = screen_width -1
            dysmax = Screen_Height -1
    end select
    Image_Blank_Check = ImageCreate (8,8, RGB(255,255,255))
    image_buffer = ImageCreate ((dxsmax-dxsmin+1), (dysmax-dysmin+1))       'buffer to save graphics area on screen
    'Image_MenuSave = ImageCreate (400, 400)                                 'buffer to save chunk of screen for dropdown menu
    color Color_FG, 0
    SetMouse 0,0,1,0    'set mouse visible
    View                'Reset graphics viewport to entire screen (allow mouse action on Cmmd_buttons)
END SUB


'
' Destroy Image Buffers to prevent memory leakage.  Exit program
SUB ShutDown()
    Deallocate(B)
    'Delete B
' Destroy all image buffers, prevent memory leakage
    ImageDestroy (Image_Buffer)
    ImageDestroy (Image_MenuSave)
    ImageDestroy (Image_MenuMask)
''    ImageDestroy (Image_Check)
    ImageDestroy (Image_Blank_Check)
    ImageDestroy (Image_PopUp)
    ImageDestroy (Image_Temp)
' No longer using FB_Ext_Lib Font Images
'    ImageDestroy (MenuFont)
'    ImageDestroy (MenuFontSel)
'    ImageDestroy (ButtonFont)
'    ImageDestroy (ButtonFontSel)
'    ImageDestroy (LabelFont)
'    ImageDestroy (RedFont)
'    ImageDestroy (PopUpFont)
'    ImageDestroy (TxtBoxFont)
END SUB

'
' Event Handler for Slider actions
'
' Define Slider position as the top (for vertical) or right (for horizontal) edge of the slider
SUB Slider_Process ()
DIM as integer xm, ym, wm, bm, x_last, y_last
Dim as byte H_Slider = TRUE     'default, slider is horizontal
Dim as byte Keep_Going = TRUE   'flag for slider moved past mouse click
DIM as single Delta
With B[Active_Ctrl.Indx]
    IF .V_Scroll_Len = 0 then .V_Scroll_Len = SliderWidth       'default
    IF ABS(.x2-.x1) < ABS(.y2-.y1) then H_Slider = False        'determine if horiz vs vert
    IF H_Slider then
        IF Mouse_Now.x < (.x1 + .X_offset + SliderHeight) then 
            .Slider_click = 1   'left
            Delta = .Slider_Incr
            .State = Ctrl_Status_Clicked
        ELSEIF Mouse_Now.x < (.x1 + .X_offset + SliderHeight + .Slider_Pos) then
            .Slider_Click = 4   'left of slider
            Delta = (.V_Scroll_Len / (.x2-.x1-2*SliderHeight))*(.Slider_max-.Slider_min)
            .State = Ctrl_Status_Enabled
        ELSEIF Mouse_Now.x > (.x2 + .x_offset - SliderHeight) then
            .Slider_Click = 2   'right
            Delta = .Slider_Incr
            .State = Ctrl_Status_Clicked
        ELSEIF (Mouse_Now.x >=  .x1 + .x_offset + SliderHeight + .Slider_Pos) _
            and (mouse_Now.x <= .x1 + .x_offset + SliderHeight + .Slider_Pos + .V_Scroll_Len) then
            .Slider_Click = 3   'On Slider
            .State = Ctrl_Status_Clicked
        ELSE    'must be right of slider
            .Slider_Click = 5
            Delta = (.V_Scroll_Len / (.x2-.x1-2*SliderHeight))*(.Slider_max-.Slider_min)
            .State = Ctrl_Status_Enabled
        END IF
    ELSE
        IF Mouse_Now.y > (.y2 + .y_offset - SliderHeight) then
            .Slider_Click = 1   'bottom cmd button
            Delta = .Slider_Incr
            .State = Ctrl_Status_Clicked
        ELSEIF Mouse_Now.y > (.y2 + .y_offset - SliderHeight - .Slider_Pos) then   'below slider
            .Slider_Click = 4
            Delta = (.V_Scroll_Len / (.y2-.y1-2*SliderHeight))*(.Slider_max-.Slider_min)
            .State = Ctrl_Status_Enabled
        ELSEIF Mouse_Now.y < (.y1 + .y_offset + SliderHeight) then
            .Slider_Click = 2   'Top
            .State = Ctrl_Status_Clicked
        ELSEIF (Mouse_Now.y >= .y2 + .y_offset - SliderHeight - .Slider_Pos - .V_Scroll_Len) _
            and (mouse_Now.y <= .y2 + .y_offset - (.Slider_Pos + SliderHeight)) then    
            .Slider_Click = 3   'On Slider
            .State = Ctrl_Status_Clicked
        ELSE  'Must be above slider
            .Slider_Click = 5
            Delta = (.V_Scroll_Len / (.y2-.y1-2*SliderHeight))*(.Slider_max-.Slider_min)
            .State = Ctrl_Status_Enabled
        END IF
    end if
    
    Select Case .Slider_Click
    Case 1    'left / Bottom cmmd button
        Do
            .Slider_Value = .Slider_Value - Delta '.Slider_Incr
            if .Slider_Value < .Slider_Min then .Slider_Value = .Slider_Min
            IF H_Slider then
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.x2-.x1)-2*SliderHeight - .V_Scroll_Len)
            ELSE
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.y2-.y1)-2*SliderHeight - .V_Scroll_Len)
            END IF
            screenlock
            .Draw_Control 0
            serve_slider
            screenunlock
            Sleep Slider_Sleep
            getmouse(xm, ym, wm, bm)
        loop while bm = 1
    Case 4    'Clicked left / below slider
        DO
            .Slider_Value = .Slider_Value - Delta 
            if .Slider_Value < .Slider_Min then .Slider_Value = .Slider_Min
            IF H_Slider then
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.x2-.x1)-2*SliderHeight - .V_Scroll_Len)
                IF (.Slider_Pos + .x1 + .x_offset + SliderHeight < Mouse_Now.x) Then Keep_Going = FALSE
            ELSE
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.y2-.y1)-2*SliderHeight - .V_Scroll_Len)
                IF (.y2 + .y_offset - SliderHeight -.Slider_Pos > Mouse_Now.y) then Keep_Going = FALSE
            END IF
            screenlock
            .Draw_Control 0
            serve_slider
            screenunlock
            Sleep Slider_Sleep
            getmouse(xm, ym, wm, bm)
        loop while (bm =1) and (Keep_Going = TRUE)
    Case 5   'Clicked Rigt/ Above slider
        DO
            .Slider_Value = .Slider_Value + Delta '.Slider_Incr
            if .Slider_Value > .Slider_Max then .Slider_Value = .Slider_Max
            IF H_Slider then
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.x2-.x1)-2*SliderHeight - .V_Scroll_Len)
                IF (.Slider_Pos + .x1 + .x_offset + SliderHeight + .V_Scroll_Len > Mouse_Now.x) THEN Keep_Going = FALSE
            ELSE
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.y2-.y1)-2*SliderHeight - .V_Scroll_Len)
                IF (.y2 + .y_offset - SliderHeight - .Slider_Pos - .V_Scroll_Len < Mouse_Now.y) then Keep_Going = FALSE  
            END IF
            screenlock
            .Draw_Control 0
            serve_slider
            screenunlock
            Sleep Slider_Sleep
            getmouse(xm, ym, wm, bm)
        loop while (bm =1) and (Keep_Going = TRUE)
    Case 2  'right / Top cmmd button
        Do
            .Slider_Value = .Slider_Value + .Slider_Incr
            if .Slider_Value > .Slider_Max then .Slider_Value = .Slider_Max
            IF H_Slider then
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.x2-.x1)-2*SliderHeight - .V_Scroll_Len)
            ELSE
                .Slider_Pos = ((.Slider_Value-.Slider_Min)/(.Slider_Max-.Slider_Min))*((.y2-.y1)-2*SliderHeight - .V_Scroll_Len)
            end if
            Screenlock
            .Draw_Control 0
            Serve_Slider
            screenunlock
            Sleep Slider_Sleep
            getmouse(xm, ym, wm, bm)
        loop while bm = 1
        screenlock
        .Draw_Control 0
        screenunlock
    Case 3   'Click/Drag slider bar
       x_last = Mouse_now.x
       y_last = Mouse_now.y
       xm = x_last
       ym = y_last
        DO
            IF H_Slider then
                IF (xm <> x_last) and (xm > -1) then
                    .Slider_Pos = .Slider_pos + (xm - x_last)    'Delta   
                    If .Slider_Pos < 0 then 
                        .Slider_Pos = 0
                        xm = x_Last
                    end if
                    If .Slider_Pos >  (.x2-.x1)- (2*SliderHeight + .V_Scroll_Len) then 
                        .Slider_Pos = (.x2-.x1)- (2*SliderHeight + .V_Scroll_Len)
                        xm = x_last
                    end if
                    .Slider_Value = .Slider_Min + .Slider_Pos/((.x2-.x1)- 2*SliderHeight - .V_Scroll_Len)*(.Slider_Max -.Slider_Min)
                    screenlock
                    .Draw_Control 0
                    Serve_Slider
                    screenunlock
                    x_last = xm
                END IF
            Else
                IF (ym <> y_last) and (ym > -1) then
                    .Slider_Pos = .Slider_pos - (ym - y_last)    'Delta 
                    IF .Slider_Pos < 0 then
                        .Slider_Pos = 0
                        ym = y_last
                    END IF
                    If .Slider_Pos > (.y2-.y1)- (2*SliderHeight + .V_Scroll_Len) then 
                        .Slider_Pos = (.y2-.y1)- (2*SliderHeight + .V_Scroll_Len)
                        ym = y_last
                    END IF
                    .Slider_Value = .Slider_Min + (.Slider_Pos)/((.y2-.y1)-2*SliderHeight - .V_Scroll_Len)*(.Slider_Max-.Slider_Min)
                    screenlock
                    .Draw_Control 0
                    Serve_Slider
                    screenunlock
                    y_last = ym
                END IF
            end if
            getmouse(xm, ym, wm, bm)
        loop while bm = 1
    Case ELSE    'Mouse Press on Slider, but not active elements
        .Slider_Click = 0
        .State = Ctrl_Status_Enabled    'no longer click/drag slider.  Redraw
        screenlock
        .Draw_Control 0
        Screenunlock
    END Select
end with
end SUB
'
'Routine to scale the active region of the graphics port.
'X1, Y1 are the upper left coordinates and X2,Y2 are the lower right,
'all expressed as a fraction (i.e. 0 to 1) of the total graphics area.
'Use SUBPLOT (0,0,1,1) to restore the active port to the full graphics area.
'
SUB subplot (byval X1 as single, byval Y1 as single, byval X2 as single, _
    byval Y2 as single)
'Verify parameters
IF X2 <= X1 OR Y2 <= Y1 THEN
        Box_PRINT "Illegal parameter values."
        Box_PRINT "Must set X1 < X2 and Y1 < Y2."
        EXIT SUB
END IF
IF X1 < 0 OR X1 > 1 THEN Box_PRINT "X1 is out of range": EXIT SUB
IF X2 < 0 OR X2 > 1 THEN Box_PRINT "X2 is out of range": EXIT SUB
IF Y1 < 0 OR Y1 > 1 THEN Box_PRINT "Y1 is out of range": EXIT SUB
IF Y2 < 0 OR Y2 > 1 THEN Box_PRINT "Y2 is out of range": EXIT SUB
'Redefine global variables for graphics window
xsmin = dxsmin + X1 * (dxsmax - dxsmin)
xsmax = xsmin + (X2 - X1) * (dxsmax - dxsmin)
ysmin = dysmin + Y1 * (dysmax - dysmin)
ysmax = ysmin + (Y2 - Y1) * (dysmax - dysmin)
VIEW (xsmin, ysmin)-(xsmax, ysmax)          'reset graphics view port
END SUB
'
' Routine to update Text string associated with selected TextBox.  <Enter> or mouse
' click outside the TextBox terminates.
SUB TextBox_Process ()
dim as byte bailflg
dim as integer xm, ym, bm, indx, max_len
bailflg = false
do until inkey = "": loop   'clear keybd buffer
Do
    GetMouse xm, ym, , bm       'dummy call to clear bm status
loop until bm = 0
'Using ext   
Font.FontIndex = MyFont.TxtBox_Indx
with B[Active_Ctrl.Indx]
    .TxtStr = .TxtStr + "_"     'add cursor to end.
    dim as string d
    Dim as integer lbllen, txtlen, Txtlen_old, box_width = .x2 - .x1
    IF .Label_Len <> -1 then    'test to see if Label printing is suppressed
        'lbllen = gfx.font.gettextwidth(TxtBoxFont, .label)
        LblLen = Font.StringWidth(.label)
    ELSE
        lbllen = 0
    END IF
    ''View Screen (.x1, .y1)-(.x2, .y2)    'clip txtstr to fit in TxtBox
    TxtLen_old = 0  'reset
    Do
        d = inkey         
        If asc(d) = 8 then  'backspace, delete last char
            .TxtStr = mid(.txtstr,1,len(.txtstr)-2)
            .TxtStr = .TxtStr + "_"     'add cursor back, with space
        end if
        If (asc(d) >31) and (asc(d)<127) then  'valid ASCII char to add to txtstr
            .Txtstr = mid(.Txtstr,1,len(.txtstr)-1) + d + "_"
        end if
        if len (.TxtStr) > 0 then 
            'TxtLen = gfx.font.gettextwidth(TxtBoxFont , .TxtStr)+2*TxtBox.Boarder
            TxtLen = Font.StringWidth(.TxtStr) + 2*TxtBox.Boarder
        else
            TxtLen = 0
        end if
        If TxtLen <> TxtLen_old then    'check to see if TxtBox needs to be updated
            IF .V_Scroll_Enable = False then
                '.Sub_Menu_Label(0) = .TxtStr                'working copy, to truncate
                'No V_scroll.  Test if Txt needs H_scroll
                If TxtLen + lbllen + 2*TxtBox.boarder > Box_Width then
                    'Shift horizontal offset.  Keep on one line. 
                  '  max_len = Box_Width - LblLen - 2*TxtBox.Boarder
                  '  do until Font.StringWidth(.Sub_Menu_Label(0)) < Max_len
                  '      .Sub_Menu_Label(0) = mid(.Sub_Menu_Label(0), 2, Len(.Sub_Menu_Label(0))-1)   'strip off first character
                  '  loop
                    TxtBox.offset = Box_Width - (TxtLen + lbllen + txtBox.boarder)
                else
                    TxtBox.offset = 0
                End IF
                Screenlock
                .Draw_Control 0
                screenunlock
            else
                Screenlock
                .V_Scroll_Pos = 1               'Force text scrolling to bottom, when adding text
                B[.Scroll_Hnd].V_Scroll_Pos = 1 'ditto for "child" scroll bar position variable
                .Draw_Control 0                 'Draw TxtBox
                if .V_Scroll_Active = True then Draw_Scroll
                screenunlock
            end if
            TxtLen_old = TxtLen
        end if
        'Check if clicked outside active textbox
        GetMouse xm,ym,,bm
        if (xm < .x1+.X_offset) or (xm > .x2 + .x_offset) _
            or (ym < .y1 + .y_offset) or (ym > .y2 + .y_offset) then
            'Test for mouse click off textbox, but careful to test for mouse off active window
            if bm <> 0 and (xm <> -1 and ym <> -1) then BailFlg = True  
        end if
        Sleep SleepTime
    loop until d = chr(13) or d = chr(9) or BailFlg = True
    IF d = CHR(13) then 
        .CheckState = True  'flag for Enter Key vs Mouse event to leave TxtBox
        Mouse_Now.b = 0     'clear mouse_click flg
    Else
        .CheckState = False
    END IF
    IF d = CHR(9) then 
        .Sub_Menu_State(2) = -1   'flag that TAB key terminated TxtBox
    ELSE
        .Sub_Menu_State(2) = 0
    end if
    .TxtStr = mid(.TxtStr,1,Len(.txtStr)-1) 'remove cursor    
End WIth  
'Reset TxtBox
TxtBox.offset = 0
B[Active_Ctrl.Indx].State = Ctrl_Status_Enabled
B[Active_Ctrl.Indx].Draw_Control 0
if B[Active_Ctrl.Indx].V_Scroll_Active = True then Draw_Scroll
'Active_Ctrl.Indx = -1   'reset to null Ctrl
'Active_Ctrl.Ctrl_Type = Ctrl_Null
''View
ClearEvents    
END SUB

' Routine to create a popup box for text input that recognizes CRLF (ie. forced linebreak)
' Width and Height of popup are automatically adjusted to accommodate Max_Chr per line 
' and Num_Line to display.  Text automaically scrolls vertically if Num_Line is exceeded.
' Backspace can be used to "erase", but not back across CRLF.
' Entered text is sent to ASCII outfile, one line at a time.  Calling routine must
' Open/Close the text file
'
SUB Text_To_File (byval x as integer, byval y as integer, byval Max_Chr as integer, _
    byval Num_Line as integer, byval FN as integer, byval Title as string)
    DIM as integer dx, dy, Chr_Cnt, Kbd, Active_Line = 0
    Dim as string Show_Title
    DIM Rmk_Str(Num_Line-1) as string*100
    Dim image_buf as FB.IMAGE ptr 
    Font.FontIndex = MyFont.TxtBox_Indx
    Font.ForeColor = Color_TxtBoxTxt
    Font.BackColor = Color_Transparent
    'Define dimensions of box
    dx = 8 * Max_Chr + 10
    dy = 16 * (Num_Line) + 20     'extra space for title
    'Make sure title fits. If not then truncate
    If Len(Title) > Max_Chr then
        Show_Title = mid(Title,1,Max_Chr)
    else
        Show_Title = Title
    end if
    'Store Screen
    image_buf = ImageCreate (dx+1, dy+1)        'temp image bufffer
    Get (x,y) - step (dx,dy), image_buf         'Save working area to image_buf
    'Make Box
    line (x,y)- step (dx, dy), rgb(255,255,255), bf
    line (x,y) - step (dx,18), rgb(0,0,255), bf
    'draw string (x+16,y+2), Show_Title, rgb(255,255,255)
    Font.DrawString 0, Show_Title, x+16, y+2
    'draw string (x+5, y+20), "_", rgb(0,0,0)        'show initial cursorT
    Font.DrawString 0, "-", x+5, y+20
    DO: loop until inkey = ""   'clear keybd buffer

    'Reset text buffer
    For i as integer = 0 to Num_Line-1
        Rmk_Str(i) = ""
    next i

'Main loop for text entry
    DO
        'Inner loop for current line
        DO
            Kbd = Getkey
            IF kbd = 8 then         'backspace/delete key
                IF Chr_Cnt > 0 then
                    Chr_Cnt = Chr_Cnt-1
                    Rmk_Str(Active_Line) = MID(Rmk_Str(Active_Line), 1, Chr_Cnt)
                end if
            ELSEif kbd = 13 then    'Enter/Return key
                exit do
            ELSEIF kbd > 31 and kbd < 127 then
                Rmk_Str(Active_Line) = Rmk_Str(Active_Line) + chr(kbd)
                Chr_Cnt = Chr_Cnt+1
            end if
            line (x,y+20)- step (dx, dy-20), rgb(255,255,255), bf
            For i as integer = 0 to Num_Line -1
                if i = Active_Line then
                    'draw string (x+5, y+16*i+20), Rmk_Str(i)+ "_", rgb(0,0,0)
                    Font.DrawString 0, Rmk_Str(i) & "_", x+5, y + 16*i +20
                Else
                    'draw string (x+5, y+16*i+20), Rmk_Str(i), rgb(0,0,0)
                    Font.DrawString 0, Rmk_Str(i), x+5, y + 16
                end if
            NEXT i
        loop until Chr_Cnt = Max_Chr-1
        
        'Done with current line
        If Rmk_Str(Active_Line) = "" then exit do
        Print #FN, Rmk_Str(Active_Line)
        Chr_Cnt = 0
        Active_Line = Active_Line + 1
        'If necessary, shift lines of text to scroll
        IF Active_Line > Num_Line-1 then
            For i as integer = 0 to Num_Line-2
                Rmk_Str(i) = Rmk_Str(i+1)
            next i
            Active_Line = Num_Line - 1
        END if
        'Reset new line
        Rmk_Str(Active_Line) = ""
        'Refresh box
        line (x,y+20)- step (dx, dy-20), rgb(255,255,255), bf
        For i as integer = 0 to Num_Line -1
            if i = Active_Line then
                'draw string (x+5, y+16*i+20), Rmk_Str(i)+ "_", rgb(0,0,0)
                Font.DrawString 0, Rmk_Str(i) & "_", x+5, y+16*i+20
            Else
                'draw string (x+5, y+16*i+20), Rmk_Str(i), rgb(0,0,0)
                Font.DrawString 0, Rmk_Str(i), x+5, y+16*i+20
            end if
        NEXT i
        Sleep SleepTIme
    loop
' Restore Screen
Put (x,y),image_buf, Pset
ImageDestroy (Image_Buf)    'destroy temporary buffer
END SUB

'
' Display a text mssg with a background rectangle
' x,y       the upper left corner. Width / Height are computed automatically
'           if x < 0, then box is centered horizontally 
' Bck_Color for background in 32-bit RGBA
' Brd_Color for boarder color (set equal to Bck_color for no boarder)
' 
SUB TitleBar (byval x as integer, byval y as integer, byval mssg as string, _
    byval Bck_color as uinteger, byval Brd_color as uinteger)
DIM as integer mssg_len, bwidth, bheight, xpos
DIM as FB.Image ptr title
using fb
Font.FontIndex = MyFont.TxtBox_Indx
Font.ForeColor = Color_TxtBoxTxt
Font.BackColor = Color_Transparent
'Determine length of mssg in pixels
IF len(mssg) then
   ' IF my_font then                 'custom font
   '     mssg_len = gfx.font.getTextWidth(my_font, mssg)
   '     imageinfo my_font, , bheight
   ' ELSE
   '     mssg_len = len(mssg)*8      'default font
   '     bheight = 16                'buffer of 2 pixels above/below
   ' END IF
   mssg_len = Font.StringWidth(mssg)
ELSE
   mssg_len = 0
end if
' Define graphics sprite
bwidth = mssg_len +20   'boarder
bheight = Font.TextHeight + 10  'boarder
Title = ImageCreate (bwidth+1, bheight+1, Bck_color)
Line Title, (0,0) - (bwidth,bheight), Brd_color, B
' Add text mssg
'IF my_font then
'    draw string Title, (10,5), mssg, ,My_Font, alpha        'custom font
'ELSE
'    draw string Title, (10,5), mssg, rgb(0,0,0)
'END IF
Font.DrawString Title, mssg, 10, 5
IF x < 0 then
    xpos = (dxsmax + dxsmin - bwidth)\2
ELSE
    xpos = x
end if
' Put to screen
Put (xpos,y), Title, pset
ImageDestroy (Title)    'release memory
end sub

'
' Wait for keybd input.  Nothing returned
SUB Wait_Any_Key ()
    'locate print_bottom-2, (LoWord(Width)-len("Hit any key to continue"))/2
    Box_Print " "
    Box_print "                     Hit any key to continue"
    sleep
    do until inkey = "": loop          'Clear keybd buffer
end sub

'
' Routine to Update image buffer for Drop_down Menu.  This capability enables a font 
' change for individual SubMenu items to indicate Enabled / Disabled
SUB UpDate_Menu (byval Indx as integer)
Dim as integer  TxtLen, MenuTxtWidth, y_menu, xa, ya, la
Dim as uinteger Symb_Color = rgb(0,0,0)
DIM as FB.Image ptr Symb
Symb = ImageCreate (10, 10)     ' 10 x 10 image for special graphic to left of menu item
If B[Indx].Sub_Menu_Num = 0 then exit sub   'no Sub_Menus
'Using Ext
Font.FontIndex = MyFont.Menu_Indx
Font.BackColor = RGB(255,255,255)
With B[Indx]
    'Find longest Sub_menu Label
    MenuTxtWidth = 0
    For i as integer = 0 to .Sub_Menu_Num-1
        'TxtLen = gfx.font.getTextWidth(MenuFontSel, .Sub_Menu_Label(i))
        TxtLen = Font.StringWidth(.Sub_Menu_Label(i))
        If MenuTxtWidth < TxtLen then
            MenuTxtWidth = TxtLen
        END IF
    Next i
    MenuTxtWidth = MenuTxtWidth + 25            'Add a little cushion
    MenuRowHeight = MenuFont_size + 5    
    y_menu = 10
    ImageDestroy(.Menu_IMage)   'reset
    .Menu_Image = ImageCreate (MenuTxtWidth+1,MenuRowHeight * .Sub_Menu_Num + 21)         'drop-down size
    get (.x1, 23) - (.x1+MenuTxtWidth,23+ MenuRowHeight*.Sub_Menu_Num+20), .Menu_image     'get existing bckgnd (jagged edges)
    line .menu_image ,(5,5)-(MenuTxtWidth, MenuRowHeight*.Sub_Menu_Num+20), rgb(170,170,170), bf
    line .Menu_Image, (0,0)-(MenuTxtWidth-5,MenuRowHeight*.Sub_Menu_Num+15),rgb (255,255,255), bf 
    line .Menu_Image, (0,0)-(MenuTxtWidth-5,MenuRowHeight*.Sub_Menu_Num+15),rgb (64,64,64), b 
    'Draw Submenu Text strings and prefix symbols
    For i as integer = 0 to .Sub_Menu_Num-1
        line Symb, (0,0)-(10,10), RGB(255,255,255), BF    'background fill
        If (Enabled AND .Sub_Menu_State(i)) = Enabled then
            'draw string .Menu_Image, (15,y_menu), .Sub_Menu_Label(i), ,MenuFont, alpha
            Font.ForeColor = RGB(0,0,0)
            Font.DrawString .Menu_Image, .Sub_Menu_Label(i), 15, y_menu
            Symb_Color = RGB(0,0,0)
        Else
            'draw string .Menu_Image, (15,y_menu), .Sub_Menu_Label(i), ,MenuFontDisable, alpha
            Font.ForeColor = RGB(190,190,190)
            Font.DrawString .Menu_Image, .Sub_Menu_Label(i), 15, y_menu
            Symb_Color = RGB(190,190,190)
        END IF   
        If (.Sub_Menu_State(i) AND ChkMrk) = ChkMrk then
            line symb, (1, 5)-(3,8), Symb_Color
            line symb, (3, 8)-(10,1), Symb_Color
            
            'Put Symb ,(2,2), Image_Check, pset
            Put .Menu_image, (1,y_menu), Symb, pset
        END IF
        If (.Sub_Menu_State(i) AND UpArrow) = UpArrow then
            xa = 5: ya = 0:  LA = 10
            line Symb, (xa, ya)-(xa,ya+LA),Symb_Color
            line Symb ,(xa, ya)-(xa-MenuFont_Size\4,ya+.3*La),Symb_Color
            line Symb ,(xa, ya)-(xa+MenuFont_Size\4,ya+.3*La),Symb_Color
            Put .Menu_image, (1,y_menu), Symb, pset
        END IF
        IF (.Sub_Menu_State(i) AND DnArrow) = DnArrow then
            xa = 5: ya = 0:  LA = 10
            line Symb, (xa, ya)-(xa,ya+LA),Symb_Color
            line Symb ,(xa, ya+LA)-(xa-MenuFont_Size\4,ya+.7*La),Symb_Color
            line Symb ,(xa, ya+LA)-(xa+MenuFont_Size\4,ya+.7*La),Symb_Color
            Put .Menu_image, (1,y_menu), Symb, pset
        END IF
        IF (.Sub_Menu_State(i) AND RtArrow) = RtArrow then
            xa = 1: ya = 5:  LA = 9
            line Symb, (xa, ya)-(xa+La,ya),Symb_Color
            line Symb ,(xa+LA, ya)-(xa+.7*La,ya+MenuFont_Size\4),Symb_Color
            line Symb ,(xa+La, ya)-(xa+.7*La,ya-MenuFont_Size\4),Symb_Color
            Put .Menu_image, (1,y_menu), Symb, pset
        END IF
        IF (.Sub_Menu_State(i) AND LtArrow) = LtArrow then
            xa = 1: ya = 5:  LA = 9
            line Symb, (xa, ya)-(xa+La,ya),Symb_Color
            line Symb ,(xa, ya)-(xa+.3*La,ya+MenuFont_Size\4),Symb_Color
            line Symb ,(xa, ya)-(xa+.3*La,ya-MenuFont_Size\4),Symb_Color
            Put .Menu_image, (1,y_menu), Symb, pset
        END IF
        IF (.Sub_Menu_State(i) AND XMrk) = XMrk then
            xa = 1: ya = 1:  LA = 8
            line Symb, (xa, ya)-(xa+La,ya+LA),Symb_Color
            line Symb ,(xa, ya+La)-(xa+La,ya),Symb_Color
            Put .Menu_image, (1,y_menu), Symb, pset
        END IF
        y_menu = y_menu + MenuRowHeight
    Next i
end with
ImageDestroy (Symb)
END SUB
'
' Function to clip the string representation of floating point number (single) 
' to n signficant digits.
#include Once "vbcompat.bi"
Function SignifDig (byval x as single, byval n as integer) as string
    If n < 1 then n = 1
    IF x = 0 then return "0"
    Dim As String sx = Format(x, "+." & String(n, "0") & "E+00")
    Dim As String mant = mid(sx,3, n)      ' mantissa
    Dim As Integer expo = Val(Right(sx, 3)) ' exponent
    Dim Temp as string
    Temp = ""
    If expo > 0 then
        for i as integer = 1 to expo
            if i <=n then
                temp = temp + mid(sx, i+2, 1)
            else
                Temp = Temp + "0"
            END IF
        next
        if n > expo then
            temp = temp + "."
            for i as integer = 1 to n-expo
                temp = temp + mid(sx, i+expo+2,1)
            next
        end if
    end if
    IF expo = 0 then temp = left(sx,n+2)
    IF Expo < 0 then
        temp = "0."
        for i as integer = 1 to abs(expo)
            temp = temp + "0"
        next i
        temp = temp + mant
    end if
    if (x < 0) and (mid(temp, 1,1) <> "-") then temp = "-" & temp
    
    'Kludge added
    IF mid(Temp,1,1) = "+" then temp = mid(temp,2,len(temp)-1)
    IF mid(temp,1,1) = "." then temp = "0" + temp 
    return temp
end function



' Routine to determine if the current mouse position is over an enabled Control on the screen
'
' Returns:  Active_Ctrl.Indx if on an enabled control
'           Else, returns -1 
FUNCTION WhichCtrl ()as integer

dim as integer x_offset, y_offset

'locate 8,1:  print using "Num_Ctrl_Total: ###  ";Num_Ctrl_Total

dprint (8,"Num_Ctrl_Total: " & Num_Ctrl_Total)
'end debug
For i as integer = Num_Ctrl_Total-1 to 0 step -1    'search in reverse order of definition, 
                                                    'to pick up scrollbars or other controls added "on top"
    if  B[i].x1 + B[i].X_offset < mouse_now.x and B[i].x2 + B[i].X_offset > mouse_now.x and _
        B[i].y1 + B[i].y_offset < mouse_now.y and B[i].y2 + B[i].y_offset > mouse_now.y then  
        if (B[i].state = Ctrl_Status_Disabled) or (B[i].state = Ctrl_Status_Hidden) then     'Test if button is disabled
           'Convenient debug
           'locate 9,1 : print using "Hidden or Disabled Control: ##                         "; i
            dprint (10,"On Hidden or Disabled Control: " & i & "    ")
            dprint (11,"Ctrl.Label          " & B[i].label & "                      ")
            dprint (12,"B[ctrl].Scroll_hnd  " & B[i].scroll_hnd & "                 ")
            dprint (13,"V_Scroll_Active     " & B[i].V_Scroll_Active & "                 ")
            dprint (14,"V_Scrol_Pos         " & B[i].V_Scroll_Pos & "                 ")
           ' return -1  ?don't return b/c may be another control with higher index and enabled
           '            at the same location.
        else
           'part of convenient debug
           'locate 9,1 : Print using "On Enabled Control: ##   B[ctrl].Scroll_hnd   ## ";i, B[i].scroll_hnd
            dPrint (10,"On Enabled Control: " & i & "                 ")
            dprint (11,"Ctrl.Label          " & B[i].label & "                      ")
            dprint (12,"B[ctrl].Scroll_hnd  " & B[i].scroll_hnd & "                 ")
            dprint (13,"V_Scroll_Active     " & B[i].V_Scroll_Active & "                 ")
            dprint (14,"V_Scrol_Pos         " & B[i].V_Scroll_Pos & "                 ")
            return i
        end if
    end if
next i
' Convenient debug for controls
'locate print_top+9,1 : Print "                                "

return -1
END FUNCTION

'
'
'
SUB Wipe ()
    view
    window screen                                 'reset, default coordinate system
    Put (dxsmin,dysmin),image_buffer, Pset        'restore image_buffer to View port
END SUB
'
'       Routine to draw x-axis
'       Assumes:        xsmin - physical coordinates of x, lower left
'                       ysmin - physical coordinates of y, lower left
'                       These are COMMON variables
SUB xaxis (byval xmin as single, byval xmax as single, byval ymin as single, _
    byval ymax as single, byval ntic as integer, byval offset as single, _
    byval LogFlg as byte = FALSE, byval xlabel as string)
dim as single xpt, dx, dy, ypt, x, y, Lbl_Len
dim as string lbl
'Using ext
Font.FontIndex = MyFont.PopUp_Indx
Font.BackColor = Color_Transparent
WINDOW (-.1, -.1)-(1.1, 1.1)
     dy = 5/(dysmax-dysmin)*1.2     'equivalent of 5 pixels
     ypt = (offset - ymin) / (ymax - ymin)
     y   = PMAP(ypt,1) + Font.TextHeight\2 + ysmin
     LINE (0, ypt)-(1, ypt), RGB(0,0,0)
     IF LogFlg = FALSE  then 'arithematic, not log
        if Ntic = 0 then
            dx = axisdelta(xmax-xmin)
        else
            dx = (xmax-xmin)/Ntic
        end if
        x = xmin
        do
            lbl = SignifDig(x,2)
            LINE ((x-xmin)/(xmax-xmin), ypt-dy)-Step(0, 2*dy), RGB(0,0,0)
            Lbl_Len = Font.StringWidth(lbl)
            xpt = PMAP((x-xmin)/(xmax-xmin),0) - Lbl_Len/2 + xsmin    'L_board
            Font.DrawString (,Lbl, xpt, y)
            x = x + dx   
        loop until (x-xmin)/(xmax-xmin) > 1.01        'allow for small rounding overflow on x
    ELSE    'logarithmic axis
        x = 10^int(log(10^xmin)/log(10))
        do
            lbl = SignifDig(x,1)
            xpt = (log(x)/log(10)-xmin)/(xmax-xmin)
            IF xpt >=0 and xpt <= 1 then 
                LINE (xpt, ypt-dy)-(xpt, ypt+dy), RGB(0,0,0)
                if mid(str(x),1,1) = "1" then
                    lbl = str(x)
                    'Lbl_Len = gfx.font.GetTextWidth(MenuFont,Lbl)
                    Lbl_Len = Font.StringWidth(Lbl)
                    xpt = PMAP(x,0) - Lbl_Len\2 + xsmin    'in window coordinates
                    'draw string (xpt,ypt-20/(ysmax-ysmin)), lbl, ,MenuFont,alpha
                    Font.DrawString (,Lbl, xpt, y)
                end if
            end if
            x = x + 10^int(log(x+.1)/log(10))
        loop until (log(x)/log(10)-xmin)/(xmax-xmin) > 1.01
    END IF
    IF xlabel <> "" then
        Dim as single slen, pzero
        'Font.unloadfont(1)                  'unload any pre-existing font
        'IF font.loadfont (Font_Path & "Micross14.xf",1) then
    '      Mssg_Box "LoadFont Error. " & FontName & " not found", "Error"
        'end if
        'font.fontindex = 1
        slen = Font.StringWidth (xlabel)
        'pzero = dxsmin + .45*(dxsmax-dxsmin) - (slen/2)
        pzero = Pmap(0.5,0) - Slen/2 + xsmin
        'ypt = (offset-ymin) / (ymax - ymin)
        'ypt = dysmin + ((1.1-ypt)/1.2)*(dysmax-dysmin) '+ Font.TextHeight  'Scale -0.1 to 1.1
        'DrawString_Custom (pzero, ypt, xlabel, "Micross14.xf")
        Font.DrawString (,xlabel, pzero, y + Font.TextHeight)
    end if
window
END SUB
'
' Axis min/max optimization.
' Given min & max (single), determines adjusted min, max to create "nice" axis
SUB XY_Axis_Range (byref xymin as single, byref xymax as single)
DIM as single delta, min_new, max_new
delta = axisdelta (xymax - xymin) 'determine optimal detla for axis tics
' Find new minimum
    min_new = 0     'guarantees axis tics will include 0, if in range (min,max)
    IF xymin < 0 then
        do
            min_new = min_new - delta
        loop until min_new <= xymin
    Else
        do
            min_new = min_new + delta
        loop until min_new > xymin
        min_new = min_new - delta
    END IF
'Find new maximum
    max_new = min_new
    do
        max_new = max_new + delta
    loop until max_new >= xymax*.999     'scale factor to account for round-off
'Re-assign
    xymin = min_new
    xymax = max_new
end sub

'   Routine to draw y-axis.  If Ntic = 0, then the optimal number of 
'   tics will be determined automatically
'
SUB yaxis (byval xmin as single, byval xmax as single, byval ymin as single, _
    byval ymax as single, byval ntic as integer, byval offset as single, _
    byval ylabel as string)
dim as single xpt, dx, dy, ypt, x, y, Lbl_Len
dim as string lbl
Font.FontIndex = MyFont.PopUp_Indx
Font.BackColor = Color_Transparent
WINDOW (-.1, -.1)-(1.1, 1.1)
     dx = 5/(dxsmax-dxsmin)*1.2    'equivalent of 5 pixel width 
     xpt = (offset - xmin) / (xmax - xmin)
     LINE (xpt, 0)-(xpt, 1), RGB(0,0,0)
     if Ntic = 0 then
         dy = axisdelta(ymax-ymin)
     else
         dy = (ymax-ymin)/Ntic
     end if
     y = ymin
     do
        lbl = str(clip(y,2))
        if Instr(lbl,"e") <> 0 then lbl = "0"   'kludge to avoid rounding error when
                                                'result should be 0, but x.xxxe-xx is returned
        ypt = PMAP((y-ymin)/(ymax-ymin),1) - 0.5*Font.TextHeight + ysmin
        LINE (xpt - dx, (y-ymin)/(ymax-ymin))-Step(2*dx, 0), RGB(0,0,0)
        Lbl_Len = Font.StringWidth(Lbl)
        x = PMAP(xpt,0) - Lbl_Len - 8 + xsmin   'in window coordinates
        Font.DrawString (, Lbl, x, ypt)
        y = y + dy
    loop until (y-ymin)/(ymax-ymin) > 1.01        'allow for small rounding overflow on y
    
    IF ylabel <> "" then
        Dim as single slen, pzero
        slen = Font.StringWidth (ylabel)
        pzero = Pmap(.5,1)+ (slen/2) + ysmin
        xpt = (offset-xmin) / (xmax - xmin) - .1   'shift left by 10% of screen
        xpt = Pmap(xpt,0) + Font.TextHeight + xsmin
        Font.DrawString (,ylabel, xpt, pzero,,,1)
    end if
window
END SUB