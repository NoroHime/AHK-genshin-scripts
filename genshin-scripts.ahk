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
   - �л�������`F`��������ʰȡ��ֱ���ٴΰ���F
   - ��ס������`F`ʱ����ʰȡ���ɿ���ȡ��
   - �رգ������κ�����
 - �Զ���Ծ��`Ctrl+�ո�`�л����أ�������л�ʰȡ����ʹ�ÿ��ܻ���С����
 - ����`M��`�������ٴ��͹��ܣ�����ʱ��`F`�Զ�������Ͱ�ť��ֱ������`�����ƶ���`ȡ������
 - ��Ϊ������ʱ����ס`����Ҽ�`��Ϊ��׼���ɿ�ȡ����׼
 - ��ס`Ctrl+���ּ�`�Զ��л��ý�ɫ���ͷ�Ԫ�ر����������滻��Ϸ�Դ���`Alt+���ּ�`���ܣ��Ұ���ʱ�������`Q`�����������ӳ���һ���ݴ���
 - ������ʷ����й���½������

## �������
- `F��`������`Shift+F`�л��ù���
- ����M���������ٴ��͹��ܣ�����ʱ��`F`�Զ�������Ͱ�ť��ֱ������`�����ƶ���`ȡ�����ܣ�Ҳ�ɰ���`Ctrl+F`ǿ�ƴ����ù���

## ���׽���
- `F��`������`Shift+F`�л��ù���
- ����`ESC��`�������ٵ���Ի����ܣ�����ʱ��`F`�Զ�������Ͱ�ť��ֱ������`�����ƶ���`ȡ�����ܣ�Ҳ�ɰ���`Ctrl+F`ǿ�ƴ����ù���

## ɭ��֮��
- ��ס`F`ʱ�����`E`ʰȡ

*/

;���ʷ�֧��
GroupAdd, genshin, ahk_exe YuanShen.exe
GroupAdd, genshin, ahk_exe GenshinImpact.exe


;�������ԱȨ��
full_command_line := DllCall("GetCommandLine", "str")
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



;ʰȡ��ʼģʽ��1����ס 2���л� 0������
toggle_F := 1
;��ʹ���л�ʰȡʱ��Ĭ���Ƿ��
always_F := 0
;�ո�������ʼ״̬
toggle_space := 0

;ʹMouseMove��ʱ���
SetDefaultMouseSpeed, 1

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

#IfWinActive, ahk_group genshin
	

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
				While (GetKeyState("F", "P") && WinActive("ahk_group genshin") && !in_map)
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
	
	toggle_F := 1

	*+f::
		toggle_F := !toggle_F

		if (toggle_F)
			ToolTip, F����������
		else
			ToolTip, F����������
		SetTimer, RemoveToolTip, 1000
	return

	in_map := 0

	~$*F::
		if (in_map || GetKeyState("Ctrl", "P"))
		{
			WinGetPos, X, Y, Width, Height, ahk_exe StarRail.exe
			MouseMove Width - 100, (Height * 0.89)
			Click
			Sleep 20
		}
		else if (toggle_F)
		{
			While (GetKeyState("F", "P") && WinActive("ahk_exe StarRail.exe") && !in_map)
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

	toggle_F := 1

	*+f::
		toggle_F := !toggle_F

		if (toggle_F)
			ToolTip, F����������
		else
			ToolTip, F����������
		SetTimer, RemoveToolTip, 1000
	return

	in_map := 0

	~$*F::
		if (in_map || GetKeyState("Ctrl", "P"))
		{
			WinGetPos, X, Y, Width, Height, ���׽���
			MouseMove Width * 0.7, Height * 0.7
			Click
			Sleep 20
		}
		else if (toggle_F)
		{
			While (GetKeyState("F", "P") && WinActive("���׽���") && !in_map)
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

#IfWinActive, ahk_exe SonsOfTheForest.exe
	~*F::
		While (GetKeyState("F", "P") && WinActive("ahk_exe SonsOfTheForest.exe"))
		{
			SendInput, {e}
			Sleep, 10
		}
	return
#IfWinActive