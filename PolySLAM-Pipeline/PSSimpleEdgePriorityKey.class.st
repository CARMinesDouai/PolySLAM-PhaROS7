Class {
	#name : #PSSimpleEdgePriorityKey,
	#superclass : #PSKey,
	#instVars : [
		'edge'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSSimpleEdgePriorityKey >> compare: anotherKey [
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
PSSimpleEdgePriorityKey >> compareFrontier: anotherKey [
	|point|
	point := anotherKey edge centerPoint.
	(edge value isPointOnRightSide: point)
					ifTrue:[ ^ 1 ]
					ifFalse: [ ^ -1 ]
]

{ #category : #accessing }
PSSimpleEdgePriorityKey >> compareMixed: anotherKey [
	edge value isObstacle
		ifTrue: [ ^ -1 ].
	^ 1
	
]

{ #category : #accessing }
PSSimpleEdgePriorityKey >> compareObstacles: anotherKey [
	|point|
	point := anotherKey edge centerPoint.
	(edge value isPointOnLeftSide: point)
					ifTrue:[ ^ 1 ]
					ifFalse: [ ^ -1 ]
]

{ #category : #accessing }
PSSimpleEdgePriorityKey >> edge [
	^ edge
]

{ #category : #accessing }
PSSimpleEdgePriorityKey >> edge: anObject [
	edge := anObject
]

{ #category : #'instance creation' }
PSSimpleEdgePriorityKey >> from: value [
	edge := value
]