Class {
	#name : #PSLinkedEdge,
	#superclass : #DoubleLink,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #converting }
PSLinkedEdge >> asPSVertices [
	^ { PSVertex startOf: self. PSVertex endOf: self }
]
