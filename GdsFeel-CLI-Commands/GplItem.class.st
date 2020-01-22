Class {
	#name : #GplItem,
	#superclass : #GplBiContextHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplItem class >> methodName [
	^'ITEM'
]

{ #category : #handler }
GplItem >> argumentMustBe [
	^self error: 'ARGUMENT MUST BE SCALAR VALUE -2 , -1 and 0 TO 9'.

]

{ #category : #handler }
GplItem >> findEmpty: aToken [	
	^self nullVector.
]

{ #category : #handler }
GplItem >> findHasData: aToken [	
	^self nullVector.
]

{ #category : #handler }
GplItem >> functionCall: aToken [
	^self getCurrentItemNumber: aToken.

]

{ #category : #handler }
GplItem >> getCurrentItemNumber: aToken [
	^self currentItem number asGdsValue.	

]

{ #category : #handler }
GplItem >> printItems: aToken [
	| lines colonMaxIndex |
	lines := {Character cr} split: self currentItem consoleString .
	colonMaxIndex := (lines collect: [:line | line indexOf: $:]) max.
	lines := lines collect: [:line | |fillWidth|
		fillWidth := (colonMaxIndex - (line indexOf: $:)).
		(String new: fillWidth withAll: Character space), line.].
	^(String cr join: lines) asGdsValue . 

]

{ #category : #handler }
GplItem >> procedureCall: aToken [
	(evaluator numArgs: aToken) = 0
		ifTrue: [^self printItems: aToken]
		ifFalse: [^self setCurrentItem: aToken].
	^self nullVector.
]

{ #category : #handler }
GplItem >> setCurrentItem: aToken [	
	| gv1 vec smVec smValue |
	gv1 := evaluator popArg asGplValue.
	vec := gv1 asVector.
	(vec mode = 2 or: [vec mode = 7])
		ifFalse: [^self argumentMustBe].
	smVec := vec asSmalltalkValue.
	(smVec size = 1)
		ifFalse: [^self argumentMustBe].
	smValue := smVec first.
	
	((-2 to: 9) includes: smValue)
		ifFalse: [^self argumentMustBe].
	smValue negative
		ifTrue: [
			smValue = -1
				ifTrue: [^self findEmpty: aToken].
			smValue = -2
				ifTrue: [^self findHasData: aToken]].	
	self structure items current: smValue.
	^self nullVector.
]
