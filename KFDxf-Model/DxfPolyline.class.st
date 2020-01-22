Class {
	#name : #DxfPolyline,
	#superclass : #DxfShape,
	#instVars : [
		'vertexArray'
	],
	#category : #'KFDxf-Model'
}

{ #category : #testing }
DxfPolyline >> isClosed [
	^ (self polylineFlag bitAnd: 1) ~= 0
]

{ #category : #private }
DxfPolyline >> lookupVertexArray [
	^ (self splitByCode: 0) 
		select: [ :each | each first data sameAs: 'VERTEX' ]
		thenCollect: [ :each | DxfPrivateVertex new dataGroups: each ]
]

{ #category : #accessing }
DxfPolyline >> points [
	^ self vertexArray collect: [ :each | each asPoint]
]

{ #category : #accessing }
DxfPolyline >> polylineFlag [
	^ self commonFlag 
]

{ #category : #accessing }
DxfPolyline >> vertexArray [
	^ vertexArray ifNil: [ vertexArray := self  lookupVertexArray ]
]
