/**
 *	通过实现原神快速拾取、持续跳跃、快速瞄准，半自动传送等功能学习AutoHotKey语言
 *	原标题：通过AutoHotKey(AHK)实现原神快速拾取、持续跳跃、快速瞄准，半自动传送
 * 	起初是打开SnapHutao时无意间看到BetterGI项目，通过对屏幕进行持续截图且识别内容，性能消耗不小且有延时，而且不支持21比9屏幕啊啊啊啊，所幸我需要的功能并不多，决定上手学习AHK语言
 * 	技术支持：
 * 		- ChatGPT，大部分功能由持续询问ChatGPT 3.5 Turbo实现，但有些问题过于复杂最终还是去看了文档
 * 		- Google，拜托，哪有人不用这个的
 */


;拾取初始模式，1：按住 2：切换 0：禁用
toggle_F := 1
;当使用切换拾取时，默认是否打开
always_F := 0

;空格连发初始状态
toggle_space := 0

#IfWinActive, ahk_exe YuanShen.exe

	;使MouseMove即时完成
	SetDefaultMouseSpeed, 1

	;按住[F]时快速拾取，[Ctrl+F]切换功能

	^f::
		if (toggle_F == 1)
		{
			ToolTip, 快速拾取：×
			toggle_F := 0
		}
		else if (toggle_F == 0)
		{
			ToolTip, 快速拾取：切换
			toggle_F := 2
		}
		else
		{
			ToolTip, 快速拾取：按住
			toggle_F := 1
		}
		SetTimer, RemoveToolTip, 1000

	return



	in_map := 0

	~$*F::
		if (in_map)
		{
			WinGetPos, X, Y, Width, Height, ahk_exe YuanShen.exe
			MouseMove Width - 100, (Height * 0.92)
			Click
			Sleep 20
		}
		else
		{
			if (toggle_F == 1)
			{
				While (GetKeyState("F", "P") && WinActive("ahk_exe YuanShen.exe"))
				{
					SendInput, {f}

					Random, rand, 1, 100
					if (rand <= 20)	;20%的概率触发
						Send {WheelDown}

					Sleep, 10

					;解决抢占Space事件
					if (toggle_space && GetKeyState("Space", "P"))
						SendInput, {space}
				}
			}
			else if (toggle_F == 2 && GetKeyState("F", "P"))
			{
				always_F := !always_F

				if (always_F)
					ToolTip, 持续拾取...
				else
					ToolTip, 停止拾取

				SetTimer, RemoveToolTip, 1000
			}
		}
	return

	~*M::
		in_map := 1
	return

	~*W::
	~*S::
	~*A::
	~*D::
		in_map := 0
	return

	RemoveToolTip:
		SetTimer, RemoveToolTip, Off
		ToolTip
	return

	~$*F up::
		while (always_F && toggle_F == 2 && WinActive("ahk_exe YuanShen.exe"))
		{
			if (!in_map)
			{
				SendInput, {f}

				Random, rand, 1, 100
				if (rand <= 20)	;20%的概率触发
					Send {WheelDown}

				Sleep, 10
			}
		}
	return

	;[空格]连发，[Ctrl+空格]切换f
	^Space::
		toggle_space := !toggle_space
		if (toggle_space)
			ToolTip, 自动空格：√
		else
			ToolTip, 自动空格：×
		SetTimer, RemoveToolTip, 1000

	return

	~$*space::
		if (toggle_space)
		{
			While (GetKeyState("Space", "P") && WinActive("ahk_exe YuanShen.exe"))
			{
				SendInput, {space}
				Sleep, 10

				;抢占F up事件
				if (always_F && toggle_F == 2 && !in_map)
				{
					SendInput, {f}

					Random, rand, 1, 100
					if (rand <= 20)	;20%的概率触发
						Send {WheelDown}
				}
			}
		}
	return


	;右键瞄准，松开取消瞄准
	*RButton::
		Send, {r}
	return

	*RButton Up::
		Send, {r}
	return

	;[Ctrl+数字键]切换角色并开大招（更好的Alt+数字键）
	~*^1::
	~*^2::
	~*^3::
	~*^4::
		while (GetKeyState("Ctrl", "P"))
		{
			Send, {q}
			Sleep, 10
		}

#IfWinActive


#IfWinActive, ahk_exe StarRail.exe

	in_map := 0

	~$*F::
		if (in_map || GetKeyState("Space", "P"))
		{
			WinGetPos, X, Y, Width, Height, ahk_exe StarRail.exe
			MouseMove Width - 100, (Height * 0.89)
			Click
			Sleep 20
		}
		else
		{
			While (GetKeyState("F", "P") && WinActive("ahk_exe StarRail.exe"))
			{
				SendInput, {f}
				Sleep, 10
			}
		}
	return

	~*M::
		in_map := 1
	return

	~*W::
	~*S::
	~*A::
	~*D::
		in_map := 0
	return

#IfWinActive