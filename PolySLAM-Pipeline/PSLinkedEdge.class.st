Class {
	#name : #PSLinkedEdge,
	#superclass : #DoubleLink,
	#instVars : [
		'nearestIntersection'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #adding }
PSLinkedEdge >> addIntersectionPoint: vertex [
	|d1 d2|
	nearestIntersection ifNil: [ ^ nearestIntersection := vertex ].
	d1 := self value pointA dist: nearestIntersection.
	d2 := self value pointA dist: vertex.
	d2 > d1 ifTrue: [ ^self  ].
	nearestIntersection := vertex
]

{ #category : #converting }
PSLinkedEdge >> asPSVertices [
	^ { PSVertex startOf: self. PSVertex endOf: self }
]

{ #category : #accessing }
PSLinkedEdge >> nearestIntersection [
	^ nearestIntersection
]

{ #category : #accessing }
PSLinkedEdge >> nearestIntersection: anObject [
	nearestIntersection := anObject
]
