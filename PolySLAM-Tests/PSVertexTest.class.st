Class {
	#name : #PSVertexTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSVertexTest >> testGetPivot [
		|l1 l2 intersection pivot|
		l1 := PSLinkedEdge from: 2@2 to: 5@5  type: 1. 
		l2 := PSLinkedEdge from: 5@2 to: 3@5  type: 1.
		intersection := PSVertex intersectionOf: l1 and: l2. 
		pivot := intersection getOuterPivotLine.
		self assert: pivot = l1.
		pivot := intersection getInnerPivotLine.
		self assert: pivot = l2.
		l1 := PSLinkedEdge from: 2@2 to: 5@5  type: 2.
		intersection := PSVertex intersectionOf: l1 and: l2. 
		self assert: intersection getInnerPivotLine =l2.
		self assert: intersection getOuterPivotLine = l2.
		l2 := PSLinkedEdge from: 5@2 to: 3@5  type: 2.
		intersection := PSVertex intersectionOf: l1 and: l2.
		self assert: intersection getInnerPivotLine = l1.
		self assert: intersection getOuterPivotLine = l2.
		
		
]

{ #category : #tests }
PSVertexTest >> testGetPivotSpecialCase [
		|l1 l2 intersection pivot|
		l1 := PSLinkedEdge from: 2@2 to: 4@6  type: 1. 
		l2 := PSLinkedEdge from: 2@2 to: 6@4  type: 1.
		intersection := PSVertex intersectionOf: l1 and: l2.
		self assert: intersection getInnerPivotLine = l1.
		self assert: intersection getOuterPivotLine = l2.
		l2 := PSLinkedEdge from: 2@2 to: 6@4  type: 2.
		intersection := PSVertex intersectionOf: l1 and: l2.
		self assert: intersection getInnerPivotLine = l1.
		self assert: intersection getOuterPivotLine = l1.
		l1 := PSLinkedEdge from: 2@2 to: 4@6  type: 2.
		intersection := PSVertex intersectionOf: l1 and: l2.
		self assert: intersection getInnerPivotLine = l2.
		self assert: intersection getOuterPivotLine = l1.
		
]
