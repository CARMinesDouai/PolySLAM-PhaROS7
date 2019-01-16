Class {
	#name : #VMLineTypeFrontier,
	#superclass : #VMLineType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMLineTypeFrontier >> asInteger [
	^2.
]

{ #category : #testing }
VMLineTypeFrontier >> ifMergeableTypeDo: aBlock otherwiseDo: otherBlock [
	
	"this block is executed if the type is not an obstacle border, i.e. when it is a frontier."
	otherBlock value.

]

{ #category : #testing }
VMLineTypeFrontier >> isFrontier [
	^true.
]

{ #category : #testing }
VMLineTypeFrontier >> isObstacle [
	^false.
]

{ #category : #testing }
VMLineTypeFrontier >> isSector [
	^false.
]

{ #category : #rendering }
VMLineTypeFrontier >> renderColor [
	^Color green
]

{ #category : #'type hierarchy' }
VMLineTypeFrontier >> useDominantType: aLineType [
	aLineType dominatesOverFrontier
		ifTrue: [ ^aLineType ].
	^ self
]
