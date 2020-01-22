Extension { #name : #GdsAcArc }

{ #category : #'*GdsFeel-Magritte' }
GdsAcArc >> descriptionEndAngle [
	<magritteDescription>
	^ MANumberDescription new
		label: 'End Angle';
		accessor: #endAngleDegress;
		beReadonly;
		priority: 142;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsAcArc >> descriptionStartAngle [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Start Angle';
		accessor: #startAngleDegress;
		beReadonly;
		priority: 141;
		yourself	
]
