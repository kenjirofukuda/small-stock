Class {
	#name : #GdsObjectProperty,
	#superclass : #Object,
	#instVars : [
		'propertyName',
		'propertyOwner',
		'initialValue',
		'propertyType',
		'propertyValue',
		'announcer',
		'acceptWhen',
		'lock',
		'nilAllowed'
	],
	#category : #'GdsFeel-Foundation-Property'
}

{ #category : #'as yet unclassified' }
GdsObjectProperty class >> named: aPropertyName owner: anObject [
	^self named: aPropertyName type: self typeClass owner: anObject
]

{ #category : #'as yet unclassified' }
GdsObjectProperty class >> named: aPropertyName type: aClass owner: anObject [
	^self new 
		propertyName: aPropertyName;
		propertyType: aClass;
		propertyOwner: anObject
]

{ #category : #'as yet unclassified' }
GdsObjectProperty class >> typeClass [
	^Object
]

{ #category : #actions }
GdsObjectProperty >> acceptWhen: anAcceptBooleanBlock [
	acceptWhen := anAcceptBooleanBlock.
]

{ #category : #accessing }
GdsObjectProperty >> announcer [
	^announcer ifNil: [announcer := Announcer new]
	
]

{ #category : #check }
GdsObjectProperty >> changedTest: anObject oldValue: oldValue [
	^oldValue ~= anObject.
	
]

{ #category : #check }
GdsObjectProperty >> checkAccept: anObject [
	acceptWhen
		ifNotNil: [ | blockResult |
			blockResult := (acceptWhen value: anObject).
			blockResult
				ifFalse: [ ^self error: ('Can''t accept value: ', anObject printString)]].

]

{ #category : #check }
GdsObjectProperty >> checkType: anObject [
	self checkType: anObject kindOf: propertyType

]

{ #category : #check }
GdsObjectProperty >> checkType: anObject kindOf: aPropertyClass [
	(self nilAllowed and: [anObject isNil])
		ifTrue: [ ^ self ].
	
	(anObject isKindOf: aPropertyClass)
		ifFalse: [ 
			^self error: ('value only: ',  aPropertyClass asString, ' but: ', anObject printString) ].

]

{ #category : #'error handling' }
GdsObjectProperty >> error: aString [
	GdsPropertyError new signal: aString.
]

{ #category : #check }
GdsObjectProperty >> fireValueChangedNew: newValue old: oldValue [
	propertyValue := newValue.
	self announcer announce: 
		(GdsPropertyChanged new property: self;
			newValue: newValue;
			oldValue: oldValue).
	
]

{ #category : #accessing }
GdsObjectProperty >> getValue [
	^propertyValue ifNil: [ propertyValue := initialValue.]
	
	
]

{ #category : #accessing }
GdsObjectProperty >> initialValue: anObject [
	initialValue := anObject.
	
]

{ #category : #'initialize-release' }
GdsObjectProperty >> initialize [ 
	super initialize.
	propertyType := self class typeClass.
	propertyValue := nil.
	lock := false.
	
]

{ #category : #printing }
GdsObjectProperty >> labelStyleColon [
	^self labelStyleColonUppercased: false.
]

{ #category : #printing }
GdsObjectProperty >> labelStyleColonUppercased: aBoolean [	
	^String streamContents: [:s |
		s nextPutAll: 
			(aBoolean
				ifTrue: [self propertyName asUppercase]
				ifFalse: [self propertyName]).
		s nextPut: $:.
		s nextPut: Character space.
		s nextPutAll: self getValue printString].
]

{ #category : #printing }
GdsObjectProperty >> labelStyleParlen [
	^self labelStyleParlenUppercased: false.
]

{ #category : #printing }
GdsObjectProperty >> labelStyleParlenUppercased: aBoolean [	
	^String streamContents: [:s |
		s nextPutAll: 
			(aBoolean
				ifTrue: [self propertyName asUppercase]
				ifFalse: [self propertyName]).
		s nextPut: $(.
		s nextPutAll: self getValue printString. 
		s nextPut: $). ].
]

{ #category : #check }
GdsObjectProperty >> newValue: anObject [
	^anObject 
	
]

{ #category : #accessing }
GdsObjectProperty >> nilAllowed [
	^ nilAllowed ifNil: [ nilAllowed := false ]
]

{ #category : #accessing }
GdsObjectProperty >> nilAllowed: aBoolean [
	nilAllowed := aBoolean 
]

{ #category : #check }
GdsObjectProperty >> oldValue [
	^propertyValue ifNil: [ propertyValue := initialValue ]
	
]

{ #category : #printing }
GdsObjectProperty >> printOn: aStream [
	aStream nextPutAll: 'property: '.
	aStream nextPutAll: self propertyName.
	aStream nextPut: $(.
	aStream nextPutAll: self getValue printString.
	aStream nextPut: $).
	
]

{ #category : #accessing }
GdsObjectProperty >> propertyName [
	^propertyName.
	
]

{ #category : #accessing }
GdsObjectProperty >> propertyName: aPropertyName [
	propertyName := aPropertyName.
	
]

{ #category : #accessing }
GdsObjectProperty >> propertyOwner: aPropertyOwner [
	propertyOwner := aPropertyOwner.
	
]

{ #category : #accessing }
GdsObjectProperty >> propertyType: aClass [
	propertyType := aClass.
	
]

{ #category : #accessing }
GdsObjectProperty >> setValue: anObject [
	| oldValue newValue |
	lock ifTrue: [ ^ self ].
	self checkType: anObject.
	self checkAccept: anObject.
	lock := true.	
	oldValue := self oldValue.
	newValue := self newValue: anObject.
	[(self changedTest: newValue oldValue: oldValue)
		ifTrue: [
			self fireValueChangedNew: newValue old: oldValue]]
		ensure: [lock := false].
	
]

{ #category : #debugging }
GdsObjectProperty >> spy [
	| spyWindow |
	spyWindow := (AnnouncementSpy on: self announcer) build. 
	spyWindow openInWorld.
	^spyWindow
]

{ #category : #debugging }
GdsObjectProperty >> spyAutoCloseAfterSeconds: aNumber [
	| spyWindow |
	spyWindow := self spy.
	[ (Delay forSeconds: aNumber) wait.
	  spyWindow delete] fork.
]

{ #category : #subscription }
GdsObjectProperty >> unsubscribe: anObject [
	self announcer unsubscribe: anObject.
]

{ #category : #evaluting }
GdsObjectProperty >> value [
	^self getValue.
]

{ #category : #check }
GdsObjectProperty >> valueAssign: newValue [
	propertyValue := newValue.
	
]

{ #category : #announce }
GdsObjectProperty >> whenChangedDo: aBlock [
	| block |
	"from: NewValueHolder"	
	block := [:announcement :ann | 
		aBlock 
			cull: announcement newValue  
			cull: announcement oldValue  
			cull: announcement 
			cull: ann ].
	
	self announcer when: GdsPropertyChanged  do: block
]

{ #category : #announce }
GdsObjectProperty >> whenChangedPropertyDo: aBlock [
	| block |
	
	block := [:announcement :ann | 
		aBlock 
			cull: announcement property
			cull: announcement 
			cull: ann ].
	
	self announcer when: GdsPropertyChanged  do: block
]
