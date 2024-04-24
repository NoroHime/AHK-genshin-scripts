/**
 *	通过实现原神快速拾取、持续跳跃、快速瞄准，半自动传送等功能学习AutoHotKey语言
 *	原标题：通过AutoHotKey(AHK)实现原神快速拾取、持续跳跃、快速瞄准，半自动传送
 * 	起初是打开SnapHutao时无意间看到BetterGI项目，通过对屏幕进行持续截图且识别内容，性能消耗不小且有延时，而且不支持21比9屏幕啊啊啊啊，所幸我需要的功能并不多，决定上手学习AHK语言
 * 	技术支持：
 * 		- ChatGPT，大部分功能由持续询问ChatGPT 3.5 Turbo实现，但有些问题过于复杂最终还是去看了文档
 * 		- Google，拜托，哪有人不用这个的
 *
 */

/*
readme.md

# AHK-genshin-scripts

*自用脚本，仓库仅供存档*

## 使用
1. 前往AHK官网安装[AutoHotKey](https://www.autohotkey.com/)，脚本撰写时，使用的为[v2版本](https://www.autohotkey.com/download/ahk-v2.exe)。
2. 下载并打开[genshin-scripts.ahk](https://github.com/NoroHime/AHK-genshin-scripts/raw/main/genshin-scripts.ahk)，脚本会自动申请管理员权限（原神与星穹铁道权限比较高，需要这么做）
3. 当看到AHK程序在托盘显示时，脚本即为生效状态
4. 如果游戏使用的为真正意义上的独占全屏，则无法看到脚本的ToolTip操作提示框

## 原神
 - 快速拾取：`Ctrl+F`切换功能
   - 按住：长按`F`时快速拾取，松开即取消
   - 关闭：不做任何事情
 - 自动跳跃：`Ctrl+空格`切换开关，按住空格触发
 - 按下`M键`开启快速传送功能，开启时按`F`自动点击传送按钮
 - 右键：弓箭角色 "蓄力-R-闪" 脚本
 - 按住`Ctrl+数字键`自动切换该角色并释放元素爆发，用于替换游戏自带的`Alt+数字键`功能，且按下时会持续按`Q`，对于网络延迟有一定容错性
 - 按住`Ctrl+W` 高效冲刺脚本
 - 适配国际服与中国大陆服进程
 - `Ctrl+Q` QM快捷键

## 星穹铁道
- `F键`连发，`Shift+F`切换该功能
- 当鼠标不处于屏幕中心时，`F`自动点击传送按钮，也可按下`Ctrl+F`强制触发该功能

## 尘白禁区
- `F键`连发
- 按下`ESC键`开启快速点击对话框功能，开启时按`F`自动点击传送按钮，直至按下`任意移动键`取消功能，也可按下`Ctrl+F`强制触发该功能

## 森林之子
- 按住`F`时候快速`E`拾取

*/

;============================================
; 国际服、国服、云原神支持
;============================================
GroupAdd, genshin, ahk_exe YuanShen.exe
GroupAdd, genshin, ahk_exe GenshinImpact.exe
GroupAdd, genshin, ahk_exe Genshin Impact Cloud Game.exe

GroupAdd, QQchannel, QQ频道
GroupAdd, QQchannel, 图片查看器

;============================================
; 防止热键过于频繁而触发提醒
;============================================
#HotkeyInterval 20
#MaxHotkeysPerInterval 20000

;============================================
; 申请管理员权限
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


;F连发初始状态
toggle_F := 1
;空格连发初始状态
toggle_space := 1
;私人功能开关（快捷输入uid）
privates := 1
;蓄力-R-闪避功能初始状态
toggle_mouseright := 0

;使MouseMove即时完成
SetDefaultMouseSpeed, 1

;============================================
; 辅助函数
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
; 检查某处像素的值
;============================================
CheckPixelColor(TargetColor, x, y) {
    ; 获取指定坐标的像素颜色
    PixelGetColor, ScreenColor, %x%, %y%
    ; ToolTip, screen %ScreenColor% target %TargetColor%
    ; 比较颜色是否相同
    return ScreenColor = TargetColor
}

;============================================
; 检测光标是否位于屏幕中心以判断战斗状态 tolerance：容错像素
;============================================
IsMouseAtCenterOfActiveWindow(tolerance = 3) {
	; 获取活动窗口句柄及其尺寸
	WinGetActiveStats, winTitle, winWidth, winHeight, winX, winY

	; 计算窗口中心坐标
	centerX := winX + (winWidth // 2)
	centerY := winY + (winHeight // 2)
	
	; 获取鼠标当前坐标
	MouseGetPos, mouseX, mouseY
	mouseX += winX
	MouseY += winY

	; 检查鼠标是否在容错范围内
	return Abs(mouseX - centerX) <= tolerance && Abs(mouseY - centerY) <= tolerance
}

;============================================
; 检查剪切板内容是否为图片
;============================================
IsClipboardImage() {
    ; 打开剪贴板
    r := DllCall("OpenClipboard", "ptr", A_ScriptHwnd)
    
    ; 获取剪贴板中的数据格式
    formats := DllCall("IsClipboardFormatAvailable", "uint", 0x8, "uint")
    
    ; 关闭剪贴板
    r := DllCall("CloseClipboard")
    
    ; 判断是否包含图片格式
    Return formats
}

#IfWinActive, ahk_group genshin

	;============================================
	; 按住[F]时快速拾取，[Ctrl+F]切换功能
	;============================================

	~^F::
		toggle_F := !toggle_F

		if (toggle_F)
			echo("快速拾取：√", 1000)
		else
			echo("快速拾取：×", 1000)

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
		SendMessage("谢谢！！祝你身体健康")
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
		SendMessage("抬头能看到金鱼钩爪，可以快速上来")
	return

	~*^Numpad1::
		if (!privates)
		return

		texts := [ "我们一个宿舍的，就打打三个精英怪，不会占用很多时间"]
		len := texts.Length()
		Random, idx, 1, %len%
		SendMessage(texts[idx])
	return

	~*^Numpad4::
		if (!privates)
		return
		SendMessage("在边上看戏就ok，我们应该可以淹死这个怪的")
	return

	;============================================
	; 输入状态检测
	;============================================
	~*Enter::
		inputing := 1
		echo("进入输入模式")
	return

	~*LButton up::
		if (inputing) {
			Sleep, 300
			if (IsMouseAtCenterOfActiveWindow()) {
				inputing := 0
				echo("退出输入模式")
			}
		}
		map_just_started := 0
	return

	~*Tab::
	~*M::
		if (GetKeyState("Alt", "P") && GetKeyState("Tab", "P"))
			return
		map_just_started := 1
		echo("进入地图")
	return

	~*ESC::
		inputing := 0
		map_just_started := 0
	return

	;W事件合并入了[Ctrl+W]功能
	~*S::
	~*A::
	~*D::
		map_just_started := 0 
	return

	;============================================
	; [F2] 调整按钮并聚焦输入栏
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
	; [空格]连发，[Alt+空格]切换
	;============================================
	~!Space::

		toggle_space := !toggle_space
		if (toggle_space)
			echo("自动空格：√")
		else
			echo("自动空格：×")
	return

	;============================================
	;锁定大写状态 （bug对策）
	;============================================
	~*CapsLock up::
		SetCapsLockState, Off
	return

	;============================================
	; 蓄力-R-闪避
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
			echo("蓄力-R-闪避：√")
		else
			echo("蓄力-R-闪避：×")
	return

	;============================================
	; [Ctrl+数字键]切换角色并开大招（更好的Alt+数字键）
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
	; [Ctrl+Q] QM快捷键
	;============================================
	$*^Q::
		map_just_started := 1
		SendInput, q
		Sleep, 10
		SendInput, m
	return

	;============================================
	; [Ctrl+W] 高效冲刺循环
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
	; [Ctrl+S] F2搜索并加入（私人）
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
; [Ctrl+S] 抢uid加入
;============================================
#IfWinActive, ahk_group QQchannel
	*^S::

		; 保留旧剪切板
		clipboardOld := Clipboard
		; 清空剪贴板
		Clipboard := ""
		; 复制
		SendInput ^c
		; 等待剪切板更新
		ClipWait 1

		; 定义映射关系
		Mappings := "①1 ②2 ③3 ④4 ⑤5 ⑥6 ⑦7 ⑧8 ⑨9 一1 二2 三3 四4 五5 六6 七7 八8 九9 零0 壹1 贰2 叁3 肆4 伍5 陆6 柒7 捌8 玖9"  ; 使用空格分隔映射对

		; 输入字符串
		outputStr := Clipboard

		;============================================
		; OCR图像识别功能，注释以切换功能
		;============================================
		; #include <vis2>
		; if (IsClipboardImage()) {
		; 	outputStr := OCR(Clipboard)
		; }

		; 替换字符
		Loop, Parse, Mappings, %A_Space%  ; 遍历映射对
		{
			If (A_LoopField != "") {
				FromChar := SubStr(A_LoopField, 1, 1)  ; 获取第一个字符作为要替换的字符
				ToChar := SubStr(A_LoopField, 0)  ; 获取第二个字符作为替换后的字符
				StringReplace, OutputStr, OutputStr, %FromChar%, %ToChar%, All
			}
		}

		; 去掉剩余的非数字字符
		outputStr := RegExReplace(outputStr, "[^0-9]")
		; 截取9位数字
		outputStr := RegExReplace(outputStr, "^\D*(\d{9}).*", "$1")

		; 将新字符串写入剪贴板
		Clipboard := trim(outputStr)

		echo(outputStr)

		if (strlen(Clipboard) <> 9) {
			echo(复制有误 %Clipboard%)
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
; 其他游戏
;============================================
#IfWinActive, ahk_exe StarRail.exe

	+F::
		toggle_F := !toggle_F

		if (toggle_F)
			echo("F键连发：√")
		else
			echo("F键连发：×")

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

	;标记为输入中
	~*Enter::
		inputing := 1
	return

	~*LButton::
		inputing := 0
	return

#IfWinActive

#IfWinActive, 尘白禁区

	
	map_just_started := 0

	~$*F::
		if (map_just_started || GetKeyState("Ctrl", "P"))
		{
			WinGetPos, X, Y, Width, Height, 尘白禁区
			MouseMove Width * 0.7, Height * 0.7
			Click
			Sleep 20
		}
		else
		{
			while (GetKeyState("F", "P") && WinActive("尘白禁区") && !map_just_started)
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