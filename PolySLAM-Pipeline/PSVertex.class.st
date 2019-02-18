"
a normal Point, but with reference to the line segments it belongs to and type
"
Class {
	#name : #PSVertex,
	#superclass : #Point,
	#instVars : [
		'type',
		'segments'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'as yet unclassified' }
PSVertex class >> endOf: line [
	|o|
	o := self new.
	o setX: line pointB x setY: line pointB y.
	o type: 1.
	o segments add: line.
	^o
]

{ #category : #'as yet unclassified' }
PSVertex class >> intersectionOf: lineA and: lineB [
	|o p intersection|
	o := self new.
	intersection := VMIntersection intersectLine: lineA withLine: lineB.
	(intersection strictInsideLineASegment and: intersection strictInsideLineBSegment ) ifFalse: [ ^nil ].
	p := intersection intersectionPoint.
	o type: -1.
	o setX: p x setY: p y.
	o segments add: lineA; add: lineB.
	^o
]

{ #category : #'as yet unclassified' }
PSVertex class >> startOf: line [
	|o|
	o := self new.
	o setX: line pointA x setY: line pointA y.
	o type: 0.
	o segments add: line.
	^o
]

{ #category : #initialization }
PSVertex >> initialize [
	super initialize.
	type := 0.
	segments  := OrderedCollection new
]

{ #category : #testing }
PSVertex >> isEnd [
	^ type = 1
]

{ #category : #testing }
PSVertex >> isIntersection [
	^ type = -1
]

{ #category : #testing }
PSVertex >> isStart [
	^ type = 0
]

{ #category : #accessing }
PSVertex >> segments [
	^ segments
]

{ #category : #accessing }
PSVertex >> segments: anObject [
	segments := anObject
]

{ #category : #accessing }
PSVertex >> type [
	^ type
]

{ #category : #accessing }
PSVertex >> type: anObject [
	type := anObject
]
