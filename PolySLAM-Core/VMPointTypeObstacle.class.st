Class {
	#name : #VMPointTypeObstacle,
	#superclass : #VMPointType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMPointTypeObstacle >> asInteger [
	^ 1
]

{ #category : #'as yet unclassified' }
VMPointTypeObstacle >> isObstacle [
	^ true
]

{ #category : #'as yet unclassified' }
VMPointTypeObstacle >> renderColor [
	^Color red
]
