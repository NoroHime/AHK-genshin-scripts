/**
 *	ͨ��ʵ��ԭ�����ʰȡ��������Ծ��������׼�����Զ����͵ȹ���ѧϰAutoHotKey����
 *	ԭ���⣺ͨ��AutoHotKey(AHK)ʵ��ԭ�����ʰȡ��������Ծ��������׼�����Զ�����
 * 	����Ǵ�SnapHutaoʱ����俴��BetterGI��Ŀ��ͨ������Ļ���г�����ͼ��ʶ�����ݣ��������Ĳ�С������ʱ�����Ҳ�֧��21��9��Ļ������������������Ҫ�Ĺ��ܲ����࣬��������ѧϰAHK����
 * 	����֧�֣�
 * 		- ChatGPT���󲿷ֹ����ɳ���ѯ��ChatGPT 3.5 Turboʵ�֣�����Щ������ڸ������ջ���ȥ�����ĵ�
 * 		- Google�����У������˲��������
 *
 */

/*
readme.md

# AHK-genshin-scripts

*���ýű����ֿ�����浵*

## ʹ��
1. ǰ��AHK������װ[AutoHotKey](https://www.autohotkey.com/)���ű�׫дʱ��ʹ�õ�Ϊ[v2�汾](https://www.autohotkey.com/download/ahk-v2.exe)��
2. ���ز���[genshin-scripts.ahk](https://github.com/NoroHime/AHK-genshin-scripts/raw/main/genshin-scripts.ahk)���ű����Զ��������ԱȨ�ޣ�ԭ�����������Ȩ�ޱȽϸߣ���Ҫ��ô����
3. ������AHK������������ʾʱ���ű���Ϊ��Ч״̬
4. �����Ϸʹ�õ�Ϊ���������ϵĶ�ռȫ�������޷������ű���ToolTip������ʾ��

## ԭ��
 - ����ʰȡ��`Ctrl+F`�л�����
   - ��ס������`F`ʱ����ʰȡ���ɿ���ȡ��
   - �رգ������κ�����
 - �Զ���Ծ��`Ctrl+�ո�`�л����أ���ס�ո񴥷�
 - ����`M��`�������ٴ��͹��ܣ�����ʱ��`F`�Զ�������Ͱ�ť
 - �Ҽ���������ɫ "����-R-��" �ű�
 - ��ס`Ctrl+���ּ�`�Զ��л��ý�ɫ���ͷ�Ԫ�ر����������滻��Ϸ�Դ���`Alt+���ּ�`���ܣ��Ұ���ʱ�������`Q`�����������ӳ���һ���ݴ���
 - ��ס`Ctrl+W` ��Ч��̽ű�
 - ������ʷ����й���½������
 - `Ctrl+Q` QM��ݼ�

## �������
- `F��`������`Shift+F`�л��ù���
- ����겻������Ļ����ʱ��`F`�Զ�������Ͱ�ť��Ҳ�ɰ���`Ctrl+F`ǿ�ƴ����ù���

## ���׽���
- `F��`����
- ����`ESC��`�������ٵ���Ի����ܣ�����ʱ��`F`�Զ�������Ͱ�ť��ֱ������`�����ƶ���`ȡ�����ܣ�Ҳ�ɰ���`Ctrl+F`ǿ�ƴ����ù���

## ɭ��֮��
- ��ס`F`ʱ�����`E`ʰȡ

*/

;============================================
; ���ʷ�����������ԭ��֧��
;============================================
GroupAdd, genshin, ahk_exe YuanShen.exe
GroupAdd, genshin, ahk_exe GenshinImpact.exe
GroupAdd, genshin, ahk_exe Genshin Impact Cloud Game.exe

;============================================
; ��ֹ�ȼ�����Ƶ������������
;============================================
#HotkeyInterval 20
#MaxHotkeysPerInterval 20000

;============================================
; �������ԱȨ��
;============================================
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
	try {
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}


;F������ʼ״̬
toggle_F := 1
;��ʹ���л�ʰȡʱ��Ĭ���Ƿ��
always_F := 0
;�ո�������ʼ״̬
toggle_space := 0
;�ո��������ܿ���
SpaceBurst := 0
;˽�˹��ܿ��أ���uid��
privates := 10
RightButtonFeatures := 0

;ʹMouseMove��ʱ���
SetDefaultMouseSpeed, 1

;============================================
; �Ƴ���ʾ�ĸ�������
; �÷���SetTimer, RemoveToolTip, 1000
;============================================
RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

;============================================
; ������Ƿ�λ����Ļ�������ж�ս��״̬ tolerance���ݴ�����
;============================================
IsMouseAtCenterOfActiveWindow(tolerance=3) {
	; ��ȡ����ھ������ߴ�
	WinGetActiveStats, winTitle, winWidth, winHeight, winX, winY

	; ���㴰����������
	centerX := winX + (winWidth // 2)
	centerY := winY + (winHeight // 2)
	
	; ��ȡ��굱ǰ����
	MouseGetPos, mouseX, mouseY
	mouseX += winX
	MouseY += winY

	; �������Ƿ����ݴ�Χ��
	return Abs(mouseX - centerX) <= tolerance && Abs(mouseY - centerY) <= tolerance
}


#IfWinActive, ahk_group genshin

	;============================================
	; ��ס[F]ʱ����ʰȡ��[Ctrl+F]�л�����
	;============================================

	~^F::
		toggle_F := !toggle_F

		if (toggle_F)
			ToolTip, ����ʰȡ����
		else
			ToolTip, ����ʰȡ����

		SetTimer, RemoveToolTip, 1000

	return

	~$*F::
		if inputing
		return

		if (!IsMouseAtCenterOfActiveWindow() || map_just_started) {
			WinGetPos, X, Y, Width, Height, ahk_group genshin
			if (!GetKeyState("LButton", "P"))
				MouseMove Width - 110, (Height * 0.92)
			Click
			Sleep 50
		} else if (toggle_F) {
			while (GetKeyState("F", "P") && WinActive("ahk_group genshin")) {

				SendInput, f

				times += 1
				if (times == 4) {
					times := 0
					SendInput {wheeldown}
				}

				Sleep, 20
			}
		}
	return

	;============================================
	; ����״̬���
	;============================================
	~*Enter::
		inputing := 1
	return

	~*LButton::
		if (inputing) {
			Sleep, 200
			if (IsMouseAtCenterOfActiveWindow()) {

				inputing := 0
			}
		}
		map_just_started := 0
	return

	~*Tab::
	~*M::
		map_just_started := 1
	return

	~*ESC::
		inputing := 0
		map_just_started := 0
	return

	;W�¼��ϲ�����[Ctrl+W]����
	~*S::
	~*A::
	~*D::
		map_just_started := 0 
	return

	;============================================
	; [F2] ������ť���۽�������
	;============================================
	~*F2::

		inputing := 0
		map_just_started := 0
		Sleep, 500

		WinGetPos, X, Y, Width, Height, ahk_group genshin

		MouseMove Width * 0.5, (Height * 0.5)
		SendInput {LButton down}
		SetDefaultMouseSpeed, 5
		MouseMove Width * 0.5, (Height * 0.5) - 90
		Sleep, 100
		SetDefaultMouseSpeed, 1
		SendInput {LButton up}
		
		MouseMove Width * 0.5, (Height * 0.1)
		click
	return


	;============================================
	; [�ո�]������[Ctrl+�ո�]�л�
	;============================================
	~^Space::

		if !SpaceBurst
		return

		toggle_space := !toggle_space
		if (toggle_space)
			ToolTip, �Զ��ո񣺡�
		else
			ToolTip, �Զ��ո񣺡�
		SetTimer, RemoveToolTip, 1000
	return

	~$*space::
		while (toggle_space && GetKeyState("Space", "P") && WinActive("ahk_group genshin")) {
			SendInput, {space}
			Sleep, 10
		}
	return

	;============================================
	;������д״̬ ��bug�Բߣ�
	;============================================
	~*CapsLock up::
		SetCapsLockState, Off
	return

	;============================================
	; ����-R-����
	;============================================
	*RButton::
		if (!RightButtonFeatures) {
			SendInput, {RButton down}
			return
		}

		SendInput, r
	return

	*RButton Up::
		if (!RightButtonFeatures) {
			SendInput, {RButton up}
			return
		}
		click
		SendInput, {LShift down}
		Sleep, 10
		SendInput, {LShift up}
	return

	~*^RButton::
		RightButtonFeatures := !RightButtonFeatures
		if (RightButtonFeatures)
			ToolTip, ����-R-���ܣ���
		else
			ToolTip, ����-R-���ܣ���
		SetTimer, RemoveToolTip, 1000
	return

	;============================================
	; [Ctrl+���ּ�]�л���ɫ�������У����õ�Alt+���ּ���
	;============================================
	~*^1::
	~*^2::
	~*^3::
	~*^4::
		while (GetKeyState("Ctrl", "P")) {
			SendInput, q
			Sleep, 10
		}
	return

	;============================================
	; [Ctrl+Q] QM��ݼ�
	;============================================
	~$*^Q::
		map_just_started := 1
		SendInput, q
		Sleep, 1
		SendInput, m
	return

	;============================================
	; [Ctrl+W] ��Ч���ѭ��
	;============================================
	ctrlComboPressed := 0

	TimerShift() {

		if (GetKeyState("Ctrl", "P")) {
			SendInput, {Shift up}
			Sleep, 1
			SendInput, {Shift down}
		} else {
			SendInput, {Shift up}
			SetTimer, TimerShift, Off
		}
	}

	~*Ctrl::	
	~*^W::
	~*W::
		map_just_started := 0

		if (!ctrlComboPressed && GetKeyState("Ctrl", "P") && GetKeyState("W", "P")) {

			ctrlComboPressed := 2
			TimerShift()
			SetTimer, TimerShift, 800
		}
	return

	~*Ctrl up::
	~*^W up::
	~*W up::
		SendInput, {Shift up}
		SetTimer, TimerShift, Off
		ctrlComboPressed := 0
	return

	;============================================
	; [Ctrl+S] F2���������루˽�ˣ�
	;============================================
	*^S::
		if !privates {
			SendInput, {^s}
			return
		}

		WinGetPos, X, Y, Width, Height, ahk_group genshin
		MouseMove Width * 0.87, (Height * 0.1)
		Click
		Sleep 70
		MouseMove Width * 0.87, (Height * 0.22)
		Click
		Sleep, 1
		MouseMove Width * 0.5, (Height * 0.1)
		Click

	return

#IfWinActive

;============================================
; [Ctrl+S] ��uid����
;============================================
#IfWinActive, QQƵ��
	*^S::
		Clipboard := ""
		SendInput ^c
		ClipWait 1

		SetTimer, RemoveToolTip, 2000

		; ����ӳ���ϵ
		Mappings := "��1 ��2 ��3 ��4 ��5 ��6 ��7 ��8 ��9 ??0 һ1 ��2 ��3 ��4 ��5 ��6 ��7 ��8 ��9 ��0 Ҽ1 ��2 ��3 ��4 ��5 ½6 ��7 ��8 ��9"  ; ʹ�ÿո�ָ�ӳ���

		; �����ַ���
		OutputStr := Clipboard

		; �滻�ַ�
		Loop, Parse, Mappings, %A_Space%  ; ����ӳ���
		{
			If (A_LoopField != "")  ; �������ַ���
			{
				FromChar := SubStr(A_LoopField, 1, 1)  ; ��ȡ��һ���ַ���ΪҪ�滻���ַ�
				ToChar := SubStr(A_LoopField, 0)  ; ��ȡ�ڶ����ַ���Ϊ�滻����ַ�
				StringReplace, OutputStr, OutputStr, %FromChar%, %ToChar%, All
			}
		}

		; ȥ��ʣ��ķ������ַ�
		outputStr := RegExReplace(outputStr, "[^0-9]")
		; ��ȡ9λ����
		outputStr := RegExReplace(outputStr, "^\D*(\d{9}).*", "$1")

		; �����ַ���д�������
		Clipboard := trim(outputStr)

		ToolTip, %Clipboard%

		if (strlen(Clipboard) <> 9) {
			ToolTip, �������� %Clipboard%
			return
		}

		GroupActivate, genshin, r
		WinGetPos, X, Y, Width, Height, ahk_group genshin

		MouseMove Width * 0.3, (Height * 0.1)
		click
		sleep, 2

		SendInput ^v
		sleep, 2

		MouseMove Width * 0.87, (Height * 0.1)
		Click
		Sleep 70

		MouseMove Width * 0.87, (Height * 0.22)
		; Click
	return
#IfWinActive


















































;============================================
; ������Ϸ
;============================================
#IfWinActive, ahk_exe StarRail.exe

	+F::
		toggle_F := !toggle_F

		if (toggle_F)
			ToolTip, F����������
		else
			ToolTip, F����������

		SetTimer, RemoveToolTip, 1000
	return


	~$*F::
		if inputing
		return

		if (!IsMouseAtCenterOfActiveWindow() || GetKeyState("Ctrl", "P"))
		{
			WinGetPos, X, Y, Width, Height, ahk_exe StarRail.exe
			MouseMove Width - 110, (Height * 0.89)
			Click
			Sleep 20
		}
		else
		{
			while (toggle_F && GetKeyState("F", "P") && WinActive("ahk_exe StarRail.exe"))
			{
				SendInput, {f}
				Sleep, 10
			}
		}
	return

	;���Ϊ������
	~*Enter::
		inputing := 1
	return

	~*LButton::
		inputing := 0
	return

#IfWinActive

#IfWinActive, ���׽���

	
	map_just_started := 0

	~$*F::
		if (map_just_started || GetKeyState("Ctrl", "P"))
		{
			WinGetPos, X, Y, Width, Height, ���׽���
			MouseMove Width * 0.7, Height * 0.7
			Click
			Sleep 20
		}
		else
		{
			while (GetKeyState("F", "P") && WinActive("���׽���") && !map_just_started)
			{
				SendInput, {f}
				Sleep, 10
			}
		}
	return

	~*ESC::
		map_just_started := 1
	return

	~*W::
	~*S::
	~*A::
	~*D::
		map_just_started := 0
	return

#IfWinActive

#IfWinActive, ahk_exe SonsOfTheForest.exe
	~*F::
		while (GetKeyState("F", "P") && WinActive("ahk_exe SonsOfTheForest.exe"))
		{
			SendInput, {e}
			Sleep, 10
		}
	return
#IfWinActive