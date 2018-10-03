Class {
	#name : #VMPointTypeIntersection,
	#superclass : #VMPointType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMPointTypeIntersection >> asInteger [
	^ 4
]

{ #category : #'as yet unclassified' }
VMPointTypeIntersection >> renderColor [
	^Color h: (50/360) s: 1.0 v: 1.0.
]
