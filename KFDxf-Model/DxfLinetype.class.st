Class {
	#name : #DxfLinetype,
	#superclass : #DxfDataGroups,
	#category : #'KFDxf-Model'
}

{ #category : #accessing }
DxfLinetype >> description [
	^ self encodedStringByNumber: 3 default: ''	
]

{ #category : #accessing }
DxfLinetype >> elementCount [
	^ self numberByNumber: 73 default: 0	
]

{ #category : #'as yet unclassified' }
DxfLinetype >> lookupName [
	^ self encodedStringByNumber: 2 default: '###ERROR###'
]

{ #category : #accessing }
DxfLinetype >> name [
	^ name ifNil: [ name := self lookupName ]
]

{ #category : #accessing }
DxfLinetype >> patternLength [
	^ self numberByNumber: 40 default: 0.0	
]

{ #category : #accessing }
DxfLinetype >> patternValues [
	^ self dataGroups 
		select: [ :g | g code = 49 ]
		thenCollect: [ :g | g data trim asNumber ]
]

{ #category : #printing }
DxfLinetype >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self name printOn: aStream.
	aStream nextPut: $).	
]
