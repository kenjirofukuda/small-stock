Class {
	#name : #GplTree,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplTree class >> methodName [
	^'TREE'
]

{ #category : #handler }
GplTree >> evaluateToken: aToken [
	|  map |	
	self mustStructureOpen.
	map := self referenceNameBagMap.
	evaluator console 
		ifNil: [ map explore.]
		ifNotNil: [ self printMap: map ].		
	^self nullVector.
]

{ #category : #handler }
GplTree >> printMap: aDictionary [
	aDictionary keys allButFirst sort do: [ :level | | bag indentString line |
		bag := aDictionary at: level.
		bag sortedElements do: [ :assoc | 
			indentString := String new: (level - 1) * 2 withAll: Character space.
			line := String streamContents: [ :s |
				s nextPutAll: indentString.
				s nextPutAll: assoc key.
				s space.
				s nextPutAll: 'level='.
				s nextPutAll: level asString.
				s space.
				s nextPutAll: 'references'.
				s space.
				s nextPutAll: assoc value asString.												
			].
			evaluator console puts: line.
		].
	]

]

{ #category : #handler }
GplTree >> referenceNameBagMap [
	| map walker bag |
	map := Dictionary new.
	walker := GdsStructureWalker new.	
	walker walk: self structure do: [ :theStructure | 
		bag := map at: walker depth ifAbsentPut: [ Bag new ].
		bag add: theStructure name ]. 
	^ map
]
