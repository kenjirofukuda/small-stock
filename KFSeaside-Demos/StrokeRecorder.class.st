Class {
	#name : #StrokeRecorder,
	#superclass : #Object,
	#instVars : [
		'segs'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #adding }
StrokeRecorder >> addPoint: aPoint withMark: aMarkerString [
	segs
		add:
			{aMarkerString.
			aPoint x.
			aPoint y}
]

{ #category : #recording }
StrokeRecorder >> asXmlElement [
	| attrDict elmt |
	attrDict := Dictionary new.
	self attributesOn: attrDict.
	elmt := XMLElement name: 'path' attributes: attrDict.
	^ elmt
]

{ #category : #recording }
StrokeRecorder >> attributesOn: aDictionary [
	aDictionary at: 'd' put: self dimensionString
]

{ #category : #recording }
StrokeRecorder >> closePath [
	segs add: {'Z'}
]

{ #category : #recording }
StrokeRecorder >> dimensionString [
	^ (segs
		collect: [ :seg | 
			(seg first = 'M' or: [ seg first = 'L' ])
				ifTrue: [ seg first , seg second asString , ' ' , seg third asString ]
				ifFalse: [ seg first ] ]) joinUsing: ' '
]

{ #category : #'initialize-release' }
StrokeRecorder >> initialize [
	segs := OrderedCollection new
]

{ #category : #recording }
StrokeRecorder >> lineToPoint: aPoint [
	self addPoint: aPoint withMark: 'L'
]

{ #category : #recording }
StrokeRecorder >> moveToPoint: aPoint [
	self addPoint: aPoint withMark: 'M'
]

{ #category : #recording }
StrokeRecorder >> points [
	^ (segs
		collect: [ :seg | 
			(seg first = 'M' or: [ seg first = 'L' ])
				ifTrue: [ seg second @ seg third ]
				ifFalse: [ nil ] ]) reject: [ :e | e isNil ]
]
