Class {
	#name : #DxfTest,
	#superclass : #TestCase,
	#category : #'KFDxf-Tests'
}

{ #category : #'tests-accessing' }
DxfTest >> exampleDxfFilesDo: dxfFileBlock [
	DxfShapeTest qcadExamplesDxfFiles 
		do: [ :f |
			dxfFileBlock value: (DxfFile new file: f). 
			 ]
]
