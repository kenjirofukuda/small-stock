element reader
readPATH: aGdsStructure

	| element record loopContext clazz |
	clazz := self elementClassForType: #path.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #path ]. 	
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupPATHkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchPATH: record ].
	^ loopContext result