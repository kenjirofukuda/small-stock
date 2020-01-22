Extension { #name : #FileReference }

{ #category : #'*KFJapanese-GT' }
FileReference >> gtInspectorEUCJPContentsIn: composite [
	<gtInspectorPresentationOrder: 100>
	composite text
		title: 'EUC Contents';
		display: [ self
				readStreamDo: [ :stream | 
					| result |
					stream converter: (TextConverter newForEncoding: 'euc-jp').
					result := [ (stream next: 10000) asString ]
						on: Error
						do: [ (stream binary next: 10000) asString ].
					stream size > 10000
						ifTrue: [ result , '  ... truncated ...' ]
						ifFalse: [ result ] ] ];
		withLineNumbers: true;
		when: [ self isFile ]
]
