Class {
	#name : #VMLineTypeFrontier,
	#superclass : #VMLineType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLineTypeFrontier >> asInteger [
	^2.
]

{ #category : #'as yet unclassified' }
VMLineTypeFrontier >> ifMergeableTypeDo: aBlock otherwiseDo: otherBlock [
	
	"this block is executed if the type is not an obstacle border, i.e. when it is a frontier."
	otherBlock value.

]

{ #category : #'as yet unclassified' }
VMLineTypeFrontier >> isFrontier [
	^true.
]

{ #category : #'as yet unclassified' }
VMLineTypeFrontier >> isObstacle [
	^false.
]

{ #category : #'as yet unclassified' }
VMLineTypeFrontier >> isSector [
	^false.
]

{ #category : #'as yet unclassified' }
VMLineTypeFrontier >> renderColor [
	^Color green
]
