"
A TwkMaterialResitoryTest is a test class for testing the behavior of TwkMaterialResitory
"
Class {
	#name : #TwkMaterialResitoryTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Core-Tests'
}

{ #category : #'tests-as yet unclassified' }
TwkMaterialResitoryTest >> testSplitMaterialName [
	| reg result |
	reg := TwkMaterialResitory new.
	result := reg splitMaterialName: 'L45x4'.
	self assert: (result = (Array with: 'L45x4' with: '1' with: #unkown)). 

	result := reg splitMaterialName: 'FB50x6'.
	self assert: (result = (Array with: 'FB50x6' with: '1' with: #unkown)). 
	
	result := reg splitMaterialName: '2L45x4'.
	
	self assert: (result = (Array with: 'L45x4' with: '2' with: #member)). 	
	
	result := reg splitMaterialName: 'M16-1'.
	self assert: (result = (Array with: 'M16' with: '1' with: #bolt)). 	
	
	result := reg splitMaterialName: 'M16-x'.
	self assert: (result = (Array with: 'M16' with: 'x' with: #bolt)). 		

	result := reg splitMaterialName: '-1'.
	self assert: (result = (Array with: '' with: '1' with: #bolt)). 		

	result := reg splitMaterialName: '-x'.
	self assert: (result = (Array with: '-x' with: '1' with: #unkown)). 		

]
