Class {
	#name : #GdsSqueakUI,
	#superclass : #Object,
	#category : #'GdsFeel-SF-UI-Squeak'
}

{ #category : #examples }
GdsSqueakUI class >> exampleStructureList [
	"self exampleStructureList"

	GdsInform sampleAtomicInstance  ifNotNil: [ :inform | | choosedNumber strucName  struct element | 
		inform run.
		choosedNumber := ListChooser chooseFrom: inform library structureNames title: 'choose structure'.
		choosedNumber = 0 ifTrue: [ ^ inform ].
		strucName := inform library structureNames at: choosedNumber.
		struct :=  inform library structureNamed: strucName.
		struct ifNil: [ ^ inform ].
		choosedNumber := ListChooser chooseFrom: struct elements title: 'choose elements'.
		choosedNumber = 0 ifTrue: [ ^ inform ].
		element := struct elements at: choosedNumber.
		element explore ].
 
]
