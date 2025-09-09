Trait {
	#name : #TGdsModel,
	#category : #'GdsFeel-Foundation-Tests'
}

{ #category : #'T-GdsModel' }
TGdsModel >> attributesMap [
	| map |
	map := Dictionary new.
	self writeAttributesOn: map.
	^ map
]

{ #category : #'T-GdsModel' }
TGdsModel >> checkAnnouncer: anInstance [
	((anInstance respondsTo: #announcer)
		and: [ (anInstance perform: #announcer) class = Announcer ])
		ifFalse:
			[ self error: 'no Announcer instance: ' , anInstance printString ]
]

{ #category : #'T-GdsModel' }
TGdsModel >> endProperties [
	self endProperties: self
]

{ #category : #'T-GdsModel' }
TGdsModel >> endProperties: anInstance [
	self checkAnnouncer: anInstance.
	anInstance class allInstVarNames
		do: [ :propName | anInstance instVarNamed: propName ]
]

{ #category : #'T-GdsModel' }
TGdsModel >> writeAttributesOn: aDictionry [
	self class instVarNames
		do: [ :iName | 
			| iVar |
			iVar := self instVarNamed: iName.
			(iVar isKindOf: GdsObjectProperty)
				ifTrue: [ aDictionry at: iVar propertyName put: iVar getValue ] ]
]
