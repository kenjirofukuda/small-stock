Class {
	#name : #TowerCalcMyql,
	#superclass : #Object,
	#category : #'TowerKit-Garage'
}

{ #category : #'as yet unclassified' }
TowerCalcMyql class >> configFile [
	| folder file |
	folder := './TowerCalc' asFileReference .
	folder ensureCreateDirectory.
	file := folder / 'config.json'.
	^ file
]

{ #category : #'as yet unclassified' }
TowerCalcMyql class >> configMap [
	"self configMap explore."
	self configFile isFile ifFalse: [ ^ nil ].
	self configFile readStreamDo: [ :s |
		^ (NeoJSONReader on: s) next
		 ].
	^ nil
]

{ #category : #'as yet unclassified' }
TowerCalcMyql class >> newConnection [

	^ GADriver connectToConnectionString: self connectionString 
]
