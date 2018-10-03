Class {
	#name : #VMRay,
	#superclass : #VMLine,
	#instVars : [
		'point',
		'direction'
	],
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'instance creation' }
VMRay class >> origin: aPoint direction: anotherPoint [
	"constructs a ray that starts at 'aPoint' and points towards 'anotherPoint'.
	note, that 'anotherPoint must not be 0@0, nor infinite in any coordinate.
	
	for example
	  VMRay origin: 2@2 direction: 1@0
	creates a ray that starts at 2@2 and points to the right (positive x-axis)"
	^(self new)
		pointA: aPoint;
		pointB: aPoint + anotherPoint;
		yourself.
]

{ #category : #'instance creation' }
VMRay class >> origin: aPoint direction: anotherPoint type: aType [
	"constructs a ray that starts at 'aPoint' and points towards 'anotherPoint'.
	note, that 'anotherPoint must not be 0@0, nor infinite in any coordinate.
	
	for example
	  VMRay origin: 2@2 direction: 1@0
	creates a ray that starts at 2@2 and points to the right (positive x-axis)"
	^(self new)
		pointA: aPoint;
		pointB: aPoint + anotherPoint;
		type: aType;
		yourself.
]

{ #category : #'rendering support' }
VMRay class >> rendererClass [
	^VMRayRenderer
]

{ #category : #conversion }
VMRay >> asVMRay [
	^self.
]

{ #category : #ToDo }
VMRay >> ifIntersectsWith: aLine do: aBlock [
	^aLine ifIntersectsWithRay: self do: aBlock.
]

{ #category : #ToDo }
VMRay >> ifIntersectsWithLine: aLine do: aBlock [
	self flag: #ToDo
]

{ #category : #intersecting }
VMRay >> ifIntersectsWithLineSeg: aLineSeg do: aBlock [
	
	^aLineSeg asVMLineSegment ifIntersectsWithRay: self do: aBlock.
	
]

{ #category : #ToDo }
VMRay >> ifIntersectsWithRay: aRay do: aBlock [
	"not implemented since it is not needed at the moment"
	self flag: #ToDo.
]

{ #category : #printing }
VMRay >> printString [
	^self class name,
		' origin: ',
		pointA printString,
		' direction: ',
		self direction printString.
]
