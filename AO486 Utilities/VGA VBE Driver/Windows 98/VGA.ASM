;****************************************************************************
;                                                                           *
; THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY     *
; KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE       *
; IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR     *
; PURPOSE.                                                                  *
;                                                                           *
; Copyright (C) 1993-95  Microsoft Corporation.  All Rights Reserved.       *
;                                                                           *
;****************************************************************************

;----------------------------------------------------------------------------
; VGA.ASM
;----------------------------------------------------------------------------
        .xlist
        include cmacros.inc
        incDevice = 1                   ;Include control for gdidefs.inc
        incDrawMode = 1                 ;Include DRAWMODE structure
        include gdidefs.inc
        include macros.inc
        include dibeng.inc
	include minivdd.inc
	include valmode.inc
	include	device.inc
        .list
;----------------------------------------------------------------------------
; S T R U C T U R E S
;----------------------------------------------------------------------------
DataBlockStruc struc
	wMode	 	dw	?	;mode
	bMemory		db	?	;Amount of memory for this mode
	wPitch		dw	?	;Mode pitch (width bytes)
	wPDevFlags	dw	?	;PDevice flags
	wBIOSModeFlags	db	?	;INT 10 BIOS Mode Flags
DataBlockStruc ends

SCREENRGN	struc
	sr_rect		db size(RECT) dup (?)
	sr_width	dw		   ?
	sr_height	dw		   ?
SCREENRGN ends

AdapterEntryStruc struc
        bResolution     db      ?
        bBpp            db      ?
        pDataBlock      dw      ?
        pBitBltDevProc  dw      ?
        pTextOutDevProc dw      ?
AdapterEntryStruc ends

;----------------------------------------------------------------------------
; E Q U A T E S
;----------------------------------------------------------------------------
GET386API       equ     1684h           ;Get API entry point from VxD.
VFLATD_VXD      equ     11Fh            ;id of VFLATD VxD
GET_VIDEO_SEL   equ     1               ;function # to call to get selector
VDD             equ     000Ah           ;id of Virtual Display Driver.
STOP_IO_TRAP    equ     4000h           ; stop io trapping
START_IO_TRAP	equ	4007h		; re-start io trapping
VDDsetaddresses equ	0Ch		;function # to call to pass addresses

FOURTHMEG	=	0
HALFMEG		=	1
ONEMEG		=	2*HALFMEG
TWOMEG		=	2*ONEMEG
THREEMEG	=	3*ONEMEG
FOURMEG		=	4*ONEMEG
FIVEMEG		=	5*ONEMEG
SIXMEG		=	6*ONEMEG
SEVENMEG	=	7*ONEMEG
EIGHTMEG	=	8*ONEMEG

;----------------------------------------------------------------------------
; E X T E R N S  and  P U B L I C S
;----------------------------------------------------------------------------
        externA  KernelsScreenSel          ;equates to a000:0000
	externNP XYtoRes		   ;in INIT.ASM 
	externFP SetRAMDAC_far		   ;in PALETTE.ASM
	externNP Is_ET4000
	externNP BltSpecial_Tseng
	externNP TsengTxtOut

;----------------------------------------------------------------------------
; D A T A
;----------------------------------------------------------------------------
sBegin  Data
externB bReEnable                       ;in INIT.ASM
externW wResolution                     ;in INIT.ASM
externW wDpi                            ;in INIT.ASM
externW wBpp                            ;in INIT.ASM
externD lpColorTable
externD lpDriverPDevice

public Rgn1
public Rgn2
Rgn1 SCREENRGN <>			;Off-screen regions.
Rgn2 SCREENRGN <>			;Off-screen regions.

globalW wBaseMode,0
globalW pSetBank,0
globalW pBankSwitchTemplate,0
globalW TemplateSize,0
globalW pSetMode,0
globalW pExtraInit,0
globalW BitBltDevProc,0
globalW TextOutDevProc,0
globalW pAdapterTable,0
globalW pAdapterEntry,0
globalW nNumEntries,0
globalW nTableEntries,0
globalW wDeviceType,0
externD VDDEntryPoint
globalW wCurrentMode,0
globalW wPDeviceFlags,0
globalW wModeFlags,0
globalD dwVideoMemorySize,0
globalW wScreenWidth,0
globalW wScreenHeight,0
globalW wMaxWidth,0
globalW wMaxHeight,0
globalW wScreenWidthBytes,0
externW OurVMHandle
globalW ScreenSelector,0                ;selector for the screen
globalB bVDDByte,0
globalB bLatchBank,0
globalB bLatchCapable,0
globalB bCanVirtualize,0		;non-zero if MiniVDD can do VGA
					;4 plane graphics in a window
sEnd    Data

;----------------------------------------------------------------------------
; C O D E
;----------------------------------------------------------------------------
createSeg _INIT,InitSeg,word,public,CODE
sBegin  InitSeg
assumes cs,InitSeg
        .386

;----------------------------------------------------------------------------
; Adapter Table
;----------------------------------------------------------------------------
AdapterEntry macro      r,b,db,blt,txt
        NextEntry = NextEntry + 1
        AdapterEntryStruc <r,b,db,blt,txt>
        endm

NextEntry = 0
ET4000_AdapterTable    label word
        AdapterEntry 1,8,ET4000_1_8,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 2,8,ET4000_2_8,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 3,8,ET4000_3_8,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 4,8,ET4000_4_8,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 1,16,ET4000_1_16,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 2,16,ET4000_2_16,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 3,16,ET4000_3_16,BltSpecial_Tseng,TsengTxtOut
        AdapterEntry 1,24,ET4000_1_24,0,0
        AdapterEntry 2,24,ET4000_2_24,0,0
        AdapterEntry 1,1,MONO_1_1,0,0
        AdapterEntry 2,1,ET4000_2_1,0,0
        AdapterEntry 3,1,ET4000_3_1,0,0
        AdapterEntry 4,1,ET4000_4_1,0,0
ET4000_nEntries = NextEntry

;----------------------------------------------------------------------------
; A D A P T E R   D A T A   B L O C K S
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; 1 bpp modes
;----------------------------------------------------------------------------
MONO_1_1:
ET4000_1_1:
        dw      11h			;640x480x1
        db      0
	dw	80			;pitch
	dw	MINIDRIVER+VRAM		;deFlags
	db	0			;Misc flags

ET4000_2_1:
        dw      29h			;800x600x1
        db      0
	dw	100			;pitch
	dw	MINIDRIVER+VRAM		;deFlags
	db	0			;Misc flags

ET4000_3_1:
        dw      37h			;1024x768x1
        db      HALFMEG
	dw	128			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM ;deFlags
	db	0			;Misc flags

ET4000_4_1:
        dw      3Dh			;1280x1024x1
        db      ONEMEG
	dw	160			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM ;deFlags
	db	0			;Misc flags

;----------------------------------------------------------------------------
; 8 bpp modes
;----------------------------------------------------------------------------
ET4000_1_8:
        dw      2Eh	                ;640x480x8
        db      HALFMEG
	dw	1024			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM ;deFlags
	db	0			;Misc flags

ET4000_2_8:
        dw      30h                     ;800x600x8
        db      HALFMEG
	dw	1024			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM
	db	0			;Misc flags

ET4000_3_8:
        dw      38h                     ;1024x768x8
        db      ONEMEG
	dw	1024			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM ;deFlags
	db	0			;Misc flags

ET4000_4_8:
        dw      3Fh                     ;1280x1024x8
        db      TWOMEG
	dw	1280			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM+BANKEDSCAN ;deFlags
	db	0			;Misc flags

;----------------------------------------------------------------------------
; 15 bpp modes
;----------------------------------------------------------------------------
ET4000_1_16:
        dw      2Eh	                ;640x480x16
        db      ONEMEG
	dw	1280			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM+BANKEDSCAN ;deFlags
	db	0			;Misc flags

ET4000_2_16:
        dw      30h                     ;800x600x16
        db      ONEMEG
	dw	1600			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM+BANKEDSCAN ;deFlags
	db	0			;Misc flags

ET4000_3_16:
        dw      38h                     ;1024x768x16
        db      TWOMEG
	dw	2048			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM ;deFlags
	db	0			;Misc flags

;----------------------------------------------------------------------------
; 24 bpp modes
;----------------------------------------------------------------------------
ET4000_1_24:
        dw      2Eh                     ;640x480   24  bpp mode
        db      ONEMEG                  ;flags
	dw	1920			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM+BANKEDSCAN ;deFlags
	db	0			;Misc flags

ET4000_2_24:
        dw      30h                     ;800x600   24  bpp mode
        db      ONEMEG                  ;flags
	dw	2400			;pitch
	dw	MINIDRIVER+VRAM+BANKEDVRAM+BANKEDSCAN ;deFlags
	db	0			;Misc flags

;----------------------------------------------------------------------------
; PhysicalEnable
;----------------------------------------------------------------------------
PPROC	PhysicalEnable	near
        assumes ds,Data
        assumes es,nothing
        assumes gs,nothing
        assumes fs,nothing
	xor	ax,ax
	mov	pAdapterEntry,ax	;Force FindMode to search from top.
;----------------------------------------------------------------------------
; IF FirstTime THEN
;   Determine device type
;   GET Adapter memory size
; ENDIF
;----------------------------------------------------------------------------
	cmp	wDeviceType,0
	jnz	PE_FindMode
	call	DetermineAdapter
	test	ax,ax
	jz	PE_Fail

PLABEL PE_GetMemSize
	call GetMemSize
    mov  word ptr [dwVideoMemorySize],ax
    mov  word ptr [dwVideoMemorySize+2],dx

;----------------------------------------------------------------------------
; WHILE (ModeNum = FindMode(bpp,res,memsize)) 
;   IF SetMode(ModeNum,bpp,res,memsize) THEN
;     ScreenSelector = GetLinearSelector();
;     HOOK up with the VDD.
;     CLEAR the screen.
;   RETURN( SUCCESS )
; ENDWHILE
; RETURN( FAIL )
;----------------------------------------------------------------------------
PLABEL PE_FindMode
	call	FindMode
	or	bx,bx
	jz	PE_Fail
	mov	wCurrentMode,bx
	mov	wModeFlags,ax
	mov	ax,1
	call	SetMode
	jc	PE_FindMode

;----------------------------------------------------------------------------
; Get screen selector.
;----------------------------------------------------------------------------
PLABEL PE_GetVFlatDSelector
        push    si                      ;
        push    di                      ;
        call    GetScreenSelector       ;Get the screen selector from VFlatD.
        pop     di                      ;
        pop     si                      ;
        or      ax,ax                   ;Is screen selector zero?
        jz      PE_Fail                 ;yes. Error exit.
	mov	ScreenSelector,ax	;no. Store it.

;----------------------------------------------------------------------------
; Hook up with the vdd.
;
; The MiniVDD requires us to register ourselves with it in order to activate
; its ability to virtualize graphics mode DOS apps in a window or in the
; background.  The VDD will also allocate some memory so that it can perform
; this virtualization correctly.  Let's setup this call and pass down the
; proper information to the MiniVDD.
;----------------------------------------------------------------------------
PLABEL PE_HookUpWithVDD
;
;Before calling VDD_DRIVER_REGISTER, we want to pass some information to the
;MiniVDD (if there is one).  First, the total video memory size which we've
;calculated.  We need to get this to the MiniVDD before calling
;VDD_DRIVER_REGISTER since the VDD needs the video memory size to calculate
;the off-screen area available to it.
;
;This driver uses the so-called KernelsScreenSelector for doing screen-to-screen
;BLT's etc.  Some MiniVDD's need to control this selector during virtualization.
;We therefore call VDD_REGISTER_DISPLAY_DRIVER_INFO.  Then, any MiniVDD's which
;need to understand this selector, can register it in their MiniVDD code.
;
	xor	edx,edx 		;make sure top word of EDX is 0
	xor	edi,edi 		;make sure DI is zero (for CHIPS.VXD)
	mov	dx,KernelsScreenSel	;pass "extra" screen selector to VDD
					;don't move this to EDX, it don't work!
	mov	ecx,dwVideoMemorySize	;give him the memory size we calculated
	mov	eax,VDD_REGISTER_DISPLAY_DRIVER_INFO
	movzx	ebx,OurVMHandle 	;VDD PM API needs this
	call	dword ptr VDDEntryPoint ;
;
;Now, setup the call to VDD_DRIVER_REGISTER:
;
	movzx	eax,wScreenWidthBytes	;get screen pitch
	movzx	edx,wScreenHeight	;get height of visible screen
	mul	edx			;EAX has total bytes of visible screen
	mov	ecx,eax 		;pass visible memory size in ECX
	mov	eax,VDD_DRIVER_REGISTER ;this is function code for VDD PM API
	movzx	ebx,OurVMHandle 	;VDD PM API needs this
	mov	di,_TEXT		;send ES:DI --> routine that VDD calls
	mov	es,di			;to set us back into Windows mode
	mov	di,CodeOFFSET ResetHiResMode
	mov	edx,-1			;tell VDD NOT to attempt to virtualize
	cmp	bCanVirtualize,0	;can this card do graphics in a window?
	je	@F			;nope, leave EDX as -1
	cmp	[dwVideoMemorySize],00100000h	;1M (or better) on the card?
	jb	short @f		;no, can not do graphics in a window.
	xor	edx,edx 		;yes, set EDX to zero!
@@:	call	dword ptr VDDEntryPoint

;----------------------------------------------------------------------------
;The MiniVDD will return the total memory used by both the visible screen
;and the VDD itself.  We can therefore calculate the location of our off-screen
;cache areas and where the cursor is supposed to be cached etc.
;
;At this point:
; EAX contains VDD_DRIVER_REGISTER if the call failed.
; EAX contains -1 if we're running in a memory-shy state
;     (that is, if the visible screen extends into the last
;      physical 64K bank on card -- ie: 800x600x8 on a 512K card).
; EAX contains the size in bytes of the visible screen plus the
;     memory allocated by the VDD.
;
;----------------------------------------------------------------------------
	cmp	eax,VDD_DRIVER_REGISTER ;did the call fail?
	je	short PE_SaveState	;yes, just use values that we've got.

;----------------------------------------------------------------------------
;The VDD returned normally.  EAX contains the total amount of video memory
;used by both the visible screen and the VDD.  The VDD is using the memory
;directly below the visible screen.  That means that our stuff will have to
;be located below the VDD's reserved memory.
;----------------------------------------------------------------------------
PLABEL	PE_VDDReturnedNormal
	push	eax			;save memory used for now
	mov	edx,dwVideoMemorySize	;
	sub	edx,eax 		;EDX == bytes of scratch memory left
	mov	eax,edx 		;(get this into EAX for divide)
	xor	edx,edx 		;zero EDX for dword divide
	movzx	ebx,wScreenWidthBytes	;
	div	ebx			;AX == # of lines in scratch memory
	mov	Rgn2.sr_height,ax
	pop	eax			;get back memory used returned by VDD
	xor	edx,edx 		;zero EDX for dword lengthed divide
	div	ebx			;AX == # of lines used by screen & VDD
	or	dx,dx			;any remainder?
	jz	short @f		;nope, we're OK
	inc	ax			;yes! bump up another line
@@:	mov	Rgn2.top,ax		;save adjusted value

PLABEL PE_SaveState
;
;Call the VDD to order it to save the current register state.  This will
;hopefully assure that the Windows VM has the running state saved:
;
	mov	eax,VDD_POST_MODE_CHANGE;function code goes in EAX
	movzx	ebx,OurVMHandle 	;this is needed for the call
	call	dword ptr VDDEntryPoint ;call the VDD to do post setup
	mov	eax,VDD_SAVE_DRIVER_STATE
	movzx	ebx,OurVMHandle 	;
	call	dword ptr VDDEntryPoint ;
;
PLABEL PE_ClearScreen
        mov     si,wBpp
        call    ClearScreen
	clc				;Indicate success
	ret

PLABEL PE_Fail
	stc				;indicate failure
	ret
PhysicalEnable	endp

;----------------------------------------------------------------------------
; FindMode
; Exit:
;  bx = next mode, or 0 if no more matching modes.
;  ax = Mode Flags
; Sets:
;   nNumEntries, pAdapterEntry
;----------------------------------------------------------------------------
PPROC	FindMode	near
	mov	ax,wResolution
	mov	dx,wBpp
        mov     di,pAdapterTable
	mov	cx,nNumEntries
	cmp	pAdapterEntry,0
	jne	FM_NextMode
        mov     cx,nTableEntries

PLABEL FM_CheckModeLoop
	cmp	al,cs:[di].bResolution
        jne     short FM_NextMode       ;no. skip this table entry.
	cmp	dl,cs:[di].bBpp
        jne     short FM_NextMode       ;no. skip this table entry.
	mov	eax,dwVideoMemorySize
	shr	eax,19			;eax = mem size in 512k units.
	mov	si,cs:[di].pDataBlock
	cmp	al,cs:[si].bMemory
	jl	short FM_NextMode
@@:	mov	bx,cs:[si].wMode
	movzx	ax,cs:[si].wBIOSModeFlags
	mov	pAdapterEntry,di
	mov	nNumEntries,cx
	ret
PLABEL FM_NextMode
	add	di,SIZE AdapterEntryStruc
        dec     cx                      ;Have we gone through the entire table?
        jnz     FM_CheckModeLoop        ;nope. Try the next entry.
	xor	bx,bx
	ret
FindMode	endp

;----------------------------------------------------------------------------
; GetMemSize
; Entry:
; Exit:
;  dx:ax == memory size of adapter
;----------------------------------------------------------------------------
PPROC	GetMemSize	near
	assumes	ds,Data
	assumes	es,nothing
	assumes	fs,nothing
	assumes	gs,nothing
	cmp	wDeviceType,TRIDENT
	je	GMS_SpecialHandling
	mov	bx,wBaseMode
	call	pSetMode
	call	CanWeUseTheLatches
	mov	bLatchCapable,al
	mov	bx,pSetBank
	xor	ax,ax
	int	1ah			;get tick count
	mov	cx,dx			;cx = reference value
	xor	dx,dx			;start at bank 0.
	mov	ax,KernelsScreenSel
	mov	es,ax
	call	bx			;set the bank h/w
@@:	mov	word ptr es:[0],cx	;write reference value to video memory
	cmp	word ptr es:[0],cx	;read it back.
	jne	GMS_SizeFound		;if read fails, we've found end of mem.
	inc	dl			;read works, must be okay memory.
	call	bx			;next bank.
	cmp	dl,40h			;Are we at 4M?
	je	GMS_SizeFound		;yes, peg at 4M.
	cmp	word ptr es:[0],cx	;is reference value there?
	jne	@b			;no, memory did not wrap.

PLABEL GMS_SizeFound
	xor	ax,ax

PLABEL GMS_Exit
	ret

; The code above does not reliable determine the amount of memory
; on a Trident 8900.  So, we will try the mode for 1024x768 -- if it
; works we will assume 1M of memory, else assume 512k.

PLABEL	GMS_SpecialHandling
	mov	bLatchCapable,0
	mov	ax,62h + 80h	;don't clear the screen.
	int	10h
	mov	ax,0f00h
	int	10h
	and	al,7fh
	mov	dx,10h		;assume 1M.
	cmp	al,62h		;did it work?
	je	GMS_SizeFound	;yes.
	mov	dx,8h		;no, must be 512k.
	jmp	GMS_SizeFound

PLABEL SetBank_ET4000
	push	dx
	and	dl,0Fh
   mov   al,dl
   shl   dl,4
   or    al,dl
   mov   dx,3cdh
   out   dx,al
   pop   dx

	push	dx
	and	dl,30h
   shr   dl,4
   mov   al,dl
   shl   dl,4
   or    al,dl
   mov   dx,3cbh
   out   dx,al
   pop   dx

	ret


GetMemSize	endp

;----------------------------------------------------------------------------
; ClearScreen
; Entry: si = wBpp
;----------------------------------------------------------------------------
PPROC	ClearScreen_Far far
	call	ClearScreen
	retf
ClearScreen_Far 	endp

PPROC	ClearScreen	near
        assumes ds,Data
        assumes es,nothing
        assumes gs,nothing
        assumes fs,nothing
        mov     dx,ScreenSelector
        mov     es,dx
        shr     si,1                    ;si = 0,2,4,8,12,16
        movzx   ecx,PixelToByteTable[si]
        mov     dx,wScreenWidth
        mov     bx,dx                   ;bx = Screen Width in pels.
        cmp     si,12                   ;24 bpp?
        je      short @f                ;if no,
        xor     bx,bx                   ; then clear bx.
@@:     rol     dx,cl                   ;dx = screen width (adjusted for bpp).
        add     dx,bx                   ;Add in extra for 24 bpp (if needed).
        movzx   ebx,wScreenWidthBytes
        sub     bx,dx
        shr     dx,2
        xor     edi,edi
        mov     eax,edi
        mov     si,wScreenHeight
@@:     mov     cx,dx
        rep     stos dword ptr es:[edi]
        add     edi,ebx
        dec     si
        jnz     @b
        ret
ClearScreen     endp

;----------------------------------------------------------------------------
; GetScreenSelector
; Retrieves a screen selector from VFlatD.  This need only
; be done when a bank switched video adapter is installed.
; Entry:
;   cs:si-->Data Block
; Exit:
;   ax = Screen selector, 0 if error.
;----------------------------------------------------------------------------
PPROC GetScreenSelector near
        assumes ds,Data
        assumes es,nothing
        assumes gs,nothing
        assumes fs,nothing
        xor     di,di
        mov     es,di
        mov     ax,GET386API
        mov     bx,VFLATD_VXD
        int     2fh                     ;returns with es:di-->VFlatD Entry point
        xor     ax,ax                   ;assume error.
        mov     bx,es                   ;Is VFlatD entry point zero?
        or      bx,di                   ;
        jz      short GSS_None          ;Yes. Return a zero screen selector.
        pop     ax                      ;no. ax = our near return address
        push    cs                      ;push a far return address for the VDD
        push    ax                      ;to return to.
        push    es                      ;push the VDD entry point to call
        push    di
        mov     dx, GET_VIDEO_SEL       ;the argument to the VxD function
        mov     ax,1024                 ;size of frame buffer in pages
        mov     cx,cs                   ;es:di --> bank switch template
        mov     es,cx
	mov	di,pBankSwitchTemplate
        mov     cx,TemplateSize

PLABEL GSS_VDDRet
        retf                            ;far ret to VxD entry pt.
PLABEL GSS_None
        ret                             ;error return point.
GetScreenSelector endp

;----------------------------------------------------------------------------
; SetMode
; Entry:
;  ax = 1: Full Init (reset globals)
;  ax = 0: Basic init (h/w only -- assumes Full Init has 
;                   happened before).
;  bx = mode number
; Exit:
;  CARRY if error
; Sets:
;   wScreenWidth, wScreenHeight, wScreenWidthBytes, wMaxWidth, 
;   wMaxHeight, wPDeviceFlags, Rgn1, Rgn2
;----------------------------------------------------------------------------
PPROC	SetMode far
	push	eax			;save these over call
	push	ebx			;
	mov	eax,VDD_PRE_MODE_CHANGE ;function code goes in EAX
	movzx	ebx,OurVMHandle 	;this is needed for the call
	call	dword ptr VDDEntryPoint ;call the VDD to set refresh rate
	pop	ebx			;restore saved registers
	pop	eax			;
	call	pSetMode
	jc	SM_Error

; Get screen resolution
;
	mov	di,wResolution
        shl     di,2                    ;Resolution table has dword entries
        mov     cx,cs:ResolutionTable[di];get width.
        mov     dx,cs:ResolutionTable[di+2];get height
        mov     wScreenWidth,cx         ;store it.
	mov	wScreenHeight,dx	;store it.
;
; Get bytes/scan, pixels/scan
;
	mov	di,pAdapterEntry
	mov	si,cs:[di].pDataBlock
	mov	dx,cs:[si].wPDevFlags	;Get PDev flags
	mov	wPDeviceFlags,dx	;   and save
	movzx	eax,cs:[si].wPitch	;Width bytes.

	cmp	cx,800			;screen width = 800?
	jne	short @f		;no.
	cmp	[dwVideoMemorySize],00100000h	;1M (or better) on the card?
	jae	short @f		;yes. Use 1k scans.
	mov	ax,800			;pitch will be 800.
	or	wPDeviceFlags,BANKEDSCAN;Indicate broken rasters.
@@:	mov	wScreenWidthBytes,ax	;store width bytes.

	mov	cx,cs:[di].pTextOutDevProc; cx = textout dev proc address
	mov	dx,cs:[di].pBitBltDevProc;  dx = bitblt dev proc address
	cmp	bLatchCapable,0		;Do latches work on this h/w?
	jne	short @f		;yes.
	xor	cx,cx			;no. Can't use acceleration code.
	xor	dx,dx
@@:	test	wPDeviceFlags,BANKEDSCAN;Is this a broken raster device?
	jz	short @f		;no. 
	xor	cx,cx			;yes, Can't use acceleration code.
	xor	dx,dx
@@:	mov	BitBltDevProc,dx
	mov	TextOutDevProc,cx
	shl	eax,3			;eax = # of bits/scan
	mov	cx,wBpp
	xor	dx,dx
	div	cx			;ax = pels/scan
	mov	wMaxWidth,ax

	mov	bx,wScreenWidthBytes
	call	pExtraInit

PLABEL SM_ComputeMaxScreenHeight
;
; Compute max screen height
;
@@:     mov     ax,word ptr dwVideoMemorySize
        mov     dx,word ptr dwVideoMemorySize+2
        div     wScreenWidthBytes       ;AX contains # of scan lines
        mov     wMaxHeight,ax		;If max height < screen height then
					;AX = max screen height
        mov     di,wMaxWidth            ;DI = max screen width
        mov     dx,wScreenHeight        ;DX = screen height
        mov     bx,wScreenWidth         ;BX = screen width
        sub     di,bx                   ;DI = avail screen width of rgn1.
        js      SM_Error                ;Error if negative
        sub     ax,dx                   ;AX = height of rgn2.
        js      SM_Error                ;Error if negative

;----------------------------------------------------------------------------
; Compute offscreen memory layout.
;
; We have defined 2 regions:
;
; +-------------------------+       * RGN1 is non-existent in some modes.
; |                  |      |       
; |                  |      |
; |                  |      |
; |     VISIBLE      | RGN1 |
; |                  |      |
; |                  |      |
; |                  |      |
; |                  |      |
; |------------------+------|
; |                         |
; |                         |
; |          RGN2           |
; |                         |
; |                         |
; +-------------------------+
;
;----------------------------------------------------------------------------
	mov	Rgn1.left,bx
	mov	Rgn1.top,0
	mov	si,wMaxWidth
	mov	Rgn1.right,si
	mov	Rgn1.bottom,dx
	sub	si,bx
	mov	Rgn1.sr_width,si
	mov	Rgn1.sr_height,dx

	mov	Rgn2.left,0
	mov	Rgn2.top,dx
	mov	si,wMaxWidth
	mov	Rgn2.right,si
	mov	Rgn2.sr_width,si
	mov	si,wMaxHeight
	mov	Rgn2.bottom,si
	sub	si,dx
	mov	Rgn2.sr_height,si

PLABEL SM_Exit
	clc
	ret

PLABEL SM_Error
	stc
	ret

SetMode	endp

ResolutionTable label word
        dw      320,200
        dw      640,480
        dw      800,600
        dw      1024,768
        dw      1280,1024
        dw      1152,864
        dw      1600,1200

PixelToByteTable        label   word
        dw      -3              ;1 bpp
        dw      -1              ;4 bpp
        dw      0               ;8 bpp
        dw      0               ;unused
        dw      1               ;16 bpp
        dw      0               ;unused
        dw      1               ;24 bpp, additional adj required.
        dw      0               ;unused
        dw      2               ;32 bpp.

;----------------------------------------------------------------------------
; ValidateMode
; Attempt to set the mode and verify that it works.  Then set back to
; the original mode and return yes, maybe or mo.
; Entry:
;   lpValMode = DISPVALMODE structure
; Exit:
;   ax = VALMODE_YES or VALMODE_NO_WRONGDRV, VALMODE_NO_NOMEM,
;        VALMODE_NO_NODAC, VALMODE_NO_UNKNOWN
;----------------------------------------------------------------------------
cProc   ValidateMode,<FAR,PUBLIC,PASCAL,NODATA>,<esi,edi>
	parmD	lpValMode
cBegin
	mov	ax,DGROUP
	mov	ds,ax
        assumes ds,Data
        assumes es,nothing
        assumes gs,nothing
        assumes fs,nothing
	push	wResolution		;save current resolution 
	push	wBpp			; and bpp.
	push	pAdapterEntry		;   and pAdapterEntry

; get the details of the mode that we are interested in. 

	les	di,lpValMode
	mov	si,es:[di].dvmXRes
	shl	esi,16
	mov	si,es:[di].dvmYRes
	call	XYtoRes			;returns with ax = wResolution value
	mov	wResolution,ax
	mov	ax,es:[di].dvmBpp
	mov	wBpp,ax
	xor	ax,ax
	mov	pAdapterEntry,ax	;Force FindMode to search from top.


; if we are not currently running the driver, we need to identify the adapter


	cmp	ScreenSelector,0	;Is the driver currently running?
	jnz	VM_GetModeInfo		;yes.
	call	DetermineAdapter	;Is this an adapter we support?
	test	ax,ax
	jz	VM_FailWrongDrv		;no.
	mov	wDeviceType,ax
	xor	ax,ax
	mov	dx,10h			;assume 1M. 
        mov     word ptr [dwVideoMemorySize],ax
        mov     word ptr [dwVideoMemorySize+2],dx

PLABEL VM_GetModeInfo
	call	FindMode
	or	bx,bx
	jz	short VM_FailNoMem
	mov	ax,VALMODE_YES
PLABEL VM_Done
	pop	pAdapterEntry		;
	pop	wBpp
	pop	wResolution
cEnd

PLABEL VM_FailNoMem
	mov	ax,VALMODE_NO_NOMEM
	jmp	VM_Done

PLABEL VM_FailWrongDrv
	mov	ax,VALMODE_NO_WRONGDRV
	jmp	VM_Done

;----------------------------------------------------------------------------
; DetermineAdapter
; Exit:
;   ax = device type  or 0 if none found.
;----------------------------------------------------------------------------
PPROC	DetermineAdapter	near
	mov	wModeFlags,0
	call	Is_ET4000
	mov	bCanVirtualize,0ffh
	mov	pBankSwitchTemplate,offset ET4000_BankSwitchTemplate
	mov	TemplateSize, offset ET4000_BankSwitchTemplateSize
	mov	pExtraInit,offset SM_ExtraInit_ET4000
	mov	pSetBank,offset SetBank_ET4000
	mov	pSetMode,offset SM_ET4000
	mov	wBaseMode,2Eh
	mov	pAdapterTable,offset ET4000_AdapterTable
	mov	nTableEntries,ET4000_nEntries
	mov	wDeviceType,ax
	ret

DetermineAdapter	endp

;----------------------------------------------------------------------------
; B A N K   S W I T C  H   T E M P L A T E S
;
;  This template is given to vflatd.386 which copies it inline in to the
;  page fault handling code.
; NOTE: This code runs at ring 0 in a USE32 code segment, so be carefull!!!
;
; Entry:
;   ax = bank number (0-15)
; Exit:
;   ALL REGISTERS MUST BE PRESERVED (except for dx,ax)
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; ET4000_BankSwitchTemplate
;----------------------------------------------------------------------------
ET4000_BankSwitchTemplate label byte
	push	bx
        mov     bl, al
		  and     al, 0fh
        mov     dl, al                  ;mov edx,eax
        shl     al, 4
        or      al, dl
        db      66h,0bah,0cdh,03h       ;mov dx, 3CDh
        out     dx, al
		  and     bl, 30h
		  mov     al, bl
		  shr     al, 4
		  or      al, bl
        db      66h,0bah,0cbh,03h       ;mov dx, 3CBh
        out     dx, al
	pop	bx
ET4000_BankSwitchTemplateSize = $ - ET4000_BankSwitchTemplate

;----------------------------------------------------------------------------
; M O D E   S E T   R O U T I N E S 
; Entry:
;   bx = mode number 
; Exit:
;   CARRY if mode cannot be set.
;----------------------------------------------------------------------------
PPROC	SM_ET4000	near
	cmp	wBpp,8
	ja	short @f

	mov	ax,bx
	push	ax
	or	al,80h			;don't erase screen at this time
	int	10h
	mov	ax,0F00h
	int	10h
	and	al,NOT 80h		;get rid of "don't erase screen" bit
	pop	bx
	cmp	al,bl			;do modes match?
	jne	SM_Not
	clc
	ret
@@:	or	bl,80h			;don't erase screen at this time
	cmp	wBpp,24
	jne	short @f
	mov	bh,bl
	mov	bl,0FFh
@@:	mov	ax,010F0h
	int	10h
	cmp	ax,10h
	jne	SM_Not
	clc
	ret

PLABEL SM_Not
	stc
	ret
SM_ET4000	endp


;----------------------------------------------------------------------------
; SM_Wonder
;----------------------------------------------------------------------------
PPROC	SM_Wonder	near
	mov	dx,1ceh
	mov	al,0b6h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,not 5
	mov	ah,al
	mov	al,0b6h
	dec	dx
	out	dx,ax
	
	mov	ax,bx
	push	ax
	or	al,80h			;don't erase screen at this time
	int	10h
	mov	ax,0F00h
	int	10h
	and	al,NOT 80h		;get rid of "don't erase screen" bit
	pop	bx
	cmp	al,7bh
	jne	short @f
	mov	al,62h
@@:	cmp	al,bl			;do modes match?
	jne	SM_Not
	clc
	ret
SM_Wonder	endp

;----------------------------------------------------------------------------
; SM_V7
;----------------------------------------------------------------------------
PPROC	SM_V7	near
	push	bx			;save the mode
	or	bl,80h			;don't erase the screen at this time
	mov	ax,6f05h
	int	10h
	mov	ax,6f04h
	int	10h
	and	al,NOT 80h		;get rid of "don't erase screen" bit
	pop	bx
	cmp	al,bl
	jne	SM_Not
	clc
	ret
SM_V7	endp


;----------------------------------------------------------------------------
; SM_VESA
;----------------------------------------------------------------------------
PPROC	SM_VESA	near
	mov	ax,4f02h
	or	bx,8000h		;don't erase screen at this time
	int	10h
	cmp	ax,004fh
	jne	SM_Not
	clc
	ret
SM_VESA	endp

;----------------------------------------------------------------------------
; E X T R A   I N I T   R O U T I N E S
; Entry:
;   bx = screen width in bytes
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; SM_ExtraInit_ET4000
;----------------------------------------------------------------------------
PPROC SM_ExtraInit_ET4000	near

; we use the bLatchBank variable only when we are in PLANAR mode where banks are
; 256k in size.

	mov	al,11h
	cmp	wScreenHeight,480
	je	short @f
	mov	al,33h
	cmp	wScreenHeight,768
	je	short @f
	mov	al,022h                         ;assume 8x6 with 1K scans
        test    wPDeviceFlags,BANKEDSCAN        
	je	short @f
        mov     al,11h                          ;8x6 with broken rasters.
@@:	mov	bLatchBank,al
	cmp	bx,1024
	jne	short @f
	mov	dx,3d4h
	mov	ax,8013h
	out	dx,ax
@@:	ret
SM_ExtraInit_ET4000	endp

;----------------------------------------------------------------------------
; CanWeUseTheLatches
; returns:
;   ax = 1 if a planar write affects 4 contiguous pixels
;   ax = 0 if not.
;----------------------------------------------------------------------------
PPROC	CanWeUseTheLatches	near
	mov	ax,KernelsScreenSel
	mov	es,ax
	mov	eax,87654321h
	mov	es:[0],eax		;set screen mem to known pattern.
	mov	es:[4],eax		;set screen mem to known pattern.
	mov	dx,3ceh			;3ce = graphics controller
	in	al,dx
	mov	bl,al			;bl = 3ce()
	mov	al,5			;select the mode register
	out	dx,al
	inc	dx
	in	al,dx			;
	mov	bh,al			;bh = 3cf(3ce(5))
	or	al,2
	out	dx,al			;write mode 2 selected.

	mov	dx,3c4h			;3c4 = sequencer
	in	al,dx		
	mov	cl,al			;cl=3c4()
	mov	al,4			;select index 4 (memory mode)
	out	dx,al
	inc 	dx
	in	al,dx			
	mov	ch,al			;ch=3c5(3c4(4))
	and	al,11110111b		;clear chain 4 bit
	out	dx,al			;disable chain 4 bit.
	mov	byte ptr es:[0],0dh	;write to video mem.
	mov	byte ptr es:[1],0dh	;write to video mem.
;----------------------------------------------------------------------------
; Restore sequencer
;----------------------------------------------------------------------------
	mov	al,ch			
	out	dx,al			;3c5(3c4(4)) = ch
	dec	dx			
	mov	al,cl
	out	dx,al			;3c4(4) = cl
;----------------------------------------------------------------------------
; Restore Graphics Controller
;----------------------------------------------------------------------------
	mov	dx,3cfh
	mov	al,bh
	out	dx,al
	dec	dx
	mov	al,bl
	out	dx,al	
	mov	edx,0ffff00ffh
	xor	al,al
	cmp	es:[0],edx
	jne	short @f
	cmp	es:[4],edx
	jne	short @f
	inc	al
@@:	ret
CanWeUseTheLatches	endp


sEnd	InitSeg

sBegin	Code
assumes	cs,Code
;----------------------------------------------------------------------------
; ResetHiResMode
;   This function is called by the VDD to restore the graphics adapter 
;   into graphics mode when switching to the system vm.  Note that this
;   function is in a page-locked segment.
;   
;   Called when reentering the windows vm.
;----------------------------------------------------------------------------
PPROC   ResetHiResMode far
	mov	ax,DGROUP
	mov	ds,ax
        assumes ds,Data
        assumes es,nothing
        assumes gs,nothing
	assumes fs,nothing
	push	esi
	push	edi
	mov	bx,wCurrentMode
	xor	ax,ax			;basic init.
	call	SetMode

	cmp	wBpp,8
	ja	short RHR_CallVDD
	mov	cx,256
	je	short @f
	mov	cx,16
	cmp	wBpp,4
	je	short @f
	mov	cx,2
@@:	xor	ax,ax
	push	ds
	lds	si,lpColorTable		;ds:[si]-->color table
	call	SetRAMDAC_far		;set up initial palette
	pop	ds

PLABEL RHR_CallVDD
	les	si,lpDriverPDevice
lock	and	es:[si].deFlags,not BUSY

;
;Call the VDD to order it to save the current register state.  This will
;hopefully assure that the Windows VM has the running state saved:
;
	mov	eax,VDD_SAVE_DRIVER_STATE
	movzx	ebx,OurVMHandle 	;
	call	dword ptr VDDEntryPoint ;
;
;Now clear the screen so the user sees black until UserRepaint happens:
;
	mov	si,wBpp 		;needed for call
	call	ClearScreen_Far 	;
	pop	edi			;
	pop	esi			;
	retf

ResetHiResMode endp



sEnd	Code

end
