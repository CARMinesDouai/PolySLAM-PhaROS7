Class {
	#name : #VMLineTypeObstacle,
	#superclass : #VMLineType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLineTypeObstacle >> asInteger [
	^1.
]

{ #category : #'as yet unclassified' }
VMLineTypeObstacle >> ifMergeableTypeDo: aBlock otherwiseDo: otherBlock [

	aBlock value.

]

{ #category : #'as yet unclassified' }
VMLineTypeObstacle >> isFrontier [
	^false.
]

{ #category : #'as yet unclassified' }
VMLineTypeObstacle >> isObstacle [
	^true.
]

{ #category : #'as yet unclassified' }
VMLineTypeObstacle >> isSector [
	^false.
]

{ #category : #'as yet unclassified' }
VMLineTypeObstacle >> renderColor [
	^Color red
]
