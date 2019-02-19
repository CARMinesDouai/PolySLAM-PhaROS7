Extension { #name : #VMLineSegment }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMLineSegment >> asPSLinkedEdge [
	^ PSLinkedEdge value:self
]
