Class {
	#name : #VMLineTypeSector,
	#superclass : #VMLineType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLineTypeSector >> asInteger [
	^3.
]

{ #category : #'as yet unclassified' }
VMLineTypeSector >> isFrontier [
	^false.
]

{ #category : #'as yet unclassified' }
VMLineTypeSector >> isObstacle [
	^false.
]

{ #category : #'as yet unclassified' }
VMLineTypeSector >> isSector [
	^true
]

{ #category : #'as yet unclassified' }
VMLineTypeSector >> renderColor [
	^Color r: 0.8 g: 0.8 b: 0.2
]
