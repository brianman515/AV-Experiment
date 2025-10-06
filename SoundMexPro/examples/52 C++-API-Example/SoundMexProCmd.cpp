//---------------------------------------------------------------------------
/// Sample command line program for using SoundMexPro without MATLAB
///
/// Important notes:
/// - In real applications you must always
///   - keep the message loop alive
///   - be gracefull by giving the SoundMexPro thread processing time, i.e.
///     do not implement e.g. blocking loops
///
/// Written by Daniel Berg, HörTech gGmbH, 2014
//---------------------------------------------------------------------------

#pragma hdrstop

#include <tchar.h>
#include <windows.h>
#include <stdio.h>
//---------------------------------------------------------------------------


#define BUFSIZE 4096
typedef int  cdecl (*LPFNSMP)(const char* , char* , int );


#pragma argsused
int _tmain(int argc, _TCHAR* argv[])
{
   char cBuf[BUFSIZE];

   // load SoundMexPro main DLL
   HINSTANCE hLib = LoadLibrary("T:\\BIN\\SoundDllPro.dll");
   if (!hLib)
      {
      printf("\nerror loading library");
      return 0;
      }

   // retrieve exported funtion
   LPFNSMP lpFunc = (LPFNSMP)GetProcAddress(hLib, "_SoundDllProCommand");
   if (!!lpFunc)
      {
      // as an example: retrieve driver names
      int nReturn = lpFunc("command=getdrivers", cBuf, BUFSIZE);
      // NOTE: if nReturn is 1, than command was successfull, otherwise it failed
      // On succes cBuf will contain the return values, otherwise cBuf will contain
      // the error message. In this simple example we always print cBuf, ignore the
      // return value and proceed anyway....
      // Here the existing drivernames are returned/printed
      printf("\n%s", cBuf);

      // Adjust driver number or name here!
      nReturn = lpFunc("command=init;driver=3", cBuf, BUFSIZE);
      // Here version and license type are returned/printed
      printf("\n%s", cBuf);

      // show visualization
      nReturn = lpFunc("command=show", cBuf, BUFSIZE);
      // no return value, but may contain error message
      printf("\n%s", cBuf);

      // Load a wave file: adjust wave filename here!
      nReturn = lpFunc("command=loadfile;filename=..\\waves\\eurovision.wav", cBuf, BUFSIZE);
      // no return value, but may contain error message
      printf("\n%s", cBuf);

      // start playback
      nReturn = lpFunc("command=start", cBuf, BUFSIZE);
      // no return value, but may contain error message
      printf("\n%s", cBuf);

      // wait for playback to be complete
      nReturn = lpFunc("command=wait", cBuf, BUFSIZE);
      // no return value, but may contain error message
      printf("\n%s", cBuf);

      // call exit to cleanup
      lpFunc("command=exit", cBuf, BUFSIZE);
      }
   else
      printf("\nerror loading SoundDllProCommand");

   // FreeLibrary
   FreeLibrary(hLib);

   printf("\nDONE");
   return 0;
}
//---------------------------------------------------------------------------
