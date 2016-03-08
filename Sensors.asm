    #include <p18f4620.inc>
    #include <MACROS.inc>
    #include <Constants.inc>

    extern bin16_BCD, direction
    extern LCD_INIT, DELAY_ROUTINE, NIBBLE_LCD, DISP_TEXT, READ_KEYPAD, keypress
    
    udata
pingtime    res	    1
pingH	    res	    1
NumH	    res	    1
NumL	    res	    1
TenK	    res	    1
Thou	    res	    1
Hund	    res	    1
Tens	    res	    1
Ones	    res	    1
LeftL	    res	    1
LeftH	    res	    1
RightL	    res	    1
RightH	    res	    1
IRState	    res	    1		;this holds the Infrared sensor state
tempBin	    res	    1
BinNum	    res	    1  
B1L	    res	    1		;variables for the buckets. xL = position lower
B1H	    res	    1		;xH = position higher byte
B1S	    res	    1		;xS = bucket sticker states 
B2L	    res	    1     
B2H	    res	    1  
B2S	    res	    1	 
B3L	    res	    1
B3H	    res	    1
B3S	    res	    1
B4L	    res	    1	    
B4H	    res	    1
B4S	    res	    1
B5L	    res	    1	    
B5H	    res	    1
B5S	    res	    1
B6L	    res	    1	    
B6H	    res	    1	    
B6S	    res	    1
B7L	    res	    1	    
B7H	    res	    1	    
B7S	    res	    1
PoleH	    res	    1
PoleL	    res	    1
PoleLocL    res	    1
PoleLocH    res	    1

	    
	    
    code
    global	ADC,PING,DIST,pingtime, pingH, NumH, NumL, TenK, Thou ,Hund, Tens, Ones,ENCODER1,ENCODER2, LeftL, LeftH, disp_encoders,RightL,RightH,PoleL,PoleH
    global	IRState, B1L,B1H,B1S,B2L,B2H,B2S,B3L,B3H,B3S,B4L,B4H,B4S,B5L,B5H,B5S,B6L,B6H,B6S,B7L,B7H,B7S, Disp_Number,dispPING,BinNum,PoleLocH,PoleLocL
;ADC is a blocking subroutine, in that it involves slightly longer delays 
ADC	movlw	B'00000001'	;configure ADCON0 for AN0 input (RA0)
	btfsc	direction, 0
	movlw	B'00000101'	;Configure for AN1 (RA1) if direction reversed 
     	movwf	ADCON0		
     	bsf	ADCON0,1	;start the conversion
WAIT	btfsc	ADCON0,1	;wait until the conversion is completed
     	bra	WAIT		;poll the GO bit in ADCON0
	bcf	ADCON0,0	;disable ADC now
	;btfss	direction,0
	;incf	IRState
	;btfsc	direction,0
	;decf	IRState
	;return 
fin    	return

Disp_Number
	movlw	0x30
	addwf	TenK,W
	lcdData
	movlw	0x30
	addwf	Thou,W
	lcdData
	movlw	0x30
	addwf	Hund,W
	lcdData
	movlw	0x30
	addwf	Tens,W
	lcdData
	movlw	0x30
	addwf	Ones,W
	lcdData
	return
	
disp_encoders 
	lcdClear
	movff	LeftL,NumL
	movff	LeftH,NumH
	call	bin16_BCD
	call	Disp_Number
	movff	RightL,NumL
	movff	RightH,NumH
	call	bin16_BCD
	call	Disp_Number
	return
	
Ultrasound
    db "Ultrasound:",0
	
dispPING	
	movff	PoleL,NumL
	movff	PoleH,NumH
	call	bin16_BCD	;convert the previous values to BCD notation
	dispText  Ultrasound,first_line
	call	Disp_Number
	return
	
PING	bsf	TRIG		;delay 0x2 gives 15 us approximately at 8Mhz
	delay	0x2
	bcf	TRIG
	btfsc	ECHO
	bra	$-2
	
	return
	
DIST	btfss	PORTB,4		;if RB4 is high, reset and start timer 3
	goto	echo_b
echo_a	clrf	TMR0H
	clrf	TMR0L		;clear register and prescaler
	bsf	T0CON,7		;enable timer
	bcf	INTCON,0	;reset interrupt vector 
	retfie	1
echo_b	bcf	T0CON,7		;disable timer
	movf	TMR0L,W
	movwf	PoleL
	movf	TMR0H,W
	movwf	PoleH
		
	bcf	INTCON,0	;reset interrupt vector
	retfie	1			;return from interrupt
	

	
ENCODER1
	btfsc	LComp		;check direction of encoder
	goto	for
	goto	back
	
for	incf	LeftL
	btfsc	STATUS,C
	incf	LeftH
	goto	transf
back	decf	LeftL
	btfss	STATUS,C
	decf	LeftH
transf	bcf	INTCON3,1	;reset flag bit
	retfie	1
	
ENCODER2
	btfss	RComp		;check direction of encoder. directions reversed
	goto	for2
	goto	back2
	
for2	incf	RightL
	btfsc	STATUS,C
	incf	RightH
	goto	transf2
back2	decf	RightL
	btfss	STATUS,C
	decf	RightH
transf2	bcf	INTCON,1	;reset flag bit
	retfie	1
	
	end