//-------------------------------------------------------------------------
//
//  hardsid.inc
//
//-------------------------------------------------------------------------

{$INLINE ON}
{$MACRO ON}

// define to statically link the hardsid library
{$DEFINE HS_STATIC_LIB}

// define to support SIDBlaster
{$DEFINE HS_SIDBLASTER}

// define to automatic initialize and finalize the unit (dynamic only)
{$DEFINE HS_AutoInitialize}

//-------------------------------------------------------------------------
// ...automated settings, no need to edit!
//-------------------------------------------------------------------------

{$IFDEF HS_STATIC_LIB}
  {$DEFINE EXTDECL := stdcall; external 'hardsid.dll' name}
{$ELSE}
  {$DEFINE EXTDECL := stdcall}
{$ENDIF HS_STATIC_LIB}

