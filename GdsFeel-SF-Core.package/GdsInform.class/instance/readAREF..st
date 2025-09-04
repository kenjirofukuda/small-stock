element reader
readAREF: aGdsStructure

	| loopContext element record clazz |
	clazz := self elementClassForType: #aref.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #aref ]. 
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupAREFkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchAREF: record ].
	^ loopContext result