Extension { #name : #VMLineSegment }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMLineSegment >> asPSLinkedEdge [
	^ PSLinkedEdge from: self pointA to: self pointB  type: self type 
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMLineSegment >> asPSLinkedEdgeOf: chain [
	^ PSLinkedEdge from: self pointA to: self pointB  type: self type chain: chain
]
