Class {
	#name : #GplInitLib,
	#superclass : #GplBiContextHandler,
	#instVars : [
		'libname',
		'dbu',
		'unit'
	],
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplInitLib class >> methodName [
	^ 'INITLIB'
]

{ #category : #'as yet unclassified' }
GplInitLib >> extractArguments [
	| arg1 gv1 |
	arg1 := evaluator popArg.
	gv1 := arg1 asGplValue.
	gv1 isList
		ifFalse: [ ^ self error: self usageString ].
	gv1 length = 6
		ifFalse: [ ^ self error: self usageString ].
	libname := gv1 at: 1.
	dbu := gv1 at: 4.
	unit := gv1 at: 5.
	self extractLibName.
	self extractDatabaseUnits.
	self extractUnitString
]

{ #category : #'as yet unclassified' }
GplInitLib >> extractDatabaseUnits [
	dbu := [ dbu asScalar ]
		on: Error
		do: [ :ex | 
			dbu := nil.
			^ self error: 'DBU MUST BE SCALAR VALUE' ].
	dbu := dbu asSmalltalkValue.
	GdsLibrary checkDatabaseUnit: dbu
]

{ #category : #'as yet unclassified' }
GplInitLib >> extractLibName [
	libname isCharVector
		ifFalse: [ libname := nil.
			^ self error: 'LIBRARY NAME MUST BE STRING' ].
	libname := libname gplString.
	GdsLibrary checkLibName: libname
]

{ #category : #'as yet unclassified' }
GplInitLib >> extractUnitString [
	unit isCharVector
		ifFalse: [ unit := nil.
			^ self error: 'UNIT  MUST BE STRING' ].
	unit := unit gplString.
	GdsLibrary checkUnitString: unit
]

{ #category : #'as yet unclassified' }
GplInitLib >> functionCall: aToken [
	
]

{ #category : #'as yet unclassified' }
GplInitLib >> procedureCall: aToken [
	| lib |
	(evaluator numArgs: aToken) < 1
		ifTrue: [ ^ self error: 'MISSING ARGUMENT' ].
	self extractArguments.
	lib := GdsLibrary
		initializeName: libname
		databaseUnits: dbu
		unitString: unit.
	^ self nullVector
]

{ #category : #'as yet unclassified' }
GplInitLib >> usageString [
	^ 'INITLIB {filename};"";"";{dbu};{unit};""'
]
