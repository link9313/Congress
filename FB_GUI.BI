' Header File for Routines in FB-GUI
'
' S. Cannon August 2008
'-----------------------------------------------------------

#Define FB_GUI_Version_ "1.20.1"
#Define FB_GUI_Date_ "14-April-2010"
'These must go before Windows.bi or conflict arises with definition of boolean constants
#include once "fbgfx.bi"
#include once "file.bi"

' Custom Fonts from xFont
' http://xaviorsoft.freebasic.net/fbproduct/
'
#define Fonts_Xfont
#include once "xfont.bi"

' Access to Windows API
#define WIN_INCLUDEALL
#include once "windows.bi"
#Define FileOpenDialog(a,b,c,d) FileOpenSaveDialog(0,(a),(b),(c),(d))
#Define FileSaveDialog(a,b,c,d) FileOpenSaveDialog(1,(a),(b),(c),(d))
'
' Use comment delimeter to trun on/off debug print to console
'#Define DEBUG_ENABLED
#Ifdef DEBUG_ENABLED
	#Define DPrint(row, Msg)  locate row,5: Print Msg
#Else
	#Define DPrint(row, Msg) 'does nothing
#EndIf

'Boolean constants.  To be safe...but, likely to have been previously defined in .bi files
#ifndef FALSE
    #define FALSE 0
#endif
#ifndef TRUE
    #define TRUE 1
#endif

Dim Shared As xfont.interface font
DIM shared as string*240    Font_Path   = "C:\Program Files\FreeBASIC\inc\xfont\"

Type _MyFont
    Button  as string = "micross12.xf"
    Label   as string = "micross12.xf"
    Menu    as string = "Tahoma12.xf"
    PopUp   as string = "Tahoma14B.xf"
    TxtBox  as string = "Micross12.xf" 
    
    'default index for font load
    Button_Indx as integer = 2
    Label_Indx  as integer = 3
    Menu_Indx   as integer = 4
    PopUP_Indx  as integer = 5
    TxtBox_Indx as integer = 6
    
end type
DIM shared as _MyFont MyFont

'Load Fonts.  First look in current directory, then Font_Path if not found
With MyFont
    IF Font.loadfont (CurDir &"/" &.Button, .Button_Indx)    then 
        IF Font.loadfont (Font_Path &.Button, .Button_Indx)  then  
            print "Unable to find font: " & .Button
        end if
    END IF
        IF Font.loadfont (CurDir &"/" &.Label, .Label_Indx)    then 
        IF Font.loadfont (Font_Path &.Label, .Label_Indx)  then  
            print "Unable to find font: " & .Label
        end if
    END IF
    IF Font.loadfont (CurDir &"/" &.Menu, .Menu_Indx)    then 
        IF Font.loadfont (Font_Path &.Menu, .Menu_Indx)  then  
            print "Unable to find font: " & .Menu
        end if
    END IF
    IF Font.loadfont (CurDir &"/" &.PopUp, .PopUp_Indx)    then 
        IF Font.loadfont (Font_Path &.PopUp, .PopUp_Indx)  then  
            print "Unable to find font: " & .PopUp
        end if
    END IF
    IF Font.loadfont (CurDir &"/" &.TxtBox, .TxtBox_Indx)    then 
        IF Font.loadfont (Font_Path &.TxtBox, .TxtBox_Indx)  then  
            print "Unable to find font: " & .TxtBox
        end if
    END IF
end with

'
'  Create GUI Controls with FB, no Win API
'

Dim Shared as integer   Max_Ctrl  = 256, _  'Maximum number of controls
                        Max_PopUp = 10      'Max number of PopUp forms
Const                   Max_Menu  = 16      'Max number of items in drop_down menu
Dim Shared gInstance as integer
Type Control
        'Declare Constructor()
        'Declare Destructor()
        index As Integer
        Ctrl_Type as integer         '
        x1 as integer           'Coordinates
        x2 as integer
        y1 as integer
        y2 as integer   
        x_offset as integer     'offsets for control contained on a PopUp Form
        y_offset as integer
        Label as string         'Label for Control
        Label_FontSize as integer   'NOW OBSOLETE
        LabelFont as any ptr        'NOW OBSOLETE   font for label
        LabelFontSel as any ptr     'NOW OBSOLETE   font for Label with got-focus   
        Label_len as integer    'length of label in pixels
        color as uinteger       'ctrl bckgnd color
        TxtStr as string        'String for TxtBox; not really used for other controls
        CheckState as byte      'status of CheckBox
        V_Scroll_Enable as byte 'Flg to enable V_Scroll Bar
        V_Scroll_Active as byte 'Flg to indicate if V_Scroll Bar is active
        V_Scroll_Pos as single  'position of scroll bar (0 - 1 : uppermax - Lowermax)
        V_Scroll_Len as integer 'length of scrollbar
        Scroll_hnd as integer   'handle or reference to the control a scroll bar is associated with 
        Slider_Click as byte    'Flag for mouse status: 0 = none, 1 = left cmmd btn, 2 = right cmmd bttn, 3 = slider
        Slider_pos as integer   'position of slider
        Slider_Incr as single   'increment for Cmmd Button press on slider
        Slider_Min as single    'minimum value for slider
        Slider_Max as single    'maximum value for slider
        Slider_Value as single  'Value for slider output
        State as integer        'State of Control (hidden, enable, gotfocus)
        Menu_Image as any ptr   'Contents for drop-down menu
        Sub_Menu_Num as integer 'Number of elements in SubMenu <= Max_Menu
        Sub_Menu_State (Max_Menu) as byte     'Flg for submenu items
                                        ' bit 0:  Enable = 1            Disable = 0
                                        ' bit 1:  Show CheckMrk = 1     Clear CheckMrk = 0
                                        ' bit 2:  Show UpArrow = 1      Clear UpArrow = 0
                                        ' bit 3:  Show DnArrow = 1      Clear DnArrow = 0
                                        ' bit 4:  Show RtArrow = 1      Clear RtArrow = 0
                                        ' bit 5:  Show LtArrow = 1      Clear LtArrow = 0
        Sub_Menu_Label (Max_Menu) as string   'labels for Submenu Itens
        Declare Function Draw_Control (byval CtrlPtr as any ptr) as integer  'Draw control.  CtrlPtr = 0 for screen or ptr to FB.image
end type


'Dim Shared B as Control Ptr = New Control[256]

Dim Shared B as Control Ptr
B = CALLocate (Max_Ctrl*len(Control))              'alloacte maximum number of controls

' Klutzy way to allow B[xxx] to know the value of xxx
For j as integer = 0 to Max_Ctrl-1
    B[j].Index = j
next

DIM SHARED as any ptr Temp_Font(100)      'temporary storage LabelFont

Const Enabled = &b00000001
Const Chkmrk  = &b00000010
const UpArrow = &b00000100
const DnArrow = &b00001000
const RtArrow = &b00010000
const LtArrow = &b00100000
const Xmrk    = &b01000000

Type Form
    x1 as integer               'Coordinates
    x2 as integer
    y1 as integer
    y2 as integer  
    x_offset as integer
    y_offset as integer
    color as uinteger           'bckgnd color
    Title as string             'form title
    Exit_Button_Mssg as string  'custom mssg for button to close form
    Temp_Flg as byte            'Flag that Pop_Up is temporary (dynamic) and should
                                'be "killed" upon CLose_Pop_Up
    Num_Ctrl as integer         'number of controls added to form
    Ctrl_Indx(63) as integer    'allow up to 64 controls on a form
End Type
Dim Shared PopUP as Form ptr
PopUP = CALLocate (Max_PopUp*len(Form))    'maximum of 10 PopUp forms
For i as integer = 0 to Max_PopUp-1
    PopUP[i].Temp_Flg = FALSE              'force default to not Kill PopUp
next

'DIM shared as integer PopUp_Ctrl_Indx(10)
DIM SHARED Num_Ctrl_Total as integer    'Total number of defined controls
DIM SHARED Num_PopUp_Total as integer   'Total number of defined PopUp Contorls
Dim shared Num_PopUp_Ctrl as integer    'Total number of controls added to the active PopUp
DIM shared Num_PopUp_Temp_Ctrl as integer   'Number new temporary controls in popUp (to be removed in Close_PopUP)
'TextBox features
Type TxtBox_Param
    as integer  Boarder ,_      'boarder between edge of text and box
                Offset          'x-offset for left edge of txt_string (left shift for scroll)
                                'Or used to indicate First_line of Ascii Text file for printing
    as single   Line_Spacing    'Line spacing for text
End Type
Dim Shared TxtBox as TxtBox_Param
' Initialize parameter for txt scrolling in TxtBox
    TxtBox.boarder = 5
    TxtBox.Offset = 0           'initialize horizontal offset
    TxtBox.Line_Spacing = 1
Dim Shared Default_TxtFileBox as integer    'Shared variable for Indx of Ctrl = Default TxtFileBox
Dim Shared as string Txt_Substr(32)         'substring for wrap text option, each element is one line
DIM Shared as string Menu_Title(10)         'Names for Menu selections
'ListBox features
CONST ListBox_hgt = 20          'default height for ListBox
Type Current_State field=1
    Ctrl_Type as integer        'which class of control
    Indx as integer             'which element in Control ptr
    Key as integer              'scancode for kybd input
    Active_Menu as integer      'which dropdown menu, if any, is active
    Menu_Select as integer      'which item within dropdown menu
    Active_PopUp as integer     
    Active_TxtBox as integer
end type
DIM SHARED AS Current_State Active_Ctrl

'Initialize
with Active_Ctrl
    .Ctrl_type = 0
    .indx = 0
    .key = 0
    .Active_Menu = 0
    .Menu_Select = -1
    .Active_PopUP = -1
    .Active_TxtBox = -1
end with
Num_PopUp_Temp_Ctrl = 0

Type Mouse_Type
    As Integer x, y, w, b
END Type
DIM SHARED AS Mouse_Type mouse_now, mouse_prev

' Poll Response IDs
Const as integer    Poll_Null                   =0  ,_
                    Poll_CmdButton_Press        =1  ,_
                    Poll_CmdButton_Release      =2  ,_
                    Poll_TxtBox_Press           =3  ,_
                    Poll_TxtBox_Release         =4  ,_
                    Poll_MenuSelect_Press       =5  ,_
                    Poll_MenuSelect_Release     =6  ,_
                    Poll_MenuDropDown_Press     =7  ,_
                    Poll_MenuDropDown_Release   =8  ,_
                    Poll_Key_Press              =9  ,_ 
                    Poll_Window_Close           =10 ,_
                    Poll_CheckBox_Press         =11 ,_
                    Poll_CheckBox_Release       =12 ,_
                    Poll_Slider_Press           =13 ,_
                    Poll_Slider_Release         =14 ,_
                    Poll_ListBox_Press          =15 ,_
                    Poll_ListBox_Release        =16 ,_
                    Poll_Mouse_R_Press          =17
' Control Type
Const as integer    Ctrl_Null                   =0  ,_  'for mouse click on no Control Object
                    Ctrl_Button                 =1  ,_
                    Ctrl_Menu                   =2  ,_
                    Ctrl_TxtBox                 =3  ,_
                    Ctrl_Key                    =4  ,_  'keybd input
                    Ctrl_PopUp                  =5  ,_  'PopUp Form
                    Ctrl_Scroll                 =6  ,_
                    Ctrl_CheckBox               =7  ,_
                    Ctrl_TxtFileBox             =8  ,_    'display contents of Ascii text file in a box, using std font
                    Ctrl_Label                  =9  ,_
                    Ctrl_Slider                 =10 ,_
                    Ctrl_ListBox                =11 ,_
                    Ctrl_Mouse_R_PopUp          =12
' Status of Controls
Const as integer    Ctrl_Status_idle            =-3 ,_  'placehold, when no Control active/selected
                    Ctrl_Status_Hidden          =-2 ,_  'do not draw
                    Ctrl_Status_Disabled        =-1 ,_  'show, but disabled
                    Ctrl_Status_Enabled         = 0 ,_  
                    Ctrl_Status_GotFocus        = 1 ,_  '
                    Ctrl_Status_Clicked         = 2

Dim shared image_buffer as FB.IMAGE ptr     'define ptr for buffer to be used with ImageCreate 
Dim shared image_MenuSave as FB.IMAGE ptr
Dim SHARED image_MenuMask as FB.IMAGE ptr
''dim shared image_check as FB.IMAGE ptr
DIM SHARED Image_PopUP as FB.IMAGE ptr
DIM SHARED Image_Blank_Check as FB.IMAGE ptr
DECLARE FUNCTION WhichCtrl () as integer
DECLARE SUB Mouse_Move_Process ()
DECLARE FUNCTION PollEvent () as integer


' Special variables for Fonts.  NOW OBSOLETE
DIM shared as integer ButtonFont_size = 14, MenuFont_size = 14, MenuFontDisable_Size = 14, _
    MenuFontSel_size=16, LabelFont_size = 14, PopUP_Size = 16, TxtBoxFont_Size = 16, _
    Scroll_Width = 10
DIM shared as FB.IMAGE ptr MenuFont, MenuFontSel, MenuFontDisable, ButtonFont, _
    LabelFont, RedFont, PopUpFont, TxtBoxFont, ButtonFontSel


'Temporary FB.Image for making sprites
DIM Shared as FB.IMAGE ptr Image_Temp, Image_Restore

' ---------------------End Custom Controls---------------------------------------------
'
' File Open / Close
DIM SHARED as STRING FileName       'short file name, does not include path
DIM SHARED as STRING *250 Path      'path name may be very long

'
'
' Video stuff
'
DIM Shared as string WinTitle
DIM Shared as integer WinPanel
dim shared as integer Screen_Width, Screen_Height
ScreenInfo Screen_Width, Screen_Height
'screen_width = screen_width *.9         'don't take up entire screen
'screen_Height = Screen_Height *.85      'mouse coordinate bug if entire screen used
'Must set ScreenRes in graphics mode from this BI file. otherwise GFX font load crashes
screenres screen_width, screen_height, 32, 0    '32 BPP, Windowed
'print "pre-processed: ", screen_width, screen_height
screen_width = screen_width *.9         'don't take up entire screen
screen_Height = Screen_Height *.85      'mouse coordinate bug if entire screen used
const GET_ViewPort = 11                 'ScreenControl option
const BytePP = 4                        '4-byte (32-bits) per pixel color depth to allow custom fonts
const Default_Font_Height = 14          'nice big charcters.... easier to read!
       'set default font size for print

DIM SHARED as UINTEGER Color_FG = rgb(255,255,255)  ,_  'foreground text color
            Color_Scrn          = rgb(240,240,240)  ,_  'screen background color
            Color_Button_Area   = rgb(200,200,200)  ,_  'Button area bckgnd color
            Color_ButtonTxt     = rgb (0,0,0)       ,_  'Button Text color
            Color_LabelTxt      = rgb (0,0,0)       ,_
            Color_MenuInactive  = rgb(236,233,216)  ,_
            Color_MenuBar       = rgb(236,233,216)  ,_  'Menu bar background at top of window
            Color_MenuTxt       = rgb(0,0,0)        ,_
            Color_MenuTxtInactive = rgb(150,150,150) ,_
            Color_Menu_Focus_Txt = rgb(255,255,255),_
            Color_PopUP         = rgb (230,230,230) ,_
            Color_PopUpTxt      = rgb(0,0,0)        ,_
            Color_Plot          = rgb (0,0,0)       ,_  'Plotted points / lines color
            Color_Scale         = rgB (0,0,0)       ,_  'Scale bars color
            Color_Grid          = rgb (150,150,150) ,_  'Gridlines
            Color_TxtBoxTxt     = rgb(0,0,0)        ,_
            Color_Box_Enabled   = rgb(255,255,255)  ,_  'TxtBox background when enabled
            Color_Box_Focus     = rgb (245,245,245) ,_  'TxtBox background when GotFocus
            Color_Box_Clicked   = rgb (255,230,255) ,_  'TxtBox background when clicked
            Color_Transparent   = rgba(255,0,255,0) ,_  'background mask for transparency
            Color_MenuActiveBckgnd = rgb (49,106,197)
const Window_FullScreen = 1
DIM Shared as byte PopUP_Fade = FALSE           'Fade-in option for PopUps
dim shared dxsmin as integer = 1
dim shared dxsmax as integer 
dxsmax = Screen_Width *4\5
dim shared dysmin as integer = 1
dim shared dysmax as integer
dysmax = Screen_Height *.8
DIM shared as integer   SliderHeight    = 17    ,_ 
                        SliderWidth     = 9     ,_
                        Slider_Sleep    = 100   ,_  'sleep delay (msec) with button press on slider
                        Menu_Bar_Height = 19    ,_
                        MenuRowHeight           ,_
                        Menu_Col
dim SHARED as integer xsmin, xsmax, ysmin, ysmax
'Set current garphics port equal to default
xsmin = dxsmin: xsmax = dxsmax
ysmin = dysmin: ysmax = dysmax


'
' Keyboard scan codes
'Using fb
#Ifndef crlf
#Define crlf   Chr(13) + Chr(10)
#EndIf
DIM Shared as Integer   SleepTime = 2      'Time in ms for "sleep" during polling loops
'
' Function Declarations
DECLARE FUNCTION AxisDelta (byval x as single) as single
declare function CLIP(BYVAL X AS SINGLE, BYVAL SIGDIG AS INTEGER)AS SINGLE
DECLARE FUNCTION Decimal_Place(byval x as single, byval n as integer) as string
DECLARE FUNCTION DrawStringRotate (byval x as integer, byval y as integer, _
    byval Text as string, byval Myfont as any ptr, byval FontSize as integer, _
    byval angle as integer)as byte
DECLARE FUNCTION Get_Ctrl_Indx (byval Lbl as string) as integer
DECLARE FUNCTION GetFileName (byval Prompt as string, byval FileExt as string) as string
DECLARE FUNCTION Get_Input (byval Prompt as string) as string
DECLARE FUNCTION Get_Input_PopUp (Prompt () as string, byval Txt_Label as string, _
    byval Txtdef as string) as string
Declare Function FileOpenSaveDialog(iMode As Integer,Byval szTitle As Zstring Ptr ,_
    Byval szInitialDir As Zstring Ptr, Byval _szFilter As Zstring Ptr, _
    Byval szName As Zstring Ptr) As String
'--------------------------------
' These Win32 declarations are required only for FileSelectFolder routines
#include Once "win/shlobj.bi"
Type FOLDER_PROPS
        Dim lpszTitle As Zstring Ptr
        Dim lpszInitialFolder As Zstring Ptr
        Dim As Uinteger ulFlags
End Type
'-------------------------------
DECLARE Function FileExist (byval fname as string) as byte
DECLARE Function FileSelectFolder (Byref title As String = "Choose A Folder", _
    Byval nCSIDL As Integer, iFlags As ULong = BIF_EDITBOX, _
    Byref sz_InitialDir As String) As String
DECLARE Function FileSelectFolder_callback (Byval hwndbrowse As HWND, Byval uMsg As UINT, _
  Byval lp As LPARAM, Byval lpData As LPARAM) As Integer
DECLARE Function Parse_Text (byval text as string, _
    byval Tlen as integer) as integer
DECLARE FUNCTION QUERY (byval Prompt as string) as byte
DECLARE FUNCTION RoundSym (byval x as single) as single
DECLARE FUNCTION ScrnBMP ()as byte
DECLARE FUNCTION SignifDig (byval x as single, byval n as integer) as string
'
' Subroutine Declarations
'
DECLARE SUB Box_3D (byval x as integer, byval y as integer, _
    byval w as integer, byval h as integer, byval Color_Main as uinteger, byval CtrlPtr as any ptr = 0)
DECLARE SUB Box_Print (byval MyString as string)
DECLARE SUB Clear_All()
DECLARE SUB ClearEvents () 
DECLARE SUB Close_PopUp ()
DECLARE SUB ClrScrn ()
DECLARE SUB Cmmd_Buttons_Main (B as Control ptr, byref NumButtons as integer)
DECLARE SUB Create_Menu (byval NumMenu as integer, byref FirstMenuCtrl as integer)
DECLARE SUB Create_Scroll (byval xr as integer, byval yd as integer, _
    byval S_length as integer, byval S_type as string)
    
DECLARE SUB Data_Form overload (FormLabel() as string, FormContent() as string, _
    byval Box_Width as integer, byval FormTitle as string)
DECLARE SUB Data_Form overload (FormLabel() as string, FormContent() as string, _
    byval Box_Width as integer)    
DECLARE SUB Data_Form_proc overload (FormLabel() as string, FormContent() as string, _
    byval Box_Width as integer, byval FormTitle as string)     

DECLARE SUB DrawString_Custom overload (byval target as any ptr = 0, byval x as integer, byval y as integer, _
    byval Text as string, _
    byval FontName as string, _
    byval Fore_Color as uinteger = rgb(0,0,0), _
    byval Back_Color as uinteger = rgba(255,0,255,0), _
    byval Rotation as integer = 0)
    
DECLARE SUB DrawString_Custom (byval x as integer, byval y as integer, _
    byval Text as string, _
    byval FontName as string, _
    byval Fore_Color as uinteger = rgb(0,0,0), _
    byval Back_Color as uinteger = rgba(255,0,255,0), _
    byval Rotation as integer = 0)
    
declare sub DrawString_Xfont (byval target as any ptr, byval x as integer, byval y as integer, _
    byval Text as string, _
    byval FontName as string, _
    byval Fore_Color as uinteger, _
    byval Back_Color as uinteger, _
    byval Rotation as integer)

DECLARE SUB Disable (byval label as string)
DECLARE SUB Draw_Pop_UP (byval PopUp_indx as integer)
DECLARE SUB Draw_Scroll ()
DECLARE SUB Enable_Controls ()
DECLARE SUB Hi_Light (byval x as integer, byval y as integer, byval wid as integer, _
    byval hgt as integer, byval dirn as byte)
DECLARE SUB Hint (byval Prompt as string, byval x as integer, byval y as integer)
DECLARE SUB Kill_Ctrl (byref lbl as string)
DECLARE SUB Kill_PopUp (byref indx as integer)
DECLARE SUB ListBox_Button (byval x as integer, byval y as integer, byval state as byte)
DECLARE SUB ListBox_Process ()
DECLARE SUB Menu_Process()
'DECLARE SUB Menu_Toggle()
DECLARE SUB Mouse_Update()
DECLARE SUB Mouse_PopUp_Process()
DECLARE SUB Mssg_Box overload (Prompt() as string, byval title as string)
DECLARE SUB Mssg_Box overload (byval Prompt as string, byval title as string)
DECLARE SUB plot overload (byval x as single, byval y as single, byval xmin as single, _
    byval ymin as single, byval xmax as single, byval ymax as single, _
    byval pcol as uinteger, byval pstyle as integer)
DECLARE sub plot overload (byval x as single, byval y as single, byval xmin as single, _
    byval xmax as single, byval ymin as single, byval ymax as single, _
    byval ptcol as uinteger, byval pstyle as integer, byval radius as single)
DECLARE SUB PROTECT ()
DECLARE SUB RestVid ()
DECLARE SUB SaveVid ()
' Default Subs to Serve Controls
DECLARE SUB Serve_CheckBox ()
DECLARE SUB Serve_CmdButton ()
DECLARE SUB Serve_KeyPress (byval Key as integer)
DECLARE SUB Serve_ListBox()
DECLARE SUB Serve_PopUp ()
DECLARE SUB Serve_PulldownMenu ()
DECLARE SUB Serve_Slider ()
#Ifndef User_Serve_SLIDER   
    Sub Serve_Slider ()     'Direct call to Sub Serve_Slider from FB_GUI.BAS
    end sub                 'Therefore define here if NOT defined by User Main. 
#Endif
DECLARE SUB Serve_TxtBox()
'''''''''''''''''''''''''''''''''''''''
DECLARE SUB Set_Scroll_Len(byval Bar_len as integer)
'DECLARE SUB SetFonts()
DECLARE SUB SetPanel (byval Pwidth as integer)
DECLARE sub SetVideo (byval Title as string, byval Panels as integer = 0, byval PWidth as integer = 0)
DECLARE SUB ShutDown ()
DECLARE SUB Slider_Process()
DECLARE SUB SubPlot (byval z1 as single, byval z2 as single, byval z3 as single, byval z4 as single)
DECLARE SUB Text_To_File (byval x as integer, byval y as integer, byval Max_Char as integer, _
    byval Num_Line as integer, byval FN as integer, byval Title as string)
DECLARE SUB TextBox_Process ()    
DECLARE SUB TitleBar (byval x as integer, byval y as integer, byval mssg as string, _
    byval Bck_color as uinteger, byval Brd_color as uinteger)
DECLARE SUB UpDate_Menu (byval Indx as integer)
DECLARE SUB wait_any_key ()
DECLARE SUB WIPE ()
DECLARE SUB xaxis (byval xmin as single, byval xmax as single, byval ymin as single, _
    byval ymax as single, byval ntic as integer, byval offset as single, _
    byval LogFlg as byte = FALSE, byval xlabel as string = "")
DECLARE SUB XY_Axis_Range (byref xymin as single, byref xymax as single)
DECLARE SUB yaxis (byval xmin as single, byval xmax as single, byval ymin as single, _
    byval ymax as single, byval ntic as integer, byval offset as single, byval ylabel as string = "")


' Older components for backward compatibility
Sub SetFonts
    
end sub

'
' Array in FB.Image format to create an 8x8 pixel checkmark.
' Prevents having to use Bload on check8.bmp image file.
dim shared as uinteger image_check(0 to 71) => { _
  &H00000007, &H00000004, &H00000008, &H00000008, &H00000020, &H00000000 _
, &H00000000, &H00000000, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC _
, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC _
, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFE3E3E3 _
, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC _
, &HFFD4D4D4, &HFF4A4A4A, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC, &HFFFCFCFC _
, &HFFFCFCFC, &HFFD4D4D4, &HFF5A5A5A, &HFFCCCCCC, &HFFE3E3E3, &HFFFCFCFC _
, &HFFFCFCFC, &HFFFCFCFC, &HFFD4D4D4, &HFF5A5A5A, &HFFD4D4D4, &HFFF4F4F4 _
, &HFF4A4A4A, &HFFD4D4D4, &HFFF4F4F4, &HFFD4D4D4, &HFF5A5A5A, &HFFCCCCCC _
, &HFFF4F4F4, &HFFF4F4F4, &HFFCCCCCC, &HFF5A5A5A, &HFFBBBBBB, &HFF5A5A5A _
, &HFFCCCCCC, &HFFF4F4F4, &HFFF4F4F4, &HFFF4F4F4, &HFFFCFCFC, &HFFCCCCCC _
, &HFF454545, &HFFC5C5C5, &HFFF4F4F4, &HFFF4F4F4, &HFFF4F4F4, &HFFF4F4F4 }


'Macro for Menu_Toggle to update status of submenu items on drop-down menu
#Define Menu_toggle : _
    B[Active_Ctrl.Active_Menu].state = Ctrl_Status_Clicked : _
    Menu_Process()                                         : _     'go back to menu
    Serve_PulldownMenu

