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

	public int ArgCount()
	{
		return LoadFromAddress(view_as<Address>(this), NumberType_Int32);
	}

	/**
	* Get a string of given Argument index.
	* @note Argument index.
	*
	* @param argnum        Argument number to retrieve.
	* @param buffer        Buffer to use for storing the string.
	* @param maxlength     Maximum length of the buffer.
	* @return              Length of string written to buffer.
	*/
	public int GetArg(int argnum, char[] buffer, int maxlength)
	{
		if (argnum < 0 || argnum >= this.ArgCount()) return 0;

		Address pAdr = LoadFromAddress(view_as<Address>(this) + view_as<Address>(0x408) + view_as<Address>(argnum * 4), NumberType_Int32);
		return LoadStringFromAddress(pAdr, buffer, maxlength);
	}

	/**
	* Get a string of all arguments. No command itself (0th arg).
	* 
	* @param buffer        Buffer to use for storing the string.
	* @param maxlength     Maximum length of the buffer.
	* @return              Length of string written to buffer.
	*/
	public int GetAllArg(char[] buffer, int maxlength)
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
		if (this.ArgCount() <= 0) return 0;

		Address pAdr = view_as<Address>(this) + view_as<Address>(8);
		return LoadStringFromAddress(pAdr, buffer, maxlength);
	}
}

int LoadStringFromAddress(Address pAdr, char[] buffer, int maxlength)
{
	int i;
	char sChar;

	do
	{
		sChar = LoadFromAddress(pAdr + view_as<Address>(i), NumberType_Int8);
		buffer[i] = sChar;
	} while (sChar && ++i < maxlength - 1);

	return i;
}
