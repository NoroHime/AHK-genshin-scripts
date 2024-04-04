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
; 国际服支持
;============================================
GroupAdd, genshin, ahk_exe YuanShen.exe
GroupAdd, genshin, ahk_exe GenshinImpact.exe

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
;当使用切换拾取时，默认是否打开
always_F := 0
;空格连发初始状态
toggle_space := 0
;空格连发功能开关
SpaceBurst := 1
privates := 0

;使MouseMove即时完成
SetDefaultMouseSpeed, 1

;============================================
; 移除提示的辅助函数
; 用法：SetTimer, RemoveToolTip, 1000
;============================================
RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

;============================================
; 检测光标是否位于屏幕中心以判断战斗状态 tolerance：容错像素
;============================================
IsMouseAtCenterOfActiveWindow(tolerance=3) {
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



#IfWinActive, ahk_group genshin

	;============================================
	; 按住[F]时快速拾取，[Ctrl+F]切换功能
	;============================================

	~^F::
		toggle_F := !toggle_F

		if (toggle_F)
			ToolTip, 快速拾取：√
		else
			ToolTip, 快速拾取：×

		SetTimer, RemoveToolTip, 1000

	return

	~$*F::
		if inputing
		return

		if (!IsMouseAtCenterOfActiveWindow() || map_just_started) {
			WinGetPos, X, Y, Width, Height, ahk_group genshin
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

				;解决抢占rendInput, {space}
			}
		}
	return

	;============================================
	; 输入状态检测
	;============================================
	~*Enter::
		inputing := 1
	return

	~*LButton::
		inputing := 0
		map_just_started := 0
	return

	~*M::
		map_just_started := 1
	return

	;W事件合并入了[Ctrl+W]功能
	~*S::
	~*A::
	~*D::
		map_just_started := 0
	return

	;============================================
	; [空格]连发，[Ctrl+空格]切换
	;============================================
	^Space::

		if !SpaceBurst
		return

		toggle_space := !toggle_space
		if (toggle_space)
			ToolTip, 自动空格：√
		else
			ToolTip, 自动空格：×
		SetTimer, RemoveToolTip, 1000
	return

	~$*space::
		while (toggle_space && GetKeyState("Space", "P") && WinActive("ahk_group genshin")) {
			SendInput, {space}
			Sleep, 10
		}
	return

	;============================================
	;锁定大写状态 （bug对策）
	;============================================
	~*CapsLock::
		SetCapsLockState, Off
	return

	;============================================
	; 蓄力-R-闪避
	;============================================
	*RButton::
		SendInput, r
	return

	*RButton Up::
		click
		SendInput, {LShift down}
		Sleep, 10
		SendInput, {LShift up}
	return

	;============================================
	; [Ctrl+数字键]切换角色并开大招（更好的Alt+数字键）
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
	; [Ctrl+Q] QM快捷键
	;============================================
	~$*^Q::
		map_just_started := 1
		SendInput, q
		Sleep, 1
		SendInput, m
	return

	;============================================
	; [Ctrl+W] 高效冲刺循环
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
			SetTimer, TimerShift, 799
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
	; [Ctrl+X] F2搜索并加入（私人）
	;============================================
	*^X::
		if !privates
		return
		WinGetPos, X, Y, Width, Height, ahk_group genshin
		MouseMove Width * 0.87, (Height * 0.1)
		Click
		Sleep 70
		MouseMove Width * 0.87, (Height * 0.22)
		Click
	return


#IfWinActive


#IfWinActive, ahk_exe StarRail.exe

	+F::
		toggle_F := !toggle_F

		if (toggle_F)
			ToolTip, F键连发：√
		else
			ToolTip, F键连发：×

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