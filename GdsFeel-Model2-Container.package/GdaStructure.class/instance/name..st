initialization
name: aStructureName

	name ifNotNil: [ ^ self error: 'structure name already set.' ].
	name := self coerceStructureName: aStructureName