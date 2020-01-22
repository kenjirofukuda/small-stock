Extension { #name : #DxfLayer }

{ #category : #'*KFDxf-Model-Deprecated' }
DxfLayer class >> lookupCode1 [
	<script>
	(((Soup fromString: ('http://sub-atomic.com/~moses/acadcolors.html' asZnUrl retrieveContents ))
		 findAllTags: [ :t | t name = 'tr' ]) allButFirst: 3 ) explore.
]

{ #category : #'*KFDxf-Model-Deprecated' }
DxfLayer class >> lookupColorMap [
	| map thElements |
	map := Dictionary new.
	thElements := ('http://sub-atomic.com/~moses/acadcolors.html' asZnUrl retrieveContents parseHTML
		allNodesSelect: [ :e | e name = 'th' ]) allButFirst: 9.
	thElements do: [ :th | map at: th contentString asInteger put: (Color colorFrom: (th attributeAt: 'bgcolor')) ].
	^ map
]

{ #category : #'*KFDxf-Model-Deprecated' }
DxfLayer class >> lookupColorStringMap [
	| map thElements |
	map := Dictionary new.
	thElements := ('http://sub-atomic.com/~moses/acadcolors.html' asZnUrl retrieveContents parseHTML
		allNodesSelect: [ :e | e name = 'th' ]) allButFirst: 9.
	thElements do: [ :th | map at: th contentString put: (th attributeAt: 'bgcolor') ].
	^ map
]
