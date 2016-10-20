/' +---------------------------------------------------+
   |                    Congress Game                  |
   |               Written by Nick Lauber              |
   | This game is written as a simulation of Congress. |
   |     Code licensced under the GNU GPL License      |
   +---------------------------------------------------+
   |                   Randomizer Code                 |
   +---------------------------------------------------+'/

' Include Header File
#Include Once "Congress.bi"

' Radomize Issue number & count the used issues

issuen = Rnd * (24 - 1) + 1
Randomize 1.3456345 , 3
If issuen = 1 And used_issues(1) = 0 Then
	issue_chosen = issue(1)
	used_issues(1) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 2 And used_issues(2) = 0 Then
	issue_chosen = issue(2)
	used_issues(2) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 3 And used_issues(3) = 0 Then
	issue_chosen = issue(3)
	used_issues(3) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 4 And used_issues(4) = 0 Then
	issue_chosen = issue(4)
	used_issues(4) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 5 And used_issues(5) = 0 Then
	issue_chosen = issue(5)
	used_issues(5) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 6 And used_issues(6) = 0 Then
	issue_chosen = issue(6)
	used_issues(6) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 7 And used_issues(7) = 0 Then
	issue_chosen = issue(7)
	used_issues(7) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 8 And used_issues(8) = 0 Then
	issue_chosen = issue(8)
	used_issues(8) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 9 And used_issues(9) = 0 Then
	issue_chosen = issue(9)
	used_issues(9) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 10 And used_issues(10) = 0 Then
	issue_chosen = issue(10)
	used_issues(10) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 11 And used_issues(11) = 0 Then
	issue_chosen = issue(11)
	used_issues(11) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 12 And used_issues(12) = 0 Then
	issue_chosen = issue(12)
	used_issues(12) = 1
	total_issues = total_issues + 1
	
EndIf
If issuen = 13 And used_issues(13) = 0 Then
	issue_chosen = issue(13)
	used_issues(13) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 14 And used_issues(14) = 0 Then
	issue_chosen = issue(14)
	used_issues(14) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 15 And used_issues(15) = 0 Then
	issue_chosen = issue(15)
	used_issues(15) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 16 And used_issues(16) = 0 Then
	issue_chosen = issue(16)
	used_issues(16) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 17 And used_issues(17) = 0 Then
	issue_chosen = issue(17)
	used_issues(17) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 18 And used_issues(18) = 0 Then
	issue_chosen = issue(18)
	used_issues(18) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 19 And used_issues(19) = 0 Then
	issue_chosen = issue(19)
	used_issues(19) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 20 And used_issues(20) = 0 Then
	issue_chosen = issue(20)
	used_issues(20) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 21 And used_issues(21) = 0 Then
	issue_chosen = issue(21)
	used_issues(21) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 22 And used_issues(22) = 0 Then
	issue_chosen = issue(22)
	used_issues(22) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 23 And used_issues(23) = 0 Then
	issue_chosen = issue(23)
	used_issues(23) = 1
	total_issues = total_issues + 1
EndIf
If issuen = 24 And used_issues(24) = 0 Then
	issue_chosen = issue(24)
	used_issues(24) = 1
	total_issues = total_issues + 1
EndIf

People_Vote = Rnd * (3 - 0) + 0
Randomize 1.3456345 , 3
