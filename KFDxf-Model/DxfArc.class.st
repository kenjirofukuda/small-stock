Class {
	#name : #DxfArc,
	#superclass : #DxfCircle,
	#category : #'KFDxf-Model'
}

{ #category : #'as yet unclassified' }
DxfArc >> endAngleDegress [
	^ self numberByNumber: 51 default: 0.0
]

{ #category : #'as yet unclassified' }
DxfArc >> startAngleDegress [
	^ self numberByNumber: 50 default: 0.0
]
