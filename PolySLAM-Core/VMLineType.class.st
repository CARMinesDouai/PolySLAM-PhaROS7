"
This class' instances define the type of a line segment (obstacle or frontier). It exists mostly to provide semantic value, but adds the ifMergeableTypeDo.... method for convinience. more methods may follow in the future.

at the moment we have only two possible types: obstacle borders (type 1) and frontiers (type 2). 

this class is derived from Integer for historic reasons. when shared through ROS messages, the line segment type will be represented by the integer value that this object holds.


public methods:
	- ifMergeableTypeDo: <Block 1> otherwiseDo: <Block 2>
		if the line segment type allows merging (i.e. if it is an obstacle border) then <Block 1> will be executed. otherwise <Block 2> will be executed.
"
Class {
	#name : #VMLineType,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLineType class >> fromInteger: anObject [
	| int |
	int := anObject asInteger.
	
	(int == 1) ifTrue: [
		^VMLineTypeObstacle new.
	].

	^VMLineTypeFrontier new.
]

{ #category : #comparing }
VMLineType >> = aType [
	"line types are considered equal if the are instances of the same class"
	^ aType asLineSegmentType class = self class
]

{ #category : #converting }
VMLineType >> asInteger [
	^0
]

{ #category : #converting }
VMLineType >> asLineSegmentType [
	^self
]

{ #category : #converting }
VMLineType >> asLineType [
	^ self asLineSegmentType
]

{ #category : #'type hierarchy' }
VMLineType >> dominatesOverFrontier [
	^ false
]

{ #category : #'type hierarchy' }
VMLineType >> dominatesOverObstacle [
	^ false
]

{ #category : #'type hierarchy' }
VMLineType >> dominatesOverSector [
	^ false
]

{ #category : #comparing }
VMLineType >> hash [
	^self asInteger hash
]

{ #category : #testing }
VMLineType >> ifMergeableTypeDo: aBlock otherwiseDo: otherBlock [
	self subclassResponsibility.
]

{ #category : #testing }
VMLineType >> isFrontier [
	^false
]

{ #category : #testing }
VMLineType >> isObstacle [
	^false
]

{ #category : #testing }
VMLineType >> isSector [
	^false
]

{ #category : #printing }
VMLineType >> printString [
	^ self asInteger printString, ' asLineSegmentType'
]

{ #category : #rendering }
VMLineType >> renderColor [
	^Color blue.
]

{ #category : #'type hierarchy' }
VMLineType >> useDominantType: aLineType [
	^ aLineType asLineSegmentType

]
