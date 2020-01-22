Class {
	#name : #DxfCircle,
	#superclass : #DxfPoint,
	#category : #'KFDxf-Model'
}

{ #category : #accessing }
DxfCircle >> radius [
	^ self numberByNumber: 40 default: 0.0
]
