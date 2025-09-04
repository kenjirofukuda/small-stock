accessing
pointsScaledBy: aFacter

	| items numPoints offsetX offsetY |
	self deprecated: 'use pointsDividedByDatabaseUnit: '.
	items := self int4Array.
	numPoints := items size / 2.
	^ Array streamContents: [ :s | 
		  | dbPoint userPoint |
		  1 to: numPoints do: [ :index | 
			  offsetX := index - 1 * 2 + 1.
			  offsetY := offsetX + 1.
			  dbPoint := (items at: offsetX) @ (items at: offsetY).
			  userPoint := dbPoint / aFacter reciprocal.
			  s nextPut: userPoint ] ]