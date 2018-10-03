Class {
	#name : #VMPointTypeFrontier,
	#superclass : #VMPointType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMPointTypeFrontier >> asInteger [
	^ 2
]

{ #category : #'as yet unclassified' }
VMPointTypeFrontier >> isFrontier [
	^ true
]

{ #category : #'as yet unclassified' }
VMPointTypeFrontier >> renderColor [
	^Color green
]
