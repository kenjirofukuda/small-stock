Class {
	#name : #GdsLoopContext,
	#superclass : #Object,
	#instVars : [
		'break',
		'result'
	],
	#category : #'GdsFeel-Model-StreamFormat'
}

{ #category : #'as yet unclassified' }
GdsLoopContext class >> spec [
^{
#(16r00 HEADER) . 
#(16r01 BGNLIB) . 
#(16r02 LIBNAME) . 
#(16r03 UNITS) . 
#(16r04 ENDLIB) . 
#(16r05 BGNSTR) . 
#(16r06 STRNAME) . 
#(16r07 ENDSTR) . 
#(16r08 BOUNDARY) . 
#(16r09 PATH) . 
#(16r0A SREF) . 
#(16r0B AREF) . 
#(16r0C TEXT) . 
#(16r0D LAYER) . 
#(16r0E DATATYPE) . 
#(16r0F WIDTH) . 
#(16r10 XY) . 
#(16r11 ENDEL) . 
#(16r12 SNAME) . 
#(16r13 COLROW) . 
#(16r14 TEXTNODE) . 
#(16r15 NODE) . 
#(16r16 TEXTTYPE) . 
#(16r17 PRESENTATION) . 
#(16r18 SPACING) . 
#(16r19 STRING) . 
#(16r1A STRANS) . 
#(16r1B MAG) . 
#(16r1C ANGLE) . 
#(16r1D UINTEGER) . 
#(16r1E USTRING) . 
#(16r1F REFLIBS) . 
#(16r20 FONTS) . 
#(16r21 PATHTYPE) . 
#(16r22 GENERATIONS) . 
#(16r23 ATTRTABLE) . 
#(16r24 STYPTABLE) . 
#(16r25 STRTYPE) . 
#(16r26 ELFLAGS) . 
#(16r27 ELKEY) . 
#(16r28 LINKTYPE) . 
#(16r29 LINKKEYS) . 
#(16r2A NODETYPE) . 
#(16r2B PROPATTR) . 
#(16r2C PROPVALUE) . 
#(16r2D BOX) . 
#(16r2E BOXTYPE) . 
#(16r2F PLEX) . 
#(16r30 BGNEXTN) . 
#(16r31 ENDTEXTN) . 
#(16r32 TAPENUM) . 
#(16r33 TAPECODE) . 
#(16r34 STRCLASS) . 
#(16r35 RESERVED) . 
#(16r36 FORMAT) . 
#(16r37 MASK) . 
#(16r38 ENDMASKS) . 
#(16r39 LIBDIRSIZE) . 
#(16r3A SRFNAME) . 
#(16r3B LIBSECUR)  
}
]

{ #category : #'as yet unclassified' }
GdsLoopContext >> break [
	^ break
]

{ #category : #'as yet unclassified' }
GdsLoopContext >> break: aBoolean [
	break := aBoolean
]

{ #category : #'as yet unclassified' }
GdsLoopContext >> initialize [
	super initialize.
	break := false
]

{ #category : #'as yet unclassified' }
GdsLoopContext >> result [
	^ result
]

{ #category : #'as yet unclassified' }
GdsLoopContext >> result: anObject [
	result := anObject
]
