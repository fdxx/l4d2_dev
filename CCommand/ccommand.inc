#if defined _ccommand_included
 #endinput
#endif
#define _ccommand_included

methodmap CCommand 
{
	/**
	* @return	Argument count.
	* @note		Split by spaces??
	*/
	property int ArgC
	{
		public get()
		{
			return LoadFromAddress(view_as<Address>(this), NumberType_Int32);
		}
	}

	/**
	* Get a string of all arguments. No command(0th arg) itself.
	* 
	* @param buffer        Buffer to use for storing the string.
	* @param maxlength     Maximum length of the buffer.
	* @return              Length of string written to buffer.
	*/
	public int GetArgString(char[] buffer, int maxlength)
	{
		int iArg0Size = LoadFromAddress(view_as<Address>(this) + view_as<Address>(4), NumberType_Int32);

		if (iArg0Size > 0)
		{
			char sCmd[512];
			if (this.GetCmdString(sCmd, sizeof(sCmd)) > 0)
			{
				return strcopy(buffer, maxlength, sCmd[iArg0Size]);
			}
		}
		
		return 0;
	}

	/**
	* Get a string of the entire command and arguments.
	* 
	* @param buffer        Buffer to use for storing the string.
	* @param maxlength     Maximum length of the buffer.
	* @return              Length of string written to buffer.
	*/
	public int GetCmdString(char[] buffer, int maxlength)
	{
		if (this.ArgC <= 0) return 0;

		// https://github.com/nosoop/stocksoup/blob/master/memory.inc
		
		int i;
		char sChar;
		Address pAddr = view_as<Address>(this) + view_as<Address>(8);

		do
		{
			sChar = view_as<int>(LoadFromAddress(pAddr + view_as<Address>(i), NumberType_Int8));
			buffer[i] = sChar;
		} while (sChar && ++i < maxlength - 1);

		return i;
	}
}
