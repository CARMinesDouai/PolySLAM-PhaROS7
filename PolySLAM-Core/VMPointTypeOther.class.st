Class {
	#name : #VMPointTypeOther,
	#superclass : #VMPointType,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #converting }
VMPointTypeOther >> asInteger [
	^ 3
]

{ #category : #'as yet unclassified' }
VMPointTypeOther >> renderColor [
	^Color yellow
]
