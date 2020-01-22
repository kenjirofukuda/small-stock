"
A GdsGlyphExporter is support class for GDSII's TEXT Glyph development.

"
Class {
	#name : #GdsGlyphExporter,
	#superclass : #Object,
	#instVars : [
		'station'
	],
	#category : #'GdsFeel-Developer-Utility'
}

{ #category : #private }
GdsGlyphExporter class >> boundsForCompare [
	^ Rectangle 
		origin: 0 @ 0
		extent: 1600 @ 1600
]

{ #category : #private }
GdsGlyphExporter class >> fontDescription [
	KFFreeTypeSupport fixTTFontDescriptionNilProblem.
	^ nil "TTFontDescription default"
]

{ #category : #private }
GdsGlyphExporter class >> glyphStructureBaseNameFor: anAsciiCode [
	 ^(anAsciiCode radix: 8) padLeftTo: 3  with: $0.
]

{ #category : #service }
GdsGlyphExporter class >> outputGlyphs [
	"Cursor wait showWhile: [self outputGlyphs]"
	self new outputGlyphs.
]

{ #category : #private }
GdsGlyphExporter class >> printableAsciiCodes [
	"self printableAsciiCodes"
	^(16r21 to: 16r7E)
]

{ #category : #'as yet unclassified' }
GdsGlyphExporter >> createDatabase [
	(GdsLibrary exists: self dbName)
		ifFalse: [ GdsLibrary 
			initializeName: self dbName
			databaseUnits: 1000
			unitString: 'MM' ].	
]

{ #category : #'as yet unclassified' }
GdsGlyphExporter >> createGlyph: asciiValue on: aGdsStructure [ 
	| c glyph |
	c := Character value: asciiValue.
	glyph := self class fontDescription at: c.
	aGdsStructure currentItem layerNumber: 0;
		 putRectangle: self class boundsForCompare.
	aGdsStructure currentItem layerNumber: 1;
		 boundary.
	glyph contours
		do: [:ptArray | 
			ptArray
				do: [:ttPoint | aGdsStructure currentItem ce: ttPoint].
			aGdsStructure currentItem put].

]

{ #category : #'as yet unclassified' }
GdsGlyphExporter >> dbName [
	^'SAMPLE_GLYPHS'
]

{ #category : #'as yet unclassified' }
GdsGlyphExporter >> outputGlyphs [
	self createDatabase.
	station := GdsStation default.
	station openLibraryNamed: self dbName.
	self class printableAsciiCodes
		do: [:asciiValue | 
			| structure sname |
			sname := self class glyphStructureBaseNameFor: asciiValue.
			structure := station library structureNamed: sname.
			structure
				ifNil: [
					structure := station newStructureNamed: sname withActivate: true.
					self createGlyph: asciiValue on: structure.
					station closeStructure.]
				ifNotNil: [
					Transcript 
						cr; 
						show: ('***WARNING*** Already exported: {1}' format: {sname})].].
	station closeLibrary.
	station := nil.
]
