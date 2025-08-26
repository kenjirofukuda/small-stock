Extension { #name : #'GDSreader_0_3_2' }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Pharo' }
GDSreader_0_3_2 class >> fullNameForTestGds [

	| dir |
	dir := FileSystem workingDirectory / 'GdsFeel'
	       / GDSreader_0_3_2 projectName.
	^ (dir / 'test.gds') fullName
]
