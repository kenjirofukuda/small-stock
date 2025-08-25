Class {
	#name : #GdsInformTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-Model-StreamFormat-Tests'
}

{ #category : #tests }
GdsInformTest >> testSampleStreamFormatFile [

	| file |
	file := GdsInform sampleStreamFormatFile.
	self assert: file exists.
	self assert: file isFile.
	self assert: file basename equals: 'bghier.gds'.
	self assert: file parent basename equals: GDSreader_0_3_2 projectName.
	self
		assert: (MD5 hashStream: file binaryReadStream) hex
		equals: GDSreader_0_3_2 testGdsMD5sum
]
