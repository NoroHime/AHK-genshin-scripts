/**
 *	ͨ��ʵ��ԭ�����ʰȡ��������Ծ��������׼�����Զ����͵ȹ���ѧϰAutoHotKey����
 *	ԭ���⣺ͨ��AutoHotKey(AHK)ʵ��ԭ�����ʰȡ��������Ծ��������׼�����Զ�����
 * 	����Ǵ�SnapHutaoʱ����俴��BetterGI��Ŀ��ͨ������Ļ���г�����ͼ��ʶ�����ݣ��������Ĳ�С������ʱ�����Ҳ�֧��21��9��Ļ������������������Ҫ�Ĺ��ܲ����࣬��������ѧϰAHK����
 * 	����֧�֣�
 * 		- ChatGPT���󲿷ֹ����ɳ���ѯ��ChatGPT 3.5 Turboʵ�֣�����Щ������ڸ������ջ���ȥ�����ĵ�
 * 		- Google�����У������˲��������
 *
 */


;ʰȡ��ʼģʽ��1����ס 2���л� 0������
toggle_F := 1
;��ʹ���л�ʰȡʱ��Ĭ���Ƿ��
always_F := 0

;�ո�������ʼ״̬
toggle_space := 0


;�������ԱȨ��
full_command_line := DllCall("GetCommandLine", "str")


;���ʷ�֧��
GroupAdd, genshin, ahk_exe YuanShen.exe
GroupAdd, genshin, ahk_exe GenshinImpact.exe

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
	try
	{
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}

#IfWinActive, ahk_group genshin

	;ʹMouseMove��ʱ���
	SetDefaultMouseSpeed, 1

	;��ס[F]ʱ����ʰȡ��[Ctrl+F]�л�����

	*^f::
		if (toggle_F == 1)
		{
			ToolTip, ����ʰȡ����
			toggle_F := 0
		}
		else if (toggle_F == 0)
		{
			ToolTip, ����ʰȡ���л�
			toggle_F := 2
		}
		else
		{
			ToolTip, ����ʰȡ����ס
			toggle_F := 1
		}
		SetTimer, RemoveToolTip, 1000

	return



	in_map := 0

	~$*F::
		if (in_map)
		{
			WinGetPos, X, Y, Width, Height, ahk_group genshin
			MouseMove Width - 100, (Height * 0.92)
			Click
			Sleep 20
		}
		else
		{
			if (toggle_F == 1)
			{
				While (GetKeyState("F", "P") && WinActive("ahk_group genshin"))
				{
					SendInput, {f}

					Random, rand, 1, 100
					if (rand <= 20)	;20%�ĸ��ʴ���
						SendInput {wheeldown}

					Sleep, 10

					;�����ռSpace�¼�
					if (toggle_space && GetKeyState("Space", "P"))
						SendInput, {space}
				}
			}
			else if (toggle_F == 2 && GetKeyState("F", "P"))
			{
				always_F := !always_F

				if (always_F)
					ToolTip, ����ʰȡ...
				else
					ToolTip, ֹͣʰȡ

				SetTimer, RemoveToolTip, 1000
			}
		}
	return

	;����M��ʱ��Ϊ�ڵ�ͼ�ڣ��л����ٴ��͹���
	~*M::
		in_map := 1
	return

	;�������ʱ��Ϊ���ڵ�ͼ
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

	;ʰȡ�л�����
	~$*F up::
		while (always_F && toggle_F == 2 && WinActive("ahk_group genshin"))
		{
			if (!in_map)
			{
				SendInput, {f}

				Random, rand, 1, 100
				;ֻ��20%�ĸ��ʴ������֣����ⰴ������
				if (rand <= 20)
					SendInput {wheeldown}

				Sleep, 10
			}
		}
	return

	;[�ո�]������[Ctrl+�ո�]�л�f
	^Space::
		toggle_space := !toggle_space
		if (toggle_space)
			ToolTip, �Զ��ո񣺡�
		else
			ToolTip, �Զ��ո񣺡�
		SetTimer, RemoveToolTip, 1000

	return

	~$*space::
		if (toggle_space)
		{
			While (GetKeyState("Space", "P") && WinActive("ahk_group genshin"))
			{
				SendInput, {space}
				Sleep, 10

				;��ռF up�¼�
				if (always_F && toggle_F == 2 && !in_map)
				{
					SendInput, {f}

					Random, rand, 1, 100
					;ֻ��20%�ĸ��ʴ������֣����ⰴ������
					if (rand <= 20)
						SendInput {wheeldown}
				}
			}
		}
	return


	;�Ҽ���׼���ɿ�ȡ����׼
	*RButton::
		Send, {r}
	return

	*RButton Up::
		Send, {r}
	return

	;[Ctrl+���ּ�]�л���ɫ�������У����õ�Alt+���ּ���
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
		if (in_map || GetKeyState("Ctrl", "P"))
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

#IfWinActive, ���׽���

	in_map := 0

	~$*F::
		if (in_map || GetKeyState("Ctrl", "P"))
		{
			WinGetPos, X, Y, Width, Height, ���׽���
			MouseMove Width * 0.7, Height * 0.7
			Click
			Sleep 20
		}
		else
		{
			While (GetKeyState("F", "P") && WinActive("���׽���"))
			{
				SendInput, {f}
				Sleep, 10
			}
		}
	return

	~*ESC::
		in_map := 1
	return

	~*W::
	~*S::
	~*A::
	~*D::
		in_map := 0
	return

#IfWinActive