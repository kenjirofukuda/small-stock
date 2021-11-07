Class {
	#name : #GdsHatchSets,
	#superclass : #Object,
	#instVars : [
		'hatchMap'
	],
	#category : #'GdsFeel-Developer-Model'
}

{ #category : #specification }
GdsHatchSets class >> specRecord [
	^{
	{'A'  . 0.0 . 127}.
	{'B'  . 45.0 . 127}.
	{'C'  . 90.0 . 127}.
	{'D'  . 135.0 . 127}
	}.
]

{ #category : #initialization }
GdsHatchSets >> initialize [
	super initialize.
	hatchMap := Dictionary new.
	 self class specRecord do: [:toliplet |
		hatchMap at: toliplet first put: (GdsHatch new setName: toliplet first angle: toliplet second linesPerScreen: toliplet third).
		].
	
]

{ #category : #initialization }
GdsHatchSets >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	hatchMap keys do: [:key | 
		aStream nextPutAll: key.
		aStream nextPut: $, ].
	aStream skip: -1.
	aStream nextPut: $).	
]
