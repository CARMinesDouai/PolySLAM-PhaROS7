Class {
	#name : #VMPointType,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMPointType >> asInteger [
	^ 0
]

{ #category : #converting }
VMPointType >> asVMPointType [
	^ self
]

{ #category : #'as yet unclassified' }
VMPointType >> isFrontier [
	^ false
]

{ #category : #'as yet unclassified' }
VMPointType >> isObstacle [
	^ false
]

{ #category : #printing }
VMPointType >> printString [
	^ self asInteger printString
]

{ #category : #'as yet unclassified' }
VMPointType >> renderColor [
	^Color blue.
]
