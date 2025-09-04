as yet unclassified
readPrimitiveEnd: element

	| record points |
	record := reader nextRecord.
	#XY = record type ifFalse: [ 
		^ self abort: (self missingField: record type ofElement: element) ].
	points := record pointsDividedByDatabaseUnit: library databaseUnit.
	element vertices: points.
	record := reader nextRecord.
	#ENDEL = record type ifFalse: [ 
		^ self abort: (self missingField: record type ofElement: element) ]