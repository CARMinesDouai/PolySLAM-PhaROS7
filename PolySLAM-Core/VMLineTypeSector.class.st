Class {
	#name : #VMLineTypeSector,
	#superclass : #VMLineType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMLineTypeSector >> asInteger [
	^3.
]

{ #category : #'type hierarchy' }
VMLineTypeSector >> dominatesOverFrontier [
	^ true
]

{ #category : #testing }
VMLineTypeSector >> isFrontier [
	^false.
]

{ #category : #testing }
VMLineTypeSector >> isObstacle [
	^false.
]

{ #category : #testing }
VMLineTypeSector >> isSector [
	^true
]

{ #category : #rendering }
VMLineTypeSector >> renderColor [
	^Color r: 0.8 g: 0.8 b: 0.2
]

{ #category : #'type hierarchy' }
VMLineTypeSector >> useDominantType: aLineType [
	aLineType dominatesOverSector
		ifTrue: [ ^aLineType ].
	^ self
]
