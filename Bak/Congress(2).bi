/' +---------------------------------------------------+
   |                    Congress Game                  |
   |               Written by Nick Lauber              |
   | This game is written as a simulation of Congress. |
   |     Code licensced under the GNU GPL License      |
   +---------------------------------------------------+
   |                  Main Header File                 |
   +---------------------------------------------------+'/

' Define Version
#Define __Congress_Version__ "1.1.0.5"
#Define __BUILD_Date__ "10-28-2010"

' Intitialize Global Variables
Common Shared Score As Integer
Common Shared SScore As String

Common Shared issue() As String
Dim issue(1 To 20) As String

Common Shared issuen As Integer
Common Shared issue_chosen As String

Common Shared total_issues As Integer
Common Shared used_issues() As Integer
Dim used_issues(1 To 20) As Integer

Common Shared Vote() As Integer
Dim Vote(1 To 20) As Integer
Common Shared People_Vote As Integer

Common Shared As Integer reelection
