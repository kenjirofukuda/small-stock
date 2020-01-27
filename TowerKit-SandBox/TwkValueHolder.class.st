Class {
	#name : #TwkValueHolder,
	#superclass : #TwkNode,
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkValueHolder class >> exapmpleInstances [
	<script>
	| template col |
	template := Dictionary
		newFromPairs: {'部材番号' . 1 . '部位' . '主柱材' . 'カラム' . 'G' . 'グループ1' . '応力係数' . 'value' . 2.89}.
	col := OrderedCollection new.
	#(2.89 3.22 3.98 4.73 5.39 5.95 6.43 6.87 7.00 6.81)
		doWithIndex: [ :v :i | 
			col
				add:
					(template copy
						at: '部材番号' put: i;
						at: 'value' put: v;
						yourself) ].
	#(0 0 0.49 1.42 2.24 2.92 3.52 4.07 4.45 . 4.63)
		doWithIndex: [ :v :i | 
			col
				add:
					(template copy
						at: 'カラム' put: 'C1'; 
						at: '部材番号' put: i;
						at: 'value' put: v;
						yourself) ].
	^ col explore
]
