Class {
	#name : #DxfInsert,
	#superclass : #DxfShape,
	#category : #'KFDxf-Model'
}

{ #category : #accessing }
DxfInsert >> blockName [
	^ self encodedStringByNumber: 2 
]

{ #category : #accessing }
DxfInsert >> blockName: aName [
	self setCode: 2 data: aName.

]

{ #category : #accessing }
DxfInsert >> columnCount [
	^ self numberByNumber: 70 default: 1.0
]

{ #category : #accessing }
DxfInsert >> columnCount: aNumber [
	self setCode: 44 data: aNumber
]

{ #category : #accessing }
DxfInsert >> columnSpacing [
	^ self numberByNumber: 44 default: 0.0
]

{ #category : #accessing }
DxfInsert >> columnSpacing: aNumber [
	self setCode: 70 data: aNumber
]

{ #category : #testing }
DxfInsert >> isMultiple [
	^ (self rowCount + self columnCount) > 2
]

{ #category : #accessing }
DxfInsert >> rowCount [
	^ self numberByNumber: 71 default: 1.0
]

{ #category : #accessing }
DxfInsert >> rowCount: aNumber [
	self setCode: 45 data: aNumber
]

{ #category : #accessing }
DxfInsert >> rowSpacing [
	^ self numberByNumber: 45 default: 0.0
]

{ #category : #accessing }
DxfInsert >> rowSpacing: aNumber [
	self setCode: 71 data: aNumber
]

{ #category : #'as yet unclassified' }
DxfInsert >> sampleDxf [
	^
'  0
INSERT
  5
200E1
330
1F
100
AcDbEntity
  8
0
100
AcDbBlockReference
  2
c
 10
100.2317059904219
 20
39.22294507575759
 30
0.0
 50
45.00000000000004
'
]

{ #category : #accessing }
DxfInsert >> scaleX [
	^ self numberByNumber: 41 default: 1.0
]

{ #category : #accessing }
DxfInsert >> scaleX: aNumber [
	self setCode: 41 data: aNumber
]

{ #category : #accessing }
DxfInsert >> scaleY [
	^ self numberByNumber: 42 default: 1.0
]

{ #category : #accessing }
DxfInsert >> scaleY: aNumber [
	self setCode: 42 data: aNumber
]

{ #category : #accessing }
DxfInsert >> scaleZ [
	^ self numberByNumber: 43 default: 1.0
]

{ #category : #accessing }
DxfInsert >> scaleZ: aNumber [
	self setCode: 43 data: aNumber
]
