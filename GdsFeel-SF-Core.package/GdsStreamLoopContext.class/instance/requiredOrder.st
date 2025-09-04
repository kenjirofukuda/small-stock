validations
requiredOrder

	^ typeOrder
		  select: [ :each | each first = #required ]
		  thenCollect: [ :each | each second ]