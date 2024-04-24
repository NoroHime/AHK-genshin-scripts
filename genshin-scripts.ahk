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

GroupAdd, QQchannel, QQƵ��
GroupAdd, QQchannel, ͼƬ�鿴��

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
;�ո�������ʼ״̬
toggle_space := 1
;˽�˹��ܿ��أ��������uid��
privates := 1
;����-R-���ܹ��ܳ�ʼ״̬
toggle_mouseright := 0

;ʹMouseMove��ʱ���
SetDefaultMouseSpeed, 1

;============================================
; ��������
;============================================
RemoveToolTip() {
	ToolTip
	return
}

echo(text, timeout = 1000, positions = "top random center") {

	WinGetPos, winX, winY, Width, Height, A

	if (InStr(positions, "center")) {
		posX := winX + Width / 2
		PosY := winY + Height / 2
	} else
		MouseGetPos, posX, posY

	posY -= 10
	posX -= 7 * strlen(text)

	if (InStr(positions, "rand")) {
		Random randomX, -96, 96
		Random randomY, -96, 96
		posX += randomX
		posY += randomY
	}

	if (InStr(positions, "up") || InStr(positions, "top"))
		posY -= Height / 2 * 0.75

	if (InStr(positions, "down") || InStr(positions, "bottom"))
		posY += Height / 2 * 0.75

	if (InStr(positions, "left"))
		posX -= Width / 2 * 0.75

	if (InStr(positions, "right"))
		posX += Width / 2 * 0.75


	ToolTip, %text%, %posX%, %posY%
	SetTimer, RemoveToolTip, %timeout%
}

;============================================
; ���ĳ�����ص�ֵ
;============================================
CheckPixelColor(TargetColor, x, y) {
    ; ��ȡָ�������������ɫ
    PixelGetColor, ScreenColor, %x%, %y%
    ; ToolTip, screen %ScreenColor% target %TargetColor%
    ; �Ƚ���ɫ�Ƿ���ͬ
    return ScreenColor = TargetColor
}

;============================================
; ������Ƿ�λ����Ļ�������ж�ս��״̬ tolerance���ݴ�����
;============================================
IsMouseAtCenterOfActiveWindow(tolerance = 3) {
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

;============================================
; �����а������Ƿ�ΪͼƬ
;============================================
IsClipboardImage() {
    ; �򿪼�����
    r := DllCall("OpenClipboard", "ptr", A_ScriptHwnd)
    
    ; ��ȡ�������е����ݸ�ʽ
    formats := DllCall("IsClipboardFormatAvailable", "uint", 0x8, "uint")
    
    ; �رռ�����
    r := DllCall("CloseClipboard")
    
    ; �ж��Ƿ����ͼƬ��ʽ
    Return formats
}

#IfWinActive, ahk_group genshin

	;============================================
	; ��ס[F]ʱ����ʰȡ��[Ctrl+F]�л�����
	;============================================

	~^F::
		toggle_F := !toggle_F

		if (toggle_F)
			echo("����ʰȡ����", 1000)
		else
			echo("����ʰȡ����", 1000)

	return

	MakeTeleport() {
		WinGetPos, X, Y, Width, Height, ahk_group genshin
		MouseGetPos, mouseX, mouseY
		BlockInput On
		MouseMove Width - 110, (Height * 0.93)
		Click
		MouseMove %mouseX%, %mouseY%
		BlockInput Off
	}

	*^ESC::
		SendInput {esc}
		Sleep, 700
		WinGetPos, X, Y, Width, Height, ahk_group genshin
		MouseGetPos, mouseX, mouseY
		BlockInput Mouse
		MouseMove Width * 0.045, Height * 0.95
		Click
		Sleep, 20
		MouseMove Width * 0.575, Height * 0.7
		click
		BlockInput Off
	return

	~$*F::
		if inputing
		return

		if (!IsMouseAtCenterOfActiveWindow() || map_just_started) {

			if (!GetKeyState("LButton", "P")) {
				MakeTeleport()
			}
			Sleep 50
		} else if (toggle_F) {
			while (GetKeyState("F", "P") && WinActive("ahk_group genshin") && !inputing && !map_just_started) {

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

	SendMessage(text) {
		SendInput {Enter}
		Sleep, 100
		SendInput {enter}
		Sleep, 30
		Clipboard := text
		SendInput ^v{enter}
		Sleep, 10
		SendInput {esc}
	}

	~*^Numpad3::
		if (!privates)
		return
		SendMessage("лл����ף�����彡��")
		Sleep, 10
		SendInput, {f2}

		WinGetPos, X, Y, Width, Height, ahk_group genshin
		BlockInput Mouse
		Sleep, 450
		MouseGetPos, mouseX, mouseY
		MouseMove Width * 0.865, Height * 0.96
		click
		MouseMove %mouseX%, %mouseY%
		BlockInput off

	return

	~*^Numpad2::
		if (!privates)
		return
		SendMessage("̧ͷ�ܿ������㹳צ�����Կ�������")
	return

	~*^Numpad1::
		if (!privates)
		return

		texts := [ "����һ������ģ��ʹ��������Ӣ�֣�����ռ�úܶ�ʱ��"]
		len := texts.Length()
		Random, idx, 1, %len%
		SendMessage(texts[idx])
	return

	~*^Numpad4::
		if (!privates)
		return
		SendMessage("�ڱ��Ͽ�Ϸ��ok������Ӧ�ÿ�����������ֵ�")
	return

	;============================================
	; ����״̬���
	;============================================
	~*Enter::
		inputing := 1
		echo("��������ģʽ")
	return

	~*LButton up::
		if (inputing) {
			Sleep, 300
			if (IsMouseAtCenterOfActiveWindow()) {
				inputing := 0
				echo("�˳�����ģʽ")
			}
		}
		map_just_started := 0
	return

	~*Tab::
	~*M::
		if (GetKeyState("Alt", "P") && GetKeyState("Tab", "P"))
			return
		map_just_started := 1
		echo("�����ͼ")
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

		WinGetPos, X, Y, Width, Height, ahk_group genshin

		if (GetKeyState("Ctrl", "P")) {
			BlockInput Mouse
			Sleep, 500

			SendInput {wheeldown}
			Sleep, 1
			SendInput {wheeldown}
			Sleep, 1
			SendInput {wheeldown}
			Sleep, 1

			
			if (!privates) {
				MouseMove Width * 0.5, (Height * 0.1)
				click
			}
			BlockInput off
			if (privates && WinExist("ahk_group QQchannel"))
				GroupActivate, QQchannel, r

			return
		}

		if (GetKeyState("Shift", "P")) {
			BlockInput Mouse
			Sleep, 450
			MouseGetPos, mouseX, mouseY
			MouseMove Width * 0.865, Height * 0.96
			click
			MouseMove %mouseX%, %mouseY%
			BlockInput off

			return
		}

	return

	*F3::F2


	;============================================
	; [�ո�]������[Alt+�ո�]�л�
	;============================================
	~!Space::

		toggle_space := !toggle_space
		if (toggle_space)
			echo("�Զ��ո񣺡�")
		else
			echo("�Զ��ո񣺡�")
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
	$*RButton::

		if ((!IsMouseAtCenterOfActiveWindow() || map_just_started)) {
			BlockInput On
			click
			map_just_started := 0
			sleep, 120

			if (CheckPixelColor(0x66534A, Width - 110, Height * 0.93)) {
				MakeTeleport()
			} else {
				WinGetPos, X, Y, Width, Height, ahk_group genshin
				sleep, 300
				MouseMove Width * 0.69, Height * 0.69
				click
				Sleep, 10
				if (CheckPixelColor(0x66534A, Width - 110, Height * 0.93))
					MakeTeleport()
			}
			BlockInput Off
		} else if (!toggle_mouseright) {
			SendInput, {RButton down}
			return
		}

		SendInput, r
	return

	$*RButton Up::
		if (!toggle_mouseright) {
			SendInput, {RButton up}
			return
		}
		click
		SendInput, {RButton down}
		Sleep, 10
		SendInput, {RButton up}
	return

	~*^RButton::
		toggle_mouseright := !toggle_mouseright
		if (toggle_mouseright)
			echo("����-R-���ܣ���")
		else
			echo("����-R-���ܣ���")
	return

	;============================================
	; [Ctrl+���ּ�]�л���ɫ�������У����õ�Alt+���ּ���
	;============================================
	~*^1::
	~*^2::
	~*^3::
	~*^4::
		while (GetKeyState("1", "P")) {
			SendInput, 1q
			Sleep, 10
		}
		while (GetKeyState("2", "P")) {
			SendInput, 2q
			Sleep, 10
		}
		while (GetKeyState("3", "P")) {
			SendInput, 3q
			Sleep, 10
		}
		while (GetKeyState("4", "P")) {
			SendInput, 4q
			Sleep, 10
		}
	return

	;============================================
	; [Ctrl+Q] QM��ݼ�
	;============================================
	$*^Q::
		map_just_started := 1
		SendInput, q
		Sleep, 10
		SendInput, m
	return

	;============================================
	; [Ctrl+W] ��Ч���ѭ��
	;============================================
	ctrlComboPressed := 0

	TimerShift() {

		if (GetKeyState("Ctrl", "P")) {
			SendInput, {RButton up}
			Sleep, 1
			SendInput, {RButton down}
		} else {
			SendInput, {RButton up}
			SetTimer, TimerShift, Off
		}
	}

	~*^Space::
	~*Ctrl::
	~*^W::
	~*W::
		map_just_started := 0

		if (GetKeyState("Space", "P")) {
			while (toggle_space && GetKeyState("Space", "P") && GetKeyState("Ctrl", "P") && WinActive("ahk_group genshin")) {
				SendInput, {space}
				Sleep, 10
			}
		} else if (!ctrlComboPressed && GetKeyState("Ctrl", "P") && GetKeyState("W", "P")) {

			ctrlComboPressed := 1
			TimerShift()
			SetTimer, TimerShift, 820
		}
	return

	~*Ctrl up::
	~*^W up::
	~*W up::
		SendInput, {RButton up}
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
		Sleep 80
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
#IfWinActive, ahk_group QQchannel
	*^S::

		; �����ɼ��а�
		clipboardOld := Clipboard
		; ��ռ�����
		Clipboard := ""
		; ����
		SendInput ^c
		; �ȴ����а����
		ClipWait 1

		; ����ӳ���ϵ
		Mappings := "��1 ��2 ��3 ��4 ��5 ��6 ��7 ��8 ��9 һ1 ��2 ��3 ��4 ��5 ��6 ��7 ��8 ��9 ��0 Ҽ1 ��2 ��3 ��4 ��5 ½6 ��7 ��8 ��9"  ; ʹ�ÿո�ָ�ӳ���

		; �����ַ���
		outputStr := Clipboard

		;============================================
		; OCRͼ��ʶ���ܣ�ע�����л�����
		;============================================
		; #include <vis2>
		; if (IsClipboardImage()) {
		; 	outputStr := OCR(Clipboard)
		; }

		; �滻�ַ�
		Loop, Parse, Mappings, %A_Space%  ; ����ӳ���
		{
			If (A_LoopField != "") {
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

		echo(outputStr)

		if (strlen(Clipboard) <> 9) {
			echo(�������� %Clipboard%)
			return
		}

		GroupActivate, genshin, r
		WinGetPos, X, Y, Width, Height, ahk_group genshin

		MouseMove Width * 0.3, (Height * 0.1)
		click
		sleep, 2

		SendInput ^v
		sleep, 2

		Clipboard := clipboardOld

		MouseMove Width * 0.87, (Height * 0.1)
		Click
		Sleep 70

		MouseMove Width * 0.87, (Height * 0.22)
		Click
	return
#IfWinActive
















































;============================================
; ������Ϸ
;============================================
#IfWinActive, ahk_exe StarRail.exe

	+F::
		toggle_F := !toggle_F

		if (toggle_F)
			echo("F����������")
		else
			echo("F����������")

	return


	~$*F::
		if inputing
		return

		if (!IsMouseAtCenterOfActiveWindow() || GetKeyState("Ctrl", "P")) {
			WinGetPos, X, Y, Width, Height, ahk_exe StarRail.exe
			MouseGetPos, mouseX, mouseY
			BlockInput Mouse
			MouseMove Width - 110, (Height * 0.89)
			Click
			MouseMove %mouseX%, %mouseY%
			BlockInput Off

		} else {
			while (toggle_F && GetKeyState("F", "P") && WinActive("ahk_exe StarRail.exe")) {
			
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