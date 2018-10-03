Class {
	#name : #VMVectorQuadTreeNode,
	#superclass : #VMQuadTreeNode2,
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'class names' }
VMVectorQuadTreeNode class >> node [
	"returns the class that should be used for non-leaf nodes"
	^ VMVectorQuadTreeNode
]

{ #category : #adding }
VMVectorQuadTreeNode >> add: aVector [
	"similar to the point-based quad tree, but doesn't grow automatically to prevent infinit recursive loops"
	(rectangle containsPoint: aVector) ifTrue: [
		children do: [ :child |
			(child containsVector: aVector) ifTrue: [ child add: aVector ].
		].
		^self.
	].
	

]

{ #category : #adding }
VMVectorQuadTreeNode >> addAndGrow: aVector [
	"todo: grow until the vector is fully enclosed, then call #add on the top-level node only"
	((aVector pointA x < self left) or: [aVector pointB x < self left]) ifTrue: [ "grow left"
		((aVector pointA y < self top) or: [aVector pointB y < self top])
			ifTrue: [ "grow top left" ]
			ifFalse: [ "grow bottom left" ].
	].
	
	((aVector pointA x > self left) or: [aVector pointB x > self left]) ifTrue: [ "grow right"
		((aVector pointA y < self top) or: [aVector pointB y < self top])
			ifTrue: [ "grow top right" ]
			ifFalse: [ "grow bottom right" ].
	].
	
	((aVector pointA y < self top) or: [aVector pointB y < self top]) ifTrue: [ "grow upwards (into smaller values)"
	].
	
	((aVector pointA y < self top) or: [aVector pointB y < self top]) ifTrue: [ "grow downwards (into greater values)"
	].
	
	"don't grow at all - the vector is fully enclosed by the rectangle"
	^ self add: aVector
]
