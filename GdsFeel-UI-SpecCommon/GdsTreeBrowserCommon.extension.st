Extension { #name : #GdsTreeBrowserCommon }

{ #category : #'*GdsFeel-UI-SpecCommon' }
GdsTreeBrowserCommon class >> allDispose [
	<script>
	Cursor wait
		showWhile: [ 
			GdsStation quit.
			GdsStation initialize.
			GdsLibrary allInstancesDo: [ :l | l allDispose ].
			GdsStructure allInstancesDo: [ :l | l allDispose ].
			10 timesRepeat: [ Smalltalk garbageCollect ] ].
	SmalltalkImage current informSpaceLeftAfterGarbageCollection
]

{ #category : #'*GdsFeel-UI-SpecCommon' }
GdsTreeBrowserCommon class >> gdsMenuOn: aBuilder [

	<worldMenu>
	self class environment at: #GdsTreeBrowser 
		ifPresent: [ :clazz | 
			(aBuilder item: #'Tree Browser (Spec 1)')
				action: [ clazz new openWithSpec ];
				parent: #GdsFeel;
				yourself ].
	self class environment at: #GdsTreePresenter 
		ifPresent: [ :clazz | 
			(aBuilder item: #'Tree Browser (Spec 2)')
				action: [ clazz open ];
				parent: #GdsFeel;
				yourself ].
	(aBuilder item: #'All Dispose')
		action: [ self allDispose ];
		parent: #GdsFeel.
	(aBuilder item: #'Repair sample data')
		action: [ self repairSampleData ];
		parent: #GdsFeel.
		
]
