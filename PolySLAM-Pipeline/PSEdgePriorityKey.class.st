Class {
	#name : #PSEdgePriorityKey,
	#superclass : #PSKey,
	#instVars : [
		'edge'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

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
	(edge value isPointOnRightSide: anotherKey edge value pointB)
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
	(edge value isPointOnLeftSide: anotherKey edge value pointB)
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
