"
A DxfSectionTest is a test class for testing the behavior of DxfSection
"
Class {
	#name : #DxfSectionTest,
	#superclass : #DxfTest,
	#category : #'KFDxf-Tests'
}

{ #category : #'tests-accessing' }
DxfSectionTest >> testAccadver [
	self exampleDxfFilesDo: [ :dxfFile |
		| accadver |
		accadver := (dxfFile sectionNamed: 'HEADER') accadver .
		self assert: (accadver beginsWith: 'AC').
		self inform: accadver ]
]
