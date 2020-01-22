Class {
	#name : #GplChangeElement,
	#superclass : #GplCustomHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplChangeElement class >> handledSpecs [
	"self handledSpecs"
	^#('BOUNDARY' 'PATH' 'SREF' 'AREF')
		collect: [:commandName |
			GplCommandSpec new
				name: commandName;
				procedureArgumentTypes: {#niladic};
				functionArgumentTypes: {#niladic};				
				yourself]
]

{ #category : #'as yet unclassified' }
GplChangeElement >> niladicProcedurePath: aToken [
	self currentItem path.
	^self nullVector.
]
