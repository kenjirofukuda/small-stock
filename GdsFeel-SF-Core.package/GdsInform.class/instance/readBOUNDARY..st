element reader
readBOUNDARY: aGdsStructure

	| element loopContext record clazz |
	clazz := self elementClassForType: #boundary.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #boundary ]. 
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupBOUNDARYkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchBOUNDARY: record ].
	^ loopContext result