Extension { #name : #GdsAcArc }

{ #category : #'*GdsFeel-Magritte' }
GdsAcArc >> descriptionEndAngle [
	<magritteDescription>
	^ MANumberDescription new
		label: 'End Angle';
		accessor: #endAngleDegress;
		beReadOnly;
		priority: 142;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsAcArc >> descriptionStartAngle [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Start Angle';
		accessor: #startAngleDegress;
		beReadOnly;
		priority: 141;
		yourself	
]
