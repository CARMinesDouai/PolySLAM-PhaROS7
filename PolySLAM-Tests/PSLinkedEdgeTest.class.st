Class {
	#name : #PSLinkedEdgeTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSLinkedEdgeTest >> testAngleWith [
	|l1 l2|
	l1 := PSLinkedEdge from: 1@1 to: 5@5  type:1. 
	l2 := PSLinkedEdge from: 5@1 to: 1@5  type:1.
	self assert: ((l1 angleWith: l2) = (Float pi / 2)).
	self assert: ((l2 angleWith: l1) = (Float pi / -2)).
	l2 := PSLinkedEdge from: 6@6 to: 8@8  type:1.
	self assert: ((l1 angleWith: l2) = 0).
]
