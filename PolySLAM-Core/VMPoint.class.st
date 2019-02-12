"
VMPoint is a Point that additionally has a type associated with it. It also has a 'bounds' method which is helpfull for visualization via the VMViewer class.
"
Class {
	#name : #VMPoint,
	#superclass : #Point,
	#instVars : [
		'type'
	],
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMPoint class >> x: xCoord y: yCoord type: pointType [
^ (super x: xCoord y: yCoord)
	type: pointType
]

{ #category : #transforming }
VMPoint >> applyTransform: aVMTFMatrix [
	^ self transform: aVMTFMatrix
]

{ #category : #converting }
VMPoint >> asRenderableElement [
	^ VMPointRenderer model: self
]

{ #category : #accessing }
VMPoint >> bounds [
	^ VMRectangle origin: self corner: self
]

{ #category : #hooks }
VMPoint >> fuelAccept: aGeneralMapper [
	^ aGeneralMapper visitFixedObject: self
]

{ #category : #accessing }
VMPoint >> isFrontier [
	^ type isFrontier
]

{ #category : #accessing }
VMPoint >> isObstacle [
	^ type isObstacle
]

{ #category : #transforming }
VMPoint >> negated [
	"Answer a copy whose x and y coordinates are the negatives of those of the receiver."
	^ self species x: (0 - x) y: (0 - y) type: type
]

{ #category : #accessing }
VMPoint >> species [
	^ self class
]

{ #category : #transforming }
VMPoint >> transform: aVMTFMatrix [
	| tf |
	
	tf := aVMTFMatrix asVMTFMatrix.
	
	^ self species x: (
		((tf at: 1 at: 1) * x) + 
		((tf at: 1 at: 2) * y) + 
		(tf at: 1 at: 3)
	) y: (
		((tf at: 2 at: 1) * x) + 
		((tf at: 2 at: 2) * y) + 
		(tf at: 2 at: 3)
	) type: type.

]

{ #category : #accessing }
VMPoint >> type [
	^type
]

{ #category : #accessing }
VMPoint >> type: aVMPointType [
	type := aVMPointType asVMPointType.
]
