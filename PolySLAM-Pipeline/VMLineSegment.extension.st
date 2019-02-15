Extension { #name : #VMLineSegment }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMLineSegment >> asPSVertices [
	^ { PSVertex startOf: self. PSVertex endOf: self }
]
