Class {
	#name : #VMLineTypeObstacle,
	#superclass : #VMLineType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMLineTypeObstacle >> asInteger [
	^1.
]

{ #category : #'type hierarchy' }
VMLineTypeObstacle >> dominatesOverFrontier [
	^ true
]

{ #category : #'type hierarchy' }
VMLineTypeObstacle >> dominatesOverSector [
	^ true
]

{ #category : #testing }
VMLineTypeObstacle >> ifMergeableTypeDo: aBlock otherwiseDo: otherBlock [

	aBlock value.

]

{ #category : #testing }
VMLineTypeObstacle >> isFrontier [
	^false.
]

{ #category : #testing }
VMLineTypeObstacle >> isObstacle [
	^true.
]

{ #category : #testing }
VMLineTypeObstacle >> isSector [
	^false.
]

{ #category : #rendering }
VMLineTypeObstacle >> renderColor [
	^Color red
]

{ #category : #'type hierarchy' }
VMLineTypeObstacle >> useDominantType: aLineType [
	aLineType dominatesOverObstacle
		ifTrue: [ ^aLineType ].
	^ self
]
