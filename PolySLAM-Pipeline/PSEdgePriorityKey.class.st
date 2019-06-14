Class {
	#name : #PSEdgePriorityKey,
	#superclass : #PSKey,
	#instVars : [
		'edge',
		'baseline'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSEdgePriorityKey class >> from: anEdge baseline: aNotherEdge [
	|o|
	o := self from: anEdge.
	o baseline: aNotherEdge.
	^ o
]

{ #category : #accessing }
PSEdgePriorityKey >> baseline [
	^ baseline
]

{ #category : #accessing }
PSEdgePriorityKey >> baseline: anObject [
	baseline := anObject
]

{ #category : #accessing }
PSEdgePriorityKey >> compare: anotherKey [
	"	suppose two edge has the same origin (e.g. pointA), we select based on edge priority. Two edges are:
			+ obstacle: left edge has priority
			+ frontier: right edge has priority
			+ mixed: obstacle edge has priority
	TODO: incoporate polygon direction
	"
	edge = anotherKey edge
		ifTrue: [ ^0 ].
	((self edge value isObstacle) & (anotherKey edge value isObstacle))
	 	ifTrue:[^ self compareObstacles: anotherKey].
	((self edge value isFrontier) & (anotherKey edge value isFrontier ) )
		ifTrue:[^ self compareFrontier: anotherKey].
	
	^self compareMixed: anotherKey
	
]

{ #category : #accessing }
PSEdgePriorityKey >> compareFrontier: anotherKey [
	|angle1 angle2 point|
	(edge value pointA dist: anotherKey edge value pointA) <= 1e-6
		ifTrue:[
			angle1 := self baseline value deltaAngle: edge value.
			angle2 := self baseline value deltaAngle: anotherKey edge value.
	
			angle1 < angle2
				ifTrue:[^ -1]
			ifFalse:[^ 1].
		].
	point := anotherKey edge value pointB.
	(edge value isPointOnRightSide: point)
					ifTrue:[ ^ 1 ]
					ifFalse: [ ^ -1 ]
]

{ #category : #accessing }
PSEdgePriorityKey >> compareMixed: anotherKey [
	edge value isObstacle
		ifTrue: [ ^ -1 ].
	^ 1
	
]

{ #category : #accessing }
PSEdgePriorityKey >> compareObstacles: anotherKey [
	|angle1 angle2 point|
	
	(edge value pointA dist: anotherKey edge value pointA) <= 1e-6
		ifTrue:[
			angle1 := self baseline value deltaAngle: edge value.
			angle2 := self baseline value deltaAngle: anotherKey edge value.
			angle1 > angle2 ifTrue:[^ -1] ifFalse:[^ 1].
		].
	point := anotherKey edge value pointB.
	(edge value isPointOnLeftSide: point)
					ifTrue:[ ^ 1 ]
					ifFalse: [ ^ -1 ]
]

{ #category : #accessing }
PSEdgePriorityKey >> edge [
	^ edge
]

{ #category : #accessing }
PSEdgePriorityKey >> edge: anObject [
	edge := anObject
]

{ #category : #'instance creation' }
PSEdgePriorityKey >> from: value [
	edge := value
]
