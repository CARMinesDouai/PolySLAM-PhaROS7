Class {
	#name : #PSLinkedEdge,
	#superclass : #DoubleLink,
	#instVars : [
		'intersectionPoints',
		'chain'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #adding }
PSLinkedEdge >> addIntersectionPoint: vertex [
	intersectionPoints at: (self value pointA dist:vertex) put: vertex.
	
]

{ #category : #converting }
PSLinkedEdge >> asPSVertices [
	^ { PSVertex startOf: self. PSVertex endOf: self }
]

{ #category : #accessing }
PSLinkedEdge >> chain [
	^ chain
]

{ #category : #accessing }
PSLinkedEdge >> chain: anObject [
	chain := anObject
]

{ #category : #initialization }
PSLinkedEdge >> initialize [
	super initialize.
	intersectionPoints := BTree order: 4.
	
]

{ #category : #adding }
PSLinkedEdge >> nearestIntersectionPoint [
	intersectionPoints isEmpty ifTrue: [ ^nil ].
	^intersectionPoints first
]

{ #category : #adding }
PSLinkedEdge >> nextIntersectionOf: vertex [
	"find the next intersection point from a vertex"
	|d|
	d := self value pointA dist: vertex.
	intersectionPoints from:d keysAndValuesDo: [ :k :v| k = d ifFalse:[^ v]].
	^ self value pointB 
]
